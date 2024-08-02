BEGIN

  INSERT INTO cecred.crapbcx
    (CDCOOPER
    ,DTMVTOLT
    ,CDAGENCI
    ,NRDCAIXA
    ,NRSEQDIG
    ,CDOPECXA
    ,CDSITBCX
    ,NRDLACRE
    ,NRDMAQUI
    ,QTAUTENT
    ,VLDSDINI
    ,VLDSDFIN
    ,HRABTBCX
    ,HRFECBCX)
  VALUES
    (10
    ,to_date('02-08-2024', 'dd-mm-yyyy')
    ,91
    ,900
    ,1
    ,'996'
    ,1
    ,0
    ,900
    ,0
    ,0.00
    ,0.00
    ,194
    ,0);

  COMMIT;

END;
