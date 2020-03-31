/*Atualização de número de contrato
31/03/2020 - Paulo Martins*/
update tbgar_cobertura_operacao o
   set nrcontrato = 257632
 where nrdconta = 165956 
   and insituacao = 1 
   and nrconta_terceiro = 219428 
   and nrcontrato = 255585;
   commit;
