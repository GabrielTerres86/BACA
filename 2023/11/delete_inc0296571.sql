BEGIN
  DELETE FROM cecred.tbgen_batch_paralelo
  WHERE cdcooper = 14
  AND cdprogra IN ('CRPS782', 'CRPS782_13')
  AND dtmvtolt = '19/10/2023';
  COMMIT;
END;
