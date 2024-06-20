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
     WHERE tab.cdacesso = 'HRTRTITULO';

  UPDATE crapaca aca
     SET aca.lstparam =
         (SELECT aca.lstparam
            FROM crapaca aca
           WHERE aca.nmdeacao = 'ALTERA_HORARIO_PARHPG') || ',pr_hrbotatu,pr_hrbotini,pr_hrbotfim'
   WHERE aca.nmdeacao = 'ALTERA_HORARIO_PARHPG';

  UPDATE crapaca aca
     SET aca.lstparam =
         (SELECT aca.lstparam
            FROM crapaca aca
           WHERE aca.nmdeacao = 'CADPAC_GRAVA') || ',pr_hhbotini,pr_hhbotfim'
   WHERE aca.nmdeacao = 'CADPAC_GRAVA';

  COMMIT;
END;