BEGIN
  UPDATE crapcyb b
  SET b.cdlcremp = 10000
  , b.cdfinemp = 100
  , b.cdagenci = (SELECT s.cdagenci
    FROM crapass s
    WHERE s.cdcooper = b.cdcooper
    AND   s.nrdconta = b.nrdconta)
  WHERE b.cdcooper = 16
  AND b.dtmvtolt = '28/03/2022'
  AND EXISTS (SELECT 1
  FROM crapris a
  WHERE a.cdcooper = 16
  AND a.dtrefere = b.dtmvtolt
  AND a.cdmodali IN (901,902,903)
  AND b.cdcooper = a.cdcooper
  AND b.nrdconta = a.nrdconta
  AND b.nrctremp = a.nrctremp);
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
