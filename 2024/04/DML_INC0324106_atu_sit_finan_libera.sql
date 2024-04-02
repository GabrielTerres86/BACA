BEGIN
  
  UPDATE CRAPPRM
     SET dsvlrprm = 0
   WHERE nmsistem = 'CRED'
     AND cdacesso = 'DIGIT_RISCO_FINAN_LIBERA';
     
  COMMIT;
     
END;
