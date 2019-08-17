DECLARE
  vr_nrseqrdr NUMBER;
  vr_nrseqaca NUMBER;

BEGIN

  SELECT nrseqrdr INTO vr_nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ANALISE_CREDITO';

  INSERT INTO cecred.crapaca
    (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    ((SELECT MAX(nrseqaca) + 1 FROM crapaca),
     'INSERE_CONTROLE_ACESSO',
     'TELA_ANALISE_CREDITO',
     'pc_insere_analise_cred_acessos',
     'pr_cdcooper, pr_nrdconta, pr_cdoperador, pr_nrcontrato, pr_tpproduto, pr_dhinicio_acesso, pr_dhfim_acesso, pr_idanalise_contrato_acesso',
     vr_nrseqrdr);
  COMMIT;
END;