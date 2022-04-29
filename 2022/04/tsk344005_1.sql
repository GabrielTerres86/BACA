begin
update craplem
   set nrparepr = 13
 where cdcooper = 13
   and nrdconta = 10766
   and nrctremp =  91572
   and dtmvtolt = '25/04/2022' 
   and cdhistor = 3027;
   
   commit;
exception
  when others then
    rollback;
end;
