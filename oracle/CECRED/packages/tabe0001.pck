CREATE OR REPLACE PACKAGE CECRED.TABE0001 AS

  /*..............................................................................

    Programa: TABE0001
    Autor   : Marcos (Supero)
    Data    : Março/2012                     Ultima Atualizacao: 06/01/2017

    Dados referentes ao programa:

    Objetivo  : Agrupar funçoes e variaveis para buscas de configurações de telas e CRAPTAB

    Alterações: 30/08/2013 - Acrescentei a função UPPER no cursor cr_craptab para correta
                             utilização do índice craptab.craptab##craptab1 (Daniel - Supero)
                             
                             
				30/11/2015 - Ajustes de performace na leitura da craptab para nao utilizar
							 a ordenacao pelo progress_recid e sim pelo index da tabela
							 SD 318820(Odirlei-AMcom)                             

				08/06/2016 - Adicionado procedure generica para carregar os dados das contas 
							 bloqueadas (Douglas - Chamado 454248)

				10/10/2016 - Ajuste na rotina genérica de busca das informações da craptab 
							 para minimizar a quantidade de leituras (Rodrigo)

				06/01/2017 - Criação de nova rotina para busca de informações da craptab 
							 com tratamento de tabelas que podem conter NULOS (Rodrigo)
..............................................................................*/

  /* Função para busca do dstextab cfme parâmetros */
  FUNCTION fn_busca_dstextab(pr_cdcooper IN craptab.cdcooper%TYPE
                            ,pr_nmsistem IN craptab.nmsistem%TYPE
                            ,pr_tptabela IN craptab.tptabela%TYPE
                            ,pr_cdempres IN craptab.cdempres%TYPE
                            ,pr_cdacesso IN craptab.cdacesso%TYPE
                            ,pr_tpregist IN craptab.tpregist%TYPE) RETURN craptab.dstextab%TYPE;

  /* Função para busca do dstextab cfme parâmetros */
  PROCEDURE pc_busca_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                            ,pr_nmsistem IN craptab.nmsistem%TYPE
                            ,pr_tptabela IN craptab.tptabela%TYPE
                            ,pr_cdempres IN craptab.cdempres%TYPE
                            ,pr_cdacesso IN craptab.cdacesso%TYPE
                            ,pr_tpregist IN craptab.tpregist%TYPE
                            ,pr_flgfound OUT BOOLEAN                  --> Indicador de verificacao existencia craptab
                            ,pr_dstextab OUT craptab.dstextab%TYPE);

  /* Carregar os dados gravados na TAB030 */
  PROCEDURE pc_busca_tab030(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Coop
                           ,pr_cdagenci IN crapass.cdagenci%TYPE      --> Código da agência
                           ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE      --> Número do caixa
                           ,pr_cdoperad IN crapdev.cdoperad%TYPE      --> Código do Operador
                           ,pr_vllimite OUT NUMBER                    --> Limite
                           ,pr_vlsalmin OUT NUMBER                    --> Salário mínimo
                           ,pr_diasatrs OUT INTEGER                   --> Dias de atraso
                           ,pr_atrsinad OUT INTEGER                   --> Dias de atraso para inadimplencia
                           ,pr_des_reto OUT VARCHAR                   --> Indicador de saída com erro (OK/NOK)
                           ,pr_tab_erro OUT GENE0001.typ_tab_erro);  --> Tabela com erros) IS

  /* Carregar os dados das contas bloqueadas */
  PROCEDURE pc_carrega_ctablq(pr_cdcooper      IN craptab.cdcooper%TYPE           --> Codigo da Cooperativa
                             ,pr_nrdconta      IN crapass.nrdconta%TYPE DEFAULT 0 --> Numero da Conta (sera utilizado como craptab.cdacesso)
                             ,pr_tab_cta_bloq OUT APLI0001.typ_tab_ctablq);       --> Tabela para contas bloqueadas

