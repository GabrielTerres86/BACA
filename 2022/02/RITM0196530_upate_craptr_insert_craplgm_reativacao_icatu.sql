BEGIN
  UPDATE crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL,
      atr.dtiniatr = TRUNC(SYSDATE+1)
  WHERE atr.nrdconta = 2298066
    AND atr.cdcooper = 1    
    AND atr.cdrefere = 930205710903;
     
  INSERT INTO craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (1, 2298066, 1, 1, TRUNC(SYSDATE+1), 60000, 'Reativação débito autorizado (RITM0196530)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 
  
  COMMIT;
END;


