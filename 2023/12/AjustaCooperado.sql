BEGIN
  DELETE 
    FROM cecred.crapass a
   WHERE a.progress_recid = 2139261;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
