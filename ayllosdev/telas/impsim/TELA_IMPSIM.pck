CREATE OR REPLACE PACKAGE CECRED.IMPSIM AS

		PROCEDURE pc_importar_arquivo_SIM(pr_arquivo  IN VARCHAR2 --> nome do arquivo de exportação
																		 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
																		 ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

		PROCEDURE pc_exportar_arquivo_SIM(pr_arquivo  IN VARCHAR2 --> nome do arquivo de exportação
																		 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
																		 ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

END IMPSIM;
/
CREATE OR REPLACE PACKAGE BODY CECRED.IMPSIM AS
		---------------------------------------------------------------------------------------------------------------
		--
		--    Programa: TELA_IMPSIM
		--    Autor   : Diogo Carlassara
		--    Data    : 15/09/2017                   Ultima Atualizacao: 
		--
		--    Dados referentes ao programa:
		--
		--    Objetivo  : Importação e exportação de cadastros cooperados Simples Nacional
		--
		--    Alteracoes:                              
		--    
		---------------------------------------------------------------------------------------------------------------

		PROCEDURE pc_importar_arquivo_SIM(pr_arquivo  IN VARCHAR2 --> nome do arquivo de exportação
																		 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
																		 ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
		
		BEGIN
				DECLARE
						vr_endarqui   VARCHAR2(100);
						vr_nm_arquivo VARCHAR(2000);
				
						-- Variável de críticas
						vr_cdcritic crapcri.cdcritic%TYPE;
						vr_dscritic VARCHAR2(10000);
				
						-- Variaveis padrao
						vr_cdcooper NUMBER;
						vr_cdoperad VARCHAR2(100);
						vr_nmdatela VARCHAR2(100);
						vr_nmeacao  VARCHAR2(100);
						vr_cdagenci VARCHAR2(100);
						vr_nrdcaixa VARCHAR2(100);
						vr_idorigem VARCHAR2(100);
				
						vr_linha_arq VARCHAR2(2000);
						vr_des_erro  VARCHAR2(2000);
						vr_dsorigem  VARCHAR2(20);
						vr_nrdrowid  ROWID;
				
						--Manipulação do texto do arquivo
						vr_linha    NUMBER(6) := 0;
						vr_tabtexto gene0002.typ_split;
				
						--Variáveis do split            
						vr_cdcooper_arq NUMBER;
						vr_nrcpfcgc     NUMBER;
						vr_nrdconta     NUMBER;
						vr_idregtrb     NUMBER;
						vr_erros        NUMBER := 0;
				
						vr_handle_arq utl_file.file_type;
				
						--Controle de erro
						vr_exc_erro         EXCEPTION;
						vr_exc_erro_negocio EXCEPTION;
				
						separador VARCHAR2(1) := ';';
				
						--Cursor para buscar crapjur válido
						CURSOR C_CRAPJUR(pr_cdcooper IN NUMBER
														,pr_nrdconta IN NUMBER) IS
								SELECT *
								FROM crapjur
								WHERE crapjur.cdcooper = pr_cdcooper
											AND crapjur.nrdconta = pr_nrdconta;
						r_crapjur C_CRAPJUR%ROWTYPE;
				
				BEGIN
						-- Extrair informacoes padrao do xml - parametros
						gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
																		 pr_cdcooper => vr_cdcooper,
																		 pr_nmdatela => vr_nmdatela,
																		 pr_nmeacao  => vr_nmeacao,
																		 pr_cdagenci => vr_cdagenci,
																		 pr_nrdcaixa => vr_nrdcaixa,
																		 pr_idorigem => vr_idorigem,
																		 pr_cdoperad => vr_cdoperad,
																		 pr_dscritic => pr_dscritic);
						-- Buscando descricao da origem do ambiente
						vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);
				
						-- Validação do arquivo de saída
						IF pr_arquivo IS NULL THEN
								vr_dscritic := 'Arquivo para importação do Simples Nacional não foi informado!';
								vr_cdcritic := 3;
						
								--Gera log
								GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
																		 pr_cdoperad => vr_cdoperad,
																		 pr_dscritic => NVL(pr_dscritic, ' ') || vr_dscritic,
																		 pr_dsorigem => vr_dsorigem,
																		 pr_dstransa => 'IMPSIM - Importação cadastros cooperados Simples Nacional',
																		 pr_dttransa => TRUNC(SYSDATE),
																		 --> ERRO/FALSE
																		 pr_flgtrans => 0,
																		 pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
																		 pr_idseqttl => 1,
																		 pr_nmdatela => vr_nmdatela,
																		 pr_nrdconta => 0,
																		 pr_nrdrowid => vr_nrdrowid);
								--Levanta excessão
								RAISE vr_exc_erro;
						ELSE
								--/micros/coop    
								vr_endarqui   := gene0001.fn_diretorio(pr_tpdireto => 'M',
																											 pr_cdcooper => vr_cdcooper,
																											 pr_nmsubdir => '/impsim/');
								vr_nm_arquivo := vr_endarqui || '/' || pr_arquivo;
						END IF;
				
						/* verificar se o arquivo existe */
						IF NOT gene0001.fn_exis_arquivo(pr_caminho => vr_nm_arquivo) THEN
								vr_dscritic := 'Erro rotina pc_importar_arquivo_SIM - Arquivo: ' || vr_nm_arquivo ||
															 ' inexistente!';
								vr_cdcritic := 3;
								RAISE vr_exc_erro;
						END IF;
				
						--Abre o arquivo de saída 
						gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo,
																		 pr_tipabert => 'R',
																		 pr_utlfileh => vr_handle_arq,
																		 pr_des_erro => vr_des_erro);
				
						IF vr_des_erro IS NOT NULL THEN
								vr_dscritic := 'Erro abertura arquivo de importação! ' || vr_des_erro || ' ' ||
															 SQLERRM;
								vr_cdcritic := 4;
								RAISE vr_exc_erro;
						END IF;
				
						--Tudo certo até aqui, importa o arquivo
						vr_linha := 1;
						LOOP
								BEGIN
										--Lê a linha do arquivo
										gene0001.pc_le_linha_arquivo(vr_handle_arq, vr_linha_arq);
										vr_linha_arq := TRIM(translate(translate(vr_linha_arq, chr(10), ' '),
																									 chr(13),
																									 ' '));
										vr_linha     := vr_linha + 1;
								
										--Explode no texto
										vr_tabtexto := gene0002.fn_quebra_string(vr_linha_arq, separador);
								
										--Variáveis que serão usadas na atualização
										vr_cdcooper_arq := to_number(vr_tabtexto(1));
										vr_nrcpfcgc     := to_number(vr_tabtexto(2));
										vr_nrdconta     := to_number(vr_tabtexto(3));
										vr_idregtrb     := to_number(vr_tabtexto(4));
								
										IF vr_idregtrb IS NULL OR (vr_idregtrb <> 1 AND vr_idregtrb <> 2) THEN
												vr_dscritic := 'Campo regime de tributação inválido para a conta: ' ||
																			 vr_nrdconta || ', cooperativa ' || vr_cdcooper ||
																			 ' (Valor informado: ' || vr_idregtrb ||
																			 ', Valores permitidos: 1, 2)';
												vr_cdcritic := 6;
										
												--Gera log da conta não localizada
												GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
																						 pr_cdoperad => vr_cdoperad,
																						 pr_dscritic => vr_dscritic,
																						 pr_dsorigem => vr_dsorigem,
																						 pr_dstransa => 'IMPSIM - Importação cadastros cooperados Simples Nacional',
																						 pr_dttransa => TRUNC(SYSDATE),
																						 --> ERRO/FALSE
																						 pr_flgtrans => 0,
																						 pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
																						 pr_idseqttl => 1,
																						 pr_nmdatela => vr_nmdatela,
																						 pr_nrdconta => 0,
																						 pr_nrdrowid => vr_nrdrowid);
										
												vr_erros := vr_erros + 1;
												--RAISE vr_exc_erro_negocio;
										ELSE
												--Código de tributação é válido, tenta encontrar a conta
												OPEN c_crapjur(pr_cdcooper => vr_cdcooper_arq, pr_nrdconta => vr_nrdconta);
												FETCH c_crapjur
														INTO r_crapjur;
										
												IF c_crapjur%FOUND THEN
														--Conta encontrada.. tudo certo.. Atualiza crapjur
														UPDATE crapjur a
														SET a.idregtrb = vr_idregtrb,
																--Projeto 410 - RF 52 / 62
																a.idimpdsn = 1
														WHERE a.cdcooper = vr_cdcooper_arq
																	AND a.nrdconta = vr_nrdconta;
												ELSE
														--Gera log da conta não localizada
														GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
																								 pr_cdoperad => vr_cdoperad,
																								 pr_dscritic => 'Conta informada inexistente como pessoa jurídica. Conta: ' ||
																																vr_nrdconta || ' Cooperativa: ' ||
																																vr_cdcooper_arq,
																								 pr_dsorigem => vr_dsorigem,
																								 pr_dstransa => 'IMPSIM - Importação cadastros cooperados Simples Nacional',
																								 pr_dttransa => TRUNC(SYSDATE),
																								 --> ERRO/FALSE
																								 pr_flgtrans => 0,
																								 pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
																								 pr_idseqttl => 1,
																								 pr_nmdatela => vr_nmdatela,
																								 pr_nrdconta => 0,
																								 pr_nrdrowid => vr_nrdrowid);
														vr_erros := vr_erros + 1;
												END IF;
												CLOSE c_crapjur;
										END IF;
								END;
						END LOOP;
						COMMIT;
				
				EXCEPTION
						WHEN NO_DATA_FOUND THEN
								-- Fim das linhas do arquivo
								IF vr_erros > 0 THEN
										-- Retorno não OK          
										pr_des_erro := 'NOK';
										-- Erro
										pr_cdcritic := 0;
										pr_dscritic := 'Arquivo foi processado, porém com erros de preenchimento. Para maiores informações, consulte o log.';
								
										-- Existe para satisfazer exigência da interface. 
										pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																									 '<Root><Erro>' || pr_cdcritic || '-' ||
																									 pr_dscritic || '</Erro></Root>');
								ELSE
										NULL;
								END IF;
						
						WHEN vr_exc_erro_negocio THEN
								ROLLBACK;
								--Log
								GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
																		 pr_cdoperad => vr_cdoperad,
																		 pr_dscritic => vr_dscritic,
																		 pr_dsorigem => vr_dsorigem,
																		 pr_dstransa => 'IMPSIM - Importação cadastros cooperados Simples Nacional',
																		 pr_dttransa => TRUNC(SYSDATE),
																		 --> ERRO/FALSE
																		 pr_flgtrans => 0,
																		 pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
																		 pr_idseqttl => 1,
																		 pr_nmdatela => vr_nmdatela,
																		 pr_nrdconta => 0,
																		 pr_nrdrowid => vr_nrdrowid);
								COMMIT;
						
								-- Retorno não OK          
								pr_des_erro := 'NOK';
								-- Erro
								pr_cdcritic := vr_cdcritic;
								pr_dscritic := vr_dscritic;
						
								-- Existe para satisfazer exigência da interface. 
								pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																							 '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
																							 '</Erro></Root>');
						WHEN vr_exc_erro THEN
								-- Retorno não OK          
								pr_des_erro := 'NOK';
								-- Erro
								pr_cdcritic := vr_cdcritic;
								pr_dscritic := vr_dscritic;
						
								-- Existe para satisfazer exigência da interface. 
								pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																							 '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
																							 '</Erro></Root>');
						WHEN OTHERS THEN
								-- Retorno não OK
								pr_des_erro := 'NOK';
						
								-- Erro
								pr_cdcritic := 0;
								pr_dscritic := 'Erro na IMPSIM.PC_IMPORTAR_ARQUIVO_SIM --> ' || SQLERRM;
						
								-- Existe para satisfazer exigência da interface. 
								pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																							 '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
																							 '</Erro></Root>');
				END;
		END pc_importar_arquivo_SIM;

		PROCEDURE pc_exportar_arquivo_SIM(pr_arquivo  IN VARCHAR2 --> nome do arquivo de exportação
																		 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
																		 ,pr_des_erro OUT VARCHAR2) IS
		BEGIN
				DECLARE
						vr_endarqui   VARCHAR2(100);
						vr_nm_arquivo VARCHAR(200);
				
						-- Variável de críticas
						vr_cdcritic crapcri.cdcritic%TYPE;
						vr_dscritic VARCHAR2(10000);
				
						-- Variaveis padrao
						vr_cdcooper NUMBER;
						vr_cdoperad VARCHAR2(100);
						vr_nmdatela VARCHAR2(100);
						vr_nmeacao  VARCHAR2(100);
						vr_cdagenci VARCHAR2(100);
						vr_nrdcaixa VARCHAR2(100);
						vr_idorigem VARCHAR2(100);
				
						vr_handle_arq utl_file.file_type;
				
						vr_linha_arq VARCHAR2(2000);
						vr_des_erro  VARCHAR2(2000);
						vr_dsorigem  VARCHAR2(20);
						vr_nrdrowid  ROWID;
				
						--Controle de erro
						vr_exc_erro EXCEPTION;
				
						separador VARCHAR2(1) := ';';
				
						CURSOR cr_crapjur IS
								SELECT j.cdcooper, a.nrcpfcgc, j.nrdconta
								FROM crapjur j
								INNER JOIN crapass a
								ON a.cdcooper = j.cdcooper
									 AND a.nrdconta = j.nrdconta
								WHERE a.inpessoa >= 2
								ORDER BY j.cdcooper, a.nrcpfcgc, j.nrdconta;
				
						r_crapjur cr_crapjur%ROWTYPE;
				
				BEGIN
						-- Extrair informacoes padrao do xml - parametros
						gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
																		 pr_cdcooper => vr_cdcooper,
																		 pr_nmdatela => vr_nmdatela,
																		 pr_nmeacao  => vr_nmeacao,
																		 pr_cdagenci => vr_cdagenci,
																		 pr_nrdcaixa => vr_nrdcaixa,
																		 pr_idorigem => vr_idorigem,
																		 pr_cdoperad => vr_cdoperad,
																		 pr_dscritic => pr_dscritic);
						-- Buscando descricao da origem do ambiente
						vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);
				
						-- Validação do arquivo de saída
						IF pr_arquivo IS NULL THEN
								vr_dscritic := 'Arquivo para exportação Simples Nacional não foi informado!';
								vr_cdcritic := 6;
						
								--Gera log
								GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
																		 pr_cdoperad => vr_cdoperad,
																		 pr_dscritic => NVL(pr_dscritic, ' ') || vr_dscritic,
																		 pr_dsorigem => vr_dsorigem,
																		 pr_dstransa => 'IMPSIM - Importação cadastros cooperados Simples Nacional',
																		 pr_dttransa => TRUNC(SYSDATE),
																		 --> ERRO/FALSE
																		 pr_flgtrans => 0,
																		 pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
																		 pr_idseqttl => 1,
																		 pr_nmdatela => vr_nmdatela,
																		 pr_nrdconta => 0,
																		 pr_nrdrowid => vr_nrdrowid);
								--Levanta excessão
								RAISE vr_exc_erro;
						ELSE
								--/micros/coop    
								vr_endarqui   := gene0001.fn_diretorio(pr_tpdireto => 'M',
																											 pr_cdcooper => vr_cdcooper,
																											 pr_nmsubdir => '/impsim/');
								vr_nm_arquivo := vr_endarqui || '/' || pr_arquivo;
						END IF;
				
						--Abre o arquivo de saída 
						gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo,
																		 pr_tipabert => 'W',
																		 pr_utlfileh => vr_handle_arq,
																		 pr_des_erro => vr_des_erro);
				
						IF vr_des_erro IS NOT NULL THEN
								vr_dscritic := 'Rotina pc_exportar_arquivo_SIM: Erro abertura arquivo de exportacao!' ||
															 SQLERRM;
								vr_cdcritic := 6;
								RAISE vr_exc_erro;
						END IF;
				
						--Exporta os registros da crapjur   
						FOR r_crapjur IN cr_crapjur LOOP
								--Monta a linha
								vr_linha_arq := r_crapjur.cdcooper || separador || r_crapjur.nrcpfcgc || separador ||
																r_crapjur.nrdconta || separador;
								--Escreve no arquivo
								gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_arq,
																							 pr_des_text => vr_linha_arq);
						END LOOP;
				
						-- Fecha arquivos
						gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
				
						--Cria XML de retorno
						pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><pr_arquivo>' ||
																					 pr_arquivo || '</pr_arquivo>');
				EXCEPTION
				
						WHEN vr_exc_erro THEN
								-- Retorno não OK          
								pr_des_erro := 'NOK';
								-- Erro
								pr_cdcritic := vr_cdcritic;
								pr_dscritic := vr_dscritic;
						
								-- Existe para satisfazer exigência da interface. 
								pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																							 '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
																							 '</Erro></Root>');
						WHEN OTHERS THEN
								-- Retorno não OK
								pr_des_erro := 'NOK';
						
								-- Erro
								pr_cdcritic := 0;
								pr_dscritic := 'Erro na IMPSIM.PC_EXPORTAR_ARQUIVO_SIM --> ' || SQLERRM;
						
								-- Existe para satisfazer exigência da interface. 
								pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																							 '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
																							 '</Erro></Root>');
				END;
		END pc_exportar_arquivo_SIM;

END IMPSIM;
/
