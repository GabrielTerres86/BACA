UPDATE crapris e
   SET e.vldivida = 0.29
      ,e.vlvec180 = 0.29
 WHERE e.cdcooper = 1 
   AND e.nrdconta = 3955877 
   AND e.nrctremp = 2308256 
   AND e.dtrefere = to_date('31/10/2020','dd/mm/rrrr');

UPDATE crapvri e
   SET e.vldivida = 0.29
 WHERE e.cdcooper = 1 
   AND e.nrdconta = 3955877 
   AND e.nrctremp = 2308256 
   AND e.dtrefere = to_date('31/10/2020','dd/mm/rrrr');

UPDATE crapris e
   SET e.vldivida = 4046.48
      ,e.vlvec180 = 4046.48
 WHERE e.cdcooper = 1 
   AND e.nrdconta = 6908179 
   AND e.nrctremp = 2460485 
   AND e.dtrefere = to_date('31/10/2020','dd/mm/rrrr');

UPDATE crapvri e
   SET e.vldivida = 4046.48
 WHERE e.cdcooper = 1 
   AND e.nrdconta = 6908179 
   AND e.nrctremp = 2460485 
   AND e.dtrefere = to_date('31/10/2020','dd/mm/rrrr');

UPDATE crapris e
   SET e.vldivida = 70.66
      ,e.vlvec180 = 70.66
 WHERE e.cdcooper = 13 
   AND e.nrdconta = 70700 
   AND e.nrctremp = 64382 
   AND e.dtrefere = to_date('30/11/2020','dd/mm/rrrr');

UPDATE crapvri e
   SET e.vldivida = 70.66
 WHERE e.cdcooper = 13 
   AND e.nrdconta = 70700 
   AND e.nrctremp = 64382 
   AND e.dtrefere = to_date('30/11/2020','dd/mm/rrrr');

COMMIT;
