-- INC0032256 - Atualizar data de rejeição, cartão ja está entregu
update crawcrd d
   set d.dtrejeit = null
 where d.cdcooper = 1
   and d.dtrejeit is not null
   and d.nrdconta = 7525010;

Commit;
