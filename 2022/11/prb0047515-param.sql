BEGIN                                         
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'CONSIST_FATURA_TRIBUTOS',
     'Consist�ncia para impedir duplicidade de faturas - Indica se o servi�o est� ativo 0:N�o 1:Sim',
     '1');

  COMMIT;
END;   
