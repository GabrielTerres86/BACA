BEGIN

  UPDATE cecred.crapprm
     SET crapprm.dsvlrprm = '1'
   WHERE crapprm.nmsistem = 'CRED'
     AND crapprm.cdacesso = 'MLC_ATIVO';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'boletos conta yyyyyy');
END;
