     
 update crapcob b 
     set b.inenvcip = 1
   where b.cdcooper = 1
     and b.nrdconta = 3047733
     and b.dtmvtolt = '17/12/2018'
     and b.nrcnvcob = 10131
     and b.nrdocmto between 46435 and 46446
     and b.incobran = 0;
     
  update crapcob b 
     set b.inenvcip = 1 
   where cdcooper = 1
     and nrdconta = 3047733
     and dtmvtolt = '17/12/2018'
     and nrcnvcob = 10131
     and nrdocmto between 46411 and 46422
     and b.incobran = 0;               
     
commit;     
