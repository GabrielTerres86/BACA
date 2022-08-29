BEGIN
  UPDATE CECRED.CRAPTEL
     SET CDOPPTEL = CDOPPTEL||',A,F',
         LSOPPTEL = LSOPPTEL||',CONSULTAR REC FED,CONSULTAR COBRANCA'
   WHERE NMDATELA = 'PRONAM';
  COMMIT;

  INSERT 
    INTO CECRED.CRAPACE(NMDATELA
                       ,CDDOPCAO
                       ,CDOPERAD
                       ,NMROTINA
                       ,CDCOOPER
                       ,NRMODULO
                       ,IDEVENTO
                       ,IDAMBACE)
                SELECT ACE.NMDATELA
                      ,'A'
                      ,ACE.CDOPERAD
                      ,ACE.NMROTINA
                      ,ACE.CDCOOPER
                      ,ACE.NRMODULO
                      ,ACE.IDEVENTO
                      ,ACE.IDAMBACE
                 FROM CECRED.CRAPACE ACE
                WHERE UPPER(NMDATELA) = 'PRONAM'
                  AND CDDOPCAO = 'L';

  INSERT 
    INTO CECRED.CRAPACE(NMDATELA
                       ,CDDOPCAO
                       ,CDOPERAD
                       ,NMROTINA
                       ,CDCOOPER
                       ,NRMODULO
                       ,IDEVENTO
                       ,IDAMBACE)
                SELECT ACE.NMDATELA
                      ,'F'
                      ,ACE.CDOPERAD
                      ,ACE.NMROTINA
                      ,ACE.CDCOOPER
                      ,ACE.NRMODULO
                      ,ACE.IDEVENTO
                      ,ACE.IDAMBACE
                 FROM CECRED.CRAPACE ACE
                WHERE UPPER(NMDATELA) = 'PRONAM'
                  AND CDDOPCAO = 'L';
	   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
	RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;