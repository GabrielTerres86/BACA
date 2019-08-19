
UPDATE crapprg d
SET D.DSPROGRA##1 = 'CONCILIACAO DA CONTA LIQUIDACAO'
where d.cdprogra ='CONSPB'
AND d.cdcooper = 3;

COMMIT;

 
