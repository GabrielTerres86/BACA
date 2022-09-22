BEGIN
  UPDATE crapprm prm
     SET prm.dsvlrprm = 'S'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper IN (5, 8)
     AND prm.cdacesso = 'VALIDA_BENEFICIARIO_APTO';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRB0047331');
    ROLLBACK;
END;
