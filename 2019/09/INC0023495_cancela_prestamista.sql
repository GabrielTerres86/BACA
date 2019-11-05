UPDATE crapseg a
   SET a.cdsitseg = 2
     , a.dtcancel = SYSDATE
 WHERE a.cdcooper = 11
   AND a.nrdconta = 67547
   AND a.nrctrseg = 1744;
   
COMMIT;
