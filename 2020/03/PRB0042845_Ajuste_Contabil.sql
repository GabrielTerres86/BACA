/*Conta 202541 CredCrea (situação fraude) INC0040265.
- Realizar UPDATE dos valor R$ 45.144,52 (recuperando prejuízo)*/

-- Excluir 2408 do dia 06/03/2020 R$ 45.000,00
DELETE FROM tbcc_prejuizo_detalhe a
   WHERE a.cdcooper = 7
     AND a.nrdconta = 202541
     AND a.cdhistor = 2408
     AND a.vllanmto = 45000;

-- Realizar UPDATE dos valor R$ 45.000,00 (recuperando prejuízo)
UPDATE tbcc_prejuizo  a
  SET a.vlsdprej = Nvl(vlsdprej,0) - 45000
WHERE a.cdcooper = 7
  AND a.nrdconta = 202541;

COMMIT;
