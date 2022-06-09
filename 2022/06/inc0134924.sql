begin
  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto, 1)
   where pep.cdcooper = 1
     and pep.nrdconta = 7668732
     and pep.nrctremp = 4885568;  
     
  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto, 1)
   where pep.cdcooper = 1
     and pep.nrdconta = 14534606
     and pep.nrctremp = 5379655;         
  commit;
end;