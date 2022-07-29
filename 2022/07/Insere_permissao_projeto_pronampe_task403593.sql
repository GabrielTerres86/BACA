BEGIN
  UPDATE CECRED.CRAPTEL
     SET CDOPPTEL = CDOPPTEL||',A',
         LSOPPTEL = LSOPPTEL||',CONSULTAR RFB'
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
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
 
