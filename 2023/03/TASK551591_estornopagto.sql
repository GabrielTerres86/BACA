declare 
  vr_cdcritic      crapcri.cdcritic%TYPE;
  vr_dscritic      VARCHAR2(10000);
  vr_exc_saida     EXCEPTION;
  rw_crapdat       BTCH0001.cr_crapdat%ROWTYPE;
  
  vr_cdcooper      crapcop.cdcooper%TYPE := 1;
  
  vr_nrdconta      crapass.nrdconta%TYPE := 7777949;
  vr_nrctremp      craplem.nrctremp%TYPE := 3000421;
  vr_vllanmto      craplem.vllanmto%TYPE := 2857.25;
  vr_vllanmto1     craplem.vllanmto%TYPE := 2036.70;
  
  vr_vlmtapar1     crappep.vlmtapar%TYPE := 40.73; ---MULTA
  vr_vlmrapar1     crappep.vlmrapar%TYPE := 54.40; --JUROS
  
  vr_vlmtapar2     crappep.vlmtapar%TYPE := 40.73; ---MULTA
  vr_vlmrapar2     crappep.vlmrapar%TYPE := 9.72; --JUROS
  
  vr_cdhistor      craplem.cdhistor%TYPE := 3274;
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
BEGIN
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                 ,pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass INTO rw_crapass;
  CLOSE cr_crapass;
  cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper
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
  
  UPDATE cecred.crappep c
     SET vlparepr = vr_vllanmto1,
         vlsdvatu = vr_vllanmto1,
         vlsdvpar = vr_vllanmto1,
         vlmtapar = vr_vlmtapar1,
         vlmrapar = vr_vlmrapar1,
         inliquid = 0,
         dtultpag = null,
         vlpagpar = 0
   WHERE c.cdcooper = vr_cdcooper
     AND c.nrdconta = vr_nrdconta
     AND c.nrctremp = vr_nrctremp
     and c.nrparepr = 26;
     
      UPDATE cecred.crappep c
     SET vlsdvatu = vr_vllanmto1,
         vlsdvpar = vr_vllanmto1,
         vlmtapar = vr_vlmtapar2,
         vlmrapar = vr_vlmrapar2,
         dtultpag = null,
         vlpagpar = 0
   WHERE c.cdcooper = vr_cdcooper
     AND c.nrdconta = vr_nrdconta
     AND c.nrctremp = vr_nrctremp
     and c.nrparepr = 27;
     

  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;
end;