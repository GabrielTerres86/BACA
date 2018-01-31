CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_AGENDEB(pr_cdcooper in crapcop.cdcooper%TYPE,
                                                  pr_cdprogra IN crapprg.cdprogra%TYPE,
                                                  pr_dsjobnam IN VARCHAR2) IS
 /* ..........................................................................

   JOB: PC_JOB_AGENDEB
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Odirlei Busana - AMcom
   Data    : Novembro/2015.                     Ultima atualizacao: 02/08/2017

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Controlar a execução dos programas CRPS509 e CRPS642
               que efetivam os agendamentos de pagamentos.
               Rotina cria novos jobs para execução paralela dos programas para cada cooperativa, 
               a primeira execução do dia ocorre de forma imediata, logo após o job ser criado, 
               caso o processo batch da cooperativa esteja rodando o job é reagendado para 
               a proxima hora. Para a ultima execução do dia o job principal cria os jobs 
               por cooperativa porém os mesmos são criados para rodar no horario 
               conforme definido na craphec(HRCOMP).
               
               - Em caso de configurar na CRAPHEC para executar mesmo processo diversas vezes durante o dia
                 é necessario que o craphec.cdprogra tenha o mesmo nome, com ele é identificado o processo
                 a ser executado e o craphec.dsprogra com nomes diferentes, pois este é utilizado para
                 definir o nome do job, assim sendo possivel controlar se o job já foi criado ou
                 não, do contrario ficaria um job sobrepondo o outro.

   Alteracoes: 22/12/2015 - Incluido o codico da cooperativa como segundo na data hora de execução do job
                            para que o job execute na sequencia de cooperativa (Odirlei-Amcom)

               08/03/2016 - Ajustado para que o programa seja rodado apenas quando a data do sistema
                            for a data atual (Douglas - Chamado 412137)

               21/06/2016 - Ajustes para inclusao da execucao do crps688 (Tiago/Thiago SD402010)

               21/07/2016 - Ajuste na hora de inicio da DEBSIC para as 07:31 - SD485978	
                            (Guilherme/SUPERO)
               
			   29/07/2016 - Atualizar craphec mesmo qdo voltar critica do crps688
			                e mudar o nome do job do processo com sufico _p
							ao inves de _proc (Tiago/Thiago SD 496111)
                            
               07/07/2017 - #551223 Uso dos parametros novos da btch0001.pc_gera_log_batch utilizada 
                            na rotina pc_gera_log_execucao para logar o início, fim e ocorrências dos 
                            programas. Padronização dos nomes dos jobs (Carlos)
                            
               02/08/2017 - #722488 Correção da reprogramação dos jobs utilizando a reprogramação pela 
                            rotina interna pc_reprograma_job ao invés de passar para a rotina
                            gene0004.pc_executa_job, pois a mesma utiliza apenas 13 caracteres, não 
                            atendendo o novo padrão de nome dos jobs. Uso de formato de 2 dígitos 
                            para o cdcooper (Carlos)
                            
               11/01/2018 - Ajustado rotina para executar debitos agendados do bancoob DEBBAN.
                            PRJ406 - FGTS (Odirlei-AMcom)
                            
  ..........................................................................*/
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    VARCHAR2(40) := 'PC_JOB_AGENDEB';
    vr_infimsol    PLS_INTEGER;                     
    vr_stprogra    PLS_INTEGER;
    
    vr_exc_email   EXCEPTION;
    vr_cdcritic    PLS_INTEGER;                     
    vr_dscritic    VARCHAR2(4000);

    vr_dtdiahoje   DATE;
    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(30);
    
    vr_flultexe    INTEGER;
    vr_qtdexec     INTEGER;
    vr_dtmvtolt    DATE;
    vr_dtprxexc    TIMESTAMP;
    
    vr_email_dest  VARCHAR2(1000); 
    vr_conteudo    VARCHAR2(4000);
    vr_tempo       NUMBER;
    vr_minuto      NUMBER;
    vr_minutos     NUMBER;   -- Tempo em minutos
    
    -- Variáveis de controle de calendário
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;    
    
    CURSOR cr_craphec_pri IS 
      SELECT hec.cdcooper,       
             hec.cdprogra
        FROM craphec hec, 
             crapcop cop
       WHERE hec.dsprogra IN  ('AGENDAMENTO APLICACAO/RESGATE')
         AND hec.cdcooper = cop.cdcooper
         AND cop.flgativo = 1   
       GROUP BY hec.cdcooper,
                hec.cdprogra
       ORDER BY hec.cdcooper; 
    
    --> Buscar hora de execucao para criação de job para cada coop
    CURSOR cr_craphec IS
      SELECT hec.cdcooper,
             hec.dsprogra,
             hec.cdprogra,
             hec.flgativo,
             hec.hriniexe,
             to_date(hec.hriniexe,'SSSSS') dtiniexe 
        FROM craphec hec, 
             crapcop cop
       WHERE hec.cdprogra IN  ('DEBNET','DEBSIC','CRPS688','DEBBAN')
         AND hec.cdcooper = cop.cdcooper
         AND cop.flgativo = 1
       ORDER BY hec.cdcooper,
                hec.nrseqexe; 
    
    --> Buscar hora de execucao para saber se esta ativo
    CURSOR cr_craphec_1 IS
      SELECT hec.cdcooper,
             hec.dsprogra,
             hec.cdprogra,
             hec.flgativo,
             hec.hriniexe,
             to_date(hec.hriniexe,'SSSSS') dtiniexe,
             hec.rowid 
        FROM craphec hec
       WHERE hec.cdprogra = pr_cdprogra
         AND hec.cdcooper = pr_cdcooper;
    rw_craphec_1 cr_craphec_1%ROWTYPE;    
    
    CURSOR cr_craphec_2(pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT 1
        FROM craphec hec
       WHERE hec.cdprogra = 'CRPS688'
         AND hec.cdcooper = pr_cdcooper
         AND hec.dtultexc = pr_dtmvtolt;
    rw_craphec_2 cr_craphec_2%ROWTYPE;     

    --> Verificar se o job 
    CURSOR cr_job (pr_job_name VARCHAR2) IS
      SELECT job.job_name,
             job.next_run_date
        FROM dba_scheduler_jobs job
       WHERE job.owner = 'CECRED'
         AND job.job_name LIKE pr_job_name||'%';
    rw_job cr_job%ROWTYPE;
    
    --> LOG de execuaco dos programas prcctl
    PROCEDURE pc_gera_log_execucao(pr_nmprgexe  IN VARCHAR2,
                                   pr_indexecu  IN VARCHAR2,
                                   pr_cdcooper  IN INTEGER, 
                                   pr_tpexecuc  IN VARCHAR2,
                                   pr_idtiplog  IN VARCHAR2, -- I - inicio, E - erro ou F - Fim
                                   pr_dtmvtolt  IN DATE) IS
      vr_nmarqlog VARCHAR2(500);
      vr_desdolog VARCHAR2(2000);
    BEGIN    
      
      --> Definir nome do log
      vr_nmarqlog := 'prcctl_'||to_char(pr_dtmvtolt,'RRRRMMDD')||'.log';
      --> Definir descrição do log
      vr_desdolog := 'Automatizado - '||to_char(SYSDATE,'HH24:MI:SS')||
                     ' --> Coop.:'|| pr_cdcooper ||' '|| 
                     pr_tpexecuc ||' - '||pr_nmprgexe|| ': '|| pr_indexecu;
      
        
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3, 
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => vr_desdolog, 
                                 pr_nmarqlog     => vr_nmarqlog,
                                 pr_cdprograma   => pr_nmprgexe);
      
                                
      -- Incluir log no proc_batch.log
      IF pr_idtiplog = 'I' THEN --> Inicio
        -- inicializar o tempo
        vr_tempo := to_char(SYSDATE,'SSSSS'); 
        
        vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> Inicio da execucao.';
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => vr_desdolog,
                                   pr_dstiplog     => 'I',
                                   pr_cdprograma   => pr_nmprgexe); 
                                   
      ELSIF pr_idtiplog = 'E' THEN --> ERRO             
        vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> ERRO:'||pr_indexecu;
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => vr_desdolog,
                                   pr_dstiplog     => 'E',
                                   pr_cdprograma   => pr_nmprgexe);
                                   
      ELSIF pr_idtiplog = 'F' THEN --> Fim         
        vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> Stored Procedure rodou em '|| 
                       -- calcular tempo de execução
                       to_char(to_date(to_char(SYSDATE,'SSSSS') - vr_tempo,'SSSSS'),'HH24:MI:SS');
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => vr_desdolog,                                   
                                   pr_dstiplog     => 'F',
                                   pr_cdprograma   => pr_nmprgexe); 
      END IF; 
                                                                           
    END pc_gera_log_execucao;
    
    -- Procedimento para reprogramar job que não pode ser rodados
    -- pois o processo da cooperativa ainda esta rodando
    PROCEDURE pc_reprograma_job(pr_job_name  IN VARCHAR2,
                                pr_dtreagen  IN DATE,
                                pr_dscritic OUT VARCHAR2) IS
        
      -- Identificar o Job e se o mesmo esta rodando
      CURSOR cr_job IS
        SELECT j.job_name,j.JOB_ACTION
          FROM Dba_Scheduler_Jobs         j
             -- ,Dba_Scheduler_Running_Jobs r
         WHERE j.owner = 'CECRED'
           AND upper(j.job_name) LIKE '%'||upper(pr_job_name)||'%';
      rw_job cr_job%ROWTYPE;   
        
      vr_jobname  VARCHAR2(100);  
      vr_dscritic VARCHAR2(1000);
        
        
    BEGIN
      -- Buscar dados do Job
      OPEN cr_job;
      FETCH cr_job INTO rw_job;        
        
      -- se encontrou o job
      IF cr_job%FOUND THEN
        CLOSE cr_job;
          
        --ANTES (13): CRPS688_16_P$ || _REP$ 913102
        --NOVO  (18): JBP_CRPS688_01_P$R || 1234567
        --NOVO  (18): JBP_DEBNET_01_P$R || 1234567
        IF instr(pr_job_name, 'CRPS688', 1, 1) > 1 THEN
          vr_jobname := substr(rw_job.job_name,1,17)||'R';
        ELSE
          vr_jobname := substr(rw_job.job_name,1,16)||'R';
        END IF;
        
        -- Max 18 chars para submit_job: A prefix cannot be longer than 18 characters and cannot end 
        -- with a digit. https://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_sched.htm#i1011296
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper              --> Código da cooperativa
                              ,pr_cdprogra  => upper(pr_job_name)       --> Código do programa
                              ,pr_dsplsql   => rw_job.job_action        --> Bloco PLSQL a executar
                              ,pr_dthrexe   => TO_TIMESTAMP_tz(to_char(pr_dtreagen,'DD/MM/RRRR HH24:MI'),
                                                                                   'DD/MM/RRRR HH24:MI') --> Incrementar mais 1 hora
                              ,pr_interva   => NULL                     --> apenas uma vez
                              ,pr_jobname   => vr_jobname               --> Nome randomico criado
                              ,pr_des_erro  => pr_dscritic);
      ELSE
        CLOSE cr_job;
        pr_dscritic := 'Não foi possivel reagendar job para procedimento '||pr_job_name||
                       ', job não encontrado.';           
      END IF;        
    END pc_reprograma_job;
    

         
  BEGIN
    
    vr_dtdiahoje := TRUNC(SYSDATE);
    
    --> Se for coop 3, deve criar o job para cada coop
    IF pr_cdcooper = 3 AND
       pr_cdprogra IS NULL THEN
      
      ------>>>>>> PRIMEIRA EXECUCAO DO DIA <<<<<<---------
      --> Buscar registros de definicao de horarios de execucao dos procedimentos
      FOR rw_craphec IN cr_craphec_pri LOOP
        
        -- Verificação do calendário
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craphec.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
        IF BTCH0001.cr_crapdat%NOTFOUND THEN     
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic:= 1;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_email;
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
          --> O JOB esta configurado para rodar de Segunda a Sexta
          -- Mas nao existe a necessidade de rodar nos feriados
          -- Por isso que validamos se o dia de hoje eh o dia do sistema
          -- E vamos para a próxima configuração da CRAPHEC
          continue;
        END IF;
        
        --> Verificar a execução da DEBNET e DEBSIC
        SICR0001.pc_controle_exec_deb ( pr_cdcooper  => rw_craphec.cdcooper        --> Código da coopertiva
                                      ,pr_cdtipope  => 'V'                         --> Tipo de operacao I-incrementar e C-Consultar
                                      ,pr_dtmvtolt  => vr_dtmvtolt                 --> Data do movimento                                
                                      ,pr_cdprogra  => rw_craphec.cdprogra         --> Codigo do programa                                  
                                      ,pr_flultexe  => vr_flultexe                 --> Retorna se é a ultima execução do procedimento
                                      ,pr_qtdexec   => vr_qtdexec                  --> Retorna a quantidade
                                      ,pr_cdcritic  => vr_cdcritic                 --> Codigo da critica de erro
                                      ,pr_dscritic  => vr_dscritic);               --> descrição do erro se ocorrer    
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          vr_dscritic := 'Falha na criacao do Job para execucao da '||rw_craphec.cdprogra||' (Coop:'||rw_craphec.cdcooper||'): '||vr_dscritic;
                           
          RAISE vr_exc_email; 
        END IF; 
                       
        -- JBP_CRPS688_01_P$1234567 JBP_DEBNET_01_P$1234567 JBP_DEBSIC_01_P$1234567
        vr_jobname := 'JBP_' || rw_craphec.cdprogra||'_'||to_char(rw_craphec.cdcooper, 'fm00')||'_P$'; 
        vr_dsplsql := 'begin cecred.PC_JOB_AGENDEB(pr_cdcooper => '||rw_craphec.cdcooper ||
                                                  ', pr_cdprogra => '''||rw_craphec.cdprogra ||''''||
                                                  ', pr_dsjobnam => '''||vr_jobname||'''); end;';
          
        -- Se for a primeira execucao do dia, agenda o job para o proximo minuto
        IF vr_qtdexec = 1 THEN
          
          vr_minuto := (1/24/60); --> 1 - minuto
          
          /*  ***** Não sera mais gerado DEBSIC e DEBNET de forma aut. como primeira execucao, será criada na craphec um horario fixo ****
          -- Se for DEBNET, incrementar para rodar depois de 5 minutos
          -- Para DEBSIC será em 31 min, pra ficar após o horario liberado de uso do Webservice Sicredi (07:30h)
          
          IF rw_craphec.cdprogra LIKE '%DEBSIC%' THEN
            vr_minuto := vr_minuto * 31; 
          ELSIF rw_craphec.cdprogra LIKE '%DEBNET%' THEN
            vr_minuto := vr_minuto * 5;
          END IF;*/
          
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper       --> Código da cooperativa
                                ,pr_cdprogra  => vr_cdprogra       --> Código do programa
                                ,pr_dsplsql   => vr_dsplsql        --> Bloco PLSQL a executar
                                ,pr_dthrexe   => TO_TIMESTAMP(to_char((SYSDATE + vr_minuto),'DD/MM/RRRR HH24:MI')||':'||to_char(rw_craphec.cdcooper,'fm00'),
                                                                                            'DD/MM/RRRR HH24:MI:SS') --> Incrementar mais 1 minuto
                                ,pr_interva   => NULL                     --> apenas uma vez
                                ,pr_jobname   => vr_jobname               --> Nome randomico criado
                                ,pr_des_erro  => vr_dscritic);

          IF TRIM(vr_dscritic) is not null THEN
            vr_dscritic := 'Falha na criacao do Job para execucao da '||rw_craphec.cdprogra||' (Coop:'||rw_craphec.cdcooper||' Job: '||vr_jobname||'): '|| vr_dscritic;
            RAISE vr_exc_email;              
          END IF;
        END IF;  
      END LOOP;
      
      ------>>>>>> DEMAIS EXECUCAO DO DIA <<<<<<---------
      --> Buscar registros de definicao de horarios de execucao dos procedimentos
      FOR rw_craphec IN cr_craphec LOOP
        -- Verificação do calendário
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_craphec.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic:= 1;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_email;
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
        
        /*M349 Tratamento para mais de uma execucao diaria dos programas
          DEBSIC, DEBNET, DEBBAN que terao um processo vespertino e um noturno alem
          do primeiro que roda logo apos o termino do processo da cooperativa*/
        IF rw_craphec.cdprogra <> 'CRPS688' THEN
           
           IF rw_craphec.dsprogra LIKE '%DIURNA%' THEN
              -- JBP_DEBNET_16_DIA1234567
              vr_jobname := 'JBP_'||rw_craphec.cdprogra||'_'||to_char(rw_craphec.cdcooper, 'fm00')||'_'||'DIA'; 
           
           ELSIF rw_craphec.dsprogra LIKE '%VESPERTINA%' THEN
              -- JBP_DEBNET_16_VES1234567
              vr_jobname := 'JBP_'||rw_craphec.cdprogra||'_'||to_char(rw_craphec.cdcooper, 'fm00')||'_'||'VES'; 
           ELSE
              vr_jobname := 'JBP_'||rw_craphec.cdprogra||'_'||to_char(rw_craphec.cdcooper, 'fm00')||'_'||'NOT'; 
           END IF;   
        ELSE   
          -- JBP_CRPS688_16_DIA1234567
          vr_jobname := 'JBP_'||rw_craphec.cdprogra||'_'||to_char(rw_craphec.cdcooper, 'fm00')||'_'||'DIA'; 
        END IF;
                                             
        vr_dsplsql := 'begin cecred.PC_JOB_AGENDEB(pr_cdcooper => '||rw_craphec.cdcooper ||
                                                  ', pr_cdprogra => '''||rw_craphec.cdprogra ||''''||
                                                  ', pr_dsjobnam => '''||vr_jobname||'''); end;';                                                                                                            
            
          --> Montar data da proxima execução conforme hec
        vr_dtprxexc := TO_TIMESTAMP_tz(to_char(vr_dtmvtolt ,'DD/MM/RRRR')||' '||
                         to_char(rw_craphec.dtiniexe,'HH24:MI')||':'||to_char(rw_craphec.cdcooper,'fm00')
                          ,'DD/MM/RRRR HH24:MI:SS');                    
          
          -- Se já passou o horario, não criar job e buscar proximo
          IF TO_TIMESTAMP(SYSDATE) > vr_dtprxexc THEN
            continue;
          END IF;
          
          --> Verificar se o job 
          OPEN cr_job (pr_job_name => vr_jobname);
          FETCH cr_job INTO rw_job;
          IF cr_job%FOUND THEN
            CLOSE cr_job;
            -- se ja foi criado o job, ir para o proximo registro
            IF vr_dtprxexc = rw_job.next_run_date THEN
              continue;
            --> Caso exista o job e na hec estiver desativado, deve dropar o job  
            ELSIF rw_craphec.flgativo = 0 THEN
              dbms_scheduler.drop_job(job_name => rw_job.job_name);
              gene0001.pc_gera_log_job(pr_cdcooper => pr_cdcooper
                                      ,pr_des_log  => '*******************************************************************************************************'||chr(13)||
                                             'Coop: '||pr_cdcooper||' --> Progr: '||vr_cdprogra||' Em: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||chr(13)||
                                             'JobNM: '||rw_job.job_name||' - Agendado para: '|| to_char(rw_job.next_run_date,'dd/mm/yyyy hh24:mi:ss')||chr(13)||
                                           ' Descricao: Job dropado devido a nao estar mais ativo na craphec.');
            -- Caso hora da hce seja diferente do Job, job deve ser reagendado
            ELSIF vr_dtprxexc <> rw_job.next_run_date THEN  
              
              dbms_scheduler.set_attribute(name      => rw_job.job_name, 
                                           attribute => 'start_date', 
                                           value     => vr_dtprxexc);
              
              gene0001.pc_gera_log_job(pr_cdcooper => pr_cdcooper
                                      ,pr_des_log  => '*******************************************************************************************************'||chr(13)||
                                             'Coop: '||pr_cdcooper||' --> Progr: '||vr_cdprogra||' Em: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||chr(13)||
                                             'JobNM: '||rw_job.job_name||' - Reagendado para: '|| to_char(vr_dtprxexc,'dd/mm/yyyy hh24:mi:ss'));
            END IF;
              
          --> Senao encontrou o job deve criar  
          ELSE
            CLOSE cr_job;    
            -- Faz a chamada ao programa paralelo atraves de JOB
            gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper     --> Código da cooperativa
                                  ,pr_cdprogra  => vr_cdprogra     --> Código do programa
                                  ,pr_dsplsql   => vr_dsplsql      --> Bloco PLSQL a executar
                                  ,pr_dthrexe   => vr_dtprxexc
                                  ,pr_interva   => NULL            --> apenas uma vez
                                  ,pr_jobname   => vr_jobname      --> Nome randomico criado
                                  ,pr_des_erro  => vr_dscritic);

            IF TRIM(vr_dscritic) is not null THEN
              vr_dscritic := 'Falha na criacao do Job para execucao da '||rw_craphec.cdprogra||' (Coop:'||rw_craphec.cdcooper||' Job: '||vr_jobname||'): '|| vr_dscritic;
              RAISE vr_exc_email;              
            END IF;
                    
          END IF; 
      END LOOP;  
    ELSE
      
      -- Valida se executa o job( testar de esta rodando o batch)
      gene0004.pc_executa_job( pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                              ,pr_fldiautl => 0             --> Flag se deve validar dia util
                              ,pr_flproces => 1             --> Flag se deve validar se esta no processo (true = não roda no processo)
                              ,pr_flrepjob => 0             --> Flag para reprogramar o job
                              ,pr_flgerlog => 1             --> indicador se deve gerar log
                              ,pr_nmprogra => pr_dsjobnam   --> Nome do programa que esta sendo executado no job
                              ,pr_dscritic => vr_dscritic);
      
      -- Se processo estiver rodando ainda, reprogramar job e enviar e-mail      
      IF TRIM(vr_dscritic) IS NOT NULL THEN

        -- Buscar quantidade em minutos para reagendar a JOB
        vr_minutos := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                pr_cdcooper => 0, 
                                                pr_cdacesso => 'QTD_MIN_REAGENDAMENTO');                            
        -- Transformar minuto em milisegundo  
        vr_tempo := vr_minutos/60/24;
 
        pc_reprograma_job(pr_job_name => pr_dsjobnam,
                          pr_dtreagen => SYSDATE + vr_tempo, --> reagendar para daqui a 5 min.
                          pr_dscritic => vr_dscritic);
        -- se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_email;
        END IF;                                   

        vr_dscritic := 'Processo noturno nao finalizado para cooperativa '||to_char(pr_cdcooper)||
                       ', job reagendado para '||to_char((SYSDATE + vr_tempo),'DD/MM/RRRR HH24:MI');        
                 
        -- mandar e-mail
        RAISE vr_exc_email;
      END IF;


      -- Se não retornou critica chama rotina, está online
      IF TRIM(vr_dscritic) IS NULL THEN
        
        -- Verificação do calendário
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
        IF BTCH0001.cr_crapdat%NOTFOUND THEN     
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic:= 1;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_email;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
        
        --> Verificar a execução da DEBNET e DEBSIC
        SICR0001.pc_controle_exec_deb ( pr_cdcooper  => pr_cdcooper  --> Código da coopertiva
                                          ,pr_cdtipope  => 'V'               --> Tipo de operacao I-incrementar e C-Consultar
                                          ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento                                
                                          ,pr_cdprogra  => pr_cdprogra       --> Codigo do programa                                  
                                          ,pr_flultexe  => vr_flultexe       --> Retorna se é a ultima execução do procedimento
                                          ,pr_qtdexec   => vr_qtdexec        --> Retorna a quantidade
                                          ,pr_cdcritic  => vr_cdcritic       --> Codigo da critica de erro
                                          ,pr_dscritic  => vr_dscritic);     --> descrição do erro se ocorrer    
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          vr_dscritic := 'Falha na execucao do Job da '|| pr_cdprogra||
                         ' (Coop:'||pr_cdcooper||'): '||vr_dscritic;                           
          RAISE vr_exc_email; 
        END IF;
        
        --> Buscar hora de execucao para saber se esta ativo
        rw_craphec_1 := NULL;
        OPEN cr_craphec_1;
        FETCH cr_craphec_1 INTO rw_craphec_1;
        CLOSE cr_craphec_1;
        
        -- se hce não estiver ativo e nao for a primeira execucao
        IF rw_craphec_1.flgativo = 0 AND 
           vr_qtdexec > 1 THEN
          -- deve abortar no caso esteja desativado a execução qnd nao for a primeira tentativa 
          vr_dscritic := 'Job '||pr_dsjobnam||' programado para '||to_char(SYSDATE,'DD/MM/RRRR')||' '||
                                                                   to_char(to_date(rw_craphec_1.hriniexe,'SSSSS'),'HH24:MI')||
                         ' nao foi executado pois craphec para processo  esta desativado.';
          RAISE vr_exc_email;
        END IF;
        
        --> Executar DEBNET/CRPS509
        IF upper(pr_cdprogra) = 'DEBNET' THEN
          
          /* Verificar se CRPS688 ja rodou neste dia */
          OPEN cr_craphec_2(pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_craphec_2 INTO rw_craphec_2;
          IF cr_craphec_2%NOTFOUND THEN                                           
            CLOSE cr_craphec_2;
            /*caso ainda não tenha rodado, deve reagendar para daqui a 5 minutos */
            pc_reprograma_job(pr_job_name => pr_dsjobnam,
                              pr_dtreagen => SYSDATE + ((1/24/60)* 5), --> reagendar para daqui a 5 min.
                              pr_dscritic => vr_dscritic); 
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_email;
            END IF;        
            
            vr_dscritic := 'CRPS688 ainda executando, job reagendado para '||to_char((SYSDATE + ((1/24/60)* 5)),'DD/MM/RRRR HH24:MI');
            RAISE vr_exc_email;
          END IF;
          CLOSE cr_craphec_2;  
        
          vr_cdprogra := 'CRPS509';
          -- Log de inicio de execucao
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                               pr_indexecu  => 'Inicio execucao',
                               pr_cdcooper  => pr_cdcooper, 
                               pr_tpexecuc  => NULL,
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                               pr_idtiplog  => 'I');
          --> Executar programa
          pc_crps509 (pr_cdcooper => pr_cdcooper, 
                      pr_flgresta => 0, 
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol, 
                      pr_cdcritic => vr_cdcritic, 
                      pr_dscritic => vr_dscritic);
          
          --> Tratamento de erro                                 
          IF vr_cdcritic > 0 OR
             vr_dscritic IS NOT NULL THEN 
             
            pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                                 pr_indexecu  => 'Fim execucao com critica: '||vr_dscritic ,
                                 pr_cdcooper  => pr_cdcooper, 
                                 pr_tpexecuc  => NULL,
                                 pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                 pr_idtiplog  => 'E');
                                
            RAISE vr_exc_email;              
          END IF;   
          
          --> Log de fim de execucao
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                               pr_indexecu  => 'Fim execucao',
                               pr_cdcooper  => pr_cdcooper, 
                               pr_tpexecuc  => NULL,
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                               pr_idtiplog  => 'F');
        
        --> Executar DEBDIC/CRPS642  
        ELSIF upper(pr_cdprogra) = 'DEBSIC' THEN  
          
          /* Verificar se CRPS688 ja rodou neste dia */
          OPEN cr_craphec_2(pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_craphec_2 INTO rw_craphec_2;
          IF cr_craphec_2%NOTFOUND THEN                                           
            CLOSE cr_craphec_2;
            /*caso ainda não tenha rodado, deve reagendar para daqui a 5 minutos */
            pc_reprograma_job(pr_job_name => pr_dsjobnam,
                              pr_dtreagen => SYSDATE + ((1/24/60)* 5), --> reagendar para daqui a 5 min.
                              pr_dscritic => vr_dscritic); 
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_email;
            END IF;        
            
            vr_dscritic := 'CRPS688 ainda executando, job reagendado para '||to_char((SYSDATE + ((1/24/60)* 5)),'DD/MM/RRRR HH24:MI');
            RAISE vr_exc_email;
          END IF;
          CLOSE cr_craphec_2;  
          
        
          vr_cdprogra := 'CRPS642';
          -- Log de inicio de execucao
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                               pr_indexecu  => 'Inicio execucao',
                               pr_cdcooper  => pr_cdcooper, 
                               pr_tpexecuc  => NULL,
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                               pr_idtiplog  => 'I');
          
          --> Executar programa
          pc_crps642 (pr_cdcooper => pr_cdcooper, 
                      pr_flgresta => 0, 
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol, 
                      pr_cdcritic => vr_cdcritic, 
                      pr_dscritic => vr_dscritic);
                      
          --> Tratamento de erro                         
          IF vr_cdcritic > 0 OR
             vr_dscritic IS NOT NULL THEN 
            pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                                 pr_indexecu  => 'Fim execucao com critica: '||vr_dscritic ,
                                 pr_cdcooper  => pr_cdcooper, 
                                 pr_tpexecuc  => NULL,
                                 pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                 pr_idtiplog  => 'E'); 
            RAISE vr_exc_email;              
          END IF;
          
          --> Log de fim de execucao
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                               pr_indexecu  => 'Fim execucao',
                               pr_cdcooper  => pr_cdcooper, 
                               pr_tpexecuc  => NULL,
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                               pr_idtiplog  => 'F');
                               
        --> Executar DEBSIC/CRPS688
        ELSIF upper(pr_cdprogra) = 'CRPS688' THEN
             
          vr_cdprogra := 'CRPS688';
          -- Log de inicio de execucao
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                               pr_indexecu  => 'Inicio execucao',
                               pr_cdcooper  => pr_cdcooper,
                               pr_tpexecuc  => NULL,
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                               pr_idtiplog  => 'I');

          --> Executar programa
          pc_crps688 (pr_cdcooper => pr_cdcooper,
                      pr_flgresta => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);
                      

          --> Tratamento de erro
          IF vr_cdcritic > 0 OR
             vr_dscritic IS NOT NULL THEN
            
             -- Atualizar craphec
             BEGIN
                UPDATE craphec
                   SET craphec.dtultexc = trunc(SYSDATE),
                       craphec.hrultexc = to_char(SYSDATE,'SSSSS')
                 WHERE craphec.rowid = rw_craphec_1.rowid;
                 
                 COMMIT;
             EXCEPTION
               WHEN OTHERS THEN
                  vr_dscritic := 'Job '||pr_dsjobnam||' nao foi executado pois ocorreu erro '||
                                 'ao atualizar craphec: '||SQLERRM;
                  RAISE vr_exc_email;
             END;
          
           
            pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                                 pr_indexecu  => 'Fim execucao com critica: '||vr_dscritic ,
                                 pr_cdcooper  => pr_cdcooper,
                                 pr_tpexecuc  => NULL,
                                 pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                 pr_idtiplog  => 'E');
            RAISE vr_exc_email;
          END IF;

          --> Log de fim de execucao
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                               pr_indexecu  => 'Fim execucao',
                               pr_cdcooper  => pr_cdcooper,
                               pr_tpexecuc  => NULL,
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                               pr_idtiplog  => 'F');

        --> Executar DEBBAN/PAGA0003.pc_processa_agend_bancoob  
        ELSIF upper(pr_cdprogra) = 'DEBBAN' THEN  
          
          --> Verificar se CRPS688 ja rodou neste dia
          OPEN cr_craphec_2(pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_craphec_2 INTO rw_craphec_2;
          IF cr_craphec_2%NOTFOUND THEN                                           
            CLOSE cr_craphec_2;
            /*caso ainda não tenha rodado, deve reagendar para daqui a 5 minutos */
            pc_reprograma_job(pr_job_name => pr_dsjobnam,
                              pr_dtreagen => SYSDATE + ((1/24/60)* 5), --> reagendar para daqui a 5 min.
                              pr_dscritic => vr_dscritic); 
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_email;
            END IF;        
            
            vr_dscritic := 'CRPS688 ainda executando, job reagendado para '||to_char((SYSDATE + ((1/24/60)* 5)),'DD/MM/RRRR HH24:MI');
            RAISE vr_exc_email;
          END IF;
          CLOSE cr_craphec_2;  
          
        
          vr_cdprogra := 'DEBBAN';
          -- Log de inicio de execucao
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                               pr_indexecu  => 'Inicio execucao',
                               pr_cdcooper  => pr_cdcooper, 
                               pr_tpexecuc  => NULL,
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                               pr_idtiplog  => 'I');
          
          --> Executar programa
          PAGA0003.pc_processa_agend_bancoob   
                     (pr_cdcooper => pr_cdcooper, 
                      pr_cdcritic => vr_cdcritic, 
                      pr_dscritic => vr_dscritic);
                      
          --> Tratamento de erro                         
          IF vr_cdcritic > 0 OR
             vr_dscritic IS NOT NULL THEN 
            pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                                 pr_indexecu  => 'Fim execucao com critica: '||vr_dscritic ,
                                 pr_cdcooper  => pr_cdcooper, 
                                 pr_tpexecuc  => NULL,
                                 pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                                 pr_idtiplog  => 'E'); 
            RAISE vr_exc_email;              
          END IF;
          
          --> Log de fim de execucao
          pc_gera_log_execucao(pr_nmprgexe  => vr_cdprogra,
                               pr_indexecu  => 'Fim execucao',
                               pr_cdcooper  => pr_cdcooper, 
                               pr_tpexecuc  => NULL,
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                               pr_idtiplog  => 'F');
                               

        END IF;
        
        -- Atualizar craphec
        BEGIN
          UPDATE craphec
             SET craphec.dtultexc = trunc(SYSDATE),
                 craphec.hrultexc = to_char(SYSDATE,'SSSSS')
           WHERE craphec.rowid = rw_craphec_1.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Job '||pr_dsjobnam||' nao foi executado pois ocorreu erro '||
                           'ao atualizar crapche: '||SQLERRM;
            RAISE vr_exc_email;
        END;

      END IF;
    END IF; -- fim IF coop = 3
    
    COMMIT;  
  EXCEPTION
    WHEN vr_exc_email THEN
      -- Efetuar rollback
      ROLLBACK;
      
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                 pr_dstiplog     => 'E',
                                 pr_cdprograma   => pr_dsjobnam,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_JOB');
      
      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('ERRO NA EXECUCAO JOB:'|| pr_dsjobnam          ||
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')||                      
                     '<br>Critica: '         || vr_dscritic,1,4000);
                      
      vr_dscritic := NULL;
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'PC_JOB_AGENDEB'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB:'|| pr_dsjobnam 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;                              
    WHEN OTHERS THEN

      vr_dscritic := SQLERRM;      
      -- Efetuar rollback
      ROLLBACK;
      
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_JOB');
      
      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('ERRO NA EXECUCAO JOB:'|| pr_dsjobnam          ||
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')||                      
                     '<br>Critica: '         || vr_dscritic,1,4000);
                      
      CECRED.pc_internal_exception(pr_cdcooper, vr_conteudo);
                      
      vr_dscritic := NULL;
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'PC_JOB_AGENDEB'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB:'|| pr_dsjobnam 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT; 
      
 END PC_JOB_AGENDEB;
/
