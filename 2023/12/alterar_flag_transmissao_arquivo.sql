BEGIN
  UPDATE craptab a
     SET a.dstextab = '0 72000 21600 '
  
   WHERE a.cdcooper = 1
     AND UPPER(a.nmsistem) = 'CRED'
     AND UPPER(a.tptabela) = 'GENERI'
     AND a.cdempres = 0
     AND UPPER(a.cdacesso) = 'HRTRTITULO'
     AND a.tpregist = 1;

  COMMIT;

END;
