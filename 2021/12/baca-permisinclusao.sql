DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP

    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',F'
          ,t.lsopptel = t.lsopptel || ',INCL. MUNUAL'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'IMOVEL';                   
  END LOOP;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_application_error(-20500,SQLERRM);    
END;
