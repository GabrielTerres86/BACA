CREATE OR REPLACE PROCEDURE CECRED.pc_job_contab_cessao(pr_cdcooper IN crapcop.cdcooper%TYPE
                                                       ,pr_dsjobnam IN VARCHAR2) IS
 /* ..........................................................................

   JOB: PC_JOB_CONTAB_CESSAO
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Odirlei Busana - AMcom
   Data    : Maio/2017.                     Ultima atualizacao: 13/04/2018

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Chamar CRPS715 responsavel por gerar a contabilizacao das cessoes
               de cartao de credito. O JOB executa no primeiro dia da semana de
               cada mês, mesmo que ele for um feriado, o que nao representa nenhum
               problema. O unico prerequisito do CRPS715 e o processo mensal ter
               finalizado e a data da cooperativa estar no mes seguinte.

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

  ..........................................................................*/
  ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    VARCHAR2(40) := 'PC_JOB_CONTAB_CESSAO';
    
    vr_exc_email   EXCEPTION;
    vr_cdcritic    PLS_INTEGER;
    vr_dscritic    VARCHAR2(4000);

    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(30);

    vr_email_dest  VARCHAR2(1000);
    vr_conteudo    VARCHAR2(4000);

    -- Excluida variavel vr_minuto não é "mais" utilizada - Chmd REQ0011757 - 13/04/2018  

    vr_nomdojob  CONSTANT VARCHAR2(100) := 'JBCRD_CBCESSAO';
    -- Excluida variavel vr_flgerlog não é utilizada - Chmd REQ0011757 - 13/04/2018  
    vr_intipmsg   INTEGER := 1; -- pr_intipmsg tipo de mensagem a ser tratada especificamente - Chmd REQ0011757 - 13/04/2018 

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

  --> Agrupa comandos de saida com erro
  PROCEDURE pc_agrupa_comandos_saida_erro 
  IS                       
    -- ..........................................................................
    --
    --  Programa : pc_agrupa_comandos_saida_erro
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Autor    : Envolti - Belli - Chamado REQ0011757
    --  Data     : 13/04/2018                        Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Agrupa comandos de saida com erro.
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --
  BEGIN
      -- Se aconteceu erro, gera o log e envia o erro por e-mail
      pc_controla_log_batch(pr_cdcooper => pr_cdcooper
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
                           
      -- buscar destinatarios do email
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_JOB');

      -- Gravar conteudo do email, controle com substr para não estourar campo texto
      vr_conteudo := substr('ERRO NA EXECUCAO JOB:'|| pr_dsjobnam          ||
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')||
                     '<br>Critica: '         || vr_dscritic,1,4000);

      vr_dscritic := NULL;
      
      -- Envia e-mail para o Operador
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
      IF TRIM(vr_dscritic) is not null THEN
        -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
        vr_cdcritic := 1197;  
        pc_controla_log_batch(pr_cdcooper => pr_cdcooper
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                                                                       ' vr_dscritic:' || vr_dscritic ||
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
   
  BEGIN                                                           --- --- --- INICIO DO PROCESSO    
    -- Incluido nome do módulo logado - Chmd REQ0011757 - 13/04/2018
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
    
    -- Log de inicio de execucao
    pc_controla_log_batch(pr_dstiplog => 'I'
                         ,pr_cdcooper => pr_cdcooper);
   
    -- Forçado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018    
    --DECLARE
    --  vr_teste NUMBER;
    --BEGIN
    --  vr_teste := 0 / 0;
    --END;
    
    --> Se for coop 0 deve criar o job para cada coop
    IF pr_cdcooper = 0 THEN

      ------>>>>>> AGENDAR JOBS COOPs <<<<<<---------
      --> Buscar cooperativas ativas
      FOR rw_crapcop IN cr_crapcop LOOP
        
        vr_jobname := vr_nomdojob||'_'||rw_crapcop.cdcooper||'$';
        vr_dsplsql := 'begin cecred.pc_job_contab_cessao(pr_cdcooper => '     ||rw_crapcop.cdcooper ||
                                                         ', pr_dsjobnam => '''||vr_jobname||'''); end;';

        -- Forçado troca de parametro - Teste Belli - Chmd REQ0011757 - 13/04/2018
        --vr_dsplsql := 'begin cecred.pc_job_ctb_c_belli(pr_cdcooper => '     ||rw_crapcop.cdcooper ||
        --                                                ', pr_dsjobnam => '''||vr_jobname||'''); end;';
              
        -- Excluido vr_minuto := (1/24/60); --> 1 - minuto - Chmd REQ0011757 - 13/04/2018           
        -- A submissão marca que executa por minuto mas executa por segundo, alem de dar erro se a cooperativa é maior que 59
        -- Ajustei para o programa somar em segundos o valor da cooperativa        
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper       --> Código da cooperativa
                              ,pr_cdprogra  => vr_cdprogra       --> Código do programa
                              ,pr_dsplsql   => vr_dsplsql        --> Bloco PLSQL a executar
                              ,pr_dthrexe   => TO_TIMESTAMP(TO_CHAR(SYSDATE + (NVL(rw_crapcop.cdcooper,0) / 24 / 60 / 60)
                                                           ,'DD/MM/RRRR HH24:MI:SS')) --> Incrementar mais 1 segundo
                              ,pr_interva   => NULL                     --> apenas uma vez
                              ,pr_jobname   => vr_jobname               --> Nome randomico criado
                              ,pr_des_erro  => vr_dscritic);

        IF TRIM(vr_dscritic) is not null THEN
          -- Ajuste codigo e descrição de critica - Chmd REQ0011757 - 13/04/2018
          vr_cdcritic := 1197;  
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                         ' vr_dscritic:' || vr_dscritic  ||
                         ' ' || vr_cdprogra ||
                         ', pr_cdcooper:' || pr_cdcooper ||
                         ', pr_dsjobnam:' || pr_dsjobnam ||
                         ', vr_jobname:'  || vr_jobname  ||   
                         ', rw_crapcop.cdcooper:' || rw_crapcop.cdcooper;
          RAISE vr_exc_email;
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
                                ,pr_dscritic => vr_dscritic);

      -- se nao retornou critica  chama rotina
      IF TRIM(vr_dscritic) IS NULL THEN
        
        -- Retorna nome do módulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);  

        -- Verificação do calendário
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic:= 1;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                        ' ' || vr_cdprogra ||
                        ', pr_cdcooper:' || pr_cdcooper ||
                        ', pr_dsjobnam:' || pr_dsjobnam;
          RAISE vr_exc_email;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;

        --> Verificar se é o primeiro dia util do mês
        IF to_char(rw_crapdat.dtmvtolt,'MM') <>  to_char(rw_crapdat.dtmvtoan,'MM') THEN
          --> Rodar os programas que devem rodar no primeiro dia util do Mês

          BEGIN
   
            -- Forçado erro - Teste Belli - Chmd REQ0011757 - 13/04/2018    
            --DECLARE
            --  vr_teste NUMBER;
            --BEGIN
            --  vr_teste := 0 / 0;
            --END;
            
            --> Realizar geração do arquivo contabil de emprestimo de cessão de credito
            pc_crps715 (pr_cdcooper => pr_cdcooper);
            -- Retorna nome do módulo logado
            GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);  
          EXCEPTION
            WHEN others THEN
              -- No caso de erro de programa gravar tabela especifica de log - Chmd REQ0011757 - 13/04/2018
              cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              -- Monta mensagens
              vr_cdcritic := 9999; -- Erro nao tratado: 
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             vr_cdprogra || 
                             '. ' || SQLERRM || 
                             '. pr_cdcooper:' || pr_cdcooper ||
                             ', pr_dsjobnam:' || pr_dsjobnam;
              -- Caso ocorra algum erro, apenas apresenta critica, e executará proxima rotina
              pc_controla_log_batch(pr_cdcooper => pr_cdcooper
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic );
          END;


        END IF;--> Fim IF primeiro dia util do mês

      ELSE
        RAISE vr_exc_email;
      END IF;
    END IF; -- fim IF coop = 0

    COMMIT;   
      
    -- Log de fim de execucao
    pc_controla_log_batch(pr_dstiplog => 'F'
                         ,pr_cdcooper => pr_cdcooper);
    
    -- Retorna nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    -- Trata log - Chmd REQ0011757 - 13/04/2018
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
 END pc_job_contab_cessao;
/
