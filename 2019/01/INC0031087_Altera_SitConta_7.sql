-- Alterar a situação da conta para "7 - Em processo de demissão"
update crapass
   set cdsitdct = 7
 where cdcooper = 1
   and nrdconta = 2234653;
   
Commit;   

