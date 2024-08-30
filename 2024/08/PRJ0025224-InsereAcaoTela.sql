BEGIN
  INSERT INTO crapaca
    (nmdeacao
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('OBTER_CONTRATOS_RENEGOCIACAO'
    ,'recuperacao.obtercontratosrenegociados'
    ,'pr_cdcooper, pr_nrdconta'
    ,71);

  INSERT INTO crapaca
    (nmdeacao
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('OBTER_DETALHES_CONTRATO_RENEGOCIACAO'
    ,'recuperacao.obterdetalhescontratorenegociado'
    ,'pr_cdcooper, pr_nrdconta, pr_nrctremp'
    ,71);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
