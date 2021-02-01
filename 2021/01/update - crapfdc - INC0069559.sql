update crapfdc
  set incheque = 0
where  cdcooper = 1
  and  nrdconta = 9964959
  and  nrcheque in (359, 395); 
 
commit;  
