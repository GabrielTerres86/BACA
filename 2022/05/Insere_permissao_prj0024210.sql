BEGIN 
  INSERT 
    INTO CECRED.CRAPACE (NMDATELA
                        ,CDDOPCAO
                        ,CDOPERAD
                        ,NMROTINA
                        ,CDCOOPER
                        ,NRMODULO
                        ,IDEVENTO
                        ,IDAMBACE)
              SELECT ACE.NMDATELA
                    ,'S'
                    ,ACE.CDOPERAD
                    ,ACE.NMROTINA
                    ,ACE.CDCOOPER
                    ,ACE.NRMODULO
                    ,ACE.IDEVENTO
                    ,ACE.IDAMBACE
               FROM CECRED.CRAPACE ACE
              WHERE UPPER(NMDATELA) = 'ATENDA'
                AND CDOPERAD = 'f0030689'
                AND UPPER(NMROTINA) = 'PRESTACOES'
                AND CDDOPCAO = '@';
    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  END;
