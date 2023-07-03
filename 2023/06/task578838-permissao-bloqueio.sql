DECLARE

BEGIN

  FOR rw_crapcop IN (SELECT cop.cdcooper
                       FROM cecred.crapcop cop
                      WHERE cop.flgativo = 1) LOOP
    UPDATE cecred.craptel tel
       SET tel.cdopptel = tel.cdopptel || ',BO'
          ,tel.lsopptel = tel.lsopptel || ',BLOQUEIO ORIGEM'
     WHERE tel.cdcooper = rw_crapcop.cdcooper
       AND UPPER(tel.nmdatela) = 'BLQJUD'
       AND UPPER(tel.nmrotina) = 'BLOQUEIO';
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
           ,'BO'
           ,ope.cdoperad
           ,'BLOQUEIO'
           ,cop.cdcooper
           ,1
           ,0
           ,2
       FROM cecred.crapcop cop
      INNER JOIN (SELECT CASE LEVEL
                          WHEN 1 THEN
                           'F0034370'
                        END AS cdoperad
                   FROM DUAL
                   CONNECT BY LEVEL IN (1)) ope
         ON 1 = 1
      WHERE cop.flgativo = 1);
 
  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
