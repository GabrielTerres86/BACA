/*
  INC0025979 - Ajustar limpeza do campo data de demissão na tabela de cooperados
  com finalidade de permitir o resgate de saldo em cotas da conta 8310114 da VIACREDI

  -- Script de auxilio para conferencia
  SELECT dtdemiss
    FROM crapass ass
   WHERE cdcooper = 1
     AND nrdconta = 8310114;
*/

UPDATE crapass
   SET dtdemiss = NULL
 WHERE cdcooper = 1
   AND nrdconta = 8310114
   AND progress_recid = 729783;

COMMIT;

