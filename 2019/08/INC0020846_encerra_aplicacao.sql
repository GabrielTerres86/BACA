UPDATE craprda l
   SET l.insaqtot = 1
      ,l.dtsaqtot = TO_DATE('05/08/2019','DD/MM/RRRR')
 WHERE l.cdcooper = 1
   AND l.nrdconta = 830739
   AND l.nraplica = 7;

COMMIT;
