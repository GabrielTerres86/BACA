BEGIN
  INSERT INTO cecred.crapcem
    (cdoperad
    ,nrdconta
    ,dsdemail
    ,cddemail
    ,dtmvtolt
    ,hrtransa
    ,cdcooper
    ,idseqttl
    ,prgqfalt
    ,nmpescto
    ,secpscto
    ,dtinsori
    ,dtrefatu
    ,inprincipal)
  VALUES
    ('1879'
    ,97816272
    ,'mdm_bnu@hotmail.com'
    ,1
    ,to_date('07-08-2014', 'dd-mm-yyyy')
    ,44180
    ,1
    ,1
    ,'A'
    ,' '
    ,' '
    ,to_date('24-04-2019 22:41:00', 'dd-mm-yyyy hh24:mi:ss')
    ,to_date('27-01-2021 00:02:25', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cecred.crapcem
    (cdoperad
    ,nrdconta
    ,dsdemail
    ,cddemail
    ,dtmvtolt
    ,hrtransa
    ,cdcooper
    ,idseqttl
    ,prgqfalt
    ,nmpescto
    ,secpscto
    ,dtinsori
    ,dtrefatu
    ,inprincipal)
  VALUES
    ('1879'
    ,97816272
    ,'marlon.m@ailos.coop.br'
    ,1
    ,to_date('07-08-2014', 'dd-mm-yyyy')
    ,44180
    ,1
    ,1
    ,'A'
    ,' '
    ,' '
    ,to_date('24-04-2019 22:41:00', 'dd-mm-yyyy hh24:mi:ss')
    ,to_date('27-01-2021 00:02:25', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  COMMIT;
END;
