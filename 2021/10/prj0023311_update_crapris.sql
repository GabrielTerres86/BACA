UPDATE crapris a
SET a.vljura60 = 0
WHERE a.cdcooper = 1
AND   a.nrdconta IN (2515938,2515938,8481997,9356703)
AND a.dtrefere = '27/09/2021'
AND a.nrctremp IN (3930543,3969605,2103837,2956154)
AND a.vljura60 IS NULL;

COMMIT;
  
