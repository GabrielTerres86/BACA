BEGIN
  
UPDATE CECRED.crapseg
   SET cdsitseg = 2
 WHERE cdcooper = 1
   AND nrctrseg = 1512451;
COMMIT;
END;
