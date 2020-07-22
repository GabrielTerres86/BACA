/* inc0032941_update_seguros.sql
05/03/2020 - inc0032941 Atualizar seguros para cancelados (Carlos)
*/
UPDATE crapseg SET cdsitseg = 2, dtcancel = trunc(SYSDATE), dtfimvig = trunc(SYSDATE), cdopeexc = '1', cdageexc = 1, dtinsexc = trunc(SYSDATE), cdopecnl = '1'
WHERE cdcooper = 13 AND nrdconta = 23760 AND nrctrseg IN (1588,1987,9942);

UPDATE crapseg SET cdsitseg = 2, dtcancel = trunc(SYSDATE), dtfimvig = trunc(SYSDATE), cdopeexc = '1', cdageexc = 1, dtinsexc = trunc(SYSDATE), cdopecnl = '1'
WHERE cdcooper = 13 AND nrdconta = 221910 AND nrctrseg IN (12460,12077);

UPDATE crapseg SET cdsitseg = 2, dtcancel = trunc(SYSDATE), dtfimvig = trunc(SYSDATE), cdopeexc = '1', cdageexc = 1, dtinsexc = trunc(SYSDATE), cdopecnl = '1'
WHERE cdcooper = 8 AND nrdconta = 40444 AND nrctrseg IN (4999);

UPDATE crapseg SET cdsitseg = 2, dtcancel = trunc(SYSDATE), dtfimvig = trunc(SYSDATE), cdopeexc = '1', cdageexc = 1, dtinsexc = trunc(SYSDATE), cdopecnl = '1'
WHERE cdcooper = 13 AND nrdconta = 264881  AND nrctrseg IN (26422);

UPDATE crapseg SET cdsitseg = 2, dtcancel = trunc(SYSDATE), dtfimvig = trunc(SYSDATE), cdopeexc = '1', cdageexc = 1, dtinsexc = trunc(SYSDATE), cdopecnl = '1'
WHERE cdcooper = 14 AND nrdconta = 34258  AND nrctrseg IN (5194,7260,7289);

COMMIT;
