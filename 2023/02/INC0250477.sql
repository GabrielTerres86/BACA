begin
  delete from cecred.crawcrd
  where cdcooper = 1
  and nrdconta = 6285406 
  and insitcrd = 6
  and nrcrcard = 0;
  
  INSERT INTO tbcrd_expurgo (
    cdcooper,
    nrcrcard,
    nrcctitg,
    instatus
 ) VALUES (
       1,
       5474080004988133,
       7563239015515,
       'PENDENTE'
 );
    
  commit;
end;
