begin
  update CECRED.crapepr
     set vlpreemp = 2639.52, 
         vlsdeved = vlsdeved - 4692.86         
   where cdcooper = 9
     and nrdconta = 99545080
     and nrctremp = 87650;
   
  update CECRED.crappep
     set vlsdvpar = 2639.52, 
         vlparepr = 2639.52, 
         vlsdvsji = 2639.52
   where cdcooper = 9
     and nrdconta = 99545080
     and nrctremp = 87650
     and inliquid = 0;
      
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
