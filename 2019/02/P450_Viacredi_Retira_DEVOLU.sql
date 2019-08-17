DELETE
  FROM crapneg n
 WHERE n.cdcooper = 1
   AND n.nrdconta = 10071881
   AND n.cdhisest = 1
   AND n.cdobserv = 11
   AND n.dtiniest = '13/02/2019';
COMMIT;
