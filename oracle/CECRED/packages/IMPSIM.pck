CREATE OR REPLACE PACKAGE CECRED.IMPSIM AS

		PROCEDURE pc_importar_arquivo_SIM(pr_arquivo IN VARCHAR2 --> nome do arquivo de importação
                                     ,pr_dirarquivo IN VARCHAR2 --> nome do diretório arquivo de importação
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

		PROCEDURE pc_importar_arquivo_SIM(pr_arquivo IN VARCHAR2 --> nome do arquivo de importação
                                     ,pr_dirarquivo IN VARCHAR2 --> nome do diretório arquivo de importação
																		 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
																		 ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
		
		BEGIN
				DECLARE
						vr_nm_arquivo VARCHAR(2000);
				
						-- Variável de críticas
						vr_dscritic VARCHAR2(10000);
            vr_typ_said VARCHAR2(50);
				
						-- Variaveis padrao
						vr_cdcooper NUMBER;
						vr_cdoperad VARCHAR2(100);
						vr_nmdatela VARCHAR2(100);
						vr_nmeacao  VARCHAR2(100);
						vr_cdagenci VARCHAR2(100);
						vr_nrdcaixa VARCHAR2(100);
						vr_idorigem VARCHAR2(100);
            vr_dsdireto VARCHAR2(250);
				
						vr_linha_arq VARCHAR2(2000);
						vr_des_erro  VARCHAR2(2000);
						vr_dsorigem  VARCHAR2(20);
						vr_nrdrowid  ROWID;
				
						--Manipulação do texto do arquivo
						vr_tabtexto gene0002.typ_split;
				
						--Variáveis do split            
						vr_cdcooper_arq NUMBER;
						vr_nrcpfcgc     NUMBER;
						vr_nrdconta     NUMBER;
            vr_stpregtrb    VARCHAR2(3);
						vr_erros        NUMBER := 0;
            vr_registros    NUMBER := 0;
            vr_registros_inexis NUMBER := 0;
				
						vr_handle_arq utl_file.file_type;
				
						--Controle de erro
						vr_exc_erro         EXCEPTION;
						vr_exc_erro_negocio EXCEPTION;
				
						separador VARCHAR2(1) := ';';
            
            --vr_idx PLS_INTEGER;
            vr_idx VARCHAR2(20);
            TYPE typ_rec_dados_crapjur
                 IS RECORD (nrdconta crapjur.nrdconta%TYPE,
                            cdcooper crapjur.cdcooper%TYPE,
                            tpregtrb crapjur.tpregtrb%TYPE,
                            nrcpfcgc crapass.nrcpfcgc%TYPE);
            TYPE typ_tab_dados_crapjur IS TABLE OF typ_rec_dados_crapjur     
                   INDEX BY VARCHAR2(20);
                   
            vr_tab_dados_crapjur typ_tab_dados_crapjur;
				
						--Cursor para buscar crapjur válido
            CURSOR cr_crapjur IS
                   SELECT j.tpregtrb, j.cdcooper, j.nrdconta, a.nrcpfcgc
                   FROM crapjur j
                   INNER JOIN crapass a ON a.cdcooper = j.cdcooper AND a.nrdconta = j.nrdconta;
            rw_crapjur cr_crapjur%ROWTYPE;
                   
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
				
            vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                                ,pr_cdcooper => vr_cdcooper
                                                ,pr_nmsubdir => 'upload');
           -- Realizar a cópia do arquivo
           GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||' '||pr_dirarquivo||pr_arquivo||' N'
                                      ,pr_typ_saida   => vr_typ_said
                                      ,pr_des_saida   => vr_des_erro);                             
           -- Testar erro
           IF vr_typ_said = 'ERR' THEN
              -- O comando shell executou com erro, gerar log e sair do processo
              vr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
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
              RAISE vr_exc_erro;
           END IF;
            
           vr_nm_arquivo := vr_dsdireto||'/'||pr_arquivo;
            
           IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_nm_arquivo) THEN
              -- Retorno de erro
              vr_dscritic := 'Erro no upload do arquivo: '||vr_des_erro;
						
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
						END IF;
				
						--Abre o arquivo de saída 
						gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo,
																		 pr_tipabert => 'R',
																		 pr_utlfileh => vr_handle_arq,
																		 pr_des_erro => vr_des_erro);
				
						IF vr_des_erro IS NOT NULL THEN
								vr_dscritic := 'Erro abertura arquivo de importação! ' || vr_des_erro || ' ' ||
															 SQLERRM;
								RAISE vr_exc_erro;
						END IF;
            
            -- Busca todos os cooperados e armazena na tela temporária
            vr_tab_dados_crapjur.DELETE;
            FOR rw_crapjur IN cr_crapjur LOOP
                vr_idx := rw_crapjur.cdcooper||rw_crapjur.nrdconta;
                
                vr_tab_dados_crapjur(vr_idx).cdcooper := rw_crapjur.cdcooper;
                vr_tab_dados_crapjur(vr_idx).nrdconta := rw_crapjur.nrdconta;
                vr_tab_dados_crapjur(vr_idx).tpregtrb := rw_crapjur.tpregtrb;
                vr_tab_dados_crapjur(vr_idx).nrcpfcgc := rw_crapjur.nrcpfcgc;                
            END LOOP;
				
						--Tudo certo até aqui, importa o arquivo
						LOOP
								BEGIN
										--Lê a linha do arquivo
										gene0001.pc_le_linha_arquivo(vr_handle_arq, vr_linha_arq);
                    vr_linha_arq := TRIM(vr_linha_arq);
                                                   
                    IF NVL(vr_linha_arq,' ') <> ' ' THEN
										--Explode no texto
										vr_tabtexto := gene0002.fn_quebra_string(vr_linha_arq, separador);
								
										--Variáveis que serão usadas na atualização
										vr_cdcooper_arq := to_number(vr_tabtexto(1));
                      --Faz o replace da aspa por nada, deixando apenas o número do CNPJ (dúvidas verificar a exportação do arquivo)
                      vr_nrcpfcgc     := to_number(REPLACE(vr_tabtexto(2), '''', ''));
										vr_nrdconta     := to_number(vr_tabtexto(3));
										vr_stpregtrb    := upper(SUBSTR(vr_tabtexto(4), 1, 1));
								
										IF vr_stpregtrb IS NULL OR (vr_stpregtrb <> 'S' AND vr_stpregtrb <> 'N') THEN
												vr_dscritic := 'Campo regime de tributação inválido para a conta: ' ||
                                           vr_nrdconta || ', cooperativa ' || vr_cdcooper_arq ||
																			 ' (Valor informado: ' || vr_stpregtrb ||
                                           ', Valores permitidos: S, N)';
										
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
                        vr_idx := vr_cdcooper_arq||vr_nrdconta;
                            IF NOT vr_tab_dados_crapjur.exists(vr_idx) THEN
                          --Não achou, gera log..
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
                                vr_registros_inexis := vr_registros_inexis + 1;
                        ELSE
                            --Achou a conta
                            IF vr_tab_dados_crapjur(vr_idx).tpregtrb = 1 AND vr_stpregtrb = 'N' THEN
                                --Nula a situação tributária
                                    UPDATE crapjur a SET a.tpregtrb = 0
                                                        ,a.idimpdsn = 1
                                WHERE a.cdcooper = vr_cdcooper_arq
                                      AND a.nrdconta = vr_nrdconta;
                             ELSE
                               IF vr_stpregtrb = 'S' THEN
                                        UPDATE crapjur a SET a.tpregtrb = 1
                                                            ,a.idimpdsn = 1
                                   WHERE a.cdcooper = vr_cdcooper_arq
                                      AND a.nrdconta = vr_nrdconta;
                                 END IF;                                
                               END IF;                                
                             END IF;
                        END IF;
										END IF;
                    
                    vr_registros := vr_registros + 1;
                     
                EXCEPTION
						         WHEN NO_DATA_FOUND THEN
                          --Fecha o arquivo se não tem mais linhas para ler
                          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq); --> Handle do arquivo aberto
                          EXIT;
								END;
						END LOOP;
                        
						COMMIT;
				
            IF (vr_erros + vr_registros_inexis) > 0 THEN
										-- Retorno não OK          
										pr_des_erro := 'NOK';
										-- Erro
										pr_cdcritic := 0;
                pr_dscritic := 'Arquivo foi processado, porém com erros de preenchimento. Linhas processadas: ' || vr_registros || 
                               '. Erros preenchimento: ' || vr_erros || '. Contas inexistentes: ' || vr_registros_inexis || 
                               '. Para maiores informações, consulte o log.';
                    
                GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                     pr_cdoperad => vr_cdoperad,
                                     pr_dscritic => pr_dscritic,
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
								
										-- Existe para satisfazer exigência da interface. 
										pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																									 '<Root><Erro>' || pr_cdcritic || '-' ||
																									 pr_dscritic || '</Erro></Root>');
								END IF;
						
				EXCEPTION
						WHEN vr_exc_erro_negocio THEN
								ROLLBACK;
								--Log
								GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
																		 pr_cdoperad => vr_cdoperad,
																		 pr_dscritic => nvl(vr_dscritic,' ') || SQLERRM,
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
								pr_dscritic := vr_dscritic;
						
								-- Existe para satisfazer exigência da interface. 
								pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																							 '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
																							 '</Erro></Root>');
						WHEN vr_exc_erro THEN
                ROLLBACK;
								-- Retorno não OK          
								pr_des_erro := 'NOK';
								-- Erro
								pr_dscritic := vr_dscritic;
						
								-- Existe para satisfazer exigência da interface. 
								pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																							 '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
																							 '</Erro></Root>');
						WHEN OTHERS THEN
                ROLLBACK;
								-- Retorno não OK
								pr_des_erro := 'NOK';
						
								-- Erro
								pr_cdcritic := 0;
								pr_dscritic := 'Erro na IMPSIM.PC_IMPORTAR_ARQUIVO_SIM --> Veririque se o arquivo está em formato correto. ' || SQLERRM;
						
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
						vr_dscritic VARCHAR2(10000);
            vr_typ_said VARCHAR2(50);
				
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
								WHERE a.inpessoa >= 2 AND a.dtdemiss IS NULL
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
                --Gera o arquivo em /coop/cecred/upload
                vr_endarqui   := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                                ,pr_cdcooper => vr_cdcooper
                                                ,pr_nmsubdir => 'upload');
                
								vr_nm_arquivo := vr_endarqui || '/' || pr_arquivo;
						END IF;
				
						--Abre o arquivo de saída 
						gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo,
																		 pr_tipabert => 'W',
																		 pr_utlfileh => vr_handle_arq,
																		 pr_des_erro => vr_des_erro);
				
						IF vr_des_erro IS NOT NULL THEN
								vr_dscritic := 'Rotina pc_exportar_arquivo_SIM: Erro abertura arquivo de exportacao ('||vr_nm_arquivo||')!' ||
															 SQLERRM;
								RAISE vr_exc_erro;
						END IF;
				
						--Exporta os registros da crapjur   
						FOR r_crapjur IN cr_crapjur LOOP
								--Monta a linha
                -- Obs: Deixar o apóstrofo na linha do CNPJ/CPF, pois na edição com excel, ele "bagunça" os números
								vr_linha_arq := r_crapjur.cdcooper || separador || '''' ||r_crapjur.nrcpfcgc || separador ||
																r_crapjur.nrdconta || separador;
								--Escreve no arquivo
								gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_arq,
																							 pr_des_text => vr_linha_arq);
						END LOOP;
				
						-- Fecha arquivos
						gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
				
            -- Move o arquivo para o diretório do ayllos/upload_files
            GENE0001.pc_OScommand_Shell('scp '||vr_nm_arquivo||' scpuser@'||
            gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => 1, pr_cdacesso =>'SRVINTRA')||
            ':/var/www/ayllos/upload_files/'||pr_arquivo
                                      ,pr_typ_saida   => vr_typ_said
                                      ,pr_des_saida   => vr_des_erro);                             
						--Cria XML de retorno
						pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><arquivo>' ||
																					 pr_arquivo || '</arquivo></Root>');
				EXCEPTION
				
						WHEN vr_exc_erro THEN
								-- Retorno não OK          
								pr_des_erro := 'NOK';
								-- Erro
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
