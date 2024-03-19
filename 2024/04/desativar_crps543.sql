BEGIN
  UPDATE CECRED.crapprg SET nrsolici =99992, inlibprg = 2 WHERE cdprogra = 'CRPS543';
  COMMIT;
END;