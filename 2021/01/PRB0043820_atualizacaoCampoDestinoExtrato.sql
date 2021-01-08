--PRB0043820
BEGIN
  
  -- Atualizar os registros que estão nulos
  UPDATE crapass t
     SET t.cdsecext = 999 -- Balcão padrão
   WHERE t.cdsecext IS NULL;
 
  -- Gravar dados
  COMMIT;

END;
