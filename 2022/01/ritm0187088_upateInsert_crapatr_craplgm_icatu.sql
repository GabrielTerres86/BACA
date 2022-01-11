BEGIN
  UPDATE crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL,
      atr.dtiniatr = TRUNC(SYSDATE+1)
  WHERE atr.nrdconta = 8535884
    AND atr.cdcooper = 1    
    AND atr.cdrefere = 930205858188;
     
  INSERT INTO craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (1, 8535884, 1, 1, TRUNC(SYSDATE+1), 60000, 'Reativação débito autorizado (RITM0187088)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 
  
  COMMIT;
END;
