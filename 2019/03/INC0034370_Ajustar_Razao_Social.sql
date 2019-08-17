-- Ajustar razão social do cadastro unificado.
-- INC0034370 - Wagner - Sustentação.
update tbcadast_pessoa aa
set aa.nmpessoa = 'TRANSMAGNA TRANSPORTES EIRELI'
where aa.nrcpfcgc = 79942140000562;

COMMIT;
