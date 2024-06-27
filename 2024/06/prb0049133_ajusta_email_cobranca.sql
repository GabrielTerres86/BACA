BEGIN
  UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = 'cobranca@ailos.coop.br,leomir.fischer@ailos.coop.br'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 0
     AND prm.cdacesso = 'EMAIL_NOTIFICA_COBRAN';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRB0049133 Geral');
    ROLLBACK;
    RAISE;
END;