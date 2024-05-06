BEGIN

  INSERT INTO craptfn
    (cdcooper
    ,cdagenci
    ,cdsitfin
    ,nrterfin
    ,tpterfin
    ,nmnarede
    ,nrdendip
    ,nmterfin
    ,nrtempor
    ,qtcasset
    ,dsfabtfn
    ,dsmodelo
    ,dsdserie
    ,flsistaa
    ,flgntcem)
  VALUES
    (9
    ,1
    ,8
    ,97
    ,6
    ,LOWER(TRIM(NULL))
    ,TRIM('0.0.0.0')
    ,UPPER('Nome TAA')
    ,120
    ,4
    ,UPPER('DIEBOLD')
    ,UPPER('ATM 4534-336')
    ,NULL
    ,1
    ,0);

  INSERT INTO crapstf
    (cdcooper
    ,nrterfin
    ,dtmvtolt)
  VALUES
    (9
    ,97
    ,to_date('03/05/2024', 'dd/mm/yyyy'));

  INSERT INTO crapstf
    (cdcooper
    ,nrterfin
    ,dtmvtolt)
  VALUES
    (9
    ,97
    ,to_date('02/05/2024', 'dd/mm/yyyy'));
  COMMIT;
END;
