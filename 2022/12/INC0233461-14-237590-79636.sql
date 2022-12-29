begin

  update CECRED.crapepr
     set vlpreemp = 1196.14,
         vlppagat = 1196.14,
         vlsdeved = vlsdeved - 743.39,
         vlsdevat = vlsdevat - 743.39,
         vlsdvctr = vlsdvctr - 743.39
   where cdcooper = 14
     and nrdconta = 237590
     and nrctremp = 79636;

  update CECRED.crappep
     set vlsdvpar = 1196.14, vlparepr = 1196.14, vlsdvsji = 1196.14
   where cdcooper = 14
     and nrdconta = 237590
     and nrctremp = 79636
     and inliquid = 0;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
