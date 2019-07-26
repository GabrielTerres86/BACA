CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_AGENDEBTED(pr_cdcooper in crapcop.cdcooper%TYPE,
                                                     pr_cdprogra IN crapprg.cdprogra%TYPE,
                                                     pr_dsjobnam IN VARCHAR2) IS
 /* ..........................................................................

   JOB: PC_JOB_AGENDEBTED
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Adriano 
   Data    : Maio/2016.                     Ultima atualizacao: 07/03/2017

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Controlar a execução dos programas CRPS705 que efetivam os agendamentos de TED.
               Rotina cria novos jobs para execução paralela dos programas para cada cooperativa, 
               a primeira execução do dia ocorre de forma imediata, logo após o job ser criado, 
               caso o processo batch da cooperativa esteja rodando o job é reagendado para 
               a proxima hora. 
              
   Alteracoes:
   
   15/09/2016 - #519637 Criação de log de controle de início, erros e fim de execução do job (Carlos)
   
   02/01/2017 - Adição de filtro para não agendar o job para cooperativas inativas (Anderson).
   
   07/03/2017 - Ajuste para aumentar o tamanho da variável vr_jobname (Adriano - SD 625356 ).
   
   17/05/2019 - Ajuste para evitar criar agendamentos já expirados na execução desta rotina.
                Evitando com isso, que o processo de efetivação dos agendamentos rode em duplicidade 
                durante o dia, igual ao erro que tivemos em 15/05/2019. (Wagner  - PRB004791).
   
   10/07/2019 - Ajuste para não executar o job se processo noturno estiver executando. (Andre MoutS - INC0013286)		
   
  ..........................................................................*/
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    VARCHAR2(40) := 'PC_JOB_AGENDEBTED';
    vr_nomdojob    VARCHAR2(40) := 'JBCOMPE_AGENDAMENTO_TED';
    vr_flgerlog    BOOLEAN := FALSE;
      
    vr_infimsol    PLS_INTEGER;                     
    vr_stprogra    PLS_INTEGER;
    
    vr_exc_email   EXCEPTION;
    vr_cdcritic    PLS_INTEGER;                     
    vr_dscritic    VARCHAR2(4000);

    vr_dtdiahoje   DATE;
    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(100);
    
    vr_dtmvtolt    DATE;
    
    vr_email_dest  VARCHAR2(1000); 
    vr_conteudo    VARCHAR2(4000);
    
    -- Variáveis de controle de calendário
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;    
    vr_intipmsg    PLS_INTEGER; 
    
    -- Selecionar os dados da Cooperativa
    CURSOR cr_crapcop IS
     SELECT cop.cdcooper
           ,cop.nmrescop
           ,cop.nrtelura
           ,cop.cdbcoctl
           ,cop.cdagectl
           ,cop.dsdircop
           ,cop.nrctactl
     FROM crapcop cop
     WHERE cop.cdcooper <> 3
       AND cop.flgativo = 1;

    CURSOR cr_agendamento IS
      WITH horarios AS (
      SELECT trim(substr(craptab.dstextab,1,2))||':'||trim(substr(craptab.dstextab,3,2)) hora_exec,
             trim(substr(craptab.dstextab,1,2))||trim(substr(craptab.dstextab,3,2)) hora_exec_n,
             1 ordem_exec
        FROM craptab
       WHERE craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'GENERI'
         AND craptab.cdempres = 00
         AND craptab.cdacesso = 'HRAGENDEBTED'
         AND craptab.cdcooper = 0
      UNION ALL
      SELECT trim(substr(craptab.dstextab,6,2))||':'||trim(substr(craptab.dstextab,8,2)) hora_exec,
             trim(substr(craptab.dstextab,6,2))||trim(substr(craptab.dstextab,8,2)) hora_exec_n,
             2 ordem_exec
        FROM craptab
       WHERE craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'GENERI'
         AND craptab.cdempres = 00
         AND craptab.cdacesso = 'HRAGENDEBTED'
         AND craptab.cdcooper = 0
      UNION ALL
      SELECT trim(substr(craptab.dstextab,11,2))||':'||trim(substr(craptab.dstextab,13,2)) hora_exec,
             trim(substr(craptab.dstextab,11,2))||trim(substr(craptab.dstextab,13,2)) hora_exec_n,
             3 ordem_exec
        FROM craptab
       WHERE craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'GENERI'
         AND craptab.cdempres = 00
         AND craptab.cdacesso = 'HRAGENDEBTED'
         AND craptab.cdcooper = 0)
      -- Só irá gerar os agendamentos futuros,
      -- horários já passados serão ignorados.  
      SELECT h.hora_exec,
             hora_exec_n,
             ordem_exec
        FROM horarios h
       WHERE hora_exec_n >= to_char(SYSDATE,'hh24mi') 
       ORDER BY ordem_exec;

    CURSOR cr_job_duplicado(pr_job_name IN VARCHAR2) IS
      SELECT COUNT(*) qtde
        FROM dba_scheduler_jobs job
       WHERE job.owner                = 'CECRED' --Fixo
         AND job.job_name             LIKE pr_job_name||'%' -- mesmo job, mesma cooperativa e mesmo horário do dia
         AND TRUNC(job.next_run_date) = TRUNC(SYSDATE); -- JOBS de hoje
    
    vr_qtexecucao_job NUMBER;
    
    
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
    
    vr_dtdiahoje := TRUNC(SYSDATE);
    
    --> Se for coop 3, deve criar o job para cada coop
    IF pr_cdcooper = 3 THEN
      
      --> Busca todas as cooperativas com exceção da CECRED
      FOR rw_crapcop IN cr_crapcop LOOP
        
        -- Verificação do calendário
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        
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
          --> O JOB esta confirgurado para rodar de Segunda a Sexta
          -- Mas nao existe a necessidade de rodar nos feriados
          -- Por isso que validamos se o dia de hoje eh o dia do sistema          
          continue;
        END IF;
        
        FOR rw_agendamento IN cr_agendamento LOOP
          vr_jobname := 'PC_CRPS705_'||rw_agendamento.ordem_exec||rw_crapcop.cdcooper||'$';
          
          -- Evitar gerar o mesmo job para o mesmo horário do dia
          OPEN cr_job_duplicado(vr_jobname);
            FETCH cr_job_duplicado
             INTO vr_qtexecucao_job;
          CLOSE cr_job_duplicado;   
          
          -- Se ainda não existe, permite a criação.
          IF vr_qtexecucao_job = 0 THEN
            
            vr_dsplsql := 'begin cecred.PC_JOB_AGENDEBTED(pr_cdcooper => '||rw_crapcop.cdcooper ||
                                                        ',pr_cdprogra => '' PC_CRPS705  '''||
                                                        ',pr_dsjobnam => '''||vr_jobname||'''); end;';
            
            -- Faz a chamada ao programa paralelo atraves de JOB
            gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper       --> Código da cooperativa
                                  ,pr_cdprogra  => vr_cdprogra       --> Código do programa
                                  ,pr_dsplsql   => vr_dsplsql        --> Bloco PLSQL a executar
                                  ,pr_dthrexe   => TO_TIMESTAMP(to_char((SYSDATE),'DD/MM/RRRR ')||rw_agendamento.hora_exec||':'||to_char(rw_crapcop.cdcooper,'fm00'),
                                                                                  'DD/MM/RRRR HH24:MI:SS') --> Incrementar mais 1 minuto
                                  ,pr_interva   => NULL                     --> apenas uma vez
                                  ,pr_jobname   => vr_jobname               --> Nome randomico criado
                                  ,pr_des_erro  => vr_dscritic);

            IF TRIM(vr_dscritic) is not null THEN
              vr_dscritic := 'Falha na criacao do Job para execucao da '||vr_cdprogra||' (Coop:'||rw_crapcop.cdcooper||' Job: '||vr_jobname||'): '|| vr_dscritic;
              RAISE vr_exc_email;              
            END IF;
          END IF;
        END LOOP;
      END LOOP;  
    ELSE
      
      -- Valida se executa o job( testar de esta rodando o batch)
      gene0004.pc_trata_exec_job(pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                                ,pr_fldiautl => 0             --> Flag se deve validar dia util
                                ,pr_flproces => 1             --> Flag se deve validar se esta no processo (true = não roda no processo)
                                ,pr_flrepjob => 1             --> Flag para reprogramar o job
                                ,pr_flgerlog => 1             --> indicador se deve gerar log
                                ,pr_nmprogra => pr_dsjobnam   --> Nome do programa que esta sendo executado no job
                                ,pr_intipmsg => vr_intipmsg
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      
      -- se nao retornou critica  chama rotina
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
        
        -- Log de inicio de execucao
        pc_controla_log_batch(pr_dstiplog => 'I');
                             
        --> Executar programa
        pc_crps705 (pr_cdcooper => pr_cdcooper, 
                    pr_flgresta => 0, 
				          	pr_execucao => TO_NUMBER(SUBSTR(pr_dsjobnam,12,1)),
                    pr_stprogra => vr_stprogra,
                    pr_infimsol => vr_infimsol, 
                    pr_cdcritic => vr_cdcritic, 
                    pr_dscritic => vr_dscritic);
          
        --> Tratamento de erro                                 
        IF vr_cdcritic > 0 OR
           vr_dscritic IS NOT NULL THEN 
             
          pc_controla_log_batch(pr_dstiplog => 'E',
                                pr_dscritic => vr_dscritic);
                                
          RAISE vr_exc_email;    
                    
        END IF;   
          
        --> Log de fim de execucao
        pc_controla_log_batch(pr_dstiplog => 'F');
        
      ELSE 
        RAISE vr_exc_email;
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
                                ,pr_cdprogra        => 'PC_JOB_AGENDEBTED'
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
                      
      vr_dscritic := NULL;
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'PC_JOB_AGENDEBTED'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB:'|| pr_dsjobnam 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT; 
      
 END PC_JOB_AGENDEBTED;
/
