BEGIN
  UPDATE cecred.craptab tab 
     SET tab.dstextab = '0 79200 21600 SIM'
   WHERE tab.cdcooper        = 1
     AND UPPER(tab.nmsistem) =  'CRED'
     AND UPPER(tab.tptabela) = 'GENERI'
     AND tab.cdempres        = 0
     AND UPPER(tab.cdacesso) IN ('HRPGAILOS')
     AND tab.tpregist        = 90;
  COMMIT;
END;