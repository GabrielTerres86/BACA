begin
  -- Remove a garantia da aplicação da proposta que não deveria ter
  UPDATE crawepr w
     SET w.idcobope = 0
   WHERE w.cdcooper = 7
     AND w.nrdconta = 237868
     AND w.nrctremp = 44313;
     
  -- Atualiza o contrato na garantia da operação para o contrato correto
  UPDATE tbgar_cobertura_operacao t
     SET t.nrcontrato = 44344
   WHERE t.cdcooper = 7
     AND t.nrdconta = 10693
     AND t.idcobertura = 32426;
  COMMIT;
exception
  when others then
    dbms_output.put_line('Erro Script PRB0043070 '||sqlerrm);
    rollback;
end;
