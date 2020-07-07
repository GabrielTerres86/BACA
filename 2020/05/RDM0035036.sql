UPDATE crappep
   SET vlpagpar = 240.44 -- 46,38
     , vlsdvpar = 0     -- 194.06
     , vlsdvatu = 0     -- 240.44
     , vlsdvsji = 0     -- 194,06
WHERE progress_recid = 145101315;


UPDATE crapepr e
   SET vlsdeved = vlsdeved - 194.06
     , vlsdvctr = vlsdvctr - 194.06
     , vlsdevat = vlsdevat - 194.06
WHERE e.cdcooper = 1
AND e.nrdconta = 2625806
AND e.nrctremp = 1784246;



UPDATE craplem
   SET vllanmto =  240.44 
 WHERE progress_recid = 152202747;
 
            
  COMMIT;            
