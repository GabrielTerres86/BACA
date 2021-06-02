--Script para realizar o cancelamento das folhas de cheque da coop ACENTRA para a conta 163481
update crapfdc c
  set c.dtliqchq = trunc(SYSDATE), c.dtretchq = trunc(SYSDATE), c.incheque = 8
where  c.cdcooper = 5
  and  c.nrdconta = 163481
  and  c.nrcheque in (65,84,86);
commit; 

--Script para realizar o cancelamento das folhas de cheque da coop VIACREDI para a conta 2077167
update crapfdc c
  set c.dtliqchq = trunc(SYSDATE), c.dtretchq = trunc(SYSDATE), c.incheque = 8
where  c.cdcooper = 1
  and  c.nrdconta = 2077167
  and  c.nrcheque in (406, 407);
commit;
  
 
