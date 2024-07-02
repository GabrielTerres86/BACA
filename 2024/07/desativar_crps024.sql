BEGIN
update cecred.crapprg set nrsolici =9980, inlibprg=2 where cdprogra ='CRPS024' and cdcooper =12;
COMMIT;
END;