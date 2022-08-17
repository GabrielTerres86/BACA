BEGIN
  UPDATE CECRED.crapseg p
     SET p.cdmotcan = 20
        ,p.dtcancel = TRUNC(SYSDATE)
        ,p.cdsitseg = 2
   WHERE p.cdcooper = 13
     AND p.nrdconta = 499862
     AND p.nrctrseg = 341254
     AND p.tpseguro = 4;
  COMMIT;
END;
/
