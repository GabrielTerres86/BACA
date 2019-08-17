BEGIN
  --
  UPDATE craptab
     SET dstextab = '10000,00;10000,00'
   WHERE upper(nmsistem) = 'CRED'
     AND upper(tptabela) = 'GENERI'
     AND cdempres = 0
     AND upper(cdacesso) = 'VLMICFEMPR'
     AND tpregist = 0;
  --
  UPDATE craptab
     SET dstextab = '0,00'
   WHERE upper(nmsistem) = 'CRED'
     AND upper(tptabela) = 'GENERI'
     AND cdempres = 0
     AND upper(cdacesso) = 'VLMICFLIMI'
     AND tpregist = 0;
	 
  COMMIT;
END;
