declare

begin

  update crapsld sld
     set sld.vlsddisp = -730.60
   where sld.cdcooper = 10
     and sld.nrdconta = 99932547;

  commit;

exception

  when others then
  
    rollback;
  
end;
