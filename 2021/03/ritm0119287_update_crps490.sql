--ritm0119287 - alterar cadeia do programa crps490 da exclusiva para a paralela (Carlos)
--crps490 nrsolici de 82 (noturna exclusiva) para 86 (noturna paralela) e nrordprg para 59
--SELECT * FROM crapprg WHERE cdprogra = 'CRPS490' AND cdcooper <> 3;
/* rollback: UPDATE crapprg pr SET pr.nrsolici = 82, pr.nrordprg = 81 WHERE pr.cdprogra = 'CRPS490' AND cdcooper <> 3; */
UPDATE crapprg pr SET pr.nrsolici = 86, pr.nrordprg = 59 WHERE pr.cdprogra = 'CRPS490' AND cdcooper <> 3;
COMMIT;
