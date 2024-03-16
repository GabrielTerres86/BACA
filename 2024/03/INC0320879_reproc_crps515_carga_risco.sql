DECLARE 

  vr_stprogra PLS_INTEGER;          
  vr_infimsol PLS_INTEGER;          
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);


  PROCEDURE PC_CRPS515 ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa conectada
                        ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                        ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                        ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                        ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
   
 
    DECLARE
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;
      vr_idlog    tbgen_prglog.idprglog%TYPE;
      -- Tratamento de erros
      vr_exc_erro exception;
      vr_idparale INTEGER;

      vr_tempo TIMESTAMP := systimestamp;
      vr_nmjob VARCHAR2(30);
      vr_dsplsql VARCHAR2(4000);

      ---------------- Cursores genéricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.nrctactl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Variável genérica de calendário com base no cursor da btch0001
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Variável para retorno de busca na craptab
      vr_dstextab craptab.dstextab%TYPE;

      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE;--> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);       --> String genérica com informações para restart
      vr_inrestar INTEGER;              --> Indicador de Restart

      -- Valor de arrastro cfme parâmetros
      vr_vlr_arrasto NUMBER;

    vr_qtdjobs     NUMBER;
    vr_dtinicio    DATE;

    vr_flcentral   NUMBER(1);

    procedure pc_create_job (pr_nmjob IN VARCHAR2, pr_dsplsql IN VARCHAR2)is
    BEGIN
      DECLARE
        CURSOR cr_job_running(pr_job_name VARCHAR2) IS
          SELECT J.JOB_NAME
            FROM DBA_SCHEDULER_JOBS J, DBA_SCHEDULER_RUNNING_JOBS R
           WHERE J.OWNER = 'CECRED' --Fixo
             AND J.OWNER = R.OWNER
             AND J.JOB_NAME = R.JOB_NAME
             AND UPPER(J.JOB_NAME) = pr_job_name
             AND ROWNUM = 1;
        rw_job_running cr_job_running%ROWTYPE;
      begin
          OPEN cr_job_running(pr_job_name => pr_nmjob);
          FETCH cr_job_running INTO rw_job_running;
          IF cr_job_running%NOTFOUND THEN
            CLOSE cr_job_running;
            BEGIN 
              dbms_scheduler.drop_job(job_name  => pr_nmjob);
            EXCEPTION
              WHEN OTHERS THEN
                cecred.pc_internal_exception;
            END;
            dbms_scheduler.create_job(job_name   => pr_nmjob
                                     ,job_type   => 'PLSQL_BLOCK' --> Indica que é um bloco PLSQL
                                     ,job_action => pr_dsplsql    --> Bloco PLSQL
                                     ,start_date => SYSDATE       --> Data/hora para executar
                                     ,auto_drop  => TRUE
                                     ,enabled    => TRUE);
          ELSE
            CLOSE cr_job_running;
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 1, -- mensagem
                                       pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || 
                                                          ' - crps515 --> PROGRAMA COM ERRO: O job ' || pr_nmjob || 'ainda está em execução.',
                                       pr_dstiplog     => 'O',
                                       pr_cdprograma   => 'CRPS515.P',
                                       pr_tpexecucao   => 2); -- job
          END IF;
      END;
    end pc_create_job;

    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS515';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS515'
                                ,pr_action => null);
                                      

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_cdcritic := 1;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      rw_crapdat.dtmvtolt := to_date('15/03/2024','DD/MM/RRRR');
      rw_crapdat.dtmvtoan := to_date('14/03/2024','DD/MM/RRRR');
      rw_crapdat.dtmvtopr := to_date('18/03/2024','DD/MM/RRRR');
      
      
      vr_flcentral := to_number(nvl(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                             ,pr_cdcooper => pr_cdcooper
                                                             ,pr_cdacesso => 'EXECUTAR_CARGA_CENTRAL'),0));
      
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                           pr_ind_tipo_log => 1, -- mensagem
                           pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || 
                                              ' - crps515 --> Início nova central',
                           pr_dstiplog     => 'O',
                           pr_cdprograma   => 'CRPS515.P',
                           pr_tpexecucao   => 2); -- job

      IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapdat.dtmvtopr,'mm')  THEN
        IF vr_flcentral IN (1,2) THEN
          -- Rodar somente a nova central, se rodar ambos(2), já vai ter calculado tudo no 310
          IF vr_flcentral = 1 THEN
            --> Calcula juros+60 das contas em ADP
            GESTAODERISCO.calcularJurosADP(pr_cdcooper => pr_cdcooper
                                          ,pr_dtrefere => rw_crapdat.dtmvtolt
                                          ,pr_cdcritic => pr_cdcritic
                                          ,pr_dscritic => pr_dscritic);
            
            IF pr_dscritic IS NOT NULL THEN
              -- Rodando somente a nova carga
              IF vr_flcentral = 1 THEN
                pr_cdcritic := 0;
                RAISE vr_exc_erro;
              ELSE -- vr_flcentral = 2 rodando ambas
                pc_log_programa(pr_dstiplog           => 'O'
                               ,pr_cdprograma         => vr_cdprogra || '_calcularJurosADP'
                               ,pr_cdcooper           => pr_cdcooper
                               ,pr_tpexecucao         => 1   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               ,pr_tpocorrencia       => 4
                               ,pr_dsmensagem         => 'Erro ao programar calcularJurosADP: ' || pr_dscritic
                               ,pr_idprglog           => vr_idlog);
                pr_dscritic := NULL;
              END IF;
            END IF;
          END IF;

          BEGIN
            INSERT INTO gestaoderisco.tbrisco_central_risco
                                     (idcooperativa,
                                      dtrefere,
                                      tpsituacao)
                              VALUES (pr_cdcooper,
                                      rw_crapdat.dtmvtolt,
                                      1 --> Pendente
                                      );       
              
          EXCEPTION
            WHEN dup_val_on_index THEN
              NULL;
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao gravar tabela de controle de central de risco: '||SQLERRM;
              RAISE vr_exc_erro;
          END;  
          
          GESTAODERISCO.atualizarParcelasParalelo(pr_cdcooper => pr_cdcooper
                                                 ,pr_idparale => vr_idparale
                                                 ,pr_dscritic => pr_dscritic);
          IF pr_dscritic IS NOT NULL THEN
            -- Rodando somente a nova carga
            IF vr_flcentral = 1 THEN
              pr_cdcritic := 0;
              RAISE vr_exc_erro;
            ELSE -- vr_flcentral = 2 rodando ambas
              pc_log_programa(pr_dstiplog           => 'O'
                             ,pr_cdprograma         => vr_cdprogra || '_atualizarParcelasParalelo'
                             ,pr_cdcooper           => pr_cdcooper
                             ,pr_tpexecucao         => 1   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             ,pr_tpocorrencia       => 4
                             ,pr_dsmensagem         => 'Erro ao programar atualizarParcelasParalelo: ' || pr_dscritic
                             ,pr_idprglog           => vr_idlog);
              pr_dscritic := NULL;
            END IF;
          END IF;
          
          -- Chama rotina que ira pausar este processo controlador
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                      ,pr_qtdproce => 1
                                      ,pr_des_erro => pr_dscritic);

          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Rodando somente a nova carga
            IF vr_flcentral = 1 THEN
              pr_cdcritic := 0;
              RAISE vr_exc_erro;
            ELSE -- vr_flcentral = 2 rodando ambas
              pc_log_programa(pr_dstiplog           => 'O'
                             ,pr_cdprograma         => vr_cdprogra || '_atualizarParcelasParalelo_AGUARDO'
                             ,pr_cdcooper           => pr_cdcooper
                             ,pr_tpexecucao         => 1   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             ,pr_tpocorrencia       => 4
                             ,pr_dsmensagem         => 'Erro ao programar atualizarParcelasParalelo: ' || pr_dscritic
                             ,pr_idprglog           => vr_idlog);
              pr_dscritic := NULL;
            END IF;
          END IF;
          
          GESTAODERISCO.gerarCargaParalela(pr_cdcooper => pr_cdcooper
                                          ,pr_rw_crapdat => rw_crapdat
                                          ,pr_dscritic => pr_dscritic);
          IF pr_dscritic IS NOT NULL THEN
            -- Rodando somente a nova carga
            IF vr_flcentral = 1 THEN
              pr_cdcritic := 0;
              RAISE vr_exc_erro;
            ELSE -- vr_flcentral = 2 rodando ambas
              pc_log_programa(pr_dstiplog           => 'O'
                             ,pr_cdprograma         => vr_cdprogra || '_gerarCargaParalela'
                             ,pr_cdcooper           => pr_cdcooper
                             ,pr_tpexecucao         => 1   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             ,pr_tpocorrencia       => 4
                             ,pr_dsmensagem         => 'Erro ao programar carga paralela' || pr_dscritic
                             ,pr_idprglog           => vr_idlog);
              pr_dscritic := NULL;
            END IF;
          END IF;
          
        END IF;
      END IF;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                           pr_ind_tipo_log => 1, -- mensagem
                           pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || 
                                              ' - crps515 --> Fim nova central',
                           pr_dstiplog     => 'O',
                           pr_cdprograma   => 'CRPS515.P',
                           pr_tpexecucao   => 2); -- job
      commit;
                           
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;
        
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- erro
                                   pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||  
                                                      ' - crps515 --> PROGRAMA COM ERRO - ' || pr_dscritic,
                                   pr_dstiplog     => 'E',
                                   pr_cdprograma   => 'CRPS515.P',
                                   pr_tpexecucao   => 2); -- job
        
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- erro
                                   pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||  
                                                      ' - crps515 --> PROGRAMA COM ERRO - ' || pr_dscritic,
                                   pr_dstiplog     => 'E',
                                   pr_cdprograma   => 'CRPS515.P',
                                   pr_tpexecucao   => 2); -- job

        -- Efetuar rollback
        ROLLBACK;
    END;
    
  END PC_CRPS515;


  
BEGIN 
  
  PC_CRPS515 ( pr_cdcooper =>  14
              ,pr_flgresta =>  0
              ,pr_stprogra =>  vr_stprogra
              ,pr_infimsol =>  vr_infimsol
              ,pr_cdcritic =>  vr_cdcritic
              ,pr_dscritic =>  vr_dscritic);


  IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20500,'Erro: '||vr_cdcritic||' - '||vr_dscritic);
  END IF;                
  
END;
