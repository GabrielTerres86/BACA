CREATE OR REPLACE PACKAGE SOA.SOA_BLOQUEIO_JUDICIAL IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_BLOQUEIO_JUDICIAL
  --  Sistema  : Rotinas referentes ao WebService de Bloqueio Judicial
  --  Sigla    : BLQJ
  --  Autor    : Andrino Carlos de Souza Junior (Mouts)
  --  Data     : Dezembro - 2016.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de Bloqueio Judicial
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------
  
  -- Efetuar o recebimento das solicitacoes de consulta de conta
  PROCEDURE pc_recebe_solicitacao(pr_nrdocnpj_cop  IN  NUMBER,    -- CNPJ da cooperativa
                                  pr_nrcpfcnpj     IN  NUMBER,    -- CNPJ / CPF do réu
                                  pr_tppessoa      IN  VARCHAR2,  -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                                  pr_idordem       OUT NUMBER,    -- Sequencial do recebimento
                                  pr_cdcritic      OUT NUMBER,      -- Codigo da critica
                                  pr_dscritic      OUT VARCHAR2); -- Texto de erro/critica encontrada
  
  -- Efetuar o recebimento das solicitacoes de bloqueio e desbloqueio
  PROCEDURE pc_recebe_blq_desblq(pr_nrdocnpj_cop  IN  NUMBER    -- CNPJ da cooperativa
                                ,pr_nrcpfcnpj     IN  NUMBER    -- CNPJ / CPF do réu
                                ,pr_tppessoa      IN  VARCHAR2  -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                                ,pr_tpproduto     IN  VARCHAR2  -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                                ,pr_dsoficio      IN  VARCHAR2  -- Numero do oficio
                                ,pr_nrdconta      IN  NUMBER    -- Numero da conta
                                ,pr_cdagenci      IN  NUMBER    -- Codigo da agencia
                                ,pr_tpordem       IN  NUMBER    -- Tipo de Operacao (2-Bloqueio, 3-Desbloqueio)
                                ,pr_vlordem       IN  NUMBER    -- Valor do bloqueio
                                ,pr_dsprocesso    IN  VARCHAR2  -- Numero do processo
                                ,pr_nmjuiz        IN  VARCHAR2  -- Juiz emissor
                                ,pr_idordem       OUT NUMBER    -- Sequencial do recebimento
                                ,pr_cdcritic      OUT NUMBER    -- Codigo da critica
                                ,pr_dscritic      OUT VARCHAR2);-- Texto de erro/critica encontrada

  -- Efetuar o recebimento das solicitacoes de TED
  PROCEDURE pc_recebe_ted(pr_nrdocnpj_cop         IN NUMBER     -- CNPJ da cooperativa
                         ,pr_nrcpfcnpj            IN NUMBER     -- CNPJ / CPF do titular da conta
                         ,pr_tppessoa             IN VARCHAR2   -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                         ,pr_tpproduto            IN VARCHAR2   -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                         ,pr_dsoficio             IN VARCHAR2   -- Numero do oficio
                         ,pr_nrdconta             IN NUMBER     -- Numero da conta
                         ,pr_vlordem              IN NUMBER     -- Valor   
                         ,pr_indbloqueio_saldo    IN NUMBER     -- Indicador de término de bloqueio de saldo remanescente (0-Não encerra bloqueio, 1-Encerra bloqueio)
                         ,pr_nrcnpj_if_destino    IN NUMBER     -- Numero do CNPJ da instituicao financeira de destino
                         ,pr_nrcpfcnpj_favorecido IN NUMBER     --  Numero do CPF / CNPJ da conta de destino
                         ,pr_nragencia_if_destino IN NUMBER     -- Codigo da agencia de destino
                         ,pr_nmfavorecido         IN VARCHAR2   --  Nome da conta de destino
                         ,pr_tpdeposito           IN VARCHAR2   -- Indicador de tipo de depósito (T-Tributario, P-Previdenciario, Vazio-Demais) 
                         ,pr_cddeposito           IN NUMBER     -- Codigo do deposito (preenchido somente quanto tipo de deposito for T ou P)
                         ,pr_cdtransf_bacenjud    IN NUMBER     -- Numero de identificação da transferencia, gerado pelo BACENJUD
                         ,pr_cdcritic            OUT NUMBER     -- Codigo da critica
                         ,pr_dscritic            OUT VARCHAR2); -- Texto de erro/critica encontrada

  -- Efetuar a devolucao dos dados de uma solicitacao de consulta
  PROCEDURE pc_devolve_solicitacao(pr_idordem  IN  NUMBER,    -- Sequencial do recebimento
                                   pr_xmlrespo OUT xmltype,   -- XML com os dados de retorno
                                   pr_cdcritic OUT NUMBER,      -- Codigo da critica
                                   pr_dscritic OUT VARCHAR2); -- Texto de erro/critica encontrada


  -- Efetuar a devolucao dos dados de um bloqueio / desbloqueio
  PROCEDURE pc_devolve_blq_desblq(pr_idordem    IN  NUMBER,    -- Sequencial do recebimento
                                  pr_nrcnpjcop  OUT NUMBER,    -- CNPJ da Cooperativa
                                  pr_nrcpfcnpj  OUT NUMBER,    -- CPF / CNPJ do reu
                                  pr_tpproduto  OUT VARCHAR2,  -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                                  pr_nrdconta   OUT NUMBER,    -- Numero da conta
                                  pr_cdagenci   OUT NUMBER,    -- Codigo da agencia
                                  pr_vlbloqueio OUT NUMBER,    -- Valor de bloqueio
                                  pr_dhbloqueio OUT VARCHAR2,  -- Data e hora do bloqueio
                                  pr_inbloqueio OUT NUMBER,    -- Indicador de bloqueio (0-Sem retorno, 1-Processo OK, 2-Processo com Erro)
                                  pr_cdcritic   OUT NUMBER,    -- Codigo da critica
                                  pr_dscritic   OUT VARCHAR2); -- Texto de erro/critica encontrada

  -- Verifica se o processo noturno esta em execucao. Se o PR_NRDOCNPJ_COP vier como 0, verificará se todos os processos acabaram
  PROCEDURE pc_verifica_processo(pr_nrdocnpj_cop  IN NUMBER -- CNPJ da cooperativa
                                ,pr_idretorno    OUT VARCHAR2    -- Identifica se o processo esta em execucao (S-Esta em execucao, N-Processo nao esta em execucao)
                                ,pr_cdcritic     OUT NUMBER      -- Codigo da critica
                                ,pr_dscritic     OUT VARCHAR2);  -- Texto de erro/critica encontrada

