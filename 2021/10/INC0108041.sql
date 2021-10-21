begin
  
  update craprac
   set idsaqtot = 1
 where cdcooper = 1
   and cdprodut = 1007
   and nrdconta = 12227870
   and nraplica = 1;
   
update craprac
   set idsaqtot = 1
 where cdcooper = 1
   and cdprodut = 1007
   and nrdconta = 12224227
   and nraplica = 3;

update craprac
   set idsaqtot = 1
 where cdcooper = 1
   and cdprodut = 1007
   and nrdconta = 10563628
   and nraplica = 26;
   
update craprac
   set idsaqtot = 1
 where cdcooper = 2
   and cdprodut = 1007
   and nrdconta = 387363
   and nraplica = 35;
   
update craprac
   set idsaqtot = 1
 where cdcooper = 9
   and cdprodut = 1007
   and nrdconta = 367478
   and nraplica = 15;
   
update craprac
   set idsaqtot = 1
 where cdcooper = 10
   and cdprodut = 1007
   and nrdconta = 26433
   and nraplica = 37;
   
update craprac
   set idsaqtot = 1
 where cdcooper = 14
   and cdprodut = 1007
   and nrdconta = 22039
   and nraplica = 28;
   
commit;
   
end;
