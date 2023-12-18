BEGIN
  UPDATE cecred.crapprg SET inlibprg = 2, nrsolici = 9335 WHERE UPPER(cdprogra) = 'CRPS335' AND cdcooper <> 3;
  COMMIT;
END;
