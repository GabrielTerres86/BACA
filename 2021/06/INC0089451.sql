DECLARE 
 
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  --Variaveis para retorno de erro
  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
BEGIN
    -- Viacredi
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 10469150 AND cdhistor = 2472 AND nrversao = 2 AND nrctremp IN (2275287, 2275645, 2275902, 2276420);
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 8783926  AND cdhistor = 2472 AND nrversao = 2 AND nrctremp IN (2255458, 2255514);
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 6263453  AND cdhistor = 2472 AND nrversao = 2 AND nrctremp IN (2231285, 2231317, 2231340, 2231369);
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 10046178 AND cdhistor = 2472 AND nrversao = 2 AND nrctremp IN (2332162, 2332199, 2332240, 2332267);
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 10469150 AND cdhistor = 2535 AND nrversao = 2 AND nrctremp IN (2275287, 2275645, 2275902, 2276420);
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 8783926  AND cdhistor = 2535 AND nrversao = 2 AND nrctremp IN (2255458, 2255514);
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 6263453  AND cdhistor = 2535 AND nrversao = 2 AND nrctremp IN (2231285, 2231317, 2231340, 2231369);
    DELETE FROM tbepr_renegociacao_craplem WHERE cdcooper = 1 AND nrdconta = 10046178 AND cdhistor = 2535 AND nrversao = 2 AND nrctremp IN (2332162, 2332199, 2332240, 2332267);
    
    --Acredicoop
    OPEN btch0001.cr_crapdat(pr_cdcooper => 2);
    FETCH btch0001.cr_crapdat  INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- credcrea
    empr0001.pc_cria_lancamento_lem(pr_cdcooper => 2
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdagenci => 1
                                   ,pr_cdbccxlt => 100
                                   ,pr_cdoperad => 1
                                   ,pr_cdpactra => 1
                                   ,pr_tplotmov => 5
                                   ,pr_nrdolote => 600029
                                   ,pr_nrdconta => 530050	
                                   ,pr_cdhistor => 2391 -- abono
                                   ,pr_nrctremp => 254515
                                   ,pr_vllanmto => 667.61
                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                   ,pr_txjurepr => 0
                                   ,pr_vlpreemp => 0
                                   ,pr_nrsequni => 0
                                   ,pr_nrparepr => 0
                                   ,pr_flgincre => TRUE 
                                   ,pr_flgcredi => FALSE  
                                   ,pr_nrseqava => 0
                                   ,pr_cdorigem => 7 -- batch
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                        
    COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20111, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20111, SQLERRM);
END;