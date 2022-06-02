declare
begin

  delete from cecred.craplem lem
   where lem.cdcooper = 13
     and lem.nrdconta = 14958
     and lem.nrctremp = 118515
     and lem.nrparepr = 0
     and trunc(lem.dtmvtolt) = trunc(to_date('26/05/2022', 'dd/mm/yyyy'))
     and lem.cdhistor = 3019
     and lem.vllanmto = 2.04;

  if sql%rowcount = 1 then
    commit;
  else
    rollback;
  end if;

  commit;

exception

  when others then
    rollback;
  
end;
