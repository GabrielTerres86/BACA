--Conta 2918544 cooperativa 1 - Viacredi - corre��o de ch no vlr 20000,00

UPDATE crapsda t 
SET t.vlsdbloq = t.vlsdbloq + 20000.00 --Quando o bloqueio � negativo
   ,t.vlsddisp = t.vlsddisp - 20000.00 --Quando o dispon�vel � posiivo 
 WHERE t.cdcooper = 1
   AND t.nrdconta = 2918544
   AND t.dtmvtolt = '05/07/2019';

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 20000.00
       ,t.vlsddisp = t.vlsddisp - 20000.00
  WHERE t.cdcooper = 1
    AND t.nrdconta = 2918544;

commit;
-----------------------------------------------------
