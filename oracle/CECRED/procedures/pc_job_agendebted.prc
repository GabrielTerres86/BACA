CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_AGENDEBTED(pr_cdcooper in crapcop.cdcooper%TYPE,
                                                     pr_cdprogra IN crapprg.cdprogra%TYPE,
                                                     pr_dsjobnam IN VARCHAR2) IS
 /* ..........................................................................

   JOB: PC_JOB_AGENDEBTED
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Adriano 
   Data    : Maio/2016.                     Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Controlar a execução dos programas CRPS705 que efetivam os agendamentos de TED.
               Rotina cria novos jobs para execução paralela dos programas para cada cooperativa, 
               a primeira execução do dia ocorre de forma imediata, logo após o job ser criado, 
               caso o processo batch da cooperativa esteja rodando o job é reagendado para 
               a proxima hora. 
              
   Alteracoes:
   
  ..........................................................................*/
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    VARCHAR2(40) := 'PC_JOB_AGENDEBTED';
    vr_infimsol    PLS_INTEGER;                     
    vr_stprogra    PLS_INTEGER;
    
    vr_exc_email   EXCEPTION;
    vr_cdcritic    PLS_INTEGER;                     
    vr_dscritic    VARCHAR2(4000);

    vr_dtdiahoje   DATE;
    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(20);
    
    vr_dtmvtolt    DATE;
    
    vr_email_dest  VARCHAR2(1000); 
    vr_conteudo    VARCHAR2(4000);
    vr_tempo       NUMBER;
    
    -- Variáveis de controle de calendário
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;    
    
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
     WHERE cop.cdcooper <> 3;
    
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
                                 pr_nmarqlog     => vr_nmarqlog);
      
                                
      -- Incluir log no proc_batch.log
      IF pr_idtiplog = 'I' THEN --> Inicio
        -- inicializar o tempo
        vr_tempo := to_char(SYSDATE,'SSSSS'); 
        
        vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> Inicio da execucao.';
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => vr_desdolog); 
                                   
      ELSIF pr_idtiplog = 'E' THEN --> ERRO             
        vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> ERRO:'||pr_indexecu;
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => vr_desdolog);
                                   
      ELSIF pr_idtiplog = 'F' THEN --> Fim         
        vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| vr_cdprogra ||
                       ' --> Stored Procedure rodou em '|| 
                       -- calcular tempo de execução
                       to_char(to_date(to_char(SYSDATE,'SSSSS') - vr_tempo,'SSSSS'),'HH24:MI:SS');
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                   pr_ind_tipo_log => 1, 
                                   pr_des_log      => vr_desdolog); 
      END IF; 
                                                                           
    END pc_gera_log_execucao;
    
         
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
        
        vr_jobname := 'PC_CRPS705_'||rw_crapcop.cdcooper||'$';
        vr_dsplsql := 'begin cecred.PC_JOB_AGENDEBTED(pr_cdcooper => '||rw_crapcop.cdcooper ||
                                                    ',pr_cdprogra => '' PC_CRPS705  '''||
                                                    ',pr_dsjobnam => '''||vr_jobname||'''); end;';
          
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper       --> Código da cooperativa
                              ,pr_cdprogra  => vr_cdprogra       --> Código do programa
                              ,pr_dsplsql   => vr_dsplsql        --> Bloco PLSQL a executar
                              ,pr_dthrexe   => TO_TIMESTAMP(to_char((SYSDATE),'DD/MM/RRRR HH24:MI')||':'||to_char(rw_crapcop.cdcooper,'fm00'),
                                                                              'DD/MM/RRRR HH24:MI:SS') --> Incrementar mais 1 minuto
                              ,pr_interva   => NULL                     --> apenas uma vez
                              ,pr_jobname   => vr_jobname               --> Nome randomico criado
                              ,pr_des_erro  => vr_dscritic);

        IF TRIM(vr_dscritic) is not null THEN
          vr_dscritic := 'Falha na criacao do Job para execucao da '||vr_cdprogra||' (Coop:'||rw_crapcop.cdcooper||' Job: '||vr_jobname||'): '|| vr_dscritic;
          RAISE vr_exc_email;              
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
        pc_gera_log_execucao(pr_nmprgexe  => pr_cdprogra,
                             pr_indexecu  => 'Inicio execucao',
                             pr_cdcooper  => pr_cdcooper, 
                             pr_tpexecuc  => NULL,
                             pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                             pr_idtiplog  => 'I');
                             
        --> Executar programa
        pc_crps705 (pr_cdcooper => pr_cdcooper, 
                    pr_flgresta => 0, 
                    pr_stprogra => vr_stprogra,
                    pr_infimsol => vr_infimsol, 
                    pr_cdcritic => vr_cdcritic, 
                    pr_dscritic => vr_dscritic);
          
        --> Tratamento de erro                                 
        IF vr_cdcritic > 0 OR
           vr_dscritic IS NOT NULL THEN 
             
          pc_gera_log_execucao(pr_nmprgexe  => pr_cdprogra,
                               pr_indexecu  => 'Fim execucao com critica: '||vr_dscritic ,
                               pr_cdcooper  => pr_cdcooper, 
                               pr_tpexecuc  => NULL,
                               pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                               pr_idtiplog  => 'E');
                                
          RAISE vr_exc_email;    
                    
        END IF;   
          
        --> Log de fim de execucao
        pc_gera_log_execucao(pr_nmprgexe  => pr_cdprogra,
                             pr_indexecu  => 'Fim execucao',
                             pr_cdcooper  => pr_cdcooper, 
                             pr_tpexecuc  => NULL,
                             pr_dtmvtolt  => rw_crapdat.dtmvtolt,
                             pr_idtiplog  => 'F');
        
        
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
