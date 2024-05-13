BEGIN
  UPDATE CECRED.crapbpr E
     SET e.VLRDOBEM = 1943869.15, e.VLMERBEM = 1943869.15
   WHERE e.cdcooper = 12
         AND e.nrdconta = 108359
         AND e.nrctrpro = 100755;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
