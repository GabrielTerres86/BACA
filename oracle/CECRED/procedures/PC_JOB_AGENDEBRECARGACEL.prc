CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_AGENDEBRECARGACEL(pr_cdcooper in crapcop.cdcooper%TYPE,
                                                            pr_cdprogra IN crapprg.cdprogra%TYPE,
                                                            pr_dsjobnam IN VARCHAR2) IS
 /* ..........................................................................

   JOB: PC_JOB_AGENDEBTED
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Lombardi
   Data    : Março/2017.                     Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Efetivar os agendamentos de recarga de celular em todas as cooperativas.
               Rotina cria novos jobs para execução paralela dos programas para cada cooperativa.
               Caso o processo batch da cooperativa esteja rodando o job é reagendado para 
               a proxima hora. 
              
   Alteracoes:
   
  ..........................................................................*/
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    VARCHAR2(40);
    
    vr_idprglog    tbgen_prglog.idprglog%TYPE := 0;
    
    vr_exc_erro    EXCEPTION;
    vr_cdcritic    PLS_INTEGER;                     
    vr_dscritic    VARCHAR2(4000);

    vr_dtdiahoje   DATE;
    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(200);
    
    vr_dtmvtolt    DATE;
    vr_flultexe    INTEGER;
    vr_qtdexec     INTEGER;
      
    vr_email_dest  VARCHAR2(1000); 
    vr_conteudo    VARCHAR2(4000);
    
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
     WHERE cop.cdcooper <> 3
       AND cop.flgativo = 1;
        
  BEGIN
    
    IF pr_cdprogra IS NOT NULL THEN
      vr_cdprogra := pr_cdprogra;
    ELSE
      vr_cdprogra := 'PC_JOB_AGENDEBRECARGACEL';
    END IF;
    
    -- Gera log no início da execução
    pc_log_programa(PR_DSTIPLOG   => 'I'           --> Tipo do log: I - início; F - fim; O - ocorrência
                   ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                   ,pr_cdcooper   => pr_cdcooper   --> Codigo da Cooperativa
                   ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    -- Parametros para Ocorrencia
                   ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)
			
    
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
        
        vr_jobname := 'JBRCEL_debage_'||rw_crapcop.cdcooper||'$';
        vr_dsplsql := 'begin cecred.PC_JOB_AGENDEBRECARGACEL(pr_cdcooper => '||rw_crapcop.cdcooper ||
                                                           ',pr_cdprogra => ''JBRCEL_debita_agendamento_recarga'''||
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
          RAISE vr_exc_erro;              
        END IF;
        
      END LOOP;  
    ELSE
      
      -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
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
        
        /* Procedimento para verificar/controlar a execução da DEBNET e DEBSIC */
        SICR0001.pc_controle_exec_deb (pr_cdcooper => pr_cdcooper         --> Código da coopertiva
                                      ,pr_cdtipope => 'I'                 --> Tipo de operacao I-incrementar e C-Consultar
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movimento 
                                      ,pr_cdprogra => 'JOBAGERCEL'        --> Codigo do programa 
                                      ,pr_flultexe => vr_flultexe         --> Retorna se é a ultima execução do procedimento
                                      ,pr_qtdexec  => vr_qtdexec          --> Retorna a quantidade
                                      ,pr_cdcritic => vr_cdcritic         --> Codigo da critica de erro
                                      ,pr_dscritic => vr_dscritic);       --> descrição do erro se ocorrer
        
        IF nvl(vr_cdcritic,0) > 0 OR
          TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro; 
        END IF;
        
        --> Executar programa
        RCEL0001.pc_proces_agendamentos_recarga (pr_cdcooper => pr_cdcooper
                                                ,pr_nmdatela => 'JOBAGERCEL'
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
          
        --> Tratamento de erro                                 
        IF vr_cdcritic > 0 OR
           vr_dscritic IS NOT NULL THEN 
          RAISE vr_exc_erro;          
        END IF;   
        
      ELSE 
        RAISE vr_exc_erro;
      END IF;
      
    END IF; -- fim IF coop = 3
    
		pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
									 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
									 ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
										-- Parametros para Ocorrencia
									 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
		
    COMMIT;  
    
  EXCEPTION
    WHEN vr_exc_erro THEN
			ROLLBACK;
      
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
			pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; E - Erro; O - ocorrência
										 ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_cdcooper   => pr_cdcooper   --> Codigo da Cooperativa
                     ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,pr_tpocorrencia  => 3             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
										 ,pr_cdcriticidade => 0             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
										 ,pr_dsmensagem    => vr_dscritic   --> Crítica
										 ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
										 ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

			pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
										 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
                     ,pr_cdcooper   => pr_cdcooper   --> Codigo da Cooperativa
                     ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
			COMMIT;                              		
    WHEN OTHERS THEN
			ROLLBACK;        
			
      vr_dscritic := 'Erro não tratado na execução da procedure pc_solicita_produtos_recarga -> '||SQLERRM;
      
      pc_log_programa(PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; E - Erro; O - ocorrência
										 ,PR_CDPROGRAMA    => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
										 ,pr_cdcriticidade => 0             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
										 ,pr_dsmensagem    => vr_dscritic   --> dscritic       
										 ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
										 ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

			pc_log_programa(PR_DSTIPLOG   => 'F'           --> Tipo do log: I - início; F - fim; O - ocorrência
										 ,PR_CDPROGRAMA => vr_cdprogra   --> Codigo do programa ou do job
										 ,pr_tpexecucao => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
											-- Parametros para Ocorrencia
										 ,PR_IDPRGLOG   => vr_idprglog); --> Identificador unico da tabela (sequence)                          
										 
			-- buscar destinatarios do email                           
			vr_email_dest := gene0001.fn_param_sistema('CRED',3 ,'ERRO_EMAIL_JOB');
        
			-- Gravar conteudo do email, controle com substr para não estourar campo texto
			vr_conteudo := substr('ERRO NA EXECUCAO JOB: JBRCEL_atualiza_produtos_recarga' ||
										 '<br>Cooperativa: '     || to_char(3, '990')||                      
										 '<br>Critica: '         || vr_dscritic,1,4000);
                        
			vr_dscritic := NULL;
			--/* Envia e-mail para o Operador */
			gene0003.pc_solicita_email(pr_cdcooper        => 3
																,pr_cdprogra        => vr_cdprogra
																,pr_des_destino     => vr_email_dest
																,pr_des_assunto     => 'ERRO NA EXECUCAO JOB: ' || pr_dsjobnam
																,pr_des_corpo       => vr_conteudo
																,pr_des_anexo       => NULL
																,pr_flg_remove_anex => 'N' --> Remover os anexos passados
																,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
																,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
																,pr_des_erro        => vr_dscritic);
										 
			COMMIT;
 END PC_JOB_AGENDEBRECARGACEL;
/
