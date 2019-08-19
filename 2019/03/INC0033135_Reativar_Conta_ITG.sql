-- Reativar conta ITG, conforme solicitação da área de negócio.
-- INC0033135 - Wagner - Sustentação.
UPDATE crapass a
   SET a.flgctitg = 2 -- ativa
 WHERE a.cdcooper = 1
   AND a.nrdconta = 2893282;
   
COMMIT;   
