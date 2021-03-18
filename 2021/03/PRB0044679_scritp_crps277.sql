BEGIN
  
   UPDATE crapprg SET nrsolici = 92, inlibprg = 1
    WHERE cdprogra = 'CRPS277';
    
   COMMIT;
END;
