BEGIN
  UPDATE crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL
  WHERE atr.nrdconta = 2774038
    AND atr.cdcooper = 1    
    AND atr.cdrefere = 1003005289968000000;
     
  INSERT INTO craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (1, 2774038, 1, 1, TRUNC(SYSDATE+1), 60000, 'Reativação débito autorizado (RITM0221957)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 
  
  COMMIT;
END;