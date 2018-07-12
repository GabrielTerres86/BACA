-- Comandos DML referente ao PRJ431

-- ---------------------------------
-- Inserts dos dom�nios da cobran�a
-- ---------------------------------

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
                          ) VALUES('TPFLOATING_RECIPRO'
													        ,'5'
																	,'5'
																	);
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

-- ------------------------
-- Inserts das novas a��es
-- ------------------------

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

-- ------------------------------------------
-- Inclus�o dos indicadores da reciprocidade
-- ------------------------------------------

INSERT INTO tbrecip_indicador(idindicador
                             ,nmindicador
														 ,dsindicador
														 ,tpindicador
														 ,flgativo
														 )
                       VALUES((SELECT MAX(tbrecip_indicador.idindicador) + 1 FROM tbrecip_indicador)
											       ,'Quantidade de Floating'
														 ,'� o valor com a quantidade do floating da reciprocidade.'
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
											       ,'Quantidade da Aplica��o'
														 ,'� a quantidade de aplica��o do cooperado na reciprocidade.'
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
											       ,'Quantidade de Dep�sito � Vista'
														 ,'� a quantidade de dep�sito � vista do cooperado na reciprocidade.'
														 ,'Q'
														 ,1
														 );
