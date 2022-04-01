BEGIN
  UPDATE crapprm m
     SET m.dsvlrprm = 'S'
   WHERE m.cdacesso = 'UTILIZA_REGRAS_SEGPRE';
  COMMIT;
END;
/
