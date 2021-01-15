begin
  
  -- Remove a garantia da aplicação da proposta que não deveria ter
  UPDATE crawepr w
     SET w.idcobope = 0
   WHERE w.cdcooper = 1
     AND w.nrdconta = 7823070
     AND w.nrctremp = 2077672;
     
  -- Atualiza o contrato na garantia da operação para o contrato correto
  UPDATE tbgar_cobertura_operacao t
     SET t.nrcontrato = 2078291
   WHERE t.cdcooper = 1
     AND t.nrdconta = 7007779
     AND t.idcobertura = 24114;

  COMMIT;
exception
  when others then
    dbms_output.put_line('Erro Script PRB0043070 '||sqlerrm);
    rollback;
end;
