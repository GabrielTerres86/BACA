UPDATE crapatr atr
  SET atr.cdopeexc = ' ',
      atr.dtinsexc = NULL,
      atr.dtfimatr = NULL,
      atr.dtiniatr = TRUNC(SYSDATE+1)
WHERE atr.nrdconta = 9091734
  AND atr.cdcooper = 1    
  AND atr.cdrefere = 930209010663;
  
COMMIT;
