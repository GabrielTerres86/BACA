UPDATE craplrt l
   SET l.tpctrato = 0 -- Geral
 WHERE l.cdcooper = 1
   AND l.cddlinha IN (9, 10)
   AND l.tpctrato = 1;

COMMIT;