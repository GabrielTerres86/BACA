BEGIN
  DELETE FROM cecred.crapass a
   WHERE a.cdcooper = 12
     AND NOT EXISTS (SELECT 1
            FROM cecred.crapsld b
           WHERE b.cdcooper = a.cdcooper
             AND b.nrdconta = a.nrdconta);
  COMMIT;
END;
