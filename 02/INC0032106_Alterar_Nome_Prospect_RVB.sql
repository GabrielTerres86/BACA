-- Ajustar nome de prospect no CRM (Cadastro unificado).
-- INC0032106 - Wagner - Sustentação.
UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'INDUSTRIA E COMERCIO DE MALHAS RVB LTDA'
 WHERE a.nrcpfcgc = 83203992000181;
 

COMMIT;
