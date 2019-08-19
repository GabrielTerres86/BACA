--Conta 31527.3 cooperativa 13 - Civia - correção de ch no vlr 1107,00

UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 1107.00 --Quando o bloqueio é negativo
   ,t.vlsddisp = t.vlsddisp - 1107.00 --Quando o disponível é posiivo 
 WHERE t.cdcooper = 13
   AND t.nrdconta = 315273
   AND t.dtmvtolt = '02/07/2019';

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 1107.00
       ,t.vlsddisp = t.vlsddisp - 1107.00 
  WHERE t.cdcooper = 13
    AND t.nrdconta = 315273;

commit;
-----------------------------------------------------
--Conta 9062823 cooperativa 1 - Viacredi- correção de ch no vlr 381,00
UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 381.00 --Quando o bloqueio é negativo
   ,t.vlsddisp = t.vlsddisp - 381.00 --Quando o disponível é posiivo 
 WHERE t.cdcooper = 1
   AND t.nrdconta = 9062823
   AND t.dtmvtolt = '02/07/2019';

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 381.00
       ,t.vlsddisp = t.vlsddisp - 381.00 
  WHERE t.cdcooper = 1
    AND t.nrdconta = 9062823;

commit;
------------------------------------------------
--Conta 2013967 cooperativa 1 - Viacredi- correção de ch no vlr 4000,00
UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 4000.00 --Quando o bloqueio é negativo
   ,t.vlsddisp = t.vlsddisp - 4000.00 --Quando o disponível é posiivo 
 WHERE t.cdcooper = 1
   AND t.nrdconta = 2013967
   AND t.dtmvtolt = '02/07/2019';

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 4000.00
       ,t.vlsddisp = t.vlsddisp - 4000.00 
  WHERE t.cdcooper = 1
    AND t.nrdconta = 2013967;

commit;