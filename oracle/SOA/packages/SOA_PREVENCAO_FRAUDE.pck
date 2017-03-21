create or replace package soa.SOA_PREVENCAO_FRAUDE is

---------------------------------------------------------------------------
  --
  --  Programa : SOA_PREVECAO_FRAUDE
  --  Sistema  : Rotinas referentes ao WebService de comunicação com sistema de análise 
  --  antifraude (OFSAA) Oracle Financial Services Analytical Applications
  --  Sigla    : SOA
  --  Autor    : Oscar Alcantara Junior
  --  Data     : Outubro - 2016.                   Ultima atualizacao: 27/10/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de prevenção de fraudes OFSAA
  --
  -- Alteracoes: 
  --             
  --             
  --
  ---------------------------------------------------------------------------
  
  --> Rotina responsavel por registrar o parecer de retorno da análise do sistema antifraude
  PROCEDURE pc_reg_reto_analise_antifraude(pr_idanalis    IN  NUMBER,       /* Id Unico da transação */
                                           pr_cdparece    IN  NUMBER,       /* Parecer da análise antifraude 
                                                                               1 - Aprovada
                                                                               2 - Reprovada
                                                                            */
                                           pr_flganama   IN  NUMBER,        /* Indentificador de analise manual */
                                           pr_cdcanal    IN  NUMBER,        /* Canal origem da operação         */
                                           pr_fingerpr   IN  VARCHAR2,      /* Identifica a comunicação partiu do antifraude */
                                           pr_cdcritic   OUT  NUMBER,       /* Código da Crítica */
                                           pr_dscritic   OUT VARCHAR2,      /* Descrição da Crítica */
                                           pr_dsdetcri   OUT VARCHAR2);     /* Detalhe da critica */
                                
  --> Rotina responsavel por registrar a confirmação de entrega da análise ao sistema antifraude
  PROCEDURE pc_reg_conf_entrega_antifraude(pr_idanalis    IN  NUMBER,       /* Id Unico da transação */
                                           pr_cdentreg    IN  NUMBER,       /* Codigo de confirmação de entrega 
                                                                               3 - Entrega confirmada antifraude
                                                                               4 - Erro na comunicação com antifraude */                                                                                                           
                                           pr_cdcritic   IN OUT  NUMBER,       /* Código da Crítica */
                                           pr_dscritic   IN OUT VARCHAR2,      /* Descrição da Crítica */
                                           pr_dsdetcri   IN OUT VARCHAR2);     /* Detalhe da critica */
                                          
  

end SOA_PREVENCAO_FRAUDE;
/
create or replace package body soa.SOA_PREVENCAO_FRAUDE is

---------------------------------------------------------------------------
  --
  --  Programa : SOA_PREVECAO_FRAUDE
  --  Sistema  : Rotinas referentes ao WebService de comunicação com sistema de análise 
  --  antifraude (OFSAA) Oracle Financial Services Analytical Applications
  --  Sigla    : SOA
  --  Autor    : Oscar Alcantara Junior
  --  Data     : Outubro - 2016.                   Ultima atualizacao: 27/10/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao WebService de prevenção de fraudes OFSAA
  --
  -- Alteracoes: 
  --             
  --             
  --
  ---------------------------------------------------------------------------
  
  
  --> Rotina responsavel por registrar o parecer de retorno da análise do sistema antifraude
  PROCEDURE pc_reg_reto_analise_antifraude(pr_idanalis    IN  NUMBER,       /* Id Unico da transação */
                                           pr_cdparece    IN  NUMBER,       /* Parecer da análise antifraude 
                                                                               1 - Aprovada
                                                                               2 - Reprovada
                                                                            */
                                           pr_flganama   IN  NUMBER,        /* Indentificador de analise manual */
                                           pr_cdcanal    IN  NUMBER,        /* Canal origem da operação         */
                                           pr_fingerpr   IN  VARCHAR2,      /* Identifica a comunicação partiu do antifraude */
                                           pr_cdcritic   OUT  NUMBER,       /* Código da Crítica */
                                           pr_dscritic   OUT VARCHAR2,      /* Descrição da Crítica */
                                           pr_dsdetcri   OUT VARCHAR2) IS   /* Detalhe da critica */
  BEGIN
    pr_cdcritic := 0; 
    pr_dscritic := NULL;
    
    AFRA0001.pc_reg_reto_analise_antifraude(pr_idanalis   => pr_idanalis,       --> Id Unico da transação 
                                            pr_cdparece   => pr_cdparece,       --> Parecer da análise antifraude
                                                                                 --> 1 - Aprovada
                                                                                 --> 2 - Reprovada
                                            pr_flganama   => pr_flganama,      --> Indentificador de analise manual 
                                            pr_cdcanal    => pr_cdcanal ,      --> Canal origem da operação
                                            pr_fingerpr   => pr_fingerpr,      --> Identifica a comunicação partiu do antifraude
                                            pr_cdcritic   => pr_cdcritic,      --> Código da Crítica 
                                            pr_dscritic   => pr_dscritic,      --> Descrição da Crítica 
                                            pr_dsdetcri   => pr_dsdetcri);     --> Detalhe da critica 

    IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
      ROLLBACK;
    END IF;
    
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;     
      pr_cdcritic := 996;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;            
  END pc_reg_reto_analise_antifraude;                                        
                                          
  --> Rotina responsavel por registrar a confirmação de entrega da análise ao sistema antifraude
  PROCEDURE pc_reg_conf_entrega_antifraude(pr_idanalis    IN  NUMBER,       /* Id Unico da transação */
                                           pr_cdentreg    IN  NUMBER,       /* Codigo de confirmação de entrega 
                                                                               3 - Entrega confirmada antifraude
                                                                               4 - Erro na comunicação com antifraude */                                                                                                           
                                           pr_cdcritic   IN OUT  NUMBER,       /* Código da Crítica */
                                           pr_dscritic   IN OUT VARCHAR2,      /* Descrição da Crítica */
                                           pr_dsdetcri   IN OUT VARCHAR2) IS   /* Detalhe da critica */
  BEGIN
    pr_cdcritic := 0; 
    pr_dscritic := NULL;
    
    AFRA0001.pc_reg_conf_entrega_antifraude(pr_idanalis   => pr_idanalis,   --> Id Unico da transação 
                                   pr_cdentreg   => pr_cdentreg,   --> Codigo de confirmação de entrega 
                                                                    --> 3 - Entrega confirmada antifraude
                                                                    --> 4 - Erro na comunicação com antifraude
                                   pr_cdcritic   => pr_cdcritic,   --> Código da Crítica 
                                   pr_dscritic   => pr_dscritic,   --> Descrição da Crítica 
                                   pr_dsdetcri   => pr_dsdetcri);  --> Detalhe da critica 

    IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
      ROLLBACK;
    END IF;
    
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;     
      pr_cdcritic := 997;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := SQLERRM;            
  END pc_reg_conf_entrega_antifraude;
  
  
end SOA_PREVENCAO_FRAUDE;
/
