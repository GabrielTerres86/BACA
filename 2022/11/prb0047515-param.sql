BEGIN                                         
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONSIST_FATURA_TRIBUTOS',
     'Consistência para impedir duplicidade de faturas - Indica se o serviço está ativo 0:Não 1:Sim',
     '1');

  COMMIT;
END;   
