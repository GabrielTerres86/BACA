BEGIN
  update cecred.crapepr epr
  set epr.qtprepag = epr.qtpreemp,
      epr.vlsdeved = 0,
      epr.inliquid = 1,
      epr.vlsdvctr = 0,
      epr.vlsdevat = 0,
      epr.dtliquid = sysdate
   where epr.nrdconta = 65692 
     and epr.nrctremp = 87320;

  update cecred.crappep 
     set vlpagpar = vlparepr,
         inliquid = 1, 
         vlsdvatu = 0 
   where nrdconta = 65692 
     and nrctremp = 87320 
     and nrparepr in (29,30);
   
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
