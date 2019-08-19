UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 13880.00 --Quando o bloqueio é negativo
   ,t.vlsddisp = t.vlsddisp - 13880.00 --Quando o disponível é posiivo 
 WHERE t.cdcooper = 16
   AND t.nrdconta = 330051
   AND t.dtmvtolt = '04/07/2019';

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 13880.00
       ,t.vlsddisp = t.vlsddisp - 13880.00 
  WHERE t.cdcooper = 16
    AND t.nrdconta = 330051;

commit;

--------------------------------------

UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 2146.66 --Quando o bloqueio é negativo
   ,t.vlsddisp = t.vlsddisp - 2146.66 --Quando o disponível é posiivo 
 WHERE t.cdcooper = 16
   AND t.nrdconta = 6671900
   AND t.dtmvtolt = '04/07/2019';

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 2146.66
       ,t.vlsddisp = t.vlsddisp - 2146.66 
  WHERE t.cdcooper = 16
    AND t.nrdconta = 6671900;

commit;

