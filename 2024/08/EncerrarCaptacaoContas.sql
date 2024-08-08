BEGIN
  UPDATE craprac rac
     SET rac.idsaqtot = 1
   WHERE rac.cdcooper = 1
     AND rac.nrdconta IN (99996286,99996561,99998459)
     AND rac.idsaqtot = 0;
  
  COMMIT;
  
END;
