--INC0127905 Reativar o paralelismo do programa crps734, pois o mesmo não está rodando nas cooperativas, apenas na Viacredi
UPDATE tbgen_batch_param SET qtparalelo = 10 WHERE cdcooper > 1 AND cdprograma = 'CRPS734';
COMMIT;
