CREATE OR REPLACE PACKAGE CECRED.tela_traesp IS

  
PROCEDURE pc_busca_limite_operacao(
                           pr_cdcooper        IN tbcc_monitoramento_parametro.cdcooper%TYPE           --> codigo da coopetiva
                           ,pr_tpoperacao     IN NUMBER                --> tipo da provisao                                                    
                           ,pr_cdcritic       OUT PLS_INTEGER                                         --> Código da crítica
                           ,pr_dscritic       OUT VARCHAR2                                            --> Descrição da crítica
                           ,pr_vloperac       OUT tbcc_monitoramento_parametro.vllimite_deposito%type -->retorno da proc
                           );

END tela_traesp;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_traesp IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TRAESP
  --  Sistema  : Ayllos Progress
  --  Autor    : Antonio Remualdo Junior
  --  Data     : Novembro - 2017.                Ultima atualizacao: 28/11/2017
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Buscar o valor do limite de operacao
  --
  ---------------------------------------------------------------------------
  
PROCEDURE pc_busca_limite_operacao(
                           pr_cdcooper        IN tbcc_monitoramento_parametro.cdcooper%TYPE --> codigo da coopetiva
                           ,pr_tpoperacao     IN NUMBER              --> tipo da operacao                                                     
                           ,pr_cdcritic       OUT PLS_INTEGER                               --> Código da crítica
                           ,pr_dscritic       OUT VARCHAR2            --> Descrição da crítica
                           ,pr_vloperac       OUT tbcc_monitoramento_parametro.vllimite_deposito%type -->retorno da proc
                           ) IS    
    /* .............................................................................
    
        Programa: pc_busca_limite_operacao
        Sistema : CECRED
        Sigla   : TRAESP
        Autor   : Antonio Remualdo Junior
        Data    : Novembro/2017.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para consultar valores tabela tbcc_monitoramento_parametro
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      ---------->> CURSORES <<--------    
      -- busca monitor
      CURSOR cr_monit_param(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE
                            ,pr_tpoperacao IN NUMBER) IS
      SELECT DECODE(pr_tpoperacao,1,p.vllimite_deposito,2,p.vllimite_saque,3,p.vllimite_pagamento) AS vllimite
      FROM tbcc_monitoramento_parametro p
      WHERE p.cdcooper = pr_cdcooper;         
      rw_monit_param cr_monit_param%ROWTYPE;
    
    BEGIN               
      --> Buscar parametros
      OPEN cr_monit_param(pr_cdcooper => pr_cdcooper, 
                          pr_tpoperacao => pr_tpoperacao);
      FETCH cr_monit_param INTO rw_monit_param;
    
      -- Se nao encontrar
      IF cr_monit_param%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_monit_param;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Parametro nao encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_monit_param;   
      END IF;
      
      pr_vloperac := rw_monit_param.vllimite;                                                                 
                            
  EXCEPTION
    WHEN vr_exc_saida THEN      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      ROLLBACK;
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina TELA_TRAESP.pc_busca_limite_operacao: ' || SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      ROLLBACK;
END pc_busca_limite_operacao;

END tela_traesp;
/
