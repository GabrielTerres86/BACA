BEGIN
  UPDATE crapprg c
    SET c.nrsolici = 1, 
        c.inlibprg = 1
  WHERE c.cdprogra  = 'CRPS814'; 
COMMIT;
END;
/
