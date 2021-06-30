DECLARE

CURSOR c1 IS
  SELECT *
    FROM crapcop c
   WHERE c.flgativo = 1;


i NUMBER := 0;
vr_dsprogra VARCHAR2(25);

BEGIN
  UPDATE craphec c 
     SET c.dsprogra = 'TAA E INTERNET 3'
   WHERE c.dsprogra LIKE 'TAA E INTERNET';
  

  WHILE(i < 2) LOOP
    vr_dsprogra := 'TAA E INTERNET '||to_char( i + 1);
    FOR r1 IN c1 LOOP
      IF i = 0 THEN
      INSERT INTO craphec
        (cdcooper
        ,cdprogra
        ,dsprogra
        ,hriniexe
        ,hrfimexe
        ,hrultexc
        ,dtultexc
        ,cdoperad
        ,flgativo
        ,nrseqexe
        )
        VALUES
        (r1.cdcooper
        ,NULL
        ,vr_dsprogra
        ,to_char(to_date('15:00:00','hh24:mi:ss'),'sssss')
        ,to_char(to_date('16:00:00','hh24:mi:ss'),'sssss')
        ,NULL
        ,NULL
        ,'1'
        ,1
        ,38);
      ELSIF i = 1 THEN
        INSERT INTO craphec
        (cdcooper
        ,cdprogra
        ,dsprogra
        ,hriniexe
        ,hrfimexe
        ,hrultexc
        ,dtultexc
        ,cdoperad
        ,flgativo
        ,nrseqexe
        )
        VALUES
        (r1.cdcooper
        ,NULL
        ,vr_dsprogra
        ,to_char(to_date('19:00:00','hh24:mi:ss'),'sssss')
        ,to_char(to_date('20:00:00','hh24:mi:ss'),'sssss')
        ,NULL
        ,NULL
        ,'1'
        ,1
        ,39);        
      END IF;
    END LOOP;
    
    i := i + 1;
  END LOOP;
  -- Inserir registro craptab
  FOR r1 IN c1 LOOP
    INSERT INTO craptab 
    (nmsistem
    ,tptabela
    ,cdempres
    ,cdacesso
    ,tpregist
    ,dstextab
    ,cdcooper
    )
    VALUES
    ('CRED'
    ,'GENERI'
    ,0
    ,'NREXECTITULO'
    ,90
    ,'1'
    ,r1.cdcooper);
    -- 
    INSERT INTO craptab 
    (nmsistem
    ,tptabela
    ,cdempres
    ,cdacesso
    ,tpregist
    ,dstextab
    ,cdcooper
    )
    VALUES
    ('CRED'
    ,'GENERI'
    ,0
    ,'NREXECTITULO'
    ,91
    ,'1'
    ,r1.cdcooper);     
  
  END LOOP;
  COMMIT;
END;
