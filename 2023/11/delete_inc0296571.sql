BEGIN
  DELETE FROM cecred.tbgen_batch_paralelo
  WHERE cdcooper = 14
  AND cdprogra  = 'CRPS001'
  AND dtmvtolt = to_date('19/10/2023','dd/mm/yyyy');
  COMMIT;
END;
