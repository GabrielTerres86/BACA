/*Atualização de número de contrato
31/03/2020 - Paulo Martins*/
begin
update tbgar_cobertura_operacao o
   set nrcontrato = 257632
 where nrdconta = 165956 
   and insituacao = 1 
   and nrconta_terceiro = 219428 
   and nrcontrato = 255585;
update crawepr e
   set e.idcobope = 0,
       e.idcobefe = 0
 where e.nrdconta = 689211 
   and e.nrctremp = 255585
   and e.cdcooper = 2;
   commit;
exception
  when others then
    rollback;
end;   
   
   
