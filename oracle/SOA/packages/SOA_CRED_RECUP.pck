CREATE OR REPLACE PACKAGE SOA.SOA_CRED_RECUP IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_CRED_RECUP
  --  Sistema  : Rotinas referentes ao WebService de Acordos
  --  Sigla    : EMPR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho - 2016.                   Ultima atualizacao: 19/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de Acordos
  --
  -- Alteracoes: 19/09/2016 - Incluido parametro de data de cancelamento na
  --                          chamada da procedure RECP0002.pc_cancelar_acordo
  --                          na procedure pc_cancelar_acordo, Prj. 302 (Jean Michel).
  --
  ---------------------------------------------------------------------------
  --> Retornar o saldo do contrado do cooperado
  PROCEDURE pc_consultar_saldo_contrato(pr_nrgrupo    IN  NUMBER,       --> Número do Grupo
                                        pr_nrcontrato IN  VARCHAR2,     --> Número do Contrato
                                        pr_vlsdeved   OUT NUMBER,       --> Valor Saldo Devedor
                                        pr_vlsdprej   OUT NUMBER,       --> Valor Saldo Prejuizo
                                        pr_vlatraso   OUT NUMBER,       --> Valor Atraso
                                        pr_cdcritic   OUT NUMBER,       --> Código da Crítica
                                        pr_dscritic   OUT VARCHAR2,     --> Descrição da Crítica
                                        pr_dsdetcri   OUT VARCHAR2);    --> Detalhe da critica
  
  --> Retornar o saldo dos contratos do CPF/CNPJ informado
  PROCEDURE pc_consultar_saldo_cooperado (pr_inPessoa    IN INTEGER,       --> Tipo de pessoa
                                          pr_nrcpfcgc    IN  NUMBER,       --> Número do CPF/CNPJ
                                          pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                                          pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                          pr_dscritic   OUT VARCHAR2,     --> Descrição da Crítica
                                          pr_dsdetcri   OUT VARCHAR2);    --> Detalhe da critica
                                          
  --> Rotina responsavel por gerar acordo e criar os boletos
  PROCEDURE pc_gerar_acordo (pr_xmlrequi    IN  xmltype,      --> XML de Requisição
                             pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                             pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                             pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                             pr_dsdetcri   OUT VARCHAR2);     --> Detalhe da critica
  
  --> Rotina responsavel por cancelar acordo
  PROCEDURE pc_cancelar_acordo (pr_nracordo    IN  NUMBER,       --> Numero do acordo
                                pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                                pr_dsdetcri   OUT VARCHAR2);     --> Detalhe da critica
  
