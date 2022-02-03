DECLARE
  VR_CDCRITIC CRAPCRI.CDCRITIC%TYPE;
  VR_DSCRITIC VARCHAR2(10000);
  VR_EXC_SAIDA EXCEPTION;
  RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;

  CURSOR CR_CRAPASS(PR_CDCOOPER IN CRAPASS.CDCOOPER%TYPE,
                    PR_NRDCONTA IN CRAPASS.NRDCONTA%TYPE) IS
    SELECT ASS.CDAGENCI
      FROM CRAPASS ASS
     WHERE ASS.CDCOOPER = PR_CDCOOPER
       AND ASS.NRDCONTA = PR_NRDCONTA;

  RW_CRAPASS CR_CRAPASS%ROWTYPE;

  CURSOR CR_OBTVALPARC IS
    SELECT NRPAREPR, PAG.VLPAGPAR
      FROM TBEPR_CONSIGNADO_PAGAMENTO PAG
     WHERE NRCTREMP = 114729
       AND CDCOOPER = 13
       AND NRDCONTA = 66605
       AND NRPAREPR BETWEEN 28 AND 36;

  RW_OBTVALPARC CR_OBTVALPARC%ROWTYPE;

BEGIN

  OPEN BTCH0001.CR_CRAPDAT(PR_CDCOOPER => 13);
  FETCH BTCH0001.CR_CRAPDAT
    INTO RW_CRAPDAT;
  CLOSE BTCH0001.CR_CRAPDAT;

  OPEN CR_CRAPASS(PR_CDCOOPER => 13, PR_NRDCONTA => 66605);
  FETCH CR_CRAPASS
    INTO RW_CRAPASS;
  CLOSE CR_CRAPASS;

  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => 13,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => 66605,
                                  PR_CDHISTOR => 1044,
                                  PR_NRCTREMP => 114729,
                                  PR_VLLANMTO => 167.03,
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

  EMPR0001.PC_CRIA_LANCAMENTO_LEM(PR_CDCOOPER => 13,
                                  PR_DTMVTOLT => RW_CRAPDAT.DTMVTOLT,
                                  PR_CDAGENCI => RW_CRAPASS.CDAGENCI,
                                  PR_CDBCCXLT => 100,
                                  PR_CDOPERAD => 1,
                                  PR_CDPACTRA => RW_CRAPASS.CDAGENCI,
                                  PR_TPLOTMOV => 5,
                                  PR_NRDOLOTE => 600031,
                                  PR_NRDCONTA => 66605,
                                  PR_CDHISTOR => 1048,
                                  PR_NRCTREMP => 114729,
                                  PR_VLLANMTO => 14.32,
                                  PR_DTPAGEMP => RW_CRAPDAT.DTMVTOLT,
                                  PR_TXJUREPR => 0,
                                  PR_VLPREEMP => 0,
                                  PR_NRSEQUNI => 0,
                                  PR_NRPAREPR => 7,
                                  PR_FLGINCRE => FALSE,
                                  PR_FLGCREDI => FALSE,
                                  PR_NRSEQAVA => 0,
                                  PR_CDORIGEM => 5,
                                  PR_CDCRITIC => VR_CDCRITIC,
                                  PR_DSCRITIC => VR_DSCRITIC);

  IF VR_CDCRITIC IS NOT NULL OR VR_DSCRITIC IS NOT NULL THEN
    RAISE VR_EXC_SAIDA;
  END IF;

  FOR RW_OBTVALPARC IN CR_OBTVALPARC
  LOOP
    UPDATE CRAPPEP PEP
       SET PEP.VLSDVPAR = 0,
           PEP.VLSDVATU = 0,
           INLIQUID = 1,
           VLPAGPAR = RW_OBTVALPARC.VLPAGPAR
     WHERE CDCOOPER = 13
       AND NRDCONTA = 66605
       AND PEP.NRCTREMP = 114729
       AND NRPAREPR = RW_OBTVALPARC.NRPAREPR;
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN VR_EXC_SAIDA THEN
    RAISE_APPLICATION_ERROR(-20500, VR_DSCRITIC);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;
