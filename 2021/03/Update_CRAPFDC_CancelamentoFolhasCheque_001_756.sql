--Script para realizar o cancelmento de folhas de chques para os bancos 756 e 001
update crapfdc fdc
  set fdc.dtretchq = trunc(sysdate), fdc.dtliqchq = trunc(sysdate), fdc.incheque = 8
WHERE  fdc.cdbanchq in (1,756)--bancos que terão seus cheques cancelados
   AND  fdc.dtretchq is null -- cheques nao retirados
   AND  fdc.dtliqchq is null -- cheques nao compensados
   AND  fdc.incheque = 0
   AND  fdc.progress_recid >= 19463458
   AND  fdc.progress_recid <= 33222014; --cheques com situação normal
commit;   
