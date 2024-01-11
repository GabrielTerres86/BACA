BEGIN
  
DELETE cecred.crapris a
 WHERE a.cdcooper = 10
   AND a.dtrefere = '04/01/2024'
   AND a.cdmodali = 299
   AND TRIM(a.dsinfaux) = 'IMOBILIARIO';


DELETE cecred.crapvri a
 WHERE a.cdcooper = 10
   AND a.cdmodali = 299
   AND a.nrctremp IN (51174, 51175)
   AND a.dtrefere = '04/01/2024';

COMMIT;

EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;
