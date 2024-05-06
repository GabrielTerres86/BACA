BEGIN

  UPDATE craptab tab
     SET tab.dstextab = '0' || substr(tab.dstextab, 2)
   WHERE UPPER(tab.cdacesso) LIKE UPPER('%HRTRTITULO%') 
     AND tab.cdcooper = 8
     AND tab.tpregist = 90
     AND UPPER(tab.nmsistem) = 'CRED'
     AND UPPER(tab.tptabela) = 'GENERI';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'altera HRTRTITULO');
END;
