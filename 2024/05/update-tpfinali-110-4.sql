BEGIN

  UPDATE cecred.crapfin SET tpfinali = 4 WHERE cdcooper = 9 and cdfinemp = 110;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
