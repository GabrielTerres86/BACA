BEGIN
  UPDATE cecred.crapatr atr
     SET atr.cdopeexc = ' ', 
         atr.dtinsexc = NULL, 
         atr.dtfimatr = NULL
   WHERE atr.cdcooper = 9
     AND atr.nrdconta = 99552922
     AND atr.cdhistor = 2074
     AND atr.cdrefere = 202210758314;
  COMMIT;
END;
