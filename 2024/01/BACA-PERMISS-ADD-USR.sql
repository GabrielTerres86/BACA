BEGIN

  FOR rw_coop IN ((SELECT cdcooper
                     FROM cecred.crapcop c
                    WHERE c.flgativo = 1)) LOOP
  
    INSERT INTO cecred.crapace
      (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES
      ('ATENDA', 'CR', 'f0033078', 'PRESTACOES', rw_coop.cdcooper, 1, 0, 2);    
    INSERT INTO cecred.crapace
      (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES
      ('ATENDA', 'CR', 'f0033479', 'PRESTACOES', rw_coop.cdcooper, 1, 0, 2);
    INSERT INTO cecred.crapace
      (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES
      ('ATENDA', 'CR', 'f0033754', 'PRESTACOES', rw_coop.cdcooper, 1, 0, 2);
    INSERT INTO cecred.crapace
      (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES
      ('ATENDA', 'CR', 'f0034370', 'PRESTACOES', rw_coop.cdcooper, 1, 0, 2);
    INSERT INTO cecred.crapace
      (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
    VALUES
      ('ATENDA', 'CR', 'f0034476', 'PRESTACOES', rw_coop.cdcooper, 1, 0, 2);
  
  END LOOP;

COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
