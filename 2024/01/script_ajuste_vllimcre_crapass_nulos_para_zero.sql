begin

  update cecred.crapass ass
     set ass.vllimcre = 0
   where ass.vllimcre is null 
     and ass.cdcooper = 2

end;