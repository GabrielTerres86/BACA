--SELECT vllimcre, dtultlcr, crapass.* FROM crapass 
UPDATE crapass
   SET vllimcre = 0
      ,dtultlcr = to_date('01/02/2019', 'dd/mm/RRRR')
 WHERE cdcooper = 1
   AND nrdconta IN (8782601, 8792496, 9690026);
   
COMMIT;
