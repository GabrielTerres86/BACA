BEGIN 
  
  UPDATE tbapi_produto_servico s
     SET s.dspermissao_api = DECODE(s.idservico_api, 1,'cobranca-boleto'
                                                   , 2,'credito-recuperacao'
                                                   , NULL);
  
  COMMIT;
  
END;
