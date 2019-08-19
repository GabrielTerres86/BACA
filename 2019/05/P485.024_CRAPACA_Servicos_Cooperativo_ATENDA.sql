BEGIN
  INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
      ('BUSCA_MODALIDADE'
      ,'CADA0006'
      ,'pc_busca_modalidade_web'
      ,'pr_cdcooper, pr_nrdconta'
      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'CADA0006'));
	  
    COMMIT;
  
END;
