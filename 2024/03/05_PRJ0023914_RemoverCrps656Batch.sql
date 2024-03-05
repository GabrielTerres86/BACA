BEGIN
  UPDATE cecred.crapprg a
     SET a.nrsolici = 99999
        ,a.inlibprg = 2
   WHERE a.nmsistem = 'CRED'
     AND a.cdprogra = 'CRPS656'
     AND a.cdcooper = 3;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
