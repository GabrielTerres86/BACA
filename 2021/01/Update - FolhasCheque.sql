--Script pra cancelar/retirar folhas de cheques para a conta 8885
update crapfdc fdc
  SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
where  cdcooper = 11
  and  nrdconta = 8885
  and  nrcheque in (1,2,3,4,5,6,7,8,9,10);
commit;  
