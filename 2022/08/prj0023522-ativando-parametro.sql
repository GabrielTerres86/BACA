BEGIN
    update crapprm set dsvlrprm = 'N' where nmsistem = 'CRED' and cdcooper = 0 and cdacesso = 'MLC_ATIVO';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
      
END;