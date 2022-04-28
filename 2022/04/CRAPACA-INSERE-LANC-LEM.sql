BEGIN
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('INSERE_LANC_LEM'
    ,NULL
    ,'CREDITO.incluirLancamentoOpeLem'
    ,'pr_nrdconta,pr_nrctremp,pr_cdhistor,pr_vllanmto,pr_nrparepr'
    ,71);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
