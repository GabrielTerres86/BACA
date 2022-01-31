DECLARE
  VR_CDCRITIC  CRAPCRI.CDCRITIC%TYPE;
  VR_DSCRITIC  VARCHAR2(10000);
  VR_EXC_SAIDA EXCEPTION;
  RW_CRAPDAT   BTCH0001.CR_CRAPDAT%ROWTYPE;
  VR_DES_RETO  VARCHAR(3);
  VR_TAB_ERRO  GENE0001.TYP_TAB_ERRO;

  VR_CDCOOPER CRAPCOP.CDCOOPER%TYPE := 13;
  VR_NRDCONTA CRAPASS.NRDCONTA%TYPE := 187429;
  ---VR_NRCTREMP CRAPLEM.NRCTREMP%TYPE := 102556;
  ---VR_VLLANMTO CRAPLEM.VLLANMTO%TYPE := 275.30;
  VR_CDHISTOR CRAPLEM.CDHISTOR%TYPE := 1040;

  CURSOR CR_CRAPASS(PR_CDCOOPER IN CRAPASS.CDCOOPER%TYPE,
                    PR_NRDCONTA IN CRAPASS.NRDCONTA%TYPE) IS
    SELECT ASS.CDAGENCI
      FROM CRAPASS ASS
     WHERE ASS.CDCOOPER = PR_CDCOOPER
       AND ASS.NRDCONTA = PR_NRDCONTA;

  RW_CRAPASS CR_CRAPASS%ROWTYPE;

BEGIN

  OPEN BTCH0001.CR_CRAPDAT(PR_CDCOOPER => VR_CDCOOPER);
  FETCH BTCH0001.CR_CRAPDAT INTO RW_CRAPDAT;
  CLOSE BTCH0001.CR_CRAPDAT;

  OPEN CR_CRAPASS(PR_CDCOOPER => VR_CDCOOPER, PR_NRDCONTA => VR_NRDCONTA);
  FETCH CR_CRAPASS INTO RW_CRAPASS;
  CLOSE CR_CRAPASS;
  
  -- Cria o lancamento de estorno
  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => VR_CDCOOPER,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => VR_NRDCONTA,
                                  PR_CDHISTOR => VR_CDHISTOR,
                                  PR_NRCTREMP => 102556,
                                  PR_VLLANMTO => 275.30,
                                  PR_DTPAGEMP => RW_CRAPDAT.DTMVTOLT,
                                  PR_TXJUREPR => 0,
                                  PR_VLPREEMP => 0,
                                  PR_NRSEQUNI => 0,
                                  PR_NRPAREPR => 0,
                                  PR_FLGINCRE => FALSE,
                                  PR_FLGCREDI => FALSE,
                                  PR_NRSEQAVA => 0,
                                  PR_CDORIGEM => 5,
                                  PR_CDCRITIC => VR_CDCRITIC,
                                  PR_DSCRITIC => VR_DSCRITIC);
  
  IF VR_CDCRITIC IS NOT NULL OR VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_SAIDA;
  END IF;
  
  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => VR_CDCOOPER,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => VR_NRDCONTA,
                                  PR_CDHISTOR => VR_CDHISTOR,
                                  PR_NRCTREMP => 98595,
                                  PR_VLLANMTO => 340.98,
                                  PR_DTPAGEMP => RW_CRAPDAT.DTMVTOLT,
                                  PR_TXJUREPR => 0,
                                  PR_VLPREEMP => 0,
                                  PR_NRSEQUNI => 0,
                                  PR_NRPAREPR => 0,
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