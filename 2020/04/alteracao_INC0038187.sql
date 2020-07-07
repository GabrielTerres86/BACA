/*
  INC0038187 - Saldos de caixa incorretos (RDM0034706)
  Dois caixas online da cooperativa Credcrea registraram saldos 
  incorretos em 15/01/2020 e 31/01/2020.
  Desde estas datas, estes dois caixas vêm computando diariamente 
  os saldos iniciais e finais com a diferença referente a estas datas.
  O objetivo desta requisição é aplicar o ajuste nos saldos destes 
  dois caixas até a data atual.
*/

-- Aplica ajuste no saldo final do caixa 2 em 15/01/2020
UPDATE crapbcx
   SET vldsdfin = vldsdfin + 109.76
 WHERE dtmvtolt = '15/01/2020'
   AND cdcooper = 7
   AND nrdcaixa = 2
   AND cdagenci = 3;
   
-- Aplica ajuste no saldos inicial e final do caixa 2 a partir de 16/01/2020
UPDATE crapbcx
   SET vldsdfin = vldsdfin + 109.76, 
       vldsdini = vldsdini + 109.76
 WHERE dtmvtolt > '15/01/2020'
   AND cdcooper = 7
   AND nrdcaixa = 2
   AND cdagenci = 3;

-- Aplica ajuste no saldo final do caixa 2 em 31/01/2020
UPDATE crapbcx
   SET vldsdfin = vldsdfin + 622.19
 WHERE dtmvtolt = '31/01/2020'
   AND cdcooper = 7
   AND nrdcaixa = 2
   AND cdagenci = 6;
   
-- Aplica ajuste no saldos inicial e final do caixa 2 a partir de 01/02/2020
UPDATE crapbcx
   SET vldsdfin = vldsdfin + 622.19, 
       vldsdini = vldsdini + 622.19
 WHERE dtmvtolt > '31/01/2020'
   AND cdcooper = 7
   AND nrdcaixa = 2
   AND cdagenci = 6;

commit;

