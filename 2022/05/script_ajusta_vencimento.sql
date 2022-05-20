begin
 update cecred.crappep pep
    set pep.dtvencto = add_months(pep.dtvencto,-2)
  where pep.cdcooper = 13
    and pep.nrdconta = 136050
    and pep.nrctremp = 168149;
    
 update cecred.crappep pep
    set pep.dtvencto = add_months(pep.dtvencto,2)
  where pep.cdcooper = 13
    and pep.nrdconta = 478512
    and pep.nrctremp = 185911;
	
 update cecred.crappep pep
    set pep.dtvencto = add_months(pep.dtvencto,1)
  where pep.cdcooper = 13
    and pep.nrdconta = 184993
    and pep.nrctremp = 188624;	

 update cecred.crappep pep
    set pep.dtvencto = add_months(pep.dtvencto,-1)
  where pep.cdcooper = 13
    and pep.nrdconta = 415189
    and pep.nrctremp = 188905;		
	
  COMMIT;
exception
  when others then
    rollback;
    raise_application_error(-20500, SQLERRM);
end;
