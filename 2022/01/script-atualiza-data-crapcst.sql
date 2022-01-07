begin

update crapcst
   set dtlibera = '25/01/2022'
 where cdcooper = 7
   and nrdconta = 30937
   and nrcheque = 129
   and dtlibera = '10/01/2022'
   and vlcheque = 44550000;

update crapfdc fdc      
    set fdc.nrctatic = 0, 
        fdc.cdbantic = 0, 
        fdc.cdagetic = 0
  where  fdc.cdcooper = 1
    and  fdc.nrdconta = 10868445
    and  fdc.nrcheque = 129;


commit;


end;

