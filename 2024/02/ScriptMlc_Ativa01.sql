BEGIN

  UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = '1'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdacesso = 'MLC_ATIVO';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'MLC');
END;
