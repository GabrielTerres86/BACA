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
     Data    : Agosto/2017                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Pagar as parcelas dos contratos do produto Pos-Fixado.

     Alteracoes: 

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

    ------------------------------- VARIAVEIS -------------------------------
    vr_flgachou   BOOLEAN;
    vr_idparale   INTEGER;
    vr_qtdjobs    NUMBER;
    vr_dsplsql    VARCHAR2(4000);
    vr_jobname    VARCHAR2(30);
    vr_cdrestart  tbgen_batch_controle.cdrestart%TYPE;
    vr_insituacao tbgen_batch_controle.insituacao%TYPE;

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

    -- Gerar o ID para o paralelismo
    vr_idparale := GENE0001.fn_gera_ID_paralelo;

    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := NVL(GENE0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_PARALE_CRPS724'),10);

    -- Listagem das agencias
    FOR rw_epr_pep IN cr_epr_pep(pr_cdcooper => pr_cdcooper) LOOP

      -- Verificaca a execucao por agencia
      GENE0001.pc_verifica_batch_controle(pr_cdcooper    => pr_cdcooper
                                         ,pr_cdprogra    => vr_cdprogra
                                         ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                         ,pr_tpagrupador => 1 -- PA
                                         ,pr_cdagrupador => rw_epr_pep.cdagenci
                                         ,pr_nrexecucao  => 1
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
                                  ,pr_des_erro => pr_dscritic);
      -- Se houve erro
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    END LOOP; -- cr_epr_pep

    -- Chama rotina de aguardo agora passando 0, para esperarmos
    -- ate que todos os Jobs tenha finalizado seu processamento
    GENE0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                ,pr_qtdproce => 0
                                ,pr_des_erro => pr_dscritic);
    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

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
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
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
