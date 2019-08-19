-- Ajustar endereços inválidos na base de contatos da conta.
-- INC0033481 - Wagner - Sustentação.
update crapenc a
   set nrendere = 1
 where a.progress_recid IN (1217781,637534,2497919,759763);
 
COMMIT;
 