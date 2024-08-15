BEGIN  
  UPDATE cecred.crapprg 
     SET nrsolici = 99985, 
         inlibprg = 2
   WHERE cdprogra = 'CRPS279';
COMMIT;
END;
