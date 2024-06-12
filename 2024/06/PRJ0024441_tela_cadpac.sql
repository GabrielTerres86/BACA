BEGIN
  INSERT INTO craptab
    (nmsistem
    ,tptabela
    ,cdempres
    ,cdacesso
    ,tpregist
    ,dstextab
    ,cdcooper)
    SELECT nmsistem
          ,tptabela
          ,cdempres
          ,'HRTRBOLTIT'
          ,tpregist
          ,dstextab
          ,cdcooper
      FROM craptab tab
     WHERE tab.nmsistem = 'CRED'
       AND tab.cdacesso = 'HRTRTITULO'
       AND tab.tptabela = 'GENERI'
       AND tab.cdempres = 0
       AND tab.cdcooper = 9
       AND tab.tpregist = 90;
       
  UPDATE crapaca aca
     SET aca.lstparam =
         (SELECT aca.lstparam
            FROM crapaca aca
           WHERE aca.nmdeacao = 'CADPAC_GRAVA') || ',pr_hhbotini,pr_hhbotfim'
   WHERE aca.nmdeacao = 'CADPAC_GRAVA';
   COMMIT;
END;






