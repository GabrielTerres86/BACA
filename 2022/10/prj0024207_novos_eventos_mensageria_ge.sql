BEGIN
  INSERT INTO crapaca 
    (NRSEQACA, 
     NMDEACAO, 
     NMPACKAG, 
     NMPROCED, 
     LSTPARAM, 
     NRSEQRDR)
  VALUES 
    ((SELECT MAX(NRSEQACA)+1 FROM CECRED.CRAPACA), 
     'CONSULTAR_CUMULATIVIDADE_TAXA', 
     null, 
     'INVESTIMENTO.obterCumulatividadeTaxa', 
     'pr_cdcooper, pr_nrdconta',
     71);
  
  INSERT INTO crapaca 
    (NRSEQACA, 
     NMDEACAO, 
     NMPACKAG, 
     NMPROCED, 
     LSTPARAM, 
     NRSEQRDR)
  VALUES 
    ((SELECT MAX(NRSEQACA)+1 FROM CECRED.CRAPACA), 
     'ATUALIZAR_CUMULATIVIDADE_TAXA', 
     null, 
     'INVESTIMENTO.atualizarCumulatividadeTaxa', 
     'pr_cdcooper, pr_nrdconta, pr_flgcumulatividade',
     71);
  
  COMMIT;
END;
