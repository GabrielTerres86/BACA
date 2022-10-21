BEGIN

  DELETE FROM craplem a
   WHERE cdcooper = 9
     AND nrdconta = 168009
     AND nrctremp = 18383
     AND dtmvtolt = to_date('21/10/2022', 'dd/mm/yyyy')
     AND cdhistor = 1044
     AND vllanmto IN (103.02, 46.98);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
