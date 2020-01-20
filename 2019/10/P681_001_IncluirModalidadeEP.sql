BEGIN
  
  -- Inserir a nova modalidade de conta
  INSERT INTO TBCC_DOMINIO_CAMPO (NMDOMINIO,
                                  CDDOMINIO,
                                  DSCODIGO)
                          VALUES ('MODALIDADE_TIPO_CONTA'
                                 , 4
                                 ,'Conta Ente P�blico');
                                 
  COMMIT;
  
  -- Ajustar o tipo de conta de ente p�blico para a modalidade Ente P�blico
  UPDATE tbcc_tipo_conta t 
     SET t.cdmodalidade_tipo = 4
   WHERE t.inpessoa          = 2
     AND t.cdtipo_conta      = 23;
     
  COMMIT;

END;
