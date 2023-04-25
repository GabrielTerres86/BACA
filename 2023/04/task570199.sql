BEGIN
  UPDATE cecred.crapepr epr
  SET epr.qtprepag = epr.qtpreemp,
      epr.vlsdeved = 0,
      epr.inliquid = 1,
      epr.vlsdvctr = 0,
      epr.vlsdevat = 0,
      epr.dtliquid = to_date(sysdate, 'dd/mm/rrrr')
   WHERE epr.nrdconta = 218847 
     AND epr.nrctremp = 182279;
     
  UPDATE cecred.crappep 
     SET vlpagpar = vlparepr,
         inliquid = 1, 
         vlsdvatu = 0 
   WHERE nrdconta = 218847 
     AND nrctremp = 182279 
     AND nrparepr = 12;
   
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
