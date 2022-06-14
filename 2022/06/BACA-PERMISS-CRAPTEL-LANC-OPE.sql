DECLARE
BEGIN
  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP
    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',LO'
          ,t.lsopptel = t.lsopptel || ',LANC. OPERACOES'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'ATENDA'
       AND UPPER(t.nmrotina) = 'PRESTACOES';
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
