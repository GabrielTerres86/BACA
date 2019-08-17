-- Criar crítica de boleto bloqueado
begin
  -- Test statements here
  insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
  values (1462, 'Boleto bloqueado - encaminhado a cartorio.', 3, 0);
  
  COMMIT;
end;