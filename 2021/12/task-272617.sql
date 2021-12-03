begin
  UPDATE crappep 
     SET vlpagpar = vlparepr, 
	     inliquid = 1, 
		 vlsdvpar = 0, 
		 vlsdvatu = 0, 
		 dtultpag = to_date('17-11-2021', 'dd-mm-yyyy')
   WHERE cdcooper = 1 
     and nrdconta = 7430671 
     and nrctremp = 2955290
     AND nrparepr >= 15
     AND nrparepr <= 22
     AND inliquid = 0;


   UPDATE crapepr pr 
      SET inliquid = 1, 
	      vlsdeved = 0
    WHERE pr.tpemprst = 1
      AND pr.tpdescto = 2
      AND pr.inliquid = 0
      AND pr.cdcooper = 1 
      and pr.nrdconta = 7430671 
      and pr.nrctremp = 2955290;
commit;

end;