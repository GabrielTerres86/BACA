BEGIN
  
UPDATE cecred.craplcr l
   SET l.tpcuspr = 1
 WHERE l.flgsegpr = 0
   AND l.tpcuspr = 0;
   
COMMIT;
END;
