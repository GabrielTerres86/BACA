CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_GRAVAM(pr_cdcooper in crapcop.cdcooper%TYPE) IS
 
  /* ..........................................................................

   JOB: PC_JOB_GRAVAM
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Renato Darosci - Supero
   Data    : Agosto/2016.                     Ultima atualizacao: 04/08/2016

   Dados referentes ao programa:

   Frequencia: Di�rio.
   Objetivo  : Ir� controlar a cria��o dos JOBs individuais para cada cooperativa, que tratar�o de chamar
               a rotina de baixa autom�tica do gravames para os registros de preju�zos que foram pagos.

   Alteracoes: 12/08/2016 - Cria��o da rotina (Renato Darosci - Supero)

  ..........................................................................*/
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    CONSTANT VARCHAR2(40) := 'PC_JOB_GRAVAM';
    vr_des_reto    VARCHAR2(1000);
    vr_tab_erro    gene0001.typ_tab_erro;
    vr_cdcritic    PLS_INTEGER;
    vr_dscritic    VARCHAR2(4000);
    vr_dsplsql     VARCHAR2(2000);
	  vr_jobname     VARCHAR2(30);
    vr_minuto      NUMBER;

    vr_exc_erro    EXCEPTION;

    -- Vari�veis de controle de calend�rio
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;

    --> Buscar todas as cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.flgativo = 1
         AND cop.cdcooper <> 3 -- N�o deve rodar para a CECRED
       ORDER BY cop.cdcooper;

    -- Buscar todos os empr�stimos que tiveram seu preju�zo liquidado
    CURSOR cr_crapepr(pr_dtmvtoan  DATE) IS
      SELECT epr.nrdconta
           , epr.nrctremp
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.inliquid = 1 -- liquidado
         AND epr.inprejuz = 1 -- em preju�zo
         AND epr.vlsdprej = 0 -- Saldo do preju�zo igual a zero. Significa que o prejuizo foi pago
         AND epr.dtliqprj = pr_dtmvtoan; -- Apenas contratos com prejuizo pago no dia anterior


    /******************************/
    --> LOG de execucao
    PROCEDURE pc_gera_log_execucao(pr_dsexecut  IN VARCHAR2,
                                   pr_cdcooper  IN INTEGER,
                                   pr_dtmvtolt  IN DATE) IS
      vr_nmarqlog VARCHAR2(500);
      vr_desdolog VARCHAR2(2000);
      
    BEGIN

      --> Definir nome do log
      vr_nmarqlog := 'gravam.log';
      --> Definir descri��o do log
      vr_desdolog := 'Automatizado - '||to_char(pr_dtmvtolt,'DD/MM/YYYY')||' - '||to_char(SYSDATE,'HH24:MI:SS')||
                     ' [Baixa Automatica Prejuizo] - Coop:'|| pr_cdcooper ||' - '||pr_dsexecut;

      -- Gera o Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => vr_desdolog,
                                 pr_nmarqlog     => vr_nmarqlog);

    END pc_gera_log_execucao;
    /******************************/
    
  BEGIN

    --> Se for coop 3, deve criar o job para cada coop
    IF pr_cdcooper = 3 THEN

      --> Buscar as cooperativas
      FOR rw_crapcop IN cr_crapcop LOOP

        -- Verifica��o do calend�rio
        OPEN  BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic:= 1;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          
          -- Forma a frase de erro para incluir no log
          vr_dscritic:= 'Erro: '||vr_dscritic;
          
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
        
        -- Criar o nome para o job
        vr_jobname := 'GRAVAM_'||LPAD(rw_crapcop.cdcooper,2,'0')||'_BXA_ATM$';
        
        vr_dsplsql := 'begin cecred.PC_JOB_GRAVAM(pr_cdcooper => '||rw_crapcop.cdcooper ||'); end;';
        
        -- Se o processo batch est� rodando ... agenda para 15 minutos
        IF rw_crapdat.inproces > 1 THEN
          vr_minuto := (1/24/60) * 15;  -- 15 minutos
        ELSE 
          vr_minuto :=(1/24/60); -- 1 minuto
        END IF;
        
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => rw_crapcop.cdcooper  --> C�digo da cooperativa
                              ,pr_cdprogra  => vr_cdprogra          --> C�digo do programa
                              ,pr_dsplsql   => vr_dsplsql           --> Bloco PLSQL a executar
                              ,pr_dthrexe   => TO_TIMESTAMP(to_char((SYSDATE + vr_minuto),'DD/MM/RRRR HH24:MI')||':'||to_char(rw_crapcop.cdcooper,'fm00'),
                                                                                          'DD/MM/RRRR HH24:MI:SS') --> Incrementar o tempo
                              ,pr_jobname   => vr_jobname           --> Nome randomico criado
                              ,pr_des_erro  => vr_dscritic);

        IF TRIM(vr_dscritic) is not null THEN
          vr_dscritic := 'Falha na criacao do Job (Coop:'||rw_crapcop.cdcooper||' Job: '||vr_jobname||'): '|| vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
      
      END LOOP;
    
    -- Realizar a chamada da rotina para cada cooperativa 
    ELSE
      
      -- Verifica��o do calend�rio
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        -- Forma a frase de erro para incluir no log
        vr_dscritic:= 'Erro: '||vr_dscritic;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
       
      --> Se a coop ainda estiver no processo batch, usar proxima data util
      IF rw_crapdat.inproces > 1 THEN

        -- Criar o nome para o job
        vr_jobname := 'GRAVAM_'||LPAD(pr_cdcooper,2,'0')||'_BXA_ATM$';
        
        vr_dsplsql := 'begin cecred.PC_JOB_GRAVAM(pr_cdcooper => '|| pr_cdcooper ||'); end;';
        
        -- Agendar nova execu��o para 15 minutos
        vr_minuto := (1/24/60) * 15;  -- 15 minutos
        
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> C�digo da cooperativa
                              ,pr_cdprogra  => vr_cdprogra          --> C�digo do programa
                              ,pr_dsplsql   => vr_dsplsql           --> Bloco PLSQL a executar
                              ,pr_dthrexe   => TO_TIMESTAMP(to_char((SYSDATE + vr_minuto),'DD/MM/RRRR HH24:MI')||':'||to_char(pr_cdcooper,'fm00'),
                                                                                          'DD/MM/RRRR HH24:MI:SS') --> Incrementar o tempo
                              ,pr_jobname   => vr_jobname           --> Nome randomico criado
                              ,pr_des_erro  => vr_dscritic);

        IF TRIM(vr_dscritic) is not null THEN
          vr_dscritic := 'Falha na criacao do Job (Coop:'||pr_cdcooper||' Job: '||vr_jobname||'): '|| vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
      
      ELSE
        
        -- Log de inicio de execucao
        pc_gera_log_execucao(pr_dsexecut  => 'Inicio execucao'
                            ,pr_cdcooper  => pr_cdcooper
                            ,pr_dtmvtolt  => rw_crapdat.dtmvtolt);
      
        -- Buscar os dados de empr�stimo que tiveram o preju�zo liquidado
        FOR rw_crapepr IN cr_crapepr(rw_crapdat.dtmvtoan) LOOP 
          
          -- Para cada registro retornado, chamar a rotina de solicita��o de baixa
          GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => rw_crapepr.nrdconta
                                               ,pr_nrctrpro => rw_crapepr.nrctremp
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                               ,pr_des_reto => vr_des_reto
                                               ,pr_tab_erro => vr_tab_erro
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
          
          -- Verificar a execu��o
          IF vr_des_reto = 'OK' THEN
            -- Log de execu��o OK
            pc_gera_log_execucao(pr_dsexecut  => 'Conta: '||TRIM(GENE0002.fn_mask_conta(rw_crapepr.nrdconta))||
                                                 ' - Contrato: '||TRIM(GENE0002.fn_mask_contrato(rw_crapepr.nrctremp))||
                                                 ' - OK'
                                ,pr_cdcooper  => pr_cdcooper
                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt);
          ELSE
            -- Log de execu��o NOK
            pc_gera_log_execucao(pr_dsexecut  => 'Conta: '||TRIM(GENE0002.fn_mask_conta(rw_crapepr.nrdconta))||
                                                 ' - Contrato: '||TRIM(GENE0002.fn_mask_contrato(rw_crapepr.nrctremp))||
                                                 ' - Erro: '||vr_cdcritic||' - '||vr_dscritic
                                ,pr_cdcooper  => pr_cdcooper
                                ,pr_dtmvtolt  => rw_crapdat.dtmvtolt);
          END IF;
          
        END LOOP;
        
        -- Log de inicio de execucao
        pc_gera_log_execucao(pr_dsexecut  => 'Termino execucao'
                            ,pr_cdcooper  => pr_cdcooper
                            ,pr_dtmvtolt  => rw_crapdat.dtmvtolt);
        
      END IF; -- FIM INPROCES

    END IF; -- FIM IF COOP = 3

    -- Efetivar os dados
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Efetuar rollback
      ROLLBACK;

      -- Log de execu��o NOK
      pc_gera_log_execucao(pr_dsexecut  => vr_dscritic
                          ,pr_cdcooper  => pr_cdcooper
                          ,pr_dtmvtolt  => TRUNC(SYSDATE));

    WHEN OTHERS THEN
      vr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

      
      -- Log de execu��o NOK
      pc_gera_log_execucao(pr_dsexecut  => 'Erro na PC_JOB_GRAVAM: '||vr_dscritic
                          ,pr_cdcooper  => pr_cdcooper
                          ,pr_dtmvtolt  => TRUNC(SYSDATE));
 END PC_JOB_GRAVAM;
/
