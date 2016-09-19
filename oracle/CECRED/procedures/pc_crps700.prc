CREATE OR REPLACE PROCEDURE CECRED.pc_crps700 (
                                        pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_dtmvtoan IN crapdat.dtmvtolt%TYPE
                                       ,pr_dtinimes IN DATE
                                       ,pr_dtultdia IN DATE
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps700
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Castro (RKAM)
       Data    : Janeiro/2016                     Ultima atualizacao: 17/02/16

       Dados referentes ao programa:

       Frequencia: Diário (JOB)
       Objetivo  : Popular a tabela de beneficiarios do INSS, apenas inicia JOBS
                   chamando crps700_1.

       Alteracoes: 

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS700';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados das cooperativas
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper 
              ,cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
          WHERE cop.cdcooper = pr_cdcooper;
      
      -- Buscar contas que receberam beneficios do INSS no dia de ontem
      CURSOR cr_craplcm_inss(pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) IS        
        SELECT DISTINCT lcm.cdcooper
              ,cop.cdagesic
              ,lcm.nrdconta
        FROM   crapcop cop,
               craplcm lcm
        WHERE  cop.cdcooper = pr_cdcooper
        AND    lcm.cdcooper = cop.cdcooper
        AND    lcm.cdhistor = 1399 
        AND    lcm.dtmvtolt = pr_dtmvtoan    
         ORDER BY nrdconta;
          

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
            
      -- ID para o paralelismo
      vr_idparale INTEGER;
      -- Qtde parametrizada de Jobs
      vr_qtdjobs NUMBER;
      
      -- Bloco PLSQL para chamar a execução paralela do pc_crps414
      vr_dsplsql VARCHAR2(4000);
      -- Job name dos processos criados
      vr_jobname VARCHAR2(30);

      --------------------------- SUBROTINAS INTERNAS --------------------------
      
      
      
    
      
      --------------- VALIDACOES INICIAIS -----------------
    BEGIN
       -- Gerar hora inicio no log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => to_char(SYSDATE
                                                           ,'DD/MM/YYYY HH24:MI:SS') ||
                                                    ' - crps700 - INICIO.'
                                ,pr_nmarqlog     => 'log_crps700');


      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      FOR rw_crapcop IN cr_crapcop LOOP
        
        /* Inicial rotinas em paralelo por cooperado para agilizar processamento */
        -- Gerar o ID para o paralelismo
        vr_idparale := gene0001.fn_gera_ID_paralelo;

        -- Se houver algum erro, o id vira zerado
        IF vr_idparale = 0 THEN
          -- Levantar exceção
          pr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
          RAISE vr_exc_saida;
        END IF;

        -- Buscar quantidade parametrizada de Jobs
        vr_qtdjobs := NVL(gene0001.fn_param_sistema('CRED'
                                                   ,rw_crapcop.cdcooper
                                                   ,'QTD_PARALE_CRPS700')
                                                   ,10);
        -- contas a serem buscados os demonstrativos
        FOR rw_craplcm_inss IN cr_craplcm_inss (pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_dtmvtoan => pr_dtmvtoan) LOOP
                                               
          -- Gerar hora inicio no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => 'Conta: '||rw_craplcm_inss.nrdconta
                                    ,pr_nmarqlog     => 'log_crps700'); 
        
         -- Cadastra o programa paralelo
         gene0001.pc_ativa_paralelo(pr_idparale  => vr_idparale
                                    ,pr_idprogra => rw_craplcm_inss.nrdconta
                                    ,pr_des_erro => pr_dscritic);
          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_saida;
          END IF;
          
          -- Montar o bloco PLSQL que será executado
          -- Ou seja, executaremos a geração dos dados
          -- para a agência atual atraves de Job no banco
          vr_dsplsql := 'DECLARE' || chr(13) || --
                        '  vr_cdcritic NUMBER;' || chr(13) || --
                        '  vr_dscritic VARCHAR2(1500);' || chr(13) || --
                        'BEGIN' || chr(13) || --
                        '  pc_crps700_1( ' || --
                        rw_craplcm_inss.cdcooper || ',' || --
                        rw_craplcm_inss.nrdconta || ',' || --
                        rw_craplcm_inss.cdagesic || ',''' || --
                        to_char(pr_dtmvtoan,'yyyymmdd') ||''',''' || --
                        to_char(pr_dtinimes,'yyyymmdd') ||''',''' || --
                        to_char(pr_dtultdia,'yyyymmdd') ||''',' || --
                        vr_idparale           || ',' || --                    
                        ' vr_cdcritic, vr_dscritic);' ||
                        chr(13) || --
                        'END;'; --
          -- Montar o prefixo do código do programa para o jobname
          vr_jobname := 'crps700_' || rw_craplcm_inss.nrdconta || '$';

          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper => rw_crapcop.cdcooper --> Código da cooperativa
                                ,pr_cdprogra => vr_cdprogra --> Código do programa
                                ,pr_dsplsql  => vr_dsplsql --> Bloco PLSQL a executar
                                ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva  => NULL --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname  => vr_jobname --> Nome randomico criado
                                ,pr_des_erro => pr_dscritic);
          
          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_saida;
          END IF;

          -- Chama rotina que irá pausar este processo controlador
          -- caso tenhamos excedido a quantidade de JOBS em execuçao
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                      ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                      ,pr_des_erro => pr_dscritic);
          -- Testar saida com erro
          IF pr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_saida;
          END IF;
         -- Salvar informações atualizadas
         COMMIT;           
        END LOOP;
        
        -- Chama rotina de aguardo agora passando 0, para esperarmos
        -- até que todos os Jobs tenha finalizado seu processamento
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => 0
                                    ,pr_des_erro => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;          
        
      END LOOP;
      
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------


       -- Gerar hora inicio no log
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => to_char(SYSDATE
                                                           ,'DD/MM/YYYY HH24:MI:SS') ||
                                                    ' - crps700 - FIM.'
                                ,pr_nmarqlog     => 'log_crps700');


      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- gera log do erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 1, -- somente mensagem
                                   pr_nmarqlog     => 'CRPS700_1', --gerar log no prprev,
                                   pr_des_log      => 'vr_exc_saida: '||pr_dtmvtoan||'_'||vr_idparale||vr_dscritic);
        
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- gera log do erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 1, -- somente mensagem
                                   pr_nmarqlog     => 'CRPS700_1', --gerar log no prprev,
                                   pr_des_log      => 'when OTHERS: '||pr_dtmvtoan||'_'||vr_idparale||vr_dscritic);
        
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps700;
