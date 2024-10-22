BEGIN
  UPDATE CECRED.CRAPTEL
     SET CDOPPTEL = CDOPPTEL||',G',
         LSOPPTEL = LSOPPTEL||',GERAR CONTRATO BNDES'
   WHERE NMDATELA = 'RATBND';
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
                      ,'G'
                      ,ACE.CDOPERAD
                      ,ACE.NMROTINA
                      ,ACE.CDCOOPER
                      ,ACE.NRMODULO
                      ,ACE.IDEVENTO
                      ,ACE.IDAMBACE
                 FROM CECRED.CRAPACE ACE
                WHERE UPPER(NMDATELA) = 'RATBND'
                  AND CDDOPCAO = 'I';
	   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
	  RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;