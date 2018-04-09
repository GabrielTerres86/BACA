DECLARE

    CURSOR cr_cooperativas IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
    rw_cooperativas cr_cooperativas%ROWTYPE; 

    vr_nrordprg INTEGER;

BEGIN
    SELECT MAX(nrordprg)
      INTO vr_nrordprg
      FROM crapprg aux
     WHERE aux.nrsolici = 50; 

    vr_nrordprg := vr_nrordprg + 1;

    FOR rw_cooperativas IN cr_cooperativas
    LOOP
        INSERT INTO CECRED.CRAPTEL
        (
            NMDATELA
          , NRMODULO
          , CDOPPTEL
          , TLDATELA   
          , TLRESTEL
          , FLGTELDF
          , FLGTELBL  
          , LSOPPTEL
          , INACESSO
          , CDCOOPER
          , IDSISTEM
          , IDEVENTO
          , NRORDROT
          , NRDNIVEL
          , NMROTPAI
          , IDAMBTEL
        )
        VALUES
        ( 
            'ATVPRB'
          , 5
          , '@,A,I,E,C,H'  
          , 'Ativos Problemáticos'
          , 'Ativos Problemáticos'
          , 0
          , 1
          , 'ACESSO,ALTERAR,INCLUIR,EXCLUIR,CONSULTA,HISTORICO'
          , 2
          , rw_cooperativas.cdcooper -- Cooperativa
          , 1
          , 5
          , 1
          , 1
          , ''
          , 2
        );

        INSERT INTO CRAPPRG
        (
            CDCOOPER 
          , CDPROGRA
          , DSPROGRA##1
          , NRSOLICI                    
          , NRORDPRG  
          , NMSISTEM
        )
        VALUES (
            rw_cooperativas.cdcooper
          , 'ATVPRB' 
          , 'Ativos Problemáticos'
          , 50
          , vr_nrordprg
          , 'CRED'
        );
    END LOOP;
    
    COMMIT;
END;
