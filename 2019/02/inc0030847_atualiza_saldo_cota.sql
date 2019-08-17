-- INC0030847 - Atualizar valor das cotas do cooperado, está faltando R$ 14,44
update crapcot t
   set t.vldcotas = t.vldcotas + 14.44
 where t.cdcooper = 1
   and t.nrdconta = 2817055;
   
commit;
