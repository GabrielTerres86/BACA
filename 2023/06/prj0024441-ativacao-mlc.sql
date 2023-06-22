BEGIN
  UPDATE crapprm prm
     SET prm.DSVLRPRM = 1
   WHERE prm.NMSISTEM = 'CRED'
     AND prm.CDCOOPER = 0
     AND prm.CDACESSO = 'MLC_ATIVO';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');
    ROLLBACK;
    RAISE;
END;
/