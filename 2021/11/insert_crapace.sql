BEGIN
  INSERT INTO crapace(nmdatela,
                    cddopcao,
                    cdoperad,
                    nmrotina,
                    cdcooper,
                    nrmodulo,
                    idevento,
                    idambace)
 (SELECT 'SEGPRE',
          cddopcao,
          cdoperad,
          nmrotina,
          cdcooper,
          nrmodulo,
          idevento,
          idambace   
FROM CRAPACE WHERE NMDATELA = 'TAB049');
  COMMIT;   
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
