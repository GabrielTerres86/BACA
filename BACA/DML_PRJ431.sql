-- Comandos DML referente ao PRJ431

-- ---------------------------------
-- Inserts dos domínios da cobrança
-- ---------------------------------

-- Floating
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPFLOATING_RECIPR'
													        ,'1'
																	,'1'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPFLOATING_RECIPR'
													        ,'2'
																	,'2'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPFLOATING_RECIPR'
													        ,'3'
																	,'3'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPFLOATING_RECIPR'
													        ,'4'
																	,'4'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPFLOATING_RECIPR'
													        ,'5'
																	,'5'
																	);

-- Prazo de meses
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPMESES_RECIPRO'
													        ,'3'
																	,'3'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPMESES_RECIPRO'
													        ,'6'
																	,'6'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPMESES_RECIPRO'
													        ,'9'
																	,'9'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPMESES_RECIPRO'
													        ,'12'
																	,'12'
																	);

-- Vinculação
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPVINCULACAO_RECIPR'
													        ,'4'
																	,'Baixíssima'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPVINCULACAO_RECIPR'
													        ,'3'
																	,'Baixa'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPVINCULACAO_RECIPR'
													        ,'2'
																	,'Média'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('TPVINCULACAO_RECIPR'
													        ,'1'
																	,'Boa'
																	);

-- Alçadas de Aprovação
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('IDALCADA_RECIPR'
													        ,'1'
																	,'Coordenação Regional'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('IDALCADA_RECIPR'
													        ,'2'
																	,'Sede - Área de Negócios'
																	);
INSERT INTO tbcobran_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo
                          ) VALUES('IDALCADA_RECIPR'
													        ,'3'
																	,'Diretoria'
																	);

-- ------------------------
-- Inserts das novas ações
-- ------------------------
INSERT INTO craprdr(nmprogra
									 ,dtsolici
									 )
						 VALUES('TELA_CADRES'
						       ,SYSDATE
									 );

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('BUSCA_WORKFLOW'
						      ,'TELA_CADRES'
									,'pc_busca_workflow'
									,'pr_cdcooper'
						      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES')
									);

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('INSERE_APROVADOR'
						      ,'TELA_CADRES'
									,'pc_insere_aprovador'
									,'pr_cdcooper,pr_cdalcada_aprovacao,pr_cdaprovador,pr_dsemail_aprovador'
						      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES')
									);
									
INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('EXCLUIR_APROVADOR'
						      ,'TELA_CADRES'
									,'pc_exclui_aprovador'
									,'pr_cdcooper,pr_cdalcada_aprovacao,pr_cdaprovador'
						      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES')
									);

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('BUSCA_APROVADORES'
						      ,'TELA_CADRES'
									,'pc_busca_aprovadores'
									,'pr_cdcooper,pr_cdalcada_aprovacao,pr_cdaprovador'
						      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES')
									);

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('BUSCA_OPERADORES'
						      ,'TELA_CADRES'
									,'pc_busca_operadores'
									,'pr_cdcooper,pr_cdoperad,pr_nmoperad,pr_nriniseq,pr_nrregist'
						      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES')
									);

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('ATUALIZA_ALCADA'
						      ,'TELA_CADRES'
									,'pc_atualiza_alcada'
									,'pr_cdcooper,pr_cdalcada_aprovacao,pr_flregra_aprovacao'
						      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES')
									);

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('BUSCA_ALCADA_APROVACAO'
						      ,'TELA_CADRES'
									,'pc_busca_alcada_aprovacao'
									,'pr_cdcooper,pr_idcalculo_reciproci'
						      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES')
									);

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('APROVA_CONTRATO'
						      ,'TELA_CADRES'
									,'pc_aprova_contrato'
									,'pr_cdcooper,pr_cdalcada_aprovacao,pr_idcalculo_reciproci,pr_idstatus,pr_dsjustificativa'
						      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CADRES')
									);

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('BUSCA_DOMINIO'
						      ,'TELA_ATENDA_COBRAN'
									,'pc_busca_dominio'
									,'pr_nmdominio'
						      ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN')
									);

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
					   VALUES('BUSCA_CONTRATOS_ATENDA'
						       ,'TELA_ATENDA_COBRAN'
									 ,'pc_busca_contratos'
									 ,'pr_cdcooper, pr_nrdconta'
									 ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN')
									 );

