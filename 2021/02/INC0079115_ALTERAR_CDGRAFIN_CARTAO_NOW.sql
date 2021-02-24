BEGIN 
  UPDATE crapacb a
     SET a.cdgrafin = REPLACE(a.cdgrafin, 981, 986) 
   WHERE a.cdadmcrd = 18;
  COMMIT;
END;
