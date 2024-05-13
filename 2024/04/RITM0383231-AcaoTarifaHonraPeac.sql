BEGIN
  INSERT INTO cecred.crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('TARIFAHONRA_PEAC'
    ,'TELA_PEAC'
    ,'pc_atualizar_tarifahonra_web'
    ,'pr_contratos'
    ,2385);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
