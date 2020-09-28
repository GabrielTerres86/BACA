BEGIN
  UPDATE crapslc 
     SET vlrsaldo = 0
   WHERE cdcooper = 9 
     AND cdagenci = 21;
  
  COMMIT;
  
END;

