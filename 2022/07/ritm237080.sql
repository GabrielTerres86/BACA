begin 

	update cecred.crappep
	set dtvencto = add_months(dtvencto,1)
	 where cdcooper = 7
	   and nrdconta = 14956810
	   and nrctremp = 85066;

	update cecred.crawepr
	 set dtdpagto = add_months(dtdpagto,1),
		 dtvencto = add_months(dtvencto,1)
	  where cdcooper = 7
		and nrdconta = 14956810
		and nrctremp = 85066;
		
	commit;

end;