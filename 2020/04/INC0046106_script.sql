/*Atualização de número de contrato
22/04/2020 - Paulo Martins*/
begin
update tbgar_cobertura_operacao o
   set nrcontrato = 2216981
 where nrdconta = 7872453 
   and insituacao = 1 
   and nrconta_terceiro = 2549689 
   and nrcontrato = 2256473;
update crawepr e
   set e.idcobope = 0,
       e.idcobefe = 0
 where e.nrdconta = 7873930 
   and e.nrctremp = 2256473
   and e.cdcooper = 1;
   commit;
exception
  when others then
    rollback;
end;   
   
   
