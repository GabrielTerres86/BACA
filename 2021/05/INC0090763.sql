begin
  for i in (select ass.cdcooper,
                   ass.nrdconta,
                   ass.dtdemiss,
                   ass.cdsitdct
              from crapass ass
             where ass.dtdemiss is not null               
               and ass.cdsitdct = 7) loop
             
      update crapass c
         set c.cdsitdct = 4
       where c.nrdconta = i.nrdconta
         and c.cdcooper = i.cdcooper
         and c.dtdemiss < to_date('01/01/2019','DD/MM/YYYY');
    
  end loop;
  commit;
end;
