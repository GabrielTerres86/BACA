UPDATE crapsld
   SET vlsmnmes = 0
 WHERE cdcooper = 1
   AND nrdconta = 10899111;   
   
DELETE FROM CRAPLAT
 WHERE CDCOOPER = 1
   AND NRDCONTA = 10899111   
   AND DTMVTOLT = TO_DATE( '27/08/2020','DD/MM/YYYY' )
   AND CDHISTOR = 1465;