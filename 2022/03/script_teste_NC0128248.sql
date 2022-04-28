BEGIN
  
delete from crawcrd 
where cdcooper = 10
and nrdconta = 82058
and nrctrcrd in (29741, 32033, 37856);
commit;

END;
