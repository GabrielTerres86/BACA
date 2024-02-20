BEGIN
  UPDATE CECRED.tbprevidencia_conta c
     SET c.insituac = 0,
         c.dtmvtolt = SYSDATE
   WHERE c.cdcooper = 13
     AND c.nrdconta = 250996;
     
  INSERT INTO CECRED.tbprevidencia_conta(CDCOOPER,
                                         NRDCONTA,
                                         DTMVTOLT,
                                         DTADESAO,
                                         INSITUAC,
                                         CDOPEADE,
                                         CDOPECAN)
  VALUES (1, 17839050, SYSDATE,  TRUNC(SYSDATE), 1, NULL, NULL);
  COMMIT;
END;
/
