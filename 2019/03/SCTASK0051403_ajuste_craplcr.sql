BEGIN
  UPDATE craplcr c
     SET c.cdusolcr = 1
   WHERE c.cdcooper = 3
     AND c.cdlcremp IN (5,7);
  
  COMMIT;
END;
