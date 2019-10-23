BEGIN
  UPDATE crapcob c SET c.incobran = 3 WHERE c.cdcooper = 16 AND c.nrdconta = 180408 AND c.nrdocmto = 397 AND c.nrcnvcob = 115070;
  UPDATE crapcob c SET c.incobran = 3 WHERE c.cdcooper = 13 AND c.nrdconta = 10235 AND c.nrdocmto = 8928 AND c.nrcnvcob = 11250;
  COMMIT;
END;