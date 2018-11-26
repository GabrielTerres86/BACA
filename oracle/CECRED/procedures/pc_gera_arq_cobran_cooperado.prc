CREATE OR REPLACE PROCEDURE CECRED.pc_gera_arq_cobran_cooperado(pr_dscritic OUT VARCHAR2) IS
 /* ..........................................................................

   JOB: JBCOBRAN_ARQ_COOPERADO
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Rodrigo Andreatta
   Data    : Julho/2018.                     Ultima atualizacao: 29/08/2018

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Acionar processo de devolução da Cobrança Aos Cooperados (crs538_2)

   Alteracoes: 29/08/2018 - Revitalização Sistemas - Ajustes na busca da quantidade
                            de jobs por execução e passagem para o paralelismo - (Andreatta-Mouts)  
         
  ..........................................................................*/    
                                                                        
  ------------------------- VARIAVEIS PRINCIPAIS ------------------------------      
  
    --> Cooperativa Central
    vr_cdcooper CONSTANT crapcop.cdcooper%TYPE := 3;      
    vr_nomdojob CONSTANT VARCHAR2(100) := 'JBCOBRAN_ARQ_COOPERADO';
    
    --> Criticas do processo
    vr_cdcritic PLS_INTEGER; 
    vr_dscritic varchar2(2000);
    vr_flgerlog  BOOLEAN := FALSE;
        
    -- Quantidade de JOBS
    vr_qtdjobs NUMBER;
    
    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
    
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => NULL           --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;

  BEGIN
    
    -- Garantir que o JOB seja executado fora do processo
    gene0004.pc_executa_job( pr_cdcooper => vr_cdcooper --> Codigo da cooperativa
                            ,pr_fldiautl => 0           --> Flag se deve validar dia util
                            ,pr_flproces => 1           --> Flag se deve validar se esta no processo    
                            ,pr_flrepjob => 1           --> Flag para reprogramar o job
                            ,pr_flgerlog => 1           --> indicador se deve gerar log
                            ,pr_nmprogra => vr_nomdojob --> Nome do programa que esta sendo executado no job
                            ,pr_dscritic => vr_dscritic);
    -- senao retornou critica  chama rotina
    IF TRIM(vr_dscritic) IS NULL THEN     

      -- Início da execução do job
      pc_controla_log_batch(pr_dstiplog => 'I');
        
      -- Buscar quantidade parametrizada de Jobs para este horário
      vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(vr_cdcooper,vr_nomdojob); 
        
      -- Chamar processamento do arquivo
      CECRED.PC_CRPS538_2(pr_flavaexe => 'S'
                         ,pr_cdcooper => vr_cdcooper
                         ,pr_nmtelant => 'DIARIA'
                         ,pr_qtdejobs => vr_qtdjobs
                         ,pr_cdcritic => vr_cdcritic  
                         ,pr_dscritic => vr_dscritic);
                   
      -- Se houve erro na execução                           
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Gerar log do erro
        pr_dscritic := vr_dscritic;
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
      ELSE 
        -- Fim da execução do job
        pc_controla_log_batch(pr_dstiplog => 'F');
      END IF;
    ELSE
      -- Gerar log do erro
      pr_dscritic := vr_dscritic;
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => vr_dscritic);
    END IF;
             
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;

      -- Efetuar retorno do erro não tratado
      pr_dscritic := sqlerrm;
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);
    
 END pc_gera_arq_cobran_cooperado;
/
