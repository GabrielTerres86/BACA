BEGIN
  UPDATE crapprm
    SET dsvlrprm = dsvlrprm ||',3526'
  WHERE nmsistem = 'CRED'
    AND cdcooper = 0
    AND cdacesso = 'HISTOR_SALDO_FIM_SEMANA';
  COMMIT;
  
EXCEPTION
    WHEN OTHERS THEN
         ROLLBACK;
     
END;
