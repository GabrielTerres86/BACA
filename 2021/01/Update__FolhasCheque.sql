--Script pra cancelar/retirar folhas de cheques para a conta 1862022
update crapfdc fdc
  SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
where  cdcooper = 1
  and  nrdconta = 1862022
  and  nrcheque in ( 441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,460);
commit;  
