-- Viacredi  
UPDATE crapbdt bdt
   SET bdt.dtrejeit = NULL -- 30/10/2020
      ,bdt.hrrejeit = 0 -- 40201
      ,bdt.cdoperej = ' ' -- f0011055
      ,bdt.insitbdt = 3 -- 5
      ,bdt.insitapr = 4 -- 5 
 WHERE bdt.cdcooper = 1
   AND bdt.nrborder = 819328
   AND bdt.nrdconta = 10890424;
   
-- Evolua  
UPDATE crapbdt bdt
   SET bdt.insitbdt = 3 -- 2 
 WHERE bdt.cdcooper = 14
   AND bdt.nrborder = 56925
   AND bdt.nrdconta = 154989;   
   
COMMIT;   