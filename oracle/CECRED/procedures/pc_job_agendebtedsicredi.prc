CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_AGENDEBTEDSICREDI(pr_cdcooper in crapcop.cdcooper%TYPE) IS
 /* ..........................................................................

   JOB: PC_JOB_AGENDEBTEDSICRED
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Evandro Guaranha - RKAM 
   Data    : Setembro/2016.                     Ultima atualizacao: 12/04/2017

   Dados referentes ao programa:

   Frequencia: Segunda a sexta, a cada 15 minutos, das 10:05 as 18:50.
   Objetivo  : Controlar a execução dos programas CRPS707 que efetivam os agendamentos de TED Sicredi.
               Rotina cria novos jobs para execução paralela dos programas para cada cooperativa, 
               a primeira execução do dia ocorre de forma imediata, logo após o job ser criado, 
               caso o processo batch da cooperativa esteja rodando o job é reagendado para 
               a proxima hora. 
              
   Alteracoes:
   
   12/04/2017 - #633306 Criação de log de controle de início, erros e fim de execução do job (Carlos)
   
  ..........................................................................*/
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    VARCHAR2(40) := 'PC_JOB_AGENDEBTEDSICREDI';
    vr_nomdojob    VARCHAR2(40) := 'JBCOMPE_TED_SICREDI';
    vr_flgerlog    BOOLEAN := FALSE;
    vr_infimsol    PLS_INTEGER;                     
    vr_stprogra    PLS_INTEGER;
    
    vr_exc_email   EXCEPTION;
    vr_cdcritic    PLS_INTEGER;                     
    vr_dscritic    VARCHAR2(4000);

    vr_email_dest  VARCHAR2(1000); 
    vr_conteudo    VARCHAR2(4000);
    
    -- Variáveis de controle de calendário
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;

    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
      vr_nmarqlog VARCHAR2(500);
      vr_desdolog VARCHAR2(2000);
    BEGIN    
           
      IF pr_dstiplog = 'I' OR pr_dstiplog = 'F' THEN
        --> Definir nome do log
        vr_nmarqlog := 'prcctl_'||to_char(SYSDATE,'RRRRMMDD')||'.log';
        
        vr_desdolog := --to_char(SYSDATE,'HH24:MI:SS') ||
                       ' --> Coop.: ' || pr_cdcooper ||
                       ' - Automatizado - ' || pr_dstiplog;
        --> Controlar geração de log de execução dos jobs 
        BTCH0001.pc_log_exec_job( pr_cdcooper  => 3             --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra   --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob   --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog   --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => vr_desdolog   --> Critica/mensagem a ser apresentada
                                 ,pr_flgerlog  => vr_flgerlog   --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
                                 ,pr_nmarqlog  => vr_nmarqlog);  
      ELSE
        --> Controlar geração de log de execução dos jobs 
        BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica/mensagem a ser apresentada
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
      END IF;

    END pc_controla_log_batch;
         
  BEGIN
    
    --> Se for coop 3, deve criar o job para cada coop
    IF pr_cdcooper = 3 THEN
          
      --> Log de início de execucao      
      pc_controla_log_batch('I');
      
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
       
      -- Somente se o processo já encerrou
      IF rw_crapdat.inproces = 1 THEN
                             
        --> Executar programa
        pc_crps707 (pr_cdcooper => pr_cdcooper, 
                    pr_stprogra => vr_stprogra,
                    pr_infimsol => vr_infimsol, 
                    pr_cdcritic => vr_cdcritic, 
                    pr_dscritic => vr_dscritic);
           
        --> Tratamento de erro                                 
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          
          pc_controla_log_batch('E', vr_dscritic);
                                
          RAISE vr_exc_email;    
                    
        END IF;   
        
      END IF;  
          
      --> Log de fim de execucao        
      pc_controla_log_batch('F');
      
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
      vr_conteudo := substr('ERRO NA EXECUCAO JOB :'|| vr_cdprogra ||
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')||                      
                     '<br>Critica: '         || vr_dscritic,1,4000);
                      
      vr_dscritic := NULL;
      
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'PC_JOB_AGENDEBTEDSICREDI'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB:'|| vr_cdprogra 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
                                
      COMMIT;           
                         
    WHEN OTHERS THEN

      cecred.pc_internal_exception(3);
    
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
      vr_conteudo := substr('ERRO NA EXECUCAO JOB:'|| vr_cdprogra          ||
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')||                      
                     '<br>Critica: '         || vr_dscritic,1,4000);
                      
      vr_dscritic := NULL;
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'PC_JOB_AGENDEBTEDSICREDI'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB:'|| vr_cdprogra 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT; 
      
 END PC_JOB_AGENDEBTEDSICREDI;
/
