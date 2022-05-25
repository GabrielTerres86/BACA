begin
  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto, -1)
   where pep.cdcooper = 13
     and pep.nrdconta = 184993
     and pep.nrctremp = 188624;	 

  commit;
end;