BEGIN
  INSERT INTO craptab
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
    ,'HRTRBOLTIT'
    ,90
    ,'1 18000 14400 SIM'
    ,9);
  
  UPDATE crapaca aca
     SET aca.lstparam =
         (SELECT aca.lstparam
            FROM crapaca aca
           WHERE aca.nmdeacao = 'CADPAC_GRAVA') || ',pr_hhbotini,pr_hhbotfim'
   WHERE aca.nmdeacao = 'CADPAC_GRAVA';
   
   COMMIT;
END;
