--PRB0043820
BEGIN
  
  -- Atualizar os registros que est�o nulos
  UPDATE crapass t
     SET t.cdsecext = 999 -- Balc�o padr�o
   WHERE t.cdsecext IS NULL;
 
  -- Gravar dados
  COMMIT;

END;
