BEGIN

  UPDATE crawepr a
     SET a.insitapr = 1
        ,a.insitest = 3
   WHERE a.cdcooper = 11
     AND a.nrdconta = 459089
     AND a.nrctremp = 374761;

  COMMIT;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;


