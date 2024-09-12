BEGIN
  
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('PERMITEINCLUSAOTITULAR'
    ,NULL
    ,'contacorrente.permiteInclusaoTitular'
    ,'pr_cdcooper,pr_nrdconta'
    ,246);

  COMMIT;
  
END;
