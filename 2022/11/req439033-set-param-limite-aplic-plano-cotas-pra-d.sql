BEGIN
  UPDATE CECRED.crapprm prm
     SET dsvlrprm = 'D'
   WHERE prm.nmsistem = 'CRED'
     AND prm.cdcooper = 8
     AND prm.cdacesso = 'LIMITE_APLIC_PLANO_COTAS';
  
  COMMIT;
END;
/