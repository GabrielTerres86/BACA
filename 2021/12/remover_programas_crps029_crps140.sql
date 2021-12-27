--Remover programas do batch (9 + solici anterior + nrcrps)
UPDATE crapprg SET inlibprg = 2, nrsolici = 92029 WHERE cdprogra = 'CRPS029';
UPDATE crapprg SET inlibprg = 2, nrsolici = 94083 WHERE cdprogra = 'CRPS083';
UPDATE crapprg SET inlibprg = 2, nrsolici = 94140 WHERE cdprogra = 'CRPS140';
COMMIT;
