CREATE OR REPLACE PROCEDURE CECRED.pc_crps723(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps723
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jaison
     Data    : Agosto/2017                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Atualizar saldo das parcelas de todos os contratos do produto Pos-Fixado.

     Alteracoes: 

  ............................................................................ */

  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Codigo do programa
    vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'CRPS723';

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Cursor generico de calendario
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca os contratos
    CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapepr.nrdconta
            ,crapepr.nrctremp
            ,crapepr.ROWID
        FROM crapepr
        JOIN crawepr
          ON crawepr.cdcooper = crapepr.cdcooper
         AND crawepr.nrdconta = crapepr.nrdconta
         AND crawepr.nrctremp = crapepr.nrctremp
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.tpemprst = 2 -- Pos-Fixado
         AND crapepr.inliquid = 0;

    -- Buscar parcelas nao liquidadas
    CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                     ,pr_nrdconta IN crappep.nrdconta%TYPE
                     ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
      SELECT crappep.dtvencto
        FROM crappep
       WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.inliquid = 0;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    TYPE typ_reg_crapepr IS RECORD
      (dtdpagto crapepr.dtdpagto%TYPE,
       vr_rowid ROWID);
    TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY PLS_INTEGER;
    vr_tab_crapepr typ_tab_crapepr;   

    ------------------------------- VARIAVEIS -------------------------------
    vr_flgachou BOOLEAN;
    vr_fldtpgto BOOLEAN;
    vr_dtdpagto DATE;
    vr_index    PLS_INTEGER;

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
    -- Se NAO achou
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

    -- Listagem dos contratos
    FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper) LOOP
      -- Reseta as variaveis
      vr_fldtpgto := FALSE;

      -- Leitura das parcelas em aberto
      FOR rw_crappep IN cr_crappep(pr_cdcooper
                                  ,rw_crapepr.nrdconta
                                  ,rw_crapepr.nrctremp) LOOP
        -- Se for primeira vez
        IF NOT vr_fldtpgto THEN
          -- Armazena a data de pagamento da primeira parcela
          vr_dtdpagto := rw_crappep.dtvencto;
          vr_fldtpgto := TRUE;
        END IF;

      END LOOP; -- cr_crappep

      -- Alterar data de pagamento do emprestimo
      vr_index := vr_tab_crapepr.COUNT + 1;
      vr_tab_crapepr(vr_index).dtdpagto := vr_dtdpagto;
      vr_tab_crapepr(vr_index).vr_rowid := rw_crapepr.ROWID;

    END LOOP; -- cr_crapepr
  
    -- Atualizar Emprestimo
    BEGIN
      FORALL idx IN INDICES OF vr_tab_crapepr SAVE EXCEPTIONS
        UPDATE crapepr
           SET dtdpagto = vr_tab_crapepr(idx).dtdpagto
         WHERE ROWID = vr_tab_crapepr(idx).vr_rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crapepr: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_saida;
    END;

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

END pc_crps723;
/
