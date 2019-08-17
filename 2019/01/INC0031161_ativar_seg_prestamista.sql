-- INC0031161 - Ativar seguro prestamista que foi cancelado indevidamente
update crapseg g 
   set g.dtfimvig = null
      ,g.dtcancel = null
      ,g.cdsitseg = 1 -- 1 Ativo 
 where g.cdcooper = 1
   and g.nrdconta = 9559663
   and g.tpseguro = 4;
   
Commit;   
