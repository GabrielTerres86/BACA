CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_CARTAOCREDITO IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_CARTAO_CREDITO
  --  Sistema  : Ayllos Web
  --  Autor    : 
  --  Data     :                  Ultima atualizacao: 06/04/2018
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas à tela de Cartão de Crédito
  --
  -- Alteracoes: 06/04/2018  Paulo Silva - Supero
  --             Inclusão das rotinas pc_busca_sugestao_motor, pc_valida_operador_alt_limite, pc_valida_operador_entrega e pc_busca_desc_administadora.
  --
  ---------------------------------------------------------------------------
  
  PROCEDURE pc_busca_hist_limite_crd(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                    ,pr_nrdconta  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Conta
                                    ,pr_nrcctitg  IN tbcrd_limite_atualiza.nrconta_cartao%TYPE --> Cartão
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);         --> Erros do processo
                                    
  --> Retornar uma lista com as sugestões do motor para cartão de crédito
  PROCEDURE pc_busca_sugestao_motor(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                   
  --> Retornar uma lista com as sugestões do motor para cartão de crédito
  PROCEDURE pc_valida_operador_alt_limite(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);
                                         
  --> Validar se o operador que solicitou o cartão é o mesmo que está entregando
  PROCEDURE pc_valida_operador_entrega(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                      ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Nr. do Cartão
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);
                                      
  --> Retornar nome da administradora
  PROCEDURE pc_busca_desc_administadora(pr_cdadmcrd IN crapadc.cdadmcrd%TYPE --> Nr. da Conta
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);
                                       
  --> Retornar Situação Decisão Esteira
  PROCEDURE pc_busca_situacao_decisao(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);
                                     
  --> Busca Assinatura Representantes/Procuradores
  PROCEDURE pc_busca_ass_repres_proc(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  --> Insere Aprovadores de Cartões
  PROCEDURE pc_insere_aprovador_crd( pr_cdcooper      IN tbcrd_aprovacao_cartao.cdcooper%TYPE
                                    ,pr_nrdconta      IN tbcrd_aprovacao_cartao.nrdconta%TYPE
                                    ,pr_nrctrcrd      IN tbcrd_aprovacao_cartao.nrctrcrd%TYPE
                                    ,pr_indtipo_senha IN tbcrd_aprovacao_cartao.indtipo_senha%TYPE
                                    ,pr_dtaprovacao   IN VARCHAR2
                                    ,pr_hraprovacao   IN tbcrd_aprovacao_cartao.hraprovacao%TYPE
                                    ,pr_nrcpf         IN tbcrd_aprovacao_cartao.nrcpf%TYPE
                                    ,pr_nmaprovador   IN tbcrd_aprovacao_cartao.nmaprovador%TYPE
                                    ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro      OUT VARCHAR2);           --> Erros do processo
                                    
  --> Busca Aprovadores Cartão
  PROCEDURE pc_busca_aprovadores_crd(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                    
  --> Atualiza número de contratao para sugestão do motor
  PROCEDURE pc_atualiza_contrato_suges_mot(pr_cdcooper      IN tbgen_webservice_aciona.cdcooper%TYPE
                                          ,pr_nrdconta      IN tbgen_webservice_aciona.nrdconta%TYPE
                                          ,pr_nrctrcrd      IN tbgen_webservice_aciona.nrctrprp%TYPE
                                          ,pr_dsprotoc      IN tbgen_webservice_aciona.dsprotocolo%TYPE
                                          ,pr_idproces      IN VARCHAR2
                                          ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro      OUT VARCHAR2);           --> Erros do processo
                                          
  --> Busca Aprovadores Cartão
  PROCEDURE pc_possui_senha_aprov_crd(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                     
  PROCEDURE pc_atualiza_just_updown_cartao(pr_cdcooper      IN CRAWCRD.cdcooper%TYPE
                                          ,pr_nrdconta      IN CRAWCRD.nrdconta%TYPE
                                          ,pr_nrctrcrd      IN CRAWCRD.nrctrcrd%TYPE
                                          ,pr_ds_justif     IN CRAWCRD.dsjustif%TYPE
                                          ,pr_inupgrad      IN CRAWCRD.inupgrad%TYPE
                                          ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro      OUT VARCHAR2);         --> Erros do processo                                   
  PROCEDURE pc_verifica_adicionais(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                  , pr_xmllog IN VARCHAR2               --> XML com informações de LOG
                                  , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  , pr_retxml IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  , pr_des_erro OUT VARCHAR2); --> Erros do processo                                          
                                  
  PROCEDURE pc_busca_parametro_pa_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                        
  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_incluir_proposta_est_wb(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                      ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2);

END TELA_ATENDA_CARTAOCREDITO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_CARTAOCREDITO IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_CARTAOCREDITO
  --  Sistema  : Ayllos Web
  --  Autor    : Renato Darosci
  --  Data     : Agosto/2017                 Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela de Cartão de Crédito
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_hist_limite_crd(pr_cdcooper  IN tbcrd_limite_atualiza.cdcooper%TYPE       --> Cooperativa
                                    ,pr_nrdconta  IN tbcrd_limite_atualiza.nrdconta%TYPE       --> Conta
                                    ,pr_nrcctitg  IN tbcrd_limite_atualiza.nrconta_cartao%TYPE --> Cartão
                                    ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
  /* .............................................................................

    Programa: pc_busca_hist_limite_crd
    Sistema : Ayllos Web
    Autor   : Renato Darosci
    Data    : Agosto/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar o histórico de alteração de limite de
                cartão de crédito

    Alteracoes:
  ..............................................................................*/

    -- Buscar todos os lançamentos
    CURSOR cr_limite IS
      SELECT to_char(atu.dtretorno,'DD/MM/YYYY')  dtretorno
           , DECODE(atu.cdcanal, 14, 'AUTOMATICA'   /* SAS */
                                   , 'MANUAL' )   dstipatu
           , atu.vllimite_anterior
           , atu.vllimite_alterado
        FROM tbcrd_limite_atualiza atu
       WHERE atu.cdcooper       = pr_cdcooper
         AND atu.nrdconta       = pr_nrdconta
         AND atu.nrconta_cartao = pr_nrcctitg
         AND atu.tpsituacao     = 3 /* Concluido com sucesso */
       ORDER BY atu.dtretorno DESC
              , atu.vllimite_alterado DESC;

    -- Variavel de criticas
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis gerais
    vr_cont_tag PLS_INTEGER := 0;

  BEGIN
    -- Extrai os dados vindos do XML
  /*  GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);*/

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    -- Para cada um dos históricos de alteração de limite
    FOR rw_limite IN cr_limite LOOP
      -- Insere o nodo de histórico
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'historico'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      -- Insere a data de alteração do limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'dtaltera'
                            ,pr_tag_cont => rw_limite.dtretorno
                            ,pr_des_erro => vr_dscritic);

      -- Insere a forma de atualização do limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'dstipalt'
                            ,pr_tag_cont => rw_limite.dstipatu
                            ,pr_des_erro => vr_dscritic);

      -- Valor de limite antigo
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'vllimold'
                            ,pr_tag_cont => TO_CHAR(rw_limite.vllimite_anterior,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                            ,pr_des_erro => vr_dscritic);
      -- Novo valor de limite
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'historico'
                            ,pr_posicao  => vr_cont_tag
                            ,pr_tag_nova => 'vllimnew'
                            ,pr_tag_cont => TO_CHAR(rw_limite.vllimite_alterado,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')
                            ,pr_des_erro => vr_dscritic);

      -- Incrementa o contador de tags
      vr_cont_tag := vr_cont_tag + 1;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PC_BUSCA_HIST_LIMITE_CRD: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_hist_limite_crd;
  
  --> Retornar uma lista com as sugestões do motor para cartão de crédito
  PROCEDURE pc_busca_sugestao_motor(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_sugestao_motor
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar uma lista com as sugestões do motor para cartão de crédito

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar sugestões na tela de acionamento
    CURSOR cr_acionamento(pr_cdcooper crapass.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT idacionamento
            ,dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND cdoperad = 'MOTOR'
         AND nrdconta = pr_nrdconta
         AND tpacionamento = 2 --> Apenas Retorno
         AND cdorigem  = 9     --> Apenas Ayllos Web
         AND tpproduto = 4     --> Apenas Cartão de Crédito
         AND nrctrprp IS NULL
         AND dhacionamento = (SELECT MAX(dhacionamento)
                                FROM tbgen_webservice_aciona
                               WHERE cdcooper = pr_cdcooper
                                 AND cdoperad = 'MOTOR'
                                 AND nrdconta = pr_nrdconta
                                 AND tpacionamento = 2 --> Apenas Retorno
                                 AND cdorigem  = 9     --> Apenas Ayllos Web
                                 AND tpproduto = 4     --> Apenas Cartão de Crédito
                                 AND nrctrprp IS NULL
                                 AND trunc(dhacionamento) BETWEEN (trunc(SYSDATE) - 10) and trunc(SYSDATE))
      ORDER BY dhacionamento;
    rw_acionamento cr_acionamento%ROWTYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    vr_dsmensag VARCHAR2(1000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    vr_flgsug   BOOLEAN := FALSE;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'sugestoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    OPEN cr_acionamento(pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
    FETCH cr_acionamento INTO rw_acionamento;
    
    IF cr_acionamento%FOUND THEN
      CLOSE cr_acionamento;
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestoes', pr_posicao => 0, pr_tag_nova => 'sugestao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'json', pr_tag_cont => rw_acionamento.dsconteudo_requisicao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'idacionamento', pr_tag_cont => rw_acionamento.idacionamento, pr_des_erro => vr_dscritic);
    ELSE
      CLOSE cr_acionamento;
      
      este0005.pc_solicita_sugestao_mot(pr_cdcooper  => vr_cdcooper
                                       ,pr_cdagenci  => vr_cdagenci
                                       ,pr_cdoperad  => vr_cdoperad
                                       ,pr_cdorigem  => vr_idorigem
                                       ,pr_nrdconta  => pr_nrdconta
                                       ,pr_dtmvtolt  => TRUNC(SYSDATE)
                                       ---- OUT ----
                                       ,pr_dsmensag => vr_dsmensag
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic );
                                       
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      ELSE
        vr_flgsug := TRUE;
      END IF;
    END IF;
    
    --Se rotina de sugestão foi executada sem erros, busca os acionamentos para verificar se gerou a sugestão.
    IF vr_flgsug THEN
      OPEN cr_acionamento(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);
      FETCH cr_acionamento INTO rw_acionamento;
      
      IF cr_acionamento%FOUND THEN
        CLOSE cr_acionamento;
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestoes', pr_posicao => 0, pr_tag_nova => 'sugestao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'json', pr_tag_cont => rw_acionamento.dsconteudo_requisicao, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'sugestao', pr_posicao => vr_contador, pr_tag_nova => 'idacionamento', pr_tag_cont => rw_acionamento.idacionamento, pr_des_erro => vr_dscritic);
      END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_busca_sugestao_motor. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_sugestao_motor;
  
  --> Validar se o operador está alterando o limite da sua própria conta
  PROCEDURE pc_valida_operador_alt_limite(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_valida_operador_alt_limite
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Validar se o operador está alterando o limite da sua própria conta

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Valida se o operador é o titular da conta
    CURSOR cr_conta_oper (pr_cdcooper crapass.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE
                         ,pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT 'S' existeconta
            ,idseqttl
        FROM crapttl              ttl
            ,tbcadast_colaborador col
            ,crapope              ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad
         AND col.cdcooper = ope.cdcooper
         AND col.cdusured = ope.cdoperad
         AND ttl.cdcooper = col.cdcooper
         AND ttl.nrcpfcgc = col.nrcpfcgc
         AND ttl.nrdconta = pr_nrdconta;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
    vr_existe_conta VARCHAR2(1) := 'N';
    vr_titular      VARCHAR2(1) := 'N';
    
  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'contas', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_conta_oper IN cr_conta_oper(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_cdoperad => vr_cdoperad) LOOP

      vr_existe_conta := rw_conta_oper.existeconta;
      
      IF rw_conta_oper.idseqttl = 1 THEN
        vr_titular      := 'S';
      END IF;     
      
    END LOOP;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => 0, pr_tag_nova => 'conta', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'existeconta', pr_tag_cont => vr_existe_conta, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'conta', pr_posicao => vr_contador, pr_tag_nova => 'titular', pr_tag_cont => vr_titular, pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_valida_operador_alt_limite. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_valida_operador_alt_limite;
  
  --> Validar se o operador que solicitou o cartão é o mesmo que está entregando
  PROCEDURE pc_valida_operador_entrega(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                      ,pr_nrcrcard IN crapcrd.nrcrcard%TYPE --> Nr. do Cartão
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_valida_operador_entrega
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Validar se o operador que solicitou o cartão é o mesmo que está entregando

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Valida se o operador é o titular da conta
    CURSOR cr_oper_entrega (pr_cdcooper crapass.cdcooper%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE
                           ,pr_nrcrcard crapcrd.nrcrcard%TYPE) IS
      SELECT crd.cdopeori
            ,crd.cdadmcrd
        FROM crapcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrcrcard = pr_nrcrcard;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
    vr_mesmo_operador varchar2(1) := 'N';
    
  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cartoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_oper_entrega IN cr_oper_entrega(pr_cdcooper => vr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrcrcard => pr_nrcrcard) LOOP

      --Valida se não é Cartão BB
      IF rw_oper_entrega.cdadmcrd NOT IN (83,85,87) THEN
        --Valida se operador da solicitação é o mesmo da entrega
        IF rw_oper_entrega.cdopeori = vr_cdoperad THEN
          vr_mesmo_operador := 'S';
        END IF;
      END IF;
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartoes', pr_posicao => 0, pr_tag_nova => 'cartao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartao', pr_posicao => vr_contador, pr_tag_nova => 'operador', pr_tag_cont => vr_mesmo_operador, pr_des_erro => vr_dscritic);
      
    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_valida_operador_entrega. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_valida_operador_entrega;
  
  --> Retornar nome da administradora
  PROCEDURE pc_busca_desc_administadora(pr_cdadmcrd IN crapadc.cdadmcrd%TYPE --> Nr. da Conta
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_desc_administadora
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar nome da administradora

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar informações da administradora do cartão
    CURSOR cr_admin(pr_cdcooper crapass.cdcooper%TYPE) IS
      SELECT adc.nmresadm
        FROM crapadc adc
       WHERE adc.cdcooper = pr_cdcooper
         AND adc.cdadmcrd = pr_cdadmcrd;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'administradoras', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_admin IN cr_admin(pr_cdcooper => vr_cdcooper) LOOP      

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'administradoras', pr_posicao => 0, pr_tag_nova => 'administradora', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'administradoras', pr_posicao => vr_contador, pr_tag_nova => 'nome', pr_tag_cont => rw_admin.nmresadm, pr_des_erro => vr_dscritic);
   
    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_busca_desc_administadora. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_desc_administadora;
  
  --> Retornar Situação Decisão Esteira
  PROCEDURE pc_busca_situacao_decisao(pr_nrdconta IN crawcrd.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_situacao_decisao
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 06/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar descrição da decição da Esteira de crédito

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar informações da administradora do cartão
    CURSOR cr_crawcrd(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                     ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE) IS
      SELECT decode(crd.insitdec,
                   1,'Sem Aprovacao',
                   2,'Aprovada Auto',
                   3,'Aprovada Manual',
                   4,'Erro',
                   5,'Rejeitada',
                   6,'Refazer',
                   7,'Expirada','') dssitdec
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrctrcrd = pr_nrctrcrd;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cartoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_crawcrd IN cr_crawcrd(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctrcrd => pr_nrctrcrd) LOOP      

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartoes', pr_posicao => 0, pr_tag_nova => 'situacao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartoes', pr_posicao => vr_contador, pr_tag_nova => 'descricao', pr_tag_cont => rw_crawcrd.dssitdec, pr_des_erro => vr_dscritic);
   
    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_busca_situacao_decisao. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_situacao_decisao;
  
  --> Busca Assinatura Representantes/Procuradores
  PROCEDURE pc_busca_ass_repres_proc(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_ass_repres_proc
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 09/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Busca lista de representantes/procuradores de pessoas jurídicas para validar assinatura

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT crapass.cdagenci, 
             crapass.inpessoa,
             crapass.vllimcre,
             crapass.cdcooper,
             crapass.nrdconta,
             crapass.nmprimtl,
             crapass.cdsitdtl,
             crapass.nrcpfcgc,
             crapass.inlbacen,
             crapass.cdsitcpf,
             crapass.cdtipcta,
             crapass.dtdemiss,
             crapass.nrdctitg,
             crapass.flgctitg,
             crapass.idimprtr,
             crapass.idastcjt,
             crapass.cdsitdct
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --> Buscar dados assinatura
    CURSOR cr_tbaprc (pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrcrd crawcrd.nrctrcrd%TYPE,
                      pr_nrcpf    tbcrd_aprovacao_cartao.nrcpf%TYPE)IS
      SELECT idaprovacao,
             cdcooper,
             nrdconta,
             nrctrcrd,
             indtipo_senha,
             dtaprovacao,
             hraprovacao,
             nrcpf,
             nmaprovador
        FROM tbcrd_aprovacao_cartao
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd
         AND nrcpf    = pr_nrcpf;
    rw_tbaprc cr_tbaprc%ROWTYPE;
    
    CURSOR cr_crawcrd (pr_cdcooper crawcrd.cdcooper%TYPE) IS
      SELECT insitcrd
        FROM crawcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    
    vr_assinou  VARCHAR2(1);
    vr_idxctr   PLS_INTEGER;
    vr_insitcrd crawcrd.insitcrd%TYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    --vr_cont_reg NUMBER := 0;
    
    vr_tab_crapavt cada0001.typ_tab_crapavt_58; --Tabela Avalistas
    vr_tab_bens    cada0001.typ_tab_bens;          --Tabela bens
    vr_tab_erro    gene0001.typ_tab_erro;
    
  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'representantes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    OPEN cr_crawcrd(pr_cdcooper => vr_cdcooper);
    FETCH cr_crawcrd INTO vr_insitcrd;
    CLOSE cr_crawcrd;
    
    --Busca dados do associado
    FOR rw_crapass IN cr_crapass(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta) LOOP      

      IF rw_crapass.inpessoa = 2 THEN --PJ
        cada0001.pc_busca_dados_58(pr_cdcooper => vr_cdcooper
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_nmdatela => vr_nmdatela
                                  ,pr_idorigem => vr_idorigem
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => 0
                                  ,pr_flgerlog => FALSE
                                  ,pr_cddopcao => 'C'
                                  ,pr_nrdctato => 0
                                  ,pr_nrcpfcto => ''
                                  ,pr_nrdrowid => NULL
                                  ,pr_tab_crapavt => vr_tab_crapavt
                                  ,pr_tab_bens => vr_tab_bens
                                  ,pr_tab_erro => vr_tab_erro
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR 
          vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        vr_idxctr := vr_tab_crapavt.first;
        --> Verificar se retornou informacao
        IF vr_idxctr IS NULL THEN
          vr_dscritic := 'Não foram encontrados dados de representantes.';
          RAISE vr_exc_saida;
        END IF;
            
        FOR vr_cont_reg IN vr_tab_crapavt.FIRST..vr_tab_crapavt.LAST LOOP
          
          -- Buscar dados assinatura
          OPEN cr_tbaprc(pr_cdcooper => vr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctrcrd => pr_nrctrcrd,
                         pr_nrcpf    => vr_tab_crapavt(vr_cont_reg).nrcpfcgc);
          FETCH cr_tbaprc INTO rw_tbaprc;
                  
          IF cr_tbaprc%NOTFOUND THEN
            vr_assinou := 'N';          
            CLOSE cr_tbaprc;
          ELSE
            vr_assinou := 'S';
            CLOSE cr_tbaprc;
          END IF;
                
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representantes', pr_posicao => 0, pr_tag_nova => 'representante'    , pr_tag_cont => NULL                                , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgf', pr_tag_cont => vr_tab_crapavt(vr_cont_reg).nrcpfcgc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'nome'    , pr_tag_cont => vr_tab_crapavt(vr_cont_reg).nmdavali, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'assinou' , pr_tag_cont => vr_assinou                          , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'idastcjt', pr_tag_cont => rw_crapass.idastcjt                 , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'nrdctato', pr_tag_cont => vr_tab_crapavt(vr_cont_reg).nrdctato, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'insitcrd', pr_tag_cont => vr_insitcrd                         , pr_des_erro => vr_dscritic);
              
          vr_contador := vr_contador + 1;
            
        END LOOP;
      ELSE
        -- Buscar dados assinatura
        OPEN cr_tbaprc(pr_cdcooper => vr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrctrcrd => pr_nrctrcrd,
                       pr_nrcpf    => rw_crapass.nrcpfcgc);
        FETCH cr_tbaprc INTO rw_tbaprc;
                  
        IF cr_tbaprc%NOTFOUND THEN
          vr_assinou := 'N';          
          CLOSE cr_tbaprc;
        ELSE
          vr_assinou := 'S';
          CLOSE cr_tbaprc;
        END IF;
                
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representantes', pr_posicao => 0, pr_tag_nova => 'representante'    , pr_tag_cont => NULL               , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgf', pr_tag_cont => rw_crapass.nrcpfcgc, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'nome'    , pr_tag_cont => rw_crapass.nmprimtl, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'assinou' , pr_tag_cont => vr_assinou         , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'idastcjt', pr_tag_cont => rw_crapass.idastcjt, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'nrdctato', pr_tag_cont => rw_crapass.nrdconta, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'representante', pr_posicao => vr_contador, pr_tag_nova => 'insitcrd', pr_tag_cont => vr_insitcrd        , pr_des_erro => vr_dscritic);
      END IF;
        
    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAOCREDITO.pc_busca_ass_repres_proc. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_ass_repres_proc;

  --> Insere Aprovadores de Cartões
  PROCEDURE pc_insere_aprovador_crd( pr_cdcooper      IN tbcrd_aprovacao_cartao.cdcooper%TYPE
                                    ,pr_nrdconta      IN tbcrd_aprovacao_cartao.nrdconta%TYPE
                                    ,pr_nrctrcrd      IN tbcrd_aprovacao_cartao.nrctrcrd%TYPE
                                    ,pr_indtipo_senha IN tbcrd_aprovacao_cartao.indtipo_senha%TYPE
                                    ,pr_dtaprovacao   IN VARCHAR2
                                    ,pr_hraprovacao   IN tbcrd_aprovacao_cartao.hraprovacao%TYPE
                                    ,pr_nrcpf         IN tbcrd_aprovacao_cartao.nrcpf%TYPE
                                    ,pr_nmaprovador   IN tbcrd_aprovacao_cartao.nmaprovador%TYPE
                                    ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro      OUT VARCHAR2) IS         --> Erros do processo
                                    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
                                    
  BEGIN 
    -- Inserir 
    BEGIN
      INSERT 
        INTO tbcrd_aprovacao_cartao(idaprovacao,
                                    cdcooper,
                                    nrdconta,
                                    nrctrcrd,
                                    indtipo_senha,
                                    dtaprovacao,
                                    hraprovacao,
                                    nrcpf,
                                    nmaprovador)
                             VALUES(tbcrd_aprovacao_cartao_seq.nextval,
                                    pr_cdcooper,
                                    pr_nrdconta,
                                    pr_nrctrcrd,
                                    pr_indtipo_senha,
                                    to_date(pr_dtaprovacao,'DD/MM/RRRR'),
                                    pr_hraprovacao,
                                    pr_nrcpf,
                                    pr_nmaprovador);
                                    
       COMMIT;
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Aprovador já cadastrado.';
        RAISE vr_exc_saida;
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_insere_aprovador_crd: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_insere_aprovador_crd: ' || SQLERRM;
      ROLLBACK;
  END pc_insere_aprovador_crd;
  
  --> Busca Aprovadores Cartão
  PROCEDURE pc_busca_aprovadores_crd(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE --> Nr. do contrato
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_busca_aprovadores_crd
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 09/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Busca lista de aprovadores do cartão

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar dados assinatura
    CURSOR cr_tbaprc (pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrcrd crawcrd.nrctrcrd%TYPE)IS
      SELECT idaprovacao,
             cdcooper,
             nrdconta,
             nrctrcrd,
             indtipo_senha,
             dtaprovacao,
             hraprovacao,
             nrcpf,
             nmaprovador
        FROM tbcrd_aprovacao_cartao
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    rw_tbaprc cr_tbaprc%ROWTYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    vr_cont_reg NUMBER := 0;
    
    vr_tab_crapavt cada0001.typ_tab_crapavt_58; --Tabela Avalistas
    vr_tab_bens    cada0001.typ_tab_bens;          --Tabela bens
    vr_tab_erro    gene0001.typ_tab_erro;
    
  BEGIN
    pr_des_erro := 'OK';
    
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'aprovadores', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Buscar dados assinatura
    FOR rw_tbaprc IN cr_tbaprc(pr_cdcooper => vr_cdcooper,
                               pr_nrdconta => pr_nrdconta,
                               pr_nrctrcrd => pr_nrctrcrd) LOOP      

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovadores', pr_posicao => 0, pr_tag_nova => 'aprovador', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'idaprovacao'  , pr_tag_cont => rw_tbaprc.idaprovacao  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper'     , pr_tag_cont => rw_tbaprc.cdcooper     , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta'     , pr_tag_cont => rw_tbaprc.nrdconta     , pr_des_erro => vr_dscritic);  
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'nrctrcrd'     , pr_tag_cont => rw_tbaprc.nrctrcrd     , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'indtipo_senha', pr_tag_cont => rw_tbaprc.indtipo_senha, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'dtaprovacao'  , pr_tag_cont => rw_tbaprc.dtaprovacao  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'hraprovacao'  , pr_tag_cont => rw_tbaprc.hraprovacao  , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'nrcpf'        , pr_tag_cont => rw_tbaprc.nrcpf        , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'aprovador', pr_posicao => vr_contador, pr_tag_nova => 'nmaprovador'  , pr_tag_cont => rw_tbaprc.nmaprovador  , pr_des_erro => vr_dscritic);
                  
      vr_contador := vr_contador + 1;
          
    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_busca_aprovadores_crd. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_aprovadores_crd;
  
  --> Atualiza número de contratao para sugestão do motor
  PROCEDURE pc_atualiza_contrato_suges_mot(pr_cdcooper      IN tbgen_webservice_aciona.cdcooper%TYPE
                                          ,pr_nrdconta      IN tbgen_webservice_aciona.nrdconta%TYPE
                                          ,pr_nrctrcrd      IN tbgen_webservice_aciona.nrctrprp%TYPE
                                          ,pr_dsprotoc      IN tbgen_webservice_aciona.dsprotocolo%TYPE
                                          ,pr_idproces      IN VARCHAR2
                                          ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro      OUT VARCHAR2) IS         --> Erros do processo
                                    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_contador NUMBER := 0;
                                    
  BEGIN 
    IF pr_idproces = 'S' THEN --Solicitação/Alteração
      -- Atualiza Contrato 
      BEGIN
        UPDATE tbgen_webservice_aciona
           SET nrctrprp = pr_nrctrcrd
         WHERE dsprotocolo = pr_dsprotoc;
         
        UPDATE crawcrd
           SET dsprotoc = pr_dsprotoc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrcrd = pr_nrctrcrd;
                                      
         COMMIT;
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_contrato_suges_mot: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      -- Atualiza Status 
      BEGIN
        UPDATE crawcrd
           SET insitcrd = 1 --Aprovado
              ,insitdec = 2 --Aprovado Automaticamente
              ,dtmvtolt = SYSDATE
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrcrd = pr_nrctrcrd;
                                      
         COMMIT;
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_contrato_suges_mot: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    END IF;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'atualizacoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'atualizacoes', pr_posicao => 0, pr_tag_nova => 'atualizacao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'atualizacao', pr_posicao => vr_contador, pr_tag_nova => 'status'  , pr_tag_cont => 'Atualização realizada com sucesso', pr_des_erro => vr_dscritic);
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_contrato_suges_mot: ' || SQLERRM;
      ROLLBACK;

  END pc_atualiza_contrato_suges_mot;
  
  --> Busca Aprovadores Cartão
  PROCEDURE pc_possui_senha_aprov_crd(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

        Programa: pc_possui_senha_aprov_crd
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Paulo Silva - supero
        Data    : Abril/2018                 Ultima atualizacao: 09/04/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Valida se cooperado possui alguma senha de cartão magnético, internet ou cartão de crédito para poder validar na hora da solicitação

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
    
    ---------> CURSORES <--------
    --> Buscar Senha Cartão Magnético
    CURSOR cr_crapcrm IS
      SELECT 'S'
        FROM crapcrm
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND cdsitcar = 2; --Ativo
    rw_crapcrm cr_crapcrm%ROWTYPE;
  
    -- Busca Senha Internet
    CURSOR cr_crapsnh IS
      SELECT 'S'
        FROM crapsnh
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND tpdsenha = 1 --Internet
         AND cdsitsnh = 1; --Ativo
    rw_crapsnh cr_crapsnh%ROWTYPE;
   
    -- Buscar Senha Cartão de Crédito
    CURSOR cr_crapcrd IS
      SELECT 'S'
        FROM crapcrd
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtcancel is null
         AND cdadmcrd between 10 and 80; --Apenas Bancoob
    rw_crapcrd cr_crapcrd%ROWTYPE;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;
    vr_senha    VARCHAR2(1000);
    vr_inpessoa crapass.inpessoa%TYPE;
    vr_nrdconta crapass.nrdconta%TYPE;
    
  BEGIN
    pr_des_erro := 'OK';
    
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'senhas', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Verifica se existe senha cartão magnético
    OPEN cr_crapcrm;
    FETCH cr_crapcrm INTO rw_crapcrm;
    -- Se nao encontrar
    IF cr_crapcrm%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcrm;
      
      vr_senha := 'NOK';
      
      -- Montar mensagem de critica
      vr_dscritic := 'Não possui senha para Cartão Magnético.';
    ELSE
      vr_senha := 'OK';
      
      -- Apenas fechar o cursor
      CLOSE cr_crapcrm;
    END IF;
    
    IF vr_senha <> 'OK' THEN
      -- Verifica se existe senha de internet
      OPEN cr_crapsnh;
      FETCH cr_crapsnh INTO rw_crapsnh;
      -- Se nao encontrar
      IF cr_crapsnh%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapsnh;
        
        vr_senha := 'NOK';
        
        -- Montar mensagem de critica
        vr_dscritic := 'Não possui senha de internet.';
      ELSE
        vr_senha := 'OK';
        
        -- Apenas fechar o cursor
        CLOSE cr_crapsnh;
      END IF;
      
      IF vr_senha <> 'OK' THEN
        -- Verifica se existe senha cartão crédito
        OPEN cr_crapcrd;
        FETCH cr_crapcrd INTO rw_crapcrd;
        -- Se nao encontrar
        IF cr_crapcrd%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE cr_crapcrd;
          
          vr_senha := 'NOK';
          
          -- Montar mensagem de critica
          vr_dscritic := 'Não possui senha para Cartão de Crédito.';
        ELSE
          vr_senha := 'OK';
          
          -- Apenas fechar o cursor
          CLOSE cr_crapcrd;
        END IF;
      END IF;
    END IF;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'senhas', pr_posicao => 0, pr_tag_nova => 'senha', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'senha', pr_posicao => vr_contador, pr_tag_nova => 'status'  , pr_tag_cont => vr_senha  , pr_des_erro => vr_dscritic);
      
  EXCEPTION
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_CARTAO_CREDITO.pc_possui_senha_aprov_crd. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_possui_senha_aprov_crd;
  
  --> Atualiza a justificativa
  PROCEDURE pc_atualiza_just_updown_cartao(pr_cdcooper      IN CRAWCRD.cdcooper%TYPE
                                          ,pr_nrdconta      IN CRAWCRD.nrdconta%TYPE
                                          ,pr_nrctrcrd      IN CRAWCRD.nrctrcrd%TYPE
                                          ,pr_ds_justif     IN CRAWCRD.dsjustif%TYPE
                                          ,pr_inupgrad      IN CRAWCRD.inupgrad%TYPE
                                          ,pr_xmllog        IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic      OUT PLS_INTEGER          --> Código da crítica
                                          ,pr_dscritic      OUT VARCHAR2             --> Descrição da crítica
                                          ,pr_retxml        IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo      OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro      OUT VARCHAR2) IS         --> Erros do processo
                                    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_contador NUMBER := 0;
                                    
  BEGIN 
    -- Inserir 
    BEGIN
      UPDATE CRAWCRD t
      SET    t.dsjustif = pr_ds_justif
            ,t.inupgrad = nvl(pr_inupgrad,1)
            ,t.dtmvtolt = SYSDATE
      WHERE  t.cdcooper = pr_cdcooper
      AND    t.nrdconta = pr_nrdconta
      AND    t.nrctrcrd = pr_nrctrcrd;
                                    
      COMMIT;
       
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_just_updown_cartao: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'atualizacoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'atualizacoes', pr_posicao => 0, pr_tag_nova => 'atualizacao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'atualizacao', pr_posicao => vr_contador, pr_tag_nova => 'status'  , pr_tag_cont => 'Atualização realizada com sucesso', pr_des_erro => vr_dscritic);
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_atualiza_just_updown_cartao: ' || SQLERRM;
      ROLLBACK;

  END pc_atualiza_just_updown_cartao;
 
  PROCEDURE pc_verifica_adicionais( pr_nrdconta IN crapass.nrdconta%TYPE
                                    , pr_xmllog IN VARCHAR2              --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    , pr_retxml IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................

        Programa: pc_verifica_adicionais
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Amasonas Borges Vieira Junior
        Data    : maio/2018                 Ultima atualizacao: 03/05/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Informar se a conta possui cartões adicionais ativos

        Observacao: -----

        Alteracoes:
    ..............................................................................*/

    ---------> CURSORES <--------
    --> Buscar informações da conta 
    CURSOR cr_admin(pr_cdcooper crapass.cdcooper% TYPE ) IS
    SELECT crd.nrcrcard
    FROM
    crawcrd crd
    WHERE
      crd.nrdconta = pr_nrdconta
      AND crd.cdgraupr > 0 
      AND crd.cdcooper = pr_cdcooper
      AND crd.insitcrd = 4 ;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic % TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER := 0;

    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
      pr_cdcooper => vr_cdcooper,
      pr_nmdatela => vr_nmdatela,
      pr_nmeacao  => vr_nmeacao,
      pr_cdagenci => vr_cdagenci,
      pr_nrdcaixa => vr_nrdcaixa,
      pr_idorigem => vr_idorigem,
      pr_cdoperad => vr_cdoperad,
      pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL
        THEN
        -- Levanta exceção
            RAISE vr_exc_saida;
    END IF;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'cartoes', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_admin IN cr_admin(pr_cdcooper => vr_cdcooper) LOOP

    --gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartoes', pr_posicao => 0, pr_tag_nova => 'cartao', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'cartoes', pr_posicao => vr_contador, pr_tag_nova => 'cartao', pr_tag_cont => rw_admin.nrcrcard, pr_des_erro => vr_dscritic);

    END LOOP;

    EXCEPTION
        WHEN vr_exc_saida THEN

    IF vr_cdcritic <> 0
      THEN
          pr_cdcritic := vr_cdcritic;
    pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;
    END IF;

    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<? XML version="1.0" encoding="ISO-8859-1" ?> ' ||
    '< ROOT ><Erro>' || pr_dscritic || '</Erro></ ROOT >');
    ROLLBACK;
    WHEN OTHERS THEN

    pr_cdcritic := vr_cdcritic;
    pr_dscritic := 'Erro geral na rotina na PROCEDURE TELA_ATENDA_CARTAO_CREDITO.pc_verifica_adicionais. Erro: ' || SQLERRM;
    pr_des_erro := 'NOK';
    -- Carregar XML padrão para variável de retorno não utilizada.
    -- Existe para satisfazer exigência da interface.
    pr_retxml := XMLType.createXML('<? XML version="1.0" encoding="ISO-8859-1" ?> ' ||
    '< ROOT ><Erro>'' || pr_dscritic || ''</Erro></ ROOT >');
    ROLLBACK;

  END pc_verifica_adicionais;
  
  
  PROCEDURE pc_busca_parametro_pa_cartao(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo do PA
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
/* .............................................................................

        Programa: pc_busca_parametro_pa_cartao
        Sistema : CECRED
        Sigla   : CRD
        Autor   : Anderson Fossa
        Data    : maio/2018                 Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Retornar se a Cooper / PA pode solicitar cartao atraves do novo
                    formato - utilizando os WS Bancoob.

        Observacao: Procedimento temporario. Realizar validacao por PA ou OPERAD.

        Alteracoes:
    ..............................................................................*/
    
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(10000);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    BEGIN
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
      
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'ativo'
                            ,pr_tag_cont => 1
                            ,pr_des_erro => vr_dscritic);
                                    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em TELA_ATENDA_CARTAOCREDITO.pc_busca_parametro_pa_cartao: ' || SQLERRM;
        
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    
  END pc_busca_parametro_pa_cartao;
  
  --> Rotina responsavel por gerar a inclusao da proposta para a esteira
  PROCEDURE pc_incluir_proposta_est_wb(pr_nrdconta  IN crawcrd.nrdconta%TYPE
                                      ,pr_nrctrcrd  IN crawcrd.nrctrcrd%TYPE
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS

    /* ..........................................................................
    
      Programa : pc_incluir_proposta_est_wb   
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Paulo Silva (Supero)
      Data     : Maio/2018.                   Ultima atualizacao: 05/05/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por gerar a inclusao da proposta para a esteira    
      Alteração : 
                  
    ..........................................................................*/
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
  BEGIN    
    
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
    
    este0005.pc_incluir_proposta_est(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_cdorigem => vr_idorigem
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctrcrd => pr_nrctrcrd
                                     ---- OUT ----
                                    ,pr_dsmensag => pr_des_erro
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      
    -- verificar se retornou critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'mensagem',
                           pr_tag_cont => pr_des_erro,
                           pr_des_erro => vr_dscritic);
    
    COMMIT;   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi possivel realizar inclusao da proposta de Análise de Crédito: '||SQLERRM;
  END pc_incluir_proposta_est_wb;                                   
  
END TELA_ATENDA_CARTAOCREDITO;
/
