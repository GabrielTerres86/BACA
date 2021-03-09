--Script para zerar a informação de custodias 
update crapfdc fdc
  set fdc.cdbantic = 0, fdc.cdagetic = 0, fdc.nrctatic = 0, fdc.incheque = 8,
      fdc.dtretchq = trunc(sysdate), fdc.dtliqchq = trunc(sysdate)
where fdc.nrdconta = 6427804
  and fdc.nrcheque in (83,84);
commit;    
