BEGIN
  
  BEGIN
    INSERT INTO crapaca
      (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
      (null,
       'CADASTRA_VALIDADE_ESTENDIDA',
       null,
       'mantervalidadeestendida',
       'pr_idvalidade,pr_dtvalidade,pr_dtestendida,pr_dtvigencia,pr_operacao',
       1228);
       
    INSERT INTO crapaca
      (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
      (null,
       'CONSULTA_LOG_VALIDADE',
       null,
       'consultarlogvalidadeestendida',
       'pr_idvalidade',
       1228);

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro de insert na crapaca - '||SQLERRM);    
  END;
  
  BEGIN
    INSERT INTO craptel
      (nmdatela,
       nrmodulo,
       cdopptel,
       tldatela,
       tlrestel,
       flgteldf,
       flgtelbl,
       nmrotina,
       lsopptel,
       inacesso,
       cdcooper,
       idsistem,
       idevento,
       nrordrot,
       nrdnivel,
       nmrotpai,
       idambtel,
       progress_recid)
    VALUES
      ('CARCRD',
       5,
       '@,C,R',
       'Parametros do cartao',
       'Parametros do cartao',
       0,
       1,
       'CADVAL',
       'ACESSO,CONSULTAR,RELATORIO',
       0,
       3,
       1,
       0,
       1,
       1,
       ' ',
       2,
       null);

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro de insert na craptel - '||SQLERRM);       
  END;
  
  BEGIN
    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', '@', 'f0030519', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'A', 'f0030519', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'C', 'f0030519', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', '@', 'f0030641', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'A', 'f0030641', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'C', 'f0030641', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', '@', 'f0031749', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'A', 'f0031749', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'C', 'f0031749', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', '@', 'f0031849', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'A', 'f0031849', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'C', 'f0031849', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', '@', 'f0032094', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'A', 'f0032094', 'CADVAL', 3, 1, 1, 2, NULL);

    INSERT INTO crapace
      (nmdatela,
       cddopcao,
       cdoperad,
       nmrotina,
       cdcooper,
       nrmodulo,
       idevento,
       idambace,
       progress_recid)
    VALUES
      ('CARCRD', 'C', 'f0032094', 'CADVAL', 3, 1, 1, 2, NULL);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro de insert na crapace - '||SQLERRM);  
    
  END;
  
  COMMIT;
  
END;
