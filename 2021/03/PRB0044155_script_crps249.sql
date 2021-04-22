BEGIN
  UPDATE crapprg p SET p.inlibprg = 2, p.nrsolici = 99999
    WHERE p.cdprogra = 'CRPS249';

  COMMIT;    
END;
