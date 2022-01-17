BEGIN
  UPDATE CECRED.crapprg SET nrsolici = 76, inlibprg = 1
    WHERE cdprogra = 'CRPS249';
   
  COMMIT;   
END;      
