BEGIN
  UPDATE cecred.crapcyb a
     SET a.vlsdprej = 0
   WHERE a.cdcooper = 1
     AND a.nrdconta = 10817549
     AND a.nrctremp = 2221610;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
