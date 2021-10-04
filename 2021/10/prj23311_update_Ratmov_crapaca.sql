Begin
  update crapaca a
     set a.lstparam = a.lstparam||',pr_imobiliario'
   where nmpackag = 'TELA_RATMOV'
     AND nmdeacao = 'PC_IMPRIMIR';
     
  update tbepr_contrato_imobiliario 
     set situacao_analise = 0 
   where cdcooper = 1 
     and nrdconta = 94 
     and nrctremp = 4237964;
        
  commit;
exception
  when others then
    rollback;
end;