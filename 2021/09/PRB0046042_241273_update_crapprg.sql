BEGIN
  UPDATE crapprg SET inlibprg = 2 WHERE cdprogra = 'CRPS280';
  UPDATE crapprg SET inlibprg = 2 WHERE cdprogra = 'CRPS516';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
