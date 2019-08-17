BEGIN
  UPDATE crapprm
     SET dsvlrprm = '000000000,00'
   WHERE nmsistem = 'CRED'
     AND cdacesso = 'VL_MAX_ESTORN_DST'
     AND TRIM(dsvlrprm)  IS NULL;
  COMMIT;
END;
