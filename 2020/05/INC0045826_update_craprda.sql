--INC0045826 - Saque total Aplica��o

update craprda rda
   set rda.insaqtot = 1
 where rda.cdcooper = 1
   and rda.nrdconta = 4030370
   and rda.nraplica = 1;
   
COMMIT;      
