UPDATE craptel
SET tldatela = 'Limite Saque TAA',tlrestel = 'Limite Saque TAA',nmrotina = 'LIMITE SAQUE TAA'
WHERE UPPER(nmdatela) = 'ATENDA' AND UPPER(nmrotina) = 'LIMITES TAA';

COMMIT;