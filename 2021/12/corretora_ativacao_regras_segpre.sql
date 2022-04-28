BEGIN
  UPDATE crapprm p
     SET p.dsvlrprm = 'S'
   WHERE p.cdacesso = 'UTILIZA_REGRAS_SEGPRE';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
