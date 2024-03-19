BEGIN
  UPDATE CECRED.crapprg SET nrsolici = 9980, inlibprg = 2 WHERE cdprogra = 'CRPS598';
  UPDATE CECRED.crapprg SET nrsolici = 9979, inlibprg = 2 WHERE cdprogra = 'CRPS599';
  UPDATE CECRED.crapprg SET nrsolici = 9978, inlibprg = 2 WHERE cdprogra = 'CRPS608';
  COMMIT;
END;