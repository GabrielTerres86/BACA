BEGIN
  
  -- Inserir dominio de situação do UUID do desenvolvedor
  INSERT INTO tbapi_dominio_campo(nmdominio, cddominio, dscodigo)
        VALUES('SITUACAO_CHAVE_DESENV', '1', 'Ativo');
  
  INSERT INTO tbapi_dominio_campo(nmdominio, cddominio, dscodigo)
        VALUES('SITUACAO_CHAVE_DESENV', '2', 'Cancelado');
  
  COMMIT;
  
END;
