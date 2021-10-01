begin
  delete from crapebn
   where cdcooper = 12
     and nrdconta = 17833
     and nrctremp = 7602521;
  commit;

exception
  when others then
    rollback;
end;