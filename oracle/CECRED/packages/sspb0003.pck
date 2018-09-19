CREATE OR REPLACE PACKAGE CECRED.SSPB0003 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: SSPB0003
  --    Autor   : Douglas Quisinski
  --    Data    : Abril/2017                      Ultima Atualizacao: 12/07/2018
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Gravar as mensagens de TED em uma nova estrutura, e armazenar as mensagens que 
  --                s�o devolvidas a cabine com rejei��o
  --
  --    Alteracoes: 
  --           12/07/2018 - Altera��es referentes ao projeto 475 - MELHORIAS SPB CONTING�NCIA
  --                        Marcelo Telles Coelho - Mouts
  --    
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para gravar as mensagens de TED de forma gen�rica
  PROCEDURE pc_grava_mensagem_ted(pr_cdcooper   IN tbspb_mensagem.cdcooper%TYPE,   --> Cooperativa
                                  pr_nrctrlif   IN tbspb_mensagem.nrctrlif%TYPE,   --> Numero de controle
                                  pr_dtmensagem IN tbspb_mensagem.dtmensagem%TYPE, --> Data da mensagem
                                  pr_nmevento   IN tbspb_mensagem.nmevento%TYPE,   --> Evento
                                  pr_dsxml      IN tbspb_mensagem.dsxml%TYPE,      --> XML da mensagem
                                  pr_cdprograma IN crapprg.cdprogra%TYPE,          --> Programa que chamou
                                  pr_cdcritic   OUT crapcri.cdcritic%TYPE,         --> Codigo do erro
                                  pr_dscritic   OUT crapcri.dscritic%TYPE);        --> Mensagem do erro

  -- Rotina para gravar as mensagens de TED de rejei��o que devolvemos ao Bancoob
  PROCEDURE pc_grava_msg_ted_rejeita(pr_cdcooper IN tbspb_trans_rejeitada.cdcooper%TYPE,                   --> Cooperativa
                                     pr_nrdconta IN VARCHAR2,                                              --> Conta
                                     pr_cdagenci IN tbspb_trans_rejeitada.cdagenci%TYPE,                   --> Agencia
                                     pr_nrdcaixa IN tbspb_trans_rejeitada.nrdcaixa%TYPE,                   --> Numero do Caixa
                                     pr_cdoperad IN tbspb_trans_rejeitada.cdoperad%TYPE,                   --> Operador
                                     pr_cdprogra IN tbspb_trans_rejeitada.cdprogra%TYPE,                   --> Programa que chamou
                                     pr_nmevento IN tbspb_trans_rejeitada.nmevento%TYPE,                   --> Evento
                                     pr_nrctrlif IN tbspb_trans_rejeitada.nrctrlif%TYPE,                   --> Numero de controle
                                     pr_vldocmto IN tbspb_trans_rejeitada.vldocmto%TYPE,                   --> Valor
                                     -- Dados de Origem da TED (Informa��es da Conta na CENTRAL)
                                     pr_cdbanco_origem   IN tbspb_trans_rejeitada.cdbanco_origem%TYPE,     --> Banco
                                     pr_cdagencia_origem IN tbspb_trans_rejeitada.cdagencia_origem%TYPE,   --> Agencia
                                     pr_nmtitular_origem IN tbspb_trans_rejeitada.nmtitular_origem%TYPE,   --> Nome do Titular
                                     pr_nrcpf_origem     IN tbspb_trans_rejeitada.nrcpf_origem%TYPE,       --> CPF do Titular
                                     -- Dados de Destino da TED (Informa��es da Conta em outra IF)
                                     pr_cdbanco_destino   IN tbspb_trans_rejeitada.cdbanco_destino%TYPE,   --> Banco
                                     pr_cdagencia_destino IN tbspb_trans_rejeitada.cdagencia_destino%TYPE, --> Agencia
                                     pr_nrconta_destino   IN VARCHAR2,                                     --> Conta
                                     pr_nmtitular_destino IN tbspb_trans_rejeitada.nmtitular_destino%TYPE, --> Nome do Titular
                                     pr_nrcpf_destino     IN tbspb_trans_rejeitada.nrcpf_destino%TYPE,     --> CPF do Titular
                                     -- Rejei��o
                                     pr_dsmotivo_rejeicao IN tbspb_trans_rejeitada.dsmotivo_rejeicao%TYPE, --> Motivo da Rejei��o
                                     pr_nrispbif          IN tbspb_trans_rejeitada.nrispbif%TYPE,          --> ISPB
                                     -- Erro
                                     pr_cdcritic OUT crapcri.cdcritic%TYPE,                                --> Codigo do Erro
                                     pr_dscritic OUT crapcri.dscritic%TYPE);                               --> Mensagem do Erro

  -- Rotina para inserir na tabela TBSPB_MSG_XML
  PROCEDURE pc_grava_XML (pr_nmmensagem             IN TBSPB_MSG_XML.NMMENSAGEM%TYPE                  --> Nome da mensagem enviada
                         ,pr_inorigem_mensagem      IN TBSPB_MSG_XML.INORIGEM_MENSAGEM%TYPE           --> Origem da mensagem (E=Enviada, R=Recebida)
                         ,pr_dhmensagem             IN TBSPB_MSG_XML.DHMENSAGEM%TYPE                  --> Data/Hora de processamento da mensagem
                         ,pr_dsxml_mensagem         IN TBSPB_MSG_XML.DSXML_MENSAGEM%TYPE              --> XML descriptografado da mensagem limitado a 4000
                         ,pr_dsxml_completo         IN TBSPB_MSG_XML.DSXML_COMPLETO%TYPE              --> XML descriptografado da mensagem completo
                         ,pr_inenvio                IN TBSPB_MSG_XML.INENVIO%TYPE DEFAULT 0           --> Indicador de mensagem a ser enviada para o JDSPB (0=N�o Enviar, 1=Enviar)
                         ,pr_nrdconta               IN CRAPASS.NRDCONTA%TYPE                          --> Numero da conta/dv do associado
                         ,pr_cdcooper               IN CRAPASS.CDCOOPER%TYPE                          --> Codigo que identifica a Cooperativa
                         ,pr_cdproduto              IN TBCC_PRODUTO.CDPRODUTO%TYPE                    --> Codigo do produto de abertura de conta
                         ,pr_dsobservacao           IN TBSPB_MSG_XML.DSOBSERVACAO%TYPE DEFAULT NULL   --> Campo utilizado pelo sistema para armazenar observacoes, ex. Reprocesso
                         ,pr_nrseq_mensagem_xml    OUT TBSPB_MSG_XML.NRSEQ_MENSAGEM_XML%TYPE          --> Nr.sequencial do XML da mensagem
                         ,pr_dscritic              OUT VARCHAR2
                         ,pr_des_erro              OUT VARCHAR2
                         );

  -- Rotina para gravar as informa��es para o trace das mensagens enviadas e recebidas do JDSPB
  PROCEDURE pc_grava_trace_spb (pr_cdfase                 IN TBSPB_MSG_ENVIADA_FASE.CDFASE%TYPE                 --> Nr.fase de envio da mensagem
                               ,pr_idorigem               IN VARCHAR2 DEFAULT NULL                              --> Origem da mensagem (E=Enviada, R=Recebida)
                               ,pr_nmmensagem             IN TBSPB_MSG_ENVIADA.NMMENSAGEM%TYPE                  --> Nome da mensagem enviada
                               ,pr_nrcontrole             IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Institui��o Financeira
                               ,pr_nrcontrole_str_pag     IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Institui��o Financeira de destino
                               ,pr_nrcontrole_dev_or      IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Instituicao Financeira Devolu��o ou origem
                               ,pr_dhmensagem             IN TBSPB_MSG_ENVIADA.DHMENSAGEM%TYPE                  --> Data/Hora de processamento da mensagem
                               ,pr_insituacao             IN TBSPB_MSG_ENVIADA_FASE.INSITUACAO%TYPE             --> Situa��o do envio da mensagem
                               ,pr_dsxml_mensagem         IN TBSPB_MSG_XML.DSXML_MENSAGEM%TYPE                  --> XML descriptografado da mensagem limitado a 4000
                               ,pr_dsxml_completo         IN TBSPB_MSG_XML.DSXML_COMPLETO%TYPE                  --> XML descriptografado da mensagem completo
                               ,pr_nrseq_mensagem_xml     IN TBSPB_MSG_XML.NRSEQ_MENSAGEM_XML%TYPE DEFAULT NULL --> Nr.sequencial do XML da mensagem
                               ,pr_inenvio                IN TBSPB_MSG_XML.INENVIO%TYPE DEFAULT 0               --> Indicador de mensagem a ser enviada para o JDSPB (0=N�o Enviar, 1=Enviar)
                               ,pc_dhdthr_bc              IN TBSPB_MSG_RECEBIDA_FASE.DHDTHR_BC%TYPE DEFAULT NULL -- Data/Hora de postagem da mensagem pelo BACEN
                               ,pr_nrdconta               IN CRAPASS.NRDCONTA%TYPE                              --> Numero da conta/dv do associado
                               ,pr_cdcooper               IN CRAPASS.CDCOOPER%TYPE                              --> Codigo que identifica a Cooperativa
                               ,pr_cdproduto              IN TBCC_PRODUTO.CDPRODUTO%TYPE                        --> Codigo do produto de abertura de conta
                               ,pr_nrseq_mensagem        OUT TBSPB_MSG_ENVIADA.NRSEQ_MENSAGEM%TYPE              --> Nr.sequencial de mensagem
                               ,pr_nrseq_mensagem_fase   OUT TBSPB_MSG_ENVIADA_FASE.NRSEQ_MENSAGEM_FASE%TYPE    --> Nr.sequencial de fase da mensagem
                               ,pr_dscritic              OUT VARCHAR2
                               ,pr_des_erro              OUT VARCHAR2
                               );

  -- Rotina para corrigir o nome da mensagem nas tabelas SSPB_MSG_ENVIADA e SSPB_MSG_ENVIADA_FASE
  PROCEDURE pc_acerta_nmmensagem(pr_nmmensagem             IN TBSPB_MSG_ENVIADA.NMMENSAGEM%TYPE                  --> Nome da mensagem enviada
                                ,pr_nmmensagem_OLD         IN TBSPB_MSG_ENVIADA.NMMENSAGEM%TYPE                  --> Nome da mensagem a ser convertida
                                ,pr_nrcontrole_if          IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Institui��o Financeira
                                ,pr_insituacao             IN VARCHAR2                             DEFAULT 'OK'  --> Situa��o de mensagem
                                ,pr_nrseq_mensagem_xml     IN TBSPB_MSG_XML.NRSEQ_MENSAGEM_XML%TYPE              --> Nr.sequencial do XML da mensagem
                                ,pr_dscritic              OUT VARCHAR2
                                ,pr_des_erro              OUT VARCHAR2
                                );

  -- Rotina para retornar a origem da mensagem (Enviada ou Recebida)
  FUNCTION fn_retorna_inorigem (pr_nrcontrole_if          IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Institui��o Financeira
                               ) RETURN VARCHAR2;

  -- Rotina para verificar se uma mensagem de devolu��o j� foi processada
  FUNCTION fn_ver_msg_processada (pr_nrcontrole_str_pag IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE                 --> Nr.controle da Instituicao Financeira
                                  ) RETURN BOOLEAN;

  -- Rotina para acerto de recebidas
  PROCEDURE pc_acerto_recebida(pr_dscritic          OUT VARCHAR2
                              );
