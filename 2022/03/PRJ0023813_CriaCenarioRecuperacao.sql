BEGIN
  INSERT INTO craplem
    (DTMVTOLT
    ,CDAGENCI
    ,CDBCCXLT
    ,NRDOLOTE
    ,NRDCONTA
    ,NRDOCMTO
    ,CDHISTOR
    ,NRSEQDIG
    ,NRCTREMP
    ,VLLANMTO
    ,DTPAGEMP
    ,TXJUREPR
    ,VLPREEMP
    ,NRAUTDOC
    ,NRSEQUNI
    ,CDCOOPER
    ,NRPAREPR
    ,NRSEQAVA
    ,DTESTORN
    ,CDORIGEM
    ,DTHRTRAN
    ,QTDIACAL
    ,VLTAXPER
    ,VLTAXPRD
    ,NRDOCLCM)
  VALUES
    (to_date('06/04/2022', 'dd-mm-yyyy')
    ,5
    ,100
    ,650004
    ,6653740
    ,3937070
    ,2330
    ,3937070
    ,2979852
    ,1400.73
    ,to_date('06/04/2022', 'dd-mm-yyyy')
    ,NULL
    ,1400.73
    ,0
    ,5
    ,1
    ,5
    ,0
    ,NULL
    ,7
    ,SYSDATE
    ,0
    ,0
    ,0
    ,0);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;