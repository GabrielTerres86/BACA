/*SELECT * FROM crapcje WHERE cdcooper = 1 AND nrdconta =  7779798 AND idseqttl = 1;
 */


UPDATE crapcje
   SET nmconjug = REPLACE(nmconjug, '', ' ')
 WHERE cdcooper = 1
   AND nrdconta = 7779798
   AND idseqttl = 1;
