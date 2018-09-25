CREATE OR REPLACE PROCEDURE CECRED.pc_crps724(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps724
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jaison
     Data    : Agosto/2017                     Ultima atualizacao: 29/08/2018

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Pagar as parcelas dos contratos do produto Pos-Fixado.

     Alteracoes: 
     29/08/2018 - permitir executar mais de uma vez e deve paralelizar somente na primeira execucao.
                - Projeto Debitador Unico - Fabiano B. Dias (AMcom).

  ............................................................................ */

  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Codigo do programa
    vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'CRPS724';

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Cursor generico de calendario
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca as agencias
    CURSOR cr_epr_pep(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapepr.cdagenci
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.tpemprst = 2 -- Pos-Fixado
         AND EXISTS (SELECT 1
                       FROM crappep
                      WHERE crappep.cdcooper = crapepr.cdcooper
                        AND crappep.nrdconta = crapepr.nrdconta
                        AND crappep.nrctremp = crapepr.nrctremp
                        AND crappep.inliquid = 0)
    GROUP BY crapepr.cdagenci;

    -- Alterações na rotina para executar na cadeia noturna além do debitador
    CURSOR cr_tbgen_param_debit_unico IS
      SELECT tdp.inexec_cadeia_noturna,
             tdp.incontrole_exec_prog
        FROM tbgen_debitador_param  tdp
       WHERE EXISTS (SELECT 1
                       FROM tbgen_debitador_horario_proc  tdhp
                      WHERE tdhp.cdprocesso = tdp.cdprocesso) --Programa deve estar associado a algum horário do Debitador Único
         AND nrprioridade IS NOT NULL --Programa deve ter prioridade informada
         AND cdprocesso = 'PC_CRPS724';
    rw_tbgen_param_debit_unico cr_tbgen_param_debit_unico%ROWTYPE;
	
    ------------------------------- VARIAVEIS -------------------------------
    vr_flgachou   BOOLEAN;
    vr_idparale   INTEGER;
    vr_qtdjobs    NUMBER;
    vr_dsplsql    VARCHAR2(4000);
    vr_jobname    VARCHAR2(30);
    vr_cdrestart  tbgen_batch_controle.cdrestart%TYPE;
    vr_insituacao tbgen_batch_controle.insituacao%TYPE;
    vr_flultexe   NUMBER; -- Debitador Unico.
    vr_qtdexec    NUMBER; -- Debitador Unico.

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                              ,pr_action => NULL);

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- Leitura do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    vr_flgachou := BTCH0001.cr_crapdat%FOUND;
    CLOSE BTCH0001.cr_crapdat;
    -- Se nao achou
    IF NOT vr_flgachou THEN
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    END IF;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se possui erro
    IF vr_cdcritic <> 0 THEN
      RAISE vr_exc_saida;
    END IF;

    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := NVL(GENE0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_PARALE_CRPS724'),10);

    -- Debitador Unico - 29/08/2018 - inicio:
    IF pr_cdcooper = 3 THEN
      vr_flultexe := 1;
      vr_qtdexec  := 1;
    ELSE
      -- Verifica quantidade de execuções do programa durante o dia no Debitador Único
      gen_debitador_unico.pc_qt_hora_prg_debitador(pr_cdcooper   => pr_cdcooper   --Cooperativa
                                                  ,pr_cdprocesso => 'PC_'||vr_cdprogra --Processo cadastrado na tela do Debitador (tbgen_debitadorparam)                              
                                                  ,pr_ds_erro    => vr_dscritic); --Retorno de Erro/Crítica  
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      /* Procedimento para verificar/controlar a execução da DEBNET e DEBSIC */
      SICR0001.pc_controle_exec_deb ( pr_cdcooper  => pr_cdcooper        --> Código da coopertiva
                                     ,pr_cdtipope  => 'I'                         --> Tipo de operacao I-incrementar e C-Consultar
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento                                
                                     ,pr_cdprogra  => vr_cdprogra                 --> Codigo do programa                                  
                                     ,pr_flultexe  => vr_flultexe                 --> Retorna se é a ultima execução do procedimento
                                     ,pr_qtdexec   => vr_qtdexec                  --> Retorna a quantidade
                                     ,pr_cdcritic  => vr_cdcritic                 --> Codigo da critica de erro
                                     ,pr_dscritic  => vr_dscritic);               --> descrição do erro se ocorrer
      IF nvl(vr_cdcritic,0) > 0 OR
      TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida; 
      END IF;             

      --Commit para garantir o controle de execucao do programa.
      COMMIT;

    END IF; --  pr_cdcooper = 3 then

    -- Buscar parâmetro de execução na cadeia noturna além do debitador único.
    -- Valida Programa do cadastro do Debitador
    OPEN cr_tbgen_param_debit_unico;
    FETCH cr_tbgen_param_debit_unico INTO rw_tbgen_param_debit_unico;
    IF cr_tbgen_param_debit_unico%notfound THEN
      CLOSE cr_tbgen_param_debit_unico;
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao buscar parâmetro de indicador de execução do programa do debitor na cadeia noturna';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_tbgen_param_debit_unico;
    END IF;
	  
    --  Paralelizar somente na primeira execucao do dia ou se o parametro de execução na cadeia estiver "S" irá executar na cadeia noturna também.
    IF (vr_qtdexec = 1 OR (rw_crapdat.inproces >= 2 AND NVL(rw_tbgen_param_debit_unico.inexec_cadeia_noturna,'N') = 'S'))
    AND vr_qtdjobs > 0 THEN

      -- Gerar o ID para o paralelismo
      vr_idparale := GENE0001.fn_gera_ID_paralelo;
	
      -- Listagem das agencias
      FOR rw_epr_pep IN cr_epr_pep(pr_cdcooper => pr_cdcooper) LOOP

        -- Verificaca a execucao por agencia
        GENE0001.pc_verifica_batch_controle(pr_cdcooper    => pr_cdcooper
                                           ,pr_cdprogra    => vr_cdprogra
                                           ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                           ,pr_tpagrupador => 1 -- PA
                                           ,pr_cdagrupador => rw_epr_pep.cdagenci
                                           ,pr_nrexecucao  => vr_qtdexec
                                           ,pr_cdrestart   => vr_cdrestart
                                           ,pr_insituacao  => vr_insituacao
                                           ,pr_cdcritic    => vr_cdcritic
                                           ,pr_dscritic    => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Se agencia ja foi executada com sucesso, continua
        IF vr_insituacao = 2 THEN
          CONTINUE;
        END IF;

        -- Cadastra o programa paralelo
        GENE0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => rw_epr_pep.cdagenci
                                  ,pr_des_erro => pr_dscritic);
        -- Se houve erro
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Montar o bloco PLSQL que sera executado,
        -- ou seja, executaremos a geracao dos dados
        -- para a agencia atual atraves de Job no banco
        vr_dsplsql := 'DECLARE' || chr(13)
                   || '  vr_cdcritic NUMBER;' || chr(13)
                   || '  vr_dscritic VARCHAR2(4000);' || chr(13)
                   || 'BEGIN' || chr(13)
                   || '  pc_crps724_1(' || pr_cdcooper || ','
                                        || vr_idparale || ','
                                        || rw_epr_pep.cdagenci || ','
                                        || vr_cdrestart || ','
                                        || vr_qtdexec || ','									
                                        || 'vr_cdcritic,vr_dscritic);' || chr(13)
                   || 'END;';

        -- Montar o prefixo do codigo do programa para o jobname
        vr_jobname := 'crps724_' || rw_epr_pep.cdagenci || '$';

        -- Faz a chamada ao programa paralelo atraves de JOB
        GENE0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> Codigo da cooperativa
                              ,pr_cdprogra  => vr_cdprogra  --> Codigo do programa
                              ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                              ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva   => NULL         --> Sem intervalo de execucao da fila, ou seja, apenas 1 vez
                              ,pr_jobname   => vr_jobname   --> Nome randomico criado
                              ,pr_des_erro  => pr_dscritic);
        -- Se houve erro
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Chama rotina que ira pausar este processo controlador
        -- caso tenhamos excedido a quantidade de JOBS em execucao
        GENE0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => vr_qtdjobs
                                    ,pr_des_erro => vr_dscritic);
        -- Se houve erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      END LOOP; -- cr_epr_pep

      -- Chama rotina de aguardo agora passando 0, para esperarmos
      -- ate que todos os Jobs tenha finalizado seu processamento
      GENE0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => 0
                                  ,pr_des_erro => vr_dscritic);
      -- Se houve erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      --> Validar conclusao do processo do controle do processo
      gene0001.pc_valid_batch_controle ( pr_cdcooper   => pr_cdcooper
                                        ,pr_cdprogra   => vr_cdprogra 
                                        ,pr_dtmvtolt   => rw_crapdat.dtmvtolt 
                                        ,pr_nrexecucao => vr_qtdexec
                                        ,pr_cdcritic   => vr_cdcritic  
                                        ,pr_dscritic   => vr_dscritic);   
    
      -- Se houve erro
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_saida;
      END IF;
	  
    ELSE -- vr_qtdexec > 1 

      pc_crps724_1(pr_cdcooper  => pr_cdcooper
                  ,pr_idparale  => vr_idparale
                  ,pr_cdagenci  => 0 -- nao paralelizar
                  ,pr_cdrestart => vr_cdrestart 
                  ,pr_qtdexec   => vr_qtdexec
                  ,pr_cdcritic  => vr_cdcritic
                  ,pr_dscritic  => vr_dscritic);

      -- Se houve erro
      IF TRIM(vr_dscritic) IS NOT NULL OR
      nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_saida;
      END IF;	

    END IF; -- vr_qtdexec = 1 THEN -- Paralelizar somente na primeira execucao. -- Debitador Unico - 29/08/2018.
    
    -- Processo OK, devemos chamar a fimprg
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    COMMIT;

  EXCEPTION

    WHEN vr_exc_saida THEN
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

  END;

END pc_crps724;
/
