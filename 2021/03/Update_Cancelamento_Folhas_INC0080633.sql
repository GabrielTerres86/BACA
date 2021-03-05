--Scritp pra cancelamento de folhas de cheque
update crapfdc fdc
  set fdc.dtretchq = trunc(sysdate), fdc.dtliqchq = trunc(sysdate), fdc.incheque = 8
where  cdcooper = 12
  and  nrdconta = 10456
  and  nrcheque in (1,2,3,4,5,6,7,8,9,10);
commit;    
  
