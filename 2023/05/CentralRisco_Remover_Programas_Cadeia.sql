BEGIN

  UPDATE CECRED.crapprg
     SET nrsolici = 99 || SUBSTR(cdprogra,5)
       , inlibprg = 2
   WHERE UPPER(NMSISTEM) = 'CRED' 
     AND UPPER(CDPROGRA) = 'CRPS310';

  UPDATE CECRED.crapprg
     SET nrsolici = 99 || SUBSTR(cdprogra,5)
       , inlibprg = 2
   WHERE UPPER(NMSISTEM) = 'CRED' 
     AND UPPER(CDPROGRA) = 'CRPS660';

  UPDATE CECRED.crapprg
     SET nrsolici = 99 || SUBSTR(cdprogra,5)
       , inlibprg = 2
   WHERE UPPER(NMSISTEM) = 'CRED' 
     AND UPPER(CDPROGRA) = 'CRPS573';

  COMMIT;     

END;