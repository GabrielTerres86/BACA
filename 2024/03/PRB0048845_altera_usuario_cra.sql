BEGIN

  UPDATE crapprm prm
     SET DSVLRPRM = 'admin_ailos;Ailos_2024'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 3
     AND prm.cdacesso = 'WS_IEPTB_AUTHENTICATION';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRB0048845');
    ROLLBACK;
  
END;
