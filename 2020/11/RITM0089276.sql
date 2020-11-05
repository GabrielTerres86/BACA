BEGIN
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '1','Defeito',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '2','Perda/Roubo',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '3','Pelo socio',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '4','Pela COOP',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '5','Cancelado',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '6','Por fraude',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '7','Alt.Dt.Venc',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '8','Comprometido',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '9','Devolvido/Destruido',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '10','Reposto/Reimpresso',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '11','Extraviado',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_CDMOTIVO', '16','Cartao com fraude',1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '0',  'Estudo', 1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '1',  'Aprovado', 1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '2',  'Solicitado', 1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '3',  'Liberado', 1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '4',  'Em uso', 1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '5',  'Bloqueado', 1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '6',  'Cancelado', 1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '8',  'Em análise', 1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '9',  'Enviado ao bancoob', 1);
  INSERT INTO TBCRD_DOMINIO_CAMPO (NMDOMINIO, CDDOMINIO, DSCODIGO, INATIVO)  VALUES ('OPERACAO_ADM_SITCRD', '10', 'Pendente Canais', 1);
  COMMIT;
  
	BEGIN
	  DECLARE 
		-- Buscar registro da RDR
		CURSOR cr_craprdr IS
		  SELECT t.nrseqrdr
			FROM craprdr t
		   WHERE t.NMPROGRA = 'CRD_PARAM_BANCOOB';
		-- Variaveis
		vr_nrseqrdr craprdr.nrseqrdr%TYPE;
	  BEGIN
		-- Buscar RDR
		OPEN  cr_craprdr;
		FETCH cr_craprdr INTO vr_nrseqrdr;
		-- Se nao encontrar
		IF cr_craprdr%NOTFOUND THEN
		  INSERT INTO craprdr(nmprogra,dtsolici) VALUES('CRD_PARAM_BANCOOB', SYSDATE) RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
		END IF;
		-- Fechar o cursor
		CLOSE cr_craprdr;

		/*******************************************************
		*  MENSAGERIA
		*******************************************************/	
		
		INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCAR_DOMINIO_CRD', 'CRD_PARAM_BANCOOB', 'pc_buscar_dominio_web', 'pr_nmdominio', vr_nrseqrdr);

		INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('LISTAR_SITUACOES_BANCOOB', 'CRD_PARAM_BANCOOB', 'pc_listar_situacoes_web', 'pr_idoperacao, pr_idsitadm', vr_nrseqrdr);	

		INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('LISTAR_OPERACOES_BANCOOB', 'CRD_PARAM_BANCOOB', 'pc_listar_operacoes_web', 'pr_idoperacao', vr_nrseqrdr);	

		INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('MANTER_OPERACOES_BANCOOB', 'CRD_PARAM_BANCOOB', 'pc_manter_operacoes_web', 'pr_idoperacao, pr_cdtipo_registro, pr_cdoperacao, pr_dsoperacao, pr_cdacao, pr_opcao', vr_nrseqrdr);	

		INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('MANTER_SITUACOES_BANCOOB', 'CRD_PARAM_BANCOOB', 'pc_manter_situacoes_web', 'pr_idoperacao_adm, pr_cdsituacao_adm, pr_cdsituacao_cartao, pr_cdmotivo_cancelamento, pr_opcao', vr_nrseqrdr);
		
		/*******************************************************
		*  TELAS
		*******************************************************/
		BEGIN
		  DECLARE
			  CURSOR cr_crapcop IS
				  SELECT cdcooper
					  FROM crapcop c
				   WHERE c.flgativo = 1;
			  
				CURSOR cr_crapope IS
				  SELECT o.cdoperad
					  FROM crapope o
				   WHERE LOWER(o.cdoperad) IN ('f0030519')
			   GROUP BY o.cdoperad;
			BEGIN
				  FOR coop IN cr_crapcop LOOP
							INSERT INTO craptel
								(NMDATELA
								,NRMODULO
								,CDOPPTEL
								,TLDATELA
								,TLRESTEL
								,FLGTELDF
								,FLGTELBL
								,NMROTINA
								,LSOPPTEL
								,INACESSO
								,CDCOOPER
								,IDSISTEM
								,IDEVENTO
								,NRORDROT
								,NRDNIVEL
								,NMROTPAI
								,IDAMBTEL)
							VALUES
								('CARCRD'
								,5
								,'@,C,A'
								,'DE -> PARA BANCOOB com situacao do Aimaro'
								,'DE -> PARA BANCOOB com situacao do Aimaro'
								,0
								,1
								,'SITCRD'
								,'ACESSO,CONSULTA,ALTERACAO'
								,0
								,coop.cdcooper
								,1
								,0
								,1
								,1
								,' '
								,2);	
								
								
								FOR ope IN cr_crapope LOOP
									
										INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
										values ('CARCRD', '@', ope.cdoperad, 'SITCRD', coop.cdcooper, 1, 1, 2);	
																	 
										INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
										values ('CARCRD', 'C', ope.cdoperad, 'SITCRD', coop.cdcooper, 1, 1, 2);
										
										INSERT INTO crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
										values ('CARCRD', 'A', ope.cdoperad, 'SITCRD', coop.cdcooper, 1, 1, 2);												
								
								END LOOP;
				  END LOOP;
					
					COMMIT;
		  END;
		END;  
		
		COMMIT;
		
	  EXCEPTION 
		WHEN OTHERS THEN
		dbms_output.put_line('Erro ao executar: CRD_PARAM_BANCOOB --- detalhes do erro: '|| SQLCODE || ': ' || SQLERRM);
		ROLLBACK;
	  END;
	END;
  
END; 