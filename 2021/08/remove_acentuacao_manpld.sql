declare

begin

UPDATE tbgen_dominio_campo
   SET dscodigo = 'Rotina 22 - Deposito entre Coop.'
 WHERE cddominio = 19;

UPDATE tbgen_dominio_campo
   SET dscodigo = 'Rotina 51 - Deposito'
 WHERE cddominio = 20;

commit;

end;
/