DECLARE
  CURSOR cr_coop is
    SELECT  cdcooper
    FROM    crapcop;
BEGIN
  DELETE crapprg
  WHERE CDPROGRA in ('LOGCDC', 'logcdc');

  DELETE craptel
  WHERE NMDATELA in ('LOGCDC', 'logcdc');

  DELETE crapace
  WHERE NMDATELA in ('LOGCDC', 'logcdc');

  FOR rw_coop in cr_coop LOOP

    INSERT INTO crapprg ( NMSISTEM
                         ,CDPROGRA
                         ,DSPROGRA##1
                         ,DSPROGRA##2
                         ,DSPROGRA##3
                         ,DSPROGRA##4
                         ,NRSOLICI
                         ,NRORDPRG
                         ,INCTRPRG
                         ,CDRELATO##1
                         ,CDRELATO##2
                         ,CDRELATO##3
                         ,CDRELATO##4
                         ,CDRELATO##5
                         ,INLIBPRG
                         ,CDCOOPER
                         ,PROGRESS_RECID
                         ,QTMINMED
                        )
                 VALUES ( 'CRED'
                         ,'LOGCDC'
                         ,'Log Requisi��es API CDC'
                         ,null
                         ,null
                         ,null
                         ,50
                         ,10859
                         ,1
                         ,0
                         ,0
                         ,0
                         ,0
                         ,0
                         ,1
                         ,rw_coop.CDCOOPER
                         ,null
                         ,null
                        );

 


    INSERT INTO craptel ( NMDATELA
                         ,NRMODULO
                         ,CDOPPTEL
                         ,TLDATELA
                         ,TLRESTEL
                         ,FLGTELDF
                         ,FLGTELBL
                         ,NMROTINA
                         ,LSOPPTEL
                         ,INACESSO
                         ,CDCOOPER
                         ,IDSISTEM
                         ,IDEVENTO
                         ,NRORDROT
                         ,NRDNIVEL
                         ,NMROTPAI
                         ,IDAMBTEL
                         ,PROGRESS_RECID
                        )
                 VALUES ( 'LOGCDC'
                         ,1
                         ,'C'
                         ,'Log Requisi��es API CDC'
                         ,'Log Requisi��es API CDC'
                         ,0
                         ,1
                         ,' '
                         ,'CONSULTAR LOG'
                         ,1
                         ,rw_coop.CDCOOPER
                         ,1
                         ,0
                         ,1
                         ,1
                         ,null
                         ,2
                         ,null
                        );

 


    INSERT INTO crapace ( NMDATELA
                         ,CDDOPCAO
                         ,CDOPERAD
                         ,NMROTINA
                         ,CDCOOPER
                         ,NRMODULO
                         ,IDEVENTO
                         ,IDAMBACE
                         ,PROGRESS_RECID
                        )
                VALUES (  'LOGCDC'
                         ,'C'
                         ,1
                         ,' '
                         ,rw_coop.CDCOOPER
                         ,1
                         ,0
                         ,2
                         ,null
                        );

 


    commit;
  END LOOP;
END;
/