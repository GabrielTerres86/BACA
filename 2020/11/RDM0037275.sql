
UPDATE CRAPASS
   SET nmmaeptl = 'RITA ESPINDOLA'
     , NMPAIPTL = 'LEOPOLDO ESPINDOLA'
     , DSFILIAC = 'LEOPOLDO ESPINDOLA E RITA ESPINDOLA'
 where cdcooper = 16
   and nrdconta = 145440;       
 

UPDATE CRAPTTL
   SET nmmaeTtl = 'RITA ESPINDOLA'
     , NMPAITTL = 'LEOPOLDO ESPINDOLA'
 where cdcooper = 16
   and nrdconta = 145440;  
   
   commit;