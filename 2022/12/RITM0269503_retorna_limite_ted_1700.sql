BEGIN
  UPDATE cecred.crapprm
     SET dsvlrprm = 2448000
   WHERE nmsistem = 'CRED'
     AND cdacesso = 'BLQJ_HORATED_JURIDICO'             
     AND cdcooper = 0;

  COMMIT;
END;