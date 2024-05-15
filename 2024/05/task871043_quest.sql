BEGIN

  UPDATE crawepr a
     SET a.nrseqrrq = 42192
   WHERE a.cdcooper = 1
     AND a.nrdconta = 81304366
     AND a.nrctremp = 8149399;

  COMMIT;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;


