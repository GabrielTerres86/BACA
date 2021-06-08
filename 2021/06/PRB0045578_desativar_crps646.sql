--PRB0045578 desativar programa crps646
UPDATE crapprg SET inlibprg = 2  WHERE cdcooper = 3 AND cdprogra = 'CRPS646';
COMMIT;