END TABE0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TABE0001 AS

  /*..............................................................................

    Programa: TABE0001
    Autor   : Marcos (Supero)
    Data    : Março/2012                     Ultima Atualizacao: 06/01/2017

    Dados referentes ao programa:

    Objetivo  : Agrupar funçoes e variaveis para buscas de configurações de telas e CRAPTAB

				10/10/2016 - Ajuste na rotina genérica de busca das informações da craptab 
							 para minimizar a quantidade de leituras (Rodrigo)

				06/01/2017 - Criação de nova rotina para busca de informações da craptab 
							 com tratamento de tabelas que podem conter NULOS (Rodrigo)
  ..............................................................................*/
  
  /* Cursor genérico e padrão para busca da craptab */
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE
                   ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT
           craptab.dstextab,
           craptab.tpregist
      FROM craptab
     WHERE craptab.cdcooper        = pr_cdcooper
       AND UPPER(craptab.nmsistem) = pr_nmsistem
       AND UPPER(craptab.tptabela) = pr_tptabela
       AND craptab.cdempres        = pr_cdempres
       AND UPPER(craptab.cdacesso) = pr_cdacesso
       AND craptab.tpregist        = pr_tpregist;

  /* Variação do cursor genérico para busca da craptab 
     quando não informado cdacesso e/ou tpregist*/
  CURSOR cr_craptab2(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE
                   ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT /*+index_asc (tab CRAPTAB##CRAPTAB1)*/
           craptab.dstextab,
           craptab.tpregist
      FROM craptab
     WHERE craptab.cdcooper        = pr_cdcooper
       AND UPPER(craptab.nmsistem) = pr_nmsistem
       AND UPPER(craptab.tptabela) = pr_tptabela
       AND craptab.cdempres        = pr_cdempres
       AND UPPER(craptab.cdacesso) = NVL(pr_cdacesso, craptab.cdacesso)
       AND craptab.tpregist        = NVL(pr_tpregist, craptab.tpregist);

  /* Tratamento de erro */
  vr_des_erro   VARCHAR2(4000);
  vr_exc_erro   EXCEPTION;

  /* Descrição e código da critica */
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);

  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  /* Função para busca do dstextab cfme parâmetros */
  FUNCTION fn_busca_dstextab(pr_cdcooper IN craptab.cdcooper%TYPE
                            ,pr_nmsistem IN craptab.nmsistem%TYPE
                            ,pr_tptabela IN craptab.tptabela%TYPE
                            ,pr_cdempres IN craptab.cdempres%TYPE
                            ,pr_cdacesso IN craptab.cdacesso%TYPE
                            ,pr_tpregist IN craptab.tpregist%TYPE) RETURN craptab.dstextab%TYPE AS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_busca_dstextab
    --  Sistema  : Rotinas genéricas
    --  Sigla    : TABE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Março/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Este procedimento retornar o dstextab da craptab cfme parâmetros
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
    DECLARE
      -- Armazenar o retorno
      rw_craptab cr_craptab%ROWTYPE;
    BEGIN
      IF pr_cdacesso IS NOT NULL AND pr_tpregist IS NOT NULL THEN
        -- Efetuar busca com todos os parâmetros da chave
        OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                       ,pr_nmsistem => pr_nmsistem
                       ,pr_tptabela => pr_tptabela
                       ,pr_cdempres => pr_cdempres
                       ,pr_cdacesso => pr_cdacesso
                       ,pr_tpregist => pr_tpregist);
        FETCH cr_craptab
         INTO rw_craptab;
         
        IF cr_craptab%NOTFOUND THEN
          vr_des_erro := 'NOTFOUND';
        END IF;
         
        CLOSE cr_craptab;
      ELSE
        -- Efetuar busca no cursor com tratamento especial para nulos
        OPEN cr_craptab2(pr_cdcooper => pr_cdcooper
                        ,pr_nmsistem => pr_nmsistem
                        ,pr_tptabela => pr_tptabela
                        ,pr_cdempres => pr_cdempres
                        ,pr_cdacesso => pr_cdacesso
                        ,pr_tpregist => pr_tpregist);
        FETCH cr_craptab2
         INTO rw_craptab;
         
        IF cr_craptab2%NOTFOUND THEN
          vr_des_erro := 'NOTFOUND';
        END IF;
         
        CLOSE cr_craptab2;
      END IF;

      -- Retornar o rowtype encontrado
      RETURN rw_craptab.dstextab;
    END;
  END fn_busca_dstextab;

  /* Carregar os dados gravados na TAB030 */
  PROCEDURE pc_busca_tab030(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Coop
                           ,pr_cdagenci IN crapass.cdagenci%TYPE      --> Código da agência
                           ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE      --> Número do caixa
                           ,pr_cdoperad IN crapdev.cdoperad%TYPE      --> Código do Operador
                           ,pr_vllimite OUT NUMBER                    --> Limite
                           ,pr_vlsalmin OUT NUMBER                    --> Salário mínimo
                           ,pr_diasatrs OUT INTEGER                   --> Dias de atraso
                           ,pr_atrsinad OUT INTEGER                   --> Dias de atraso para inadimplencia
                           ,pr_des_reto OUT VARCHAR                   --> Indicador de saída com erro (OK/NOK)
                           ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --> Tabela com erros) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_busca_tab030 (Antigo sistema/generico/procedures/b1wgen0129.p --> busca_tab030)
    --  Sistema  : Rotinas genéricas
    --  Sigla    : TABE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Março/2013.                   Ultima atualizacao: 24/05/2013
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Carregar os dados gravados na TAB030
    --
    --   Alteracoes: 24/05/2013 - Incluido novo parametro "Dias atraso para
    --               inadimplencia" => pr_atrsinad. (Marcos-Supero)
    -- .............................................................................
    DECLARE
      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;
    BEGIN
      -- Buscar configuração na tabela
      vr_dstextab := fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                      ,pr_nmsistem => 'CRED'
                                      ,pr_tptabela => 'USUARI'
                                      ,pr_cdempres => 11
                                      ,pr_cdacesso => 'RISCOBACEN'
                                      ,pr_tpregist => 000);
      -- Se não encontrou nada
      IF vr_dstextab IS NULL THEN
        -- Gerar erro 55
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1  --> Fixo
                             ,pr_cdcritic => 55 --> Critica 55
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Retorno NOK
        pr_des_reto := 'NOK';
      ELSE
        -- Demembrar as informações necessárias
        pr_vllimite := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,3,9));
        pr_vlsalmin := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,13,11));
        pr_diasatrs := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,25,3));
        pr_atrsinad := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,29,4));
        -- Chegou ao final sem problemas
        pr_des_reto := 'OK';
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'TABE0001.pc_busca_tab030 --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_busca_tab030;

  /* Carregar os dados das contas bloqueadas */
  PROCEDURE pc_carrega_ctablq(pr_cdcooper      IN craptab.cdcooper%TYPE           --> Codigo da Cooperativa
                             ,pr_nrdconta      IN crapass.nrdconta%TYPE DEFAULT 0 --> Numero da Conta (sera utilizado como craptab.cdacesso)
                             ,pr_tab_cta_bloq OUT APLI0001.typ_tab_ctablq) IS     --> Tabela para contas bloqueadas
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_carrega_ctablq
    --  Sistema  : Rotinas genericas
    --  Sigla    : TABE
    --  Autor    : Douglas Quisinski
    --  Data     : Junho/2016                    Ultima atualizacao:   /  /
    --
    --  Dados referentes ao programa:
    --    - O indice da PL TABLE eh definido como: LPAD(cdacesso,12,'0')             -- Numero da conta com 12
    --                                             LPAD(SubStr(dstextab,1,7),8,'0')  -- Numero da aplicacao com 8
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Carregar as contas que possuem aplicacoes bloqueadas
    --
    --   Alteracoes: 
    -- .............................................................................
    DECLARE
      -- Cursor para listar todas as aplicacoes bloqueadas de todas as contas
      CURSOR cr_all_contas_bloqueadas (pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT tab.cdacesso
              ,tab.dstextab
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND UPPER(tab.nmsistem) = 'CRED'
           AND UPPER(tab.tptabela) = 'BLQRGT'
           AND tab.cdempres = 0
           AND tab.tpregist > 0
           AND TRIM(UPPER(tab.cdacesso)) IS NOT NULL;
    
      -- Cursor para listar todas as aplicacoes bloqueadas da conta em questao
      CURSOR cr_conta_bloqueada (pr_cdcooper IN craptab.cdcooper%TYPE
                                ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
        SELECT tab.cdacesso
              ,tab.dstextab
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND UPPER(tab.nmsistem) = 'CRED'
           AND UPPER(tab.tptabela) = 'BLQRGT'
           AND tab.cdempres = 0
           AND tab.tpregist > 0
           AND UPPER(tab.cdacesso) = pr_cdacesso;
           
      -- Indice da tabela
      vr_index_craptab VARCHAR2(20);

    BEGIN
      -- Limpar a tabela
      pr_tab_cta_bloq.DELETE;
      
      -- Verificar se existe conta informada
      IF pr_nrdconta > 0 THEN

        --Carregar tabela de memoria da conta informada
        FOR rw_conta IN cr_conta_bloqueada (pr_cdcooper => pr_cdcooper
                                           ,pr_cdacesso => LPAD(pr_nrdconta,10,'0')) LOOP
          --Montar indice para a tabela de memoria
          vr_index_craptab:= LPAD(rw_conta.cdacesso,12,'0')||LPAD(SubStr(rw_conta.dstextab,1,7),8,'0');
          --Incluir as contas bloqueadas no vetor de memoria
          pr_tab_cta_bloq(vr_index_craptab):= 0;
        END LOOP;
        
      ELSE
        
        --Carregar tabela de memoria de contas bloqueadas
        FOR rw_conta IN cr_all_contas_bloqueadas (pr_cdcooper => pr_cdcooper) LOOP
          --Montar indice para a tabela de memoria
          vr_index_craptab:= LPAD(rw_conta.cdacesso,12,'0')||LPAD(SubStr(rw_conta.dstextab,1,7),8,'0');
          --Incluir as contas bloqueadas no vetor de memoria
          pr_tab_cta_bloq(vr_index_craptab):= 0;
        END LOOP;
        
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Nao tratar as criticas
        -- Eh um Loop parar carregar as informacoes de 
        NULL;
    END;
  END pc_carrega_ctablq;

  /* Função para busca do dstextab cfme parâmetros */
  PROCEDURE pc_busca_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                            ,pr_nmsistem IN craptab.nmsistem%TYPE
                            ,pr_tptabela IN craptab.tptabela%TYPE
                            ,pr_cdempres IN craptab.cdempres%TYPE
                            ,pr_cdacesso IN craptab.cdacesso%TYPE
                            ,pr_tpregist IN craptab.tpregist%TYPE
                            ,pr_flgfound OUT BOOLEAN                --> Indicador de verificacao existencia craptab
                            ,pr_dstextab OUT craptab.dstextab%TYPE) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_busca_craptab
    --  Sistema  : Rotinas genéricas
    --  Sigla    : TABE
    --  Autor    : Rodrigo Siewerdt
    --  Data     : Janeiro/2017.              Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Carregar os dados gravados na craptab, verificando a existência
    --               do registro que está sendo pesquisado
    -- .............................................................................
    BEGIN
      vr_des_erro := '';
      pr_flgfound := TRUE;
      
      -- Buscar configuração na tabela
      pr_dstextab := fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                      ,pr_nmsistem => pr_nmsistem
                                      ,pr_tptabela => pr_tptabela
                                      ,pr_cdempres => pr_cdempres
                                      ,pr_cdacesso => pr_cdacesso
                                      ,pr_tpregist => pr_tpregist);
      -- Se não encontrou nada
      IF vr_des_erro = 'NOTFOUND' THEN
        pr_flgfound := FALSE;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_flgfound := FALSE;
    END;
  END pc_busca_craptab;

END TABE0001;
/
