-- Ajustar nome de prospect no CRM (Cadastro unificado). - Wagner - Sustentação.
-- INC0032106 
UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'INDUSTRIA E COMERCIO DE MALHAS RVB LTDA'
 WHERE a.nrcpfcgc = 83203992000181;

-- INC0032226
UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'MUNICIPIO DE RODEIO'
 WHERE a.nrcpfcgc = 83102814000164;
 
COMMIT;
