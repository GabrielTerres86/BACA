/*
  INC0045540 - Saldos de caixa incorretos (RDM0035007)
  Realizar a correção em caixas que registraram saldos incorretos.
  Os saldos vêm computando diariamente valores incorretos nos campos 
  dos saldos iniciais e finais.
  O objetivo desta requisição é aplicar o ajuste nestes saldos até a data atual.
*/

-- Ticket: INC0043943
-- Cooper: 14
-- Agenc: 1
-- Caixa: 3
-- Data: A partir de 16/03/20
-- Diferenca = R$ 100,56

--Aplica ajuste no saldo final para o dia 16/03/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 100.56 WHERE dtmvtolt = '16/03/2020' AND cdcooper = 14 AND nrdcaixa = 3 AND cdagenci = 1;

--Aplica ajuste no saldos inicial e final a partir de 17/03/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 100.56, vldsdini = vldsdini + 100.56 WHERE dtmvtolt > '16/03/2020' AND cdcooper = 14 AND nrdcaixa = 3 AND cdagenci = 1;
/*///////////////////////////////////////////////////*/
-- Ticket: INC0045540
-- Cooper: 5
-- Agenc: 15
-- Caixa: 2
-- Data: A partir de 13/04/20
-- Diferenca = R$ 114,95

--Aplica ajuste no saldo final para o dia 13/04/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 114.95 WHERE dtmvtolt = '13/04/2020' AND cdcooper = 5 AND nrdcaixa = 2 AND cdagenci = 15;

--Aplica ajuste no saldos inicial e final a partir de 14/04/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 114.95, vldsdini = vldsdini + 114.95 WHERE dtmvtolt > '13/04/2020' AND cdcooper = 5 AND nrdcaixa = 2 AND cdagenci = 15;
/*///////////////////////////////////////////////////*/
-- Ticket: INC0045541
-- Cooper: 5
-- Agenc: 9
-- Caixa: 1
-- Data: A partir de 13/04/20
-- Diferenca = R$ 431,45

--Aplica ajuste no saldo final para o dia 13/04/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 431.45 WHERE dtmvtolt = '13/04/2020' AND cdcooper = 5 AND nrdcaixa = 1 AND cdagenci = 9;

--Aplica ajuste no saldos inicial e final a partir de 14/04/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 431.45, vldsdini = vldsdini + 431.45 WHERE dtmvtolt > '13/04/2020' AND cdcooper = 5 AND nrdcaixa = 1 AND cdagenci = 9;
/*///////////////////////////////////////////////////*/
-- Ticket: INC0046369
-- Cooper: 1
-- Agenc: 194
-- Caixa: 2
-- Data: A partir de 20/04/20
-- Diferenca = R$ 267,07

--Aplica ajuste no saldo final para o dia 20/04/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 267.07 WHERE dtmvtolt = '20/04/2020' AND cdcooper = 1 AND nrdcaixa = 2 AND cdagenci = 194;

--Aplica ajuste no saldos inicial e final a partir de 21/04/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 267.07, vldsdini = vldsdini + 267.07 WHERE dtmvtolt > '20/04/2020' AND cdcooper = 1 AND nrdcaixa = 2 AND cdagenci = 194;
/*///////////////////////////////////////////////////*/
-- Ticket: INC0046378
-- Cooper: 12
-- Agenc: 1
-- Caixa: 10
-- Data: A partir de 17/04/20
-- Diferenca = R$ 114,95

--Aplica ajuste no saldo final para o dia 17/04/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 114.95 WHERE dtmvtolt = '17/04/2020' AND cdcooper = 12 AND nrdcaixa = 10 AND cdagenci = 1;

--Aplica ajuste no saldos inicial e final a partir de 18/04/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 114.95, vldsdini = vldsdini + 114.95 WHERE dtmvtolt > '17/04/2020' AND cdcooper = 12 AND nrdcaixa = 10 AND cdagenci = 1;
/*///////////////////////////////////////////////////*/
-- Ticket: INC0048275
-- Cooper: 1
-- Agenc: 35
-- Caixa: 3
-- Data: A partir de 20/03/20
-- Diferenca = R$ 969,53

--Aplica ajuste no saldo final para o dia 20/03/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 969.53 WHERE dtmvtolt = '20/03/2020' AND cdcooper = 1 AND nrdcaixa = 3 AND cdagenci = 35;

--Aplica ajuste no saldos inicial e final a partir de 21/03/20
UPDATE crapbcx SET vldsdfin = vldsdfin + 969.53, vldsdini = vldsdini + 969.53 WHERE dtmvtolt > '20/03/2020' AND cdcooper = 1 AND nrdcaixa = 3 AND cdagenci = 35;
/*///////////////////////////////////////////////////*/
COMMIT;



