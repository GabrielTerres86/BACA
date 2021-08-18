begin

  update craplac
     set nraplica = 27
   where cdcooper = 1
     and nraplica = 24
     and nrdconta = 9324712;

  update craprac
     set nraplica = 27
   where cdcooper = 1
     and nraplica = 24
     and nrdconta = 9324712;

  update craplac
     set nrdocmto = 1474
   where cdcooper = 1
     and nrdconta = 9324712
     and nrseqdig = 1474;

  commit;

end;
