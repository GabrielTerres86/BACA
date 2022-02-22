BEGIN
  UPDATE crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL
  WHERE atr.nrdconta = 7023669
    AND atr.cdcooper = 1    
    AND atr.cdrefere = 930209121643;
     
  INSERT INTO craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (1, 7023669, 1, 1, TRUNC(SYSDATE+1), 60000, 'Reativação débito autorizado (RITM0199900)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 
  
  COMMIT;
END;


