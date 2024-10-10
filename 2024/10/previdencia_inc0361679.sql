BEGIN
  INSERT INTO cecred.tbprevidencia_conta
    (CDCOOPER,
     NRDCONTA,
     DTMVTOLT,
     DTADESAO,
     CDOPEADE,
     DTCANCEL,
     CDOPECAN,
     INSITUAC)
  VALUES
    (1,
     16535324,
     to_date('19-08-2022 15:23:05', 'dd-mm-yyyy hh24:mi:ss'),
     to_date('19-08-2022', 'dd-mm-yyyy'),
     NULL,
     NULL,
     NULL,
     1);

  UPDATE cecred.tbprevidencia_conta c
     SET c.insituac = 0
   WHERE c.cdcooper = 16
     AND c.nrdconta = 705772;

  COMMIT;
END;