END SSPB0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SSPB0003 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: SSPB0003
  --    Autor   : Douglas Quisinski
  --    Data    : Abril/2017                       Ultima Atualizacao:   /  /
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Gravar as mensagens de TED em uma nova estrutura, e armazenar as mensagens que 
  --                s�o devolvidas a cabine com rejei��o
  --
  --    Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_grava_mensagem_ted(pr_cdcooper   IN tbspb_mensagem.cdcooper%TYPE,   --> Cooperativa
                                  pr_nrctrlif   IN tbspb_mensagem.nrctrlif%TYPE,   --> Numero de controle
                                  pr_dtmensagem IN tbspb_mensagem.dtmensagem%TYPE, --> Data da mensagem
                                  pr_nmevento   IN tbspb_mensagem.nmevento%TYPE,   --> Evento
                                  pr_dsxml      IN tbspb_mensagem.dsxml%TYPE,      --> XML da mensagem
                                  pr_cdprograma IN crapprg.cdprogra%TYPE,          --> Programa que chamou
                                  pr_cdcritic   OUT crapcri.cdcritic%TYPE,         --> Codigo do erro
                                  pr_dscritic   OUT crapcri.dscritic%TYPE) IS      --> Mensagem do erro  BEGIN
  BEGIN
    /* .............................................................................
    Programa: pc_grava_mensagem_ted
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 04/05/2017                        Ultima atualizacao: 04/07/2017
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar as mensagens de TED
    
    Alteracoes: 04/07/2017 - Remover a gravacao do erro no arquivo de log, o programa
                             que chamar a procedure devera realizar o tratamento
                             (Douglas - Chamado 524133)
    ............................................................................. */
    DECLARE
    
    BEGIN
    
      INSERT INTO tbspb_mensagem
        (nrctrlif, cdcooper, dtmensagem, nmevento, dsxml)
      VALUES
        (pr_nrctrlif, pr_cdcooper, pr_dtmensagem, pr_nmevento, pr_dsxml);
    
    EXCEPTION
    
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na inclusao do mensagem de TED do SPB.' ||
                       ' Coop: ' || pr_cdcooper || 
                       ', Num Controle: ' || pr_nrctrlif || 
                       ', Evento: ' || pr_nmevento ||
                       ', Data Mensagem: ' || to_char(pr_dtmensagem, 'dd/mm/yyyy') ||
                       ', XML: ' || pr_dsxml ||
                       ', ERRO: ' || SQLERRM;
      
        pc_internal_exception(pr_cdcooper => pr_cdcooper,
                              pr_compleme => pr_dscritic);
      
    END;
  END pc_grava_mensagem_ted;

  -- Rotina para gravar as mensagens de TED de rejei��o que devolvemos ao Bancoob
  PROCEDURE pc_grava_msg_ted_rejeita(pr_cdcooper IN tbspb_trans_rejeitada.cdcooper%TYPE,                   --> Cooperativa
                                     pr_nrdconta IN VARCHAR2,                                              --> Conta
                                     pr_cdagenci IN tbspb_trans_rejeitada.cdagenci%TYPE,                   --> Agencia
                                     pr_nrdcaixa IN tbspb_trans_rejeitada.nrdcaixa%TYPE,                   --> Numero do Caixa
                                     pr_cdoperad IN tbspb_trans_rejeitada.cdoperad%TYPE,                   --> Operador
                                     pr_cdprogra IN tbspb_trans_rejeitada.cdprogra%TYPE,                   --> Programa que chamou
                                     pr_nmevento IN tbspb_trans_rejeitada.nmevento%TYPE,                   --> Evento
                                     pr_nrctrlif IN tbspb_trans_rejeitada.nrctrlif%TYPE,                   --> Numero de controle
                                     pr_vldocmto IN tbspb_trans_rejeitada.vldocmto%TYPE,                   --> Valor
                                     -- Dados de Origem da TED (Informa��es da Conta na CENTRAL)
                                     pr_cdbanco_origem   IN tbspb_trans_rejeitada.cdbanco_origem%TYPE,     --> Banco
                                     pr_cdagencia_origem IN tbspb_trans_rejeitada.cdagencia_origem%TYPE,   --> Agencia
                                     pr_nmtitular_origem IN tbspb_trans_rejeitada.nmtitular_origem%TYPE,   --> Nome do Titular
                                     pr_nrcpf_origem     IN tbspb_trans_rejeitada.nrcpf_origem%TYPE,       --> CPF do Titular
                                     -- Dados de Destino da TED (Informa��es da Conta em outra IF)
                                     pr_cdbanco_destino   IN tbspb_trans_rejeitada.cdbanco_destino%TYPE,   --> Banco
                                     pr_cdagencia_destino IN tbspb_trans_rejeitada.cdagencia_destino%TYPE, --> Agencia
                                     pr_nrconta_destino   IN VARCHAR2,                                     --> Conta
                                     pr_nmtitular_destino IN tbspb_trans_rejeitada.nmtitular_destino%TYPE, --> Nome do Titular
                                     pr_nrcpf_destino     IN tbspb_trans_rejeitada.nrcpf_destino%TYPE,     --> CPF do Titular
                                     -- Rejei��o
                                     pr_dsmotivo_rejeicao IN tbspb_trans_rejeitada.dsmotivo_rejeicao%TYPE, --> Motivo da Rejei��o
                                     pr_nrispbif          IN tbspb_trans_rejeitada.nrispbif%TYPE,          --> ISPB
                                     -- Erro
                                     pr_cdcritic OUT crapcri.cdcritic%TYPE,                                --> Codigo do Erro
                                     pr_dscritic OUT crapcri.dscritic%TYPE) IS                             --> Mensagem do Erro
  BEGIN
    /* .............................................................................
    Programa: pc_grava_msg_ted_rejeita
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 04/05/2017                        Ultima atualizacao: 04/07/2017
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar as mensagens de TED Rejeitada
    
    Alteracoes: 04/07/2017 - Remover a gravacao do erro no arquivo de log, o programa
                             que chamar a procedure devera realizar o tratamento
                             (Douglas - Chamado 524133)

    ............................................................................. */
    DECLARE
    
    BEGIN
    
      INSERT INTO tbspb_trans_rejeitada
        (cdcooper,
         nrdconta,
         cdagenci,
         nrdcaixa,
         cdoperad,
         dttransa,
         hrtransa,
         cdprogra,
         nmevento,
         nrctrlif,
         vldocmto,
         cdbanco_origem,
         cdagencia_origem,
         nmtitular_origem,
         nrcpf_origem,
         cdbanco_destino,
         cdagencia_destino,
         nrconta_destino,
         nmtitular_destino,
         nrcpf_destino,
         dsmotivo_rejeicao,
         nrispbif)
      VALUES
        (pr_cdcooper,
         pr_nrdconta,
         pr_cdagenci,
         pr_nrdcaixa,
         pr_cdoperad,
         TRUNC(SYSDATE),
         gene0002.fn_busca_time,
         pr_cdprogra,
         pr_nmevento,
         pr_nrctrlif,
         pr_vldocmto,
         pr_cdbanco_origem,
         pr_cdagencia_origem,
         pr_nmtitular_origem,
         pr_nrcpf_origem,
         pr_cdbanco_destino,
         pr_cdagencia_destino,
         pr_nrconta_destino,
         pr_nmtitular_destino,
         pr_nrcpf_destino,
         pr_dsmotivo_rejeicao,
         pr_nrispbif);
    
    EXCEPTION
    
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao incluir mensagem de TED REJEITADA.' ||
                       ' Coop: ' || pr_cdcooper || 
                       ', Conta: ' || pr_nrdconta || 
                       ', Agencia: ' || pr_cdagenci ||
                       ', Caixa: ' || pr_nrdcaixa || 
                       ', Operador: ' || pr_cdoperad || 
                       ', Evento: ' || pr_nmevento ||
                       ', Nro Controle: ' || pr_nrctrlif || 
                       ', Valor: ' || pr_vldocmto || 
                       ', Motivo Erro: ' || pr_dsmotivo_rejeicao ||
                      -- Dados do banco de origem
                       ', # AILOS - Banco ' || pr_cdbanco_origem ||
                       ', Agencia: ' || pr_cdagencia_origem ||
                       ', Titular: ' || pr_nmtitular_origem || 
                       ', CPF: ' || pr_nrcpf_origem ||
                      -- Dados do banco de destino
                       ', # OUTRA IF - Banco: ' || pr_cdbanco_destino ||
                       ', Agencia: ' || pr_cdagencia_destino || 
                       ', Conta: ' || pr_nrconta_destino || 
                       ', Titular: ' || pr_nmtitular_destino || 
                       ', CPF: ' || pr_nrcpf_destino ||
                       ', ERRO: ' || SQLERRM;
      
        pc_internal_exception(pr_cdcooper => pr_cdcooper,
                              pr_compleme => pr_dscritic);
      
    END;
  END pc_grava_msg_ted_rejeita;

  PROCEDURE pc_grava_XML (pr_nmmensagem             IN TBSPB_MSG_XML.NMMENSAGEM%TYPE                  --> Nome da mensagem enviada
                         ,pr_inorigem_mensagem      IN TBSPB_MSG_XML.INORIGEM_MENSAGEM%TYPE           --> Origem da mensagem (E=Enviada, R=Recebida)
                         ,pr_dhmensagem             IN TBSPB_MSG_XML.DHMENSAGEM%TYPE                  --> Data/Hora de processamento da mensagem
                         ,pr_dsxml_mensagem         IN TBSPB_MSG_XML.DSXML_MENSAGEM%TYPE              --> XML descriptografado da mensagem limitado a 4000
                         ,pr_dsxml_completo         IN TBSPB_MSG_XML.DSXML_COMPLETO%TYPE              --> XML descriptografado da mensagem completo
                         ,pr_inenvio                IN TBSPB_MSG_XML.INENVIO%TYPE DEFAULT 0           --> Indicador de mensagem a ser enviada para o JDSPB (0=N�o Enviar, 1=Enviar)
                         ,pr_nrdconta               IN CRAPASS.NRDCONTA%TYPE                          --> Numero da conta/dv do associado
                         ,pr_cdcooper               IN CRAPASS.CDCOOPER%TYPE                          --> Codigo que identifica a Cooperativa
                         ,pr_cdproduto              IN TBCC_PRODUTO.CDPRODUTO%TYPE                    --> Codigo do produto de abertura de conta
                         ,pr_dsobservacao           IN TBSPB_MSG_XML.DSOBSERVACAO%TYPE DEFAULT NULL   --> Campo utilizado pelo sistema para armazenar observacoes, ex. Reprocesso
                         ,pr_nrseq_mensagem_xml    OUT TBSPB_MSG_XML.NRSEQ_MENSAGEM_XML%TYPE              --> Nr.sequencial do XML da mensagem
                         ,pr_dscritic              OUT VARCHAR2
                         ,pr_des_erro              OUT VARCHAR2
                         ) IS
    /* .............................................................................
    Programa: pc_grava_XML
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Marcelo Telles Coelho - Mouts
    Data    : 10/07/2018                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir na tabela TBSPB_MSG_XML
                Constru�do no Projeeto 475

    Alteracoes:
    ............................................................................. */
    --Variaveis de Excecao
    vr_exc_erro               EXCEPTION;

    -- Variaveis de erro
    vr_dscritic               VARCHAR2(1000);

  BEGIN -- inicio pc_grava_XML
    pr_des_erro := 'OK';
    --
    -- Incluir registro de XML
    BEGIN
      INSERT INTO tbspb_msg_xml
             (nrseq_mensagem_xml
             ,inorigem_mensagem
             ,nmmensagem
             ,dsxml_mensagem
             ,dsxml_completo
             ,dhmensagem
             ,inenvio
             ,dsobservacao
             )
      VALUES (NULL                 -- nrseq_mensagem_xml
             ,NULL                 -- inorigem_mensagem
             ,pr_nmmensagem        -- nmmensagem
             ,pr_dsxml_mensagem    -- dsxml_mensagem
             ,pr_dsxml_completo    -- dsxml_completo
             ,pr_dhmensagem        -- dhmensagem
             ,pr_inenvio           -- inenvio
             ,pr_dsobservacao      -- dsobservacao
             )
      RETURNING nrseq_mensagem_xml
           INTO pr_nrseq_mensagem_xml;
    EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao incluir TBSPB_MSG_XML - '||sqlerrm;
      RAISE vr_exc_erro;
    END;
    --
    IF pr_inenvio = 1 THEN
      --
      -- Incluir registro de consumo de mensagem a ser transmitida pelo barramento SOA
      BEGIN
        INSERT INTO tb_consumo_barramento
               (nrseq_consumo
               ,nrseq_mensagem
               ,nrdconta
               ,cdcooper
               ,cdproduto
               ,dstipo_envento
               ,dssubtipo_evendto
               ,dssistema_destino
               ,dstipo_operacao
               ,dhtimestamp_operacao
               ,inem_processamento
               ,inStatus
               ,dhtimestamp_sincronismo
               ,dserro
               ,nrtentativas_envio_soa
               ,dsxml_completo)
        VALUES (NULL                  -- nrseq_consumo
               ,pr_nrseq_mensagem_xml -- nrseq_mensagem
               ,pr_nrdconta           -- nrdconta
               ,pr_cdcooper           -- cdcooper
               ,pr_cdproduto          -- cdproduto
               ,'ENVIOSMP'            -- dstipo_envento
               ,'ENVIO'               -- dssubtipo_evendto
               ,'JD'                  -- dssistema_destino
               ,'INSERT'              -- dstipo_operacao
               ,SYSDATE               -- dhtimestamp_operacao
               ,NULL                  -- inem_processamento
               ,NULL                  -- inStatus
               ,NULL                  -- dhtimestamp_sincronismo
               ,NULL                  -- dserro
               ,NULL                  -- nrtentativas_envio_soa
               ,pr_dsxml_completo     -- dsxml_completo
               );
      EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao incluir TB_CONSUMO_BARRAMENTO - '||sqlerrm;
        RAISE vr_exc_erro;
      END;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na PC_GRAVA_XML - ' || SQLERRM;
      pr_des_erro := 'NOK';
  END pc_grava_XML;

  PROCEDURE pc_grava_trace_spb (pr_cdfase                 IN TBSPB_MSG_ENVIADA_FASE.CDFASE%TYPE                 --> Nr.fase de envio da mensagem
                               ,pr_idorigem               IN VARCHAR2 DEFAULT NULL                              --> Origem da mensagem (E=Enviada, R=Recebida)
                               ,pr_nmmensagem             IN TBSPB_MSG_ENVIADA.NMMENSAGEM%TYPE                  --> Nome da mensagem enviada
                               ,pr_nrcontrole             IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Institui��o Financeira
                               ,pr_nrcontrole_str_pag     IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Institui��o Financeira de destino
                               ,pr_nrcontrole_dev_or      IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Instituicao Financeira Devolu��o ou origem
                               ,pr_dhmensagem             IN TBSPB_MSG_ENVIADA.DHMENSAGEM%TYPE                  --> Data/Hora de processamento da mensagem
                               ,pr_insituacao             IN TBSPB_MSG_ENVIADA_FASE.INSITUACAO%TYPE             --> Situa��o do envio da mensagem
                               ,pr_dsxml_mensagem         IN TBSPB_MSG_XML.DSXML_MENSAGEM%TYPE                  --> XML descriptografado da mensagem limitado a 4000
                               ,pr_dsxml_completo         IN TBSPB_MSG_XML.DSXML_COMPLETO%TYPE                  --> XML descriptografado da mensagem completo
                               ,pr_nrseq_mensagem_xml     IN TBSPB_MSG_XML.NRSEQ_MENSAGEM_XML%TYPE DEFAULT NULL --> Nr.sequencial do XML da mensagem
                               ,pr_inenvio                IN TBSPB_MSG_XML.INENVIO%TYPE DEFAULT 0               --> Indicador de mensagem a ser enviada para o JDSPB (0=N�o Enviar, 1=Enviar)
                               ,pc_dhdthr_bc              IN TBSPB_MSG_RECEBIDA_FASE.DHDTHR_BC%TYPE DEFAULT NULL -- Data/Hora de postagem da mensagem pelo BACEN
                               ,pr_nrdconta               IN CRAPASS.NRDCONTA%TYPE                              --> Numero da conta/dv do associado
                               ,pr_cdcooper               IN CRAPASS.CDCOOPER%TYPE                              --> Codigo que identifica a Cooperativa
                               ,pr_cdproduto              IN TBCC_PRODUTO.CDPRODUTO%TYPE                        --> Codigo do produto de abertura de conta
                               ,pr_nrseq_mensagem        OUT TBSPB_MSG_ENVIADA.NRSEQ_MENSAGEM%TYPE              --> Nr.sequencial de mensagem
                               ,pr_nrseq_mensagem_fase   OUT TBSPB_MSG_ENVIADA_FASE.NRSEQ_MENSAGEM_FASE%TYPE    --> Nr.sequencial de fase da mensagem
                               ,pr_dscritic              OUT VARCHAR2
                               ,pr_des_erro              OUT VARCHAR2
                               ) IS
    /* .............................................................................
    Programa: pc_grava_trace_spb
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Marcelo Telles Coelho - Mouts
    Data    : 10/07/2018                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar as informa��es para o trace das mensagens enviadas e recebidas do JDSPB
                Constru�do no Projeeto 475
    Alteracoes:
    ............................................................................. */
    -- Buscar registro nas tabelas de mensagem
    CURSOR cr_busca_fase (pr_cdfase IN TBSPB_FASE_MENSAGEM.CDFASE%TYPE) IS
    SELECT *
      FROM tbspb_fase_mensagem
     WHERE cdfase = pr_cdfase;
    rw_busca_fase cr_busca_fase%ROWTYPE;

    CURSOR cr_busca_msg (pr_nrcontrole_if IN tbspb_msg_enviada.nrcontrole_IF%TYPE) IS
    SELECT 'E' idorigem
          ,nrseq_mensagem
          ,nmmensagem
      FROM tbspb_msg_enviada a
     WHERE nrcontrole_if = pr_nrcontrole_if
    UNION
    SELECT 'R' idorigem
          ,nrseq_mensagem
          ,nmmensagem
      FROM tbspb_msg_recebida b
     WHERE nrcontrole_str_pag = pr_nrcontrole_if;
    rw_busca_msg cr_busca_msg%ROWTYPE;

    -- Buscar registro na tabela de envio
    CURSOR cr_busca_envio_fase (pr_nrseq_mensagem IN tbspb_msg_enviada_fase.nrseq_mensagem%TYPE
                               ,pr_cdfase         IN tbspb_msg_enviada_fase.cdfase%TYPE) IS
    SELECT *
      FROM tbspb_msg_enviada_fase
     WHERE nrseq_mensagem = pr_nrseq_mensagem
       AND cdfase         = pr_cdfase;
    rw_busca_envio_fase cr_busca_envio_fase%ROWTYPE;

    -- Buscar registro na tabela de envio
    CURSOR cr_busca_recebido_fase (pr_nrseq_mensagem IN tbspb_msg_recebida_fase.nrseq_mensagem%TYPE
                                  ,pr_cdfase         IN tbspb_msg_recebida_fase.cdfase%TYPE) IS
    SELECT *
      FROM tbspb_msg_recebida_fase
     WHERE nrseq_mensagem = pr_nrseq_mensagem
       AND cdfase         = pr_cdfase;
    rw_busca_recebido_fase cr_busca_recebido_fase%ROWTYPE;

    -- Buscar nome mensagem convertida
    CURSOR cr_busca_convertida (pr_nmmensagem IN tbspb_conversao_mensagem.nmmensagem%TYPE) IS
    SELECT *
      FROM tbspb_conversao_mensagem
     WHERE nmmensagem = pr_nmmensagem;
    rw_busca_convertida cr_busca_convertida%ROWTYPE;

    --Variaveis de Excecao
    vr_exc_erro               EXCEPTION;

    -- Variaveis de erro
    vr_dscritic               VARCHAR2(1000);
    vr_des_erro               VARCHAR2(1000);

    --Variaveis de Trabalho
    vr_inexiste_mensagem      VARCHAR2(01);
    vr_inexiste_mensagem_fase VARCHAR2(01);
    vr_cdcooper               CRAPCOP.CDCOOPER%TYPE;
    vr_nrseq_mensagem_xml     TBSPB_MSG_XML.NRSEQ_MENSAGEM_XML%TYPE;

  BEGIN -- Inicio pc_grava_trace_spb
    pr_des_erro               := 'OK';
    vr_inexiste_mensagem      := 'N';
    vr_inexiste_mensagem_fase := 'N';
    --
    -- Verifica se a fase do parametro est� cadastrada
    OPEN cr_busca_fase (pr_cdfase => pr_cdfase);
    --
    FETCH cr_busca_fase INTO rw_busca_fase;
    --Se nao encontrar
    IF cr_busca_fase%NOTFOUND THEN
      vr_dscritic := 'Fase da mensagem n�o encontrada';
      RAISE vr_exc_erro;
    END IF;
    --
    CLOSE cr_busca_fase;
    --
    -- Verifica se existe registro nas tabelas de mensagem
    OPEN cr_busca_msg (pr_nrcontrole_if => NVL(pr_nrcontrole,pr_nrcontrole_str_pag));
    --
    FETCH cr_busca_msg INTO rw_busca_msg;
    --Se nao encontrar
    IF cr_busca_msg%FOUND THEN
      vr_inexiste_mensagem := 'S';
    ELSE
      IF pr_idorigem IS NOT NULL THEN
        rw_busca_msg.idorigem := pr_idorigem;
      ELSE
        rw_busca_msg.idorigem := fn_retorna_inorigem (pr_nrcontrole_if => pr_nrcontrole);
      END IF;
    END IF;
    --
    CLOSE cr_busca_msg;
    --
    IF rw_busca_msg.idorigem = 'E' THEN
      IF vr_inexiste_mensagem = 'N' THEN
        -- Incluir registro de Envio
        BEGIN
          INSERT INTO tbspb_msg_enviada
                 (nrseq_mensagem
                 ,nmmensagem
                 ,nmmensagem_convertida
                 ,nrcontrole_if
                 ,nrcontrole_str_pag
                 ,nrcontrole_str_pag_rec
                 ,dhmensagem
                 ,nrdconta
                 ,cdcooper
                 )
          VALUES (NULL                      -- nrseq_mensagem
                 ,pr_nmmensagem             -- nmmensagem
                 ,NULL                      -- nmmensagem_convertida
                 ,pr_nrcontrole             -- nrcontrole_if
                 ,pr_nrcontrole_str_pag     -- nrcontrole_str_pag
                 ,pr_nrcontrole_dev_or      -- nrcontrole_str_pag_rec
                 ,SYSDATE                   -- dhmensagem
                 ,pr_nrdconta               -- nrdconta
                 ,pr_cdcooper               -- cdcooper
                 )
          RETURNING nrseq_mensagem INTO rw_busca_msg.nrseq_mensagem;
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          -- Tratamento necess�rio para os casos de processamento de R0 e R1 no mesmo momento.
          -- Trata-se de mensagem redigida na cabine, onde a JD encaminha para o Legado somente quando a mesma eh liquidada.
          -- Ao liquidar, a mensagem eh enviada para o BACEN e recebemos logo em seguida retorno R1.
          OPEN cr_busca_msg (pr_nrcontrole_if => NVL(pr_nrcontrole,pr_nrcontrole_str_pag));
          --
          FETCH cr_busca_msg INTO rw_busca_msg;
          --Se nao encontrar
          IF cr_busca_msg%FOUND THEN
            vr_inexiste_mensagem := 'S';
          END IF;
          --
          CLOSE cr_busca_msg;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir TBSPB_MSG_ENVIADA - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
      END IF;
      --
      IF vr_inexiste_mensagem = 'S' THEN
        -- Alterar registro de Envio
        BEGIN
          UPDATE tbspb_msg_enviada
             SET nrcontrole_str_pag     = NVL(pr_nrcontrole_str_pag,nrcontrole_str_pag)
                ,nrcontrole_str_pag_rec = NVL(pr_nrcontrole_dev_or,nrcontrole_str_pag_rec)
                ,nrdconta               = NVL(pr_nrdconta,nrdconta)
                ,cdcooper               = NVL(pr_cdcooper,cdcooper)
                ,nmmensagem             = CASE
                                          WHEN pr_cdfase in (10, 15) THEN
                                            pr_nmmensagem
                                          ELSE
                                            nmmensagem
                                          END
           WHERE nrseq_mensagem = rw_busca_msg.nrseq_mensagem;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar TBSPB_MSG_ENVIADA - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
      END IF;
      --
      -- Verifica se existe registro na tabela de envio de fases
      OPEN cr_busca_envio_fase (pr_nrseq_mensagem => rw_busca_msg.nrseq_mensagem
                               ,pr_cdfase         => pr_cdfase);
      --
      FETCH cr_busca_envio_fase INTO rw_busca_envio_fase;
      --Se nao encontrar
      IF cr_busca_envio_fase%FOUND THEN
        vr_inexiste_mensagem_fase := 'S';
        pr_nrseq_mensagem_fase    := rw_busca_envio_fase.nrseq_mensagem_fase;
      ELSE
        vr_nrseq_mensagem_xml := NULL;
      END IF;
      --
      CLOSE cr_busca_envio_fase;
      --
      vr_nrseq_mensagem_xml := pr_nrseq_mensagem_xml;
      --
      IF pr_dsxml_mensagem IS NOT NULL
      AND vr_nrseq_mensagem_xml IS NULL
      THEN
        SSPB0003.pc_grava_XML(pr_nmmensagem         => pr_nmmensagem
                             ,pr_inorigem_mensagem  => rw_busca_msg.idorigem
                             ,pr_dhmensagem         => pr_dhmensagem
                             ,pr_dsxml_mensagem     => pr_dsxml_mensagem
                             ,pr_dsxml_completo     => pr_dsxml_completo
                             ,pr_inenvio            => pr_inenvio
                             ,pr_nrdconta           => pr_nrdconta
                             ,pr_cdcooper           => pr_cdcooper
                             ,pr_cdproduto          => pr_cdproduto
                             ,pr_nrseq_mensagem_xml => vr_nrseq_mensagem_xml
                             ,pr_dscritic           => vr_dscritic
                             ,pr_des_erro           => vr_des_erro
                             );
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --
      IF vr_inexiste_mensagem_fase = 'N' THEN
        -- Incluir registro de Envio de fase
        BEGIN
          INSERT INTO tbspb_msg_enviada_fase
                 (nrseq_mensagem_fase
                 ,nrseq_mensagem
                 ,cdfase
                 ,nmmensagem
                 ,dhmensagem
                 ,insituacao
                 ,nrseq_mensagem_xml
                 )
          VALUES (NULL                        -- nrseq_mensagem_fase
                 ,rw_busca_msg.nrseq_mensagem -- nrseq_mensagem
                 ,pr_cdfase                   -- cdfase
                 ,pr_nmmensagem               -- nmmensagem
                 ,pr_dhmensagem               -- dhmensagem
                 ,pr_insituacao               -- insituacao
                 ,vr_nrseq_mensagem_xml       -- nrseq_mensagem_xml
                 )
          RETURNING nrseq_mensagem_fase INTO rw_busca_envio_fase.nrseq_mensagem_fase;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir TBSPB_MSG_ENVIADA_FASE - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
      ELSE
        -- Alterar registro de Envio de fase
        BEGIN
          UPDATE tbspb_msg_enviada_fase
             SET insituacao             = pr_insituacao
                ,dhmensagem             = pr_dhmensagem
                ,nrseq_mensagem_xml     = rw_busca_envio_fase.nrseq_mensagem_xml
           WHERE nrseq_mensagem         = rw_busca_msg.nrseq_mensagem
             AND nrseq_mensagem_fase    = rw_busca_envio_fase.nrseq_mensagem_fase;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar TBSPB_MSG_ENVIADA_FASE - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
      END IF;
      --
      pr_nrseq_mensagem      := rw_busca_msg.nrseq_mensagem;
      pr_nrseq_mensagem_fase := rw_busca_envio_fase.nrseq_mensagem_fase;
      --
      IF rw_busca_fase.idconversao = 1 THEN -- Fase de Convers�o de mensagem
        -- Buscar nome mensagem convertida
        OPEN cr_busca_convertida (pr_nmmensagem => rw_busca_msg.nmmensagem);
        --
        FETCH cr_busca_convertida INTO rw_busca_convertida;
        --Se nao encontrar
        IF cr_busca_convertida%NOTFOUND THEN
          CLOSE cr_busca_convertida;
          vr_dscritic := 'Nome mensagem convertida n�o encontrada';
          RAISE vr_exc_erro;
        END IF;
        --
        CLOSE cr_busca_convertida;
        --
        -- Acertar nome da mensagem no registro de Envio
        BEGIN
          UPDATE tbspb_msg_enviada
             SET nmmensagem_convertida = rw_busca_msg.nmmensagem
                ,nmmensagem            = rw_busca_convertida.nmmensagem_convertida
           WHERE nrseq_mensagem        = rw_busca_msg.nrseq_mensagem;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar TBSPB_MSG_ENVIADA_FASE - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
        -- Acertar nome da mensagem na TBSPB_MENSAGEM
        BEGIN
          UPDATE tbspb_mensagem
             SET nmevento = rw_busca_convertida.nmmensagem_convertida
           WHERE nrctrlif = pr_nrcontrole
          RETURNING cdcooper INTO vr_cdcooper;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar TBSPB_MENSAGEM - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
        -- Acertar nome da mensagem na CRAPLMT
        BEGIN
          UPDATE craplmt
             SET nmevento = rw_busca_convertida.nmmensagem_convertida
           WHERE cdcooper = vr_cdcooper
             AND nrctrlif = pr_nrcontrole
             AND nmevento = rw_busca_msg.nmmensagem;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar CRAPLMT - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
      END IF;
    ELSIF rw_busca_msg.idorigem = 'R' THEN
      IF vr_inexiste_mensagem = 'N' THEN
        -- Incluir registro de recebimento
        BEGIN
          INSERT INTO tbspb_msg_recebida
                 (nrseq_mensagem
                 ,nmmensagem
                 ,nrcontrole_str_pag
                 ,nrcontrole_if_env
                 ,dhmensagem
                 ,nrdconta
                 ,cdcooper
                 )
          VALUES (NULL                                     -- nrseq_mensagem
                 ,pr_nmmensagem                            -- nmmensagem
                 ,NVL(pr_nrcontrole,pr_nrcontrole_str_pag) -- nrcontrole_str_pag
                 ,pr_nrcontrole_dev_or                     -- nrcontrole_if_env
                 ,SYSDATE                                  -- dhmensagem
                 ,pr_nrdconta                              -- nrdconta
                 ,pr_cdcooper                              -- cdcooper
                 )
          RETURNING nrseq_mensagem INTO rw_busca_msg.nrseq_mensagem;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir TBSPB_MSG_RECEBIDA - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
      ELSE
        -- Alterar registro de recebido
        BEGIN
          UPDATE tbspb_msg_recebida
             SET nrcontrole_if_env  = NVL(pr_nrcontrole_dev_or,nrcontrole_if_env)
                ,nrdconta           = NVL(pr_nrdconta,nrdconta)
                ,cdcooper           = NVL(pr_cdcooper,cdcooper)
                ,nmmensagem         = CASE
                                      WHEN nmmensagem LIKE 'COA%'
                                        OR nmmensagem LIKE 'COD%'
                                        OR nmmensagem LIKE 'HORA%'
                                      THEN
                                        pr_nmmensagem
                                      ELSE
                                        nmmensagem
                                      END
           WHERE nrseq_mensagem = rw_busca_msg.nrseq_mensagem;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar TBSPB_MSG_RECEBIDA - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
      END IF;
      --
      IF pr_nmmensagem LIKE '%R2'
      AND pc_dhdthr_bc IS NOT NULL
      THEN
        -- Verificar se existe a fase 100 - Hora BACEN
        OPEN cr_busca_recebido_fase (pr_nrseq_mensagem => rw_busca_msg.nrseq_mensagem
                                    ,pr_cdfase         => 100);
        --
        FETCH cr_busca_recebido_fase INTO rw_busca_recebido_fase;
        --Se nao encontrar incluir a fase
        IF cr_busca_recebido_fase%NOTFOUND THEN
          BEGIN
            INSERT INTO tbspb_msg_recebida_fase
                   (nrseq_mensagem_fase
                   ,nrseq_mensagem
                   ,cdfase
                   ,nmmensagem
                   ,dhmensagem
                   ,dhdthr_bc
                   ,insituacao
                   ,nrseq_mensagem_xml
                   )
            VALUES (NULL                         -- nrseq_mensagem_fase
                   ,rw_busca_msg.nrseq_mensagem  -- nrseq_mensagem
                   ,100                          -- cdfase
                   ,'HORA BACEN'                 -- nmmensagem
                   ,pc_dhdthr_bc                 -- dhmensagem
                   ,pc_dhdthr_bc                 -- dhdthr_bc
                   ,'OK'                         -- insituacao
                   ,NULL                         -- nrseq_mensagem_xml
                   );
          EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao incluir TBSPB_MSG_RECEBIDA_FASE - Fase 100 - '||sqlerrm;
            RAISE vr_exc_erro;
          END;
        END IF;
        --
        CLOSE cr_busca_recebido_fase;
      END IF;
      --
      -- Verifica se existe registro na tabela de recebido de fases
      OPEN cr_busca_recebido_fase (pr_nrseq_mensagem => rw_busca_msg.nrseq_mensagem
                                  ,pr_cdfase         => pr_cdfase);
      --
      FETCH cr_busca_recebido_fase INTO rw_busca_recebido_fase;
      --Se nao encontrar
      IF cr_busca_recebido_fase%FOUND THEN
        vr_inexiste_mensagem_fase := 'S';
      ELSE
        rw_busca_recebido_fase.nrseq_mensagem_xml := NULL;
      END IF;
      --
      CLOSE cr_busca_recebido_fase;
      --
      vr_nrseq_mensagem_xml := pr_nrseq_mensagem_xml;
      --
      IF pr_dsxml_mensagem IS NOT NULL
      AND vr_nrseq_mensagem_xml IS NULL
      THEN
        SSPB0003.pc_grava_XML(pr_nmmensagem         => pr_nmmensagem
                             ,pr_inorigem_mensagem  => rw_busca_msg.idorigem
                             ,pr_dhmensagem         => pr_dhmensagem
                             ,pr_dsxml_mensagem     => pr_dsxml_mensagem
                             ,pr_dsxml_completo     => pr_dsxml_completo
                             ,pr_inenvio            => pr_inenvio
                             ,pr_nrdconta           => pr_nrdconta
                             ,pr_cdcooper           => pr_cdcooper
                             ,pr_cdproduto          => pr_cdproduto
                             ,pr_nrseq_mensagem_xml => vr_nrseq_mensagem_xml
                             ,pr_dscritic           => vr_dscritic
                             ,pr_des_erro           => vr_des_erro
                             );
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --
      IF vr_inexiste_mensagem_fase = 'N' THEN
        -- Incluir registro de Recebido de fase
        BEGIN
          INSERT INTO tbspb_msg_recebida_fase
                 (nrseq_mensagem_fase
                 ,nrseq_mensagem
                 ,cdfase
                 ,nmmensagem
                 ,dhmensagem
                 ,dhdthr_bc
                 ,insituacao
                 ,nrseq_mensagem_xml
                 )
          VALUES (NULL                         -- nrseq_mensagem_fase
                 ,rw_busca_msg.nrseq_mensagem  -- nrseq_mensagem
                 ,pr_cdfase                    -- cdfase
                 ,pr_nmmensagem                -- nmmensagem
                 ,pr_dhmensagem                -- dhmensagem
                 ,pc_dhdthr_bc                 -- dhdthr_bc
                 ,pr_insituacao                -- insituacao
                 ,vr_nrseq_mensagem_xml        -- nrseq_mensagem_xml
                 )
          RETURNING nrseq_mensagem_fase INTO rw_busca_recebido_fase.nrseq_mensagem_fase;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao incluir TBSPB_MSG_RECEBIDA_FASE - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
      ELSE
        -- Alterar registro de Recibo de fase
        BEGIN
          UPDATE tbspb_msg_recebida_fase
             SET insituacao             = pr_insituacao
                ,nrseq_mensagem_xml     = rw_busca_recebido_fase.nrseq_mensagem_xml
           WHERE nrseq_mensagem         = rw_busca_recebido_fase.nrseq_mensagem
             AND nrseq_mensagem_fase    = rw_busca_recebido_fase.nrseq_mensagem_fase;
        EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar TBSPB_MSG_RECEBIDA_FASE - '||sqlerrm;
          RAISE vr_exc_erro;
        END;
      END IF;
      --
      pr_nrseq_mensagem      := rw_busca_msg.nrseq_mensagem;
      pr_nrseq_mensagem_fase := rw_busca_recebido_fase.nrseq_mensagem_fase;
      --
    ELSE
      vr_dscritic := 'Origem da mensagem inv�lida - '||NVL(rw_busca_msg.idorigem,'X');
      RAISE vr_exc_erro;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na PC_GRAVA_TRACE_SPB - ' || SQLERRM;
      pr_des_erro := 'NOK';
  END pc_grava_trace_spb;

  PROCEDURE pc_acerta_nmmensagem(pr_nmmensagem             IN TBSPB_MSG_ENVIADA.NMMENSAGEM%TYPE                  --> Nome da mensagem enviada
                                ,pr_nmmensagem_OLD         IN TBSPB_MSG_ENVIADA.NMMENSAGEM%TYPE                  --> Nome da mensagem a ser convertida
                                ,pr_nrcontrole_if          IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Institui��o Financeira
                                ,pr_insituacao             IN VARCHAR2                             DEFAULT 'OK'  --> Situa��o de mensagem
                                ,pr_nrseq_mensagem_xml     IN TBSPB_MSG_XML.NRSEQ_MENSAGEM_XML%TYPE              --> Nr.sequencial do XML da mensagem
                                ,pr_dscritic              OUT VARCHAR2
                                ,pr_des_erro              OUT VARCHAR2
                                ) IS
    /* .............................................................................
    Programa: pc_acerta_nmmensagem
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Marcelo Telles Coelho - Mouts
    Data    : 10/07/2018                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para corrigir o nome da mensagem nas tabelas SSPB_MSG_ENVIADA e SSPB_MSG_ENVIADA_FASE
                O nome da mensagem foi criado com MSG_TEMPORARIA
                Isto � necess�rio, pois no CXON0020 os momento de cria��o das fases 10 e 20 acontece antes da gera��o do XML.
                Este acerto ser� disparado pelo SSPB0001.pc_proc_envia_tec_ted.
                Constru�do no Projeeto 475

    Alteracoes:
    ............................................................................. */
    --Variaveis de Excecao
    vr_exc_erro               EXCEPTION;

    -- Variaveis de erro
    vr_dscritic               VARCHAR2(1000);

    --Variaveis de Trabalho
    vr_nrseq_mensagem         TBSPB_MSG_ENVIADA.NRSEQ_MENSAGEM%TYPE;

  BEGIN -- inicio pc_acerta_nmmensagem
    pr_des_erro := 'OK';
    --
    BEGIN
      UPDATE tbspb_msg_enviada
         SET nmmensagem    = pr_nmmensagem
       WHERE nrcontrole_if = pr_nrcontrole_if
         AND nmmensagem    = pr_nmmensagem_OLD
      RETURNING nrseq_mensagem INTO vr_nrseq_mensagem;
    EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao alterar TBSPB_MSG_ENVIADA - '||sqlerrm;
      RAISE vr_exc_erro;
    END;
    --
    BEGIN
      UPDATE tbspb_msg_enviada_fase
         SET nmmensagem         = pr_nmmensagem
            ,nrseq_mensagem_xml = NVL(pr_nrseq_mensagem_xml,nrseq_mensagem_xml)
            ,insituacao         = pr_insituacao
       WHERE nrseq_mensagem     = vr_nrseq_mensagem
         AND nmmensagem         = pr_nmmensagem_OLD;
    EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao alterar TBSPB_MSG_ENVIADA_FASE - '||sqlerrm;
      RAISE vr_exc_erro;
    END;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na PC_ACERTA_NMMENSAGEM - ' || SQLERRM;
      pr_des_erro := 'NOK';
  END pc_acerta_nmmensagem;

  -- Rotina para retornar a origem da mensagem (Enviada ou Recebida)
  FUNCTION fn_retorna_inorigem (pr_nrcontrole_if          IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE               --> Nr.controle da Institui��o Financeira
                               ) RETURN VARCHAR2 IS
    -- Marcelo Telles Coelho - Mouts - Projeto 475
    --
    vr_inorigem_mensagem VARCHAR2(01);
    vr_lixo              NUMBER;
  BEGIN
    IF pr_nrcontrole_if IS NOT NULL THEN
      BEGIN
        vr_lixo := TO_NUMBER(SUBSTR(pr_nrcontrole_if,1,1));
        vr_inorigem_mensagem := 'E';
      EXCEPTION
      WHEN OTHERS THEN
        vr_inorigem_mensagem := 'R';
      END;
    ELSE
      vr_inorigem_mensagem := 'R';
    END IF;
    --
    RETURN vr_inorigem_mensagem;
  END fn_retorna_inorigem;

  -- Rotina para verificar se uma mensagem de devolu��o j� foi processada
  FUNCTION fn_ver_msg_processada (pr_nrcontrole_str_pag IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE                 --> Nr.controle da Instituicao Financeira
                                  ) RETURN BOOLEAN IS
    -- Marcelo Telles Coelho - Mouts - Projeto 475
    --
    CURSOR cr_ver_msg_processada (pr_nrcontrole_str_pag IN TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE) IS
    SELECT 1 idmsg_processada
      FROM tbspb_msg_enviada a
          ,tbspb_msg_enviada_fase b
     WHERE a.nrcontrole_str_pag = pr_nrcontrole_str_pag
       AND b.nrseq_mensagem     = a.nrseq_mensagem
       AND b.cdfase             = 60 -- Cancelamento de mensagem na IF destino - R2
    UNION
    SELECT 1 idmsg_processada
      FROM tbspb_msg_enviada a
          ,tbspb_msg_enviada_fase b
     WHERE a.nrcontrole_if      = pr_nrcontrole_str_pag
       AND b.nrseq_mensagem     = a.nrseq_mensagem
       AND b.cdfase             = 43 -- Rejei��o autom�tica - Cancelamento
    UNION
    SELECT 1 idmsg_processada
      FROM tbspb_msg_recebida l
          ,tbspb_msg_recebida_fase m
     WHERE l.nrcontrole_str_pag = pr_nrcontrole_str_pag
       AND m.nrseq_mensagem     = l.nrseq_mensagem
       AND m.cdfase             = 115; -- Mensagem de cr�dito recebida pelo Ailos - R2;
    rw_ver_msg_processada cr_ver_msg_processada%ROWTYPE;

    vr_msg_processada BOOLEAN := FALSE;

  BEGIN
    -- Verifica se a mensagem de devolu��o j� foi processada
    OPEN cr_ver_msg_processada (pr_nrcontrole_str_pag => pr_nrcontrole_str_pag);
    --
    FETCH cr_ver_msg_processada INTO rw_ver_msg_processada;
    --Se nao encontrar
    IF cr_ver_msg_processada%FOUND THEN
      vr_msg_processada := TRUE;
    ELSE
      vr_msg_processada := FALSE;
    END IF;
    --
    CLOSE cr_ver_msg_processada;
    --
    RETURN vr_msg_processada;
    --
  END fn_ver_msg_processada;

  PROCEDURE pc_acerto_recebida(pr_dscritic          OUT VARCHAR2
                              ) IS
    vr_exc_saida EXCEPTION;
    vr_nrseq_mensagem NUMBER;
  BEGIN
    FOR r1 IN (SELECT COUNT(*)
                     ,a.nrcontrole_str_pag
                 FROM tbspb_msg_recebida a
                WHERE trunc(a.dhmensagem)   = TRUNC(SYSDATE)
                  AND a.nrcontrole_str_pag IS NOT NULL
                GROUP BY a.nrcontrole_str_pag
               HAVING COUNT(*) > 1)
    LOOP
      vr_nrseq_mensagem := NULL;
      --
      FOR r2 IN (SELECT CASE
                        WHEN nmmensagem LIKE 'COD%'
                          OR nmmensagem LIKE 'COA%'
                          OR nmmensagem LIKE 'HORA%'
                        THEN
                          0
                        ELSE
                          1
                        END
                       ,a.*
                   FROM tbspb_msg_recebida a
                  WHERE trunc(a.dhmensagem)  = TRUNC(SYSDATE)
                    AND a.nrcontrole_str_pag = r1.nrcontrole_str_pag
                  ORDER BY 1)
      LOOP
        IF r2.nmmensagem LIKE 'COD%'
        OR r2.nmmensagem LIKE 'COA%'
        OR r2.nmmensagem LIKE 'HORA%'
        THEN
          vr_nrseq_mensagem := r2.nrseq_mensagem;
        ELSE
          BEGIN
            UPDATE tbspb_msg_recebida_fase
               SET nrseq_mensagem = r2.nrseq_mensagem
             WHERE nrseq_mensagem = vr_nrseq_mensagem;
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              -- N�o precisa atualizar pois a fase j� foi criada anteriormente.
              NULL;
            WHEN OTHERS THEN
              pr_dscritic := 'Erro UPDATE tbspb_msg_recebida_fase = '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          --
          BEGIN
            DELETE tbspb_msg_recebida
             WHERE nrseq_mensagem = vr_nrseq_mensagem;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro DELETE tbspb_msg_recebida = '||sqlerrm;
              RAISE vr_exc_saida;
          END;
        END IF;
      END LOOP;
    END LOOP;
    --
    FOR r01 IN (SELECT COUNT(*)
                      ,a.nrseq_mensagem
                      ,b.cdfase
                  FROM tbspb_msg_recebida a
                      ,tbspb_msg_recebida_fase b
                 WHERE trunc(a.dhmensagem)   = TRUNC(SYSDATE)
                   AND a.nrcontrole_str_pag IS NOT NULL
                   AND b.nrseq_mensagem      = a.nrseq_mensagem
                 GROUP BY a.nrseq_mensagem
                      ,b.cdfase
                HAVING COUNT(*) > 1)
    LOOP
      FOR r02 IN (SELECT a.ROWID recebida_fase_rowid
                    FROM tbspb_msg_recebida_fase a
                   WHERE a.nrseq_mensagem = r01.nrseq_mensagem
                     AND a.cdfase         = r01.cdfase
                   ORDER BY a.nrseq_mensagem_fase DESC)
      LOOP
        DELETE tbspb_msg_recebida_fase
         WHERE ROWID = r02.recebida_fase_rowid;
        EXIT;
      END LOOP;
    END LOOP;
  EXCEPTION
  WHEN vr_exc_saida THEN
    NULL;
  END pc_acerto_recebida;

END SSPB0003;
/
