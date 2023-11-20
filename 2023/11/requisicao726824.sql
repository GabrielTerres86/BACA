begin
  update CECRED.crappep
     set vlsdvpar = 116.75, 
         vlparepr = 116.75, 
         vlsdvsji = 116.75
   where cdcooper = 1
     and nrdconta = 12678899
     and nrctremp = 7548185
     and inliquid = 0;
      
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;