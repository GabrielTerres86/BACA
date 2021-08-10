BEGIN     
  INSERT INTO crapaca
    (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ((SELECT MAX(NRSEQACA) + 1 FROM crapaca),
     'BUSCASEGCREDIMOB',
     'TELA_ATENDA_SEGURO',
     'pc_detalha_cred_imobiliario',
     'pr_nrdconta, pr_cdcooper, pr_idcontrato',
     (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_SEGURO'));
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
