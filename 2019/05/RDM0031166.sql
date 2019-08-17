prompt RDM0031166

set feedback off
set define off


update crapepr
   set inrisco_refin = 2
     , dtinicio_atraso_refin = '10/11/2016'
     , qtdias_atraso_refin = 0
 where cdcooper = 5
   and nrdconta = 40940
   and nrctremp = 5304 ;

update crawepr
   set dtdpagto = '10/11/2016'
 where cdcooper = 5
   and nrdconta = 40940
   and nrctremp = 5304 ;  
   

update crapadi
   set dtdpagto = '10/11/2016'
 where cdcooper = 5
   and nrdconta = 40940   ;   

update crapass
   set dsnivris = 'A'
 where cdcooper = 5
   and nrdconta = 40940



commit;

prompt Done.
