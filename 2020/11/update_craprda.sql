--RDM0037362 - alterar flag resgate
 
update craplap
   set vllanmto = 20.83
 where PROGRESS_RECID = 138551658;

update craprda
   set insaqtot = 1,
       vlsltxmx = 0,
       vlsltxmm = 0
 where cdcooper = 1
   and nrdconta = 9478710
   and nraplica = 1;
   
commit;
