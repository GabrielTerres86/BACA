--Conta 85448 cooperativa 1 - Viacredi - corre��o de ch no vlr 1238,85

UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 1238.85 --Quando o bloqueio � negativo
   ,t.vlsddisp = t.vlsddisp - 1238.85 --Quando o dispon�vel � posiivo 
 WHERE t.cdcooper = 1
   AND t.nrdconta = 85448
   AND t.dtmvtolt = '08/07/2019';

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 1238.85
       ,t.vlsddisp = t.vlsddisp - 1238.85 
  WHERE t.cdcooper = 1
    AND t.nrdconta = 85448;

commit;
-----------------------------------------------------
