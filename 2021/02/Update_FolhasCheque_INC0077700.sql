--Script pra realizar o cancelamento das folhas de cheque
update crapfdc fdc
  set fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8 
where  cdcooper = 13
  and  nrdconta = 709980 
  and  cdagechq = 114
  and  dtliqchq is null; 
commit; 