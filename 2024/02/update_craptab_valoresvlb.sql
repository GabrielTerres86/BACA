BEGIN
  UPDATE cecred.craptab a 
     SET a.dstextab = '5000,00;0,00;1000,00'
   WHERE UPPER(a.nmsistem)     = 'CRED'
     AND UPPER(a.tptabela) = 'GENERI'
     AND a.cdempres        = 0
     AND UPPER(a.cdacesso) = 'VALORESVLB'
     AND a.tpregist        = 0
     AND a.cdcooper       IN (1,12);
       
  COMMIT;
END;
