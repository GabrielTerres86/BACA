BEGIN

  update craprda 
     set nraplica = 42 
   where cdcooper = 1 
     and nrdconta = 4064470 
     and nraplica = 43;
   
  update craplap 
     set nraplica = 42 
   where cdcooper = 1 
     and nrdconta = 4064470 
     and nraplica = 43;
     
  update craprda 
     set nraplica = 1 
   where cdcooper = 1 
     and nrdconta = 13620037 
     and nraplica = 3;
     
  update craplap 
     set nraplica = 1 
   where cdcooper = 1 
     and nrdconta = 13620037 
     and nraplica = 3;
     
  update craprda 
     set nraplica = 16 
   where cdcooper = 1 
     and nrdconta = 11813245 
     and nraplica = 14;
     
  update craplap 
     set nraplica = 16 
   where cdcooper = 1 
     and nrdconta = 11813245 
     and nraplica = 14;
     
  update craprda 
     set nraplica = 141 
   where cdcooper = 1 
     and nrdconta = 9713948 
     and nraplica = 140;
     
  update craplap 
     set nraplica = 141 
   where cdcooper = 1 
     and nrdconta = 9713948 
     and nraplica = 140;
     
  update craprda 
     set nraplica = 15 
   where cdcooper = 1 
     and nrdconta = 11877014 
     and nraplica = 12;
     
  update craplap 
     set nraplica = 15 
   where cdcooper = 1 
   and nrdconta = 11877014 
   and nraplica = 12;
   
  COMMIT;
  
END;  
