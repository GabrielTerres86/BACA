DECLARE

BEGIN

  UPDATE cecred.craptel tel
     SET tel.cdopptel = tel.cdopptel || ',U'
        ,tel.lsopptel = tel.lsopptel || ',GERAR ARQ CERC'
   WHERE UPPER(tel.nmdatela) = 'ATENDA'
     AND UPPER(tel.nmrotina) = 'EMPRESTIMOS'
     AND EXISTS (SELECT cop.cdcooper
            FROM cecred.crapcop cop
           WHERE cop.cdcooper = tel.cdcooper
             AND cop.flgativo = 1);

  INSERT INTO cecred.crapace
    (NMDATELA
    ,CDDOPCAO
    ,CDOPERAD
    ,NMROTINA
    ,CDCOOPER
    ,NRMODULO
    ,IDEVENTO
    ,IDAMBACE)
    (SELECT 'ATENDA'
           ,'U'
           ,ope.cdoperad
           ,'EMPRESTIMOS'
           ,cop.cdcooper
           ,1
           ,0
           ,2
       FROM cecred.crapcop cop
      INNER JOIN (SELECT CASE LEVEL
                          WHEN 1 THEN
                           'f0033406'
                          WHEN 2 THEN
                           'f0033495'
                          WHEN 3 THEN
                           'f0033853'
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
