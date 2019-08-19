-- Alterar a situação da conta para "4 - Encerrada por demissão".
-- Wagner - Sustentação - INC0032227.
UPDATE crapass a
   SET a.cdsitdct = 4
 WHERE a.cdcooper = 1
   AND a.nrdconta = 6163157;
   
COMMIT;
   