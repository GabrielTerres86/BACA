BEGIN
UPDATE CECRED.crapprg
   SET nrsolici = 4, nrordprg = 1
 WHERE UPPER(cdprogra) = 'CRPS312'
   AND UPPER(NMSISTEM) = 'CRED'
   AND CDCOOPER NOT IN (4, 15, 17);
COMMIT;
END;
