-- VIACREDI CONTA 10146091
-- Exclui Lançamento
DELETE FROM tbcc_prejuizo_lancamento t
 WHERE t.cdcooper = 1
   AND t.nrdconta = 10146091
   AND t.vllanmto = 2500
   AND t.cdhistor = 2408
   AND t.dtmvtolt = '24-06-2020';

-- Reverte saldo dev. Prejuizo
UPDATE tbcc_prejuizo  a
   SET a.vlsdprej = Nvl(vlsdprej,0) - 2500
 WHERE a.cdcooper = 1
   AND a.nrdconta = 10146091;
-- VIACREDI CONTA 10146091


-- CREDIFOZ CONTA 20036
-- Exclui Lançamento
DELETE FROM tbcc_prejuizo_lancamento t
 WHERE t.cdcooper = 1
   AND t.nrdconta = 20036
   AND t.vllanmto = 12000
   AND t.cdhistor = 2408
   AND t.dtmvtolt = '24-06-2020';

-- Reverte saldo dev. Prejuizo
UPDATE tbcc_prejuizo  a
   SET a.vlsdprej = Nvl(vlsdprej,0) - 12000
 WHERE a.cdcooper = 1
   AND a.nrdconta = 20036;
-- CREDIFOZ CONTA 20036

COMMIT;