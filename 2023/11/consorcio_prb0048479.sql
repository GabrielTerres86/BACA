BEGIN
  UPDATE CECRED.crapprg p
     SET p.nrsolici = 9658
        ,p.inlibprg = 2
   WHERE p.cdcooper = 3
     AND UPPER(p.nmsistem) = 'CRED'
     AND UPPER(p.cdprogra) = 'CRPS658';
   COMMIT;
END;
/
