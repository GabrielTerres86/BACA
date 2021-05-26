begin
  for i in (select ass.cdcooper,
                   ass.nrdconta,
                   ass.dtdemiss,
                   ass.cdsitdct
              from crapass ass
             where ass.dtadmiss is not null               
               and ass.cdsitdct = 7) loop
             
      update crapass c
         set c.cdsitdct = 4
       where c.nrdconta = i.nrdconta
         and c.cdcooper = i.cdcooper
         and c.dtadmiss < '01/01/2019';
    
  end loop;
  commit;
end;
