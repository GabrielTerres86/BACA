CREATE OR REPLACE PROCEDURE CECRED.PC_BANCOOB_RECEBE_ARQ_SOLCC IS
 /* ..........................................................................

   JOB: PC_BANCOOB_RECEBE_ARQ_SOLCC
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Lucas Ranghetti
   Data    : Abril/2017.                     Ultima atualizacao: 08/03/2019

   Dados referentes ao programa:

   Frequencia: Diario.

   Objetivo  : Procedimento para a Importacao do arquivo de Interface Cadastral
             dos Cartões de Crédito BANCOOB/CABAL - CCR3.

   Alteracoes: 08/03/2019 - Nao verificar se processo batch ainda está rodando na central
                            pois vamos rodar o programa mesmo com a central rodando
                            Lucas Ranghetti PRB0040618)

  ..........................................................................*/
  
    ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra   crapprg.cdprogra%TYPE;           --> Código do programa
    vr_infimsol   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
    vr_cdcritic   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
    vr_dserro     VARCHAR2(2000);
    vr_dtvalida   DATE;                            --> Variavel que retorna o dia valido

    vr_nomdojob   CONSTANT VARCHAR2(100) := 'jbcrd_bancoob_recebe_solcc';
    vr_flgerlog   BOOLEAN := FALSE;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;


BEGIN

  vr_dtvalida  := gene0005.fn_valida_dia_util(pr_cdcooper => 3,
                                              pr_dtmvtolt => TRUNC(SYSDATE),
                                              pr_tipo     => 'A',
                                              pr_feriado  => TRUE );

  -- SE FOR DIA UTIL EXECUTA O CRPS
  IF vr_dtvalida = TRUNC(SYSDATE) THEN
     
    gene0004.pc_executa_job( pr_cdcooper => 3   --> Codigo da cooperativa
                            ,pr_fldiautl => 0   --> Flag se deve validar dia util
                            ,pr_flproces => 0   --> Flag se deve validar se esta no processo    
                            ,pr_flrepjob => 1   --> Flag para reprogramar o job
                            ,pr_flgerlog => 1   --> indicador se deve gerar log
                            ,pr_nmprogra => 'PC_BANCOOB_RECEBE_ARQ_SOLCC' --> Nome do programa que esta sendo executado no job
                            ,pr_dscritic => vr_dserro);
                    
    -- se nao retornou critica  chama rotina
    IF trim(vr_dserro) IS NULL THEN                      
    
      -- Início da execução do job
      pc_controla_log_batch(pr_dstiplog => 'I');
        
      pc_crps672(pr_cdcooper => 3,
                 pr_flgresta => 1,
                 pr_stprogra =>  vr_cdprogra,
                 pr_infimsol =>  vr_infimsol,
                 pr_cdoperad =>  1,
                 pr_cdcritic =>  vr_cdcritic,
                 pr_dscritic =>  vr_dserro );
                   
      IF TRIM(vr_dserro) IS NOT NULL THEN       
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dserro);
      END IF; 
                
      -- Fim da execução do job
      pc_controla_log_batch(pr_dstiplog => 'F');
    END IF;

  END IF;

END PC_BANCOOB_RECEBE_ARQ_SOLCC;
/