INSERT INTO crapaca(nmdeacao
									 ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						VALUES('BUSCA_CONVENIOS_DESCONTO'
						      ,'TELA_ATENDA_COBRAN'
									,'pc_conv_recip_desc'
									,'pr_cdcooper, pr_nrdconta'
									,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN')
									);

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 ) 
						 VALUES('CARREGA_LOG_CONV'
						       ,'TELA_ATENDA_COBRAN'
									 ,'pc_consulta_log_conv_web'
									 ,'pr_nrdconta, pr_nrconven'
									 ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN')
									 );

INSERT INTO crapaca(nmdeacao
                   ,nmpackag
									 ,nmproced
									 ,lstparam
									 ,nrseqrdr
									 )
						 VALUES('CARREGA_LOG_NEGO'
						       ,'TELA_ATENDA_COBRAN'
									 ,'pc_consulta_log_negoc_web'
									 ,'pr_idrecipr'
									 ,(SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_COBRAN')
									 );

-- ------------------------------------------
-- Inclusão dos indicadores da reciprocidade
-- ------------------------------------------

INSERT INTO tbrecip_indicador(idindicador
                             ,nmindicador
														 ,dsindicador
														 ,tpindicador
														 ,flgativo
														 )
                       VALUES((SELECT MAX(tbrecip_indicador.idindicador) + 1 FROM tbrecip_indicador)
											       ,'Quantidade de Floating'
														 ,'É o valor com a quantidade do floating da reciprocidade.'
														 ,'Q'
														 ,1
														 );

INSERT INTO tbrecip_indicador(idindicador
                             ,nmindicador
														 ,dsindicador
														 ,tpindicador
														 ,flgativo
														 )
                       VALUES((SELECT MAX(tbrecip_indicador.idindicador) + 1 FROM tbrecip_indicador)
											       ,'Quantidade da Aplicação'
														 ,'É a quantidade de aplicação do cooperado na reciprocidade.'
														 ,'Q'
														 ,1
														 );

INSERT INTO tbrecip_indicador(idindicador
                             ,nmindicador
														 ,dsindicador
														 ,tpindicador
														 ,flgativo
														 )
                       VALUES((SELECT MAX(tbrecip_indicador.idindicador) + 1 FROM tbrecip_indicador)
											       ,'Quantidade de Depósito à Vista'
														 ,'É a quantidade de depósito à vista do cooperado na reciprocidade.'
														 ,'Q'
														 ,1
														 );

-- ------------------
-- Insert na CRAPPRM
-- ------------------

INSERT INTO crapprm(nmsistem
                   ,cdcooper
									 ,cdacesso
									 ,dstexprm
									 ,dsvlrprm
									 )
						 VALUES('CRED'
						       ,0
									 ,'DT_VIG_IMP_CTR_V2'
									 ,'Data da nova vigencia para impressao do novo modelo de contrato.'
									 ,'27/03/2018'
									 );

-- -------------------
-- Inserts na CRAPTEL
-- -------------------

INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','2','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','3','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','4','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','5','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','6','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','7','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','8','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','9','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','10','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','11','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','12','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','13','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','14','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','15','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','16','1','0','20','1',' ','2');
 
INSERT INTO craptel (NMDATELA,NRMODULO,CDOPPTEL,TLDATELA,TLRESTEL,FLGTELDF,FLGTELBL,NMROTINA,LSOPPTEL,INACESSO,CDCOOPER,IDSISTEM,IDEVENTO,NRORDROT,NRDNIVEL,NMROTPAI,IDAMBTEL)
VALUES ('ATENDA','5','@,C,H,X','Cadastro de Cobranca','Reciprocidade','0','1','RECIPROCIDADE','ACESSO,CONSULTA,HABILITACAO,CANCELAMENTO','2','17','1','0','20','1',' ','2');
