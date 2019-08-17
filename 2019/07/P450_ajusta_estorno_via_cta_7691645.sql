-------------------------------------------
UPDATE craplcm t
   SET t.dtmvtolt = '23/07/2019'
 WHERE t.cdcooper = 1
   AND t.nrdconta = 7691645
   AND t.dtmvtolt = '19/07/2019'
   AND t.cdhistor = 1706
   AND t.vllanmto = 5908.30
;

UPDATE craplem t
   SET t.dtmvtolt = '23/07/2019'
 WHERE t.cdcooper = 1
   AND t.nrdconta = 7691645
   AND t.nrctremp = 658073
   AND t.dtmvtolt = '19/07/2019'
   AND t.cdhistor = 1707
;
-------------------------------------------
COMMIT;
