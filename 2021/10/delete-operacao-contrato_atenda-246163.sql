begin
  delete from crapebn
   where cdcooper = 12
     and nrdconta = 17833
     and nrctremp = 7602521;

  delete from crapebn
   where cdcooper = 14
     and nrdconta = 130508
     and nrctremp = 1269727;
  commit;

exception
  when others then
    rollback;
end;