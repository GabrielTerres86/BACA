-- Ajustar nome de pessoa no cadastro unificado. INC0011284. Wagner - Sustenta��o.
UPDATE tbcadast_pessoa aa
   SET aa.nmpessoa = 'CLAUDIO HORONGOSO'
 where aa.nrcpfcgc = 1120099994;
 
COMMIT;

 
