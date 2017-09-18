CREATE OR REPLACE PACKAGE SOA.SOA_CRM IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_CRM
  --  Sistema  : Rotinas para integração com CRM
  --  Sigla    : SOA_CRM
  --  Autor    : Ricardo Linhares
  --  Data     : Jullho/2017.                   Ultima atualizacao:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Centralizar rotinas para integração com CRM
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    PROCEDURE pc_consultar_dados_conta (pr_cdcooper    IN INTEGER, --> Cooperativa
                                        pr_nrdconta    IN  NUMBER, --> Número da conta
                                        pr_xmlrespo   OUT  xmltype,--> XML de Resposta
                                        pr_cdcritic   OUT  NUMBER, --> Código da Crítica
                                        pr_dscritic   OUT VARCHAR2,--> Descrição da Crítica
                                        pr_dsdetcri   OUT VARCHAR2);
END SOA_CRM;
/
CREATE OR REPLACE PACKAGE BODY SOA.SOA_CRM IS
  ---------------------------------------------------------------------------
  --
  --  Programa : SOA_CRM
  --  Sistema  : Rotinas para integração com CRM
  --  Sigla    : SOA_CRM
  --  Autor    : Ricardo Linhares
  --  Data     : Jullho/2017.                   Ultima atualizacao:
  --
  -- Frequencia: Sempre que for chamado
  -- Objetivo  : Centralizar rotinas para integração com CRM
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

PROCEDURE pc_consultar_dados_conta (pr_cdcooper    IN INTEGER, --> Cooperativa
                                    pr_nrdconta    IN  NUMBER, --> Número da conta
                                    pr_xmlrespo   OUT  xmltype,--> XML de Resposta
                                    pr_cdcritic   OUT  NUMBER, --> Código da Crítica
                                    pr_dscritic   OUT VARCHAR2,--> Descrição da Crítica
                                    pr_dsdetcri   OUT VARCHAR2) IS--> Detalhe dacritica

  BEGIN
    
    CRMW0001.pc_consultar_dados_conta(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_xmlrespo => pr_xmlrespo
                                     ,pr_cdcritic => pr_cdcritic
                                     ,pr_dscritic => pr_dscritic
                                     ,pr_dsdetcri => pr_dsdetcri);
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 564;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;
  END; 
  
END SOA_CRM;
/
