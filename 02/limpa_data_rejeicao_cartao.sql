-- INC0032256 - Atualizar data de rejei��o, cart�o ja est� entregu
update crawcrd d
   set d.dtrejeit = null
 where d.cdcooper = 1
   and d.dtrejeit is not null
   and d.nrdconta = 8131945;

Commit;
