-- Remover caracter especial de complemento de endereço. 
-- INC0033561 - Wagner - Sustentação.
update crapenc  a
   set complend = replace(complend,'',' ')
 where a.progress_recid IN (578879,3045224);

COMMIT;
 