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
    ,8
    ,'1 18000 14400 SIM'
    ,9);
  
  UPDATE crapaca aca
     SET aca.lstparam =
         (SELECT aca.lstparam
            FROM crapaca aca
           WHERE aca.nmdeacao = 'ALTERA_HORARIO_PARHPG') || ',pr_hrbotatu,pr_hhbotini,pr_hhbotfim' 
   WHERE aca.nmdeacao = 'ALTERA_HORARIO_PARHPG';
   
   COMMIT;
END;






