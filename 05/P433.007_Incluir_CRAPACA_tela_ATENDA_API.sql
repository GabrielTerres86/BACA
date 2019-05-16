BEGIN
  INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
      ('CONSULTA_SERVICOS_COOP'
      ,'TELA_ATENDA_API'
      ,'pc_consulta_servicos_coop'
      ,'pr_nrdconta'
      ,(SELECT nrseqrdr FROM craprdr WHERE craprdr.nmprogra = 'TELA_ATENDA_API'));
      
  INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
      ('CONSULTA_DESENV_COOP'
      ,'TELA_ATENDA_API'
      ,'pc_consulta_desenvolvedor_coop'
      ,'pr_nrdconta,pr_idservico_api'
      ,(SELECT nrseqrdr FROM craprdr WHERE craprdr.nmprogra = 'TELA_ATENDA_API'));
      
  INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
      ('CONSULTA_FINALIDADE_COOP'
      ,'TELA_ATENDA_API'
      ,'pc_consulta_finalidade_coop'
      ,'pr_nrdconta,pr_idservico_api'
      ,(SELECT nrseqrdr FROM craprdr WHERE craprdr.nmprogra = 'TELA_ATENDA_API'));

  INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
      ('GRAVA_SERVICOS_COOP'
      ,'TELA_ATENDA_API'
      ,'pc_grava_servicos_coop'
      ,'pr_nrdconta,pr_idservico_api,pr_dtadesao,pr_idsituacao_adesao,pr_tp_autorizacao,pr_ls_finalidades,pr_ls_desenvolvedores,pr_cddopcao'
      ,(SELECT nrseqrdr FROM craprdr WHERE craprdr.nmprogra = 'TELA_ATENDA_API'));
	  
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
