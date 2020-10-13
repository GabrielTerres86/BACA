BEGIN
  UPDATE craptab tab
     SET tab.dstextab = tab.dstextab || ' 31/01/2021'
   WHERE upper(tab.nmsistem) = 'CRED'
     AND upper(tab.tptabela) = 'USUARI'
     AND tab.cdempres        = 11
     AND upper(tab.cdacesso) = 'SEGPRESTAM'
     AND tab.tpregist        = 0;
     
  COMMIT;
END;
