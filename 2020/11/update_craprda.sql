--RDM0037362 - alterar flag resgate

update craprda 
   set insaqtot = 1, 
       vlsltxmx = 0,
       vlsltxmm = 0
 where cdcooper = 1
   and nrdconta = 9478710
   and nraplica = 1;
   
commit;
