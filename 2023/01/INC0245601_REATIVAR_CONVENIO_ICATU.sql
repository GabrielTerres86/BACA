BEGIN
  
  UPDATE cecred.crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL
  WHERE atr.cdcooper = 1
    AND atr.nrdconta = 7483970
    AND atr.cdhistor = 2074
    AND atr.cdrefere = 930208910385;
    
  INSERT INTO cecred.craplgm (CDCOOPER, NRDCONTA, IDSEQTTL, NRSEQUEN, DTTRANSA, HRTRANSA, DSTRANSA, DSORIGEM, NMDATELA, FLGTRANS, DSCRITIC, CDOPERAD, NMENDTER)
  VALUES (1, 7483970, 1, 1, TRUNC(SYSDATE+1), 60000, 'Reativação débito autorizado (INC0245601)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' ');
          
  
  COMMIT;
END;
