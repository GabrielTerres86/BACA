-- Alterar a situação da conta para "4 - Encerrada por Demissão"
update crapass
   set cdsitdct = 4
 where cdcooper = 1
   and nrdconta = 9407243;
   
Commit;   

