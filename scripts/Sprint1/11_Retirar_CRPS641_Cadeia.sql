--Script para ser aplicado na cadeia:
-- retirando uma rotina de calculo do risco de grupo da diária -- Permance na mensal
-- 
UPDATE crapprg
SET crapprg.nrsolici = 999
   ,crapprg.nrordprg = (SELECT MAX(g.nrordprg) ordem
                        FROM crapprg g
                        WHERE g.nrsolici = 999) + 1
WHERE cdprogra = 'CRPS641';

COMMIT;