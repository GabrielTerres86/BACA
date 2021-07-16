BEGIN
  DELETE FROM CRAPACE
   WHERE NMDATELA LIKE '%SIMCON%';
  DELETE FROM CRAPTEL
   WHERE NMDATELA LIKE '%SIMCON%';
  DELETE FROM CRAPPRG
   WHERE CDPROGRA LIKE '%SIMCON%';

  DECLARE
    CURSOR cr_coop IS
      SELECT UNIQUE CDCOOPER
        FROM CRAPCOP;
  
  BEGIN
    FOR rw_coop IN cr_coop LOOP
      INSERT INTO craptel
        (nmdatela
        ,nrmodulo
        ,cdopptel
        ,tldatela
        ,tlrestel
        ,flgteldf
        ,flgtelbl
        ,nmrotina
        ,lsopptel
        ,inacesso
        ,cdcooper
        ,idsistem
        ,idevento
        ,nrordrot
        ,nrdnivel
        ,nmrotpai
        ,idambtel)
      VALUES
        ('SIMCON'
        ,5
        ,'@,I,C'
        ,'Simulador de Consórcio'
        ,'Simulador de Consórcio'
        ,0
        ,1
        ,' '
        ,'Acesso,INCLUIR,Consulta'
        ,1
        ,rw_coop.CDCOOPER
        ,1
        ,0
        ,1
        ,1
        ,''
        ,2);
      COMMIT;
    END LOOP;
  END;

  DECLARE
    CURSOR cr_listaope IS
      SELECT UNIQUE cdoperad
            ,cdcooper
        FROM crapope
       WHERE cdsitope = 1;
  BEGIN
    FOR rw_listaope IN cr_listaope LOOP
      INSERT INTO crapace
        (nmdatela
        ,cddopcao
        ,cdoperad
        ,nmrotina
        ,cdcooper
        ,nrmodulo
        ,idevento
        ,idambace)
      VALUES
        ('SIMCON'
        ,'C'
        ,rw_listaope.cdoperad
        ,' '
        ,rw_listaope.cdcooper
        ,1
        ,1
        ,2);
      COMMIT;
      INSERT INTO crapace
        (nmdatela
        ,cddopcao
        ,cdoperad
        ,nmrotina
        ,cdcooper
        ,nrmodulo
        ,idevento
        ,idambace)
      VALUES
        ('SIMCON'
        ,'I'
        ,rw_listaope.cdoperad
        ,' '
        ,rw_listaope.cdcooper
        ,1
        ,1
        ,2);
      COMMIT;
      INSERT INTO crapace
        (nmdatela
        ,cddopcao
        ,cdoperad
        ,nmrotina
        ,cdcooper
        ,nrmodulo
        ,idevento
        ,idambace)
      VALUES
        ('SIMCON'
        ,'@'
        ,rw_listaope.cdoperad
        ,' '
        ,rw_listaope.cdcooper
        ,1
        ,1
        ,2);
      COMMIT;
    END LOOP;
  END;

  DECLARE
    CURSOR cr_coop IS
      SELECT UNIQUE CDCOOPER
        FROM CRAPCOP;
  BEGIN
    FOR rw_coop IN cr_coop LOOP
      INSERT INTO crapprg
        (nmsistem
        ,cdprogra
        ,dsprogra##1
        ,dsprogra##2
        ,dsprogra##3
        ,dsprogra##4
        ,nrsolici
        ,nrordprg
        ,inctrprg
        ,cdrelato##1
        ,cdrelato##2
        ,cdrelato##3
        ,cdrelato##4
        ,cdrelato##5
        ,inlibprg
        ,cdcooper)
        SELECT 'CRED'
              ,'SIMCON'
              ,'Simulador de Consórcio'
              ,'.'
              ,'.'
              ,'.'
              ,406
              ,NULL
              ,1
              ,0
              ,0
              ,0
              ,0
              ,0
              ,1
              ,cdcooper
          FROM crapcop
         WHERE cdcooper IN (rw_coop.cdcooper);
      COMMIT;
    END LOOP;
  END;
  COMMIT;
END;
