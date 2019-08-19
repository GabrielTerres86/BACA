/* ROLLBACK 
UPDATE crawepr
   SET insitapr = 1,
       dtenvest = SYSDATE,
       hrenvest = TO_CHAR(SYSDATE, 'SSSSS'),
       cdopeste = '1',
       flgdocdg = 1
 WHERE cdcooper = 11
   AND nrdconta = 21814
   AND nrctremp = 55580;
*/

DELETE FROM tbepr_cdc_empr_doc
 WHERE cdcooper = 11
   AND nrdconta = 21814
   AND nrctremp = 55580;

UPDATE crawepr
   SET insitapr = 1,
       dtenvest = SYSDATE,
       hrenvest = TO_CHAR(SYSDATE, 'SSSSS'),
       cdopeste = '1',
       flgdocdg = 1
 WHERE cdcooper = 11
   AND nrdconta = 21814
   AND nrctremp = 55580;
   
   
COMMIT;   