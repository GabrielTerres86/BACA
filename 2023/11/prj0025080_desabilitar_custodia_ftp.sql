BEGIN
  UPDATE CECRED.crapccc SET flghomol = 0 WHERE cdcooper > 0 AND flghomol = 1 AND idretorn = 2;
  
  COMMIT;
END;
/