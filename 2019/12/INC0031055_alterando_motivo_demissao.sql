--INC0031055 Alterando o motivo da demissão do cooperado.

update crapass
   set cdsitdct = 4
 where cdcooper = 7
   and nrdconta = 50733;  
   
   COMMIT;
