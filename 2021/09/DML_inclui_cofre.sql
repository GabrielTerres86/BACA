BEGIN
  INSERT INTO tbged_assina_cofre
    (CDUUID
    ,NMCOFRE
    ,DSWHOOK
    ,CDCOFRE
    ,CDCOOPER)
  VALUES
    ('1b03fd03-a103-483d-bb92-b31d1d4fc1a7'
    ,'Termo de acordo'
    ,NULL
    ,5
    ,2);

  INSERT INTO tbged_assina_conf
    (CDTOKEN
    ,CDKEY
    ,CDCOOPER
    ,CDCONFIG
    ,CDHMAC
    ,CDUUIDCOF
    ,CDTPDOC)
  VALUES
    ('live_2e6c764f1e9ad1feb0b9d07169f41237980d20f971dec2733cfb160f8c4cb3bd'
    ,'live_crypt_qNJETLawMkjGIuUZu44BXEJYsy5csA4Z'
    ,2
    ,3
    ,'76092e80629647b1fb54a8432ffdbf28974849e02008149450a79a7bc21b3381'
    ,'1b03fd03-a103-483d-bb92-b31d1d4fc1a7'
    ,283);

  COMMIT;

END;
