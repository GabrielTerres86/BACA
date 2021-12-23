BEGIN

  DELETE crapace e
   WHERE UPPER(cdoperad) = 'F0033402'
     AND cdcooper = 1
     AND UPPER(e.nmdatela) = 'ATENDA'
     AND UPPER(e.nmrotina) = 'LIMITE CRED';

  FOR rw_crapace IN (SELECT e.cddopcao,
                            e.idambace,
                            e.idevento
                       FROM crapace e
                      WHERE UPPER(cdoperad) = 'F0033402'
                        AND cdcooper = 16
                        AND UPPER(e.nmdatela) = 'ATENDA'
                        AND UPPER(e.nmrotina) = 'LIMITE CRED') LOOP
  
    INSERT INTO crapace
      (NMDATELA
      ,CDDOPCAO
      ,CDOPERAD
      ,NMROTINA
      ,CDCOOPER
      ,NRMODULO
      ,IDEVENTO
      ,IDAMBACE)
    VALUES
      ('ATENDA'
      ,rw_crapace.cddopcao
      ,'F0033402'
      ,'LIMITE CRED'
      ,1
      ,1
      ,rw_crapace.idevento
      ,rw_crapace.idambace);
  
  END LOOP;
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
