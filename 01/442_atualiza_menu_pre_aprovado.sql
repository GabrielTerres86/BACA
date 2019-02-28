BEGIN
  UPDATE craptel
  SET tldatela = 'Pre Aprovado'
     ,tlrestel = 'Pre Aprovado'
     ,nmrotina = 'PRE APROVADO'
  WHERE UPPER(nmdatela) LIKE UPPER('atenda')
     AND nrmodulo = 1
     AND UPPER(tlrestel) LIKE UPPER('Desabilitar Operacoes');
     
  COMMIT;
END;
