BEGIN
  
    UPDATE craplap lap
       SET lap.dtrefere = to_date('25/01/2023','DD/MM/RRRR')
     WHERE lap.CDCOOPER = 16
       AND lap.DTMVTOLT = to_date('25/01/2022','DD/MM/RRRR')
       AND lap.CDAGENCI = 12
       AND lap.CDBCCXLT = 400
       AND lap.NRDOLOTE = 4012
       AND lap.NRDCONTA = 177903
       AND lap.NRDOCMTO = 59;
        
    UPDATE craprda rda
       SET rda.dtfimper = to_date('25/01/2023','DD/MM/RRRR')
          ,rda.dtvencto = to_date('25/01/2023','DD/MM/RRRR')
     WHERE rda.CDCOOPER = 16
       AND rda.DTMVTOLT = to_date('25/01/2022','DD/MM/RRRR')
       AND rda.CDAGENCI = 12
       AND rda.CDBCCXLT = 400
       AND rda.NRDOLOTE = 4012
       AND rda.NRDCONTA = 177903
       AND rda.NRAPLICA = 59;
 
    COMMIT;

END;



 
