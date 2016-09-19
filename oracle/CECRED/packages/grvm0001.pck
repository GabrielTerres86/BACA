CREATE OR REPLACE PACKAGE CECRED.GRVM0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: GRVM0001                        Antiga: b1wgen0171.p
  --  Autor   : Douglas Pagel
  --  Data    : Dezembro/2013                     Ultima Atualizacao: 02/04/2015
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente GRAVAMES
  --
  --  Alteracoes: 04/12/2013 - Conversao Progress para oracle (Douglas).
  --
  --              17/07/2014 - Liberacao da solicita_baixa_automatica apenas para CONCREDI (Guilherme/SUPERO)
  --
  --              29/08/2014 - Liberacao da solicita_baixa_automatica para CREDELESC (Guilherme/SUPERO)
  --
  --              05/12/2014 - Mudança no indice da GRV, inclusão do dschassi (Guilherme/SUPERO)
  --
  --              30/12/2014 - Liberação para as demais cooperativas(Guilherme/SUPERO)
  --
  --              05/03/2015 - Incluido UPPER e TRIM no dschassi (Guilherme/SUPERO)
  --
  --              31/03/2015 - Alterado para fazer Insert/Update na GRV antes da
  --                           geracao do arquivo. Geracao do arquivo faz "commit"
  --                           internamente (Guilherme/SUPERO)
  --              02/04/2015 - (Chamado 271753) - Não enviar baixas de bens ao Gravames quando 
  --                           o contrato está em prejuízo (Tiago Castro - RKAM).
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Definicação de tipo e tabela para o arquivo do GRAVAMES
  -- Antigo tt-dados-arquivos
  TYPE typ_reg_dados_arquivo IS
    RECORD (rowidbpr ROWID
           ,tparquiv VARCHAR2(12)
           ,cdoperac NUMBER
           ,cdcooper INTEGER
           ,nrdconta crapbpr.nrdconta%TYPE
           ,tpctrpro crapbpr.tpctrpro%TYPE
           ,nrctrpro crapbpr.nrctrpro%TYPE
           ,idseqbem crapbpr.idseqbem%TYPE

           ,cdfingrv crapcop.cdfingrv%TYPE
           ,cdsubgrv crapcop.cdsubgrv%TYPE
           ,cdloggrv crapcop.cdloggrv%TYPE
           ,nrseqlot INTEGER                /* Nr sequen Lote */
           ,nrseqreg INTEGER                /* Nr sequen Registro */
           ,dtmvtolt DATE                   /* Data atual Sistema  */
           ,hrmvtolt INTEGER                /* Hora atual */
           ,nmrescop crapcop.nmrescop%TYPE  /* Nome Cooperativa */

           ,dschassi crapbpr.dschassi%TYPE  /* Chassi do veículo        */
           ,tpchassi crapbpr.tpchassi%TYPE  /* Informaçao de remarcaçao */
           ,uflicenc crapbpr.uflicenc%TYPE  /* UF de licenciamento      */
           ,ufdplaca crapbpr.ufdplaca%TYPE  /* UF da placa              */
           ,nrdplaca crapbpr.nrdplaca%TYPE  /* Placa do veículo         */
           ,nrrenava crapbpr.nrrenava%TYPE  /* RENAVAM do veículo       */
           ,nranobem crapbpr.nranobem%TYPE  /* Ano de fabricaçao        */
           ,nrmodbem crapbpr.nrmodbem%TYPE  /* Ano do modelo            */
           ,nrctremp crawepr.nrctremp%TYPE  /* Número da operaçao       */
           ,dtoperad crawepr.dtmvtolt%TYPE  /* Data da Operacao         */
           ,nrcpfbem crapbpr.nrcpfbem%TYPE  /* CPF/CNPJ do cliente      */
           ,nmprimtl crapass.nmprimtl%TYPE  /* Nome do cliente          */
           ,qtpreemp crawepr.qtpreemp%TYPE  /* Quantidade de meses      */

           ,vlemprst crawepr.vlemprst%TYPE  /*  Valor principal da oper.           */
           ,vlpreemp crawepr.vlpreemp%TYPE  /*  Valor da parcela                   */
           ,dtdpagto crawepr.dtdpagto%TYPE  /*  Data de vencto prim. parc.   */
           ,dtvencto DATE                   /*  Data de vencto ult. parc.           */
           ,nmcidade crapage.nmcidade%TYPE  /*  Cidade da liberaçao da oper. */
           ,cdufdcop crapage.cdufdcop%TYPE  /*  UF da liberaçao da oper           */

           ,dsendcop crapcop.dsendcop%TYPE  /* Nome do logradouro           */
           ,nrendcop crapcop.nrendcop%TYPE  /* Número do imóvel           */
           ,dscomple crapcop.dscomple%TYPE  /* Complemento do imóvel */
           ,nmbaienc crapcop.nmbairro%TYPE  /* Bairro do imóvel           */
           ,cdcidenc crapmun.cdcidade%TYPE  /* Código do município   */
           ,cdufdenc crapcop.cdufdcop%TYPE  /* UF do imóvel               */
           ,nrcepenc crapcop.nrcepend%TYPE  /* CEP do imóvel               */
           ,nrdddenc VARCHAR2(10)           /* DDD do telefone        */
           ,nrtelenc crapcop.nrtelvoz%TYPE  /* DDD Número do telefone        */

           ,dsendere crapenc.dsendere%TYPE  /* Nome do logradouro    */
           ,nrendere crapenc.nrendere%TYPE  /* Número do imóvel      */
           ,complend crapenc.complend%TYPE  /* Complemento do imóvel */
           ,nmbairro crapenc.nmbairro%TYPE  /* Bairro do imóvel      */
           ,cdcidade crapmun.cdcidade%TYPE  /* Código do município   */
           ,cdufende crapenc.cdufende%TYPE  /* UF do imóvel          */
           ,nrcepend crapenc.nrcepend%TYPE  /* CEP do imóvel         */
           ,nrdddass VARCHAR2(10)           /* DDD do telefone       */
           ,nrtelass VARCHAR2(10)           /* Número do telefone    */

           ,inpessoa crapass.inpessoa%TYPE
           ,nrcpfcgc crapass.nrcpfcgc%TYPE);
  TYPE typ_tab_dados_arquivo IS
    TABLE OF typ_reg_dados_arquivo
      INDEX BY VARCHAR2(20); -- Chave composta por Cooper(5)+TpArquivo(1)+Sequencia(14)

  -- Cursor para verificar se ha algum BEM tipo AUTOMOVEL/MOTO/CAMINHAO
  CURSOR cr_crapbpr (pr_cdcooper crapbpr.cdcooper%type
                    ,pr_nrdconta crapbpr.nrdconta%type
                    ,pr_nrctrpro crapbpr.nrctrpro%type) IS
    SELECT crapbpr.tpdbaixa,
           crapbpr.rowid
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = 90
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.flgalien = 1
       AND (crapbpr.dscatbem LIKE '%AUTOMOVEL%'
        OR  crapbpr.dscatbem LIKE '%MOTO%'
        OR  crapbpr.dscatbem LIKE '%CAMINHAO%');
  rw_crapbpr cr_crapbpr%rowtype;

  -- Atualiza os dados conforme o cdorigem para geração de arquivos cyber
  PROCEDURE pc_solicita_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%type -- Código da Cooperativa
                                     ,pr_nrdconta IN crapbpr.nrdconta%type -- Numero da conta do associado
                                     ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato
                                     ,pr_dtmvtolt IN DATE                  -- Data de movimento para baixa
                                     ,pr_des_reto OUT VARCHAR2             -- Retorno OK ou NOK do procedimento
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro-- Retorno de erros em PlTable
                                     ,pr_cdcritic OUT PLS_INTEGER          -- Código de erro gerado em excecao
                                     ,pr_dscritic OUT VARCHAR2);         -- Descricao de erro gerado em excecao

  /* Geração dos arquivos do GRAVAMES */
  PROCEDURE pc_gravames_geracao_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa conectada
                                       ,pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Opção selecionada na tela
                                       ,pr_tparquiv  IN VARCHAR2              -- Tipo do arquivo selecionado na tela
                                       ,pr_dtmvtolt  IN DATE                  -- Data atual
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                       ,pr_dscritic OUT VARCHAR2);            -- Des Critica de erro

  /* Procedure para desfazer a solicitação de baixa automatica */
	PROCEDURE pc_desfazer_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
																				,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
																				,pr_nrctrpro IN crapbpr.nrctrpro%TYPE       -- Nr. contrato
																				,pr_des_reto OUT VARCHAR2                   -- Descrição de retorno OK/NOK
																				,pr_tab_erro OUT gene0001.typ_tab_erro);    -- Retorno de erros em PlTable

  END GRVM0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GRVM0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: GRVM0001                        Antiga: b1wgen0171.p
  --  Autor   : Douglas Pagel
  --  Data    : Dezembro/2013                     Ultima Atualizacao: 08/04/2016
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a GRAVAMES
  --
  --  Alteracoes: 04/12/2013 - Conversao Progress para oracle (Douglas).
  --
  --              08/04/2016 -  Ajuste na pc_gravames_geracao_arquivo para formatar
  --                            o número de telefone caso venha vazio, e também
  --                            foi tirado os caracteres especiais do nome da cidade
  --                            e do nome do bairro conforme solicitado no chamado
  --                            430323. (Kelvin) 
  ---------------------------------------------------------------------------------------------------------------
  -- Valida se é alienação fiduciaria
  PROCEDURE pc_valida_alienacao_fiduciaria (pr_cdcooper IN crapcop.cdcooper%type   -- Código da cooperativa
                                           ,pr_nrdconta IN crapass.nrdconta%type   -- Numero da conta do associado
                                           ,pr_nrctrpro IN PLS_INTEGER             -- Numero do contrato
                                           ,pr_des_reto OUT varchar2               -- Retorno Ok ou NOK do procedimento
                                           ,pr_dscritic OUT VARCHAR2               -- Retorno da descricao da critica do erro
                                           ,pr_tab_erro OUT gene0001.typ_tab_erro  -- Retorno da PlTable de erros
                                           ) IS
  -- ..........................................................................
    --
    --  Programa : pc_valida_alienacao_fiduciaria            Antigo: b1wgen0171.p/valida_eh_alienacao_fiduciaria

    --  Sistema  : Rotinas genericas para GRAVAMES
    --  Sigla    : GRVM
    --  Autor    : Douglas Pagel
    --  Data     : Dezembro/2013.                   Ultima atualizacao: 04/12/2013
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Retorna OK caso o contrato seja de alienacao fiduciaria
    --
    --   Alteracoes: 04/12/2013 - Conversao Progress para Oracle (Douglas Pagel).                           
    -- .............................................................................
    -- CURSORES

    -- Cursor para validacao da cooperativa conectada
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
      SELECT cdcooper
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;

    --Cursor para validar associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type) IS
      SELECT nrdconta
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;

    -- Cursor para verificar a proposta
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%type
                      ,pr_nrdconta crawepr.nrdconta%type
                      ,pr_nrctrpro crawepr.nrctremp%type) IS
      SELECT crawepr.cdcooper,
             crawepr.nrdconta,
             crawepr.nrctremp,
             crawepr.cdlcremp
        FROM crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctrpro;
    rw_crawepr cr_crawepr%rowtype;

    -- Cursor para validar a linha de credito da alienacao
    CURSOR cr_craplcr (pr_cdcooper craplcr.cdcooper%type
                      ,pr_cdlcremp craplcr.cdlcremp%type) IS
      SELECT cdcooper
        FROM craplcr
       WHERE craplcr.cdcooper = pr_cdcooper
         AND craplcr.cdlcremp = pr_cdlcremp
         AND craplcr.tpctrato = 2;
    rw_craplcr cr_craplcr%rowtype;

    -- cursor para validar se o contrato esta emprejuizo
    CURSOR cr_crapepr (pr_cdcooper crawepr.cdcooper%type
                      ,pr_nrdconta crawepr.nrdconta%type
                      ,pr_nrctrpro crawepr.nrctremp%type) IS
      SELECT epr.inprejuz
      FROM  crapepr epr
      WHERE epr.cdcooper = pr_cdcooper
      AND   epr.nrdconta = pr_nrdconta
      AND   epr.nrctremp = pr_nrctrpro
      AND   epr.inprejuz = 1; --prejuizo
    rw_crapepr cr_crapepr%ROWTYPE;
    
    
    -- VARIÁVEIS
    vr_cdcritic PLS_INTEGER := 0; -- Variavel interna para erros
    vr_dscritic varchar2(4000) := ''; -- Variavel interna para erros
    BEGIN
      -- Verifica cooperativa
      OPEN cr_crapcop (pr_cdcooper);
      FETCH cr_crapcop
        INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        pr_des_reto := 'NOK';
        vr_cdcritic := 794;
        gene0001.pc_gera_erro(pr_cdcooper => 3
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        CLOSE cr_crapcop;
        RETURN;
      END IF;
      CLOSE cr_crapcop;

      -- Verifica associado
      IF pr_nrdconta = 0 THEN
        pr_des_reto := 'NOK';
        vr_cdcritic := 0;
        vr_dscritic := ' Informar o numero da Conta" ';
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      END IF;

      OPEN cr_crapass (pr_cdcooper,
                       pr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        pr_des_reto := 'NOK';
        vr_cdcritic := 9;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        CLOSE cr_crapass;
        RETURN;
      END IF;
      CLOSE cr_crapass;

      -- Verifica a proposta
      OPEN cr_crawepr(pr_cdcooper, pr_nrdconta, pr_nrctrpro);
      FETCH cr_crawepr
        INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        vr_cdcritic := 356;
        vr_dscritic := '';
        pr_des_reto := 'NOK';
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        CLOSE cr_crawepr;
        RETURN;
      END IF;

      --verifica se contrato esta em prejuizo
      OPEN cr_crapepr(rw_crawepr.cdcooper,      
                      rw_crawepr.nrdconta,
                      rw_crawepr.nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      IF cr_crapepr%FOUND THEN
        pr_des_reto := 'NOK';
        CLOSE cr_crapepr;
        RETURN;
      END IF;
      CLOSE cr_crapepr;      

      -- Verifica a linha de credito
      OPEN cr_craplcr(rw_crawepr.cdcooper,
                      rw_crawepr.cdlcremp);
      FETCH cr_craplcr
        INTO rw_craplcr;
      IF cr_craplcr%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := ' Linha de Credito invalida para essa operacao! ';
        pr_des_reto := 'NOK';
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        CLOSE cr_craplcr;
        RETURN;
      END IF;
      CLOSE cr_craplcr;
      
      -- Verifica se ha algum BEM tipo AUTOMOVEL/MOTO/CAMINHAO
      OPEN cr_crapbpr(rw_crawepr.cdcooper,
                      rw_crawepr.nrdconta,
                      rw_crawepr.nrctremp);
      FETCH cr_crapbpr
        INTO rw_crapbpr;
      IF cr_crapbpr%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := ' Proposta sem Bem valido ou Bem nao encontado! ';
        pr_des_reto := 'NOK';
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        CLOSE cr_crapbpr;
        RETURN;
      END IF;
      CLOSE cr_crapbpr;


      CLOSE cr_crawepr;
      -- Se não ocorreram criticas anteriores, retorna OK e volta para o programa chamador
      pr_des_reto := 'OK';
      RETURN;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado na grvm0001.pc_valida_alienacao_fiduciaria';
        pr_des_reto := 'NOK';
        RETURN;
    END; --  pc_valida_alienacao_fiduciaria

  /* Atualizar bens da proposta para tipo de baixa = 'A'. */
  PROCEDURE pc_solicita_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%type -- Código da Cooperativa
                                        ,pr_nrdconta IN crapbpr.nrdconta%type -- Numero da conta do associado
                                        ,pr_nrctrpro IN crapbpr.nrctrpro%type -- Numero do contrato
                                        ,pr_dtmvtolt IN DATE                  -- Data de movimento para baixa
                                        ,pr_des_reto OUT VARCHAR2             -- Retorno OK ou NOK do procedimento
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro-- Retorno de erros em PlTable
                                        ,pr_cdcritic OUT PLS_INTEGER          -- Código de erro gerado em excecao
                                        ,pr_dscritic OUT VARCHAR2) IS         -- Descricao de erro gerado em excecao

    -- ..........................................................................
    --
    --  Programa : pc_solicita_baixa_automatica            Antigo: b1wgen0171.p/solicita_baixa_automatica

    --  Sistema  : Rotinas genericas para GRAVAMES
    --  Sigla    : GRVM
    --  Autor    : Douglas Pagel
    --  Data    : Dezembro/2013                     Ultima Atualizacao: 02/04/2015
    --
    --  Dados referentes ao programa:
    --
    --  Objetivo  : Package referente GRAVAMES
    --
    --  Alteracoes: 04/12/2013 - Conversao Progress para oracle (Douglas).
    --
    --              17/07/2014 - Liberacao da solicita_baixa_automatica apenas para
    --                           CONCREDI (Guilherme/SUPERO)
    --
    --              29/08/2014 - Liberacao da solicita_baixa_automatica para CREDELESC
    --                           (Guilherme/SUPERO)
    --
    --              13/10/2014 - Liberacao da solicita_baixa_automatica para VIACREDI
    --                           (Guilherme/SUPERO)
    --
    --              30/12/2014 - Liberação para as demais cooperativas(Guilherme/SUPERO)
    --
    --              02/04/2015 - (Chamado 271753) - Não enviar baixas de bens ao Gravames quando 
    --                           o contrato está em prejuízo (Tiago Castro - RKAM).
    -- .............................................................................

    -- VARIÁVEIS
    -- Variaveis locais para retorno de erro
    vr_des_reto varchar2(4000);
    vr_dscritic VARCHAR2(4000);
    vr_tab_erro gene0001.typ_tab_erro;


  BEGIN
/*
    -- Irlan: Funcao bloqueada temporariamente, apenas COOPs 1, 4, 7
    IF  pr_cdcooper <> 1       --> 1 - VIACREDI
    AND pr_cdcooper <> 4       --> 4 - CONCREDI
    AND pr_cdcooper <> 7  THEN --> 7 - CREDCREA
        pr_des_reto := 'OK';
        RETURN;
    END IF;
*/
    -- Valida se eh alienacao fiduciaria
    pc_valida_alienacao_fiduciaria( pr_cdcooper => pr_cdcooper   -- Código da cooperativa
                                   ,pr_nrdconta => pr_nrdconta   -- Numero da conta do associado
                                   ,pr_nrctrpro => pr_nrctrpro   -- Numero do contrato
                                   ,pr_des_reto => vr_des_reto   -- Retorno Ok ou NOK do procedimento
                                   ,pr_dscritic => vr_dscritic   -- Retorno da descricao da critica do erro
                                   ,pr_tab_erro => vr_tab_erro);  -- Retorno de PlTable com erros
    /** OBS: Sempre retornara OK pois a chamada da solicita_baixa_automatica
             nos CRPS171,CRPS078,CRPS120_1,B1WGEN0136, nesses casos nao pode
             impedir de seguir para demais contratos. **/
    IF vr_des_reto <> 'OK' THEN
      pr_des_reto := 'OK'; -- PASSA ok para o parametro de retorno
      RETURN; -- Retorna para o programa chamador.
    END IF;

    -- Para cada bem da proposta
    OPEN cr_crapbpr(pr_cdcooper,
                    pr_nrdconta,
                    pr_nrctrpro);
    LOOP
      FETCH cr_crapbpr
        INTO rw_crapbpr;
      EXIT WHEN cr_crapbpr%NOTFOUND;

      -- Se foi feito baixa manual
      IF rw_crapbpr.tpdbaixa = 'M' THEN
        -- Passa para proximo bem
        CONTINUE;
      END IF;

      -- Atualiza registro para baixa automatica
      BEGIN
        UPDATE crapbpr
           SET crapbpr.flgbaixa = 1,
               crapbpr.dtdbaixa = pr_dtmvtolt,
               crapbpr.tpdbaixa = 'A'
         WHERE crapbpr.rowid = rw_crapbpr.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao atualizar registro na crapbpr: ' || sqlerrm;
          CLOSE cr_crapbpr;
          return;
      END;
    END LOOP;
    CLOSE cr_crapbpr;
    pr_des_reto := 'OK';
    RETURN;

  EXCEPTION
      WHEN others THEN
        -- Gerar erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na pc_solicita_baixa_automatica';
        RETURN;
  END; -- pc_solicita_baixa_automatica;

  /* Manutenção do arquivo de Baixa ou Cancelamento do GRAVAMES */
  PROCEDURE pc_gravames_gerac_arqs_bxa_cnc(pr_flgfirst        IN BOOLEAN                       --> Flag de primeiro registro
                                          ,pr_fllastof        IN BOOLEAN                       --> Flag de ultimo registro
                                          ,pr_reg_dado_arquiv IN typ_reg_dados_arquivo         --> Registro com as informações atuais
                                          ,pr_clobaux         IN OUT NOCOPY VARCHAR2           --> Varchar2 de Buffer para o arquivo
                                          ,pr_clobarq         IN OUT NOCOPY CLOB               --> CLOB para as informações do arquivo
                                          ,pr_nrseqreg        IN OUT NUMBER                    --> Sequncial das informações
                                          ,pr_dscritic         OUT VARCHAR2) IS                 --> Saida de erro
  /* .............................................................................
     Programa: pc_gravames_gerac_arqs_bxa_cnc          Antigos: b1wgen0171.p/gravames_geracao_arquivo_baixa e gravames_geracao_arquivo_cancelamento
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Guilherme/SUPERO
     Data    : Agosto/2013                     Ultima atualizacao:  05/11/2014

     Dados referentes ao programa:

     Frequencia:  Diario (on-line)
     Objetivo  : Gerar arquivos GRAVAMES - Baixa e Cancelamento

     Alteracoes: 05/11/2014 - Conversão Progress para Oracle (Marcos-Supero)
    ............................................................................. */
  BEGIN
    DECLARE
      vr_set_linha VARCHAR2(32767); --> Auxiliar para montagem da linha
    BEGIN
      -- Para o primeiro registro
      IF pr_flgfirst THEN
        -- Inicializar contador registros
        pr_nrseqreg := 1;
        -- ****** HEADER CONTROLE ARQUIVO  *******
        -- Header conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante do Header
        vr_set_linha := vr_set_linha
                     || '000        00000000000000HEADER DE CONTROLE   '
                     || rpad(' ',34,' ')
                     || rpad(' ',3,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || rpad(' ',14,' ')
                     || '*'
                     || chr(10); --Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
        -- ****** HEADER ENVIO LOTE        *******
        -- Header conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante das informações
        vr_set_linha := vr_set_linha
                     || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                     || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                     || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                     || to_char(pr_nrseqreg,'fm000000')
                     || '0'
                     || RPAD(SUBSTR('HEADER ' || pr_reg_dado_arquiv.nmrescop,1,21),21,' ')
                     || RPAD(' ',34,' ')
                     || RPAD(' ',3,' ')
                     || RPAD(' ',8,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                     || '*'
                     || chr(10); -- Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
      END IF;
      -- Incrementar sequencia
      pr_nrseqreg := pr_nrseqreg + 1;
      -- ****** DETALHE ENVIO LOTE       *******
      -- Detalhe conforme o codigo da financeira do gravames da coop
      IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
        vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
      ELSE
        vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
      END IF;
      -- Restante das informações
      vr_set_linha := vr_set_linha
                   || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                   || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                   || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                   || to_char(pr_nrseqreg,'fm000000')
                   || '0'
                   || rpad(substr(pr_reg_dado_arquiv.dschassi,1,21),21,' ')
                   || substr(to_char(pr_reg_dado_arquiv.nrrenava,'fm000000000000'),2,11)
                   || rpad(substr(pr_reg_dado_arquiv.nrdplaca,1,7),7,' ')
                   || rpad(substr(pr_reg_dado_arquiv.uflicenc,1,2),2,' ')
                   || to_char(pr_reg_dado_arquiv.nrcpfbem,'fm00000000000000')
                   || RPAD(' ',3,' ')
                   || RPAD(' ',8,' ')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                   || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                   || '*'
                   || chr(10); -- Quebra
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      -- Para o ultimo registro do arquivo
      IF pr_fllastof THEN
        -- ****** TRAILLER ENVIO LOTE       *******
        pr_nrseqreg := pr_nrseqreg + 1;
        -- Trailler conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante das informações
        vr_set_linha := vr_set_linha
                     || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                     || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                     || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                     || to_char(pr_nrseqreg,'fm000000')
                     || '0'
                     || RPAD(SUBSTR('TRAILLER ' || pr_reg_dado_arquiv.nmrescop,1,21),21,' ')
                     || TO_CHAR(pr_nrseqreg,'fm000000000') -- Qtde detalhes + Head e Trail do Lote
                     || RPAD(' ',25,' ')
                     || RPAD(' ',3,' ')
                     || RPAD(' ',8,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                     || '*'
                     || chr(10); -- Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

        -- ****** TRAILLER CONTROLE ARQUIVO *******
        -- Trailler conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante do Header
        vr_set_linha := vr_set_linha
                     || '999'
                     || '99999999'
                     || '9999999'
                     || '999999'
                     || '0'
                     || 'TRAILLER DE CONTROLE '
                     || to_char(pr_nrseqreg+2,'fm000000000') -- Qtde detalhes + Head e Trail do Lote + Head e Trail do Controle geral
                     || rpad(' ',25,' ')
                     || rpad(' ',3,' ')
                     || rpad(' ',22,' ')
                     || '*'
                     || chr(10); --Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina GRVM0001.pc_gravames_gerac_arq_baixa -> '||SQLERRM;
    END;
  END pc_gravames_gerac_arqs_bxa_cnc;

  /* Manutenção do arquivo de Inclusão do GRAVAMES */
  PROCEDURE pc_gravames_gerac_arq_inclus(pr_flgfirst        IN BOOLEAN                       --> Flag de primeiro registro
                                        ,pr_fllastof        IN BOOLEAN                       --> Flag de ultimo registro
                                        ,pr_reg_dado_arquiv IN typ_reg_dados_arquivo         --> Registro com as informações atuais
                                        ,pr_clobaux         IN OUT NOCOPY VARCHAR2           --> Varchar2 de Buffer para o arquivo
                                        ,pr_clobarq         IN OUT NOCOPY CLOB               --> CLOB para as informações do arquivo
                                        ,pr_nrseqreg        IN OUT NUMBER                    --> Sequncial das informações
                                        ,pr_dscritic         OUT VARCHAR2) IS                 --> Saida de erro
  /* .............................................................................
     Programa: pc_gravames_gerac_arq_inclus          Antigo: b1wgen0171.p/gravames_geracao_arquivo_inclusao
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Guilherme/SUPERO
     Data    : Agosto/2013                     Ultima atualizacao:  05/11/2014

     Dados referentes ao programa:

     Frequencia:  Diario (on-line)
     Objetivo  : Gerar arquivos GRAVAMES - Inclusão

     Alteracoes: 05/11/2014 - Conversão Progress para Oracle (Marcos-Supero)
    ............................................................................. */
  BEGIN
    DECLARE
      vr_set_linha VARCHAR2(32767); --> Auxiliar para montagem da linha
    BEGIN
      -- Para o primeiro registro
      IF pr_flgfirst THEN
        -- Inicializar contador
        pr_nrseqreg := 1;
        -- ****** HEADER CONTROLE ARQUIVO  *******
        -- Header conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante do Header
        vr_set_linha := vr_set_linha
                     || '000        00000000000000HEADER DE CONTROLE   '
                     || rpad(' ',624,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || rpad(' ',14,' ')
                     || '*'
                     || chr(10); --Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
        -- ****** HEADER ENVIO LOTE        *******
        -- Header conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante das informações
        vr_set_linha := vr_set_linha
                     || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                     || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                     || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                     || to_char(pr_nrseqreg,'fm000000')
                     || '0'
                     || RPAD(SUBSTR('HEADER ' || pr_reg_dado_arquiv.nmrescop,1,21),21,' ')
                     || RPAD(' ',632,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                     || '*'
                     || chr(10); -- Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
      END IF;
      -- Incrementar sequencia
      pr_nrseqreg := pr_nrseqreg + 1;
      -- ****** DETALHE ENVIO LOTE       *******
      -- Detalhe conforme o codigo da financeira do gravames da coop
      IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
        vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
      ELSE
        vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
      END IF;
      -- Restante das informações
      vr_set_linha := vr_set_linha
                   || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                   || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                   || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                   || to_char(pr_nrseqreg,'fm000000')
                   || '0'
                   || rpad(substr(pr_reg_dado_arquiv.dschassi,1,21),21,' ')
                   || substr(pr_reg_dado_arquiv.tpchassi,1,1)
                   || rpad(substr(pr_reg_dado_arquiv.uflicenc,1,2),2,' ')
                   || rpad(substr(pr_reg_dado_arquiv.ufdplaca,1,2),2,' ')
                   || rpad(substr(pr_reg_dado_arquiv.nrdplaca,1,7),7,' ')
                   ||substr(to_char(pr_reg_dado_arquiv.nrrenava,'fm000000000000'),2,11)
                   || to_char(pr_reg_dado_arquiv.nranobem,'fm0000')
                   || to_char(pr_reg_dado_arquiv.nrmodbem,'fm0000')
                   || to_char(pr_reg_dado_arquiv.nrctremp,'fm00000000000000000000')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                   || '03'
                   || to_char(pr_reg_dado_arquiv.nrcpfbem,'fm00000000000000')
                   || rpad(substr(pr_reg_dado_arquiv.nmprimtl,1,40),40,' ')
                   || to_char(pr_reg_dado_arquiv.qtpreemp,'fm000')
                   || rpad(' ',11,' '); -- Sem Quebra pois as linhas abaixo são continuação
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      -- ****** DADOS COMPLEMENTARES     *******
      vr_set_linha := rpad(' ',6,' ')
                   || rpad('0',6,'0')
                   || rpad('0',6,'0')
                   || rpad('0',6,'0')
                   || rpad('0',9,'0')
                   || rpad('0',9,'0')
                   || 'NAO'
                   || 'NAO'
                   || to_char(pr_reg_dado_arquiv.vlemprst,'fm000000000')
                   || to_char(pr_reg_dado_arquiv.vlpreemp,'fm000000000')
                   || to_char(pr_reg_dado_arquiv.dtdpagto,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtdpagto,'mm')
                   || to_char(pr_reg_dado_arquiv.dtdpagto,'dd')
                   || to_char(pr_reg_dado_arquiv.dtvencto,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtvencto,'mm')
                   || to_char(pr_reg_dado_arquiv.dtvencto,'dd')
                   || rpad(substr(pr_reg_dado_arquiv.nmcidade,1,25),25,' ')
                   || rpad(substr(pr_reg_dado_arquiv.cdufdcop,1,2),2,' ')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                   || 'PRE-FIXADO'
                   || rpad(' ',65,' ')
                   || rpad('0',6,'0')
                   || rpad('0',9,'0')
                   || 'NAO'
                   || rpad(' ',50,' ')
                   || 'NAO'
                   || rpad('0',9,'0'); -- Sem quebra
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      --****** DADOS CREDOR             *******
      vr_set_linha := rpad(substr(pr_reg_dado_arquiv.dsendcop,1,30),30,' ')
                   || to_char(pr_reg_dado_arquiv.nrendcop,'fm00000')
                   || rpad(substr(pr_reg_dado_arquiv.dscomple,1,20),20,' ')
                   || rpad(substr(pr_reg_dado_arquiv.nmbaienc,1,20),20,' ')
                   || to_char(pr_reg_dado_arquiv.cdcidenc,'fm0000')
                   || rpad(substr(pr_reg_dado_arquiv.cdufdenc,1,2),2,' ')
                   || to_char(pr_reg_dado_arquiv.nrcepenc,'fm00000000')
                   || rpad(substr(pr_reg_dado_arquiv.nrdddenc,1,3),3,' ')
                   || rpad(substr(pr_reg_dado_arquiv.nrtelenc,1,9),9,' '); -- Sem quebra
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      -- ****** DADOS CLIENTE            *******
      vr_set_linha := rpad(substr(pr_reg_dado_arquiv.dsendere,1,30),30,' ')
                   || to_char(pr_reg_dado_arquiv.nrendere,'fm00000')
                   || rpad(substr(pr_reg_dado_arquiv.complend,1,20),20,' ')
                   || rpad(substr(pr_reg_dado_arquiv.nmbairro,1,20),20,' ')
                   || to_char(pr_reg_dado_arquiv.cdcidade,'fm0000')
                   || rpad(substr(pr_reg_dado_arquiv.cdufende,1,2),2,' ')
                   || to_char(pr_reg_dado_arquiv.nrcepend,'fm00000000')
                   || rpad(substr(pr_reg_dado_arquiv.nrdddass,1,3),3,' ')
                   || rpad(substr(pr_reg_dado_arquiv.nrtelass,1,9),9,' '); -- Sem quebra
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

      -- ****** DADOS OPERACAO           *******
      vr_set_linha := rpad('0',14,'0')
                   || rpad(substr(pr_reg_dado_arquiv.inpessoa,1,1),1,' ')
                   || to_char(pr_reg_dado_arquiv.nrcpfcgc,'fm00000000000000')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                   || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                   || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                   || '*'
                   || chr(10); -- Agora com quebra pois terminados o detalhe
      -- Envio ao clob
      gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);


      -- Para o ultimo registro do arquivo
      IF pr_fllastof THEN
        -- ****** TRAILLER ENVIO LOTE       *******
        pr_nrseqreg := pr_nrseqreg + 1;
        -- Trailler conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante das informações
        vr_set_linha := vr_set_linha
                     || to_char(pr_reg_dado_arquiv.cdsubgrv,'fm000')
                     || rpad(substr(pr_reg_dado_arquiv.cdloggrv,1,8),8,' ')
                     || to_char(pr_reg_dado_arquiv.nrseqlot,'fm0000000')
                     || to_char(pr_nrseqreg,'fm000000')
                     || '0'
                     || RPAD(SUBSTR('TRAILLER ' || pr_reg_dado_arquiv.nmrescop,1,21),21,' ')
                     || TO_CHAR(pr_nrseqreg,'fm000000000')  -- Qtde detalhes + Head e Trail do Lote
                     || RPAD(' ',623,' ')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'yyyy')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'mm')
                     || to_char(pr_reg_dado_arquiv.dtmvtolt,'dd')
                     || to_char(to_date(pr_reg_dado_arquiv.hrmvtolt,'sssss'),'hh24miss')
                     || '*'
                     || chr(10); -- Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);

        -- ****** TRAILLER CONTROLE ARQUIVO *******
        -- Trailler conforme o codigo da financeira do gravames da coop
        IF length(pr_reg_dado_arquiv.cdfingrv) > 4 THEN
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm000000000000000');
        ELSE
          vr_set_linha := to_char(pr_reg_dado_arquiv.cdfingrv,'fm0000');
        END IF;
        -- Restante do Header
        vr_set_linha := vr_set_linha
                     || '9999999999999999999999990'
                     || 'TRAILLER DE CONTROLE '
                     || to_char(pr_nrseqreg+2,'fm000000000') -- Qtde de detalhes + Head e Trail do Lote + Head e Trail do COntrole geral
                     || rpad(' ',637,' ')
                     || '*'
                     || chr(10); --Quebra
        -- Envio ao clob
        gene0002.pc_escreve_xml(pr_clobarq,pr_clobaux,vr_set_linha);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina GRVM0001.pc_gravames_gerac_arq_inclus -> '||SQLERRM;
    END;
  END pc_gravames_gerac_arq_inclus;

  /* Geração dos arquivos do GRAVAMES */
  PROCEDURE pc_gravames_geracao_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE -- Cooperativa conectada
                                       ,pr_cdcoptel  IN crapcop.cdcooper%TYPE -- Opção selecionada na tela
                                       ,pr_tparquiv  IN VARCHAR2              -- Tipo do arquivo selecionado na tela
                                       ,pr_dtmvtolt  IN DATE                  -- Data atual
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cod Critica de erro
                                       ,pr_dscritic OUT VARCHAR2) IS          -- Des Critica de erro
  BEGIN
    /* .............................................................................
     Programa: pc_gravames_geracao_arquivo          Antigo: b1wgen0171.p/gravames_geracao_arquivo
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Guilherme/SUPERO
     Data    : Agosto/2013                     Ultima atualizacao:  08/04/2016

     Dados referentes ao programa:

     Frequencia:  Diario (on-line)
     Objetivo  : Gerar arquivos GRAVAMES

     Alteracoes: 04/11/2014 - Conversão Progress para Oracle (Marcos-Supero)

                 05/12/2014 - Mudança no indice da GRV, inclusão do dschassi (Guilherme/SUPERO)

                 22/12/2014 - Inclusao do LOWER no cdoperad da CRAWEPR e CRAPOPE,
                              problema em localizar a chave (Guilherme/SUPERO)

                 23/12/2014 - Inclusão de testes logo após a inserção/atualização
                              da CRAPGRV para evitarmos o problema que vem ocorrendo
                              do bem ser processado e não gravarmos a GRV.
                              Também mudei a forma de tratamento dos erros, incluindo
                              raise com rollback ao invés do return. (Marcos-Supero)

                 30/12/2014 - Liberação para as demais cooperativas(Guilherme/SUPERO)

                 13/02/2015 - Adicionado condicao para nao enviar registros bloqueados
                              judicialmente quando tiver flblqjud = 1 em casos de
                              Baixa ou Cancelamento. (Jorge/Gielow) - SD 241854

                 05/03/2015 - Incluido UPPER e TRIM no dschassi (Guilherme/SUPERO)

                 31/03/2015 - Alterado para fazer Insert/Update na GRV antes da
                              geracao do arquivo. Geracao do arquivo faz "commit"
                              internamente (Guilherme/SUPERO)

                 22/05/2015 - Substituir os caracteres especiais nos campos
                              dsendere e complend. (Jaison/Thiago - SD: 286623)

                 29/09/2015 - Ajuste para que só entre na inclusão quando o flag
                              de baixa estiver igual a 0 (FALSE), conforme pedido
                              no chamado 319024.(Kelvin/Gielow)
                              
                 04/01/2016 - Ajuste na leitura da tabela CRAPGRV para utilizar UPPER nos campos VARCHAR
                              pois será incluido o UPPER no indice desta tabela - SD 375854
                             (Adriano).                                
                             
                 11/01/2016 - Ajuste na leitura da tabela CRAPGRV para utilizar UPPER nos campos VARCHAR
                              pois será incluido o UPPER no indice desta tabela - SD 375854
                             (Adriano).                                            
                             
                 08/04/2016 -  Ajuste na pc_gravames_geracao_arquivo para formatar
                               o número de telefone caso venha vazio, e também
                               foi tirado os caracteres especiais do nome da cidade
                               e do nome do bairro conforme solicitado no chamado
                               430323. (Kelvin) 
    ............................................................................. */
    DECLARE

      -- Cursor para validacao da cooperativa conectada
      CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
        SELECT cdcooper
          FROM crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;

      -- Buscar todas as informações de alienação e bens
      CURSOR cr_crapbpr IS
        SELECT bpr.rowid
              ,cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelvoz
              ,cop.nmcidade
              ,cop.cdufdcop
              ,cop.cdfingrv
              ,cop.cdsubgrv
              ,cop.cdloggrv
              ,cop.dsendcop
              ,cop.nrendcop
              ,cop.dscomple
              ,cop.nmbairro
              ,cop.nrcepend
              ,ass.nrdconta
              ,ass.nmprimtl
              ,ass.inpessoa
              ,wpr.nrctremp
              ,wpr.flgokgrv
              ,wpr.dtdpagto
              ,wpr.qtpreemp
              ,wpr.dtmvtolt
              ,wpr.vlemprst
              ,wpr.vlpreemp
              ,LOWER(wpr.cdoperad) cdoperad
              ,bpr.flginclu
              ,bpr.cdsitgrv
              ,bpr.tpinclus
              ,bpr.flcancel
              ,bpr.tpcancel
              ,bpr.tpctrpro
              ,bpr.flgbaixa
              ,bpr.tpdbaixa
              ,bpr.nrcpfbem
              ,bpr.nrctrpro
              ,bpr.idseqbem
              ,UPPER(TRIM(bpr.dschassi)) dschassi
              ,bpr.tpchassi
              ,bpr.uflicenc
              ,bpr.nranobem
              ,bpr.nrmodbem
              ,bpr.ufplnovo
              ,bpr.nrplnovo
              ,bpr.nrrenovo
              ,bpr.ufdplaca
              ,bpr.nrdplaca
              ,bpr.nrrenava
              ,ass.nrcpfcgc

              ,ROW_NUMBER ()
                  OVER (PARTITION BY cop.cdcooper ORDER BY cop.cdcooper) nrseqcop

          FROM crapass ass
              ,crapcop cop
              ,crawepr wpr
              ,crapbpr bpr

         WHERE bpr.cdcooper = DECODE(pr_cdcoptel,0,bpr.cdcooper,pr_cdcoptel)
           AND bpr.flgalien   = 1 -- Sim
           AND wpr.cdcooper   = bpr.cdcooper
           AND wpr.nrdconta   = bpr.nrdconta
           AND wpr.nrctremp   = bpr.nrctrpro
           AND wpr.insitapr IN(1,3) -- Aprovados
           AND cop.cdcooper   = bpr.cdcooper
           AND ass.cdcooper   = bpr.cdcooper
           AND ass.nrdconta   = bpr.nrdconta

           AND (  -- Bloco INCLUSAO
                     (pr_tparquiv IN ('INCLUSAO','TODAS')
                 AND  bpr.tpctrpro   = 90
                 AND  wpr.flgokgrv   = 1
                 AND  bpr.flginclu   = 1     -- INCLUSAO SOLICITADA
                 AND  bpr.cdsitgrv in(0,3)   -- NAO ENVIADO ou PROCES.COM ERRO
                 AND  bpr.tpinclus   = 'A')  -- AUTOMATICA

                  -- Bloco BAIXA --
                  OR (pr_tparquiv IN('BAIXA','TODAS')
                 AND  bpr.tpctrpro   in(90,99)  -- Tbm Para BENS excluidos na ADITIV
                 AND  bpr.flgbaixa   = 1        -- BAIXA SOLICITADA
                 AND  bpr.cdsitgrv  <> 1        -- Nao enviado
                 AND  bpr.tpdbaixa   = 'A'      -- Automatica
                 AND  bpr.flblqjud  <> 1)       -- Nao bloqueado judicial

                 -- Bloco CANCELAMENTO --
                  OR (pr_tparquiv IN('CANCELAMENTO','TODAS')
                 AND  bpr.tpctrpro   = 90
                 AND  bpr.flcancel   = 1    -- CANCELAMENTO SOLICITADO
                 AND  bpr.tpcancel   = 'A'  -- Automatica
                 AND  bpr.cdsitgrv  <> 1    -- Nao enviado
                 AND  bpr.flblqjud  <> 1)   -- Nao bloqueado judicial

               );

      -- Busca das informações dos avalistas
      CURSOR cr_crapavt(pr_cdcooper crapavt.cdcooper%TYPE
                       ,pr_nrdconta crapavt.nrdconta%TYPE
                       ,pr_nrctremp crapavt.nrctremp%TYPE
                       ,pr_nrcpfcgc crapavt.nrcpfcgc%TYPE) IS
        SELECT avt.nmdavali
              ,avt.nrcpfcgc
          FROM crapavt avt
         WHERE avt.cdcooper = pr_cdcooper
           AND avt.tpctrato = 9
           AND avt.nrdconta = pr_nrdconta
           AND avt.nrctremp = pr_nrctremp
           AND avt.nrcpfcgc = pr_nrcpfcgc;

      -- Busca de todas as agências por operador
      CURSOR cr_crapope IS
        SELECT ope.cdcooper
              ,LOWER(ope.cdoperad) cdoperad
              ,age.nmcidade
              ,age.cdufdcop
          FROM crapope ope
              ,crapage age
         WHERE ope.cdcooper = age.cdcooper
           AND ope.cdagenci = age.cdagenci;

      -- Busca de todos os municipios
      CURSOR cr_crapmun IS
        SELECT cdcidade
              ,dscidade
              ,cdestado
          FROM crapmun;

      -- BUsca de endereco do cliente
      CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE
                       ,pr_nrdconta crapenc.nrdconta%TYPE
                       ,pr_inpessoa crapass.inpessoa%TYPE) IS
        SELECT enc.dsendere
              ,enc.nrendere
              ,enc.complend
              ,enc.nmbairro
              ,enc.cdufende
              ,enc.nrcepend
              ,enc.nmcidade
          FROM crapenc enc
        WHERE enc.cdcooper = pr_cdcooper
          AND enc.nrdconta = pr_nrdconta
          AND (  -- Para PF
                 (    pr_inpessoa = 1
                  AND enc.idseqttl = 1 /* Sempre do primeiro titular */
                  AND enc.tpendass = 10)
               OR
                 -- Para PJ
                 (    pr_inpessoa = 2
                  AND enc.idseqttl = 1 /* Sempre do primeiro titular */
                  AND enc.cdseqinc = 1
                  AND enc.tpendass = 9)
               );
      rw_enc cr_crapenc%ROWTYPE;

      -- Telefone do associado
      CURSOR cr_craptfc(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crawepr.nrdconta%TYPE) IS
        SELECT tfc.nrdddtfc
              ,tfc.nrtelefo
          FROM craptfc tfc
         WHERE tfc.cdcooper = pr_cdcooper
           AND tfc.nrdconta = pr_nrdconta
           AND tfc.idseqttl = 1 /* Sempre primeiro titular */
         ORDER BY tfc.tptelefo
                 ,tfc.nrtelefo;

      -- Localiza Nr Sequencia LOTE
      CURSOR cr_crapsqg(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT ROWID
              ,nrseqqui
              ,nrseqinc
              ,nrseqcan
          FROM crapsqg
         WHERE cdcooper = pr_cdcooper;
      rw_crapsqg cr_crapsqg%ROWTYPE;

      -- Busca do GRV para atualização
      CURSOR cr_crapgrv (pr_cdcooper crapgrv.cdcooper%TYPE
                        ,pr_nrdconta crapgrv.nrdconta%TYPE
                        ,pr_tpctrpro crapgrv.tpctrpro%TYPE
                        ,pr_nrctrpro crapgrv.nrctrpro%TYPE
                        ,pr_dschassi crapgrv.dschassi%TYPE
                        ,pr_nrseqlot crapgrv.nrseqlot%TYPE
                        ,pr_cdoperac crapgrv.cdoperac%TYPE) IS
        SELECT ROWID
          FROM crapgrv
         WHERE crapgrv.cdcooper = pr_cdcooper
           AND crapgrv.nrdconta = pr_nrdconta
           AND crapgrv.tpctrpro = pr_tpctrpro
           AND crapgrv.nrctrpro = pr_nrctrpro
           AND UPPER(crapgrv.dschassi) = UPPER(pr_dschassi)
           AND crapgrv.nrseqlot = pr_nrseqlot
           AND crapgrv.cdoperac = pr_cdoperac;
      vr_rowid_grv ROWID;

      -- Tipo e tabela para armazenar as cidades e ufs
      -- dos operadores observando a agencia do mesmo
      TYPE typ_reg_endere_ageope IS
        RECORD (nmcidade crapage.nmcidade%TYPE
               ,cdufdcop crapage.cdufdcop%TYPE);
      TYPE typ_tab_endere_ageope IS
        TABLE OF typ_reg_endere_ageope
          INDEX BY VARCHAR2(15);
      vr_tab_endere_ageope typ_tab_endere_ageope;

      -- Tabela para armazenar o codigo do municipio conforme descrição
      TYPE typ_tab_munici IS
        TABLE OF crapmun.cdcidade%TYPE
          INDEX BY VARCHAR2(52); -- Cdestado(2)+Dscidade(50)
      vr_tab_munici typ_tab_munici;

      -- Tabela para contagem dos registros cfme cada tipo de arquivo
      TYPE typ_tab_qtregarq IS
        TABLE OF PLS_INTEGER
          INDEX BY PLS_INTEGER;
      vr_tab_qtregarq typ_tab_qtregarq;

      -- Variaveis auxiliares
      vr_tab_dados_arquivo typ_tab_dados_arquivo; -- Tabela com as informações do arquivo
      vr_dsdchave VARCHAR2(20);          -- Chave da tabela composta por Cooper(5)+TpArquivo(1)+Sequencia(14)

      vr_tparquiv VARCHAR2(12);          -- Descricao da operação
      vr_cdoperac PLS_INTEGER;           -- Codigo da operação
      vr_nrseqreg PLS_INTEGER;           -- Sequenciador do registro na cooperativa
      vr_nmprimtl crapass.nmprimtl%TYPE; -- Nome do proprietario do bem
      vr_nrcpfbem crapass.nrcpfcgc%TYPE; -- Cpf do proprietário do bem
      vr_dtvencto DATE;                  -- Data do ultimo vencimento
      vr_nrdddenc VARCHAR2(10);          -- DDD do Telefone do Credor
      vr_nrtelenc VARCHAR2(10);          -- Telefone do Credor
      vr_cdcidcre crapmun.cdcidade%TYPE; -- Municipio do Credor
      vr_cdcidcli crapmun.cdcidade%TYPE; -- Municipio do Cliente
      vr_nrdddass VARCHAR2(10);          -- DDD do Telefone do Cliente
      vr_nrtelass VARCHAR2(10);          -- Telefone do Cliente

      vr_flgfirst BOOLEAN;               -- Flag de primeiro registro da quebra
      vr_fllastof BOOLEAN;               -- Flag do ultimo registro da quebra
      vr_nrseqlot NUMBER;                -- Numero do Lote

      vr_clobarq CLOB;                   -- CLOB para armazenamento das informações do arquivo
      vr_clobaux VARCHAR2(32767);        -- Var auxiliar para montagem do arquivo
      vr_nmdireto VARCHAR2(100);         -- Diretorio para geração dos arquivos
      vr_nmarquiv VARCHAR2(100);         -- Var para o nome dos arquivos

      vr_exc_erro EXCEPTION;             -- Tratamento de exceção

    BEGIN
      -- Validar existencia da cooperativa informada
      IF pr_cdcoptel <> 0 THEN
        OPEN cr_crapcop(pr_cdcoptel);
        FETCH cr_crapcop
         INTO rw_crapcop;
        -- Gerar critica 794 se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          pr_cdcritic := 794;
          -- Sair
          RETURN;
        ELSE
          CLOSE cr_crapcop;
          -- Continuaremos
        END IF;
      END IF;
      -- Validar opção informada
      IF pr_tparquiv NOT IN('TODAS','INCLUSAO','BAIXA','CANCELAMENTO') THEN
        pr_cdcritic := 0;
        pr_dscritic := ' Tipo invalido para Geracao do Arquivo! ';
        RAISE vr_exc_erro;
      END IF;

      -- Busca de todas as agências por operador
      FOR rw_ope IN cr_crapope LOOP
        -- Armazenar armazenar as cidades e ufs
        -- dos operadores observando a agencia do mesmo
        vr_tab_endere_ageope(lpad(rw_ope.cdcooper,5,'0')||rpad(rw_ope.cdoperad,10,' ')).nmcidade := rw_ope.nmcidade;
        vr_tab_endere_ageope(lpad(rw_ope.cdcooper,5,'0')||rpad(rw_ope.cdoperad,10,' ')).cdufdcop := rw_ope.cdufdcop;
      END LOOP;

      -- Busca de todos os municipios
      FOR rw_mun IN cr_crapmun LOOP
        -- Adicionar a tabela o codigo pela chave UF + DsCidade
        vr_tab_munici(rpad(rw_mun.cdestado,2,' ')||rpad(rw_mun.dscidade,50,' ')) := rw_mun.cdcidade;
      END LOOP;

      -- Inicializar a pltable de contagem
      FOR vr_ind IN 1..3 LOOP
        vr_tab_qtregarq(vr_ind) := 0;
      END LOOP;

      -- Buscar o parâmetro de sistema que contém o diretório dos arquivos do GRAVAMES
      vr_nmdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'DS_PATH_GRAVAMES');

      -- Buscar todas as informações de alienação e bens
      FOR rw_bpr IN cr_crapbpr LOOP
        -- Quando escolhido todas, temos que avaliar o registro atual pra definir sua operação
        IF pr_tparquiv = 'TODAS' THEN
          -- Inclusão
          IF rw_bpr.flgokgrv = 1 AND rw_bpr.flginclu = 1 AND rw_bpr.cdsitgrv in(0,3) AND rw_bpr.tpinclus = 'A' AND 
             rw_bpr.flgbaixa = 0 THEN --Adicionado a alteração rw_bpr.flgbaixa = 0 pedido pelo análista Gielow
            vr_tparquiv := 'INCLUSAO';
          -- Cancelamento
          ELSIF rw_bpr.flcancel = 1 AND rw_bpr.tpcancel = 'A' AND rw_bpr.tpctrpro IN(90,99) THEN
            vr_tparquiv := 'CANCELAMENTO';
          -- Baixa
          ELSIF rw_bpr.flgbaixa = 1 AND rw_bpr.tpdbaixa = 'A' THEN
            vr_tparquiv := 'BAIXA';
          END IF;
        ELSE
          -- Usar a opção escolhida na tela
          vr_tparquiv := pr_tparquiv;
        END IF;

        -- Buscar o codigo da operação
        CASE vr_tparquiv
          WHEN 'BAIXA'        THEN
            vr_cdoperac := 3;
          WHEN 'CANCELAMENTO' THEN
            vr_cdoperac := 2;
          WHEN 'INCLUSAO'     THEN
            vr_cdoperac := 1;
          ELSE
            vr_cdoperac := 0;
        END CASE;
        -- Incrementar os contadores por operação
        vr_tab_qtregarq(vr_cdoperac) := vr_tab_qtregarq(vr_cdoperac) + 1;

        -- Para o primeiro registro da Cooperativa
        IF rw_bpr.nrseqcop = 1 THEN
          -- Inicia sequencia por cooperativa
          vr_nrseqreg := 0;
        END IF;

        -- Incrementar Contador de Registros
        vr_nrseqreg := vr_nrseqreg + 1;

        -- Se o bem eh do próprio associado
        IF rw_bpr.nrcpfbem = rw_bpr.nrcpfcgc OR rw_bpr.nrcpfbem = 0 THEN
          -- Usamos o nome e cpf do associado
          vr_nmprimtl := rw_bpr.nmprimtl;
          vr_nrcpfbem := rw_bpr.nrcpfcgc;
        ELSE
          -- Buscaremos as informações do cadastro de avalistas
          OPEN cr_crapavt(pr_cdcooper => rw_bpr.cdcooper
                         ,pr_nrdconta => rw_bpr.nrdconta
                         ,pr_nrctremp => rw_bpr.nrctremp
                         ,pr_nrcpfcgc => rw_bpr.nrcpfbem);
          FETCH cr_crapavt
            INTO vr_nmprimtl
                ,vr_nrcpfbem;
          -- Se não encontrou
          IF cr_crapavt%NOTFOUND THEN
            -- Usamos o nome e cpf do associado
            vr_nmprimtl := rw_bpr.nmprimtl;
            vr_nrcpfbem := rw_bpr.nrcpfcgc;
          END IF;
          --
          CLOSE cr_crapavt;
        END IF;
        -- Calcular data do ultimo vencimento considerando
        -- a data do primeiro pagamento e quantidade de parcelas
        vr_dtvencto := add_months(rw_bpr.dtdpagto,rw_bpr.qtpreemp-1);

        -- Separar DDD do Credor
        vr_nrdddenc := '0' || TRIM(REPLACE(gene0002.fn_busca_entrada(1,rw_bpr.nrtelvoz,')'),'(',''));
        -- Separar Telefone do Credor
        vr_nrtelenc := TRIM(REPLACE(gene0002.fn_busca_entrada(2,rw_bpr.nrtelvoz,')'),'-',''));

        -- Buscar municipio do credor
        IF vr_tab_munici.exists(rpad(rw_bpr.cdufdcop,2,' ')||rpad(rw_bpr.nmcidade,50,' ')) THEN
          -- Usamos o código encontrado
          vr_cdcidcre := vr_tab_munici(rpad(rw_bpr.cdufdcop,2,' ')||rpad(rw_bpr.nmcidade,50,' '));
        ELSE
          -- Usamos Codigo de BLUMENAU-SC
          vr_cdcidcre := 8047;
        END IF;

        -- BUscar o endereço do cliente
        rw_enc := NULL;
        OPEN cr_crapenc(pr_cdcooper => rw_bpr.cdcooper
                       ,pr_nrdconta => rw_bpr.nrdconta
                       ,pr_inpessoa => rw_bpr.inpessoa);
        FETCH cr_crapenc
         INTO rw_enc;
        CLOSE cr_crapenc;

        -- Buscar municipio do cliente
        IF vr_tab_munici.exists(rpad(rw_enc.cdufende,2,' ')||rpad(rw_enc.nmcidade,50,' ')) THEN
          -- Usamos o código encontrado
          vr_cdcidcli := vr_tab_munici(rpad(rw_enc.cdufende,2,' ')||rpad(rw_enc.nmcidade,50,' '));
        ELSE
          -- Usamos Codigo de BLUMENAU-SC
          vr_cdcidcli := 8047;
        END IF;

        -- Telefone do cliente
        vr_nrdddass := NULL;
        vr_nrtelass := NULL;
        FOR rw_tfc IN cr_craptfc(pr_cdcooper => rw_bpr.cdcooper
                                ,pr_nrdconta => rw_bpr.nrdconta) LOOP
          -- Formatar a informação
          vr_nrdddass := to_char(nvl(rw_tfc.nrdddtfc,0),'fm000');
          vr_nrtelass := to_char(nvl(rw_tfc.nrtelefo,0),'fm00000000');
          -- Sair quando encontrar
          EXIT WHEN (vr_nrdddass <> ' ' AND vr_nrtelass <> ' ');
        END LOOP;
        
        IF TRIM(vr_nrdddass) IS NULL THEN
          vr_nrdddass := to_char(0,'fm000');
        END IF;
        
        IF TRIM(vr_nrtelass) IS NULL THEN
          vr_nrtelass := to_char(0,'fm00000000');
        END IF;
          
        -- Montagem da chave para a tabela por Cooper(5)+TpArquivo(1)+Sequencia(14)
        vr_dsdchave := LPAD(rw_bpr.cdcooper,5,'0')
                    || vr_cdoperac
                    || LPAD(vr_tab_qtregarq(vr_cdoperac),14,'0');

        -- Enfim, criaremos os registros na tabela
        vr_tab_dados_arquivo(vr_dsdchave).rowidbpr := rw_bpr.rowid;
        vr_tab_dados_arquivo(vr_dsdchave).cdcooper := rw_bpr.cdcooper;
        vr_tab_dados_arquivo(vr_dsdchave).tparquiv := vr_tparquiv;
        vr_tab_dados_arquivo(vr_dsdchave).cdoperac := vr_cdoperac;
        vr_tab_dados_arquivo(vr_dsdchave).cdfingrv := rw_bpr.cdfingrv;
        vr_tab_dados_arquivo(vr_dsdchave).cdsubgrv := rw_bpr.cdsubgrv;
        vr_tab_dados_arquivo(vr_dsdchave).cdloggrv := rw_bpr.cdloggrv;

        vr_tab_dados_arquivo(vr_dsdchave).nrdconta := rw_bpr.nrdconta;
        vr_tab_dados_arquivo(vr_dsdchave).tpctrpro := rw_bpr.tpctrpro;
        vr_tab_dados_arquivo(vr_dsdchave).nrctrpro := rw_bpr.nrctrpro;
        vr_tab_dados_arquivo(vr_dsdchave).idseqbem := rw_bpr.idseqbem;

        vr_tab_dados_arquivo(vr_dsdchave).nrseqreg := vr_nrseqreg;
        vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt := pr_dtmvtolt;
        vr_tab_dados_arquivo(vr_dsdchave).hrmvtolt := to_char(SYSDATE,'sssss');
        vr_tab_dados_arquivo(vr_dsdchave).nmrescop := rw_bpr.nmrescop;
        vr_tab_dados_arquivo(vr_dsdchave).dschassi := rw_bpr.dschassi;
        vr_tab_dados_arquivo(vr_dsdchave).tpchassi := rw_bpr.tpchassi;
        vr_tab_dados_arquivo(vr_dsdchave).uflicenc := rw_bpr.uflicenc;
        vr_tab_dados_arquivo(vr_dsdchave).nranobem := rw_bpr.nranobem;
        vr_tab_dados_arquivo(vr_dsdchave).nrmodbem := rw_bpr.nrmodbem;
        vr_tab_dados_arquivo(vr_dsdchave).nrctremp := rw_bpr.nrctremp;
        vr_tab_dados_arquivo(vr_dsdchave).dtoperad := rw_bpr.dtmvtolt;
        vr_tab_dados_arquivo(vr_dsdchave).nrcpfbem := vr_nrcpfbem;
        vr_tab_dados_arquivo(vr_dsdchave).nmprimtl := vr_nmprimtl;
        vr_tab_dados_arquivo(vr_dsdchave).qtpreemp := rw_bpr.qtpreemp;
        vr_tab_dados_arquivo(vr_dsdchave).vlemprst := rw_bpr.vlemprst * 100;
        vr_tab_dados_arquivo(vr_dsdchave).vlpreemp := rw_bpr.vlpreemp * 100;
        vr_tab_dados_arquivo(vr_dsdchave).dtdpagto := rw_bpr.dtdpagto;
        vr_tab_dados_arquivo(vr_dsdchave).dtvencto := vr_dtvencto;

        vr_tab_dados_arquivo(vr_dsdchave).nmcidade := GENE0007.fn_caract_acento(
                                                               pr_texto => vr_tab_endere_ageope(lpad(rw_bpr.cdcooper,5,'0')||rpad(rw_bpr.cdoperad,10,' ')).nmcidade, 
                                                               pr_insubsti => 1);
        vr_tab_dados_arquivo(vr_dsdchave).cdufdcop := vr_tab_endere_ageope(lpad(rw_bpr.cdcooper,5,'0')||rpad(rw_bpr.cdoperad,10,' ')).cdufdcop;

        /* DADOS CREDOR */
        vr_tab_dados_arquivo(vr_dsdchave).dsendcop := rw_bpr.dsendcop;
        vr_tab_dados_arquivo(vr_dsdchave).nrendcop := rw_bpr.nrendcop;
        vr_tab_dados_arquivo(vr_dsdchave).dscomple := rw_bpr.dscomple;
        vr_tab_dados_arquivo(vr_dsdchave).nmbaienc := rw_bpr.nmbairro;
        vr_tab_dados_arquivo(vr_dsdchave).cdcidenc := vr_cdcidcre;
        vr_tab_dados_arquivo(vr_dsdchave).cdufdenc := rw_bpr.cdufdcop;
        vr_tab_dados_arquivo(vr_dsdchave).nrcepenc := rw_bpr.nrcepend;
        vr_tab_dados_arquivo(vr_dsdchave).nrdddenc := vr_nrdddenc;
        vr_tab_dados_arquivo(vr_dsdchave).nrtelenc := vr_nrtelenc;
        /* DADOS CLIENTE */
        vr_tab_dados_arquivo(vr_dsdchave).dsendere := GENE0007.fn_caract_acento(
                                                               pr_texto => rw_enc.dsendere, 
                                                               pr_insubsti => 1);
        vr_tab_dados_arquivo(vr_dsdchave).complend := GENE0007.fn_caract_acento(
                                                               pr_texto => rw_enc.complend, 
                                                               pr_insubsti => 1);
        vr_tab_dados_arquivo(vr_dsdchave).nrendere := rw_enc.nrendere;
        vr_tab_dados_arquivo(vr_dsdchave).nmbairro := GENE0007.fn_caract_acento(
                                                               pr_texto => rw_enc.nmbairro, 
                                                               pr_insubsti => 1);
        vr_tab_dados_arquivo(vr_dsdchave).cdcidade := vr_cdcidcli;
        vr_tab_dados_arquivo(vr_dsdchave).cdufende := rw_enc.cdufende;
        vr_tab_dados_arquivo(vr_dsdchave).nrcepend := rw_enc.nrcepend;
        vr_tab_dados_arquivo(vr_dsdchave).nrdddass := vr_nrdddass;
        vr_tab_dados_arquivo(vr_dsdchave).nrtelass := vr_nrtelass;
        vr_tab_dados_arquivo(vr_dsdchave).nrcpfcgc := rw_bpr.nrcpfcgc;
        IF rw_bpr.inpessoa = 1 THEN
          vr_tab_dados_arquivo(vr_dsdchave).inpessoa := 1;
        ELSE
          vr_tab_dados_arquivo(vr_dsdchave).inpessoa := 2;
        END IF;

        -- Para baixa com mudança no veiculo
        IF vr_tparquiv = 'BAIXA'AND rw_bpr.ufplnovo <> ' ' AND rw_bpr.nrplnovo <> ' ' AND rw_bpr.nrrenovo > 0 THEN
          vr_tab_dados_arquivo(vr_dsdchave).ufdplaca := rw_bpr.ufplnovo;
          vr_tab_dados_arquivo(vr_dsdchave).nrdplaca := rw_bpr.nrplnovo;
          vr_tab_dados_arquivo(vr_dsdchave).nrrenava := rw_bpr.nrrenovo;
        ELSE
          vr_tab_dados_arquivo(vr_dsdchave).ufdplaca := rw_bpr.ufdplaca;
          vr_tab_dados_arquivo(vr_dsdchave).nrdplaca := rw_bpr.nrdplaca;
          vr_tab_dados_arquivo(vr_dsdchave).nrrenava := rw_bpr.nrrenava;
        END IF;

        -- ATUALIZAR A SITUACAO DO BEM DO GRAVAMES
        BEGIN
          UPDATE crapbpr
             SET cdsitgrv = 1. /* Enviado */
           WHERE ROWID = rw_bpr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Ao atualizar CRAPBPR -> '||SQLERRM;
            RAISE vr_exc_erro;
        END;

      END LOOP;

      -- Se não gerou nenhuma informação
      IF vr_tab_dados_arquivo.count = 0 THEN
        pr_dscritic := ' Dados nao encontrados! Arquivo nao gerado! ';
        RAISE vr_exc_erro;
      END IF;

      ------- Geração dos arquivos --------
      -- Pela chave, os registros estão ordenados
      --  por Cooperativa + Tipo do Arquivo
      vr_dsdchave := vr_tab_dados_arquivo.first;
      WHILE vr_dsdchave IS NOT NULL LOOP
        -- Para o primeiro registro do vetor
        -- OU
        -- Se mudou a Cooperativa
        IF vr_dsdchave = vr_tab_dados_arquivo.first
        OR vr_tab_dados_arquivo(vr_dsdchave).cdcooper <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.prior(vr_dsdchave)).cdcooper THEN
          -- Localiza Nr Sequencia LOTE
          OPEN cr_crapsqg(pr_cdcooper => vr_tab_dados_arquivo(vr_dsdchave).cdcooper);
          FETCH cr_crapsqg
           INTO rw_crapsqg;
          -- Se não encontrou
          IF cr_crapsqg%NOTFOUND THEN
            CLOSE cr_crapsqg;
            -- Criaremos o registro na tabela
            BEGIN
              INSERT
                INTO crapsqg(cdcooper
                            ,nrseqqui
                            ,nrseqcan
                            ,nrseqinc)
                      VALUES(vr_tab_dados_arquivo(vr_dsdchave).cdcooper
                            ,0
                            ,0
                            ,0)
                    RETURNING ROWID
                             ,nrseqqui
                             ,nrseqcan
                             ,nrseqinc
                         INTO rw_crapsqg.ROWID
                             ,rw_crapsqg.nrseqqui
                             ,rw_crapsqg.nrseqcan
                             ,rw_crapsqg.nrseqinc;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Ao criar CRAPSQG -> '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          ELSE
            CLOSE cr_crapsqg;
          END IF;
        END IF;
        -- Para o primeiro registro do vetor
        -- OU
        -- Se mudou a Cooperativa
        -- Se mudou o Tipo de Arquivo
        IF vr_dsdchave = vr_tab_dados_arquivo.first
        OR vr_tab_dados_arquivo(vr_dsdchave).cdcooper <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.prior(vr_dsdchave)).cdcooper
        OR vr_tab_dados_arquivo(vr_dsdchave).tparquiv <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.prior(vr_dsdchave)).tparquiv THEN
          -- Incrementar e Guardar a sequencia do Lote
          CASE vr_tab_dados_arquivo(vr_dsdchave).tparquiv
            WHEN 'BAIXA'        THEN
              -- Incrementar a sequencia
              rw_crapsqg.nrseqqui := rw_crapsqg.nrseqqui + 1;
              -- Guardar na variavel genérica
              vr_nrseqlot := rw_crapsqg.nrseqqui;
            WHEN 'CANCELAMENTO' THEN
              -- Incrementar a sequencia
              rw_crapsqg.nrseqcan := rw_crapsqg.nrseqcan + 1;
              -- Guardar na variavel genérica
              vr_nrseqlot := rw_crapsqg.nrseqcan;
            WHEN 'INCLUSAO'     THEN
              -- Incrementar a sequencia
              rw_crapsqg.nrseqinc := rw_crapsqg.nrseqinc + 1;
              -- Guardar na variavel genérica
              vr_nrseqlot := rw_crapsqg.nrseqinc;
            ELSE
              vr_nrseqlot := 0;
          END CASE;
          -- Atualizar a flag de primeiro registro
          vr_flgfirst := TRUE;
          -- Preparar o CLOB para armazenar as infos do arquivo
          dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobarq, dbms_lob.lob_readwrite);
        ELSE
          -- Não é o primeiro registro do tipo de arquivo
          vr_flgfirst := FALSE;
        END IF;

        -- No ultimo registro do vetor
        -- OU
        -- No ultimo registro da Cooper
        -- No ultimo registro do tipo do arquivo
        IF vr_dsdchave = vr_tab_dados_arquivo.last
        OR vr_tab_dados_arquivo(vr_dsdchave).cdcooper <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.next(vr_dsdchave)).cdcooper
        OR vr_tab_dados_arquivo(vr_dsdchave).tparquiv <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.next(vr_dsdchave)).tparquiv THEN
          -- Atualizar a flag de ultimo registro do tipo de arquivo
          vr_fllastof := TRUE;
        ELSE
          -- Não é o ultimo
          vr_fllastof := FALSE;
        END IF;

        -- No ultimo registro do vetor
        -- OU
        -- No ultimo registro da Cooper
        IF vr_dsdchave = vr_tab_dados_arquivo.last
        OR vr_tab_dados_arquivo(vr_dsdchave).cdcooper <> vr_tab_dados_arquivo(vr_tab_dados_arquivo.next(vr_dsdchave)).cdcooper THEN
          -- Atualizaremos a tabela de sequenciamento
          BEGIN
            UPDATE crapsqg
               SET crapsqg.nrseqqui = rw_crapsqg.nrseqqui
                  ,crapsqg.nrseqcan = rw_crapsqg.nrseqcan
                  ,crapsqg.nrseqinc = rw_crapsqg.nrseqinc
             WHERE ROWID = rw_crapsqg.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Ao atualizar CRAPSQG -> '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;

        -- Atualiza o nr do lote
        vr_tab_dados_arquivo(vr_dsdchave).nrseqlot := vr_nrseqlot;

        -- Chamar rotina responsável conforme cada tipo de arquivo
        IF vr_tab_dados_arquivo(vr_dsdchave).tparquiv IN('BAIXA','CANCELAMENTO') THEN
          pc_gravames_gerac_arqs_bxa_cnc(pr_flgfirst        => vr_flgfirst                       --> Flag de primeiro registro
                                        ,pr_fllastof        => vr_fllastof                       --> Flag de ultimo registro
                                        ,pr_reg_dado_arquiv => vr_tab_dados_arquivo(vr_dsdchave) --> Registro com as informações atuais
                                        ,pr_clobaux         => vr_clobaux                        --> Varchar2 de Buffer para o arquivo
                                        ,pr_clobarq         => vr_clobarq                        --> CLOB para as informações do arquivo
                                        ,pr_nrseqreg        => vr_nrseqreg                       --> Quantidade total
                                        ,pr_dscritic        => pr_dscritic);                     --> Saida de erro
        ELSIF vr_tab_dados_arquivo(vr_dsdchave).tparquiv = 'INCLUSAO' THEN
          pc_gravames_gerac_arq_inclus(pr_flgfirst        => vr_flgfirst                       --> Flag de primeiro registro
                                      ,pr_fllastof        => vr_fllastof                       --> Flag de ultimo registro
                                      ,pr_reg_dado_arquiv => vr_tab_dados_arquivo(vr_dsdchave) --> Registro com as informações atuais
                                      ,pr_clobaux         => vr_clobaux                        --> Varchar2 de Buffer para o arquivo
                                      ,pr_clobarq         => vr_clobarq                        --> CLOB para as informações do arquivo
                                      ,pr_nrseqreg        => vr_nrseqreg                       --> Quantidade total
                                      ,pr_dscritic        => pr_dscritic);                     --> Saida de erro
        END IF;
        -- Sair se houve erro
        IF pr_dscritic IS NOT NULL THEN
          -- Concatenar descrição comum
          pr_dscritic := 'Ao chamar rotina especifica de '||vr_tab_dados_arquivo(vr_dsdchave).tparquiv||' -> '||pr_dscritic;
          -- Sair
          RAISE vr_exc_erro;
        END IF;


        -- Buscar o GRV para atualização
        OPEN cr_crapgrv (pr_cdcooper => vr_tab_dados_arquivo(vr_dsdchave).cdcooper
                        ,pr_nrdconta => vr_tab_dados_arquivo(vr_dsdchave).nrdconta
                        ,pr_tpctrpro => vr_tab_dados_arquivo(vr_dsdchave).tpctrpro
                        ,pr_nrctrpro => vr_tab_dados_arquivo(vr_dsdchave).nrctrpro
                        ,pr_dschassi => vr_tab_dados_arquivo(vr_dsdchave).dschassi
                        ,pr_nrseqlot => vr_tab_dados_arquivo(vr_dsdchave).nrseqlot
                        ,pr_cdoperac => vr_tab_dados_arquivo(vr_dsdchave).cdoperac);
        FETCH cr_crapgrv
         INTO vr_rowid_grv;
        -- Criar bloco para facilitar o tratamento de exceção
        DECLARE
          vr_dsoperac VARCHAR2(20);
        BEGIN
          -- Se não encontrou
          IF cr_crapgrv%NOTFOUND THEN
            -- Devemos criar
            vr_dsoperac := 'inserir';
            --
            INSERT INTO crapgrv
                       (cdcooper
                       ,nrdconta
                       ,tpctrpro
                       ,nrctrpro
                       ,dschassi
                       ,idseqbem
                       ,nrseqlot
                       ,cdoperac
                       ,nrseqreg
                       ,cdretlot
                       ,cdretgrv
                       ,cdretctr
                       ,dtenvgrv
                       ,dtretgrv)
                 VALUES(vr_tab_dados_arquivo(vr_dsdchave).cdcooper           --cdcooper
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrdconta           --nrdconta
                       ,vr_tab_dados_arquivo(vr_dsdchave).tpctrpro           --tpctrpro
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrctrpro           --nrctrpro
                       ,vr_tab_dados_arquivo(vr_dsdchave).dschassi           --dschassi
                       ,vr_tab_dados_arquivo(vr_dsdchave).idseqbem           --idseqbem
                       ,vr_tab_dados_arquivo(vr_dsdchave).nrseqlot           --nrseqlot
                       ,vr_tab_dados_arquivo(vr_dsdchave).cdoperac           --cdoperac
                       ,vr_nrseqreg                                          --nrseqreg
                       ,0                                                    --cdretlot
                       ,0                                                    --cdretgrv
                       ,0                                                    --cdretctr
                       ,vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt           --dtenvgrv
                       ,NULL)                                                --dtretgrv
              RETURNING ROWID
                   INTO vr_rowid_grv;
            -- Validar possível erro no insert
            IF vr_rowid_grv IS NULL THEN
              CLOSE cr_crapgrv;
              pr_dscritic := 'Nao houve insercao da CRAPGRV [Conta/Ctrato] -> '||vr_tab_dados_arquivo(vr_dsdchave).nrdconta||'/'||vr_tab_dados_arquivo(vr_dsdchave).nrctrpro;
              RAISE vr_exc_erro;
            END IF;
          ELSE
            -- Atualizaremos
            vr_dsoperac := 'atualizar';
            --
            UPDATE crapgrv
               SET nrseqreg = vr_nrseqreg
                  ,cdretlot = 0
                  ,cdretgrv = 0
                  ,cdretctr = 0
                  ,dtenvgrv = vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt
                  ,dtretgrv = NULL
             WHERE ROWID = vr_rowid_grv;
            -- Validar possível erro no update
            IF SQL%NOTFOUND THEN
              CLOSE cr_crapgrv;
              pr_dscritic := 'Nao houve atualizacao da CRAPGRV [Conta/Ctrato/Rowid] -> '||vr_tab_dados_arquivo(vr_dsdchave).nrdconta||'/'||vr_tab_dados_arquivo(vr_dsdchave).nrctrpro||vr_rowid_grv;
              RAISE vr_exc_erro;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_erro THEN
            RAISE vr_exc_erro;
          WHEN OTHERS THEN
            CLOSE cr_crapgrv;
            pr_dscritic := 'Ao '||vr_dsoperac||' CRAPGRV -> '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        --
        CLOSE cr_crapgrv;

        -- No ultimo registro do arquivo
        IF vr_fllastof  THEN
          -- Faz o -1 pois quando gravar a GRV, ja passou pelo TRAILLER e
          --    somou +1, deixando divergente a sequencia **/
          vr_nrseqreg := vr_nrseqreg - 1;
          -- Efetuar a chamada final da pc_escreve_xml pra descarregar
          -- o buffer varchar2 dentro da variavel clob
          gene0002.pc_escreve_xml(pr_xml            => vr_clobarq
                                 ,pr_texto_completo => vr_clobaux
                                 ,pr_texto_novo     => ''
                                 ,pr_fecha_xml      => TRUE);
          -- Montagem do nome do arquivo (OPERACAO_COOP_NUMLOTE_AAAAMMDD.txt)
          vr_nmarquiv := substr(vr_tab_dados_arquivo(vr_dsdchave).tparquiv,1,1)
                      ||'_'
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).cdcooper,'fm000')
                      ||'_'
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).nrseqlot,'fm000000')
                      ||'_'
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt,'yyyy')
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt,'mm')
                      || to_char(vr_tab_dados_arquivo(vr_dsdchave).dtmvtolt,'dd')
                      || '.txt';
          -- Submeter a geração do arquivo txt puro até então apenas em memória
          gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                             ,pr_cdprogra  => 'GRAVAM'                      --> Programa chamador
                                             ,pr_dtmvtolt  => pr_dtmvtolt                   --> Data do movimento atual
                                             ,pr_dsxml     => vr_clobarq                    --> Arquivo XML de dados
                                             ,pr_cdrelato  => '0'                           --> Código do relatório
                                             ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarquiv --> Arquivo final com o path
                                             ,pr_flg_gerar => 'S'                           --> Geraçao na hora
                                             ,pr_des_erro  => pr_dscritic);                 --> Saída com erro

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_clobarq);
          dbms_lob.freetemporary(vr_clobarq);
          -- Sair se houve erro
          IF pr_dscritic IS NOT NULL THEN
            -- Concatenar descrição comum
            pr_dscritic := 'Ao gerar o arquivo '||vr_nmarquiv||' -> '||pr_dscritic;
            -- Sair
            RAISE vr_exc_erro;
          END IF;
        END IF;

        -- Buscar o próximo registro
        vr_dsdchave := vr_tab_dados_arquivo.next(vr_dsdchave);
      END LOOP; -- Fim geração dos arquivos
      -- Fim da rotina, efetuamos gravação das informações alteradas
      COMMIT;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Desfazer alterações
        ROLLBACK;
        -- Incrementar a mensagem de erro
        pr_dscritic := 'Erro GRVM0001.pc_gravames_geracao_arquivo -> '||pr_dscritic;
      WHEN OTHERS THEN
        -- Desfazer alterações
        ROLLBACK;
        -- Retornar erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro GRVM0001.pc_gravames_geracao_arquivo -> '||SQLERRM;
    END;
  END pc_gravames_geracao_arquivo;
	
	PROCEDURE pc_desfazer_baixa_automatica(pr_cdcooper IN crapbpr.cdcooper%TYPE       -- Cód. cooperativa
																				,pr_nrdconta IN crapbpr.nrdconta%TYPE       -- Nr. da conta
																				,pr_nrctrpro IN crapbpr.nrctrpro%TYPE       -- Nr. contrato
																				,pr_des_reto OUT VARCHAR2                   -- Descrição de retorno OK/NOK
																				,pr_tab_erro OUT gene0001.typ_tab_erro)IS   -- Retorno de erros em PlTable
  BEGIN
	  -- ..........................................................................
    --
    --  Programa : pc_desfazer_solicitacao_baixa_automatica      Antigo: b1wgen0171.p/desfazer_solicitacao_baixa_automatica

    --  Sistema  : Rotinas genericas para GRAVAMES
    --  Sigla    : GRVM
    --  Autor    : Lucas Reinert
    --  Data     : Agosto/2015.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Objetivo  : Desfazer a solicitação de baixa automatica  do gravames
    --
    --   Alteracoes: 
    -- .............................................................................
		DECLARE
		   
		  -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
			vr_nrsequen INTEGER;
			
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;   
		
			-- CURSORES
      -- Cursor para a tabela de emprestrimos			
			CURSOR cr_crapepr IS
				SELECT 1
					FROM crapepr epr
				 WHERE epr.cdcooper = pr_cdcooper
					 AND epr.nrdconta = pr_nrdconta
					 AND epr.nrctremp = pr_nrctrpro;
			rw_crapepr cr_crapepr%ROWTYPE;
			
		BEGIN
			-- Verifica se existe contrato de emprestimo
		  OPEN cr_crapepr;
			FETCH cr_crapepr INTO rw_crapepr;
			
			-- Se não existir gera crítica
			IF cr_crapepr%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapepr;
				-- Gera crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato de emprestimo nao encontrado.';        
				vr_nrsequen := 1;				
				-- Levanta exceção
        RAISE vr_exc_saida;
			END IF;
			
			pc_valida_alienacao_fiduciaria (pr_cdcooper => pr_cdcooper  -- Código da cooperativa
																		 ,pr_nrdconta => pr_nrdconta  -- Numero da conta do associado
																		 ,pr_nrctrpro => pr_nrctrpro  -- Numero do contrato
																		 ,pr_des_reto => pr_des_reto  -- Retorno Ok ou NOK do procedimento
																		 ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
																		 ,pr_tab_erro => pr_tab_erro);-- Retorno da PlTable de erros
					
			-- Se a procedure não retornou corretamente
      IF pr_des_reto <> 'OK' THEN
				-- Levanta crítica
				RAISE vr_exc_saida;
			END IF;
						
			-- Atualiza a tabela de bens para desfazer a baixa
      UPDATE crapbpr bpr
			   SET bpr.flgbaixa = 0,
				     bpr.dtdbaixa = NULL,
						 bpr.tpdbaixa = ''
		   WHERE bpr.cdcooper = pr_cdcooper
			   AND bpr.nrdconta = pr_nrdconta
				 AND bpr.nrctrpro = pr_nrctrpro
				 AND bpr.tpctrpro IN (90,99)
				 AND bpr.flgbaixa = 1
				 AND bpr.tpdbaixa = 'A'
				 AND bpr.flblqjud <> 1;			
		
		  -- Retorno OK
		  pr_des_reto := 'OK';
			
			-- Commita alterações
			COMMIT;
		
		EXCEPTION				
			-- Críticas tratadas
			WHEN vr_exc_saida THEN
        pr_des_reto := 'NOK';
				gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => vr_nrsequen
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
			  ROLLBACK;
			-- Críticas nao tratadas
			WHEN OTHERS THEN																			
        vr_cdcritic := 0;
        vr_dscritic := 'Erro na rotina GRVM0001.pc_desfazer_solicitacao_baixa_automatica -> '||SQLERRM;        
				vr_nrsequen := 1;				
        pr_des_reto := 'NOK';
				gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => vr_nrsequen
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
														 
	      ROLLBACK;

		END;
	END pc_desfazer_baixa_automatica;

END GRVM0001;
/
