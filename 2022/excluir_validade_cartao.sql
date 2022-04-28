BEGIN
  delete from tbcartao_validade_estendida t where t.idvalidade = 1;
  delete from tbcartao_validade_estendida t where t.idvalidade = 2;
  COMMIT;
END;
