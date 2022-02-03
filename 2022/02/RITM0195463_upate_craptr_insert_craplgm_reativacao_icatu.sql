BEGIN
  UPDATE crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL,
      atr.dtiniatr = TRUNC(SYSDATE+1)
  WHERE atr.nrdconta = 339768
    AND atr.cdcooper = 2    
    AND atr.cdrefere = 930206930583;
     
  INSERT INTO craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (2, 339768, 1, 1, TRUNC(SYSDATE+1), 60000, 'Reativação débito autorizado (RITM0195463)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 
  
  COMMIT;
END;
