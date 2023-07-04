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
                           'f0033479'
                          WHEN 2 THEN
                           'f0034476'
                          WHEN 3 THEN
                           'f0034361'
                        END AS cdoperad
                   FROM DUAL
                 CONNECT BY LEVEL IN (1, 2, 3)) ope
         ON 1 = 1
      WHERE cop.flgativo = 1);

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    RAISE_application_error(-20500, SQLERRM);
  
    ROLLBACK;
  
END;
