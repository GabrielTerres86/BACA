DECLARE
  --
  vr_nrseqrdr NUMBER;
  vr_nrseqaca NUMBER;
  --
BEGIN
  --
  vr_nrseqrdr := NULL;
  vr_nrseqaca := NULL;
  --
  SELECT nrseqrdr
    INTO vr_nrseqrdr
  FROM CRAPRDR
  WHERE NMPROGRA = 'HISTOR';
  --
  dbms_output.put_line('sequencia craprdr: ' || vr_nrseqrdr);
  --
  -- Sequência da crapaca
  SELECT (MAX(nrseqaca) + 1)
    INTO vr_nrseqaca
  FROM crapaca;
  --
  -- insere crapaca - BUSCAR_CATEGORIA_LANCAMENTO
  INSERT INTO crapaca (
    nrseqaca, 
    nmdeacao, 
    nmpackag, 
    nmproced, 
    lstparam, 
    nrseqrdr
  ) VALUES (
    vr_nrseqaca, 
    'BUSCAR_CATEGORIA_LANCAMENTO', 
    NULL, 
    'buscarCategoriaLancamento', 
    'pr_cdcategoria,pr_dscategoria,pr_indebcre,pr_nriniseq,pr_nrregist', 
    vr_nrseqrdr
  );
  -- ********************************************************************
  -- insere crapaca - GRAVAR_CATEGORIA_LANCAMENTO
  --
  vr_nrseqaca := NULL;
  -- Sequência da crapaca
  SELECT (MAX(nrseqaca) + 1)
    INTO vr_nrseqaca
  FROM crapaca;
  --
  INSERT INTO crapaca (
    nrseqaca, 
    nmdeacao, 
    nmpackag, 
    nmproced, 
    lstparam, 
    nrseqrdr
  ) VALUES (
    vr_nrseqaca, 
    'GRAVAR_CATEGORIA_LANCAMENTO', 
    NULL, 
    'gravarCategoriaLancamento', 
    'pr_cdcategoria,pr_dscatego,pr_indebcre,pr_cddeacao', 
    vr_nrseqrdr
  );
  COMMIT;
  dbms_output.PUT_LINE('Sucesso na execução do script');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;
