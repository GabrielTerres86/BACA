BEGIN

  INSERT INTO craplem (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, NRCTREMP, VLLANMTO, DTPAGEMP, TXJUREPR, VLPREEMP, NRAUTDOC, NRSEQUNI, CDCOOPER, NRPAREPR, NRSEQAVA, DTESTORN, CDORIGEM, DTHRTRAN, QTDIACAL, VLTAXPER, VLTAXPRD, NRDOCLCM)
  VALUES (TO_DATE('23-11-2021', 'dd-mm-yyyy'), 28, 100, 600013, 516201, 516113, 1044, 516114, 20100662, 182.02, TO_DATE('23-11-2021', 'dd-mm-yyyy'), 0.0660306, 262.02, 0, 18, 9, 2, 0, null, 5, TO_DATE('23-11-2021', 'dd-mm-yyyy'), 0, 0.00000000, 0.00000000, 0);
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
