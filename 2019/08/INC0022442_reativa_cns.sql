UPDATE crapcns c
   SET c.flgativo = 1
 WHERE c.cdcooper = 1
   AND c.nrdconta = 2505070
   AND c.nrcotcns = 440;

COMMIT;
