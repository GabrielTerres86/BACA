BEGIN
  UPDATE CECRED.crapprm prm
     SET dsvlrprm = 'D'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper IN (1, 2, 5, 10, 11, 12, 13, 14)
     AND prm.cdacesso = 'LIMITE_APLIC_PLANO_COTAS';
  
  COMMIT;
END;
/
