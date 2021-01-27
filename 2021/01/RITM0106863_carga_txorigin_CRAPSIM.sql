-- Carga taxa original da simulacao emprestimo
BEGIN

  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP
  
    UPDATE crapsim a
       SET a.txorigin = a.txmensal
     WHERE a.cdcooper = rw_crapcop.cdcooper
       AND a.txmensal > 0;
  
    COMMIT;
  
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;