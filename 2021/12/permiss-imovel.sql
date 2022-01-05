DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cdcooper
                       FROM crapcop c
                      WHERE c.flgativo = 1) LOOP

    UPDATE craptel t
       SET t.cdopptel = t.cdopptel || ',L'
          ,t.lsopptel = t.lsopptel || ',GERA.ARQUIVO'
     WHERE t.cdcooper = rw_crapcop.cdcooper
       AND UPPER(t.nmdatela) = 'IMOVEL';
  
               
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
      SELECT 'IMOVEL'
            ,'L'
            ,ope.cdoperad
            ,' '
            ,ope.cdcooper
            ,1
            ,1
            ,2
        FROM crapace ace
            ,crapope ope
       WHERE UPPER(ace.nmdatela) = 'IMOVEL'
         AND UPPER(ace.cddopcao) = 'I'
         AND UPPER(ace.nmrotina) = ' '
         AND ace.cdcooper = rw_crapcop.cdcooper
         AND ace.idambace = 2
         AND ope.cdcooper = ace.cdcooper
         AND UPPER(ope.cdoperad) = UPPER(ace.cdoperad)
         AND ope.cdsitope = 1;

  END LOOP;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;