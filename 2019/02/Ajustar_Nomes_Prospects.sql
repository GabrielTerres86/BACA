-- Ajustar nome de prospect no CRM (Cadastro unificado). - Wagner - Sustentação.
-- INC0033065 
UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'ORSEGUPS PRESTACAO DE SERVICOS DE LIMPEZA LTDA'
 WHERE a.nrcpfcgc = 14355814000153;

 -- SCTASK0047858
UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'ANA PAULA MERINI DE MELLO'
 WHERE a.nrcpfcgc = 28124757000106;
 
 
 COMMIT;
 