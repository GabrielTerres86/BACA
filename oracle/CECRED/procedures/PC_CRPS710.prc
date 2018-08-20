CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS710(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                              pr_dsjobnam IN VARCHAR2 ) IS
 /* ..........................................................................

    Programa: PC_CRPS710
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Odirlei
    Data    : Abril/2017                      Ultima Atualizacao: --/--/----
    Dados referente ao programa:

    Frequencia: Diario.
    Objetivo  : Renovacao automatica do limite de desconto de cheque - Chamada Job.

  ..........................................................................*/
  ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
  vr_cdprogra    VARCHAR2(40) := 'PC_CRPS710';    

  vr_exc_erro    EXCEPTION;
  vr_cdcritic    PLS_INTEGER;
  vr_dscritic    VARCHAR2(4000);

  vr_dtdiahoje   DATE;
  vr_dsplsql     VARCHAR2(2000);
  vr_jobname     VARCHAR2(30);
  vr_dtmvtolt    DATE;

  vr_minuto      NUMBER;
  vr_nomdojob    CONSTANT VARCHAR2(100) := 'jbchq_crps710';
  vr_flgerlog    BOOLEAN := FALSE;

  -- Variáveis de controle de calendário
  rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;

  --> Buscar coops ativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3
     ORDER BY cop.cdcooper;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN

    --> Controlar geração de log de execução dos jobs
    BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

  END pc_controla_log_batch;

BEGIN

  vr_dtdiahoje := TRUNC(SYSDATE);

  --> Se for coop 3, deve criar o job para cada coop
  IF pr_cdcooper = 3 THEN


    FOR rw_crapcop IN cr_crapcop LOOP

      -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --> Se a coop ainda estiver no processo batch, usar proxima data util
      IF rw_crapdat.inproces > 1 THEN
        vr_dtmvtolt := rw_crapdat.dtmvtopr;
      ELSE
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
      END IF;

      --> Verificar se a data do sistema eh o dia de hoje
      IF vr_dtdiahoje <> vr_dtmvtolt THEN
        --> O JOB esta confirgurado para rodar de Segunda a Sexta
        -- Mas nao existe a necessidade de rodar nos feriados
        -- Por isso que validamos se o dia de hoje eh o dia do sistema          
        continue;
      END IF;

      vr_jobname  := vr_nomdojob ||'_'||rw_crapcop.cdcooper||'$';
      vr_dsplsql  := 'begin cecred.PC_CRPS710(pr_cdcooper => '  ||rw_crapcop.cdcooper ||
                                           ', pr_dsjobnam => '''||vr_jobname||'''); end;';


      vr_minuto := (1/24/60); --> 1 - minuto

      -- Faz a chamada ao programa paralelo atraves de JOB
      gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper       --> Código da cooperativa
                            ,pr_cdprogra  => vr_cdprogra       --> Código do programa
                            ,pr_dsplsql   => vr_dsplsql        --> Bloco PLSQL a executar
                            ,pr_dthrexe   => TO_TIMESTAMP(to_char((SYSDATE + vr_minuto),'DD/MM/RRRR HH24:MI')||':'||to_char(rw_crapcop.cdcooper,'fm00'),
                                                                                        'DD/MM/RRRR HH24:MI:SS') --> Incrementar mais 1 minuto
                            ,pr_interva   => NULL                     --> apenas uma vez
                            ,pr_jobname   => vr_jobname               --> Nome randomico criado
                            ,pr_des_erro  => vr_dscritic);

      IF TRIM(vr_dscritic) is not null THEN
        vr_dscritic := 'Falha na criacao do Job (Coop:'||rw_crapcop.cdcooper||' Job: '||vr_jobname||'): '|| vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

    END LOOP;

  ELSE

    -- Valida se executa o job( testar de esta rodando o batch)
    gene0004.pc_executa_job( pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                            ,pr_fldiautl => 0             --> Flag se deve validar dia util
                            ,pr_flproces => 1             --> Flag se deve validar se esta no processo (true = não roda no processo)
                            ,pr_flrepjob => 1             --> Flag para reprogramar o job
                            ,pr_flgerlog => 1             --> indicador se deve gerar log
                            ,pr_nmprogra => pr_dsjobnam   --> Nome do programa que esta sendo executado no job
                            ,pr_dscritic => vr_dscritic);

    -- se nao retornou critica  chama rotina
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;


    pc_controla_log_batch(pr_dstiplog => 'I');

    --> Executar programa
    pc_crps710_I (pr_cdcooper => pr_cdcooper,
                  pr_cdcritic => vr_cdcritic,
                  pr_dscritic => vr_dscritic);

    --> Tratamento de erro
    IF vr_cdcritic > 0 OR
       vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Fim da execução do job
    pc_controla_log_batch(pr_dstiplog => 'F');

  END IF; -- fim IF coop = 3

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    -- Efetuar rollback
    ROLLBACK;

    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);

    COMMIT;
    
    IF vr_dscritic NOT LIKE '%Processo noturno nao finalizado para cooperativa%' THEN    
      raise_application_error(-20501,vr_dscritic);
    END IF;
  WHEN OTHERS THEN

    vr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;

    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);

    COMMIT;
    raise_application_error(-20501,vr_dscritic); 
END PC_CRPS710;
/
