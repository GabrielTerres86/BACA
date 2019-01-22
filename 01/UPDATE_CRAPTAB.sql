BEGIN
  UPDATE craptab
     SET dstextab = '10000,00;10000,00'
   WHERE nmsistem = 'CRED'
     AND tptabela = 'GENERI'
     AND cdempres = 0
     AND cdacesso = 'VLMICFEMPR'
     AND tpregist = 0;
  --
  UPDATE craptab
     SET dstextab = '0,00'
   WHERE nmsistem = 'CRED'
     AND tptabela = 'GENERI'
     AND cdempres = 0
     AND cdacesso = 'VLMICFLIMI'
     AND tpregist = 0;
  COMMIT;
END;
