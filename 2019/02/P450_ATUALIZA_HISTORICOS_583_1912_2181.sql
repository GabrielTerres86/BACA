UPDATE craphis his
   SET his.intransf_cred_prejuizo = 1
 WHERE cdhistor = 2181;
 
UPDATE craphis his
   SET his.indebprj = 1
 WHERE cdhistor IN (583, 1912);
 
COMMIT;
