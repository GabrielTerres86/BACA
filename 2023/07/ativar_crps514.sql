BEGIN
  UPDATE cecred.crapprg SET nrsolici = 1, nrordprg = 25, inlibprg = 1 WHERE cdprogra = 'CRPS514' AND cdcooper = 3;
  COMMIT;
END;
