/*
DDL_INC0015255 - Ajuste Data Vencimento Última Parcela - Alto Vale
Ana Volles - 13/05/2019

ALTO VALE
cc 655408-3 contrato 111199
--select * from crappep where   rowid = 'AAlHysALlAAI2S+AAM';

SELECT epr.cdlcremp,epr.insitapr,epr.vlemprst,epr.qtpreemp,pep.dtvencto dtultven, pep.rowid
FROM crawepr epr ,crappep pep WHERE epr.cdcooper = 16
AND epr.nrdconta = 6554083 AND epr.nrctremp = 111199 AND pep.cdcooper = epr.cdcooper
AND pep.nrdconta = epr.nrdconta AND pep.nrctremp = epr.nrctremp
AND pep.dtvencto = (SELECT MAX(dtvencto) FROM crappep pep
                     WHERE pep.cdcooper = epr.cdcooper AND pep.nrdconta = epr.nrdconta
                       AND pep.nrctremp = epr.nrctremp);
                       
*/
Begin
  update CRAPPEP epr
  set dtvencto = '29/01/2022'
  where rowid = 'AAlHysALlAAI2S+AAM';
  
  commit;

exception
  
  when others then
  
    rollback;

End;


