BEGIN
  UPDATE cecred.crapatr atr
     SET atr.cdopeexc = ' ', atr.dtinsexc = NULL, atr.dtfimatr = NULL
   WHERE atr.cdcooper = 9
     AND atr.nrdconta = 6610
     AND atr.cdhistor = 901
     AND atr.cdrefere = 1104005016422000000; 

  INSERT INTO cecred.craplgm
    (cdcooper, nrdconta, idseqttl, nrsequen, dttransa, hrtransa, dstransa, dsorigem, nmdatela, flgtrans, dscritic, cdoperad, nmendter)
  VALUES
    (9, 6610, 1, 1, trunc(SYSDATE), to_char(sysdate,'sssss'), 'Reativação débito autorizado (INC0255072)', 'AIMARO WEB', 'CONTAS', 1, ' ', '1', ' ');

  COMMIT;
END;
