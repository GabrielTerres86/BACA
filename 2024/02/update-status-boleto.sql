BEGIN

  UPDATE crapcob c
     SET c.flgdprot = 0
        ,c.qtdiaprt = 0
        ,c.indiaprt = 3
   WHERE nrdconta = 82304963
     AND cdcooper = 9
     AND nrdocmto IN (91001, 91002, 91003, 91004, 91005);
  
   COMMIT;
END;
