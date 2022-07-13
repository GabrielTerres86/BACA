BEGIN
  UPDATE cecred.crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL
  WHERE atr.nrdconta = 3596559
    AND atr.cdcooper = 1    
    AND atr.cdrefere = 930206887548;

  INSERT INTO cecred.craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (1, 3596559, 1, 1, to_date(TRUNC(SYSDATE), 'dd-mm-yy'), 60000, 'Reativação débito autorizado (RITM0232949)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 

  COMMIT;
END;