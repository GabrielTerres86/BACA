UPDATE crapvri t
  SET t.vldivida = 135.79
 WHERE t.dtrefere = '30/06/2019'
   AND t.nrdconta = 6636764 
   AND t.nrctremp = 1367841
   AND t.cdmodali = 299
   AND t.cdvencto = 140
   AND t.cdcooper = 1
;
COMMIT;
