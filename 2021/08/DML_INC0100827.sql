BEGIN
  
  UPDATE tbrecup_boleto_arq a
    SET a.nmarq_gerado = NULL,
        a.dsarq_gerado = NULL
  WHERE a.idarquivo = 52;      

  COMMIT;

END;
