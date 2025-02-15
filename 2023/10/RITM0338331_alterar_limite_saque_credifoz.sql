BEGIN
  UPDATE cecred.craptab tab
     SET tab.DSTEXTAB = '1000,00'
   WHERE tab.CDCOOPER = 11
     AND UPPER(tab.NMSISTEM) = 'CRED'
     AND UPPER(tab.TPTABELA) = 'GENERI'
     AND tab.CDEMPRES = 0
     AND UPPER(tab.CDACESSO) = 'SAQMAXCASH'
     AND tab.TPREGIST = 0;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;  
END;
