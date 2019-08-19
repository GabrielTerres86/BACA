BEGIN
  UPDATE crapcob c
     SET c.dsdoccop = DECODE(c.rowid,'AAAS/0ABcAAA2unAAe','GAS AP 203/0001','GAS AP 202/0001')
   WHERE c.rowid IN ('AAAS/0ABcAAA2unAAe','AAAS/0ABcAABlhDAAl');
  
  COMMIT;
END;