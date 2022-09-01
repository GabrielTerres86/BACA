BEGIN
  update crapepr epr
  set epr.qtprepag = epr.qtpreemp,
      epr.vlsdeved = 0,
      epr.inliquid = 1,
      epr.vlsdvctr = 0,
      epr.vlsdevat = 0
   where epr.nrdconta = 66605 
     and epr.nrctremp = 114729;

  update crappep 
     set vlpagpar = vlparepr,
         inliquid = 1, 
         vlsdvatu = 0 
   where nrdconta = 66605 
     and nrctremp = 114729 
     and nrparepr in (28,29,30,31,32,33,34,35,36);
   
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
