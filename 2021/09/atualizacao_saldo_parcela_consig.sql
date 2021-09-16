begin
	update crappep
		   set VLMRAPAR = 4.44       
	where nrdconta = 242470
		and nrctremp = 53912
		and nrparepr = 18 
		and cdcooper = 13 ;
    
	update crappep
		   set VLMRAPAR = 2.50,
		   vldespar = 0.0
	where nrdconta = 242470
		and nrctremp = 53912
		and nrparepr = 19 
		and cdcooper = 13 ;  
	commit;
end;