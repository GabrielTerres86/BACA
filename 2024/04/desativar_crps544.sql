BEGIN
  UPDATE CECRED.crapprg SET nrsolici = 1, inlibprg = 1 WHERE cdprogra = 'CRPS544';
  COMMIT;
END;