BEGIN
  -- Adicionar opcao C na tela PARBCB devido ao erro de consulta, opcao nao cadastrada.
  UPDATE craptel t
     SET t.cdopptel = t.cdopptel || ',C', t.lsopptel = t.lsopptel || ',Consulta'
   WHERE t.nmdatela = 'PARBCB';

  INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  SELECT nmdatela,
         'C',
         cdoperad,
         nmrotina,
         3,
         nrmodulo,
         idevento,
         idambace
  FROM crapace
  WHERE nmdatela = 'PARBCB'
    AND cdcooper = 3;
  
  COMMIT;
END;