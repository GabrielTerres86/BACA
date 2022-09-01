BEGIN
  update cecred.crapepr epr
  set epr.qtprepag = epr.qtpreemp,
      epr.vlsdeved = 0,
      epr.inliquid = 1,
      epr.vlsdvctr = 0,
      epr.vlsdevat = 0
   where epr.nrdconta = 66605 
     and epr.nrctremp = 114729
     and epr.cdcooper = 13;

  update cecred.crappep pep 
     set pep.vlpagpar = pep.vlparepr,
         pep.inliquid = 1, 
         pep.vlsdvatu = 0 
   where pep.nrdconta = 66605 
     and pep.nrctremp = 114729 
     and pep.nrparepr in (28,29,30,31,32,33,34,35,36)
     and pep.cdcooper = 13;
   
  COMMIT;        
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20500,SQLERRM);
END;
