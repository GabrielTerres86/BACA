begin
  --Informar a data de admissão pro cooperado
  update crapass c 
     set c.dtadmiss = to_date('31/08/2008', 'dd/mm/yyyy')
   where c.nrdconta = 89460 
     and c.cdcooper = 12;
  commit;      
end;
