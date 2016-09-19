CREATE OR REPLACE PROCEDURE CECRED.pc_crps678 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                        ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                        ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                        ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da critica
  BEGIN
  /* ............................................................................

     Programa: pc_crps678  (Novo: Fontes/crps678.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Rafael Cechet/Lucas Reinert
     Data    : Abril/2014                         Ultima atualizacao: 12/06/2014

     Dados referentes ao programa:

     Frequencia: Diario (CRON).
     Objetivo  : Integrar cheques de custódia por arquivo

     Alteracao : 28/04/2014 - Criação do fonte crps678 (Rafael)
     
                 12/06/2014 - Ajustado mensagem de crítica ao executar script. (Rafael)         
                            - Ajustado idretorno = 2 no cursor cr_crapccc. (Rafael)

  ............................................................................ */

    DECLARE

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrdocnpj
              ,cop.cdagedbb
              ,cop.dsdircop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
			
			-- Selecionar os dados de cada Cooperativa
      CURSOR cr_crapcoop IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.dsdircop
        FROM crapcop cop
        WHERE cop.cdcooper <> 3;
      rw_crapcoop cr_crapcop%ROWTYPE;
			
			CURSOR cr_crapccc(pr_cdcooper IN crapccc.cdcooper%TYPE) IS 
      SELECT ccc.nrdconta 
			  FROM crapccc ccc 
			 WHERE ccc.cdcooper = pr_cdcooper AND -- Cooperativa
						 ccc.idretorn = 2           AND --(FTP)
						 ccc.flghomol = 1;              -- homologado
		  rw_crapccc cr_crapccc%ROWTYPE;						 
 
      -- Codigo do programa
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS678';
      -- Tratamento de erros
      vr_exc_saida    EXCEPTION;
      vr_exc_fimprg   EXCEPTION;
			vr_exc_erro     EXCEPTION;						
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
			vr_typ_saida    VARCHAR2(3);
	  
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;

      --Variaveis de Arquivo
      vr_input_file  utl_file.file_type;

      -- Diretorios das cooperativas
      vr_caminho_cooper  VARCHAR2(200);
      vr_caminho_arq     VARCHAR2(200);
			vr_caminho_conta   VARCHAR2(200);
			vr_script_cust     VARCHAR2(200);

      -- variaveis de controle de comandos shell
      vr_listadir     VARCHAR2(4000);
      vr_chave        VARCHAR2(100);

      -- variáveis de controle de arquivos
      vr_setlinha     VARCHAR2(298);
      
			-- variáveis de paramatros ftp
			vr_serv_ftp     VARCHAR2(100);
			vr_user_ftp     VARCHAR2(100);
			vr_pass_ftp     VARCHAR2(100);
			vr_comando_ftp  VARCHAR2(300);
			
			-- variáveis auxiliares
      vr_nrremess    craphcc.nrremret%TYPE;
      vr_nrremret    craphcc.nrremret%TYPE;
      
      --Tabela para receber arquivos lidos no unix
      vr_tab_arquivo     gene0002.typ_split := gene0002.typ_split();
                  
      TYPE typ_reg_cratarq IS 
        RECORD(nrdconta craphcc.nrdconta%TYPE
              ,nrconven VARCHAR2(100)
              ,nmarquiv VARCHAR2(100)
              ,nrsequen INTEGER);							
      TYPE typ_tab_cratarq IS
        TABLE OF typ_reg_cratarq
          INDEX BY VARCHAR2(100);
      vr_tab_cratarq typ_tab_cratarq; 
  
    -- INICIO
    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop( pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
	  
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
			
      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Busca nome do servidor
			vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => '0'
																							,pr_cdacesso => 'CUST_CHQ_ARQ_SERV_FTP'); 
			-- Busca nome de usuario                                                
			vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => '0'
																							,pr_cdacesso => 'CUST_CHQ_ARQ_USER_FTP');
			-- Busca senha do usuario
			vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
																							,pr_cdcooper => '0'
																							,pr_cdacesso => 'CUST_CHQ_ARQ_PASS_FTP');																							
			-- Busca caminho do script																				
      vr_script_cust := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => '0'
                                                 ,pr_cdacesso => 'SCRIPT_ENV_REC_ARQ_CUST');																																														

      FOR rw_crapcoop IN cr_crapcoop LOOP
        
				BEGIN
					
				  -- Leitura do calendário da cooperativa
					OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcoop.cdcooper);
					FETCH btch0001.cr_crapdat INTO rw_crapdat;
					-- Se não encontrar
					IF btch0001.cr_crapdat%NOTFOUND THEN
						-- Fechar o cursor pois efetuaremos raise
						CLOSE btch0001.cr_crapdat;
						-- Montar mensagem de critica
						vr_cdcritic := 1;
						-- gera excecao
						RAISE vr_exc_erro;
					ELSE
						-- Apenas fechar o cursor
						CLOSE btch0001.cr_crapdat;
					END IF;
					IF rw_crapdat.inproces <> 1 THEN
						CONTINUE;
					END IF;
					
				  IF vr_tab_arquivo.count() > 0 THEN
						-- Limpa tabela
						vr_tab_arquivo.delete;
				  END IF;
					-- Busca o diretorio da cooperativa conectada
					vr_caminho_cooper := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
																										 ,pr_cdcooper => rw_crapcoop.cdcooper
																										 ,pr_nmsubdir => '');
					-- Setando os diretorios auxiliares
					vr_caminho_arq     := vr_caminho_cooper||'/upload';							
					
					FOR rw_crapccc IN cr_crapccc(rw_crapcoop.cdcooper) LOOP
			
						vr_caminho_conta := rw_crapcoop.dsdircop || '/' || 
																TRIM(to_char(rw_crapccc.nrdconta)) || '/REMESSA';
						vr_comando_ftp := vr_script_cust                                        || ' ' || 
						'-recebe'                                                               || ' ' || 
						'-srv '          || vr_serv_ftp                                         || ' ' ||  
						'-usr '          || vr_user_ftp                                         || ' ' ||
						'-arq ''CST*.REM'''                                                     || ' ' ||
						'-pass '         || vr_pass_ftp                                         || ' ' || 
						'-dir_local '''  || vr_caminho_arq   || ''''                            || ' ' || -- /usr/coop/<cooperativa>/upload
						'-dir_remoto ''' || vr_caminho_conta || ''''                            || ' ' || -- <cooperativa>/<conta do cooperado>/REMESSA 
					  '-move_remoto ''/' || vr_caminho_conta  || '/PROC'''                    || ' ' || -- /<conta do cooperado>/REMESSA/PROC 
						'-log /usr/coop/' || rw_crapcoop.dsdircop || '/log/cst_por_arquivo.log' || ' ' || -- /usr/coop/<cooperativa>/log/cst_por_arquivo.log
						'-UC';
												
						-- Chama procedure de envio e recebimento via ftp
						GENE0001.pc_OScommand(pr_typ_comando => 'S'
																 ,pr_des_comando => vr_comando_ftp
																 ,pr_flg_aguard  => 'S'														 
																 ,pr_typ_saida   => vr_typ_saida
																 ,pr_des_saida   => vr_dscritic);
					
						 -- Se ocorreu erro dar RAISE
						IF vr_typ_saida = 'ERR' THEN
							vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando_ftp || 
                            ' - Erro: ' || vr_dscritic;
							RAISE vr_exc_erro;
						END IF;

					END LOOP;

					--Listar arquivos
					gene0001.pc_lista_arquivos( pr_path     => vr_caminho_arq
																		 ,pr_pesq     => 'CST%.REM'
																		 ,pr_listarq  => vr_listadir
																		 ,pr_des_erro => vr_dscritic);

					-- se ocorrer erro ao recuperar lista de arquivos
					-- registra no log
					IF TRIM(vr_dscritic) IS NOT NULL THEN						 
						 RAISE vr_exc_erro;
					END IF;

					/* Nao existem arquivos para serem importados */
					IF TRIM(vr_listadir) IS NULL THEN
						-- Finaliza o programa mantendo o processamento da cadeia
						vr_dscritic := 'Nao existem arquivos para serem importados';
						RAISE vr_exc_fimprg;
					END IF;

					--Carregar a lista de arquivos na temp table
					vr_tab_arquivo := gene0002.fn_quebra_string(pr_string => vr_listadir);

					-- Se retornou informacoes na temp table
					IF vr_tab_arquivo.count() > 0 THEN
						-- carrega informacoes na cratarq
						FOR vr_ind IN vr_tab_arquivo.first .. vr_tab_arquivo.last LOOP
							-- Monta a chave da temp-table
							vr_chave := rpad(vr_tab_arquivo(vr_ind),55,'#')|| lpad(rw_crapcoop.cdcooper,2,'0')||lpad(vr_ind,4,'0');
              -- alterar permissao do arquivo
              gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||
                                                            vr_caminho_arq || '/' || 
																				          			  	vr_tab_arquivo(vr_ind));                            
							-- Abre o arquivo em modo de leitura
							gene0001.pc_abre_arquivo (pr_nmcaminh => vr_caminho_arq || '/' || 
																											 vr_tab_arquivo(vr_ind)    --> Diretório do arquivo
																			 ,pr_tipabert => 'R'                       --> Modo de abertura (R,W,A)
																			 ,pr_utlfileh => vr_input_file             --> Handle do arquivo aberto
																			 ,pr_des_erro => vr_dscritic);             --> Descricao do erro
		                                  
							-- Se retornou erro
							IF  vr_dscritic IS NOT NULL  THEN
									-- Registrar Log;
									CUST0001.pc_logar_cst_arquivo(pr_cdcooper => rw_crapcoop.cdcooper
																							 ,pr_nrdconta => 0
																							 ,pr_nmarquiv => vr_tab_arquivo(vr_ind)
																							 ,pr_textolog => 'Erro ao abrir arquivo ' || vr_tab_arquivo(vr_ind) || '--> ' || vr_dscritic
																							 ,pr_cdcritic => vr_cdcritic
																							 ,pr_dscritic => vr_dscritic);
									-- Ignora arquivo, pula para o próximo                                           
									CONTINUE;
							END IF;

							-- Verifica se o arquivo esta aberto
							IF  utl_file.IS_OPEN(vr_input_file) THEN
									-- Le os dados do arquivo e coloca na variavel vr_setlinha
									gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
																							,pr_des_text => vr_setlinha); --> Texto lido             
									-- carrega a temp-table com a lista de arquivos que devem ser processados e dados do header                                                        
									vr_tab_cratarq(vr_chave).nmarquiv := vr_tab_arquivo(vr_ind);
									vr_tab_cratarq(vr_chave).nrsequen := to_number(vr_ind);
									vr_tab_cratarq(vr_chave).nrdconta := to_number(SUBSTR(vr_setlinha, 59, 13));
									vr_tab_cratarq(vr_chave).nrconven := TRIM(SUBSTR(vr_setlinha, 39, 14));      
									utl_file.fclose(vr_input_file);
							END IF;                                   

						END LOOP;
					-- Se nao possuir aquivos, sai do programa
					ELSE
						-- Finaliza o programa mantendo o processamento da cadeia
						RAISE vr_exc_fimprg;
					END IF;      

					/*--------------------------  Processa arquivos  -------------------------*/
		      
					-- Atribui à chave o primeiro registro da vr_tab_cratarq
					vr_chave := vr_tab_cratarq.FIRST;
		      
					LOOP
						-- Sai quando nao houver mais registros na vr_tab_cratarq
						EXIT WHEN vr_chave IS NULL;

						-- Rotina para validar arquivo de remessa  
						CUST0001.pc_validar_arquivo(pr_cdcooper => rw_crapcoop.cdcooper                -- Cooperativa
																			 ,pr_nrdconta => vr_tab_cratarq(vr_chave).nrdconta   -- Nr. da conta
																			 ,pr_nrconven => vr_tab_cratarq(vr_chave).nrconven   -- Nr. Convênio
																			 ,pr_nmarquiv => vr_tab_cratarq(vr_chave).nmarquiv   -- Nome do arquivo
--																			 ,pr_dtmvtolt => rw_crapdat.dtmvtolt                 -- Data atual
																			 ,pr_dtmvtolt => trunc(SYSDATE)                 -- Data atual
																			 ,pr_idorigem => 1                                   -- Fixo Ayllos
																			 ,pr_cdoperad => '1'                                 -- Fixo '1'
																			 ,pr_nrremess => vr_nrremess                         -- Nr. da remessa
																			 ,pr_cdcritic => vr_cdcritic                         -- Cód. crítica
																			 ,pr_dscritic => vr_dscritic);                       -- Desc. crítica

						-- Se retornou erro
						IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN                                            
		           -- Erro ja esta sendo logado na procedure
							 vr_cdcritic := 0;
							 vr_dscritic := '';
							 vr_chave := vr_tab_cratarq.NEXT(vr_chave);
							 CONTINUE;                   
							                                                  
						END IF;

						-- Se arquivo foi validado então processar arquivo
						CUST0001.pc_processar_arquivo(pr_cdcooper => rw_crapcoop.cdcooper                -- Cooperativa
																				 ,pr_nrdconta => vr_tab_cratarq(vr_chave).nrdconta   -- Nr. da conta
																				 ,pr_nrconven => vr_tab_cratarq(vr_chave).nrconven   -- Nr. convênio
																				 ,pr_nmarquiv => vr_tab_cratarq(vr_chave).nmarquiv   -- Nome do arquivo
																				 ,pr_dtmvtolt => rw_crapdat.dtmvtolt                 -- Data atual
																				 ,pr_idorigem => 1                                   -- Fixo Ayllos
																				 ,pr_cdoperad => '1'                                 -- Fixo '1'
																				 ,pr_nrremess => vr_nrremess                         -- Nr. da remessa
																				 ,pr_nrremret => vr_nrremret                         -- Nr. da remessa/retorno
																				 ,pr_cdcritic => vr_cdcritic                         -- Cód. crítica
																				 ,pr_dscritic => vr_dscritic);                       -- Desc. crítica
		                                     
						IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN                                   
							IF NVL(vr_cdcritic, 0) > 0 THEN
								 -- Busca critica
								 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);             
							 END IF;           
							 -- Gera log na cst_por_arquivo.log
							 CUST0001.pc_logar_cst_arquivo(pr_cdcooper => rw_crapcoop.cdcooper
																						,pr_nrdconta => vr_tab_cratarq(vr_chave).nrdconta
																						,pr_nmarquiv => vr_tab_cratarq(vr_chave).nmarquiv
																						,pr_textolog => vr_dscritic
																						,pr_cdcritic => vr_cdcritic
																						,pr_dscritic => vr_dscritic);
							 -- Zera variáveis de erro
							 vr_cdcritic := 0;
							 vr_dscritic := '';
							 -- Busca próxima chave de arquivos
							 vr_chave := vr_tab_cratarq.NEXT(vr_chave);
							 CONTINUE;
						 END IF;
						 -- Gera arquivo de retorno
						 CUST0001.pc_gerar_arquivo_retorno(pr_cdcooper => rw_crapcoop.cdcooper               -- Cooperativa
					 																	  ,pr_nrdconta => vr_tab_cratarq(vr_chave).nrdconta  -- Nr. da Conta
				 																		  ,pr_nrconven => vr_tab_cratarq(vr_chave).nrconven  -- Nr. do convênio
			 																			  ,pr_nrremret => vr_nrremret                        -- Nr. Remessa/Retorno
																						  ,pr_dtmvtolt => rw_crapdat.dtmvtolt                -- Data atual
																						  ,pr_idorigem => 1                                  -- Origem Ayllos
																						  ,pr_cdoperad => '1'                                -- Operador fixo '1'
																						  ,pr_nmarquiv => vr_tab_cratarq(vr_chave).nmarquiv  -- Nome do arquivo
																						  ,pr_cdcritic => vr_cdcritic                        -- Cód. crítica
																						  ,pr_dscritic => vr_dscritic);                      -- Desc. crítica
						 -- Se retornou crítica
						 IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN                                   
					 		 IF NVL(vr_cdcritic, 0) > 0 THEN
								 -- Busca critica
								 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);             
							 END IF;
		           
							 -- Gera log na cst_por_arquivo.log
							 CUST0001.pc_logar_cst_arquivo(pr_cdcooper => rw_crapcoop.cdcooper
																						,pr_nrdconta => vr_tab_cratarq(vr_chave).nrdconta
																						,pr_nmarquiv => vr_tab_cratarq(vr_chave).nmarquiv
																						,pr_textolog => vr_dscritic
																						,pr_cdcritic => vr_cdcritic
																						,pr_dscritic => vr_dscritic);
							 -- Zera variáveis de erro																				
							 vr_cdcritic := 0;
							 vr_dscritic := '';
							 -- Busca próxima chave de arquivos
							 vr_chave := vr_tab_cratarq.NEXT(vr_chave);
							 CONTINUE;                                                                    
						 END IF;
						 -- Busca próxima chave de arquivos
						 vr_chave := vr_tab_cratarq.NEXT(vr_chave);
		        
					 END LOOP; -- Loop por arquivo
				 -- Efetuar commit por cooperativa
				 COMMIT;	
				 EXCEPTION
					 WHEN vr_exc_erro THEN
						 -- Se foi retornado apenas codigo
						 IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
							 -- Buscar a descricao
							 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
						 END IF;
						
						 IF NVL(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
							 -- Envio centralizado de log de erro
							 -- Gera log na cst_por_arquivo.log
							 CUST0001.pc_logar_cst_arquivo(pr_cdcooper => rw_crapcoop.cdcooper
																						,pr_nrdconta => 0
																						,pr_nmarquiv => ''
																						,pr_textolog => vr_dscritic
																						,pr_cdcritic => vr_cdcritic
																						,pr_dscritic => vr_dscritic);
						 END IF;					
						
						 vr_cdcritic := 0;
						 vr_dscritic := NULL;
						 -- Efetuar rollback				  
						 ROLLBACK;
					 WHEN vr_exc_fimprg THEN
						 -- Se foi retornado apenas codigo
						 IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
							 -- Buscar a descricao
							 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
						 END IF;
						 -- Se foi gerada critica para envio ao log
						 IF NVL(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
							 -- Envio centralizado de log de erro
							 -- Gera log na cst_por_arquivo.log
							 CUST0001.pc_logar_cst_arquivo(pr_cdcooper => rw_crapcoop.cdcooper
																						,pr_nrdconta => 0
																						,pr_nmarquiv => ''
																						,pr_textolog => vr_dscritic
																						,pr_cdcritic => vr_cdcritic
																						,pr_dscritic => vr_dscritic);
						 END IF;
						
						 -- Efetuar commit pois gravaremos o que foi processo ateh entao
             COMMIT;
				 END;
				
			 END LOOP; -- FOR rw_crapcoop
			     
       -- Efetuar Commit de informacoes pendentes de gravacao
       COMMIT;
     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas codigo
         IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
           -- Buscar a descricao
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Se foi gerada critica para envio ao log
         IF NVL(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
           -- Envio centralizado de log de erro
           -- Gera log na cst_por_arquivo.log
           CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => 0
                                        ,pr_nmarquiv => ''
                                        ,pr_textolog => vr_dscritic
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
         END IF;         
         -- Efetuar commit pois gravaremos o que foi processo ateh entao
         COMMIT;
       WHEN vr_exc_saida THEN
         -- Se foi retornado apenas codigo
         IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
           -- Buscar a descricao
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         -- Efetuar rollback
         ROLLBACK;

       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;
         -- Efetuar rollback
         ROLLBACK;

    END;
  END pc_crps678;
/

