BEGIN
  UPDATE CECRED.crapprg SET nrsolici = 9984, inlibprg = 2 WHERE cdprogra = 'CRPS534';
  UPDATE CECRED.crapprg SET nrsolici = 9983, inlibprg = 2 WHERE cdprogra = 'CRPS681';
  COMMIT;
END;