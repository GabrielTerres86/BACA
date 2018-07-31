CREATE OR REPLACE PROCEDURE CECRED.PC_BANCOOB_RECEBE_ARQUIVO_CEXT(pr_dscritic OUT VARCHAR2) IS
 /* ..........................................................................

   JOB: PC_BANCOOB_RECEBE_ARQUIVO_CEXT
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : VANESSA KLEIN
   Data    : Janeiro/2015.                     Ultima atualizacao: 18/07/2016

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Conciliar débitos dos Cartões de Crédito (Bancoob/CABAL).

   Alteracoes: 10/08/2015 - Alterado rotina para ver se o job pode ser executado
                            gene0004.pc_executa_job, caso não possa ser rodado
                            e reprogramado para rodar na proxima hora(Odirlei -AMcom)       
         
               30/06/2016 - #454336 Incluído log de início, fim e erro na execução do job
                            (Carlos)
                              
                              
               18/07/2018 - Projeto Revitalização Sistemas - Andreatta (MOUTs)        
         
  ..........................................................................*/    
                                                                        
  ------------------------- VARIAVEIS PRINCIPAIS ------------------------------      
  
    --> Cooperativa Central
    vr_cdcooper CONSTANT crapcop.cdcooper%TYPE := 3;      
    vr_nomdojob CONSTANT VARCHAR2(100) := 'JBCRD_BANCOOB_RECEB_CEXT';
    vr_cdoperad CONSTANT VARCHAR2(100) := '1';
    
    --> Criticas do processo
    vr_cdcritic PLS_INTEGER; 
    vr_dscritic varchar2(2000);
    vr_flgerlog  BOOLEAN := FALSE;
  
    vr_dtvalida DATE;                              --> Variavel que retorna o dia valido
    vr_ultdiaano DATE;                             --> Variavel que informa qual é o ultimo dia do ano
    vr_dtdiahoje DATE;
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
    -- Buscar datas
    vr_dtdiahoje := TRUNC(SYSDATE); 
    vr_dtvalida  := gene0005.fn_valida_dia_util(pr_cdcooper => 3, 
                                                pr_dtmvtolt => vr_dtdiahoje, 
                                                pr_tipo     => 'A', 
                                                pr_feriado  => TRUE );     
    vr_ultdiaano := gene0005.fn_valida_dia_util(pr_cdcooper => 3, 
                                                pr_dtmvtolt =>  TO_DATE('31/12/'||EXTRACT(YEAR FROM SYSDATE),'DD/MM/YYYY'), 
                                                pr_tipo     => 'A', 
                                                pr_feriado  => TRUE,
                                                pr_excultdia => TRUE ); 
    -- SE FOR DIA UTIL E NÃO FOR O ULTIMO DIA DO ANO, EXECUTA O CRPS  
    IF vr_dtvalida = vr_dtdiahoje AND vr_dtdiahoje <> vr_ultdiaano THEN                                              
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
        
        -- Chamar processamento do arquivo
        CCRD0003.pc_recebe_arq_cet_bancoob(pr_cdcooper => vr_cdcooper
                                          ,pr_cdoperad => vr_cdoperad
                                          ,pr_cdprogra => vr_nomdojob
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
    END IF;
             
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;

      -- Efetuar retorno do erro não tratado
      pr_dscritic := sqlerrm;
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);
    
 END PC_BANCOOB_RECEBE_ARQUIVO_CEXT;
/
