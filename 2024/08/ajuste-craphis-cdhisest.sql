BEGIN 
UPDATE cecred.craphis SET cdhisest = 4578
WHERE cdhistor = 2311;
UPDATE cecred.craphis SET cdhisest = 4579
WHERE cdhistor = 2313;
UPDATE cecred.craphis SET cdhisest = 4580
WHERE cdhistor = 2312;
UPDATE cecred.craphis SET cdhisest = 4581
WHERE cdhistor = 2314;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
