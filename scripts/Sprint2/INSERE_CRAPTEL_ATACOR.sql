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
            'ATACOR'
          , 3
          , '@,A,I,E'  
          , 'Atualização de acordos'
          , 'Atualização de acordos'
          , 0
          , 1
          , 'ACESSO,ALTERAR,INCLUIR,EXCLUIR'
          , 2
          , rw_cooperativas.cdcooper -- Cooperativa
          , 1
          , 3
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
          , 'ATACOR' 
          , 'Atualização de acordos'
          , 50
          , vr_nrordprg
          , 'CRED'
        );
    END LOOP;
END;