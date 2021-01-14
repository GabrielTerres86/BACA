declare 
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;
  
  vr_cdcooper      crapcop.cdcooper%TYPE := 12;
  vr_nrdconta      crapass.nrdconta%TYPE := 123196;
  vr_nrctremp      craplem.nrctremp%TYPE := 13110;
  vr_vllanmto      craplem.vllanmto%TYPE := 4043.82;
  vr_cdhistor      craplem.cdhistor%TYPE := 3274;
  vr_vlsdeved      crapepr.vlsdeved%TYPE := 72752.16;
  vr_vlsprojt      crapepr.vlsprojt%TYPE := 72444.72;
  vr_qtprecal      crapepr.qtprecal%TYPE;
  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_qtprecal(pr_cdcooper IN crappep.cdcooper%TYPE
                    ,pr_nrdconta IN crappep.nrdconta%TYPE
                    ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
    SELECT COUNT(1) 
      FROM crappep p 
     WHERE p.cdcooper = pr_cdcooper 
       AND p.nrdconta = pr_nrdconta 
       AND p.nrctremp = pr_nrctremp 
       AND inliquid = 1;
  
BEGIN
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass INTO rw_crapass;
  CLOSE cr_crapass;

  -- Cria o lancamento de estorno
  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => rw_crapass.cdagenci
                                 ,pr_cdbccxlt => 100
                                 ,pr_cdoperad => 1
                                 ,pr_cdpactra => rw_crapass.cdagenci
                                 ,pr_tplotmov => 5
                                 ,pr_nrdolote => 600031
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_cdhistor => vr_cdhistor
                                 ,pr_nrctremp => vr_nrctremp
                                 ,pr_vllanmto => vr_vllanmto
                                 ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                 ,pr_txjurepr => 0
                                 ,pr_vlpreemp => 0
                                 ,pr_nrsequni => 0
                                 ,pr_nrparepr => 0
                                 ,pr_flgincre => FALSE
                                 ,pr_flgcredi => FALSE
                                 ,pr_nrseqava => 0
                                 ,pr_cdorigem => 5
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  
  OPEN cr_qtprecal(pr_cdcooper => vr_cdcooper
                  ,pr_nrdconta => vr_nrdconta
                  ,pr_nrctremp => vr_nrctremp);
  FETCH cr_qtprecal INTO vr_qtprecal;
  CLOSE cr_qtprecal;

  -- Atualiza os dados do Emprestimo
  BEGIN
    UPDATE crapepr
       SET crapepr.qtprecal = NVL(vr_qtprecal,1)
          ,crapepr.vlsdeved = vr_vlsdeved
          ,crapepr.vlsprojt = vr_vlsprojt
     WHERE crapepr.cdcooper = vr_cdcooper
       AND crapepr.nrdconta = vr_nrdconta
       AND crapepr.nrctremp = vr_nrctremp;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;

  -- Atualiza os dados da Parcela
  BEGIN
    UPDATE crappep
       SET crappep.vlpagpar = 4395.31
          ,crappep.vlpagmta = 87.91
          ,crappep.vlpagmra = 2.79
          ,crappep.vlsdvpar = 0
     WHERE crappep.cdcooper = vr_cdcooper
       AND crappep.nrdconta = vr_nrdconta
       AND crappep.nrctremp = vr_nrctremp
       AND crappep.inliquid = 1 
       AND crappep.nrparepr = 16;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE vr_exc_saida;
  END;
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
end;
