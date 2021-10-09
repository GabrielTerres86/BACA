BEGIN
  UPDATE tbgen_batch_param SET QTPARALELO = 10 WHERE cdprograma = 'CRPS516';
  DELETE FROM tbgen_batch_controle WHERE cdcooper = 1 AND cdprogra = 'CRPS516' AND dtmvtolt = to_date('28/09/2021','dd/mm/yyyy');
  COMMIT;
END;