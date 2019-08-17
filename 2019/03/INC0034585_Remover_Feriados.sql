-- Eliminar dois feriados que foram alterados de data via COMPE. INC0034585 - Wagner - Sustentação.
delete from crapfsf where progress_recid = 173026;
delete from crapfsf where progress_recid = 174343;

COMMIT;
