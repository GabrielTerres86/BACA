BEGIN

UPDATE crawcrd w 
   SET w.nrcctitg = 1938185
 WHERE w.cdcooper = 1
   AND w.nrdconta = 7290470
   AND w.cdadmcrd = 87;

COMMIT;
END;