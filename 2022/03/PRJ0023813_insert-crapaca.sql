BEGIN
  INSERT INTO crapaca
    (NMDEACAO
    ,NMPACKAG
    ,NMPROCED
    ,LSTPARAM
    ,NRSEQRDR)
  VALUES
    ('CONSULTA_CRITICAS_PEAC'
    ,'TELA_PEAC'
    ,'pc_consultar_criticas_web'
    ,'pr_idoperacao'
    ,2384);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
