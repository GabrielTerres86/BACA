BEGIN
  update CECRED.crapprm
  set dsvlrprm = '/usr/coop/'
  where cdacesso = 'ROOT_DIRCOOP'
  and nmsistem = 'CRED'
  and cdcooper = 0;
   COMMIT;
END;