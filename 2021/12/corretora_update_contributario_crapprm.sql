BEGIN
  UPDATE crapprm c
     SET c.dsvlrprm = 1
   WHERE c.cdacesso = 'TPCUSTEI_PADRAO';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
