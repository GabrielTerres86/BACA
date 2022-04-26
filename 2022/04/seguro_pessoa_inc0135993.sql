BEGIN  
  UPDATE crapprg p
     SET inlibprg = 2,
         nrsolici = 9998
   WHERE p.cdprogra = 'CRPS814';
COMMIT;   
END;
/  
