CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_CONTAB_APLPROG (pr_cdcooper IN crapcop.cdcooper%TYPE
                                                         ,pr_dsjobnam IN VARCHAR2
                                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                                         ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
 /* ..........................................................................

   JOB: pc_job_contab_aplprog
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Anderson Fossa
   Data    : Janeiro/2019.                     Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar relatorios contabeis da aplicacao programada.

   Alteracoes:

  ..........................................................................*/
  ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    VARCHAR2(40) := 'PC_JOB_CONTAB_APLPROG';

    vr_exc_email   EXCEPTION;
    vr_cdcritic    PLS_INTEGER;
    vr_dscritic    VARCHAR2(4000);

    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(30);

    vr_email_dest  VARCHAR2(1000);
    vr_conteudo    VARCHAR2(4000);

    vr_nomdojob  CONSTANT VARCHAR2(100) := 'JBCAPT_CONTAB_APLPROG';

    vr_intipmsg   INTEGER := 1;

    vr_stprogra PLS_INTEGER;            -- Saída de termino da execução
    vr_infimsol PLS_INTEGER;            -- Saída de termino da solicitação

    -- Cooperativas a serem processadas
    CURSOR cr_crapcop IS
       SELECT cop.cdcooper
         FROM crapcop cop
        WHERE cop.flgativo = 1 
          AND cop.cdcooper <> 3
    ORDER BY cop.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro
                                 ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                 ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                 ,pr_tpexecuc IN NUMBER   DEFAULT 2   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcooper IN VARCHAR2
                                 ,pr_flgsuces IN NUMBER   DEFAULT 1    -- Indicador de sucesso da execução
                                 ,pr_flabrchd IN INTEGER  DEFAULT 0    -- Abre chamado 1 Sim/ 0 Não
                                 ,pr_textochd IN VARCHAR2 DEFAULT NULL -- Texto do chamado
                                 ,pr_desemail IN VARCHAR2 DEFAULT NULL -- Destinatario do email
                                 ,pr_flreinci IN INTEGER  DEFAULT 0    -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado
  )
  IS
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

  --> Agrupa comandos de saida com erro
  PROCEDURE pc_agrupa_comandos_saida_erro IS
  BEGIN
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra||'.pc_agrupa_comandos_saida_erro', pr_action => NULL);

      -- Se aconteceu erro, gera o log e envia o erro por e-mail
      pc_controla_log_batch(pr_cdcooper => pr_cdcooper
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

      -- buscar destinatarios do email
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_JOB');

      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('ERRO NA EXECUCAO JOB: '|| pr_dsjobnam          ||
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')||
                     '<br>Critica: '         || vr_dscritic,1,4000);

      vr_dscritic := NULL;

      -- Envia e-mail para o Operador
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB: '|| pr_dsjobnam
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      IF TRIM(vr_dscritic) is not null THEN
        -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
        vr_cdcritic := 1197;  -- change me
        pc_controla_log_batch(pr_cdcooper => pr_cdcooper
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                                                                       ' - ' || vr_dscritic ||
                                                                       '. pr_cdcooper:' || pr_cdcooper ||
                                                                       ', pr_dsjobnam:' || pr_dsjobnam);
      END IF;
      -- Retorna nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);

      COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
  END pc_agrupa_comandos_saida_erro;

  BEGIN --Principal

    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);

    pr_cdcritic := 0;
    pr_dscritic := '';

    pc_controla_log_batch(pr_dstiplog => 'I'
                         ,pr_cdcooper => pr_cdcooper);

    --> Se for coop 3 - Ailos deve criar o job para cada coop
    IF pr_cdcooper = 3 THEN

       ------>>>>>> AGENDAR JOBS COOPs para contabilizacao <<<<<<---------
       --- Neste ponto a proc cria um job dela mesma, informando a cooperativa
       FOR rw_crapcop IN cr_crapcop LOOP
           vr_jobname := vr_nomdojob||'_'||rw_crapcop.cdcooper||'$';
           vr_dsplsql := 'declare '||
                         '   vr_cdcritic crapcri.cdcritic%TYPE; '||
                         '   vr_dscritic crapcri.dscritic%TYPE; '||
                         'begin cecred.pc_job_contab_aplprog(pr_cdcooper => ' ||rw_crapcop.cdcooper ||
                                                          ', pr_dsjobnam => '''||vr_jobname||''' ' ||
                                                          ', pr_cdcritic => vr_cdcritic'|| 
                                                          ', pr_dscritic => vr_dscritic'||
                                                          '); end;';

           -- Faz a chamada ao programa paralelo atraves de JOB
           gene0001.pc_submit_job (pr_cdcooper  => rw_crapcop.cdcooper                    --> Código da cooperativa
                                  ,pr_cdprogra  => vr_cdprogra                            --> Código do programa
                                  ,pr_dsplsql   => vr_dsplsql                             --> Bloco PLSQL a executar
                                  ,pr_dthrexe   => SYSDATE + (10 / 24 / 60 / 60)          --> Incrementar mais 10 segundos
                                  ,pr_interva   => NULL                                   --> apenas uma vez
                                  ,pr_jobname   => vr_jobname                             --> Nome composto criado
                                  ,pr_des_erro  => vr_dscritic);

           IF TRIM(vr_dscritic) is not null THEN
              -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
              vr_cdcritic := 1197;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                             ' - ' || vr_dscritic  ||
                             ' ' || vr_cdprogra ||
                             ', pr_cdcooper:' || pr_cdcooper ||
                             ', pr_dsjobnam:' || pr_dsjobnam ||
                             ', vr_jobname:'  || vr_jobname  ||
                             ', rw_crapprm.cdcooper:' || rw_crapcop.cdcooper;
              RAISE vr_exc_email;
           END IF;
           -- Retorna nome do módulo logado
           GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'Cooper: ' || pr_cdcooper);
      END LOOP;
    ELSE
       -- Execução da Job em si
       -- Troca da pc_executa_job para pc_trata_exec_job agora trata tipo de critica
       -- Valida se executa o job( testar de esta rodando o batch)
       gene0004.pc_trata_exec_job(pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                                 ,pr_fldiautl => 0             --> Flag se deve validar dia util
                                 ,pr_flproces => 1             --> Flag se deve validar se esta no processo (true = não roda no processo)
                                 ,pr_flrepjob => 1             --> Flag para reprogramar o job
                                 ,pr_flgerlog => 0             --> indicador se deve gerar log
                                 ,pr_nmprogra => pr_dsjobnam   --> Nome do programa que esta sendo executado no job
                                 ,pr_intipmsg => vr_intipmsg
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

       -- se nao retornou critica  chama rotina
       IF TRIM(vr_dscritic) IS NULL THEN

          -- Retorna nome do módulo logado
          GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'Cooper: ' || pr_cdcooper);

          pc_crps737 (pr_cdcooper => pr_cdcooper
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic);

          -- Caso tenhamos recebido algum erro
          IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
             cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
             -- Monta mensagens
             IF vr_cdcritic = 0 THEN
                vr_cdcritic := 9999; -- Erro nao tratado:
             END IF;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                            vr_cdprogra ||
                            '. ' || SQLERRM ||
                            '. pr_cdcooper:' || pr_cdcooper ||
                            ', pr_dsjobnam:' || pr_dsjobnam;
             -- Caso ocorra algum erro, apenas apresenta critica, e executará proxima rotina
             pc_controla_log_batch (pr_cdcooper => pr_cdcooper
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic );

          END IF;
       ELSE
          RAISE vr_exc_email;
       END IF; -- vr_descrit is null
    END IF; -- fim IF coop = 0

    COMMIT;
    -- Log de fim de execucao
    pc_controla_log_batch(pr_dstiplog => 'F'
                         ,pr_cdcooper => pr_cdcooper);

    -- Retorna nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

  EXCEPTION
    WHEN vr_exc_email THEN
      -- Efetuar rollback
      ROLLBACK;

      -- Não precisa gerar log de job reagendado
      IF NVL(vr_intipmsg,1) = 3 THEN -- IF upper(vr_dscritic) NOT LIKE '%JOB REAGENDADO PARA%' THEN
        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'O'
                             ,pr_tpocorre => 4
                             ,pr_cdcricid => 0
                             ,pr_cdcritic => NVL(vr_cdcritic,0)
                             ,pr_dscritic => vr_dscritic
                             ,pr_cdcooper => pr_cdcooper);
      ELSE
        pc_agrupa_comandos_saida_erro;
      END IF;
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      -- Monta mensagens
      vr_cdcritic := 9999; -- 9999 -  Erro nao tratado:
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     vr_cdprogra ||
                     '. ' || SQLERRM ||
                     '. pr_cdcooper:' || pr_cdcooper ||
                     ', pr_dsjobnam:' || pr_dsjobnam;
      -- Efetuar rollback
      ROLLBACK;
      pc_agrupa_comandos_saida_erro;
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
 END PC_JOB_CONTAB_APLPROG;
/
