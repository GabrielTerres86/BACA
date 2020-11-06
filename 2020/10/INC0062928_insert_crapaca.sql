BEGIN
  INSERT INTO crapaca
    (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ((SELECT NVL(MAX(a.nrseqaca), 0) + 1 FROM crapaca a),
     'VALIDA_REGIAO_ATENDIMENTO',
     NULL,
     'validarRegiaoAtendimento',
     'pr_nrcepend',
     (select a.nrseqrdr from craprdr a where a.nmprogra = 'MATRIC'));
  COMMIT;
END;
