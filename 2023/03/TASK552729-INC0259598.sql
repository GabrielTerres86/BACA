BEGIN
  update cecred.crapepr epr
  set epr.qtprepag = epr.qtpreemp,
      epr.vlsdeved = 0,
      epr.inliquid = 1,
      epr.vlsdvctr = 0,
      epr.vlsdevat = 0,
      epr.dtliquid = sysdate
   where epr.nrdconta = 14963213 
     and epr.nrctremp = 40800;

  update cecred.crappep 
     set vlpagpar = vlparepr,
         inliquid = 1, 
         vlsdvatu = 0 
   where nrdconta = 14963213
     and nrctremp = 40800 
     and nrparepr in (10,11,12);
   
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
/
