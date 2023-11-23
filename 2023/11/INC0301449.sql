begin
  update CECRED.crapepr
     set vlpreemp = 977.86, 
         vlsdeved = vlsdeved - 31.95, 
		 vlemprst = 28152.73		
   where cdcooper = 11
     and nrdconta = 619990
     and nrctremp = 368773;
	 
  update CECRED.crappep
     set vlsdvpar = 977.86, 
	     vlparepr = 977.86, 
		 vlsdvsji = 977.86
   where cdcooper = 11
     and nrdconta = 619990
     and nrctremp = 368773
     and inliquid = 0;
	 	 
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
