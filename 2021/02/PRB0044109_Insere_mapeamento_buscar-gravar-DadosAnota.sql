DECLARE
  --
  vr_nrseqrdr NUMBER;
  vr_nrseqaca NUMBER;
  --
BEGIN
  -- Inserindo dados para a procedure buscarDadosAnota "BUSCAR_DADOS_ANOTA"
  -- Não foi possível pegar da sequence pois ela não está de acordo com a tabela.
  SELECT ( MAX(nrseqrdr) + 1 ) nrseqrdr
    INTO vr_nrseqrdr
  FROM CRAPRDR;
  --
  dbms_output.put_line('sequencia craprdr: ' || vr_nrseqrdr);
  --
  -- Sequência da crapaca
  SELECT (MAX(nrseqaca) + 1)
    INTO vr_nrseqaca
  FROM crapaca;
  --
  -- insere craprdr
  INSERT INTO craprdr (
    nrseqrdr, 
    nmprogra, 
    dtsolici
  ) VALUES (
    vr_nrseqrdr, 
    'ANOTA', 
    SYSDATE
  );
  --
  -- insere crapaca
  INSERT INTO crapaca (
    nrseqaca, 
    nmdeacao, 
    nmpackag, 
    nmproced, 
    lstparam, 
    nrseqrdr
  ) VALUES (
    vr_nrseqaca, 
    'BUSCAR_DADOS_ANOTA', 
    NULL, 
    'buscarDadosAnota', 
    'pr_cdcooper,pr_nrdconta,pr_nrseqdig,pr_cddopcao,pr_flgerlog', 
    vr_nrseqrdr
  );
  -- ********************************************************************
  -- Inserindo dados para a procedure gravarDadosAnota "GRAVAR_DADOS_ANOTA"
  -- Pega sequence da craprdr
  vr_nrseqaca := NULL;
  --
  -- Sequência da crapaca
  SELECT (MAX(nrseqaca) + 1)
    INTO vr_nrseqaca
  FROM crapaca;
  --
  -- insere crapaca
  INSERT INTO crapaca (
    nrseqaca, 
    nmdeacao, 
    nmpackag, 
    nmproced, 
    lstparam, 
    nrseqrdr
  ) VALUES (
    vr_nrseqaca, 
    'GRAVAR_DADOS_ANOTA', 
    NULL, 
    'gravarDadosAnota', 
    'pr_cdcooper,pr_nrdconta,pr_nrseqdig,pr_cddopcao,pr_flgerlog,pr_dsobserv,pr_flgprior', 
    vr_nrseqrdr
  );
  --
  COMMIT;
  dbms_output.PUT_LINE('Sucesso na execução do script');
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;
