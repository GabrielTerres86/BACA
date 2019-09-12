BEGIN
  
  -- Inserir a nova modalidade de conta
  INSERT INTO TBCC_DOMINIO_CAMPO (NMDOMINIO,
                                  CDDOMINIO,
                                  DSCODIGO)
                          VALUES ('MODALIDADE_TIPO_CONTA'
                                 , 4
                                 ,'Conta Ente Público');
                                 
  COMMIT;

END;
