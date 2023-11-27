BEGIN

  UPDATE crapprm prm
     SET prm.dsvlrprm = '0'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdacesso = 'MLC_ATIVO';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3);
END;
