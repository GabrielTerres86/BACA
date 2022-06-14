BEGIN
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('VALIDA_HIS_LANC_LEM'
    ,NULL
    ,'CREDITO.validarHistoricoLancLem'
    ,'pr_cdhistor'
    ,71);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
