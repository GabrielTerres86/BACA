-- Alterar a situação da conta para "7 - Em processo de demissão"
UPDATE crapass a
   SET a.cdsitdct = 7 
 WHERE a.cdcooper = 1
   AND a.nrdconta IN ( 9453571,8654395,9021302);
   
Commit;   

