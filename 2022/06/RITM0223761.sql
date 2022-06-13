BEGIN
  UPDATE crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL
  WHERE atr.nrdconta = 3650570
    AND atr.cdcooper = 1    
    AND atr.cdrefere = 930205842656;
     
  INSERT INTO craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (1, 3650570, 1, 1, TRUNC(SYSDATE+1), 60000, 'Reativação débito autorizado (RITM0223761)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 
  
  COMMIT;
END;