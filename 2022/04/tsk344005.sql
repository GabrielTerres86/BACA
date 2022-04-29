begin
  delete craplem
   where dtmvtolt = to_date('25/04/2022')
     and (cdcooper, nrdconta, nrctremp) in
         ((13, 386545, 51508), (13, 223913, 57290), (13, 392413, 129492));
   commit;
exception
  when others then
    rollback;
end;
