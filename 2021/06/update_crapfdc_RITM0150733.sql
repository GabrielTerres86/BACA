--Update pra cancelamento de folhas de cheque
update crapfdc fdc
  set fdc.dtretchq = trunc(sysdate), fdc.dtliqchq = trunc(sysdate), fdc.incheque = 8
where  cdcooper = 10
  and  nrdconta in (70254)
  and  nrcheque in (317, 318, 319, 322, 323);
commit;

--Update pra cancelamento de folhas de cheque
update crapfdc fdc
  set fdc.dtretchq = trunc(sysdate), fdc.dtliqchq = trunc(sysdate), fdc.incheque = 8
where  cdcooper = 10
  and  nrdconta in (42773)
  and  nrcheque in (139, 140);
commit;
