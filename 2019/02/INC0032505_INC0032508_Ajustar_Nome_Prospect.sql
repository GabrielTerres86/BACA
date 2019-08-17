-- Ajustar nome de dois prospects no CRM (Cadastro unificado). Wagner - Sustentação - Incidentes INC0032505 e INC0032508.
UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'POSTO AGRICOPEL LTDA'
 WHERE a.nrcpfcgc = 83488882002319;

UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'GLOPRESS INDUSTRIAL EIRELI'
 WHERE a.nrcpfcgc = 43109784000101;  
 
COMMIT;
 