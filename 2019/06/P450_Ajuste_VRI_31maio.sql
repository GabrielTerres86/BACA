UPDATE crapvri  
   SET vldivida = 54.22
 WHERE DTREFERE = to_date('31/05/2019','dd/mm/rrrr')
   AND CDCOOPER = 16
   AND NRDCONTA = 6161120
   AND NRCTREMP = 75794
   AND cdvencto = 170
;
UPDATE crapvri  
   SET vldivida = 505.53
 WHERE DTREFERE = to_date('31/05/2019','dd/mm/rrrr')
   AND CDCOOPER = 1
   AND NRDCONTA = 6574599
   AND NRCTREMP = 1190587
   AND cdvencto = 170
;
UPDATE CRAPRIS 
SET vldivida = 0.01
WHERE DTREFERE = to_date('31/05/2019','dd/mm/rrrr')
AND NRDCONTA = 6892400
AND NRCTREMP = 83264
AND CDCOOPER = 1
;
UPDATE crapvri 
   SET vldivida = 0.01
WHERE DTREFERE = to_date('31/05/2019','dd/mm/rrrr')
AND NRDCONTA = 6892400
AND NRCTREMP = 83264
AND CDCOOPER = 1
;
commit;