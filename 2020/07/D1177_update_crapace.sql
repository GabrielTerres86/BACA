UPDATE crapace
SET nmrotina = 'LIMITES TAA'
WHERE UPPER(nmdatela) = 'ATENDA' AND UPPER(nmrotina) = 'LIMITE SAQUE TAA';

COMMIT;