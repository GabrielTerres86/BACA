BEGIN
  UPDATE cecred.crawepr
    SET insitest = 3
       ,dtanulac = NULL
  WHERE cdcooper = 1
    AND nrdconta = 11699337
    AND nrctremp = 7292587;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
