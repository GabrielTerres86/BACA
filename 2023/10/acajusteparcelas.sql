begin
  update CECRED.crapepr
     set vlpreemp = 349.43, 
         vlsdeved = vlsdeved - 390.10         
   where cdcooper = 13
     and nrdconta = 239909
     and nrctremp = 308243;
   
  update CECRED.crappep
     set vlsdvpar = 349.43, 
         vlparepr = 349.43, 
         vlsdvsji = 349.43
   where cdcooper = 13
     and nrdconta = 239909
     and nrctremp = 308243
     and inliquid = 0;
      
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
