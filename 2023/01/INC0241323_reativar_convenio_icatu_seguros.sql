BEGIN
  
  UPDATE cecred.crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL
  WHERE atr.cdcooper = 9
    AND atr.nrdconta = 40444
    AND atr.cdhistor = 2074
    AND atr.cdrefere = 930207633418;
    
  INSERT INTO cecred.craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (9, 40444, 1, 1, to_date(TRUNC(SYSDATE+1), 'dd-mm-yyyy'), 60000, 'Reativação débito autorizado (INC0241323)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' '); 
  
  COMMIT;
END;
