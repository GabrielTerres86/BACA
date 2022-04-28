BEGIN
  UPDATE crapprm p
     SET p.dsvlrprm = 'N'
   WHERE p.cdacesso = 'UTILIZA_REGRAS_SEGPRE';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
