DECLARE
  
  CURSOR cr_coops IS
    SELECT t.cdcooper
      FROM crapcop t
     WHERE t.flgativo = 1; -- Ativas

BEGIN 

  -- Percorrer todas as cooperativas ativas
  FOR rgcop IN cr_coops LOOP
    -- Insere os dados da empresa
    INSERT INTO cecred.crapemp(cdempres
                              ,nmextemp
                              ,nmresemp
                              ,sgempres
                              ,tpdebcot
                              ,tpdebemp
                              ,tpdebppr
                              ,flgpagto
                              ,cdcooper
                              ,idtpempr)
                       VALUES (9998                          -- cdempres
                              ,'EMPREGADOR PESSOA FISICA'    -- nmextemp
                              ,'EMPREGADOR PF'               -- nmresemp
                              ,'F'                           -- sgempres
                              ,1                             -- tpdebcot
                              ,1                             -- tpdebemp
                              ,1                             -- tpdebppr
                              ,0                             -- flgpagto
                              ,rgcop.cdcooper                -- cdcooper
                              ,'O');                         -- idtpempr

    -- Inserir os parametros para a empresa
    INSERT INTO CECRED.CRAPTAB
          (nmsistem
          ,tptabela
          ,cdempres
          ,cdacesso
          ,tpregist
          ,dstextab
          ,cdcooper)
        VALUES
          ('CRED'
          ,'GENERI'
          ,0
          ,'DIADOPAGTO'
          ,9998
          ,'01 01 01 270 0'
          ,rgcop.cdcooper);
    
    --
    INSERT INTO CECRED.CRAPTAB
          (nmsistem
          ,tptabela
          ,cdempres
          ,cdacesso
          ,tpregist
          ,dstextab
          ,cdcooper)
        VALUES
          ('CRED'
          ,'GENERI'
          ,0
          ,'NUMLOTECOT'
          ,9998
          ,'0'
          ,rgcop.cdcooper);
    
    --
    INSERT INTO CECRED.CRAPTAB
          (nmsistem
          ,tptabela
          ,cdempres
          ,cdacesso
          ,tpregist
          ,dstextab
          ,cdcooper)
        VALUES
          ('CRED'
          ,'GENERI'
          ,0
          ,'NUMLOTEEMP'
          ,9998
          ,'0'
          ,rgcop.cdcooper);
    
    --
    INSERT INTO CECRED.CRAPTAB
          (nmsistem
          ,tptabela
          ,cdempres
          ,cdacesso
          ,tpregist
          ,dstextab
          ,cdcooper)
        VALUES
          ('CRED'
          ,'GENERI'
          ,0
          ,'NUMLOTEFOL'
          ,9998
          ,'0'
          ,rgcop.cdcooper);
    
    --
    INSERT INTO CECRED.CRAPTAB
          (nmsistem
          ,tptabela
          ,cdempres
          ,cdacesso
          ,tpregist
          ,dstextab
          ,cdcooper)
        VALUES
          ('CRED'
          ,'USUARI'
          ,9998
          ,'VLTARIF008'
          ,1
          ,'000000000,00'
          ,rgcop.cdcooper);

  END LOOP;
  
  COMMIT;
    
END;
