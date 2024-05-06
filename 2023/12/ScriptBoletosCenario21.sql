BEGIN
  UPDATE craptab tab
     SET tab.dstextab = '0' || substr(tab.dstextab, 2)
   WHERE UPPER(tab.cdacesso) LIKE UPPER('%HRTRTITULO%') 
     AND tab.cdcooper = 9
     AND tab.tpregist = 90
     AND UPPER(tab.nmsistem) = 'CRED'
     AND UPPER(tab.tptabela) = 'GENERI';
  COMMIT;
END;
