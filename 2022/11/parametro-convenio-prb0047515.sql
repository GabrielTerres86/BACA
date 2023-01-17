BEGIN
  UPDATE cecred.crapprm
     SET dsvlrprm = '1'
   WHERE nmsistem = 'CRED'
     AND cdcooper = 0
     AND cdacesso = 'CONSIST_FATURA_TRIBUTOS';
  COMMIT;
END;
