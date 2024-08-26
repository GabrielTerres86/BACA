BEGIN
  
UPDATE cecred.craphis SET cdhistor = 4578
WHERE cdhistor = 4564;

UPDATE cecred.craphis SET cdhistor = 4579
WHERE cdhistor = 4565;

UPDATE cecred.craphis SET cdhistor = 4580
WHERE cdhistor = 4566;

UPDATE cecred.craphis SET cdhistor = 4581
WHERE cdhistor = 4567;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
