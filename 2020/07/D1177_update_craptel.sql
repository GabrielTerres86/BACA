UPDATE craptel
SET tldatela = 'Limites TAA',tlrestel = 'Limites TAA',nmrotina = 'LIMITES TAA'
WHERE UPPER(nmdatela) = 'ATENDA' AND UPPER(nmrotina) = 'LIMITE SAQUE TAA';

COMMIT;