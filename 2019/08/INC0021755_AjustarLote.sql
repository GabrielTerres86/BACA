-- Ajustar lote com problema no valor computado.
update craplot a
   set a.vlcompdb = 0
 where a.dtmvtolt = '31/07/2019'
   and a.vlcompdb < 0 
   and a.nrdolote = 8457
   and a.cdcooper = 16;
   
COMMIT;
   