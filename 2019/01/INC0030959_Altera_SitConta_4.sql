-- Alterar a situação da conta para "4 - Encerrada por Demissão"
UPDATE CRAPASS
   SET CDSITDCT = 4
 WHERE CDCOOPER = 7
   AND NRDCONTA = 214914;

COMMIT;
