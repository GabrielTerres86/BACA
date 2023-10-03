DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP

    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',O'
          ,t.lsopptel = t.lsopptel || ',OCULTAR MENSAGEM INICIAL'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'BLQJUD'
	   AND UPPER(t.nmrotina) = 'BLQ JUDICIAL';
               
  END LOOP;  
  
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
	RAISE_application_error(-20500, SQLERRM);
END;
