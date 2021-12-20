--Remover programas do batch
UPDATE crapprg SET inlibprg = 2, nrsolici = 9029 WHERE cdprogra = 'CRPS029';
UPDATE crapprg SET inlibprg = 2, nrsolici = 9140 WHERE cdprogra = 'CRPS140';
COMMIT;
