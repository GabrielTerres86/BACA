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
  
  INSERT INTO cecred.crapace
    (NMDATELA
    ,CDDOPCAO
    ,CDOPERAD
    ,NMROTINA
    ,CDCOOPER
    ,NRMODULO
    ,IDEVENTO
    ,IDAMBACE)
    (SELECT 'BLQJUD'
           ,'O'
           ,ope.cdoperad
           ,' '
           ,cop.cdcooper
           ,1
           ,0
           ,2
       FROM cecred.crapcop cop
      INNER JOIN (SELECT CASE LEVEL
                          WHEN 1 THEN
                           'f0033479'
                          WHEN 2 THEN
                           'f0034476'
                          WHEN 3 THEN
                           'f0034361'
                          WHEN 4 THEN
                           'f0033754'
                          WHEN 5 THEN
                           'f0033078'
                          WHEN 6 THEN
                           'f0034370'
                        END AS cdoperad
                   FROM DUAL
                 CONNECT BY LEVEL IN (1, 2, 3, 4, 5, 6)) ope
         ON 1 = 1
      WHERE cop.flgativo = 1);
  
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
	RAISE_application_error(-20500, SQLERRM);
END;
