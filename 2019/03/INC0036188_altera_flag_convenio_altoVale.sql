--SELECT cco.flgregis, cco.* FROM crapcco cco WHERE cco.cdcooper = 16 AND cco.nrconven = 970115
UPDATE crapcco cco 
   SET cco.flgregis = 1
 WHERE cco.cdcooper = 16 AND cco.nrconven = 970115;
 
COMMIT;
