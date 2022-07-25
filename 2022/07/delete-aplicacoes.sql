BEGIN
  delete from craprda
   where cdcooper = 1
     and nrdconta = 834300;

  delete from craplap
   where cdcooper = 1
     and nrdconta = 834300;

  COMMIT;
END;  
