DECLARE

BEGIN

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
           ,' '
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
