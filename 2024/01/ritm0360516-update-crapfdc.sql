begin
  
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 1
   and c.nrdconta = 9144668 
   and c.nrcheque in (40);
   
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 1
   and c.nrdconta = 6372325 
   and c.nrcheque in (235);
   
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 5
   and c.nrdconta = 146340 
   and c.nrcheque in (845, 846, 847, 848, 849, 850, 865, 866);
   
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 5
   and c.nrdconta = 254177 
   and c.nrcheque in (364, 365, 366, 367);
   
update cecred.crapfdc c
  set c.incheque = 8, c.dtliqchq = trunc(sysdate)
where c.cdcooper = 11
   and c.nrdconta = 541575 
   and c.nrcheque in (697);
   
commit;
end;
