BEGIN

    update cecred.crapcpa a
    set a.dtbloqueio = NULL,
        A.CDOPERAD_BLOQUE = NULL
    where a.iddcarga = 21258;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
