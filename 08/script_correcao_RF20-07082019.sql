--1-Conta 85448  cooperativa 1 - correção de ch no vlr 421,17

UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 421.17 --Quando o bloqueio é negativo
   ,t.vlsddisp = t.vlsddisp - 421.17 --Quando o disponível é positivo 
 WHERE t.cdcooper = 1
   AND t.nrdconta = 85448
   AND t.dtmvtolt = '07/08/2019';

UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 421.17
       ,t.vlsddisp = t.vlsddisp - 421.17 
  WHERE t.cdcooper = 1
    AND t.nrdconta = 85448;
commit;
