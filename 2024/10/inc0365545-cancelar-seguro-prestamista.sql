BEGIN

UPDATE cecred.crapseg s
   SET s.cdsitseg = 2,
       s.dtcancel = TRUNC(SYSDATE),
       s.cdmotcan = 4
 WHERE cdcooper = 14
   AND nrdconta = 384500
   AND nrctrseg = 151407
   AND s.tpseguro = 4;

COMMIT;
END;
