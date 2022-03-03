BEGIN
UPDATE cecred.tbgen_batch_param SET qtparalelo = 10 WHERE cdcooper > 1 AND cdprograma = 'CRPS734';
COMMIT;
END;
