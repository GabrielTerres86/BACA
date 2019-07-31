BEGIN 
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) 
  VALUES ('BUSCASEGCASASIGAS', 'TELA_ATENDA_SEGURO', 'pc_detalha_seguro_casa_sigas', 'pr_nrdconta, pr_cdcooper, pr_nrapolic', 504);

  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) 
  VALUES ('CANCELASEGCASASIGAS', 'TELA_ATENDA_SEGURO', 'pc_cancela_seguro_casa_sigas', 'pr_cdidsegp, pr_nrdconta', 504);
  commit;
END;
