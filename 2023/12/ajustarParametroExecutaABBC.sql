BEGIN
    
  UPDATE craptab t
     SET t.dstextab = 'SIM'
   WHERE t.cdcooper IN (3,8,9)
     AND t.nmsistem = 'CRED'
     AND t.tptabela = 'GENERI'
     AND t.cdempres = 0
     AND t.cdacesso = 'EXECUTAABBC'
     AND t.tpregist = 0;
  
  COMMIT;
END;
