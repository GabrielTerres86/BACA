--1-Conta 85448  cooperativa 1 - correção de ch no vlr 239,00

UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 239.00 --Quando o bloqueio é negativo
   ,t.vlsddisp = t.vlsddisp - 239.00 --Quando o disponível é positivo 
 WHERE t.cdcooper = 1
   AND t.nrdconta = 85448
   AND t.dtmvtolt = '21/08/2019';

UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 239.00
       ,t.vlsddisp = t.vlsddisp - 239.00 
  WHERE t.cdcooper = 1
    AND t.nrdconta = 85448;
commit;