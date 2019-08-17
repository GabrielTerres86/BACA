BEGIN 
	INSERT INTO crapaca
		  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	  VALUES
		  ('CANTESTA_PORTABILIDADE'
		  ,'TELA_ATENDA_PORTAB'
		  ,'pc_contesta_portabilidade'
		  ,'pr_nrdconta,pr_cdmotivo'
		  ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));

	INSERT INTO crapaca
		  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	  VALUES
		  ('BUSCA_MOTIVOS_CONTESTACAO'
		  ,'TELA_ATENDA_PORTAB'
		  ,'pc_busca_motivos_contestacao'
		  ,''
		  ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));

	INSERT INTO crapaca
		  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	  VALUES
		  ('BUSCA_DADOS_CONTESTACAO_ENVIA'
		  ,'TELA_ATENDA_PORTAB'
		  ,'pc_busca_dados_contest_en'
		  ,'pr_nrdconta,pr_nrsolicitacao'
		  ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));

	INSERT INTO crapaca
		  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	  VALUES
		  ('BUSCA_DADOS_CONTESTACAO_RECEBE'
		  ,'TELA_ATENDA_PORTAB'
		  ,'pc_busca_dados_contest_re'
		  ,'pr_nrnuportabilidade'
		  ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
		  
	INSERT INTO crapaca
		  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	  VALUES
		  ('RESPONDE_PORTABILIDADE'
		  ,'TELA_ATENDA_PORTAB'
		  ,'pc_responde_contestacao'
		  ,'pr_dsrowid,pr_cdmotivo,pr_idstatus'
		  ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
	
	
	INSERT INTO crapaca
		  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	  VALUES
		  ('BUSCA_MOTIVOS_RESPONDE_CONTESTACAO'
		  ,'TELA_ATENDA_PORTAB'
		  ,'pc_busca_motivos_responder'
		  ,'pr_cdmotivo'
		  ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
	
	
	INSERT INTO crapaca
		  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	  VALUES
		  ('BUSCA_MOTIVOS_REGULARIZA_PORTABILIDADE'
		  ,'TELA_ATENDA_PORTAB'
		  ,'pc_busca_motivos_regularizar'
		  ,'pr_idsituacao'
		  ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
		  
	INSERT INTO crapaca
		  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	  VALUES
		  ('REGULARIZA_PORTABILIDADE'
		  ,'TELA_ATENDA_PORTAB'
		  ,'pc_regulariza_portabilidade'
		  ,'pr_cdmotivo,pr_dsrowid'
		  ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
		  
	INSERT INTO crapaca
		  (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
	  VALUES
		  ('BUSCA_DADOS_REGULARIZACAO'
		  ,'TELA_ATENDA_PORTAB'
		  ,'pc_busca_dados_regularizacao'
		  ,'pr_nrnu_portabilidade'
		  ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));

	INSERT INTO 
		  tbcc_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
	  VALUES ('SIT_PORTAB_SALARIO_RECEBE', '6', 'Contestada');

		  
	COMMIT;
END;