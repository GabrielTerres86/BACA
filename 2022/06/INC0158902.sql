BEGIN
  UPDATE cecred.crapprm prm
     SET prm.dsvlrprm = '68400'
   WHERE prm.cdacesso like '%HRFIM_ENV_REM_PAGFOR%';
     
  COMMIT;
END;