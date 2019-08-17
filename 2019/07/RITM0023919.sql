-- Atualizar históricos para não debitar os históricos 50 e 59
UPDATE craphis
SET indutblq = 'N'
WHERE cdcooper = 3 AND cdhistor IN (50,59);

-- Efetuar commit
COMMIT;
