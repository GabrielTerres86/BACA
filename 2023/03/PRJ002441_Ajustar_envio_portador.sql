BEGIN
  UPDATE crapprm prm
     SET prm.dsvlrprm = 30
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 0
     AND prm.cdacesso = 'QT_LOGBAIXAOPERACIONAL';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3);
END;
