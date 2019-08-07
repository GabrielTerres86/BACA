BEGIN 
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) 
  VALUES ('BUSCASEGCASASIGAS', 'TELA_ATENDA_SEGURO', 'pc_detalha_seguro_casa_sigas', 'pr_nrdconta, pr_cdcooper, pr_idcontrato', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'TELA_ATENDA_SEGURO'));

  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) 
  VALUES ('CANCELASEGCASASIGAS', 'TELA_ATENDA_SEGURO', 'pc_cancela_seguro_casa_sigas', 'pr_cdidsegp, pr_nrdconta', (SELECT NRSEQRDR FROM craprdr WHERE NMPROGRA = 'TELA_ATENDA_SEGURO'));
  commit;
END;
