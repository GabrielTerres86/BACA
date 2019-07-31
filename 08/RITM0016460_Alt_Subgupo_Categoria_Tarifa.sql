-- Alterar o subgrupo e categoria da tarifa 379.
-- Subgrupo de 15 para 29
-- Cartegoria de 2 para 25.

UPDATE craptar a
  SET a.cdsubgru = 29
     ,a.cdcatego = 25
WHERE a.cdtarifa = 379;

COMMIT;

