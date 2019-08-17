UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 498.00 --Quando o bloqueio é negativo
   ,t.vlsddisp = t.vlsddisp - 498.00 --Quando o disponível é posiivo 
 WHERE t.cdcooper = 1
   AND t.nrdconta = 2726424
   AND t.dtmvtolt = '03/07/2019';

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 498.00
       ,t.vlsddisp = t.vlsddisp - 498.00 
  WHERE t.cdcooper = 1
    AND t.nrdconta = 2726424;

commit;

--------------------------------------

UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 1690.00 --Quando o bloqueio é negativo
   ,t.vlsddisp = t.vlsddisp - 1690.00 --Quando o disponível é posiivo 
 WHERE t.cdcooper = 5
   AND t.nrdconta = 60003
   AND t.dtmvtolt = '03/07/2019';

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 1690.00
       ,t.vlsddisp = t.vlsddisp - 1690.00 
  WHERE t.cdcooper = 5
    AND t.nrdconta = 60003;

commit;

