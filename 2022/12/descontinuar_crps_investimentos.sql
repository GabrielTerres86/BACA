BEGIN
UPDATE cecred.crapprg p SET p.inlibprg = 2, p.nrsolici = to_number('99' || p.nrsolici) WHERE cdcooper = 3  AND cdprogra = 'CRPS349';
UPDATE cecred.crapprg p SET p.inlibprg = 2, p.nrsolici = to_number('99' || p.nrsolici) WHERE cdcooper <> 3 AND cdprogra = 'CRPS109';
UPDATE cecred.crapprg p SET p.inlibprg = 2, p.nrsolici = to_number('99' || p.nrsolici) WHERE cdcooper <> 3 AND cdprogra = 'CRPS155';
UPDATE cecred.crapprg p SET p.inlibprg = 2, p.nrsolici = to_number('99' || p.nrsolici) WHERE cdcooper <> 3 AND cdprogra = 'CRPS349';
UPDATE cecred.crapprg p SET p.inlibprg = 2, p.nrsolici = to_number('99' || p.nrsolici) WHERE cdcooper <> 3 AND cdprogra = 'CRPS490';
COMMIT;
END;