END SOA_BLOQUEIO_JUDICIAL;
/
CREATE OR REPLACE PACKAGE BODY SOA.SOA_BLOQUEIO_JUDICIAL IS

  -- Efetuar o recebimento das solicitacoes de consulta de conta
  PROCEDURE pc_recebe_solicitacao(pr_nrdocnpj_cop  IN  NUMBER,      -- CNPJ da cooperativa
                                  pr_nrcpfcnpj     IN  NUMBER,      -- CNPJ / CPF do réu
                                  pr_tppessoa      IN  VARCHAR2,    -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                                  pr_idordem       OUT NUMBER,      -- Sequencial do recebimento
                                  pr_cdcritic      OUT NUMBER,      -- Codigo da critica
                                  pr_dscritic      OUT VARCHAR2) IS -- Texto de erro/critica encontrada
  BEGIN
    
    -- Chama a rotina original
    BLQJ0002.pc_recebe_solicitacao(pr_nrdocnpj_cop => pr_nrdocnpj_cop,
                                   pr_nrcpfcnpj    => pr_nrcpfcnpj,   
                                   pr_tppessoa     => pr_tppessoa,    
                                   pr_idordem      => pr_idordem,     
                                   pr_cdcritic     => pr_cdcritic,    
                                   pr_dscritic     => pr_dscritic);    
    IF pr_dscritic IS NULL THEN
      pr_cdcritic := 0;
    ELSE
      pr_cdcritic := 90;
    END IF;
  END pc_recebe_solicitacao;

  -- Efetuar o recebimento das solicitacoes de bloqueio e desbloqueio
  PROCEDURE pc_recebe_blq_desblq(pr_nrdocnpj_cop  IN  NUMBER       -- CNPJ da cooperativa
                                ,pr_nrcpfcnpj     IN  NUMBER       -- CNPJ / CPF do réu
                                ,pr_tppessoa      IN  VARCHAR2     -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                                ,pr_tpproduto     IN  VARCHAR2     -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                                ,pr_dsoficio      IN  VARCHAR2     -- Numero do oficio
                                ,pr_nrdconta      IN  NUMBER       -- Numero da conta
                                ,pr_cdagenci      IN  NUMBER       -- Codigo da agencia
                                ,pr_tpordem       IN  NUMBER       -- Tipo de Operacao (2-Bloqueio, 3-Desbloqueio)
                                ,pr_vlordem       IN  NUMBER       -- Valor do bloqueio
                                ,pr_dsprocesso    IN  VARCHAR2     -- Numero do processo
                                ,pr_nmjuiz        IN  VARCHAR2     -- Juiz emissor
                                ,pr_idordem       OUT NUMBER       -- Sequencial do recebimento
                                ,pr_cdcritic      OUT NUMBER       -- Codigo da critica
                                ,pr_dscritic      OUT VARCHAR2) IS -- Texto de erro/critica encontrada
  BEGIN
    
    -- Chama a rotina original
    BLQJ0002.pc_recebe_blq_desblq(pr_nrdocnpj_cop => pr_nrdocnpj_cop
                                 ,pr_nrcpfcnpj    => pr_nrcpfcnpj   
                                 ,pr_tppessoa     => pr_tppessoa    
                                 ,pr_tpproduto    => pr_tpproduto    
                                 ,pr_dsoficio     => pr_dsoficio    
                                 ,pr_nrdconta     => pr_nrdconta    
                                 ,pr_cdagenci     => pr_cdagenci    
                                 ,pr_tpordem      => pr_tpordem     
                                 ,pr_vlordem      => pr_vlordem     
                                 ,pr_dsprocesso   => pr_dsprocesso  
                                 ,pr_nmjuiz       => pr_nmjuiz    
                                 ,pr_idordem      => pr_idordem
                                 ,pr_cdcritic     => pr_cdcritic  
                                 ,pr_dscritic     => pr_dscritic);    
    IF pr_dscritic IS NULL THEN
      pr_cdcritic := 0;
    ELSE
      pr_cdcritic := 90;
    END IF;

  END pc_recebe_blq_desblq;

  -- Efetuar o recebimento das solicitacoes de TED
  PROCEDURE pc_recebe_ted(pr_nrdocnpj_cop         IN NUMBER       -- CNPJ da cooperativa
                         ,pr_nrcpfcnpj            IN NUMBER       -- CNPJ / CPF do titular da conta
                         ,pr_tppessoa             IN VARCHAR2     -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                         ,pr_tpproduto            IN VARCHAR2     -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                         ,pr_dsoficio             IN VARCHAR2     -- Numero do oficio
                         ,pr_nrdconta             IN NUMBER       -- Numero da conta
                         ,pr_vlordem              IN NUMBER       -- Valor   
                         ,pr_indbloqueio_saldo    IN NUMBER       -- Indicador de término de bloqueio de saldo remanescente (0-Não encerra bloqueio, 1-Encerra bloqueio)
                         ,pr_nrcnpj_if_destino    IN NUMBER       -- Numero do CNPJ da instituicao financeira de destino
                         ,pr_nrcpfcnpj_favorecido IN NUMBER       --  Numero do CPF / CNPJ da conta de destino
                         ,pr_nragencia_if_destino IN NUMBER       -- Codigo da agencia de destino
                         ,pr_nmfavorecido         IN VARCHAR2     --  Nome da conta de destino
                         ,pr_tpdeposito           IN VARCHAR2     -- Indicador de tipo de depósito (T-Tributario, P-Previdenciario, Vazio-Demais) 
                         ,pr_cddeposito           IN NUMBER       -- Codigo do deposito (preenchido somente quanto tipo de deposito for T ou P)
                         ,pr_cdtransf_bacenjud    IN NUMBER       -- Numero de identificação da transferencia, gerado pelo BACENJUD
                         ,pr_cdcritic            OUT NUMBER       -- Codigo da critica
                         ,pr_dscritic            OUT VARCHAR2) IS -- Texto de erro/critica encontrada
  BEGIN
    
    -- Chama a rotina original
    blqj0002.pc_recebe_ted(pr_nrdocnpj_cop         => pr_nrdocnpj_cop         
                          ,pr_nrcpfcnpj            => pr_nrcpfcnpj            
                          ,pr_tppessoa             => pr_tppessoa             
                          ,pr_nrdconta             => pr_nrdconta
                          ,pr_tpproduto            => pr_tpproduto             
                          ,pr_dsoficio             => pr_dsoficio             
                          ,pr_vlordem              => pr_vlordem              
                          ,pr_indbloqueio_saldo    => pr_indbloqueio_saldo    
                          ,pr_nrcnpj_if_destino    => pr_nrcnpj_if_destino    
                          ,pr_nrcpfcnpj_favorecido => pr_nrcpfcnpj_favorecido 
                          ,pr_nragencia_if_destino => pr_nragencia_if_destino 
                          ,pr_nmfavorecido         => pr_nmfavorecido         
                          ,pr_tpdeposito           => pr_tpdeposito           
                          ,pr_cddeposito           => pr_cddeposito           
                          ,pr_cdtransf_bacenjud    => pr_cdtransf_bacenjud    
                          ,pr_cdcritic             => pr_cdcritic
                          ,pr_dscritic             => pr_dscritic);
    IF pr_dscritic IS NULL THEN
      pr_cdcritic := 0;
    ELSE
      pr_cdcritic := 90;
    END IF;
    
  END pc_recebe_ted;

  -- Efetuar a devolucao dos dados de uma solicitacao de consulta
  PROCEDURE pc_devolve_solicitacao(pr_idordem  IN  NUMBER,      -- Sequencial do recebimento
                                   pr_xmlrespo OUT xmltype,     -- XML com os dados de retorno
                                   pr_cdcritic OUT NUMBER,      -- Codigo da critica
                                   pr_dscritic OUT VARCHAR2) IS -- Texto de erro/critica encontrada
  BEGIN
    
    -- Chama a rotina original
    blqj0002.pc_devolve_solicitacao(pr_idordem  => pr_idordem 
                                   ,pr_xml      => pr_xmlrespo     
                                   ,pr_cdcritic => pr_cdcritic
                                   ,pr_dscritic => pr_dscritic);
    IF pr_dscritic IS NULL THEN
      pr_cdcritic := 0;
    ELSE
      pr_cdcritic := 90;
    END IF;
        
  END pc_devolve_solicitacao;
  
  
  -- Efetuar a devolucao dos dados de um bloqueio / desbloqueio
  PROCEDURE pc_devolve_blq_desblq(pr_idordem    IN  NUMBER,      -- Sequencial do recebimento
                                  pr_nrcnpjcop  OUT NUMBER,      -- CNPJ da Cooperativa
                                  pr_nrcpfcnpj  OUT NUMBER,      -- CPF / CNPJ do reu
                                  pr_tpproduto  OUT VARCHAR2,    -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                                  pr_nrdconta   OUT NUMBER,      -- Numero da conta
                                  pr_cdagenci   OUT NUMBER,      -- Codigo da agencia
                                  pr_vlbloqueio OUT NUMBER,      -- Valor de bloqueio
                                  pr_dhbloqueio OUT VARCHAR2,    -- Data e hora do bloqueio
                                  pr_inbloqueio OUT NUMBER,      -- Indicador de bloqueio (0-Sem retorno, 1-Processo OK, 2-Processo com Erro)
                                  pr_cdcritic   OUT NUMBER,      -- Codigo da critica
                                  pr_dscritic   OUT VARCHAR2) IS -- Texto de erro/critica encontrada
    vr_dhbloqueio DATE;

  BEGIN
    
    -- Chama a rotina original
    blqj0002.pc_devolve_blq_desblq(pr_idordem    => pr_idordem   
                                  ,pr_nrcnpjcop  => pr_nrcnpjcop 
                                  ,pr_nrcpfcnpj  => pr_nrcpfcnpj 
                                  ,pr_tpproduto  => pr_tpproduto 
                                  ,pr_nrdconta   => pr_nrdconta  
                                  ,pr_cdagenci   => pr_cdagenci  
                                  ,pr_vlbloqueio => pr_vlbloqueio
                                  ,pr_dhbloqueio => vr_dhbloqueio
                                  ,pr_inbloqueio => pr_inbloqueio
                                  ,pr_cdcritic   => pr_cdcritic
                                  ,pr_dscritic   => pr_dscritic);  
    IF pr_dscritic IS NULL THEN
      pr_cdcritic := 0;
      pr_dhbloqueio := to_char(vr_dhbloqueio,'DD/MM/YYYY hh24:mi:ss');
    ELSE
      pr_cdcritic := 90;
    END IF;

  END pc_devolve_blq_desblq;

  -- Verifica se o processo noturno esta em execucao. Se o PR_NRDOCNPJ_COP vier como 0, verificará se todos os processos acabaram
  PROCEDURE pc_verifica_processo(pr_nrdocnpj_cop  IN NUMBER -- CNPJ da cooperativa
                                ,pr_idretorno    OUT VARCHAR2    -- Identifica se o processo esta em execucao (S-Esta em execucao, N-Processo nao esta em execucao)
                                ,pr_cdcritic     OUT NUMBER      -- Codigo da critica
                                ,pr_dscritic     OUT VARCHAR2) IS -- Texto de erro/critica encontrada
  BEGIN
    
    -- Chama a rotina original
    blqj0002.pc_verifica_processo(pr_nrdocnpj_cop => pr_nrdocnpj_cop,
                                  pr_idretorno    => pr_idretorno);
                                  
    pr_cdcritic := 0;
    
  END pc_verifica_processo;
  
END SOA_BLOQUEIO_JUDICIAL;
/
