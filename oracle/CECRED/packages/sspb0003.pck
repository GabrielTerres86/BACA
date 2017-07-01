CREATE OR REPLACE PACKAGE CECRED.SSPB0003 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: SSPB0003
  --    Autor   : Douglas Quisinski
  --    Data    : Abril/2017                      Ultima Atualizacao:   /  /    
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Gravar as mensagens de TED em uma nova estrutura, e armazenar as mensagens que 
  --                são devolvidas a cabine com rejeição
  --
  --    Alteracoes: 
  --    
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para gravar as mensagens de TED de forma genérica
  PROCEDURE pc_grava_mensagem_ted(pr_cdcooper   IN tbspb_mensagem.cdcooper%TYPE,   --> Cooperativa
                                  pr_nrctrlif   IN tbspb_mensagem.nrctrlif%TYPE,   --> Numero de controle
                                  pr_dtmensagem IN tbspb_mensagem.dtmensagem%TYPE, --> Data da mensagem
                                  pr_nmevento   IN tbspb_mensagem.nmevento%TYPE,   --> Evento
                                  pr_dsxml      IN tbspb_mensagem.dsxml%TYPE,      --> XML da mensagem
                                  pr_cdprograma IN crapprg.cdprogra%TYPE,          --> Programa que chamou
                                  pr_cdcritic   OUT crapcri.cdcritic%TYPE,         --> Codigo do erro
                                  pr_dscritic   OUT crapcri.dscritic%TYPE);        --> Mensagem do erro

  -- Rotina para gravar as mensagens de TED de rejeição que devolvemos ao Bancoob
  PROCEDURE pc_grava_msg_ted_rejeita(pr_cdcooper IN tbspb_trans_rejeitada.cdcooper%TYPE,                   --> Cooperativa
                                     pr_nrdconta IN VARCHAR2,                                              --> Conta
                                     pr_cdagenci IN tbspb_trans_rejeitada.cdagenci%TYPE,                   --> Agencia
                                     pr_nrdcaixa IN tbspb_trans_rejeitada.nrdcaixa%TYPE,                   --> Numero do Caixa
                                     pr_cdoperad IN tbspb_trans_rejeitada.cdoperad%TYPE,                   --> Operador
                                     pr_cdprogra IN tbspb_trans_rejeitada.cdprogra%TYPE,                   --> Programa que chamou
                                     pr_nmevento IN tbspb_trans_rejeitada.nmevento%TYPE,                   --> Evento
                                     pr_nrctrlif IN tbspb_trans_rejeitada.nrctrlif%TYPE,                   --> Numero de controle
                                     pr_vldocmto IN tbspb_trans_rejeitada.vldocmto%TYPE,                   --> Valor
                                     -- Dados de Origem da TED (Informações da Conta na CENTRAL)
                                     pr_cdbanco_origem   IN tbspb_trans_rejeitada.cdbanco_origem%TYPE,     --> Banco
                                     pr_cdagencia_origem IN tbspb_trans_rejeitada.cdagencia_origem%TYPE,   --> Agencia
                                     pr_nmtitular_origem IN tbspb_trans_rejeitada.nmtitular_origem%TYPE,   --> Nome do Titular
                                     pr_nrcpf_origem     IN tbspb_trans_rejeitada.nrcpf_origem%TYPE,       --> CPF do Titular
                                     -- Dados de Destino da TED (Informações da Conta em outra IF)
                                     pr_cdbanco_destino   IN tbspb_trans_rejeitada.cdbanco_destino%TYPE,   --> Banco
                                     pr_cdagencia_destino IN tbspb_trans_rejeitada.cdagencia_destino%TYPE, --> Agencia
                                     pr_nrconta_destino   IN VARCHAR2,                                     --> Conta
                                     pr_nmtitular_destino IN tbspb_trans_rejeitada.nmtitular_destino%TYPE, --> Nome do Titular
                                     pr_nrcpf_destino     IN tbspb_trans_rejeitada.nrcpf_destino%TYPE,     --> CPF do Titular
                                     -- Rejeição
                                     pr_dsmotivo_rejeicao IN tbspb_trans_rejeitada.dsmotivo_rejeicao%TYPE, --> Motivo da Rejeição
                                     pr_nrispbif          IN tbspb_trans_rejeitada.nrispbif%TYPE,          --> ISPB
                                     -- Erro
                                     pr_cdcritic OUT crapcri.cdcritic%TYPE,                                --> Codigo do Erro
                                     pr_dscritic OUT crapcri.dscritic%TYPE);                               --> Mensagem do Erro

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
  --                são devolvidas a cabine com rejeição
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
    Data    : 04/05/2017                        Ultima atualizacao:   /  /    
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar as mensagens de TED
    
    Alteracoes: 
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
        pr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - '
                       || pr_cdprograma || ' --> ' ||
                       'Erro na inclusao do mensagem de TED do SPB.' ||
                       ' Coop: ' || pr_cdcooper || 
                       ', Num Controle: ' || pr_nrctrlif || 
                       ', Evento: ' || pr_nmevento ||
                       ', Data Mensagem: ' || to_char(pr_dtmensagem, 'dd/mm/yyyy') ||
                       ', XML: ' || pr_dsxml ||
                       ', ERRO: ' || SQLERRM;
      
        pc_internal_exception(pr_cdcooper => pr_cdcooper,
                              pr_compleme => pr_dscritic);
      
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_cdprograma   => pr_cdprograma,
                                   pr_des_log      => pr_dscritic);
      
    END;
  END pc_grava_mensagem_ted;

  -- Rotina para gravar as mensagens de TED de rejeição que devolvemos ao Bancoob
  PROCEDURE pc_grava_msg_ted_rejeita(pr_cdcooper IN tbspb_trans_rejeitada.cdcooper%TYPE,                   --> Cooperativa
                                     pr_nrdconta IN VARCHAR2,                                              --> Conta
                                     pr_cdagenci IN tbspb_trans_rejeitada.cdagenci%TYPE,                   --> Agencia
                                     pr_nrdcaixa IN tbspb_trans_rejeitada.nrdcaixa%TYPE,                   --> Numero do Caixa
                                     pr_cdoperad IN tbspb_trans_rejeitada.cdoperad%TYPE,                   --> Operador
                                     pr_cdprogra IN tbspb_trans_rejeitada.cdprogra%TYPE,                   --> Programa que chamou
                                     pr_nmevento IN tbspb_trans_rejeitada.nmevento%TYPE,                   --> Evento
                                     pr_nrctrlif IN tbspb_trans_rejeitada.nrctrlif%TYPE,                   --> Numero de controle
                                     pr_vldocmto IN tbspb_trans_rejeitada.vldocmto%TYPE,                   --> Valor
                                     -- Dados de Origem da TED (Informações da Conta na CENTRAL)
                                     pr_cdbanco_origem   IN tbspb_trans_rejeitada.cdbanco_origem%TYPE,     --> Banco
                                     pr_cdagencia_origem IN tbspb_trans_rejeitada.cdagencia_origem%TYPE,   --> Agencia
                                     pr_nmtitular_origem IN tbspb_trans_rejeitada.nmtitular_origem%TYPE,   --> Nome do Titular
                                     pr_nrcpf_origem     IN tbspb_trans_rejeitada.nrcpf_origem%TYPE,       --> CPF do Titular
                                     -- Dados de Destino da TED (Informações da Conta em outra IF)
                                     pr_cdbanco_destino   IN tbspb_trans_rejeitada.cdbanco_destino%TYPE,   --> Banco
                                     pr_cdagencia_destino IN tbspb_trans_rejeitada.cdagencia_destino%TYPE, --> Agencia
                                     pr_nrconta_destino   IN VARCHAR2,                                     --> Conta
                                     pr_nmtitular_destino IN tbspb_trans_rejeitada.nmtitular_destino%TYPE, --> Nome do Titular
                                     pr_nrcpf_destino     IN tbspb_trans_rejeitada.nrcpf_destino%TYPE,     --> CPF do Titular
                                     -- Rejeição
                                     pr_dsmotivo_rejeicao IN tbspb_trans_rejeitada.dsmotivo_rejeicao%TYPE, --> Motivo da Rejeição
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
    Data    : 04/05/2017                        Ultima atualizacao:   /  /    
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar as mensagens de TED Rejeitada
    
    Alteracoes: 
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
        pr_dscritic := to_char(sysdate,'hh24:mi:ss')|| ' - '
                       || pr_cdprogra || ' --> ' ||
                       'Erro ao incluir mensagem de TED REJEITADA.' ||
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
                       ', # CECRED - Banco ' || pr_cdbanco_origem ||
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
      
        --Escrever No LOG
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_cdprograma   => pr_cdprogra,
                                   pr_des_log      => pr_dscritic);
      
    END;
  END pc_grava_msg_ted_rejeita;

END SSPB0003;
/
