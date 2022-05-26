BEGIN

  UPDATE craptab
     SET craptab.dstextab = '1 64800'
   WHERE craptab.cdcooper = 1
     AND UPPER(craptab.nmsistem) = 'CRED'
     AND UPPER(craptab.tptabela) = 'GENERI'
     AND craptab.cdempres = 0
     AND UPPER(craptab.cdacesso) = 'HRTRCOMPEL'
     AND craptab.tpregist = 25; --PA

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0023522');
END;
