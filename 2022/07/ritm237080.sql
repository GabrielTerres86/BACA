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
		
		
    update cecred.crappep
       set dtvencto = add_months(dtvencto,2)
     where cdcooper = 1
       and nrdconta = 7668732
       and nrctremp = 4885568;
     
    update cecred.crapepr
       set dtdpagto = add_months(dtdpagto,2)
     where cdcooper = 1
       and nrdconta = 7668732
       and nrctremp = 4885568;		
		
	commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;