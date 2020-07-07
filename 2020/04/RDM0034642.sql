UPDATE crapprm p 
   SET p.dsvlrprm = '07/04/2020#2'
 WHERE p.cdcooper = 1
   AND p.progress_recid IN (67980,63186,1718,45679,225,67928,226,67954,51650,2414);
   
commit;
