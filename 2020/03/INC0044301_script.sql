/*Atualização de número de contrato
06/04/2020 - Paulo Martins
Cauza Raiz PRB0042930*/
begin
update tbgar_cobertura_operacao o
   set o.nrcontrato = 2248312
 where nrdconta = 8841373 
   and insituacao = 1 
   and nrcontrato = 2254199
   and cdcooper = 1;
update crawepr e
   set e.idcobope = 0,
       e.idcobefe = 0
 where e.nrdconta = 90265904 
   and e.nrctremp = 2254199
   and e.cdcooper = 1;
   commit;
exception
  when others then
    rollback;
end;   
   

   
