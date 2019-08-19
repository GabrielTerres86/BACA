/* Ajustar nome de dois prospects no CRM (Cadastro unificado). Adriano - Sustentação - Incidentes INC0032304 e INC0032431.

   select a.* 
    from tbcadast_pessoa a
   WHERE a.nrcpfcgc = 11778954000146;

   select a.* 
    from tbcadast_pessoa a
   WHERE a.nrcpfcgc = 79379491001660;
   
   select a.* 
    from tbcadast_pessoa a
   WHERE a.nrcpfcgc = 73710444000194;
   
*/

UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'HAVAN LOJAS DE DEPARTAMENTOS LTDA'
 WHERE a.nrcpfcgc = 79379491001660;

UPDATE tbcadast_pessoa a
   SET a.nmpessoa = 'MERCADO DE ALIMENTOS FAMILIA LTDA'
 WHERE a.nrcpfcgc = 73710444000194;  
 
COMMIT;
 
