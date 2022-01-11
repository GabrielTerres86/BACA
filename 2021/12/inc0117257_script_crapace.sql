BEGIN

  DELETE crapace e
   WHERE UPPER(cdoperad) = 'F0033402'
     AND cdcooper = 1
     AND UPPER(e.nmdatela) = 'ATENDA'
     AND UPPER(e.nmrotina) = 'LIMITE CRED';

  FOR rw_crapace IN (SELECT e.nmdatela,
                            e.cddopcao,
                            e.cdoperad,
                            e.nmrotina,
                            e.nrmodulo,
                            e.idevento,
                            e.idambace
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
      (rw_crapace.nmdatela,
       rw_crapace.cddopcao,
       rw_crapace.cdoperad,
       rw_crapace.nmrotina,
      1,
      rw_crapace.nrmodulo,
      rw_crapace.idevento,
      rw_crapace.idambace);
  
  END LOOP;
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
