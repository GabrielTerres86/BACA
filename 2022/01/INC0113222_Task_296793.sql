DECLARE
  VR_CDCRITIC  CRAPCRI.CDCRITIC%TYPE;
  VR_DSCRITIC  VARCHAR2(10000);
  VR_EXC_SAIDA EXCEPTION;
  RW_CRAPDAT   BTCH0001.CR_CRAPDAT%ROWTYPE;

  CURSOR CR_CRAPASS(PR_CDCOOPER IN CRAPASS.CDCOOPER%TYPE,
                    PR_NRDCONTA IN CRAPASS.NRDCONTA%TYPE) IS
    SELECT ASS.CDAGENCI
      FROM CRAPASS ASS
     WHERE ASS.CDCOOPER = PR_CDCOOPER
       AND ASS.NRDCONTA = PR_NRDCONTA;

  RW_CRAPASS CR_CRAPASS%ROWTYPE;

BEGIN

  OPEN BTCH0001.CR_CRAPDAT(PR_CDCOOPER => 13);
  FETCH BTCH0001.CR_CRAPDAT INTO RW_CRAPDAT;
  CLOSE BTCH0001.CR_CRAPDAT;

  OPEN CR_CRAPASS(PR_CDCOOPER => 13, PR_NRDCONTA => 150304);
  FETCH CR_CRAPASS INTO RW_CRAPASS;
  CLOSE CR_CRAPASS;

  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => 13,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => 150304,
                                  PR_CDHISTOR => 1044,
                                  PR_NRCTREMP => 59164,
                                  PR_VLLANMTO => 225.51,
                                  PR_DTPAGEMP => RW_CRAPDAT.DTMVTOLT,
                                  PR_TXJUREPR => 0,
                                  PR_VLPREEMP => 0,
                                  PR_NRSEQUNI => 0,
                                  PR_NRPAREPR => 18,
                                  PR_FLGINCRE => FALSE,
                                  PR_FLGCREDI => FALSE,
                                  PR_NRSEQAVA => 0,
                                  PR_CDORIGEM => 5,
                                  PR_CDCRITIC => VR_CDCRITIC,
                                  PR_DSCRITIC => VR_DSCRITIC);
  
  IF VR_CDCRITIC IS NOT NULL OR VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_SAIDA;
  END IF;
  
  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => 13,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => 150304,
                                  PR_CDHISTOR => 1047,
                                  PR_NRCTREMP => 59164,
                                  PR_VLLANMTO => 4.51,
                                  PR_DTPAGEMP => RW_CRAPDAT.DTMVTOLT,
                                  PR_TXJUREPR => 0,
                                  PR_VLPREEMP => 0,
                                  PR_NRSEQUNI => 0,
                                  PR_NRPAREPR => 18,
                                  PR_FLGINCRE => FALSE,
                                  PR_FLGCREDI => FALSE,
                                  PR_NRSEQAVA => 0,
                                  PR_CDORIGEM => 5,
                                  PR_CDCRITIC => VR_CDCRITIC,
                                  PR_DSCRITIC => VR_DSCRITIC);
  
  IF VR_CDCRITIC IS NOT NULL OR VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_SAIDA;
  END IF;
  
  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => 13,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => 150304,
                                  PR_CDHISTOR => 1077,
                                  PR_NRCTREMP => 59164,
                                  PR_VLLANMTO => 3.09,
                                  PR_DTPAGEMP => RW_CRAPDAT.DTMVTOLT,
                                  PR_TXJUREPR => 0,
                                  PR_VLPREEMP => 0,
                                  PR_NRSEQUNI => 0,
                                  PR_NRPAREPR => 18,
                                  PR_FLGINCRE => FALSE,
                                  PR_FLGCREDI => FALSE,
                                  PR_NRSEQAVA => 0,
                                  PR_CDORIGEM => 5,
                                  PR_CDCRITIC => VR_CDCRITIC,
                                  PR_DSCRITIC => VR_DSCRITIC);
  
  IF VR_CDCRITIC IS NOT NULL OR VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_SAIDA;
  END IF;
  
  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => 13,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => 150304,
                                  PR_CDHISTOR => 1044,
                                  PR_NRCTREMP => 59164,
                                  PR_VLLANMTO => 548.68,
                                  PR_DTPAGEMP => RW_CRAPDAT.DTMVTOLT,
                                  PR_TXJUREPR => 0,
                                  PR_VLPREEMP => 0,
                                  PR_NRSEQUNI => 0,
                                  PR_NRPAREPR => 19,
                                  PR_FLGINCRE => FALSE,
                                  PR_FLGCREDI => FALSE,
                                  PR_NRSEQAVA => 0,
                                  PR_CDORIGEM => 5,
                                  PR_CDCRITIC => VR_CDCRITIC,
                                  PR_DSCRITIC => VR_DSCRITIC);
  
  IF VR_CDCRITIC IS NOT NULL OR VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_SAIDA;
  END IF;
  
  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => 13,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => 150304,
                                  PR_CDHISTOR => 1047,
                                  PR_NRCTREMP => 59164,
                                  PR_VLLANMTO => 10.97,
                                  PR_DTPAGEMP => RW_CRAPDAT.DTMVTOLT,
                                  PR_TXJUREPR => 0,
                                  PR_VLPREEMP => 0,
                                  PR_NRSEQUNI => 0,
                                  PR_NRPAREPR => 19,
                                  PR_FLGINCRE => FALSE,
                                  PR_FLGCREDI => FALSE,
                                  PR_NRSEQAVA => 0,
                                  PR_CDORIGEM => 5,
                                  PR_CDCRITIC => VR_CDCRITIC,
                                  PR_DSCRITIC => VR_DSCRITIC);
  
  IF VR_CDCRITIC IS NOT NULL OR VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_SAIDA;
  END IF;
 
  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => 13,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => 150304,
                                  PR_CDHISTOR => 1077,
                                  PR_NRCTREMP => 59164,
                                  PR_VLLANMTO => 2.01,
                                  PR_DTPAGEMP => RW_CRAPDAT.DTMVTOLT,
                                  PR_TXJUREPR => 0,
                                  PR_VLPREEMP => 0,
                                  PR_NRSEQUNI => 0,
                                  PR_NRPAREPR => 19,
                                  PR_FLGINCRE => FALSE,
                                  PR_FLGCREDI => FALSE,
                                  PR_NRSEQAVA => 0,
                                  PR_CDORIGEM => 5,
                                  PR_CDCRITIC => VR_CDCRITIC,
                                  PR_DSCRITIC => VR_DSCRITIC);
  
  IF VR_CDCRITIC IS NOT NULL OR VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_SAIDA;
  END IF;
  
  COMMIT;
  
EXCEPTION
  WHEN VR_EXC_SAIDA THEN
    RAISE_APPLICATION_ERROR(-20500, VR_DSCRITIC);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;