BEGIN 
  UPDATE crapass t
  SET t.cdsitdct=4
  WHERE t.cdcooper = 7
  AND t.nrdconta =87858;
  COMMIT;
END;  
