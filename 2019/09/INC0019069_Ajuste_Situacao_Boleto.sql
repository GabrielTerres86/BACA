BEGIN
  UPDATE crapcob c SET c.insitcrt = 5 WHERE c.cdcooper = 14 AND c.nrdconta = 37990 AND c.nrdocmto = 560 AND c.nrcnvcob = 113004;
  UPDATE crapcob c SET c.insitcrt = 5 WHERE c.cdcooper = 1 AND c.nrdconta = 7260261 AND c.nrdocmto = 505 AND c.nrcnvcob = 10120;
  COMMIT;
END;