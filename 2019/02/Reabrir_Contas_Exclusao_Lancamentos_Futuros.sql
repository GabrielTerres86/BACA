-- Alterar a situação da conta para "1 - Liberada".
-- Wagner - Sustentação - INC0033129, INC0033099 e INC0033050.
UPDATE crapass a
   SET a.cdsitdct = 1 
 WHERE a.cdcooper = 1
   AND a.nrdconta = 3210677;
   
Commit;   

-- INC0033099.
UPDATE crapass a
   SET a.cdsitdct = 1
 WHERE a.cdcooper = 1
   AND a.nrdconta = 6577296;

Commit;   

-- INC0033050
UPDATE crapass a
   SET a.cdsitdct = 1
 WHERE a.cdcooper = 1
   AND a.nrdconta = 9454608;
   
Commit;

   