-- Atualizar lista de valores para receber novo parametro
BEGIN
  UPDATE crapaca
  SET lstparam = lstparam || ',pr_perctolval' 
  WHERE nmdeacao = 'CUSAPL_GRAVAC_PARAMS';
  
  COMMIT;
END;
