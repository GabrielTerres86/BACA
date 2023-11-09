BEGIN
  
  DELETE FROM CECRED.crapace b WHERE b.nmdatela = 'RESERV';

  FOR rw_coop IN (SELECT cdcooper
                     FROM crapcop c
                    WHERE c.flgativo = 1) LOOP
  
  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('RESERV', 'C', 'f0033078', ' ', rw_coop.cdcooper, 1, 0, 2);

  insert into CECRED.crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('RESERV', 'R', 'f0033078', ' ', rw_coop.cdcooper, 1, 0, 2);
    
  END LOOP;

 COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
