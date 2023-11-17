BEGIN
  UPDATE cecred.crapatr atr
     SET atr.cdopeexc = ' ', 
         atr.dtinsexc = NULL, 
         atr.dtfimatr = NULL
   WHERE atr.cdcooper = 9
     AND atr.nrdconta = 447013
     AND atr.cdhistor = 2074
     AND atr.cdrefere = 930427515505;
  COMMIT;
END;
