-- Gerar processo na mensageria para busca de valor de parcela
BEGIN
  INSERT INTO crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES('BUSCA_PARCELA_PREAPROV', 'EMPR0002', 'pc_busca_parcela_preaprov', 'pr_cdcooper,pr_nrdconta,pr_nrctremp', 71);
    
  COMMIT;
END;
