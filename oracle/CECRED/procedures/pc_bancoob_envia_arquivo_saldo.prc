CREATE OR REPLACE PROCEDURE CECRED.PC_BANCOOB_ENVIA_ARQUIVO_SALDO(pr_tipoexec IN VARCHAR2 
                                                                 ,pr_dscritic OUT VARCHAR2)  IS
 /* ..........................................................................

   JOB: PC_BANCOOB_ENVIA_ARQUIVO_SALDO
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : VANESSA KLEIN
   Data    : Janeiro/2015.                     Ultima atualizacao: 16/07/2018

   Dados referentes ao programa:

   Frequencia: Di�rio.
   Objetivo  : procedimento para a gera��o do arquivo de Saldo Disp. dos Associados
               dos Cart�es de Cr�dito BANCOOB/CABAL.

   Alteracoes: 10/08/2015 - Alterado rotina para ver se o job pode ser executado
                            gene0004.pc_executa_job, caso n�o possa ser rodado
                            e reprogramado para rodar na proxima hora(Odirlei -AMcom)       

               30/06/2016 - #454336 Inclu�do log de in�cio, fim e erro na execu��o do job
                            (Carlos)

               08/01/2018 - #796943 Cria��o do par�metro de retorno de erro para o job; Tratado 
                            para n�o executar s�bado depois do meio dia, apenas pela manh� (Carlos)
                            
               28/02/2018 - #858915 Validar processo apenas at� sexta-feira, pois s�bado a CECRED
                            fica com o indicador de processo como solicitado (Carlos)
                            
               16/07/2018 - Projeto Revitaliza��o Sistemas - Ajustes devido renomea��o das
                            rotinas e busca de jobs paralelos para execu��o por Coop e Agencia 
                            -  Andreatta (MOUTs)              
                            
  ..........................................................................*/

  ------------------------- VARIAVEIS PRINCIPAIS ------------------------------

    --> Cooperativa Central
    vr_cdcooper CONSTANT crapcop.cdcooper%TYPE := 3;      
    vr_nomdojob CONSTANT VARCHAR2(100) := CASE 
                                           WHEN pr_tipoexec = 'D' THEN 'JBCRD_BANCOOB_ENVSLD_DIA'
                                           ELSE 'JBCRD_BANCOOB_ENVSLD_NOI'
                                          END;
    vr_cdprogra CONSTANT VARCHAR2(10) := 'CRPS669';                                 
    vr_cdoperad CONSTANT VARCHAR2(100) := '1';
    
    --> Criticas do processo
    vr_cdcritic PLS_INTEGER; 
    vr_dscritic varchar2(2000);
  vr_flgerlog  BOOLEAN := FALSE;

    -- Quantidade de JOBS
    vr_qtdejobs NUMBER;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informa��o
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN

    --> Controlar gera��o de log de execu��o dos jobs 
    BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

  END pc_controla_log_batch;

  BEGIN

    -- Se for sab�do depois de meio dia, n�o executa. S�bado o job executa apenas pela manh�.
    IF to_char(SYSDATE,'d')    = 7 AND
       to_char(SYSDATE,'hh24') > 12 THEN
      RETURN;
    END IF;
    
    -- Validar processo apenas at� sexta-feira, pois s�bado a CECRED fica com o indicador de processo como solicitado
    IF to_char(SYSDATE,'d') < 7 THEN
      gene0004.pc_executa_job( pr_cdcooper => vr_cdcooper --> Codigo da cooperativa
                            ,pr_fldiautl => 0   --> Flag se deve validar dia util
                            ,pr_flproces => 1   --> Flag se deve validar se esta no processo    
                            ,pr_flrepjob => 1   --> Flag para reprogramar o job
                            ,pr_flgerlog => 1   --> indicador se deve gerar log
                            ,pr_nmprogra => 'PC_BANCOOB_ENVIA_ARQUIVO_SALDO'   --> Nome do programa que esta sendo executado no job
                              ,pr_dscritic => vr_dscritic);
    END IF;

    -- Se nao retornou critica, chama rotina
    IF TRIM(vr_dscritic) IS NULL THEN 

      -- In�cio da execu��o do job
      pc_controla_log_batch(pr_dstiplog => 'I');

      -- Buscar quantidade parametrizada de Jobs para este hor�rio
      vr_qtdejobs := gene0001.fn_retorna_qt_paralelo(vr_cdcooper,vr_nomdojob); 

      -- Chamar rotina geradora do arquivo                                      
      CCRD0003.pc_gera_saldo_bancoob(pr_cdcooper => vr_cdcooper
                                    ,pr_cdcoppar => 0
                                    ,pr_cdagepar => 0
                                    ,pr_idparale => 0
                                    ,pr_qtdejobs => vr_qtdejobs
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_nmdatela => vr_nomdojob
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      -- Se houve erro na execu��o                           
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Gerar log do erro
        pr_dscritic := vr_dscritic;
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);
      ELSE 
      -- Fim da execu��o do job
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

      -- Efetuar retorno do erro n�o tratado
      pr_dscritic := sqlerrm;
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);

END PC_BANCOOB_ENVIA_ARQUIVO_SALDO;
/
