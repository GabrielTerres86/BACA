CREATE OR REPLACE PROCEDURE CECRED.pc_crps720_1(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                               ,pr_idparale  IN crappar.idparale%TYPE     --> Indicador de processo paralelo
                                               ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo Agencia
                                               ,pr_cdrestart IN tbgen_batch_controle.cdrestart%TYPE --> Controle do registro de restart em caso de erro na execucao
                                               ,pr_dtmvtoan  IN crapdat.dtmvtoan%TYPE     --> Data do movimento anterior
                                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                               ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps720_1
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jaison
     Data    : Julho/2017                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Calcular o valor da proxima parcela do produto Pos-Fixado.

     Alteracoes: 

  ............................................................................ */

  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Codigo do programa
    vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'CRPS720';

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca os dados dos contratos e parcelas
    CURSOR cr_epr_pep(pr_cdcooper  IN crapcop.cdcooper%TYPE
                     ,pr_cdagenci  IN crapage.cdagenci%TYPE
                     ,pr_cdrestart IN tbgen_batch_controle.cdrestart%TYPE
                     ,pr_dtmvtoan  IN crapdat.dtmvtoan%TYPE
                     ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE) IS
      SELECT crapepr.cdagenci
            ,crapepr.nrdconta
            ,crapepr.nrctremp
            ,crapepr.dtmvtolt
            ,crapepr.qtpreemp
            ,crapepr.vlsprojt
            ,crawepr.txmensal
            ,crawepr.cddindex
            ,crappep.nrparepr
            ,crappep.dtvencto
            ,ROW_NUMBER() OVER (PARTITION BY crapepr.nrdconta ORDER BY crapepr.nrdconta) AS numconta
            ,COUNT(1) OVER (PARTITION BY crapepr.nrdconta) qtdconta
        FROM crapepr
        JOIN crawepr
          ON crawepr.cdcooper = crapepr.cdcooper
         AND crawepr.nrdconta = crapepr.nrdconta
         AND crawepr.nrctremp = crapepr.nrctremp
        JOIN crappep
          ON crappep.cdcooper = crapepr.cdcooper
         AND crappep.nrdconta = crapepr.nrdconta
         AND crappep.nrctremp = crapepr.nrctremp
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.cdagenci = pr_cdagenci
         AND crapepr.nrdconta > NVL(pr_cdrestart,0)
         AND crapepr.tpemprst = 2 -- Pos-Fixado
         AND crappep.inliquid = 0 -- Pendente
         AND crappep.dtvencto > ADD_MONTHS(pr_dtmvtoan,1) 
         AND crappep.dtvencto <= ADD_MONTHS(pr_dtmvtolt,1)
    ORDER BY crapepr.nrdconta;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- Registro para armazenar informacoes do contrato
    TYPE typ_parc_atu IS RECORD (cdcooper crappep.cdcooper%TYPE
                                ,nrdconta crappep.nrdconta%TYPE
                                ,nrctremp crappep.nrctremp%TYPE
                                ,nrparepr crappep.nrparepr%TYPE
                                ,vlparepr crappep.vlparepr%TYPE
                                ,vltaxatu crappep.vltaxatu%TYPE);

    -- Tabela onde serao armazenados os registros do contrato
    TYPE typ_tab_parc_atu IS TABLE OF typ_parc_atu INDEX BY PLS_INTEGER;

    vr_tab_parc_epr typ_tab_parc_atu;
    vr_tab_parc_pep typ_tab_parc_atu;
    vr_tab_parcelas EMPR0011.typ_tab_parcelas;

    ------------------------------- VARIAVEIS -------------------------------
    vr_infimsol     PLS_INTEGER;
    vr_stprogra     PLS_INTEGER;
    vr_idx_parc_epr PLS_INTEGER;
    vr_idx_parc_pep PLS_INTEGER;
    vr_idx_parcelas INTEGER;
    vr_qtdconta     INTEGER;
    vr_ultconta     INTEGER;
    vr_idcontrole   tbgen_batch_controle.idcontrole%TYPE;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Grava os dados das parcelas, emprestimo e controle do batch
    PROCEDURE pc_grava_dados(pr_tab_parc_pep IN typ_tab_parc_atu
                            ,pr_tab_parc_epr IN typ_tab_parc_atu) IS
    BEGIN
      -- Atualizar Parcelas
      BEGIN
        FORALL idx IN 1..pr_tab_parc_pep.COUNT SAVE EXCEPTIONS
        UPDATE crappep
           SET vlparepr = pr_tab_parc_pep(idx).vlparepr
              ,vlsdvpar = pr_tab_parc_pep(idx).vlparepr
              ,vltaxatu = pr_tab_parc_pep(idx).vltaxatu
         WHERE cdcooper = pr_tab_parc_pep(idx).cdcooper
           AND nrdconta = pr_tab_parc_pep(idx).nrdconta
           AND nrctremp = pr_tab_parc_pep(idx).nrctremp
           AND nrparepr = pr_tab_parc_pep(idx).nrparepr
           AND inliquid = 0;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crappep: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_saida;
      END;

      -- Atualizar Emprestimos
      BEGIN
        FORALL idx IN 1..pr_tab_parc_epr.COUNT SAVE EXCEPTIONS
        UPDATE crapepr
           SET vlpreemp = pr_tab_parc_epr(idx).vlparepr
         WHERE cdcooper = pr_tab_parc_epr(idx).cdcooper
           AND nrdconta = pr_tab_parc_epr(idx).nrdconta
           AND nrctremp = pr_tab_parc_epr(idx).nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapepr: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_saida;
      END;

      -- Grava agencia no controle do batch
      GENE0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper
                                      ,pr_cdprogra    => vr_cdprogra
                                      ,pr_dtmvtolt    => pr_dtmvtolt
                                      ,pr_tpagrupador => 1 -- PA
                                      ,pr_cdagrupador => pr_cdagenci
                                      ,pr_cdrestart   => pr_tab_parc_epr(pr_tab_parc_epr.LAST).nrdconta
                                      ,pr_nrexecucao  => 1
                                      ,pr_idcontrole  => vr_idcontrole
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      COMMIT;
    END pc_grava_dados;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                              ,pr_action => 'PC_' || vr_cdprogra || '_1');

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => vr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se possui erro
    IF vr_cdcritic <> 0 THEN
      RAISE vr_exc_saida;
    END IF;

    -- Reseta variaveis
    vr_qtdconta := 0;
    vr_ultconta := 0;

    -- Limpa PL Table
    vr_tab_parc_epr.DELETE;
    vr_tab_parc_pep.DELETE;

    -- Listagem dos contratos e parcelas
    FOR rw_epr_pep IN cr_epr_pep(pr_cdcooper  => pr_cdcooper
                                ,pr_cdagenci  => pr_cdagenci
                                ,pr_cdrestart => pr_cdrestart
                                ,pr_dtmvtoan  => pr_dtmvtoan
                                ,pr_dtmvtolt  => pr_dtmvtolt) LOOP
      -- Limpa PL Table
      vr_tab_parcelas.DELETE;

      -- Chama o calculo da proxima parcela
      EMPR0011.pc_calcula_prox_parcela_pos(pr_cdcooper        => pr_cdcooper
                                          ,pr_flgbatch        => TRUE
                                          ,pr_dtcalcul        => pr_dtmvtolt
                                          ,pr_dtefetiv        => rw_epr_pep.dtmvtolt
                                          ,pr_dtpripgt        => -- JFF
                                          ,pr_dtcarenc        => -- JFF
                                          ,pr_txmensal        => rw_epr_pep.txmensal
                                          ,pr_qtpreemp        => rw_epr_pep.qtpreemp
                                          ,pr_vlsprojt        => rw_epr_pep.vlsprojt
                                          ,pr_qtdias_carencia => -- JFF
                                          ,pr_vlrdtaxa        => -- JFF
                                          ,pr_nrparepr        => rw_epr_pep.nrparepr
                                          ,pr_dtvencto        => rw_epr_pep.dtvencto
                                          ,pr_tab_parcelas    => vr_tab_parcelas
                                          ,pr_cdcritic        => vr_cdcritic
                                          ,pr_dscritic        => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Carrega PLTABLE das Parcelas
      vr_idx_parcelas := vr_tab_parcelas.FIRST;
      WHILE vr_idx_parcelas IS NOT NULL LOOP
        vr_idx_parc_pep := vr_tab_parc_pep.COUNT + 1;
        vr_tab_parc_pep(vr_idx_parc_pep).cdcooper := pr_cdcooper;
        vr_tab_parc_pep(vr_idx_parc_pep).nrdconta := rw_epr_pep.nrdconta;
        vr_tab_parc_pep(vr_idx_parc_pep).nrctremp := rw_epr_pep.nrctremp;
        vr_tab_parc_pep(vr_idx_parc_pep).nrparepr := vr_tab_parcelas(vr_idx_parcelas).nrparepr;
        vr_tab_parc_pep(vr_idx_parc_pep).vlparepr := vr_tab_parcelas(vr_idx_parcelas).vlparepr;
        vr_tab_parc_pep(vr_idx_parc_pep).vltaxatu := vr_tab_parcelas(vr_idx_parcelas).vlrdtaxa;
        vr_idx_parcelas := vr_tab_parcelas.NEXT(vr_idx_parcelas);
      END LOOP;
      
      -- Carrega PLTABLE de Emprestimo
      vr_idx_parc_epr := vr_tab_parc_epr.COUNT + 1;
      vr_tab_parc_epr(vr_idx_parc_epr).cdcooper := pr_cdcooper;
      vr_tab_parc_epr(vr_idx_parc_epr).nrdconta := rw_epr_pep.nrdconta;
      vr_tab_parc_epr(vr_idx_parc_epr).nrctremp := rw_epr_pep.nrctremp;
      vr_tab_parc_epr(vr_idx_parc_epr).vlparepr := vr_tab_parcelas(vr_tab_parcelas.FIRST).vlparepr;

      -- Caso seja ultimo registro da conta
      IF rw_epr_pep.numconta = rw_epr_pep.qtdconta THEN
        -- Se ultima conta for diferente da atual
        IF vr_ultconta <> rw_epr_pep.nrdconta THEN
           vr_ultconta := rw_epr_pep.nrdconta;
           vr_qtdconta := vr_qtdconta + 1;
           -- Salvar a cada 1.000 contas
           IF MOD(vr_qtdconta,1000) = 0 THEN
             -- Grava os dados conforme PL Table
             pc_grava_dados(pr_tab_parc_pep => vr_tab_parc_pep
                           ,pr_tab_parc_epr => vr_tab_parc_epr);
             -- Limpa PL Table
             vr_tab_parc_epr.DELETE;
             vr_tab_parc_pep.DELETE;
           END IF;
        END IF;
      END IF;

    END LOOP; -- cr_epr_pep

    -- Grava os dados restantes conforme PL Table
    pc_grava_dados(pr_tab_parc_pep => vr_tab_parc_pep
                  ,pr_tab_parc_epr => vr_tab_parc_epr);

    -- Encerrar o job do processamento paralelo dessa agencia
    GENE0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => pr_cdagenci
                                ,pr_des_erro => pr_dscritic);
    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Finaliza agencia no controle do batch
    GENE0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole
                                       ,pr_cdcritic   => vr_cdcritic
                                       ,pr_dscritic   => vr_dscritic);
    -- Se houve erro
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Processo OK, devemos chamar a fimprg
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => vr_infimsol
                             ,pr_stprogra => vr_stprogra);

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
      
      -- Novamente tenta encerrar o JOB
      GENE0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_cdagenci
                                  ,pr_des_erro => vr_dscritic);
      -- Se aconteceu erro
      IF vr_dscritic IS NOT NULL THEN
        pr_dscritic := pr_dscritic || ' - ' || vr_dscritic;
      END IF;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

      -- Novamente tenta encerrar o JOB
      GENE0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_cdagenci
                                  ,pr_des_erro => vr_dscritic);
      -- Se aconteceu erro
      IF vr_dscritic IS NOT NULL THEN
        pr_dscritic := pr_dscritic || ' - ' || vr_dscritic;
      END IF;

  END;

END pc_crps720_1;
/