END SOA_CRED_RECUP;
/
CREATE OR REPLACE PACKAGE BODY SOA.SOA_CRED_RECUP IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_CRED_RECUP
  --  Sistema  : Rotinas referentes ao WebService de Acordos
  --  Sigla    : EMPR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho - 2016.                   Ultima atualizacao: 19/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de Acordos
  --
  -- Alteracoes: 19/09/2016 - Incluido parametro de data de cancelamento na
  --                          chamada da procedure RECP0002.pc_cancelar_acordo
  --                          na procedure pc_cancelar_acordo, Prj. 302 (Jean Michel).
  --
  ---------------------------------------------------------------------------
  --> Retornar o saldo do contrado do cooperado
  PROCEDURE pc_consultar_saldo_contrato(pr_nrgrupo    IN  NUMBER,       --> Número do Grupo
                                        pr_nrcontrato IN  VARCHAR2,     --> Número do Contrato
                                        pr_vlsdeved   OUT NUMBER,       --> Valor Saldo Devedor
                                        pr_vlsdprej   OUT NUMBER,       --> Valor Saldo Prejuizo
                                        pr_vlatraso   OUT NUMBER,       --> Valor Atraso
                                        pr_cdcritic   OUT NUMBER,       --> Código da Crítica
                                        pr_dscritic   OUT VARCHAR2,     --> Descrição da Crítica
                                        pr_dsdetcri   OUT VARCHAR2)  IS --> Detalhe da critica
  /* .............................................................................
   Programa: pc_consultar_saldo_contrato
   Sistema : Rotinas referentes ao WebService
   Sigla   : WEBS
   Autor   : Odirlei Busana - AMcom
   Data    : Julho/2016.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Retornar o saldo do contrado do cooperado.

   Observacao: -----
   Alteracoes:
   ..............................................................................*/                                    
  BEGIN
    -- Consulta Saldo Devedor do Contrato
    RECP0002.pc_consultar_saldo_contrato(pr_nrgrupo    => pr_nrgrupo
                                        ,pr_nrcontrato => pr_nrcontrato
                                        ,pr_vlsdeved   => pr_vlsdeved
                                        ,pr_vlsdprej   => pr_vlsdprej
                                        ,pr_vlatraso   => pr_vlatraso
                                        ,pr_cdcritic   => pr_cdcritic
                                        ,pr_dscritic   => pr_dscritic
                                        ,pr_dsdetcri   => pr_dsdetcri);
                                        
    pr_vlsdeved   := nvl(pr_vlsdeved,0);
    pr_vlsdprej   := nvl(pr_vlsdprej,0);
    pr_vlatraso   := nvl(pr_vlatraso,0);                                   
                                        
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 983;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;
      
  END pc_consultar_saldo_contrato;
  
  --> Retornar o saldo dos contratos do CPF/CNPJ informado
  PROCEDURE pc_consultar_saldo_cooperado (pr_inPessoa    IN INTEGER,       --> Tipo de pessoa
                                          pr_nrcpfcgc    IN  NUMBER,       --> Número do CPF/CNPJ
                                          pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                                          pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                          pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                                          pr_dsdetcri   OUT VARCHAR2)  IS  --> Detalhe da critica
  /* .............................................................................
   Programa: pc_consultar_saldo_cooperado
   Sistema : Rotinas referentes ao WebService
   Sigla   : WEBS
   Autor   : Odirlei Busana - AMcom
   Data    : Julho/2016.                    Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Retornar o saldo dos contratos do CPF/CNPJ informado

   Observacao: -----
   Alteracoes:
   ..............................................................................*/                                    
  BEGIN
    RECP0002.pc_consultar_saldo_cooperado (pr_inPessoa => pr_inPessoa
                                          ,pr_nrcpfcgc => pr_nrcpfcgc
                                          ,pr_xmlrespo => pr_xmlrespo
                                          ,pr_cdcritic => pr_cdcritic
                                          ,pr_dscritic => pr_dscritic
                                          ,pr_dsdetcri => pr_dsdetcri);
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 983;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;
  END pc_consultar_saldo_cooperado;    
  
  --> Rotina responsavel por gerar acordo e criar os boletos
  PROCEDURE pc_gerar_acordo (pr_xmlrequi    IN  xmltype,      --> XML de Requisição
                             pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                             pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                             pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                             pr_dsdetcri   OUT VARCHAR2)  IS  --> Detalhe da critica
    /* .............................................................................
      Programa: pc_gerar_acordo
      Sistema : Rotinas referentes ao WebService
      Sigla   : WEBS
      Autor   : Odirlei Busana - AMcom
      Data    : Julho/2016.                    Ultima atualizacao: 20/07/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel por gerar acordo e criar os boletos

      Observacao: -----
      Alteracoes:
    ..............................................................................*/                                    
  BEGIN
    RECP0002.pc_gerar_acordo (pr_xmlrequi => pr_xmlrequi
                             ,pr_xmlrespo => pr_xmlrespo
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_dsdetcri => pr_dsdetcri);
                             
    IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
      ROLLBACK;
    END IF;
    
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;     
      pr_cdcritic := 993;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;
            
  END pc_gerar_acordo;
  
  --> Rotina responsavel por cancelar acordo
  PROCEDURE pc_cancelar_acordo (pr_nracordo    IN  NUMBER,       --> Numero do acordo
                                pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                                pr_dsdetcri   OUT VARCHAR2)  IS  --> Detalhe da critica
    /* .............................................................................
      Programa: pc_cancelar_acordo
      Sistema : Rotinas referentes ao WebService
      Sigla   : WEBS
      Autor   : Odirlei Busana - AMcom
      Data    : Julho/2016.                    Ultima atualizacao: 08/12/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel por cancelar acordo

      Observacao: -----
      Alteracoes: 19/09/2016 - Incluido parametro de data de cancelamento na
                               chamada da procedure RECP0002.pc_cancelar_acordo,
                               Prj. 302 (Jean Michel).

                  08/12/2017 - Inclusão de chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                               (SD#791193 - AJFink)

    ..............................................................................*/                                    
  BEGIN
    RECP0002.pc_cancelar_acordo (pr_nracordo => pr_nracordo
                                ,pr_dtcancel => TRUNC(SYSDATE)            
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic
                                ,pr_dsdetcri => pr_dsdetcri);
                                
    IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
      ROLLBACK;
      npcb0002.pc_libera_sessao_sqlserver_npc('SOA_CRED_RECUP_1');
    END IF;
    
    COMMIT;
    npcb0002.pc_libera_sessao_sqlserver_npc('SOA_CRED_RECUP_2');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;     
      npcb0002.pc_libera_sessao_sqlserver_npc('SOA_CRED_RECUP_3');
      pr_cdcritic := 994;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;            
  END pc_cancelar_acordo;
  
                                                              	
END SOA_CRED_RECUP;
/
