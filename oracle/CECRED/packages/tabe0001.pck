CREATE OR REPLACE PACKAGE CECRED.TABE0001 AS

  /*..............................................................................

    Programa: TABE0001
    Autor   : Marcos (Supero)
    Data    : Março/2012                     Ultima Atualizacao: 30/08/2013

    Dados referentes ao programa:

    Objetivo  : Agrupar funçoes e variaveis para buscas de configurações de telas e CRAPTAB

    Alterações: 30/08/2013 - Acrescentei a função UPPER no cursor cr_craptab para correta
                             utilização do índice craptab.craptab##craptab1 (Daniel - Supero)
                             
                             
    30/11/2015 - Ajustes de performace na leitura da craptab para nao utilizar
                 a ordenacao pelo progress_recid e sim pelo index da tabela
                 SD 318820(Odirlei-AMcom)                             
..............................................................................*/

  /* Cursor genérico e padrão para busca da craptab */
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE
                   ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT /*+index_asc (tab CRAPTAB##CRAPTAB1)*/
           tab.dstextab,
           tab.tpregist
      from craptab tab
     where tab.cdcooper = pr_cdcooper
       and upper(tab.nmsistem) = pr_nmsistem
       and upper(tab.tptabela) = pr_tptabela
       and tab.cdempres = pr_cdempres
       and upper(tab.cdacesso) = nvl(pr_cdacesso, tab.cdacesso)
       and tab.tpregist = nvl(pr_tpregist, tab.tpregist);

  /* Função para busca do dstextab cfme parâmetros */
  FUNCTION fn_busca_dstextab(pr_cdcooper IN craptab.cdcooper%TYPE
                            ,pr_nmsistem IN craptab.nmsistem%TYPE
                            ,pr_tptabela IN craptab.tptabela%TYPE
                            ,pr_cdempres IN craptab.cdempres%TYPE
                            ,pr_cdacesso IN craptab.cdacesso%TYPE
                            ,pr_tpregist IN craptab.tpregist%TYPE) RETURN craptab.dstextab%TYPE;

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

END TABE0001;
/

CREATE OR REPLACE PACKAGE BODY CECRED.TABE0001 AS

  /*..............................................................................

    Programa: TABE0001
    Autor   : Marcos (Supero)
    Data    : Março/2012                     Ultima Atualizacao:

    Dados referentes ao programa:

    Objetivo  : Agrupar funçoes e variaveis para buscas de configurações de telas e CRAPTAB

  ..............................................................................*/

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
      -- Efetuar busca no cursor cfme os parâmetros passados
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => pr_nmsistem
                     ,pr_tptabela => pr_tptabela
                     ,pr_cdempres => pr_cdempres
                     ,pr_cdacesso => pr_cdacesso
                     ,pr_tpregist => pr_tpregist);
      FETCH cr_craptab
       INTO rw_craptab;
      CLOSE cr_craptab;
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

END TABE0001;
/

