--prb0045005 mover crapprg crps265 para o final da cadeia noturna
UPDATE CRAPPRG SET NRSOLICI = 32, NRORDPRG = 4 WHERE CDPROGRA = 'CRPS265' AND cdcooper <> 3;
COMMIT;
