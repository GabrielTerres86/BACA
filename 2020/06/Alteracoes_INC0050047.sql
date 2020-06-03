/*
  INC0050047 - Saldos de caixa incorretos (RDM0035244)
  Realizar a corre��o em caixas que registraram saldos incorretos.
  Os saldos v�m computando diariamente valores incorretos nos campos 
  dos saldos iniciais e finais.
  O objetivo desta requisi��o � aplicar o ajuste nestes saldos at� a data atual.
*/

--Aplica ajuste no saldo final para o dia 20/05/2020
UPDATE crapbcx
   SET vldsdfin = vldsdfin + 114.95
 WHERE dtmvtolt = '20/05/2020' AND cdcooper = 9 AND nrdcaixa = 1 AND cdagenci = 8;

--Aplica ajuste no saldos inicial e final a partir de 21/05/2020
UPDATE crapbcx
   SET vldsdfin = vldsdfin + 114.95, vldsdini = vldsdini + 114.95
 WHERE dtmvtolt > '20/05/2020' AND cdcooper = 9 AND nrdcaixa = 1 AND cdagenci = 8;

/*///////////////////////////////////////////////////*/
COMMIT;

