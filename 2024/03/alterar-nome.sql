BEGIN
  update crapprm
  set dsvlrprm = '/usr/coop/'
  where cdacesso = 'ROOT_DIRCOOP'
  and nmsistem = 'CRED'
  and pcdcooper IN(0,0);
   COMMIT;
END;