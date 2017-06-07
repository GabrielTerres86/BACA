CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_MENSAL (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                                  pr_dsjobnam IN VARCHAR2) IS
 /* ..........................................................................

   JOB: PC_JOB_MENSAL
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Odirlei Busana - AMcom
   Data    : Maio/2017.                     Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Rodar procedimentos que devem ser rodados apenas na MENSAL.
               Job rodará todos os dias apos o processo

   Alteracoes:

  ..........................................................................*/
  ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    VARCHAR2(40) := 'PC_JOB_MENSAL';
    
    vr_exc_email   EXCEPTION;
    vr_cdcritic    PLS_INTEGER;
    vr_dscritic    VARCHAR2(4000);

    vr_dtdiahoje   DATE;
    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(30);

    vr_dtmvtolt    DATE;    
    vr_email_dest  VARCHAR2(1000);
    vr_conteudo    VARCHAR2(4000);
    
    vr_minuto      NUMBER;

    vr_nomdojob  CONSTANT VARCHAR2(100) := 'JBGEN_MENSAL';
    vr_flgerlog  BOOLEAN := FALSE;

    -- Variáveis de controle de calendário
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
         AND cop.cdcooper <> 3
         AND cop.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;

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

    --> Se for coop 0 deve criar o job para cada coop
    IF pr_cdcooper = 0 THEN

      ------>>>>>> AGENDAR JOBS COOPs <<<<<<---------
      --> Buscar cooperativas ativas
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

        vr_jobname := vr_nomdojob||'_'||rw_crapcop.cdcooper||'_P$';
        vr_dsplsql := 'begin cecred.PC_JOB_MENSAL(pr_cdcooper => '||rw_crapcop.cdcooper ||
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

        --> Verificar se é o primeiro dia util do mês
        IF to_char(rw_crapdat.dtmvtolt,'MM') <>  to_char(rw_crapdat.dtmvtoan,'MM') THEN
          --> Rodar os programas que devem rodar no primeiro dia util do Mês


          BEGIN
            --> Realizar geração do arquivo contabil de emprestimo de cessão de credito
            pc_crps715 (pr_cdcooper => pr_cdcooper);
          EXCEPTION
            WHEN others THEN
              -- Caso ocorra algum erro, apenas apresenta critica, e executará proxima rotina
              pc_controla_log_batch( pr_dstiplog => NULL
                                    ,pr_dscritic => 'Erro ao rodar CRPS715: '||SQLERRM );
          END;


        END IF;--> Fim IF primeiro dia util do mês

      ELSE
        RAISE vr_exc_email;
      END IF;
    END IF; -- fim IF coop = 0

    COMMIT;   

  EXCEPTION
    WHEN vr_exc_email THEN
      -- Efetuar rollback
      ROLLBACK;

      --Não precisa gerar log de job reagendado
      IF upper(vr_dscritic) NOT LIKE '%JOB REAGENDADO PARA%' THEN
      
        --> Se aconteceu erro, gera o log e envia o erro por e-mail 
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
                                  ,pr_cdprogra        => vr_cdprogra
                                  ,pr_des_destino     => vr_email_dest
                                  ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB:'|| pr_dsjobnam
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                  ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
      END IF;
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
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB:'|| pr_dsjobnam
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;

 END PC_JOB_MENSAL;
/
