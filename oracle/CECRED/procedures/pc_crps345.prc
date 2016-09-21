CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps345 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps345 (Fontes/crps345.p)
			 Sistema : Conta-Corrente - Cooperativa de Credito
			 Sigla   : CRED
			 Autor   : Edson                                                    
			 Data    : Junho/2003                        Ultima atualizacao: 13/02/2015
		                                                                          
			 Dados referentes ao programa:

			 Frequencia: Diario (Batch - Background).
			 Objetivo  : Atende a solicitacao 002.
									 Lista descontos de cheques do dia (290).

			 Alteracoes: 22/04/2004 - Acrescentar mais uma via no rel. 225 (Eduardo).
		   
									 13/08/2004 - Modificar relatorio para duplex (Ze Eduardo).
		               
									 30/09/2004 - Gravacao de dados na tabela gninfpl do banco
																generico, para relatorios gerenciais (Junior).

									 28/10/2004 - Colocado novos campos no relatorio: quantidade de
																cheques e valor medio (Edson).
		               
									 02/05/2005 - Remover gravacao de dados na tabela gninfpl, para
																relatorios gerenciais (Junior).

									 04/05/2005 - Ajuste de indices da leitura dos borderos (Edson).

									 21/09/2005 - Modificado FIND FIRST para FIND na tabela 
																crapcop.cdcooper = glb_cdcooper (Diego).

									 03/10/2005 - Alterado para imprimir apenas uma copia para
																CredCrea (Diego).
		                            
									 30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).
		               
									 17/02/2006 - Unificacao dos bancos - SQLWorks - Eder
		               
									 17/05/2006 - Alterado numero de vias do relatorio para
																Viacredi (Diego).
									 15/08/2013 - Nova forma de chamar as agencias, de PAC agora 
																a escrita será PA (André Euzébio - Supero). 
		                            
									 13/02/2015 - Ajustado estouro de format do numero do bordero (Daniel) 
		               
									 25/03/2015 - Conversao Progress >> Oracle. (Reinert)
    ............................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS345';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Cadastro de borderos de desconto de cheque
      CURSOR cr_crapbdc (pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
			  SELECT bdc.nrborder
				      ,bdc.nrdconta
							,bdc.cdagenci
							,bdc.nrctrlim
					FROM crapbdc bdc
				 WHERE bdc.cdcooper = pr_cdcooper
				   AND bdc.dtlibbdc = pr_dtmvtolt
				 ORDER BY bdc.cdagenci,
				          bdc.nrdconta,
									bdc.nrborder;
			rw_crapbdc cr_crapbdc%ROWTYPE;
			
			-- Cadastro de cheques contidos do Bordero de desconto de cheques
			CURSOR cr_crapcdb (pr_nrborder IN crapcdb.nrborder%TYPE
			                  ,pr_nrdconta IN crapcdb.nrdconta%TYPE) IS
				SELECT cdb.dtdevolu
				      ,cdb.vlcheque
							,cdb.vlliquid
				  FROM crapcdb cdb
				 WHERE cdb.cdcooper = pr_cdcooper
				   AND cdb.nrborder = pr_nrborder
					 AND cdb.nrdconta = pr_nrdconta
					 AND cdb.dtdevolu IS NULL;
			rw_crapcdb cr_crapcdb%ROWTYPE;
			
			-- Cadastro de associados
			CURSOR cr_crapass (pr_nrdconta IN crapass.nrdconta%TYPE) IS
			  SELECT ass.nmprimtl
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			rw_crapass cr_crapass%ROWTYPE;
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------

      -- Variaveis com o conteudo do relatório
			vr_qtcheque NUMBER := 0;
      vr_vlborder NUMBER := 0;
			vr_vlliquid NUMBER := 0;
			vr_vldjuros NUMBER := 0;
			vr_vlmedchq NUMBER;
			vr_nmprimtl VARCHAR(50);

      -- Variaveis auxiliares para geração do relatório
			vr_nom_dir  VARCHAR(400);	--> Diretório onde será armazenado o relatório		
			vr_des_xml  CLOB;         --> Buffer de dados para gerar XML de dados
      vr_nrcopias NUMBER;       --> Número de cópias do relatório

      --------------------------- SUBROTINAS INTERNAS --------------------------
      
			-- Procedure para escrever texto na variável CLOB do XML
			PROCEDURE pc_xml_tag(pr_des_dados IN VARCHAR2) IS
			BEGIN
				dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
			END pc_xml_tag;

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
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
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
															 
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Capturar diretório de relatórios da cooperativa
      vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
																				 ,pr_cdcooper => pr_cdcooper
																				 ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
																				 
 			-- Inicializar o CLOB do relatório
			dbms_lob.createtemporary(vr_des_xml, TRUE, dbms_lob.CALL);
			dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
																				 
			-- Inicilizar as informações do XML						
			pc_xml_tag('<?xml version="1.0" encoding="utf-8"?><root>');
													 
      -- Percorre os borderos de desconto de cheque
      FOR rw_crapbdc IN cr_crapbdc(pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

        vr_qtcheque := 0;
        vr_vlborder := 0;
				vr_vlliquid := 0;
				vr_vldjuros := 0;

        -- Percorre os cheques contidos do Bordero de desconto de cheques da conta
			  FOR rw_crapcdb IN cr_crapcdb (pr_nrborder => rw_crapbdc.nrborder
					                           ,pr_nrdconta => rw_crapbdc.nrdconta) LOOP										    
															
				  -- Incrementa quantidade/valores de cheques encontrados na conta
				  vr_qtcheque := vr_qtcheque + 1;
          vr_vlborder := vr_vlborder + rw_crapcdb.vlcheque;
					vr_vlliquid := vr_vlliquid + rw_crapcdb.vlliquid;
					vr_vldjuros := vr_vldjuros + (rw_crapcdb.vlcheque - 
					                              rw_crapcdb.vlliquid);
				
        END LOOP; -- rw_crapcdb
					
				-- Se possuir algum cheque
				IF vr_qtcheque > 0 THEN
				  -- Calcula valor medio dos cheques
				  vr_vlmedchq := vr_vlborder / vr_qtcheque;
				  
					-- Busca nome do titular da conta
					OPEN cr_crapass (pr_nrdconta => rw_crapbdc.nrdconta);
					FETCH cr_crapass INTO rw_crapass;
					
					IF cr_crapass%FOUND THEN
						vr_nmprimtl := rw_crapass.nmprimtl;
					ELSE
						vr_nmprimtl := '';
					END IF;
					-- Fecha cursor do associado
					CLOSE cr_crapass;
					
					-- Escreve dados do relatório no xml
					pc_xml_tag('<pa cdagenci="'|| rw_crapbdc.cdagenci || '">'
					           || '<nrdconta>' || trim(gene0002.fn_mask_conta(rw_crapbdc.nrdconta)) || '</nrdconta>'
										 || '<nmprimtl>' || substr(vr_nmprimtl,1,35) || '</nmprimtl>'
										 || '<nrctrlim>' || trim(gene0002.fn_mask_contrato(rw_crapbdc.nrctrlim)) ||'</nrctrlim>'
										 || '<nrborder>' || rw_crapbdc.nrborder || '</nrborder>'
										 || '<qtcheque>' || vr_qtcheque || '</qtcheque>'
										 || '<vlborder>' || trunc(vr_vlborder,2) || '</vlborder>'
										 || '<vlliquid>' || trunc(vr_vlliquid,2) || '</vlliquid>'
										 || '<vldjuros>' || trunc(vr_vldjuros,2) || '</vldjuros>'
										 || '<vlmedchq>' || trunc(vr_vlmedchq,2) || '</vlmedchq>'
					         ||'</pa>');
				
				END IF;
				
			END LOOP; -- rw_crapbdc
      			
			-- Fecha nó raiz      
			pc_xml_tag('</root>');

      /* 1 cópia para as cooperativas: Viacredi, Credifiesc, Credcrea*/
      IF pr_cdcooper IN (1,6,7) THEN
				vr_nrcopias := 1;
			ELSE
				vr_nrcopias := 3;
			END IF;
			
			-- Efetuar chamada de geração do PDF do relatório
			gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
																 ,pr_cdprogra  => vr_cdprogra
																 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
																 ,pr_dsxml     => vr_des_xml
																 ,pr_dsxmlnode => '/root'
																 ,pr_dsjasper  => 'crrl290.jasper'
																 ,pr_dsparams  => ''
																 ,pr_dsarqsaid => vr_nom_dir || '/crrl290.lst'
																 ,pr_flg_gerar => 'N'
																 ,pr_qtcoluna  => 132
																 ,pr_sqcabrel  => 1
																 ,pr_cdrelato  => 290
																 ,pr_flg_impri => 'S'
																 ,pr_nrcopias  => vr_nrcopias
																 ,pr_des_erro  => vr_dscritic);


	    -- Liberar dados do CLOB da memória
			dbms_lob.close(vr_des_xml);
			dbms_lob.freetemporary(vr_des_xml);
			
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps345;
/

