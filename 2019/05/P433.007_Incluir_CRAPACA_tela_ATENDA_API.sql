BEGIN
   INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
   VALUES
      ('EXCLUI_SERVICO_API'
      ,'TELA_ATENDA_API'
      ,'pc_exclui_api'
      ,'pr_dsrowid'
      ,(SELECT nrseqrdr FROM craprdr WHERE craprdr.nmprogra = 'TELA_ATENDA_API'));
  	
  COMMIT;
END;
