/*
  Script para atualizar a data de vencimento para hoje, pois eles não foram enviados no arquivo do dia 02/01/2019.
  
  SELECT *
    FROM craplft
   WHERE progress_recid IN (30263204,30263205);
 
*/

UPDATE craplft l
   SET l.dtvencto = '06/02/2019'
 WHERE l.progress_recid = 30263204;
 
 
UPDATE craplft l
   SET l.dtvencto = '06/02/2019'
 WHERE l.progress_recid = 30263205;
 
COMMIT;
