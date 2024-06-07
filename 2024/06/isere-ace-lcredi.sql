DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP

    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',V'
          ,t.lsopptel = t.lsopptel || ',VINCULO TOPAZ'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'LCREDI';
  
               
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
    VALUES 
	  ('LCREDI'
	  ,'V'
	  ,'f0033754'
	  ,' '
	  ,rw_crapcop.cdcooper
	  ,1
	  ,0
	  ,2);
				 		 		 
  END LOOP;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
	RAISE_application_error(-20500, SQLERRM);
END;
