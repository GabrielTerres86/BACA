update crapseg g
   set g.vlslddev = 90000
      ,g.idimpdps = 1 -- Sim
 where g.cdcooper = 1
   and g.nrdconta = 9559663
   and g.nrctrseg = 174602;
   
COMMIT;   


