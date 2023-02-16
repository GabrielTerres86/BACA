DECLARE

BEGIN

  UPDATE cecred.crapace ace
     SET ace.cdoperad = 'f0034370'
   WHERE ace.nmdatela LIKE '%RCONSI%'
     AND ace.cddopcao = 'I'
     AND ace.cdoperad = 'f0033406'
     AND ace.cdcooper = 3;

  INSERT INTO cecred.crapace
    (NMDATELA
    ,CDDOPCAO
    ,CDOPERAD
    ,NMROTINA
    ,CDCOOPER
    ,NRMODULO
    ,IDEVENTO
    ,IDAMBACE
    ,PROGRESS_RECID)
  VALUES
    ('RCONSI'
    ,'I'
    ,'f0034361'
    ,NULL
    ,3
    ,1
    ,0
    ,2
    ,NULL);

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
  
    ROLLBACK;
  
END;
