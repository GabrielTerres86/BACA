 begin
   update credito.tbepr_contrato_imobiliario c
      set c.situacao_analise = 3, c.situacao_aprovacao = 1
    where c.cdcooper = 16
      and c.nrdconta = 2841568
      and c.nrctremp = 469227;
   commit;
 exception
   when others then
     rollback;
 end;