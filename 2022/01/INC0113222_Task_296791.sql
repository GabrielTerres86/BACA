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

  /*
	Cooperativa: 13
	Conta: 66605
	Contrato: 114729

	Excluir os dados da CRAPLEM e importar o que está em anexo. Depois realizar os seguintes lançamentos:

	Histórico 1044 - Valor R$20.632,11
	Histórico 1048 - Valor R$3.374,29
  */
  
  OPEN BTCH0001.CR_CRAPDAT(PR_CDCOOPER => 13);
  FETCH BTCH0001.CR_CRAPDAT INTO RW_CRAPDAT;
  CLOSE BTCH0001.CR_CRAPDAT;

  OPEN CR_CRAPASS(PR_CDCOOPER => 13, PR_NRDCONTA => 66605);
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
                                  PR_NRDCONTA => 66605,
                                  PR_CDHISTOR => 1044,
                                  PR_NRCTREMP => 114729,
                                  PR_VLLANMTO => 20632.11,
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
                                  PR_VLLANMTO => 3374.29,
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