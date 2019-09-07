CREATE OR REPLACE PACKAGE CECRED."TELA_ATENDA_DESCTO" IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_DESCTO
  --  Sistema  : Ayllos Web
  --  Autor    : Lombardi
  --  Data     : Setembro - 2016                 Ultima atualizacao: 05/03/2019
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela Descontos dentro da ATENDA
  --
  -- Alteracoes:
  --
  --       11/12/2017 - P404 - Inclusao de Garantia de Cobertura das Operaçoes de Crédito (Augusto / Marcos (Supero))
  --       07/03/2019 - prj450 - Rating - Tratamento do Botão Confirma Novo limite Web
  --                          na tela - Desconto de Cheques (Fabio Adriano - AMcom)
  ---------------------------------------------------------------------------

  PROCEDURE pc_ren_lim_desc_cheque_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_desblq_incl_bordero_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_confirma_novo_limite_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                       ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                       ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                       ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_busca_inf_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                ,pr_cddopcao  IN VARCHAR2               --> Opção da tela
                                ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_busca_cheques_dsc_cst(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                    ,pr_nriniseq  IN INTEGER                --> Paginação - Inicio de sequencia
                                    ,pr_nrregist  IN INTEGER                --> Paginação - Número de registros
                                    ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                    ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_verifica_emitentes(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                                 ,pr_dscheque  IN VARCHAR2              --> Codigo do Indexador
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_manter_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                             ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                             ,pr_nrdolote  IN crapbdc.nrdolote%TYPE  --> Lote
                             ,pr_cddopcao  IN VARCHAR2               --> Opção da tela
                             ,pr_dscheque  IN CLOB                   --> Cheques
                             ,pr_dscheque_exc IN CLOB                --> Cheques a serem excluidos do bordero
                             ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                             ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                             ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo

  PROCEDURE pc_aprovar_reprovar_chq(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                   ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                   ,pr_dscheque  IN CLOB                   --> Cheques
                                   ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                   ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                   ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_verifica_assinatura_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                          ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                          ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                          ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                          ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                          ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                          ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                          ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_efetiva_desconto_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                       ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                       ,pr_cdopcolb  IN crapbdc.cdopcolb%TYPE  --> Operador Liberação
                                       ,pr_flresghj  IN INTEGER DEFAULT 0      --> Flag para resgatar cheques custodiados hoje
                                       ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_efetuar_resgate(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                              ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                              ,pr_dscheque  IN CLOB                   --> Cheques
                              ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                              ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                              ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_rejeitar_bordero(pr_nrdconta  IN crapcdb.nrdconta%TYPE  --> Conta
                               ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                               ,pr_flresghj  IN INTEGER DEFAULT 0      --> Flag para resgatar cheques custodiados hoje
                               ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                               ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                               ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_valida_valor_saldo(pr_nrdconta  IN crapcdb.nrdconta%TYPE  --> Numero da conta
                                 ,pr_vlverifi  IN NUMBER                 --> Valor para verificar
                                 ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_busca_cheques_cust_hj(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                    ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                    ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                    ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

END TELA_ATENDA_DESCTO;
/
CREATE OR REPLACE PACKAGE BODY CECRED."TELA_ATENDA_DESCTO" IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_DESCTO
  --  Sistema  : Ayllos Web
  --  Autor    : Lombardi
  --  Data     : Setembro - 2016                 Ultima atualizacao: 05/03/2019
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela Descontos dentro da ATENDA
  --
  -- Alteracoes: 04/10/2017 - Ajuste na pc_busca_inf_bordero para verificar
  --                          revisao cadastral na opcao de inclusao do bordero.
  --                          (Chamado 768648) - (Fabricio)
  --             07/03/2019 - prj450 - Rating - Tratamento do Botão Confirma Novo limite Web
  --                          na tela - Desconto de Cheques (Fabio Adriano - AMcom)
  --             15/03/2019 - prj450 - Bug 19190:Erro ao apresentar o rating tela ocorrencias - Desconto de Cheques (Heckmann - AMcom)
  ---------------------------------------------------------------------------

  PROCEDURE pc_ren_lim_desc_cheque_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: Pc_ren_lim_desc_cheque_web
    Sistema : Ayllos Web
    Autor   : Lombardi
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para renovar limite de desconto de cheques.

    Alteracoes:
    ..............................................................................*/
    DECLARE

      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Chama rotina de renovação
      LIMI0001.pc_renovar_lim_desc_cheque(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_vllimite => pr_vllimite
                                         ,pr_nrctrlim => pr_nrctrlim
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_nmdatela => vr_nmdatela
                                         ,pr_idorigem => vr_idorigem
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>ok</Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_ren_lim_desc_cheque_web: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_ren_lim_desc_cheque_web;

  PROCEDURE pc_desblq_incl_bordero_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: Pc_ren_lim_desc_cheque_web
    Sistema : Ayllos Web
    Autor   : Lombardi
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para desbloquear inclusao de desconto de cheques.

    Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      -- Chama rotina de desbloqueio para inclusao de bordero
      LIMI0001.pc_desblq_inclusao_bordero(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctrlim => pr_nrctrlim
                                         ,pr_nrdcaixa => vr_nrdcaixa
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_nmdatela => vr_nmdatela
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>ok</Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_desblq_incl_bordero_web: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_desblq_incl_bordero_web;

  PROCEDURE pc_confirma_novo_limite_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                       ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                       ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                       ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: Pc_ren_lim_desc_cheque_web
    Sistema : Ayllos Web
    Autor   : Lombardi
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para renovar limite de desconto de cheques.

    Alteracoes: 24/08/2017 - Ajuste para gravar log. (Lombardi)

                07/03/2019 - prj450 - Rating - Tratamento do Botão Confirma Novo limite Web
                             na tela - Desconto de Cheques (Fabio Adriano - AMcom)
    ..............................................................................*/
    DECLARE

      -- Verifica Conta
      CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT dtelimin
              ,cdsitdtl
              ,cdagenci
              ,nrcpfcnpj_base
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Verifica Conta
      CURSOR cr_crapcdc (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrctrlim IN crapcdc.nrctrlim%TYPE) IS
        SELECT 1
          FROM crapcdc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrctrlim
           AND tpctrlim = 2;
      rw_crapcdc cr_crapcdc%ROWTYPE;

      --Verifica limite
      CURSOR cr_craplim (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT nrctrlim
          FROM craplim
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpctrlim = 2
           AND insitlim = 2;
      rw_craplim cr_craplim%ROWTYPE;

      --Verifica limite
      CURSOR cr_craplim_ctr (pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_nrctrlim IN crapcdc.nrctrlim%TYPE) IS
        SELECT nrctrlim
              ,insitlim
              ,vllimite
              ,nrdconta
              ,tpctrlim
              ,cddlinha
              ,qtrenova
              ,nrctaav1
              ,nrctaav2
              ,idcobope
          FROM craplim
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrctrlim
           AND tpctrlim = 2;
      rw_craplim_ctr cr_craplim_ctr%ROWTYPE;

      -- Busca cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT vlmaxleg
             ,vlmaxutl
             ,vlcnsscr
         FROM crapcop
        WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca capa do lote
      CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplot.cdagenci%TYPE) IS
        SELECT nvl(MAX(nrdolote), 0) + 1
          FROM craplot
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = 700;

      -- Busca contratos que foram microfilmados.
      CURSOR cr_crapmcr (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN craplim.nrdconta%TYPE
                        ,pr_nrcontra IN craplim.nrctrlim%TYPE
                        ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
        SELECT 1
          FROM crapmcr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrcontra = pr_nrcontra
           AND tpctrmif = 2
           AND tpctrlim = pr_tpctrlim;
      rw_crapmcr cr_crapmcr%ROWTYPE;

      -- Informações de data do sistema
      rw_crapdat  btch0001.rw_crapdat%TYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida   EXCEPTION;
      vr_retorna_msg EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis auxiliares
      vr_flgfound     BOOLEAN;
      vr_vlmaxleg     crapcop.vlmaxleg%TYPE;
      vr_vlmaxutl     crapcop.vlmaxutl%TYPE;
      vr_vlminscr     crapcop.vlcnsscr%TYPE;
      vr_par_nrdconta INTEGER;
      vr_par_dsctrliq VARCHAR2(1000);
      vr_par_vlutiliz NUMBER;
      vr_qtctarel     INTEGER;
      vr_flggrupo     INTEGER;
      vr_nrdgrupo     INTEGER;
      vr_dsdrisco     VARCHAR2(2);
      vr_gergrupo     VARCHAR2(1000);
      vr_dsdrisgp     VARCHAR2(1000);
      vr_mensagem_01  VARCHAR2(1000);
      vr_mensagem_02  VARCHAR2(1000);
      vr_mensagem_03  VARCHAR2(1000);
      vr_mensagem_04  VARCHAR2(1000);
      vr_tab_grupo    geco0001.typ_tab_crapgrp;
      vr_valor        craplim.vllimite%TYPE;
      vr_index        INTEGER;
      vr_str_grupo    VARCHAR2(32767) := '';
      vr_nrdolote     craplot.nrdolote%TYPE;
      vr_vlutilizado  VARCHAR2(100) := '';
      vr_vlexcedido   VARCHAR2(100) := '';
      vr_rowid_log    ROWID;
      vr_strating     NUMBER;
      vr_flgrating    NUMBER;
      vr_vlendivid    craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
      vr_vllimrating  craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056

      --PL tables
      vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
      vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
      vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
      vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
      vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
      vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
      vr_tab_ratings          RATI0001.typ_tab_ratings;
      vr_tab_crapras          RATI0001.typ_tab_crapras;
      vr_tab_erro             GENE0001.typ_tab_erro;

      vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

    BEGIN

      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                                ,pr_action => NULL);
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se ocorrer algum erro
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => vr_cdcooper,
                                             pr_cdacesso => 'HABILITA_RATING_NOVO');

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Verifica se existe a conta
      OPEN cr_crapass (vr_cdcooper, pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      vr_flgfound := cr_crapass%FOUND;
      CLOSE cr_crapass;
      -- Se nao existir
      IF NOT vr_flgfound THEN
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se a conta foi eliminada
      IF rw_crapass.dtelimin IS NOT NULL THEN
        vr_cdcritic := 410;
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se a conta está em prejuizo
      IF rw_crapass.cdsitdtl IN (5,6,7,8) THEN
        vr_cdcritic := 695;
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se conta esta bloqueada
      IF rw_crapass.cdsitdtl IN (2,4) THEN
        vr_cdcritic := 95;
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se existe contrato
      IF pr_nrctrlim = 0 THEN
        vr_cdcritic := 22;
        RAISE vr_exc_saida;
      END IF;

      IF NVL(vr_cdagenci,0) = 0 THEN
        vr_cdagenci := rw_crapass.cdagenci;
      END IF;

      -- Verifica se ja existe lancamento
      OPEN cr_crapcdc (vr_cdcooper, pr_nrdconta, pr_nrctrlim);
      FETCH cr_crapcdc INTO rw_crapcdc;
      vr_flgfound := cr_crapcdc%FOUND;
      CLOSE cr_crapcdc;
      IF vr_flgfound THEN
        vr_cdcritic := 92;
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se ja existe limite ativo
      OPEN cr_craplim(vr_cdcooper, pr_nrdconta);
      FETCH cr_craplim INTO rw_craplim;
      vr_flgfound := cr_craplim%FOUND;
      CLOSE cr_craplim;
      IF vr_flgfound THEN
        vr_dscritic:= 'O contrato ' ||rw_craplim.nrctrlim || ' deve ser cancelado primeiro.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se ja existe limite ativo
      OPEN cr_craplim_ctr(vr_cdcooper, pr_nrdconta,pr_nrctrlim);
      FETCH cr_craplim_ctr INTO rw_craplim_ctr;
      vr_flgfound := cr_craplim_ctr%FOUND;
      CLOSE cr_craplim_ctr;
      IF NOT vr_flgfound THEN
        vr_cdcritic := 484;
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se esta em estudo
      IF rw_craplim_ctr.insitlim <> 1   THEN
        vr_dscritic := 'Deve estar em estudo.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se o limite está diferente do registro
      IF rw_craplim_ctr.vllimite <> pr_vllimite   THEN
        vr_cdcritic := 91;
        RAISE vr_exc_saida;
      END IF;

      -- Inicializa variaveis
      vr_vlmaxleg := 0;
      vr_vlmaxutl := 0;
      vr_vlminscr := 0;

      OPEN cr_crapcop(vr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      vr_flgfound := cr_crapcop%FOUND;
      CLOSE cr_crapcop;
      -- Carrega informacoes da cooperativa
      IF vr_flgfound THEN
        vr_vlmaxleg := rw_crapcop.vlmaxleg;
        vr_vlmaxutl := rw_crapcop.vlmaxutl;
        vr_vlminscr := rw_crapcop.vlcnsscr;
      END IF;

      -- Inicializa variaveis
      vr_par_nrdconta := pr_nrdconta;
      vr_par_dsctrliq := ' ';
      vr_par_vlutiliz := 0;
      vr_qtctarel     := 0;

      -- Verifica se tem grupo economico em formacao
      GECO0001.pc_busca_grupo_associado (pr_cdcooper => vr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_flggrupo => vr_flggrupo
                                        ,pr_nrdgrupo => vr_nrdgrupo
                                        ,pr_gergrupo => vr_gergrupo
                                        ,pr_dsdrisgp => vr_dsdrisgp);
      -- Se tiver grupo economico em formacao
      IF vr_gergrupo IS NOT NULL AND
         pr_cddopera < 1   THEN
        vr_mensagem_01 := vr_gergrupo || ' Confirma?';
      END IF;

      -- Se conta pertence a um grupo
      IF vr_flggrupo = 1 THEN
        geco0001.pc_calc_endivid_grupo(pr_cdcooper  => vr_cdcooper
                                      ,pr_cdagenci  => vr_cdagenci
                                      ,pr_nrdcaixa  => 0
                                      ,pr_cdoperad  => vr_cdoperad
                                      ,pr_nmdatela  => vr_nmdatela
                                      ,pr_idorigem  => 1
                                      ,pr_nrdgrupo  => vr_nrdgrupo
                                      ,pr_tpdecons  => TRUE
                                      ,pr_dsdrisco  => vr_dsdrisco
                                      ,pr_vlendivi  => vr_par_vlutiliz
                                      ,pr_tab_grupo => vr_tab_grupo
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        IF vr_vlmaxutl > 0 THEN
          -- Verifica se o valor limite é maior que o valor da divida
          -- e pega o maior valor
          IF pr_vllimite > vr_par_vlutiliz THEN
            vr_valor := pr_vllimite;
          ELSE
            vr_valor := vr_par_vlutiliz;
          END IF;
          -- Verifica se o valor é maior que o valor maximo
          -- utilizado pelo associado nos emprestimos
          IF vr_valor > vr_vlmaxutl AND
             pr_cddopera < 1        THEN
            vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
              to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
              to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') ||
              '.';
          END IF;
          -- Verifica se o valor é maior que o valor legal
          -- a ser emprestado pela cooperativa
          IF vr_valor > vr_vlmaxleg AND
             pr_cddopera < 1        THEN

            vr_mensagem_03 := 'Valor Legal Excedido';
            vr_vlutilizado := to_char(vr_par_vlutiliz,'999G999G990D00');
            vr_vlexcedido  := to_char((vr_valor - vr_vlmaxutl),'999G999G990D00');

            -- Abre tabela do grupo
            vr_str_grupo := '<grupo>';

            vr_qtctarel := 0;
            vr_index := vr_tab_grupo.first;
            WHILE vr_index IS NOT NULL LOOP
              -- Popula tabela do grupo
              vr_str_grupo := vr_str_grupo
              || '<conta>' ||
              to_char(gene0002.fn_mask_conta((vr_tab_grupo(vr_index).nrctasoc)))
              || '</conta>';
              vr_index := vr_tab_grupo.next(vr_index);
              vr_qtctarel := vr_qtctarel + 1;
            END LOOP;
            -- Encerra tabela grupo
            vr_str_grupo := vr_str_grupo || '</grupo>' ||
             '<qtctarel>' || vr_qtctarel || '</qtctarel>';

          END IF;
          -- Verifica se o valor é maior que o valor da consulta SCR
          IF vr_valor > vr_vlminscr AND
             pr_cddopera < 1        THEN
            vr_mensagem_04 := 'Efetue consulta no SCR.';
          END IF;
        END IF;
      ELSE --  Se conta nao pertence a um grupo

        gene0005.pc_saldo_utiliza(pr_cdcooper    => vr_cdcooper
                                 ,pr_tpdecons    => 1
                                 ,pr_dsctrliq    => vr_par_dsctrliq
                                 ,pr_cdprogra    => vr_nmdatela
                                 ,pr_nrdconta    => vr_par_nrdconta
                                 ,pr_tab_crapdat => rw_crapdat
                                 ,pr_inusatab    => TRUE
                                 ,pr_vlutiliz    => vr_par_vlutiliz
                                 ,pr_cdcritic    => vr_cdcritic
                                 ,pr_dscritic    => vr_dscritic);

        IF vr_vlmaxutl > 0 THEN
          -- Verifica se o valor limite é maior que o valor da divida
          -- e pega o maior valor
          IF pr_vllimite > vr_par_vlutiliz THEN
            vr_valor := pr_vllimite;
          ELSE
            vr_valor := vr_par_vlutiliz;
          END IF;
          -- Verifica se o valor é maior que o valor maximo
          -- utilizado pelo associado nos emprestimos
          IF vr_valor > vr_vlmaxutl AND
             pr_cddopera < 1        THEN
            vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
              to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
              to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') || '.';
          END IF;
          -- Verifica se o valor é maior que o valor legal
          -- a ser emprestado pela cooperativa
          IF vr_valor > vr_vlmaxleg AND
             pr_cddopera < 1        THEN
            vr_mensagem_03 := 'Valor legal excedido. Utilizado R$: ' ||
              to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
              to_char((vr_valor - vr_vlmaxleg),'999G999G990D00') || '.';
          END IF;
          -- Verifica se o valor é maior que o valor da consulta SCR
          IF vr_valor > vr_vlminscr AND
             pr_cddopera < 1        THEN
            vr_mensagem_04 := 'Efetue consulta no SCR.';
          END IF;

        END IF;
      END IF;

      -- Se houver alguma mensagem para o usuario
      IF vr_mensagem_01 IS NOT NULL OR
         vr_mensagem_02 IS NOT NULL OR
         vr_mensagem_03 IS NOT NULL OR
         vr_mensagem_04 IS NOT NULL THEN
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>' ||
                                       '<Msg>' ||
                                           '<msg_01>' || vr_mensagem_01 || '</msg_01>' ||
                                           '<msg_02>' || vr_mensagem_02 || '</msg_02>' ||
                                           '<msg_03>' || vr_mensagem_03 || '</msg_03>' ||
                                           '<msg_04>' || vr_mensagem_04 || '</msg_04>' ||
                                                          vr_str_grupo  ||
                                           '<vlutil>' || vr_vlutilizado || '</vlutil>' ||
                                           '<vlexce>' || vr_vlexcedido  || '</vlexce>' ||
                                       '</Msg></Root>');
      ELSE
        -- Verifica se ja existe lote criado
        OPEN cr_craplot(pr_cdcooper => vr_cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_cdagenci => vr_cdagenci);
        FETCH cr_craplot INTO vr_nrdolote;

        -- Se não, cria novo lote
        BEGIN
          INSERT INTO craplot (cdcooper
                              ,dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,tplotmov
                              ,nrseqdig
                              ,qtcompln
                              ,qtinfoln
                              ,vlcompcr
                              ,vlinfocr
                              ,cdoperad)
                       VALUES (vr_cdcooper
                              ,rw_crapdat.dtmvtolt
                              ,vr_cdagenci
                              ,700
                              ,vr_nrdolote
                              ,27
                              ,1
                              ,1
                              ,1
                              ,pr_vllimite
                              ,pr_vllimite
                              ,vr_cdoperad);
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir capa do lote. ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

        -- Atualiza Limite de credito
        BEGIN
          UPDATE craplim
             SET insitlim = 2
                ,qtrenova = 0
                ,dtinivig = rw_crapdat.dtmvtolt
                ,dtfimvig = (rw_crapdat.dtmvtolt + craplim.qtdiavig)
           WHERE cdcooper = vr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctrlim = pr_nrctrlim
             AND tpctrlim = 2;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar limite de credito. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Efetuar o bloqueio de possíveis coberturas vinculadas ao limite anterior
        BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_nmdatela => 'ATENDA'
                                             ,pr_idcobertura => rw_craplim_ctr.idcobope
                                             ,pr_inbloq_desbloq => 'B'
                                             ,pr_cdoperador => vr_cdoperad
                                             ,pr_flgerar_log => 'S'
                                             ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se ja existe contrato microfilmado
        OPEN cr_crapmcr (pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => rw_craplim_ctr.nrdconta
                        ,pr_nrcontra => rw_craplim_ctr.nrctrlim
                        ,pr_tpctrlim => rw_craplim_ctr.tpctrlim);
        FETCH cr_crapmcr INTO rw_crapmcr;
        vr_flgfound := cr_crapmcr%FOUND;
        CLOSE cr_crapmcr;
        IF vr_flgfound THEN
          vr_cdcritic := 92;
          RAISE vr_exc_saida;
        END IF;

         -- Cria novo contrato para ser microfilmado
        BEGIN
          INSERT INTO crapmcr (dtmvtolt
                              ,cdagenci
                              ,nrdolote
                              ,cdbccxlt
                              ,nrdconta
                              ,nrcontra
                              ,tpctrmif
                              ,vlcontra
                              ,nrctaav1
                              ,nrctaav2
                              ,tpctrlim
                              ,qtrenova
                              ,cddlinha
                              ,cdcooper)
                      VALUES (rw_crapdat.dtmvtolt
                             ,rw_crapass.cdagenci
                             ,1
                             ,700
                             ,rw_craplim_ctr.nrdconta
                             ,rw_craplim_ctr.nrctrlim
                             ,2
                             ,rw_craplim_ctr.vllimite
                             ,rw_craplim_ctr.nrctaav1
                             ,rw_craplim_ctr.nrctaav2
                             ,rw_craplim_ctr.tpctrlim
                             ,rw_craplim_ctr.qtrenova
                             ,rw_craplim_ctr.cddlinha
                             ,vr_cdcooper);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar contrato para ser microfilmado. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Cria lancamento de contratos de descontos.
        BEGIN
          INSERT INTO crapcdc (dtmvtolt
                              ,cdagenci
                              ,cdbccxlt
                              ,nrdolote
                              ,nrdconta
                              ,nrctrlim
                              ,vllimite
                              ,nrseqdig
                              ,cdcooper
                              ,tpctrlim)
                       VALUES (rw_crapdat.dtmvtolt
                              ,vr_cdagenci
                              ,700
                              ,vr_nrdolote
                              ,pr_nrdconta
                              ,pr_nrctrlim
                              ,pr_vllimite
                              ,1
                              ,vr_cdcooper
                              ,2);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao criar lancamento de contratos de descontos. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- gera rating
        rati0001.pc_gera_rating(pr_cdcooper => vr_cdcooper                         --> Codigo Cooperativa
                               ,pr_cdagenci => vr_cdagenci                         --> Codigo Agencia
                               ,pr_nrdcaixa => vr_nrdcaixa                         --> Numero Caixa
                               ,pr_cdoperad => vr_cdoperad                         --> Codigo Operador
                               ,pr_nmdatela => 'ATENDA'                            --> Nome da tela
                               ,pr_idorigem => vr_idorigem                         --> Identificador Origem
                               ,pr_nrdconta => pr_nrdconta                         --> Numero da Conta
                               ,pr_idseqttl => 1                                   --> Sequencial do Titular
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt                 --> Data de movimento
                               ,pr_dtmvtopr => rw_crapdat.dtmvtopr                 --> Data do próximo dia útil
                               ,pr_inproces => rw_crapdat.inproces                 --> Situação do processo
                               ,pr_tpctrrat => 2                                   --> Tipo Contrato Rating
                               ,pr_nrctrrat => pr_nrctrlim                         --> Numero Contrato Rating
                               ,pr_flgcriar => 1                                   --> Criar rating
                               ,pr_flgerlog => 1                                   -->  Identificador de geração de log
                               ,pr_tab_rating_sing => vr_tab_crapras               --> Registros gravados para rating singular
                               ,pr_tab_impress_coop => vr_tab_impress_coop         --> Registro impressão da Cooperado
                               ,pr_tab_impress_rating => vr_tab_impress_rating     --> Registro itens do Rating
                               ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                               ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                               ,pr_tab_impress_assina => vr_tab_impress_assina     --> Assinatura na impressao do Rating
                               ,pr_tab_efetivacao => vr_tab_efetivacao             --> Registro dos itens da efetivação
                               ,pr_tab_ratings  => vr_tab_ratings                  --> Informacoes com os Ratings do Cooperado
                               ,pr_tab_crapras  => vr_tab_crapras                  --> Tabela com os registros processados
                               ,pr_tab_erro => vr_tab_erro                         --> Tabela de retorno de erro
                               ,pr_des_reto => pr_des_erro);                       --> Ind. de retorno OK/NOK
        -- Em caso de erro
        IF pr_des_erro <> 'OK' THEN

          vr_cdcritic:= vr_tab_erro(0).cdcritic;
          vr_dscritic:= vr_tab_erro(0).dscritic;

          pr_des_erro := 'NOK';
          RAISE vr_exc_saida;
          RETURN;

        END IF;

        -- P450 SPT13 - alteracao para habilitar rating novo
        IF (vr_cdcooper <> 3 OR vr_habrat = 'S') THEN
          /* Validar Status rating */
          RATI0003.pc_busca_status_rating(pr_cdcooper  => vr_cdcooper
                                         ,pr_nrdconta  => pr_nrdconta
                                         ,pr_tpctrato  => 2
                                         ,pr_nrctrato  => pr_nrctrlim
                                         ,pr_strating  => vr_strating
                                         ,pr_flgrating => vr_flgrating
                                         ,pr_cdcritic  => vr_cdcritic
                                         ,pr_dscritic  => vr_dscritic);

          IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;
          -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
          RATI0003.pc_busca_endivid_param(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_vlendivi => vr_vlendivid
                                         ,pr_vlrating => vr_vllimrating
                                         ,pr_dscritic => vr_dscritic);
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          -- Status do rating inválido
          IF vr_flgrating = 0 THEN
            vr_dscritic := 'Contrato não pode ser efetivado porque não há Rating válido.';
            RAISE vr_exc_saida;

          ELSE -- Status do rating válido

            -- Se Endividamento + Contrato atual > Parametro Rating (TAB056)
            IF ((vr_vlendivid) > vr_vllimrating) THEN

              -- Gravar o Rating da operação, efetivando-o

              rati0003.pc_grava_rating_operacao(pr_cdcooper          => vr_cdcooper
                                               ,pr_nrdconta          => pr_nrdconta
                                               ,pr_tpctrato          => 2
                                               ,pr_nrctrato          => pr_nrctrlim
                                               ,pr_dtrating          => rw_crapdat.dtmvtolt
                                               ,pr_strating          => 4
                                               ,pr_efetivacao_rating => 1 -- Identificar se deve considerar o parâmetro de contingência
                                               --Variáveis para gravar o histórico
                                               ,pr_cdoperad          => vr_cdoperad
                                               ,pr_dtmvtolt          => rw_crapdat.dtmvtolt
                                               ,pr_valor             => pr_vllimite
                                               ,pr_rating_sugerido   => NULL
                                               ,pr_justificativa     => 'Efetivação do rating'
                                               ,pr_tpoperacao_rating => 2
                                               ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                               --Variáveis de crítica
                                               ,pr_cdcritic          => vr_cdcritic
                                               ,pr_dscritic          => vr_dscritic);

              IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
            END IF;
          END IF;
        END IF;
        -- P450 SPT13 - alteracao para habilitar rating novo

        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => ' '
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                            ,pr_dstransa => 'Confirmar Novo limite de desconto de cheques.'
                            ,pr_dttransa => trunc(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'ATENDA'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_rowid_log);

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_confirma_novo_limite_web: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_confirma_novo_limite_web;

  PROCEDURE pc_busca_inf_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                ,pr_cddopcao  IN VARCHAR2               --> Opção da tela
                                ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................

    Programa: pc_busca_inf_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar informações de desconto

    Alteracoes: -----
  ..............................................................................*/
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(1000);

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis auxiliares
    vr_inpessoa NUMBER;
    vr_stsnrcal BOOLEAN;
    vr_flbloque NUMBER := 0;

    vr_tab_cheques DSCC0001.typ_tab_cheques;
    vr_idx_ocorre PLS_INTEGER;

    vr_nmcheque VARCHAR2(150);
    vr_nrcpfcgc VARCHAR2(25);

    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);


    -- Buscar informações do bordero
    CURSOR cr_crapbdc(pr_cdcooper IN crapcdb.cdcooper%TYPE
                     ,pr_nrdconta IN crapcdb.nrdconta%TYPE
                     ,pr_nrborder IN crapcdb.nrborder%TYPE) IS
      SELECT bdc.insitbdc
            ,bdc.dtrejeit
            ,bdc.nrctrlim
        FROM crapbdc bdc
       WHERE bdc.cdcooper = pr_cdcooper
         AND bdc.nrdconta = pr_nrdconta
         AND bdc.nrborder = pr_nrborder;
    rw_crapbdc cr_crapbdc%ROWTYPE;

    -- Buscar valor de limite disponível
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                     ,pr_nrdconta IN craplim.nrdconta%TYPE
                     ,pr_dtmvtolt IN DATE) IS
      SELECT to_char(vllimite -
              nvl((SELECT SUM(vlcheque) FROM crapcdb
              WHERE cdcooper = pr_cdcooper
                AND nrdconta = pr_nrdconta
                AND dtlibbdc IS NOT NULL
                AND dtlibera > pr_dtmvtolt
                AND insitchq IN (0,2)
                AND insitana = 1), 0), 'fm999g999g999g990d00'
              )
              vllimdis,
              nrctrlim
       FROM craplim
      WHERE cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND insitlim = 2
        AND tpctrlim = 2;
    rw_craplim cr_craplim%ROWTYPE;

    -- Buscar cheques para alteração
    CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%TYPE
                      ,pr_nrdconta IN crapcdb.nrdconta%TYPE
                      ,pr_nrborder IN crapcdb.nrborder%TYPE) IS
      SELECT cdb.dtlibera
            ,cdb.cdcmpchq
            ,cdb.cdbanchq
            ,cdb.cdagechq
            ,cdb.nrctachq
            ,cdb.nrcheque
            ,cdb.vlcheque
            ,cdb.dsdocmc7
            ,decode(
        (SELECT 1
           FROM crapcst cst
          WHERE cst.cdcooper = pr_cdcooper
            AND cst.nrdconta = pr_nrdconta
            AND cst.nrborder = pr_nrborder
            AND cst.cdcmpchq = cdb.cdcmpchq
            AND cst.cdbanchq = cdb.cdbanchq
            AND cst.cdagechq = cdb.cdagechq
            AND cst.nrcheque = cdb.nrcheque
            AND cst.nrctachq = cdb.nrctachq
         UNION
         SELECT dcc.inconcil
           FROM crapdcc dcc
          WHERE dcc.cdcooper = pr_cdcooper
            AND dcc.nrdconta = pr_nrdconta
            AND dcc.nrborder = pr_nrborder
            AND dcc.cdcmpchq = cdb.cdcmpchq
            AND dcc.cdbanchq = cdb.cdbanchq
            AND dcc.cdagechq = cdb.cdagechq
            AND dcc.nrcheque = cdb.nrcheque
            AND dcc.nrctachq = cdb.nrctachq
            AND dcc.nrconven = 1
            AND dcc.intipmvt IN (1,3)
            AND dcc.cdtipmvt = 1
            AND trim(dcc.cdocorre) IS NULL), 1, 'Entregue', 0, 'Pendente Entrega') dssitchq,
        (SELECT cec.nmcheque
           FROM crapcec cec
          WHERE cec.cdcooper = cdb.cdcooper
            AND cec.nrcpfcgc = cdb.nrcpfcgc
            AND cec.cdcmpchq = cdb.cdcmpchq
            AND cec.cdbanchq = cdb.cdbanchq
            AND cec.cdagechq = cdb.cdagechq
            AND cec.nrctachq = cdb.nrctachq
            AND cec.nrdconta = 0) nmcheque,
        (SELECT nrcpfcgc
           FROM crapcec cec
          WHERE cec.cdcooper = cdb.cdcooper
            AND cec.nrcpfcgc = cdb.nrcpfcgc
            AND cec.cdcmpchq = cdb.cdcmpchq
            AND cec.cdbanchq = cdb.cdbanchq
            AND cec.cdagechq = cdb.cdagechq
            AND cec.nrctachq = cdb.nrctachq
            AND cec.nrdconta = 0) nrcpfcgc
      FROM crapcdb cdb
      WHERE cdb.cdcooper = pr_cdcooper
        AND cdb.nrdconta = pr_nrdconta
        AND cdb.nrborder = pr_nrborder;

    -- Buscar valor total dos cheques do borderô
    CURSOR cr_crapcdb_total(pr_cdcooper IN crapcdb.cdcooper%TYPE
                           ,pr_nrdconta IN crapcdb.nrdconta%TYPE
                           ,pr_nrborder IN crapcdb.nrborder%TYPE
                           ,pr_dtmvtolt IN crapcdb.dtlibera%TYPE) IS
      SELECT to_char(SUM(cdb.vlcheque),'fm999g999g999g990d00') vlborder
        FROM crapcdb cdb
       WHERE cdb.cdcooper = pr_cdcooper
         AND cdb.nrdconta = pr_nrdconta
         AND cdb.nrborder = pr_nrborder
         AND cdb.insitchq = 2
         AND cdb.dtlibera > pr_dtmvtolt;
    rw_crapcdb_total cr_crapcdb_total%ROWTYPE;

    -- Burscar cheques para resgate
    CURSOR cr_crapcdb_rsg(pr_cdcooper IN crapcdb.cdcooper%TYPE
                         ,pr_nrdconta IN crapcdb.nrdconta%TYPE
                         ,pr_nrborder IN crapcdb.nrborder%TYPE
                         ,pr_dtmvtolt IN crapcdb.dtlibera%TYPE) IS
      SELECT cdb.dtlibera
            ,cdb.cdcmpchq
            ,cdb.cdbanchq
            ,cdb.cdagechq
            ,cdb.nrctachq
            ,cdb.nrcheque
            ,cdb.vlcheque
            ,cdb.dsdocmc7
            ,(SELECT cec.nmcheque
                FROM crapcec cec
               WHERE cec.cdcooper = cdb.cdcooper
                 AND cec.nrcpfcgc = cdb.nrcpfcgc
                 AND cec.cdcmpchq = cdb.cdcmpchq
                 AND cec.cdbanchq = cdb.cdbanchq
                 AND cec.cdagechq = cdb.cdagechq
                 AND cec.nrctachq = cdb.nrctachq
                 AND cec.nrdconta = 0) nmcheque
            ,(SELECT nrcpfcgc
                FROM crapcec cec
               WHERE cec.cdcooper = cdb.cdcooper
                 AND cec.nrcpfcgc = cdb.nrcpfcgc
                 AND cec.cdcmpchq = cdb.cdcmpchq
                 AND cec.cdbanchq = cdb.cdbanchq
                 AND cec.cdagechq = cdb.cdagechq
                 AND cec.nrctachq = cdb.nrctachq
                 AND cec.nrdconta = 0) nrcpfcgc
            FROM crapcdb cdb
          WHERE cdb.cdcooper = pr_cdcooper
            AND cdb.nrdconta = pr_nrdconta
            AND cdb.nrborder = pr_nrborder
            AND cdb.insitchq = 2
            AND cdb.dtlibera > pr_dtmvtolt; -- somente cheques a vencer

    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Buscar cadastro do cooperado emitente
    CURSOR cr_crapass_2 (pr_cdagectl crapcop.cdagectl%TYPE,
                         pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.inpessoa,
             ass.nmprimtl,
             CASE
               WHEN ass.inpessoa IN (1) THEN
                (SELECT ttl.nmtalttl
                   FROM crapttl ttl
                  WHERE ttl.cdcooper = ass.cdcooper
                    AND ttl.nrdconta = ass.nrdconta
                    AND ttl.idseqttl = 1)
               ELSE
                (SELECT jur.nmtalttl
                   FROM crapjur jur
                  WHERE jur.cdcooper = ass.cdcooper
                    AND jur.nrdconta = ass.nrdconta)
             END nmtalttl,
             CASE
               WHEN ass.inpessoa IN (1) THEN
                (SELECT ttl.nrcpfcgc
                   FROM crapttl ttl
                  WHERE ttl.cdcooper = ass.cdcooper
                    AND ttl.nrdconta = ass.nrdconta
                    AND ttl.idseqttl = 1)
               ELSE
                ass.nrcpfcgc
             END nrcpfcgc
        FROM crapass ass,
             crapcop cop
       WHERE cop.cdagectl = pr_cdagectl
         AND ass.cdcooper = cop.cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass_2  cr_crapass_2%ROWTYPE;

    /* Cursor generico de parametrizacao */
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                     ,pr_nmsistem IN craptab.nmsistem%TYPE
                     ,pr_tptabela IN craptab.tptabela%TYPE
                     ,pr_cdempres IN craptab.cdempres%TYPE
                     ,pr_cdacesso IN craptab.cdacesso%TYPE
                     ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.dstextab
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND upper(tab.nmsistem) = pr_nmsistem
           AND upper(tab.tptabela) = pr_tptabela
           AND tab.cdempres = pr_cdempres
           AND upper(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist = pr_tpregist;
    rw_craptab cr_craptab%ROWTYPE;

    -- Cursor para verificar se existe recadastro na conta
    CURSOR cr_crapalt(pr_cdcooper IN crapalt.cdcooper%TYPE
                     ,pr_nrdconta IN crapalt.nrdconta%TYPE
                     ,pr_dtmvtolt IN crapalt.dtaltera%TYPE
                     ,pr_dtrecadast PLS_INTEGER) IS
        SELECT 1
          FROM crapalt a
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND tpaltera = 1
           AND a.dtaltera > pr_dtmvtolt - pr_dtrecadast;
    rw_crapalt cr_crapalt%ROWTYPE;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;



  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    IF pr_cddopcao <> 'R' THEN

    OPEN cr_craplim(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    FETCH cr_craplim INTO rw_craplim;

    IF cr_craplim%NOTFOUND THEN
      -- Fecha cursor
      CLOSE cr_craplim;
      -- Atribui crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperado não possui limite de desconto de cheque ativo.';
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    -- Fecha cursor
    CLOSE cr_craplim;
    END IF;

    -- Incluir
    IF pr_cddopcao = 'I' THEN

      -- Le tabela de dias de recadastro
      OPEN cr_craptab(pr_cdcooper => vr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'GENERI'
                     ,pr_cdempres => vr_cdcooper
                     ,pr_cdacesso => 'ATUALIZCAD'
                     ,pr_tpregist => 0);
      FETCH cr_craptab INTO rw_craptab;

      IF cr_craptab%FOUND THEN
        CLOSE cr_craptab;
        -- Verifica se a conta esta recadastrada
        OPEN cr_crapalt(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_dtrecadast => rw_craptab.dstextab);
        FETCH cr_crapalt INTO rw_crapalt;
        -- se nao encontrar deve solicitar revisao cadastral
        IF cr_crapalt%NOTFOUND THEN
          CLOSE cr_crapalt;
          vr_cdcritic := 763;
          vr_dscritic := NULL;
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapalt;
      ELSE
        CLOSE cr_craptab;
      END IF;

      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados><nrctrlim>' || rw_craplim.nrctrlim || '</nrctrlim>' ||
                                     '<vllimdsp>' || rw_craplim.vllimdis || '</vllimdsp>' ||
                                     '</Dados></Root>');
    -- Alterar
    ELSIF pr_cddopcao = 'A' THEN

      -- Buscar bordero
      OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrborder => pr_nrborder);
      FETCH cr_crapbdc INTO rw_crapbdc;

      IF cr_crapbdc%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapbdc;
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Borderô não encontrado.';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_crapbdc;

      -- Se estiver rejeitado
      IF rw_crapbdc.dtrejeit IS NOT NULL THEN
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Operação não permitida. Borderô rejeitado.';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;

      -- Se não estiver em analise ou em estudo
      IF rw_crapbdc.insitbdc NOT IN(1,2) THEN
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Borderô já liberado.';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;

      -- Leitura da PL/Table e geração do arquivo XML
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados><nrctrlim>' || rw_craplim.nrctrlim || '</nrctrlim>' ||
                                     '<vllimdsp>' || rw_craplim.vllimdis || '</vllimdsp><Cheques>');

      FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrborder => pr_nrborder) LOOP


        -- Se for do sistema CECRED
        IF rw_crapcdb.cdbanchq = 85 THEN
          -- Buscar cadastro do cooperado emitente
          OPEN cr_crapass_2 (pr_cdagectl => rw_crapcdb.cdagechq
                            ,pr_nrdconta => rw_crapcdb.nrctachq);
          FETCH cr_crapass_2 INTO rw_crapass_2;
          CLOSE cr_crapass_2;

          vr_nmcheque := nvl(rw_crapass_2.nmtalttl,' ');

          IF TRIM(rw_crapass_2.nrcpfcgc) IS NOT NULL THEN
            vr_nrcpfcgc :=  gene0002.fn_mask_cpf_cnpj(rw_crapass_2.nrcpfcgc,rw_crapass_2.inpessoa);
          ELSE
            vr_nrcpfcgc := ' ';
          END IF;

        ELSE
        -- Buscar inpessoa do cpf/cnpj
        gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_crapcdb.nrcpfcgc
                                   ,pr_stsnrcal => vr_stsnrcal
                                   ,pr_inpessoa => vr_inpessoa);

          vr_nmcheque := nvl(rw_crapcdb.nmcheque,' ');
          IF TRIM(rw_crapcdb.nrcpfcgc) IS NOT NULL THEN
            vr_nrcpfcgc :=  gene0002.fn_mask_cpf_cnpj(rw_crapcdb.nrcpfcgc,vr_inpessoa);
          ELSE
            vr_nrcpfcgc := ' ';
          END IF;
        END IF;


        pc_escreve_xml(
                   '<Cheque>'
                || '<dtlibera>' || to_char(rw_crapcdb.dtlibera, 'DD/MM/RRRR') ||'</dtlibera>'
                || '<cdcmpchq>' || rw_crapcdb.cdcmpchq || '</cdcmpchq>'
                || '<cdbanchq>' || rw_crapcdb.cdbanchq || '</cdbanchq>'
                || '<cdagechq>' || rw_crapcdb.cdagechq || '</cdagechq>'
                || '<nrctachq>' || CASE WHEN rw_crapcdb.cdbanchq = 1 THEN
                                      gene0002.fn_mask(rw_crapcdb.nrctachq,'zzzz.zzz-z')
                                 ELSE
                                      gene0002.fn_mask(rw_crapcdb.nrctachq,'zzzzzz.zzz-z')
                                 END                   || '</nrctachq>'

                || '<nrcheque>' || rw_crapcdb.nrcheque || '</nrcheque>'
                || '<vlcheque>' || to_char(rw_crapcdb.vlcheque, 'fm999g999g999g990d00') || '</vlcheque>'
                || '<nmcheque><![CDATA[' || nvl(vr_nmcheque,' ') || ']]></nmcheque>'
                || '<nrcpfcgc>' || vr_nrcpfcgc || '</nrcpfcgc>'
                || '<dssitchq>' || rw_crapcdb.dssitchq || '</dssitchq>'
                || '<dsdocmc7>' || regexp_replace(rw_crapcdb.dsdocmc7, '[^0-9]') || '</dsdocmc7>'
                || '</Cheque>');
      END LOOP;

      pc_escreve_xml( '</Cheques></Dados></Root>',TRUE);

      pr_retxml := XMLTYPE.CREATEXML(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    -- Analisar
    ELSIF pr_cddopcao = 'N' THEN

      -- Buscar bordero
      OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrborder => pr_nrborder);
      FETCH cr_crapbdc INTO rw_crapbdc;

      IF cr_crapbdc%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapbdc;
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Borderô não encontrado.';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_crapbdc;

      -- Se estiver rejeitado
      IF rw_crapbdc.dtrejeit IS NOT NULL THEN
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Operação não permitida. Borderô rejeitado.';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;

      -- Se não estiver em analise ou em estudo
      IF rw_crapbdc.insitbdc NOT IN(1,2) THEN
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Borderô já liberado.';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;

      -- Buscar informações do cheque para analise
      DSCC0001.pc_busca_cheques_analise(pr_cdcooper => vr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrborder => pr_nrborder
                                       ,pr_tab_cheques => vr_tab_cheques
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      -- Se houve críticas
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Gerar crítica
        RAISE vr_exc_erro;
      END IF;

      -- Analisar os cheques do borderô
      dscc0001.pc_analisar_bordero_cheques(pr_cdcooper => vr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_cdagenci => vr_cdagenci
                                          ,pr_idorigem => vr_idorigem
                                          ,pr_cdoperad => vr_cdoperad
                                          ,pr_nrborder => pr_nrborder
                                          ,pr_tab_cheques => vr_tab_cheques
                                          ,pr_flganali => 0
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

      -- Se houve críticas
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Gerar crítica
        RAISE vr_exc_erro;
      END IF;

      IF vr_tab_cheques.count > 0 THEN
        -- Leitura da PL/Table e geração do arquivo XML
        -- Inicializar o CLOB
        vr_des_xml := NULL;
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- Inicilizar as informações do XML
        vr_texto_completo := NULL;

        pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                   '<Root><Dados><nrctrlim>' || rw_craplim.nrctrlim || '</nrctrlim>' ||
                       '<vllimdsp>' || rw_craplim.vllimdis || '</vllimdsp><Cheques>');

        FOR idx IN vr_tab_cheques.first..vr_tab_cheques.last LOOP
          -- Buscar inpessoa do cpf/cnpj
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_tab_cheques(idx).nrcpfcgc
                                     ,pr_stsnrcal => vr_stsnrcal
                                     ,pr_inpessoa => vr_inpessoa);

          pc_escreve_xml( '<Cheque>'
                  || '<dtlibera>' || to_char(vr_tab_cheques(idx).dtlibera, 'DD/MM/RRRR') ||'</dtlibera>'
                  || '<cdcmpchq>' || vr_tab_cheques(idx).cdcmpchq || '</cdcmpchq>'
                  || '<cdbanchq>' || vr_tab_cheques(idx).cdbanchq || '</cdbanchq>'
                  || '<cdagechq>' || vr_tab_cheques(idx).cdagechq || '</cdagechq>'
                  || '<nrctachq>' || CASE WHEN vr_tab_cheques(idx).cdbanchq = 1 THEN
                                        gene0002.fn_mask(vr_tab_cheques(idx).nrctachq,'zzzz.zzz-z')
                                   ELSE
                                        gene0002.fn_mask(vr_tab_cheques(idx).nrctachq,'zzzzzz.zzz-z')
                                   END                   || '</nrctachq>'

                  || '<nrcheque>' || vr_tab_cheques(idx).nrcheque || '</nrcheque>'
                  || '<nmcheque><![CDATA[' || nvl(vr_tab_cheques(idx).nmcheque,' ') || ']]></nmcheque>'
                  || '<nrcpfcgc>' || CASE WHEN trim(vr_tab_cheques(idx).nrcpfcgc) <> 0 THEN
                                        gene0002.fn_mask_cpf_cnpj(vr_tab_cheques(idx).nrcpfcgc
                                                                 ,vr_inpessoa)
                                     END
                                                         || '</nrcpfcgc>'
                  || '<vlcheque>' || to_char(vr_tab_cheques(idx).vlcheque, 'fm999g999g999g990d00') || '</vlcheque>'
                  || '<dscritic>');

          -- Inicializa o bloqueio
          vr_flbloque := 0;

          IF vr_tab_cheques(idx).ocorrencias.count > 0 THEN
            -- Busca primeiro indice da PlTable
            vr_idx_ocorre := vr_tab_cheques(idx).ocorrencias.first;

            LOOP
              EXIT WHEN vr_idx_ocorre IS NULL;

              pc_escreve_xml( '<![CDATA['
                      || vr_tab_cheques(idx).ocorrencias(vr_idx_ocorre).cdocorre || ' - '
                      || vr_tab_cheques(idx).ocorrencias(vr_idx_ocorre).dsrestri ||' </br>]]>');

              -- Se alguma ocorrência bloqueia a operação
              IF vr_tab_cheques(idx).ocorrencias(vr_idx_ocorre).flbloque = 1 THEN
                -- Bloqueia aprovação
                vr_flbloque := 1;
              END IF;
              vr_idx_ocorre := vr_tab_cheques(idx).ocorrencias.next(vr_idx_ocorre);
            END LOOP;
          END IF;
          pc_escreve_xml(  '</dscritic>'
                  || '<insitana>' || vr_tab_cheques(idx).insitana || '</insitana>'
                  || '<dsdocmc7>' || regexp_replace(vr_tab_cheques(idx).dsdocmc7, '[^0-9]') || '</dsdocmc7>'
                  || '<flbloque>' || vr_flbloque || '</flbloque>'
                  || '</Cheque>');

        END LOOP;
        pc_escreve_xml('</Cheques></Dados></Root>',TRUE);
        pr_retxml := XMLTYPE.CREATEXML(vr_des_xml);

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

      ELSE
        -- Gerar crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Cheques não encontrados.';
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;
    -- Resgatar
    ELSIF pr_cddopcao = 'R' THEN

      -- Buscar bordero
      OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrborder => pr_nrborder);
      FETCH cr_crapbdc INTO rw_crapbdc;

      IF cr_crapbdc%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapbdc;
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Borderô não encontrado.';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
      CLOSE cr_crapbdc;

      -- Se não estiver liberado
      IF rw_crapbdc.insitbdc <> 3 THEN
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Borderô ainda não foi liberado.';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;

      -- Buscar soma do valor dos cheques do borderô
      OPEN cr_crapcdb_total(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrborder => pr_nrborder
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
      FETCH cr_crapcdb_total INTO rw_crapcdb_total;

      -- Leitura da PL/Table e geração do arquivo XML
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;

      pc_escreve_xml( '<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                 '<Root><Dados><nrctrlim>' || rw_crapbdc.nrctrlim || '</nrctrlim>' ||
                     '<vlborder>' || rw_crapcdb_total.vlborder || '</vlborder><Cheques>');

      FOR rw_crapcdb_rsg IN cr_crapcdb_rsg(pr_cdcooper => vr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrborder => pr_nrborder
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

        -- Buscar inpessoa do cpf/cnpj
        gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_crapcdb_rsg.nrcpfcgc
                                   ,pr_stsnrcal => vr_stsnrcal
                                   ,pr_inpessoa => vr_inpessoa);

        pc_escreve_xml(  '<Cheque>'
                || '<dtlibera>' || to_char(rw_crapcdb_rsg.dtlibera, 'DD/MM/RRRR') ||'</dtlibera>'
                || '<cdcmpchq>' || rw_crapcdb_rsg.cdcmpchq || '</cdcmpchq>'
                || '<cdbanchq>' || rw_crapcdb_rsg.cdbanchq || '</cdbanchq>'
                || '<cdagechq>' || rw_crapcdb_rsg.cdagechq || '</cdagechq>'
                || '<nrctachq>' || CASE WHEN rw_crapcdb_rsg.cdbanchq = 1 THEN
                                      gene0002.fn_mask(rw_crapcdb_rsg.nrctachq,'zzzz.zzz-z')
                                 ELSE
                                      gene0002.fn_mask(rw_crapcdb_rsg.nrctachq,'zzzzzz.zzz-z')
                                 END                   || '</nrctachq>'

                || '<nrcheque>' || rw_crapcdb_rsg.nrcheque || '</nrcheque>'
                || '<nmcheque><![CDATA[' || nvl(rw_crapcdb_rsg.nmcheque,' ') || ']]></nmcheque>'
                || '<nrcpfcgc>' || CASE WHEN trim(rw_crapcdb_rsg.nrcpfcgc) IS NOT NULL THEN
                                      gene0002.fn_mask_cpf_cnpj(rw_crapcdb_rsg.nrcpfcgc
                                                               ,vr_inpessoa)
                                 END
                                                       || '</nrcpfcgc>'
                || '<vlcheque>' || to_char(rw_crapcdb_rsg.vlcheque, 'fm999g999g999g990d00') || '</vlcheque>'
                || '<dsdocmc7>' || regexp_replace(rw_crapcdb_rsg.dsdocmc7, '[^0-9]') || '</dsdocmc7>'
                      || '</Cheque>');
      END LOOP;

      pc_escreve_xml( '</Cheques></Dados></Root>',TRUE);

      pr_retxml := XMLTYPE.CREATEXML(vr_des_xml);

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_busca_cheques_dsc_cst: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


  END pc_busca_inf_bordero;

  PROCEDURE pc_busca_cheques_dsc_cst(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                    ,pr_nriniseq  IN INTEGER                --> Paginação - Inicio de sequencia
                                    ,pr_nrregist  IN INTEGER                --> Paginação - Número de registros
                                    ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                    ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_busca_cheques_dsc_cst
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar cheques em custodia para desconto

    Alteracoes: -----
  ..............................................................................*/

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis auxiliares
    vr_qtregist NUMBER;
    vr_inpessoa NUMBER;
    vr_stsnrcal BOOLEAN;

    --PlTable com dados dos cheques
    vr_tab_cstdsc DSCC0001.typ_tab_cstdsc;

    -- Variáveis XML
    vr_clob CLOB;

    -- Cursor da data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                                ,pr_action => NULL);

    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Busca cheques de custodia
    DSCC0001.pc_busca_cheques_dsc_cst(pr_cdcooper => vr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_nriniseq => pr_nriniseq
                                     ,pr_nrregist => pr_nrregist
                                     ,pr_qtregist => vr_qtregist
                                     ,pr_tab_cstdsc => vr_tab_cstdsc
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

    -- Se ocorreu algum erro
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;

    -- Se não houver nenhum cheque na PlTable
    IF vr_tab_cstdsc.count = 0 THEN
      -- Gerar crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Cheques não encontrados';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?>'
            || '<Root><Dados>';

    FOR idx IN vr_tab_cstdsc.first..vr_tab_cstdsc.last LOOP

      gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_tab_cstdsc(idx).nrcpfcgc
                                 ,pr_stsnrcal => vr_stsnrcal
                                 ,pr_inpessoa => vr_inpessoa);

      vr_clob := vr_clob
              || '<Cheque>'
              || '<dstipchq>' || vr_tab_cstdsc(idx).dstipchq                                 || '</dstipchq>'
              || '<dtmvtolt>' || to_char(vr_tab_cstdsc(idx).dtmvtolt,'DD/MM/RRRR')           || '</dtmvtolt>'
              || '<dtlibera>' || to_char(vr_tab_cstdsc(idx).dtlibera,'DD/MM/RRRR')           || '</dtlibera>'
              || '<cdcmpchq>' || vr_tab_cstdsc(idx).cdcmpchq                                 || '</cdcmpchq>'
              || '<cdbanchq>' || vr_tab_cstdsc(idx).cdbanchq                                 || '</cdbanchq>'
              || '<cdagechq>' || gene0002.fn_mask_contrato(vr_tab_cstdsc(idx).cdagechq)      || '</cdagechq>'
              || '<nrctachq>' || CASE WHEN vr_tab_cstdsc(idx).cdbanchq = 1 THEN
                                      gene0002.fn_mask(vr_tab_cstdsc(idx).nrctachq,'zzzz.zzz-z')
                                 ELSE
                                      gene0002.fn_mask(vr_tab_cstdsc(idx).nrctachq,'zzzzzz.zzz-z')
                                 END                                                         || '</nrctachq>'
              || '<nrcheque>' || gene0002.fn_mask_contrato(vr_tab_cstdsc(idx).nrcheque)      || '</nrcheque>'
              || '<vlcheque>' || to_char(vr_tab_cstdsc(idx).vlcheque,'fm999g999g999g990d00') || '</vlcheque>'
              || '<inconcil>' || CASE WHEN vr_tab_cstdsc(idx).inconcil = 1 THEN
                                      'Entregue'
                                 ELSE
                                      'Pendente de entrega'
                                 END                                                         || '</inconcil>'
              || '<nmcheque><![CDATA[' || vr_tab_cstdsc(idx).nmcheque                        || ']]></nmcheque>'
              || '<nrcpfcgc>' || CASE WHEN trim(vr_tab_cstdsc(idx).nrcpfcgc) IS NOT NULL THEN
                                      gene0002.fn_mask_cpf_cnpj(vr_tab_cstdsc(idx).nrcpfcgc
                                                               ,vr_inpessoa)
                                 END
                                                                                             || '</nrcpfcgc>'
              || '<dsdocmc7>' || regexp_replace(vr_tab_cstdsc(idx).dsdocmc7, '[^0-9]')       || '</dsdocmc7>'
              || '<dtdcaptu>' || to_char(vr_tab_cstdsc(idx).dtdcaptu,'DD/MM/RRRR')           || '</dtdcaptu>'
              || '<dtcustod>' || CASE WHEN trim(vr_tab_cstdsc(idx).dtcustod) IS NOT NULL THEN
                                      to_char(vr_tab_cstdsc(idx).dtcustod,'DD/MM/RRRR')
                                 END                                                         || '</dtcustod>'
              || '<nrremret>' || vr_tab_cstdsc(idx).nrremret                                 || '</nrremret>'
              || '</Cheque>';

    END LOOP;
    -- Fechar tag de dados do xml de retorno
    vr_clob := vr_clob || '</Dados><Qtregist>' || vr_qtregist || '</Qtregist></Root>';

    -- Envia retorno do XML
    pr_retxml := XMLType.createXML(vr_clob);

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_busca_cheques_dsc_cst: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');


  END pc_busca_cheques_dsc_cst;

  PROCEDURE pc_verifica_emitentes(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                                 ,pr_dscheque  IN VARCHAR2              --> Codigo do Indexador
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

  BEGIN
  /* .............................................................................
    Programa: pc_verifica_emitentes
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para verificar emitentes dos cheques informados para
                inclusão/alteração de borderô

    Alteracoes: -----
  ..............................................................................*/
    DECLARE

      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_exc_emiten EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      /* Vetor para armazenar as informac?es de erro */
      vr_xml_emitentes VARCHAR2(32726);

      /* Vetor para armazenar as informacoes dos cheques que estao sendo custodiados */
      vr_tab_cheques DSCC0001.typ_tab_cheques;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verificar emitentes
      DSCC0001.pc_verifica_emitentes(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dscheque => pr_dscheque
                                    ,pr_tab_cheques => vr_tab_cheques
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

      -- Se retornou erro
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Verificar se possui algum emitente não cadastrado
      IF vr_tab_cheques.count > 0 THEN
        vr_xml_emitentes := '';
        FOR vr_index_cheque IN 1..vr_tab_cheques.count LOOP
          -- Se exister algum cheque sem emitente
          IF vr_tab_cheques(vr_index_cheque).inemiten = 0 AND
               vr_tab_cheques(vr_index_cheque).cdbanchq <> 85 THEN
            -- Passar flag de falta de cadastro de emitente
            vr_xml_emitentes := vr_xml_emitentes ||
                                '<emitente'|| vr_index_cheque || '>' ||
                                '   <cdcmpchq>' || vr_tab_cheques(vr_index_cheque).cdcmpchq || '</cdcmpchq>' ||
                                '   <cdbanchq>' || vr_tab_cheques(vr_index_cheque).cdbanchq || '</cdbanchq>' ||
                                '   <cdagechq>' || vr_tab_cheques(vr_index_cheque).cdagechq || '</cdagechq>' ||
                                '   <nrctachq>' || vr_tab_cheques(vr_index_cheque).nrctachq || '</nrctachq>' ||
                                '</emitente'|| vr_index_cheque || '>';
          END IF;
        END LOOP;
        IF trim(vr_xml_emitentes) IS NOT NULL THEN
          RAISE vr_exc_emiten;
        END IF;
      END IF;

    EXCEPTION
      WHEN vr_exc_emiten THEN
        pr_cdcritic := 0;
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Emitentes>' || vr_xml_emitentes || '</Emitentes></Root>');
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_verifica_emitentes: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_verifica_emitentes;

  PROCEDURE pc_manter_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                             ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                             ,pr_nrdolote  IN crapbdc.nrdolote%TYPE  --> Lote
                             ,pr_cddopcao  IN VARCHAR2               --> Opção da tela
                             ,pr_dscheque  IN CLOB                   --> Cheques
                             ,pr_dscheque_exc IN CLOB                --> Cheques a serem excluidos do bordero
                             ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                             ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                             ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_manter_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para manter os borderos de desconto de cheque

    Alteracoes: 02/08/2017 - Ajuste na busca do campo nrcpfcgc do emitente quando popula
                             a tabela vr_tab_cheques  PRJ300 - Desconto de Cheques (Lombardi)
  ..............................................................................*/

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Informações do cheque
    vr_dsdocmc7 VARCHAR2(45);
    vr_cdbanchq NUMBER;
    vr_cdagechq NUMBER;
    vr_cdcmpchq NUMBER;
    vr_nrctachq NUMBER;
    vr_nrcheque NUMBER;
    vr_vlcheque NUMBER;
    vr_intipchq NUMBER;
    vr_dtlibera DATE;
    vr_dtcustod DATE;
    vr_dtdcaptu DATE;
    vr_nrremret NUMBER;
    vr_nrborder NUMBER := pr_nrborder;
    vr_nrdolote NUMBER := pr_nrdolote;
    vr_nrcpfcgc NUMBER;

    vr_tab_cheques dscc0001.typ_tab_cheques;
    vr_index_cheque NUMBER;
    vr_ret_cheques gene0002.typ_split;
    vr_ret_cheques_exc gene0002.typ_split;
    vr_ret_all_cheques gene0002.typ_split;
    vr_ret_all_cheques_exc gene0002.typ_split;

    --> Buscar cadastro do cooperado emitente
    CURSOR cr_crapass (pr_cdagectl IN crapcop.cdagectl%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE)IS
      SELECT ass.inpessoa
            ,ass.cdcooper
            ,ass.nrcpfcgc
        FROM crapass ass
            ,crapcop cop
       WHERE cop.cdagectl = pr_cdagectl
         AND ass.cdcooper = cop.cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass  cr_crapass%ROWTYPE;

    --> Buscar primeiro titular da conta
    CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ttl.nmtalttl
            ,ttl.nrcpfcgc
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;
    rw_crapttl  cr_crapttl%ROWTYPE;

    -- Busca informações do emitente
    CURSOR cr_crapcec (pr_cdcooper IN crapcec.cdcooper%TYPE
                      ,pr_cdcmpchq IN crapcec.cdcmpchq%TYPE
                      ,pr_cdbanchq IN crapcec.cdbanchq%TYPE
                      ,pr_cdagechq IN crapcec.cdagechq%TYPE
                      ,pr_nrctachq IN crapcec.nrctachq%TYPE) IS
      SELECT cec.nrcpfcgc
            ,cec.nmcheque
        FROM crapcec cec
       WHERE cec.cdcooper = pr_cdcooper
         AND cec.cdcmpchq = pr_cdcmpchq
         AND cec.cdbanchq = pr_cdbanchq
         AND cec.cdagechq = pr_cdagechq
         AND cec.nrctachq = pr_nrctachq
         AND cec.nrdconta = 0;
    rw_crapcec cr_crapcec%ROWTYPE;

    CURSOR cr_crapbdc (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
      SELECT 1
        FROM crapbdc
       WHERE cdcooper = pr_cdcooper
         AND nrborder = pr_nrborder
         AND crapbdc.dtrejeit IS NOT NULL;
    rw_crapbdc cr_crapbdc%ROWTYPE;


    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

  -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;


    -- Verifica se o bordero esta liberado
    OPEN cr_crapbdc(vr_cdcooper, vr_nrborder);
    FETCH cr_crapbdc INTO rw_crapbdc;

    IF cr_crapbdc%FOUND THEN
      CLOSE cr_crapbdc;
      vr_dscritic := 'Operação não permitida. Borderô reijeitado.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapbdc;

    IF trim(pr_dscheque_exc) IS NOT NULL AND pr_cddopcao = 'A' THEN
      -- Cria array com todos os registros de cheques
      vr_ret_all_cheques_exc := gene0002.fn_quebra_string(pr_dscheque_exc, '|');

      FOR vr_auxcont IN 1..vr_ret_all_cheques_exc.count LOOP
        -- Criando um array com todas as informações do cheque
        vr_ret_cheques_exc := gene0002.fn_quebra_string(vr_ret_all_cheques_exc(vr_auxcont), ';');

        -- Data de liberação
        vr_dtlibera := to_date(vr_ret_cheques_exc(1),'dd/mm/RRRR');

        -- Buscar o cmc7
        vr_dsdocmc7 := vr_ret_cheques_exc(2);

        -- Desmontar as informações do CMC-7
        -- Banco
        vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03));
        -- Agencia
        vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04));
        -- Compe
        vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
        -- Numero do Cheque
        vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
        -- Conta do Cheque
        IF vr_cdbanchq = 1 THEN
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));
        ELSE
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10));
        END IF;

        -- Carrega as informações do cheque para o bordero
        vr_index_cheque := vr_tab_cheques.count + 1;
        vr_tab_cheques(vr_index_cheque).cdcooper := vr_cdcooper;
        vr_tab_cheques(vr_index_cheque).nrdconta := pr_nrdconta;
        vr_tab_cheques(vr_index_cheque).dtlibera := vr_dtlibera;
        vr_tab_cheques(vr_index_cheque).dsdocmc7 := gene0002.fn_mask(vr_dsdocmc7,'<99999999<9999999999>999999999999:');
        vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
        vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
        vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
        vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
        vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;

      END LOOP;

      -- Remover cheques do bordero
      DSCC0001.pc_excluir_cheque_bordero(pr_cdcooper => vr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_cdagenci => vr_cdagenci
                                        ,pr_idorigem => vr_idorigem
                                        ,pr_cdoperad => vr_cdoperad
                                        ,pr_nrborder => pr_nrborder
                                        ,pr_tab_cheques => vr_tab_cheques
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic);
      -- Se houve críticas
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

    -- Limpar PlTable
    vr_tab_cheques.DELETE();

    IF trim(pr_dscheque) IS NOT NULL THEN
      -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');

      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP
        -- Criando um array com todas as informações do cheque
        vr_ret_cheques := gene0002.fn_quebra_string(vr_ret_all_cheques(vr_auxcont), ';');
        -- Data de liberação
        vr_dtlibera := to_date(vr_ret_cheques(1),'dd/mm/RRRR');
        -- Data de emissão
        vr_dtdcaptu := to_date(vr_ret_cheques(2),'dd/mm/RRRR');
        IF TRIM(vr_ret_cheques(3)) IS NOT NULL THEN
          -- Data da custódia
          vr_dtcustod := to_date(vr_ret_cheques(3),'dd/mm/RRRR');
        ELSE
          vr_dtcustod := NULL;
        END IF;
        -- Tipo de cheque (1 - Novo, 2 - Selecionado)
        vr_intipchq := to_number(vr_ret_cheques(4));
        -- Valor do cheque
        vr_vlcheque := to_number(vr_ret_cheques(5));
        -- Buscar o cmc7
        vr_dsdocmc7 := vr_ret_cheques(6);
        -- Nr. da remessa
        vr_nrremret := vr_ret_cheques(7);

        -- Desmontar as informações do CMC-7
        -- Banco
        vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03));
        -- Agencia
        vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04));
        -- Compe
        vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
        -- Numero do Cheque
        vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
        -- Conta do Cheque
        IF vr_cdbanchq = 1 THEN
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));
        ELSE
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10));
        END IF;

        IF vr_cdbanchq = 85 THEN

          -- Buscar cadastro do cooperado emitente
          OPEN cr_crapass (pr_cdagectl => vr_cdagechq
                          ,pr_nrdconta => vr_nrctachq);
          FETCH cr_crapass INTO rw_crapass;

          -- Se encontrar
          IF cr_crapass%FOUND THEN

            -- Fechar cursor
            CLOSE cr_crapass;
            -- Pessoa Física
            IF rw_crapass.inpessoa = 1 THEN

              OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                              ,pr_nrdconta => vr_nrctachq);
              FETCH cr_crapttl INTO rw_crapttl;
              -- Se encontrar
              IF cr_crapttl%FOUND THEN
              -- Fechar cursor
              CLOSE cr_crapttl;
                vr_nrcpfcgc := rw_crapttl.nrcpfcgc;
              ELSE
                -- Fechar cursor
                CLOSE cr_crapttl;
                -- Atribui crítica
                vr_cdcritic := 0;
                vr_dscritic := 'Emitente não cadastrado';
                -- Levantar exceção
                RAISE vr_exc_erro;
              END IF;

            ELSE -- Pessoa Juridica

              vr_nrcpfcgc := rw_crapass.nrcpfcgc;

            END IF;

          ELSE
            -- Fechar cursor
            CLOSE cr_crapass;
            -- Atribui crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Emitente não cadastrado';
            -- Levantar exceção
            RAISE vr_exc_erro;
          END IF;
        ELSE

        -- Verificar se possui emitente cadastrado
        OPEN cr_crapcec(pr_cdcooper => vr_cdcooper
                       ,pr_cdcmpchq => vr_cdcmpchq
                       ,pr_cdbanchq => vr_cdbanchq
                       ,pr_cdagechq => vr_cdagechq
                       ,pr_nrctachq => vr_nrctachq);
        FETCH cr_crapcec INTO rw_crapcec;
                  -- Se encontrou emitente
                  IF cr_crapcec%FOUND THEN
            -- Fechar cursor
            CLOSE cr_crapcec;
                    vr_nrcpfcgc := rw_crapcec.nrcpfcgc;
                  ELSE
            -- Fechar cursor
            CLOSE cr_crapcec;
          -- Atribui crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Emitente não cadastrado';
          -- Levantar exceção
          RAISE vr_exc_erro;
          END IF;

        END IF;

        -- Carrega as informações do cheque para o bordero
        vr_index_cheque := vr_tab_cheques.count + 1;
        vr_tab_cheques(vr_index_cheque).cdcooper := vr_cdcooper;
        vr_tab_cheques(vr_index_cheque).nrdconta := pr_nrdconta;
        vr_tab_cheques(vr_index_cheque).cdagenci := vr_cdagenci;
        vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_crapdat.dtmvtolt;
        vr_tab_cheques(vr_index_cheque).dtcustod := vr_dtcustod;
        vr_tab_cheques(vr_index_cheque).dtlibera := vr_dtlibera;
        vr_tab_cheques(vr_index_cheque).dtdcaptu := vr_dtdcaptu;
        vr_tab_cheques(vr_index_cheque).intipchq := vr_intipchq;
        vr_tab_cheques(vr_index_cheque).vlcheque := vr_vlcheque;
        vr_tab_cheques(vr_index_cheque).dsdocmc7 := vr_dsdocmc7;
        vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
        vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
        vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
        vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
        vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;
                vr_tab_cheques(vr_index_cheque).nrcpfcgc := vr_nrcpfcgc;
        vr_tab_cheques(vr_index_cheque).nrremret := vr_nrremret;

      END LOOP;

      IF pr_cddopcao = 'I' THEN
        -- Cria bordero
        dscc0001.pc_criar_bordero_cheques(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdagenci => vr_cdagenci
                                         ,pr_idorigem => vr_idorigem
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_nrborder => vr_nrborder
                                         ,pr_nrdolote => vr_nrdolote
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
        -- Se houve críticas
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Adicionar cheques ao bordero
      DSCC0001.pc_adicionar_cheques_bordero(pr_cdcooper => vr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdagenci => vr_cdagenci
                                           ,pr_idorigem => vr_idorigem
                                           ,pr_cdoperad => vr_cdoperad
                                           ,pr_nrborder => vr_nrborder
                                           ,pr_nrdolote => vr_nrdolote
                                           ,pr_tab_cheques => vr_tab_cheques
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      -- Se houve críticas
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;
    -- Efetuar commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_manter_bordero: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_manter_bordero;

  PROCEDURE pc_aprovar_reprovar_chq(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                   ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                   ,pr_dscheque  IN CLOB                   --> Cheques
                                   ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                   ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                   ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_aprovar_reprovar_chq
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para aprovar/reprovar os cheques do borderô

    Alteracoes: -----
  ..............................................................................*/

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Informações do cheque
    vr_dsdocmc7 VARCHAR2(45);
    vr_cdbanchq NUMBER;
    vr_cdagechq NUMBER;
    vr_cdcmpchq NUMBER;
    vr_nrctachq NUMBER;
    vr_nrcheque NUMBER;
    vr_flgaprov NUMBER;

    vr_tab_cheques dscc0001.typ_tab_cheques;
    vr_index_cheque NUMBER;
    vr_ret_cheques gene0002.typ_split;
    vr_ret_all_cheques gene0002.typ_split;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Buscar informações do cheque no borderô
    CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE
                     ,pr_nrdconta IN crapcdb.nrdconta%TYPE
                     ,pr_nrborder IN crapcdb.nrborder%TYPE
                     ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
                     ,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
                     ,pr_cdagechq IN crapcdb.cdagechq%TYPE
                     ,pr_nrctachq IN crapcdb.nrctachq%TYPE
                     ,pr_nrcheque IN crapcdb.nrcheque%TYPE) IS
      SELECT cdb.vlcheque
            ,cdb.dtlibera
            ,cdb.dtemissa
            ,cdb.dtmvtolt
            ,cdb.nrremret
            ,cdb.nrcpfcgc
       FROM crapcdb cdb
      WHERE cdb.cdcooper = pr_cdcooper
        AND cdb.nrdconta = pr_nrdconta
        AND cdb.nrborder = pr_nrborder
        AND cdb.cdcmpchq = pr_cdcmpchq
        AND cdb.cdbanchq = pr_cdbanchq
        AND cdb.cdagechq = pr_cdagechq
        AND cdb.nrctachq = pr_nrctachq
        AND cdb.nrcheque = pr_nrcheque;
    rw_crapcdb cr_crapcdb%ROWTYPE;

  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    IF trim(pr_dscheque) IS NOT NULL THEN
      -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');

      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP
        -- Criando um array com todas as informações do cheque
        vr_ret_cheques := gene0002.fn_quebra_string(vr_ret_all_cheques(vr_auxcont), ';');
        -- CMC77
        vr_dsdocmc7 := vr_ret_cheques(1);
        -- Flag aprovação/reprovação cheque
        vr_flgaprov := vr_ret_cheques(2);

        -- Desmontar as informações do CMC-7
        -- Banco
        vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03));
        -- Agencia
        vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04));
        -- Compe
        vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
        -- Numero do Cheque
        vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
        -- Conta do Cheque
        IF vr_cdbanchq = 1 THEN
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));
        ELSE
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10));
        END IF;
        -- Buscar informações do cheque no borderô
        OPEN cr_crapcdb(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrborder => pr_nrborder
                       ,pr_cdcmpchq => vr_cdcmpchq
                       ,pr_cdbanchq => vr_cdbanchq
                       ,pr_cdagechq => vr_cdagechq
                       ,pr_nrctachq => vr_nrctachq
                       ,pr_nrcheque => vr_nrcheque);
        FETCH cr_crapcdb INTO rw_crapcdb;

        -- Se não encontrou
        IF cr_crapcdb%NOTFOUND THEN
          -- Fechar cursor
          CLOSE cr_crapcdb;
          -- Gerar crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Cheque não encontrado no borderô.';
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
        -- Fechar cursor
        CLOSE cr_crapcdb;

        -- Carrega as informações do cheque para o bordero
        vr_index_cheque := vr_tab_cheques.count + 1;
        vr_tab_cheques(vr_index_cheque).cdcooper := vr_cdcooper;
        vr_tab_cheques(vr_index_cheque).nrdconta := pr_nrdconta;
        vr_tab_cheques(vr_index_cheque).cdagenci := vr_cdagenci;
        vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_crapcdb.dtmvtolt;
        vr_tab_cheques(vr_index_cheque).dtlibera := rw_crapcdb.dtlibera;
        vr_tab_cheques(vr_index_cheque).dtdcaptu := rw_crapcdb.dtemissa;
        vr_tab_cheques(vr_index_cheque).vlcheque := rw_crapcdb.vlcheque;
        vr_tab_cheques(vr_index_cheque).dsdocmc7 := vr_dsdocmc7;
        vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
        vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
        vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
        vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
        vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;
        vr_tab_cheques(vr_index_cheque).nrremret := rw_crapcdb.nrremret;
        vr_tab_cheques(vr_index_cheque).flgaprov := vr_flgaprov;
        vr_tab_cheques(vr_index_cheque).nrcpfcgc := rw_crapcdb.nrcpfcgc;

      END LOOP;

      -- Chamar rotina para aprovar/reprovar o cheque
      DSCC0001.pc_aprovar_reprovar_chq(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_cdagenci => vr_cdagenci
                                      ,pr_idorigem => vr_idorigem
                                      ,pr_cdoperad => vr_cdoperad
                                      ,pr_nrborder => pr_nrborder
                                      ,pr_tab_cheques => vr_tab_cheques
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
      -- Se retornou alguma crítica
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levantar execeção
        RAISE vr_exc_erro;
      END IF;

    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_aprovar_reprovar_chq: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_aprovar_reprovar_chq;

  PROCEDURE pc_efetiva_desconto_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                       ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                       ,pr_cdopcolb  IN crapbdc.cdopcolb%TYPE  --> Operador Liberação
                                       ,pr_flresghj  IN INTEGER DEFAULT 0      --> Flag para resgatar cheques custodiados hoje
                                       ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                       ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                       ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                       ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                       ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_efetiva_desconto_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao: 15/05/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para liberar (ou efetivar) a operação de desconto de cheques.
                Este procedimento realiza a finalização da operação de desconto de
                cheque, onde é creditado o valor líquido da operação na conta do
                cooperado, como também os encargos (IOF e tarifa (se houver)).

    Alteracoes: 02/06/2017 - Ajustes para resgatar cheques custodiados no dia de hoje
                             que não foram aprovados.
                             PRJ300 - Desconto de cheque(Odirlei-AMcom)

                20/08/2018 - Ajuste na performace para liberar borderôs (Andrey Formigari - Mouts)

                10/05/2019 - Retirada de parametro do tipo XML
                             Ajuste na atualização do campo nrcpfcnpj_base na tabela TBRISCO_OPERACOES (Mário - AMcom)

                15/05/2019 - Ajuste Atualizacao Rating (Mario - AMcom)

                17/05/2019 - P450 - Gravar o rating da proposta no borderô (Heckmann - AMcom)


  ..............................................................................*/

    -- Verifica Cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT nmrescop
         FROM crapcop
        WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Verifica Conta
    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT dtelimin
            ,cdsitdtl
            ,cdagenci
           ,nrcpfcnpj_base
       FROM crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Informações de data do sistema
    rw_crapdat  btch0001.rw_crapdat%TYPE;

    -- Buscar informações do borderô
    CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
                     ,pr_nrdconta IN crapbdc.nrdconta%TYPE
                     ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
        SELECT bdc.NRCTRLIM
            FROM crapbdc bdc
         WHERE bdc.cdcooper = pr_cdcooper
           AND bdc.nrdconta = pr_nrdconta
           AND bdc.nrborder = pr_nrborder;
    rw_crapbdc cr_crapbdc%ROWTYPE;

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_dsdmensg VARCHAR2(300);
    vr_rowid_log ROWID;
    vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 8;
    vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 1;
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;

    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT nmrescop
        FROM crapcop
        WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Variaveis auxiliares
    vr_flgfound     BOOLEAN;
    vr_vlendivid    craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
    vr_vllimrating  craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056
    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)


  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => vr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');
    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (vr_cdcooper <> 3 OR vr_habrat = 'S') THEN
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Verifica se existe a conta
      OPEN cr_crapass (vr_cdcooper, pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      vr_flgfound := cr_crapass%FOUND;
      CLOSE cr_crapass;
      -- Se nao existir
      IF NOT vr_flgfound THEN
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      END IF;
    END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

    IF pr_flresghj = 1 THEN
      --> Resgatar cheques custodiados no dia de movimento
      DSCC0001.pc_resgata_cheques_cust_hj
                                (pr_cdcooper => vr_cdcooper  --> Cooperativa
                                ,pr_cdagenci => vr_cdagenci  --> Agencia
                                ,pr_nrdconta => pr_nrdconta  --> Nr. da Conta
                                ,pr_nrborder => pr_nrborder  --> Nr. Borderô
                                ,pr_cdoperad => vr_cdoperad  --> Cód. operador
                                ,pr_flreprov => 1            --> Resgatar apenas os reprovados
                                ,pr_cdcritic => vr_cdcritic  --> Crítica
                                ,pr_dscritic => vr_dscritic);  --> Desc. da crítica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Efetivar desconto do bordero
    DSCC0001.pc_efetiva_desconto_bordero(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrborder => pr_nrborder
                      ,pr_cdoperad => vr_cdoperad
                      ,pr_cdagenci => vr_cdagenci
                      ,pr_cdopcolb => pr_cdopcolb
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    OPEN cr_crapcop(vr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    END IF;

    vr_dsdmensg := 'Seu borderô de desconto de cheque nº ' || pr_nrborder ||
                   ' foi liberado.' || '\n' ||
                   ' Em caso de dúvidas, favor dirigir-se ao seu PA de relacionamento.';

    -- Insere na tabela de mensagens (CRAPMSG)
    GENE0003.pc_gerar_mensagem(pr_cdcooper => vr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_idseqttl => 0 /* Titular */
                  ,pr_cdprogra => 'DESCTO' /* Programa */
                  ,pr_inpriori => 0
                  ,pr_dsdmensg => vr_dsdmensg /* corpo da mensagem */
                  ,pr_dsdassun => 'Borderô de Desconto de Cheque Liberado' /* Assunto */
                  ,pr_dsdremet => rw_crapcop.nmrescop
                  ,pr_dsdplchv => 'Desconto de Cheque'
                  ,pr_cdoperad => vr_cdoperad
                  ,pr_cdcadmsg => 0
                  ,pr_dscritic => vr_dscritic);

    -- Se ocorrer erro
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
      RAISE vr_exc_erro;
    END IF;
    --
    vr_variaveis_notif('#numbordero') := to_char(pr_nrborder);

    -- Cria uma notificação
    noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                  ,pr_cdmotivo_mensagem => vr_notif_motivo
                  ,pr_cdcooper => vr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_variaveis => vr_variaveis_notif);

    -- P450 SPT13 - alteracao para habilitar rating novo
    IF (vr_cdcooper <> 3 OR vr_habrat = 'S') THEN
      -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
      RATI0003.pc_busca_endivid_param(pr_cdcooper => vr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_vlendivi => vr_vlendivid
                                     ,pr_vlrating => vr_vllimrating
                                     ,pr_dscritic => vr_dscritic);
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;

      -- Se Endividamento + Contrato atual > Parametro Rating (TAB056
      IF (vr_vlendivid > vr_vllimrating)  THEN

        -- Busca informações do bordero
        OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrborder => pr_nrborder);
        FETCH cr_crapbdc INTO rw_crapbdc;

        -- Se não encontrou
        IF cr_crapbdc%NOTFOUND THEN
            -- Fechar cursor
            CLOSE cr_crapbdc;
            -- Gerar crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Borderô não encontrado.';
            -- Levantar exceção
            RAISE vr_exc_erro;
        END IF;
        -- Fechar cursor
        CLOSE cr_crapbdc;

        -- Gravar o Rating da operação, efetivando-o
        rati0003.pc_grava_rating_operacao(pr_cdcooper          => vr_cdcooper
                                         ,pr_nrdconta          => pr_nrdconta
                                         ,pr_tpctrato          => 2
                                         ,pr_nrctrato          => rw_crapbdc.nrctrlim
                                         ,pr_dtrating          => rw_crapdat.dtmvtolt
                                         ,pr_dtrataut          => rw_crapdat.dtmvtolt
                                         ,pr_strating          => 4
                                         ,pr_efetivacao_rating => 1 -- Identificar se deve considerar o parâmetro de contingência
                                         --Variáveis para gravar o histórico
                                         ,pr_cdoperad          => vr_cdoperad
                                         ,pr_dtmvtolt          => rw_crapdat.dtmvtolt
                                         ,pr_valor             => NULL  --pr_vllimite
                                         ,pr_rating_sugerido   => NULL
                                         ,pr_justificativa     => 'Efetivação do rating'
                                         ,pr_tpoperacao_rating => 2
                                         ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
                                         --Variáveis de crítica
                                         ,pr_cdcritic          => vr_cdcritic
                                         ,pr_dscritic          => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

      rati0003.pc_grava_rating_bordero(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctro   => rw_crapbdc.nrctrlim
                                      ,pr_tpctrato => 2
                                      ,pr_nrborder => pr_nrborder
                                      ,pr_cdoperad => vr_cdoperad
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Efetua os inserts para apresentacao na tela VERLOG
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
              ,pr_cdoperad => vr_cdoperad
              ,pr_dscritic => ' '
              ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
              ,pr_dstransa => 'Liberado desconto do bordero Nro.: ' || pr_nrborder || '.'
              ,pr_dttransa => trunc(SYSDATE)
              ,pr_flgtrans => 1
              ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
              ,pr_idseqttl => 1
              ,pr_nmdatela => 'ATENDA_DESCT'
              ,pr_nrdconta => pr_nrdconta
              ,pr_nrdrowid => vr_rowid_log);


    -- Efetuar commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_efetiva_desconto_bordero: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_efetiva_desconto_bordero;

  PROCEDURE pc_verifica_assinatura_bordero(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                          ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                          ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                          ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                          ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                          ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                          ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                          ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_verifica_assinatura_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Verificar se o bordero necessita de assinatura para liberação.

    Alteracoes: -----
  ..............................................................................*/

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    vr_dsxml    VARCHAR2(20000);
    vr_flgassin INTEGER := 0;
    vr_flcusthj INTEGER := 0;

    -- Buscar borderô de desconto
    CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
                     ,pr_nrdconta IN crapbdc.nrdconta%TYPE
                     ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
      SELECT bdc.insitbdc
            ,bdc.flgassin
            ,bdc.dhdassin
            ,bdc.cdopeasi
        FROM crapbdc bdc
       WHERE bdc.cdcooper = pr_cdcooper
         AND bdc.nrdconta = pr_nrdconta
         AND bdc.nrborder = pr_nrborder;
    rw_crapbdc cr_crapbdc%ROWTYPE;

    -- Buscar cheques custodiados na data de hoje
    CURSOR cr_crapcdb(pr_cdcooper IN crapbdc.cdcooper%TYPE
                     ,pr_nrdconta IN crapbdc.nrdconta%TYPE
                     ,pr_nrborder IN crapbdc.nrborder%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT 1
        FROM crapcdb cdb,
             crapcst cst
       WHERE cdb.cdcooper = pr_cdcooper
         AND cdb.nrdconta = pr_nrdconta
         AND cdb.nrborder = pr_nrborder
         AND cst.cdcooper = cdb.cdcooper
         AND cst.nrdconta = cdb.nrdconta
         AND cst.nrborder = cdb.nrborder
         AND cst.cdcmpchq = cdb.cdcmpchq
         AND cst.cdbanchq = cdb.cdbanchq
         AND cst.cdagechq = cdb.cdagechq
         AND cst.nrcheque = cdb.nrcheque
         AND cst.nrctachq = cdb.nrctachq
         AND cdb.insitana = 2            --> apenas cheques nao aprovados
         AND cst.dtmvtolt = pr_dtmvtolt;


  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Buscar borderô de desconto
    OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrborder => pr_nrborder);
    FETCH cr_crapbdc INTO rw_crapbdc;

    -- Se não encontrou borderô
    IF cr_crapbdc%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_crapbdc;
      -- Gerar crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Borderô de desconto de cheque não encontrado.';
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;

    -- Se borderô já foi liberado
    IF rw_crapbdc.insitbdc > 2 THEN
      -- Gerar crítica
      vr_cdcritic := 0;
      vr_dscritic := 'Borderô já foi liberado.';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;

    vr_dsxml := '<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>';

    -- Se borderô precisa de assinatura
    vr_flgassin := 0;
    IF rw_crapbdc.flgassin = 1 THEN
      IF trim(rw_crapbdc.dhdassin) IS NULL AND trim(rw_crapbdc.cdopeasi) IS NULL THEN
        vr_flgassin := 1;
      END IF;
    END IF;

    vr_dsxml := vr_dsxml || '<flgassin>'||vr_flgassin||'</flgassin>';

    -- Buscar cheques custodiados na data de hoje
    vr_flcusthj := 0;
    OPEN cr_crapcdb ( pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrborder => pr_nrborder
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    FETCH cr_crapcdb INTO vr_flcusthj;
    CLOSE cr_crapcdb;

    vr_dsxml := vr_dsxml || '<flcusthj>'||vr_flcusthj||'</flcusthj>';
    vr_dsxml := vr_dsxml || '</Root>';
    pr_retxml := XMLTYPE.CREATEXML(vr_dsxml);


  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_verifica_assinatura_bordero: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_verifica_assinatura_bordero;

  PROCEDURE pc_efetuar_resgate(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                              ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                              ,pr_dscheque  IN CLOB                   --> Cheques
                              ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                              ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                              ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_efetuar_resgate
    Sistema : AyllosWeb
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : 06/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para efetuar resgate dos cheques do bordero

    Alteracoes:

  ............................................................................. */

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Informações do cheque
    vr_dsdocmc7 VARCHAR2(45);
    vr_cdbanchq NUMBER;
    vr_cdagechq NUMBER;
    vr_cdcmpchq NUMBER;
    vr_nrctachq NUMBER;
    vr_nrcheque NUMBER;
    vr_flgaprov NUMBER;

    vr_tab_cheques dscc0001.typ_tab_cheques;
    vr_index_cheque NUMBER;
    vr_ret_cheques gene0002.typ_split;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- Buscar informações do cheque no borderô
    CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE
                     ,pr_nrdconta IN crapcdb.nrdconta%TYPE
                     ,pr_nrborder IN crapcdb.nrborder%TYPE
                     ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
                     ,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
                     ,pr_cdagechq IN crapcdb.cdagechq%TYPE
                     ,pr_nrctachq IN crapcdb.nrctachq%TYPE
                     ,pr_nrcheque IN crapcdb.nrcheque%TYPE) IS
      SELECT cdb.vlcheque
            ,cdb.dtlibera
            ,cdb.dtemissa
            ,cdb.dtmvtolt
            ,cdb.nrremret
            ,cdb.insitchq
            ,cdb.nrddigc3
            ,cdb.inchqcop
            ,cdb.vlliquid
       FROM crapcdb cdb
      WHERE cdb.cdcooper = pr_cdcooper
        AND cdb.nrdconta = pr_nrdconta
        AND cdb.nrborder = pr_nrborder
        AND cdb.cdcmpchq = pr_cdcmpchq
        AND cdb.cdbanchq = pr_cdbanchq
        AND cdb.cdagechq = pr_cdagechq
        AND cdb.nrctachq = pr_nrctachq
        AND cdb.nrcheque = pr_nrcheque;
    rw_crapcdb cr_crapcdb%ROWTYPE;

  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    IF trim(pr_dscheque) IS NOT NULL THEN
      -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');

      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_cheques.count LOOP
        -- CMC77
        vr_dsdocmc7 := vr_ret_cheques(vr_auxcont);
        -- Desmontar as informações do CMC-7
        -- Banco
        vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03));
        -- Agencia
        vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04));
        -- Compe
        vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
        -- Numero do Cheque
        vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
        -- Conta do Cheque
        IF vr_cdbanchq = 1 THEN
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));
        ELSE
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10));
        END IF;
        -- Buscar informações do cheque no borderô
        OPEN cr_crapcdb(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrborder => pr_nrborder
                       ,pr_cdcmpchq => vr_cdcmpchq
                       ,pr_cdbanchq => vr_cdbanchq
                       ,pr_cdagechq => vr_cdagechq
                       ,pr_nrctachq => vr_nrctachq
                       ,pr_nrcheque => vr_nrcheque);
        FETCH cr_crapcdb INTO rw_crapcdb;

        -- Se não encontrou
        IF cr_crapcdb%NOTFOUND THEN
          -- Fechar cursor
          CLOSE cr_crapcdb;
          -- Gerar crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Cheque não encontrado no borderô.';
          -- Levantar exceção
          RAISE vr_exc_erro;
        END IF;
        -- Fechar cursor
        CLOSE cr_crapcdb;

        -- Carrega as informações do cheque para o bordero
        vr_index_cheque := vr_tab_cheques.count + 1;
        vr_tab_cheques(vr_index_cheque).cdcooper := vr_cdcooper;
        vr_tab_cheques(vr_index_cheque).nrdconta := pr_nrdconta;
        vr_tab_cheques(vr_index_cheque).cdagenci := vr_cdagenci;
        vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_crapcdb.dtmvtolt;
        vr_tab_cheques(vr_index_cheque).dtlibera := rw_crapcdb.dtlibera;
        vr_tab_cheques(vr_index_cheque).dtdcaptu := rw_crapcdb.dtemissa;
        vr_tab_cheques(vr_index_cheque).vlcheque := rw_crapcdb.vlcheque;
        vr_tab_cheques(vr_index_cheque).dsdocmc7 := gene0002.fn_mask(vr_dsdocmc7,'<99999999<9999999999>999999999999:');
        vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
        vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
        vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
        vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
        vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;
        vr_tab_cheques(vr_index_cheque).nrremret := rw_crapcdb.nrremret;
        vr_tab_cheques(vr_index_cheque).flgaprov := vr_flgaprov;
        vr_tab_cheques(vr_index_cheque).insitchq := rw_crapcdb.insitchq;
        vr_tab_cheques(vr_index_cheque).nrddigc3 := rw_crapcdb.nrddigc3;
        vr_tab_cheques(vr_index_cheque).inchqcop := rw_crapcdb.inchqcop;
        vr_tab_cheques(vr_index_cheque).vlliquid := rw_crapcdb.vlliquid;

      END LOOP;

      -- Chamar rotina para aprovar/reprovar o cheque
      DSCC0001.pc_resgata_cheques_bordero(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrborder => pr_nrborder
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_tab_cheques => vr_tab_cheques
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
      -- Se retornou alguma crítica
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levantar execeção
        RAISE vr_exc_erro;
      END IF;

    END IF;

    -- Efetuar commit
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_efetuar_resgate: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_efetuar_resgate;

  PROCEDURE pc_rejeitar_bordero(pr_nrdconta  IN crapcdb.nrdconta%TYPE  --> Conta
                               ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                               ,pr_flresghj  IN INTEGER DEFAULT 0      --> Flag para resgatar cheques custodiados hoje
                               ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                               ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                               ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_efetuar_resgate
    Sistema : AyllosWeb
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 23/03/2017                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para rejeitar bordero de desconto de cheques

    Alteracoes: 24/08/2017 - Ajuste para gravar log. (Lombardi)

  ............................................................................. */

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_rowid_log ROWID;

    CURSOR cr_crapbdc (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapbdc.nrdconta%TYPE
                      ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
      SELECT 1
        FROM crapbdc
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder
         AND crapbdc.dtlibbdc IS NOT NULL;
    rw_crapbdc cr_crapbdc%ROWTYPE;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Verifica se o bordero esta liberado
    OPEN cr_crapbdc(pr_cdcooper => vr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrborder => pr_nrborder);
    FETCH cr_crapbdc INTO rw_crapbdc;

    IF cr_crapbdc%FOUND THEN
      CLOSE cr_crapbdc;
      vr_dscritic := 'Borderô já liberado.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapbdc;

    IF pr_flresghj = 1 THEN
      --> Resgatar cheques custodiados no dia de movimento
      DSCC0001.pc_resgata_cheques_cust_hj
                                (pr_cdcooper => vr_cdcooper  --> Cooperativa
                                ,pr_cdagenci => vr_cdagenci  --> Agencia
                                ,pr_nrdconta => pr_nrdconta  --> Nr. da Conta
                                ,pr_nrborder => pr_nrborder  --> Nr. Borderô
                                ,pr_cdoperad => vr_cdoperad  --> Cód. operador
                                ,pr_flreprov => 0            --> Resgatar apenas os reprovados
                                ,pr_cdcritic => vr_cdcritic  --> Crítica
                                ,pr_dscritic => vr_dscritic);  --> Desc. da crítica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- Rejeita bordero
    BEGIN
      UPDATE crapbdc
         SET dtrejeit = rw_crapdat.dtmvtolt
            ,cdoperej = vr_cdoperad
       WHERE cdcooper = vr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder;

      UPDATE crapcdb
         SET insitana = 2
            ,cdopeana = vr_cdoperad
            ,dtsitana = rw_crapdat.dtmvtolt
       WHERE cdcooper = vr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder;
      -- Tira vinculo com a dcc e cst
      UPDATE crapdcc
         SET nrborder = 0
       WHERE cdcooper = vr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder;

      UPDATE crapcst
         SET nrborder = 0
       WHERE cdcooper = vr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder;
    END;

    -- Efetua os inserts para apresentacao na tela VERLOG
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Rejeicao do bordero de cheques Nro.: ' || pr_nrborder
                        ,pr_dttransa => trunc(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowid_log);

    -- Efetuar commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_efetuar_resgate: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_rejeitar_bordero;

  PROCEDURE pc_valida_valor_saldo(pr_nrdconta  IN crapcdb.nrdconta%TYPE  --> Numero da conta
                                 ,pr_vlverifi  IN NUMBER                 --> Valor para verificar
                                 ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_valida_valor_saldo
    Sistema : AyllosWeb
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 23/03/2017                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para rejeitar bordero de desconto de cheques

    Alteracoes:

  ............................................................................. */

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    vr_des_reto  VARCHAR2(10000);
    vr_tab_sald  EXTR0001.typ_tab_saldos;
    vr_tab_erro  GENE0001.typ_tab_erro;

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis auxiliares
    vr_index_saldo    PLS_INTEGER;
    vr_coordenador    BOOLEAN;

    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  BEGIN
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    --Selecionar Associado
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;

    EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => vr_cdcooper
                               ,pr_rw_crapdat => rw_crapdat
                               ,pr_cdagenci   => vr_cdagenci
                               ,pr_nrdcaixa   => vr_nrdcaixa
                               ,pr_cdoperad   => vr_cdoperad
                               ,pr_nrdconta   => pr_nrdconta
                               ,pr_vllimcre   => rw_crapass.vllimcre
                               ,pr_dtrefere   => rw_crapdat.dtmvtolt
                               ,pr_flgcrass   => (rw_crapdat.inproces <> 1)
                               ,pr_des_reto   => vr_des_reto
                               ,pr_tab_sald   => vr_tab_sald
                               ,pr_tab_erro   => vr_tab_erro);

    -- Verifica se deu erro
    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_dscritic := 'Não foi possivel verificar Saldo.';
      END IF;

      RAISE vr_exc_erro;
    END IF;

    vr_coordenador := TRUE;

    --Buscar Indice
    vr_index_saldo := vr_tab_sald.FIRST;
    IF vr_index_saldo IS NOT NULL THEN
       vr_coordenador := ((nvl(vr_tab_sald(vr_index_saldo).vlsddisp, 0) +
                           nvl(vr_tab_sald(vr_index_saldo).vllimcre, 0)) < pr_vlverifi);
    ELSE
      vr_dscritic := 'Não foi possivel verificar Saldo.';
    END IF;

    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' ||
                                   '<Root><coordenador>' ||
                                            (CASE vr_coordenador
                                             WHEN TRUE THEN 1 ELSE 0 END) ||
                                         '</coordenador></Root>');

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_valida_valor_saldo: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_valida_valor_saldo;

  --> Resgatar cheques custodiados no dia de movimento
  PROCEDURE pc_busca_cheques_cust_hj(pr_nrdconta  IN craplim.nrdconta%TYPE  --> Conta
                                    ,pr_nrborder  IN crapcdb.nrborder%TYPE  --> Bordero
                                    ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                    ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_busca_cheques_cust_hj
    Sistema : CECRED
    Autor   : Mateus Zimmermann - Mouts
    Data    : Janeiro/2018                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Resgatar cheques custodiados no dia de movimento

    Alteracoes:

  ..............................................................................*/
  -- Variável de críticas
  vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
  -- Tratamento de erros
  vr_exc_erro        EXCEPTION;

  -- Variáveis auxiliares
  vr_dstextab craptab.dstextab%TYPE;
  vr_qtdiasut INTEGER;
  vr_qtdiasli INTEGER;
  vr_hrlimite INTEGER;
  vr_nrdocmto NUMBER;
  vr_dtjurtab DATE;
  vr_tab_resgate_erro cust0001.typ_erro_resgate;

  -- Variaveis de log
  vr_cdcooper INTEGER;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);

  vr_dscheque VARCHAR(200);
  vr_dsdocmc7 VARCHAR(1000);

  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  vr_tab_cheques dscc0001.typ_tab_cheques;
  vr_index_cheque NUMBER;
  vr_flgaprov NUMBER;

  -- Buscar cheques custodiados na data de hoje
  CURSOR cr_crapcdb(pr_cdcooper IN crapbdc.cdcooper%TYPE
                   ,pr_nrdconta IN crapbdc.nrdconta%TYPE
                   ,pr_nrborder IN crapbdc.nrborder%TYPE
                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT cdb.vlcheque,
           cdb.dsdocmc7,
           cdb.nrcheque
      FROM crapcdb cdb,
           crapcst cst
     WHERE cdb.cdcooper = pr_cdcooper
       AND cdb.nrdconta = pr_nrdconta
       AND cdb.nrborder = pr_nrborder
       AND cst.cdcooper = cdb.cdcooper
       AND cst.nrdconta = cdb.nrdconta
       AND cst.nrborder = cdb.nrborder
       AND cst.cdcmpchq = cdb.cdcmpchq
       AND cst.cdbanchq = cdb.cdbanchq
       AND cst.cdagechq = cdb.cdagechq
       AND cst.nrcheque = cdb.nrcheque
       AND cst.nrctachq = cdb.nrctachq
       --> Cheques ainda nao resgatados
       AND cst.dtdevolu IS NULL
       AND cst.insitchq = 0
       AND cdb.insitana = 2
       AND cst.dtmvtolt = pr_dtmvtolt;

    -- Verificar se cheque foi resgatado na data de hoje
    CURSOR cr_crapcst_resg_hoje (pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_dsdocmc7 IN VARCHAR2
                                ,pr_dtmvtolt IN DATE) IS
      SELECT cst.vlcheque
            ,cst.dtlibera
            ,cst.insitchq
        FROM crapcst cst
       WHERE cst.cdcooper = pr_cdcooper
         AND UPPER(cst.dsdocmc7) = UPPER(pr_dsdocmc7)
         AND cst.dtdevolu = pr_dtmvtolt;
    rw_crapcst_resg_hoje cr_crapcst_resg_hoje%ROWTYPE;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    --> Buscar cheques do bosrdero custodiados do dia atual
    FOR rw_crapcdb IN cr_crapcdb (pr_cdcooper => vr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

      -- Verificar se cheque foi resgatado hoje
      OPEN cr_crapcst_resg_hoje(pr_cdcooper => vr_cdcooper
                               ,pr_dsdocmc7 => rw_crapcdb.dsdocmc7
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
      FETCH cr_crapcst_resg_hoje INTO rw_crapcst_resg_hoje;

      IF cr_crapcst_resg_hoje%FOUND THEN
        -- Gera crítica
        vr_cdcritic := 673;
        -- Fecha Cursor
        CLOSE cr_crapcst_resg_hoje;
        -- Levantar exceção
        RAISE vr_exc_erro;
      ELSE
        -- Fecha Cursor
        CLOSE cr_crapcst_resg_hoje;
      END IF;

      -- Se retornou alguma crítica
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levantar exceção
        RAISE vr_exc_erro;
      END IF;

      IF vr_dscheque IS NOT NULL THEN
         vr_dscheque := vr_dscheque || '|';
      END IF;

      vr_dscheque := vr_dscheque || rw_crapcdb.nrcheque;
      vr_dscheque := vr_dscheque || ';' || rw_crapcdb.vlcheque;
      vr_dscheque := vr_dscheque || ';' || rw_crapcdb.dsdocmc7;

      IF vr_dsdocmc7 IS NOT NULL THEN
         vr_dsdocmc7 := vr_dsdocmc7 || '|';
      END IF;

      vr_dsdocmc7 := vr_dsdocmc7 || rw_crapcdb.dsdocmc7;

    END LOOP;


    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'Dados',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dscheque',pr_tag_cont => vr_dscheque,pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dsdocmc7',pr_tag_cont => vr_dsdocmc7,pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF NVL(vr_cdcritic,0) <> 0 AND
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := REPLACE(REPLACE(vr_dscritic,chr(13)),chr(10));
      END IF;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel buscar os cheques custodiados no dia de hoje: ' || SQLERRM, chr(13)),chr(10));
  END pc_busca_cheques_cust_hj;

END TELA_ATENDA_DESCTO;
/
