BEGIN                                         
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'TEMPO_FATURA_TRIBUTOS',
     'Tempo em segundos a considerar na busca de registro para consistência de duplicidade de faturas - Usar numero inteiro',
     '10');

  COMMIT;
END;   
