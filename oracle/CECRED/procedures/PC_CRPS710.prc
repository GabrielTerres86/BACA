CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS710(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                              pr_dsjobnam IN VARCHAR2 ) IS
 /* ..........................................................................

    Programa: PC_CRPS710
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Odirlei
    Data    : Abril/2017                      Ultima Atualizacao: 08/07/2019
    Dados referente ao programa:

    Frequencia: Diario.
    Objetivo  : Renovacao automatica do limite de desconto de cheque - Chamada Job.

   Alteracoes:
  
              13/04/2018 - 1 - Tratado Others na geração da tabela tbgen erro de sistema
                           2 - Seta Modulo
                           3 - Eliminada mensagem fixas
                           4 - Criada PROCEDURE pc_log para centralizar chamada externa do log
                           5 - Dispare PROCEDURE pc_trata_exec_job para tratar a descrição de criticas 
                               no sentido de não mais utilizar descrição como condição de decisão
                               Agora com flag de não disparar Log pois está vai criar o log
                           6 - Criado o retorno na gene0004 o pr_intipmsg tipo de mensagem a ser tratada:
                                 1 - Padrão: Os programas tratam com a regra atual.
                                 2 - Grupo de mensagens para não parar o programa: 
                                     Procedures PC_CRPS710 e pc_gera_dados_cyber não gera critica.
                                 3 - Grupo de mensagens para não parar o programa: 
                                     Procedures pc_job_contab_cessao, PC_CRPS710 e pc_gera_dados_cyber não gera critica.    
                          (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)

              08/07/2019 - PRB0041950 na rotina pc_submit_job, ajustado o parâmetro pr_dthrexe para enviar a data formatada
                           em timestamp com timezone (Carlos)

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

  -- Excluida variavel vr_minuto não é "mais" utilizada - Chmd REQ0011757 - 13/04/2018  
  vr_nomdojob    CONSTANT VARCHAR2(100) := 'jbchq_crps710';
  -- Excluida variavel vr_flgerlog não é utilizada - Chmd REQ0011757 - 13/04/2018  
  vr_intipmsg   INTEGER := 1; -- pr_intipmsg tipo de mensagem a ser tratada especificamente - Chmd REQ0011757 - 13/04/2018 

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
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                 ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                 ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                 ,pr_tpexecuc IN NUMBER   DEFAULT 2   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_flgsuces IN NUMBER   DEFAULT 1    -- Indicador de sucesso da execução  
                                 ,pr_flabrchd IN INTEGER  DEFAULT 0    -- Abre chamado 1 Sim/ 0 Não
                                 ,pr_textochd IN VARCHAR2 DEFAULT NULL -- Texto do chamado
                                 ,pr_desemail IN VARCHAR2 DEFAULT NULL -- Destinatario do email
                                 ,pr_flreinci IN INTEGER  DEFAULT 0    -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado
  ) 
  IS
    -- ..........................................................................
    --
    --  Programa : pc_controla_log_batch
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Autor    : Envolti - Belli - Chamado REQ0011757
    --  Data     : 13/04/2018                        Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Chamar a rotina de Log para gravação de criticas.
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;        
  BEGIN   
    -- Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdcooper      => NVL(pr_cdcooper,0)
                          ,pr_flgsucesso    => pr_flgsuces
                          ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                          ,pr_texto_chamado => pr_textochd
                          ,pr_destinatario_email => pr_desemail
                          ,pr_flreincidente => pr_flreinci
                          ,pr_cdprograma    => vr_nomdojob
                          ,pr_idprglog      => vr_idprglog
                          );   
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  END pc_controla_log_batch;  

BEGIN                                                           --- --- --- INICIO DO PROCESSO    
  -- Incluido nome do módulo logado - Chmd REQ0011757 - 13/04/2018
  GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);

  -- Log de inicio de execucao
  pc_controla_log_batch(pr_dstiplog => 'I');      
   
  vr_dtdiahoje := TRUNC(SYSDATE);

  --> Se for coop 3, deve criar o job para cada coop
  IF pr_cdcooper = 3 THEN

    FOR rw_crapcop IN cr_crapcop LOOP

      -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica - Chmd REQ0011757 - 13/04/2018
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                      ' pr_cdcooper:'   || pr_cdcooper ||
                      ', pr_dsjobnam:'   || pr_dsjobnam ||  
                      ', rw_crapcop.cdcooper:' || rw_crapcop.cdcooper;
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

      -- Excluido vr_minuto := (1/24/60); --> 1 - minuto - Chmd REQ0011757 - 13/04/2018           
      -- A submissão marca que executa por minuto mas executa por segundo, alem de dar erro se a cooperativa é maior que 59
      -- Ajustei para o programa somar em segundos o valor da cooperativa
      -- Faz a chamada ao programa paralelo atraves de JOB
      gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper       --> Código da cooperativa
                            ,pr_cdprogra  => vr_cdprogra       --> Código do programa
                            ,pr_dsplsql   => vr_dsplsql        --> Bloco PLSQL a executar
                            ,pr_dthrexe   => to_timestamp_tz(to_char(CAST(current_timestamp AT TIME ZONE 'AMERICA/SAO_PAULO' AS timestamp)+(NVL(rw_crapcop.cdcooper,0)/86400)
                                                                    ,'ddmmyyyyhh24miss')||' AMERICA/SAO_PAULO','ddmmyyyyhh24miss TZR') --> Incrementar cdcooper segundos
                            ,pr_interva   => NULL              --> apenas uma vez
                            ,pr_jobname   => vr_jobname        --> Nome randomico criado
                            ,pr_des_erro  => vr_dscritic);

      IF TRIM(vr_dscritic) is not null THEN
        -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
        vr_cdcritic := 1197;  
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                       ' - ' || vr_dscritic ||
                       '. pr_cdcooper:'    || pr_cdcooper ||
                       ', pr_dsjobnam:'    || pr_dsjobnam ||
                       ', vr_jobname:'     || vr_jobname  ||
                       ', vr_intipmsg:'    || vr_intipmsg || 
                       ', rw_crapcop.cdcooper:' || rw_crapcop.cdcooper;
        RAISE vr_exc_erro;
      END IF;

    END LOOP;

  ELSE
    -- Troca da pc_executa_job para pc_trata_exec_job agora trata tipo de critica - Chmd REQ0011757 - 13/04/2018
    -- Indicador se deve gerar log colocado como não gerar Log 0 pois esta prc vai gerar - Chmd REQ0011757 - 13/04/2018
    -- Valida se executa o job( testar de esta rodando o batch)
    gene0004.pc_trata_exec_job(pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                              ,pr_fldiautl => 0             --> Flag se deve validar dia util
                              ,pr_flproces => 1             --> Flag se deve validar se esta no processo (true = não roda no processo)
                              ,pr_flrepjob => 1             --> Flag para reprogramar o job
                              ,pr_flgerlog => 0             --> indicador se deve gerar log
                              ,pr_nmprogra => pr_dsjobnam   --> Nome do programa que esta sendo executado no job
                              ,pr_intipmsg => vr_intipmsg
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic
                              );
    -- se nao retornou critica  chama rotina
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    -- Retorna nome do módulo logado - Chmd REQ0011757 - 13/04/2018
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);  

    --> Executar programa
    pc_crps710_I (pr_cdcooper => pr_cdcooper,
                  pr_cdcritic => vr_cdcritic,
                  pr_dscritic => vr_dscritic);
    --> Tratamento de erro
    IF vr_cdcritic > 0 OR
       vr_dscritic IS NOT NULL THEN
      vr_dscritic := vr_dscritic   ||
                   '. pr_cdcooper:'   || pr_cdcooper ||
                   ', pr_dsjobnam:'   || pr_dsjobnam ||
                   ', vr_intipmsg:'   || vr_intipmsg;
      RAISE vr_exc_erro;
    END IF;
    -- Retorna nome do módulo logado - Chmd REQ0011757 - 13/04/2018
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL); 

  END IF; -- fim IF coop = 3

  -- Fim da execução do job
  pc_controla_log_batch(pr_dstiplog => 'F');

  COMMIT;
  
  -- Limpa nome do modulo logado - Chmd REQ0011757 - 13/04/2018
  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

EXCEPTION
  WHEN vr_exc_erro THEN
    vr_cdcritic := NVL(vr_cdcritic,0);
    -- Buscar a descrição - Se foi retornado apenas código
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);
    -- Efetuar rollback
    ROLLBACK;
    -- Excluido COMMIT - Chmd REQ0011757 - 13/04/2018   
    -- Tratar critica conforme tipo - Chmd REQ0011757 - 13/04/2018
    -- Processo noturno nao finalizado para cooperativa - Não gera critica
    IF NVL(vr_intipmsg,1) = 1 THEN  -- IF vr_dscritic NOT LIKE '%Processo noturno nao finalizado para cooperativa%' THEN    
      -- Log de erro de execucao
      pc_controla_log_batch(pr_tpocorre => 1
                           ,pr_cdcricid => 1
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      -- Sai do programa com erro forçado 
      raise_application_error(-20501,vr_dscritic);
    ELSE
      -- Log de erro de execucao
      pc_controla_log_batch(pr_dstiplog => 'O'
                           ,pr_tpocorre => 4
                           ,pr_cdcricid => 0
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);      
    END IF;
  WHEN OTHERS THEN
    -- No caso de erro de programa gravar tabela especifica de log
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    -- Monta mensagens
    vr_cdcritic := 9999; -- 9999 -  Erro nao tratado: 
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                   vr_cdprogra ||
                   '. '  || SQLERRM || 
                   '. pr_cdcooper:'  || pr_cdcooper ||
                   ', pr_dsjobnam:' || pr_dsjobnam;  
    -- Efetuar rollback
    ROLLBACK;   
    -- Log de erro de execucao
    pc_controla_log_batch(pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    -- Excluido COMMIT - Chmd REQ0011757 - 13/04/2018
    -- Sai do programa com erro forçado   
    raise_application_error(-20501,vr_dscritic); 
END PC_CRPS710;
/
