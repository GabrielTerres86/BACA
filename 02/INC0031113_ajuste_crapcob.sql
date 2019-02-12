BEGIN
  UPDATE crapcob c
     SET c.dsdoccop = REPLACE(c.dsdoccop,'á','A')
   WHERE c.rowid IN ('AAAS/0ABcAAA2unAAe','AAAS/0ABcAABlhDAAl');
  
  COMMIT;
END;
