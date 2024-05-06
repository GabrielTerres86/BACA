declare
begin
  update crapsld sld
     set sld.vlsddisp = -1636.52
   where sld.cdcooper = 10
     and sld.nrdconta = 99878461;
  commit;
exception
  when others then
  
    rollback;
  
end;
