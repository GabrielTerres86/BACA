/* Ajustar controles do Debitador devido parada do programa pc_crps509 na Viacredi */

UPDATE crapprm
SET dsvlrprm = '24/12/2021#3'
WHERE cdcooper = 1 AND dsvlrprm = '24/12/2021#4';

COMMIT;
