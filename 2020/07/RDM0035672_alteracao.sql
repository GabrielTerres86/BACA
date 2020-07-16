/*
  INC0048037-RDM0035672 - Script para incluir data de liberação / cancelamento 
*/
-- Conta encerrada, cheques cancelados
-- Conta ativa, cheques cancelados, data 01/01/0001
-- Conta ativa, cheques cancelados, data nula
-- colocar data retirada = data da compensação/cancelamento
UPDATE crapfdc fdc
   SET fdc.dtretchq = nvl(fdc.dtliqchq, trunc(SYSDATE))
 WHERE nvl(fdc.dtretchq, '01/01/0001') = '01/01/0001'
   AND fdc.incheque = 8 -- CHeques Cancelados
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper);

COMMIT;

-- Conta encerrada, cheques ativos
-- colocar cheques como cancelados (incheque = 8, dtcompensacao = sysdate), colocar data de retirada = sysdate
UPDATE crapfdc fdc
   SET fdc.dtretchq = trunc(SYSDATE), fdc.dtliqchq = trunc(SYSDATE), fdc.incheque = 8
 WHERE nvl(fdc.dtretchq, '01/01/0001') = '01/01/0001'
   AND fdc.incheque = 0
   AND EXISTS (SELECT 1
          FROM crapass ass
         WHERE ass.nrdconta = fdc.nrdconta
           AND ass.cdcooper = fdc.cdcooper
           AND ass.cdsitdct = 4); -- Contas encerradas

COMMIT;
