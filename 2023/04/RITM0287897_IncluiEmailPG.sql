BEGIN
  UPDATE crapprm prm
     SET prm.dsvlrprm = prm.dsvlrprm || ';fabrica.servicos@ailos.coop.br'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdacesso = 'CRPS693_EMAIL';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    SISTEMA.excecaoInterna(pr_cdcooper => 3);
END;
