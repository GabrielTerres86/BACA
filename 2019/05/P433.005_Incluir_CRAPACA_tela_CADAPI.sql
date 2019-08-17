BEGIN
  UPDATE tbcc_produto SET flgproduto_api = 1 WHERE cdproduto = 6;

  INSERT INTO tbapi_produto_servico(idservico_api, cdproduto, dsservico_api, idapi_cooperado)
                         VALUES    (1, 6, 'API DE COBRANCA BANCARIA', 1);
  
  INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
      ('CONSULTA_PRODUTOS'
      ,'TELA_CADAPI'
      ,'pc_consulta_produtos'
      ,'pr_dsproduto'
      ,(SELECT nrseqrdr FROM craprdr WHERE craprdr.nmprogra = 'TELA_CADAPI'));
      
  INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
      ('CONSULTA_FINALIDADES'
      ,'TELA_CADAPI'
      ,'pc_consulta_finalidades'
      ,'pr_idservico_api'
      ,(SELECT nrseqrdr FROM craprdr WHERE craprdr.nmprogra = 'TELA_CADAPI'));

  INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
      ('GRAVAR_FINALIDADES'
      ,'TELA_CADAPI'
      ,'pc_grava_finalidades'
      ,'pr_idservico_api,pr_ls_finalidades'
      ,(SELECT nrseqrdr FROM craprdr WHERE craprdr.nmprogra = 'TELA_CADAPI'));
    
  COMMIT;
END;
