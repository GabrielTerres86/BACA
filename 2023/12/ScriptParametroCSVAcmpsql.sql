BEGIN

  UPDATE crapprm prm
     SET prm.dsvlrprm = 'cecred/acmp/relatorios'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdacesso = 'ROOT_ACMPS';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'update diretorio acmps');
END;
