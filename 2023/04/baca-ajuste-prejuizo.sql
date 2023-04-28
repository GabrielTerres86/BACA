begin
  update CECRED.crapepr
     set vlpreemp = 1308.23,         
         vlsdeved = vlsdeved - 1371.48,
         vlsdevat = vlsdevat - 1371.48,
         vlsdvctr = vlsdvctr - 1371.48
   where cdcooper = 2
     and nrdconta = 1084534
     and nrctremp = 440991;
	 
  update CECRED.crappep
     set vlsdvpar = 1308.23, 
	     vlparepr = 1308.23, 
		 vlsdvsji = 1308.23
   where cdcooper = 2
     and nrdconta = 1084534
     and nrctremp = 440991
     and inliquid = 0;
	 
  update CECRED.crapepr
     set vlpreemp = 160.56,         
         vlsdeved = vlsdeved - 183.36,
         vlsdevat = vlsdevat - 183.36,
         vlsdvctr = vlsdvctr - 183.36
   where cdcooper = 2
     and nrdconta = 953008
     and nrctremp = 439829;
	 
  update CECRED.crappep
     set vlsdvpar = 160.56, 
	     vlparepr = 160.56, 
		 vlsdvsji = 160.56
   where cdcooper = 2
     and nrdconta = 953008
     and nrctremp = 439829
     and inliquid = 0;

  update CECRED.crapepr
     set vlpreemp = 244.68,         
         vlsdeved = vlsdeved - 511.06,
         vlsdevat = vlsdevat - 511.06,
         vlsdvctr = vlsdvctr - 511.06
   where cdcooper = 10
     and nrdconta = 73830
     and nrctremp = 45350;
	 
  update CECRED.crappep
     set vlsdvpar = 244.68, 
	     vlparepr = 244.68, 
		 vlsdvsji = 244.68
   where cdcooper = 10
     and nrdconta = 73830
     and nrctremp = 45350
     and inliquid = 0; 	 

  update CECRED.crapepr
     set vlpreemp = 127.05,         
         vlsdeved = vlsdeved - 87.78,
         vlsdevat = vlsdevat - 87.78,
         vlsdvctr = vlsdvctr - 87.78
   where cdcooper = 13
     and nrdconta = 717525
     and nrctremp = 260723;
	 
  update CECRED.crappep
     set vlsdvpar = 127.05, 
	     vlparepr = 127.05, 
		 vlsdvsji = 127.05
   where cdcooper = 13
     and nrdconta = 717525
     and nrctremp = 260723
     and inliquid = 0;
	 
   update CECRED.crapepr
     set vlpreemp = 305.53,         
         vlsdeved = vlsdeved - 185.30,
         vlsdevat = vlsdevat - 185.30,
         vlsdvctr = vlsdvctr - 185.30
   where cdcooper = 13
     and nrdconta = 15385507
     and nrctremp = 269092;
	 
  update CECRED.crappep
     set vlsdvpar = 305.53, 
	     vlparepr = 305.53, 
		 vlsdvsji = 305.53
   where cdcooper = 13
     and nrdconta = 15385507
     and nrctremp = 269092
     and inliquid = 0;	 
	 
  update CECRED.crapepr
     set vlpreemp = 358.39,         
         vlsdeved = vlsdeved - 267.08,
         vlsdevat = vlsdevat - 267.08,
         vlsdvctr = vlsdvctr - 267.08
   where cdcooper = 13
     and nrdconta = 690309
     and nrctremp = 269407;
	 
  update CECRED.crappep
     set vlsdvpar = 358.39, 
	     vlparepr = 358.39, 
		 vlsdvsji = 358.39
   where cdcooper = 13
     and nrdconta = 690309
     and nrctremp = 269407
     and inliquid = 0;

  update CECRED.crapepr
     set vlpreemp = 723.15,         
         vlsdeved = vlsdeved - 791.20,
         vlsdevat = vlsdevat - 791.20,
         vlsdvctr = vlsdvctr - 791.20
   where cdcooper = 13
     and nrdconta = 538639
     and nrctremp = 268883;
	 
  update CECRED.crappep
     set vlsdvpar = 723.15, 
	     vlparepr = 723.15, 
		 vlsdvsji = 723.15
   where cdcooper = 13
     and nrdconta = 538639
     and nrctremp = 268883
     and inliquid = 0;
	 
  update CECRED.crapepr
     set vlpreemp = 299.06,         
         vlsdeved = vlsdeved - 720.82,
         vlsdevat = vlsdevat - 720.82,
         vlsdvctr = vlsdvctr - 720.82
   where cdcooper = 13
     and nrdconta = 485829
     and nrctremp = 269214;
	 
  update CECRED.crappep
     set vlsdvpar = 299.06, 
	     vlparepr = 299.06, 
		 vlsdvsji = 299.06
   where cdcooper = 13
     and nrdconta = 485829
     and nrctremp = 269214
     and inliquid = 0;	 
   
  update CECRED.crapepr
     set vlpreemp = 203.59,         
         vlsdeved = vlsdeved - 232.32,
         vlsdevat = vlsdevat - 232.32,
         vlsdvctr = vlsdvctr - 232.32
   where cdcooper = 13
     and nrdconta = 668915
     and nrctremp = 268960;
	 
  update CECRED.crappep
     set vlsdvpar = 203.59, 
	     vlparepr = 203.59, 
		 vlsdvsji = 203.59
   where cdcooper = 13
     and nrdconta = 668915
     and nrctremp = 268960
     and inliquid = 0; 	 
	 
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
