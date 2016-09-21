CREATE OR REPLACE PACKAGE CECRED.SOA_CRED_RECUP IS
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
  PROCEDURE pc_consultar_saldo_contrato(pr_nrgrupo    IN  NUMBER,       --> N�mero do Grupo
                                        pr_nrcontrato IN  NUMBER,       --> N�mero do Contrato
                                        pr_vlsdeved   OUT NUMBER,       --> Valor Saldo Devedor
                                        pr_vlsdprej   OUT NUMBER,       --> Valor Saldo Prejuizo
                                        pr_vlatraso   OUT NUMBER,       --> Valor Atraso
                                        pr_cdcritic   OUT NUMBER,       --> C�digo da Cr�tica
                                        pr_dscritic   OUT VARCHAR2,     --> Descri��o da Cr�tica
                                        pr_dsdetcri   OUT VARCHAR2);    --> Detalhe da critica
  
  --> Retornar o saldo dos contratos do CPF/CNPJ informado
  PROCEDURE pc_consultar_saldo_cooperado (pr_inPessoa    IN INTEGER,       --> Tipo de pessoa
                                          pr_nrcpfcgc    IN  NUMBER,       --> N�mero do CPF/CNPJ
                                          pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                                          pr_cdcritic   OUT  NUMBER,       --> C�digo da Cr�tica
                                          pr_dscritic   OUT VARCHAR2,     --> Descri��o da Cr�tica
                                          pr_dsdetcri   OUT VARCHAR2);    --> Detalhe da critica
                                          
  --> Rotina responsavel por gerar acordo e criar os boletos
  PROCEDURE pc_gerar_acordo (pr_xmlrequi    IN  xmltype,      --> XML de Requisi��o
                             pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                             pr_cdcritic   OUT  NUMBER,       --> C�digo da Cr�tica
                             pr_dscritic   OUT VARCHAR2,      --> Descri��o da Cr�tica
                             pr_dsdetcri   OUT VARCHAR2);     --> Detalhe da critica
  
  --> Rotina responsavel por cancelar acordo
  PROCEDURE pc_cancelar_acordo (pr_nracordo    IN  NUMBER,       --> Numero do acordo
                                pr_cdcritic   OUT  NUMBER,       --> C�digo da Cr�tica
                                pr_dscritic   OUT VARCHAR2,      --> Descri��o da Cr�tica
                                pr_dsdetcri   OUT VARCHAR2);     --> Detalhe da critica
  
END SOA_CRED_RECUP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SOA_CRED_RECUP IS
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
  PROCEDURE pc_consultar_saldo_contrato(pr_nrgrupo    IN  NUMBER,       --> N�mero do Grupo
                                        pr_nrcontrato IN  NUMBER,       --> N�mero do Contrato
                                        pr_vlsdeved   OUT NUMBER,       --> Valor Saldo Devedor
                                        pr_vlsdprej   OUT NUMBER,       --> Valor Saldo Prejuizo
                                        pr_vlatraso   OUT NUMBER,       --> Valor Atraso
                                        pr_cdcritic   OUT NUMBER,       --> C�digo da Cr�tica
                                        pr_dscritic   OUT VARCHAR2,     --> Descri��o da Cr�tica
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
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 983;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;
      
  END pc_consultar_saldo_contrato;
  
  --> Retornar o saldo dos contratos do CPF/CNPJ informado
  PROCEDURE pc_consultar_saldo_cooperado (pr_inPessoa    IN INTEGER,       --> Tipo de pessoa
                                          pr_nrcpfcgc    IN  NUMBER,       --> N�mero do CPF/CNPJ
                                          pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                                          pr_cdcritic   OUT  NUMBER,       --> C�digo da Cr�tica
                                          pr_dscritic   OUT VARCHAR2,      --> Descri��o da Cr�tica
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
                                          ,pr_nrcpfcgc => pr_inPessoa
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
  PROCEDURE pc_gerar_acordo (pr_xmlrequi    IN  xmltype,      --> XML de Requisi��o
                             pr_xmlrespo   OUT  xmltype,      --> XML de Resposta
                             pr_cdcritic   OUT  NUMBER,       --> C�digo da Cr�tica
                             pr_dscritic   OUT VARCHAR2,      --> Descri��o da Cr�tica
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
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;     
      pr_cdcritic := 993;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;
            
  END pc_gerar_acordo;
  
  --> Rotina responsavel por cancelar acordo
  PROCEDURE pc_cancelar_acordo (pr_nracordo    IN  NUMBER,       --> Numero do acordo
                                pr_cdcritic   OUT  NUMBER,       --> C�digo da Cr�tica
                                pr_dscritic   OUT VARCHAR2,      --> Descri��o da Cr�tica
                                pr_dsdetcri   OUT VARCHAR2)  IS  --> Detalhe da critica
    /* .............................................................................
      Programa: pc_cancelar_acordo
      Sistema : Rotinas referentes ao WebService
      Sigla   : WEBS
      Autor   : Odirlei Busana - AMcom
      Data    : Julho/2016.                    Ultima atualizacao: 19/09/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel por cancelar acordo

      Observacao: -----
      Alteracoes: 19/09/2016 - Incluido parametro de data de cancelamento na
                               chamada da procedure RECP0002.pc_cancelar_acordo,
                               Prj. 302 (Jean Michel).
    ..............................................................................*/                                    
  BEGIN
    RECP0002.pc_cancelar_acordo (pr_nracordo => pr_nracordo
                                ,pr_dtcancel => TRUNC(SYSDATE)            
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic
                                ,pr_dsdetcri => pr_dsdetcri);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;     
      pr_cdcritic := 994;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;            
  END pc_cancelar_acordo;
  
                                                              	
END SOA_CRED_RECUP;
/
