BEGIN

  DELETE FROM cecred.crapace a
   WHERE a.cdcooper IN (6, 9, 5, 12)
     AND nmdatela = 'RESERV'
     AND cddopcao = 'R';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
