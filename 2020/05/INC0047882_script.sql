/*Atualização de número de contrato
06/05/2020 - Paulo Martins*/
begin
update tbgar_cobertura_operacao o
   set nrcontrato = 1964003
 where nrdconta = 2009072 
   and insituacao = 1 
   and nrcontrato = 1935496;
update crawepr e
   set e.idcobope = 0,
       e.idcobefe = 0
 where e.nrdconta = 5525390 
   and e.nrctremp = 1935496
   and e.cdcooper = 1;
   commit;
exception
  when others then
    rollback;
end;   
   
   
