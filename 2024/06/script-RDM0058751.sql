BEGIN

  DELETE FROM craptab tab
   WHERE tab.cdcooper = 16
     AND UPPER(tab.nmsistem) = 'CRED'
     AND UPPER(tab.tptabela) = 'GENERI'
     AND UPPER(tab.cdacesso) = 'SAQMAXCASH'
     AND tab.tpregist IN (104, 105);

  COMMIT;

END;