--conta 258180
    
UPDATE crapsda t 
SET t.vlsdbloq = 966.66
   ,t.vlsddisp = t.vlsddisp + t.vlsdbloq
 WHERE t.cdcooper = 13
   AND t.nrdconta = 258180
   AND t.dtmvtolt = '27/06/2019';
   
   commit;
   
 UPDATE crapsda t 
   SET t.vlsdbloq = 0.00
      ,t.vlsddisp = t.vlsddisp + t.vlsdbloq 
 WHERE t.cdcooper = 13
   AND t.nrdconta = 258180
   AND t.dtmvtolt = '28/06/2019';    

commit;

 UPDATE crapsda t 
   SET t.vlsdbloq = 0.00
      ,t.vlsddisp = t.vlsddisp + t.vlsdbloq 
 WHERE t.cdcooper = 13
   AND t.nrdconta = 258180
   AND t.dtmvtolt = '01/07/2019';    

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = 0.00
       ,t.vlsddisp = t.vlsddisp + t.vlsdbloq 
  WHERE t.cdcooper = 13
    AND t.nrdconta = 258180;

commit;


---------------------------------------------
--conta 2071193
   
 UPDATE crapsda t 
   SET t.vlsdbloq = 0.00
      ,t.vlsddisp = t.vlsddisp + t.vlsdbloq 
 WHERE t.cdcooper = 1
   AND t.nrdconta = 2071193
   AND t.dtmvtolt = '01/07/2019';    

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = 0.00
       ,t.vlsddisp = t.vlsddisp + t.vlsdbloq 
  WHERE t.cdcooper = 1
    AND t.nrdconta = 2071193;

commit;
---------------------------------------------

--conta 667.190-0  obs. quando o bloqueado estiver positivo
  
 UPDATE crapsda t 
   SET t.vlsdbloq = t.vlsdbloq + 386.63 --cfe. somatório da crapdpb
      ,t.vlsddisp = t.vlsddisp - 386.63 --retira 1 crédito a mais da conta
 WHERE t.cdcooper = 16
   AND t.nrdconta = 6671900
   AND t.dtmvtolt = '01/07/2019';    

commit;

 UPDATE crapsld t 
    SET t.vlsdbloq = t.vlsdbloq + 386.63
       ,t.vlsddisp = t.vlsddisp - 386.63
  WHERE t.cdcooper = 16
    AND t.nrdconta = 6671900;

commit;
---------------------------------------------