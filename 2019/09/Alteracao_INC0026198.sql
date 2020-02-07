/*
  INC0026198 - Saldos de fechamento de caixa incorretos para as data 05 e 06/09/2019
  para o caixa 01, Agência 01 da VIACREDI.

  Efetua correções nos valores
*/

UPDATE crapbcx SET vldsdfin = 94377.54 WHERE progress_recid = 1353040;
UPDATE crapbcx SET vldsdini = 94377.54, vldsdfin = 8377.54 WHERE progress_recid = 1353670;

COMMIT; 

