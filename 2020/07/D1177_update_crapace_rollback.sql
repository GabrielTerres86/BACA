UPDATE crapace
SET nmrotina = 'LIMITE SAQUE TAA'
WHERE UPPER(nmdatela) = 'ATENDA' AND UPPER(nmrotina) = 'LIMITES TAA';

COMMIT;