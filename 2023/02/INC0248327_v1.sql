begin
  
  delete from cecred.crawcrd
  where cdcooper = 1
  and nrdconta = 3010872 
  and insitcrd = 6
  and nrcrcard = 0;
  
  commit;

end;
