BEGIN
UPDATE tbgen_batch_param SET QTPARALELO = 10 WHERE cdprograma = 'CRPS573';
DELETE FROM tbgen_batch_controle WHERE cdcooper = 1 AND cdprogra = 'CRPS573' AND dtmvtolt = to_date('28/09/2021','dd/mm/yyyy');
COMMIT;
END;
