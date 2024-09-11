BEGIN
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('OBTER_PARAMETRO_CADPAR'
    ,'credito.obterCadparPorCodigoWeb'
    ,'pr_cdcooper,pr_cdparam'
    ,71);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
