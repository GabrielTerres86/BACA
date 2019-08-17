/*

    Script para corrigir lançamentos - inc0033995 / inc0034005

  --Conta 672.054-4 - Viacredi
  SELECT * FROM crapdev WHERE cdcooper = 1 AND nrdconta = 6720544;

  SELECT * FROM craplcm WHERE cdcooper = 1 AND nrdconta = 6720544 AND dtmvtolt = '27/02/2019';

  SELECT * FROM craplot WHERE cdcooper = 1 AND dtmvtolt = '27/02/2019' AND cdagenci = 65 AND nrdolote IN (31);


  --Conta 104663 - Credicomin
  SELECT * FROM crapdev WHERE cdcooper = 10 AND nrdconta = 104663;

  SELECT * FROM craplcm WHERE cdcooper = 10 AND nrdconta = 104663 AND dtmvtolt = '27/02/2019';

  SELECT * FROM craplot WHERE cdcooper = 10 AND dtmvtolt = '27/02/2019' AND cdagenci = 3 AND nrdolote IN (6,7);


  SELECT * FROM crapdev WHERE progress_recid IN(2266814,2266815);

*/

--Delete
DELETE crapdev WHERE progress_recid IN(2266797,2266798);
DELETE craplcm WHERE progress_recid = 652911150;
DELETE craplot WHERE progress_recid = 23849388;

--Update
UPDATE crapdev 
   SET vllanmto = 870
 WHERE progress_recid IN(2266814,2266815);

UPDATE craplcm 
   SET vllanmto = 870
 WHERE progress_recid = 652940593;

UPDATE craplot 
   SET vlcompcr = 870
 WHERE progress_recid = 23850782;
 
COMMIT; 
