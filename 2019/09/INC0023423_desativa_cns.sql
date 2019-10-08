UPDATE crapcns c
   SET c.flgativo = 0
 WHERE c.cdcooper = 1
   AND c.nrdconta = 7162529
   AND c.nrcotcns = 122;

COMMIT;
