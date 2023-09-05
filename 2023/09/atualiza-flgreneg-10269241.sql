BEGIN

  UPDATE cecred.crawepr SET flgreneg = 0 WHERE progress_recid = 10269241;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
