CREATE OR REPLACE PROCEDURE CECRED.pc_crps597 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps597 (Fontes/crps597.p)
			 Sistema : Conta-Corrente - Cooperativa de Credito
			 Sigla   : CRED
			 Autor   : Gati - Diego
			 Data    : Maio/2011                       Ultima atualizacao: 04/08/2017

			 Dados referentes ao programa:

			 Frequencia: Diario. Solicitacao 5 / Ordem 5 / Cadeia Exclusiva. 
									 Tratado para rodar somente na segunda-feira.
			 Objetivo  : Gerar relatorio crrl598 - Contas que efetuaram emprestimo na 
									 ultima semana e nao contrataram seguro prestamista.
		               
			 Alteraçoes: 30/06/2011 - Rodar com solicitacao 5 (Diego).
		            
									 05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)
		               
									 07/07/2011 - Gerar relatorio por PAC (Henrique).
		               
									 04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por 
																cecredseguros@cecred.coop.br (Daniele). 
		               
									 28/08/2013 - Nova forma de chamar as agencias, de PAC agora 
																a escrita será PA (André Euzébio - Supero).
		                            
									 06/11/2013 - Alterado totalizador de PAs de 99 para 999.
																(Reinert)                            
		                            
									 08/04/2014 - Inc. do email sergio.buzzi@mdsinsure.com (Carlos)
		               
									 04/09/2014 - Atualizar envio de e-mail para
																emissao.cecred@mdsinsure.com
																daniella.ferreira@mdsinsure.com
																emissao.cecredseguros@mdsinsure.com
																cecredseguros@cecred.coop.br
																(Douglas - Chamado 194868)
		                            
									 02/12/2014 - Atualizar envio de e-mail para
																"sergio.buzzi@mdsinsure.com"                                
																"emissao.cecredseguros@mdsinsure.com"
																"daniella.ferreira@mdsinsure.com"
																"ariana.barba@mdsinsure.com"
																"pendencia.cecred@mdsinsure.com"
																"cecredseguros@cecred.coop.br" 
																(Felipe - Chamado 228940)     
																	
									 16/03/2015 - Conversão Progress >> Oracle. (Reinert)
                   
                   27/05/2015 - Ajuste para verificar se o emprestimo lista no relatorio (James)
                   
                   06/01/2016 - Adicionar resumo no relatório contendo os pré-aprovados
                                contratados sem seguro prestamista (Anderson).
                                
                   31/07/2017 - Padronizar as mensagens
                                Tratar os exception others
                                Ajustada chamada para buscar a descrição da critica
                                Ajustada mensagem: Hoje não é segunda então não pode haver processamento
                                ( Belli - Envolti - Chamado 721285)
                                
                   04/08/2017 - Eliminada critica se o dia não for para processar
                                Eliminada exception vr_exc_fimprg
                                ( Belli - Envolti - Chamado 721285)
                                
		............................................................................. */
    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS597';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_des_erro   VARCHAR2(4000);
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

      -- Buscar parametros
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
			                 ,pr_nmsistem IN craptab.nmsistem%TYPE
											 ,pr_tptabela IN craptab.tptabela%TYPE
											 ,pr_cdempres IN craptab.cdempres%TYPE
											 ,pr_cdacesso IN craptab.cdacesso%TYPE
											 ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.dstextab
				  FROM craptab tab
				 WHERE tab.cdcooper = pr_cdcooper
				   AND UPPER(tab.nmsistem) = UPPER(pr_nmsistem)
					 AND UPPER(tab.tptabela) = UPPER(pr_tptabela)
					 AND tab.cdempres = pr_cdempres
					 AND UPPER(tab.cdacesso) = UPPER(pr_cdacesso)
					 AND tab.tpregist = pr_tpregist;
      rw_craptab cr_craptab%ROWTYPE;			
			
			-- Buscar idade limite
			CURSOR cr_craptsg(pr_cdcooper IN craptsg.cdcooper%TYPE
			                 ,pr_tpseguro IN craptsg.tpseguro%TYPE
											 ,pr_tpplaseg IN craptsg.tpplaseg%TYPE
											 ,pr_cdsegura IN craptsg.cdsegura%TYPE) IS
				SELECT tsg.nrtabela
				  FROM craptsg tsg
 				 WHERE tsg.cdcooper = pr_cdcooper
				   AND tsg.tpseguro = pr_tpseguro
					 AND tsg.tpplaseg = pr_tpplaseg
					 AND tsg.cdsegura = pr_cdsegura;
			rw_craptsg cr_craptsg%ROWTYPE;
			
			-- Buscar emprestimos de pf não liquidados
			CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
			                 ,pr_dtiniref IN crapepr.dtmvtolt%TYPE
											 ,pr_dtfimref IN crapepr.dtmvtolt%TYPE) IS
				SELECT * FROM (
					SELECT epr.cdcooper
					      ,epr.dtmvtolt
								,epr.vlsdeved
								,ass.nrdconta
								,ass.dtnasctl
								,ass.cdagenci
								,ass.nmprimtl
								,row_number() OVER(PARTITION BY ass.nrdconta ORDER BY ass.nrdconta DESC) current_of
								,COUNT(*) OVER(PARTITION BY ass.nrdconta) last_of
						FROM crapepr epr,
								 crapass ass,
                 craplcr lcr
					 WHERE epr.cdcooper =  pr_cdcooper
						 AND epr.dtmvtolt >= pr_dtiniref
						 AND epr.dtmvtolt <= pr_dtfimref
						 AND epr.inliquid =  0
             AND lcr.cdcooper = epr.cdcooper
             AND lcr.cdlcremp = epr.cdlcremp
             AND lcr.flgsegpr = 1
						 AND ass.cdcooper = epr.cdcooper
						 AND ass.nrdconta = epr.nrdconta
						 AND ass.inpessoa = 1
						 ORDER BY ass.cdagenci,
						          ass.nrdconta) tab 
				WHERE tab.current_of = tab.last_of;
			rw_crapepr cr_crapepr%ROWTYPE;
			
			-- Busca saldo devedor
			CURSOR cr_crapsdv(pr_cdcooper IN crapsdv.cdcooper%TYPE
			                 ,pr_nrdconta IN crapsdv.nrdconta%TYPE
											 ,pr_dtefetiv IN crapsdv.dtefetiv%TYPE) IS
        SELECT sdv.vldsaldo
				  FROM crapsdv sdv,
               craplcr lcr
				 WHERE sdv.cdcooper = pr_cdcooper
				   AND sdv.nrdconta = pr_nrdconta
           AND lcr.cdcooper = sdv.cdcooper
           AND lcr.cdlcremp = sdv.cdlcremp
           AND lcr.flgsegpr = 1
					 AND sdv.tpdsaldo = 1 /* Emprestimo */
					 AND sdv.dtefetiv >= pr_dtefetiv;
			rw_crapsdv cr_crapsdv%ROWTYPE;
			
      CURSOR cr_crapepr_preaprv(pr_cdcooper IN crapepr.cdcooper%TYPE
                               ,pr_nrdconta IN crapepr.nrdconta%TYPE
			                         ,pr_dtiniref IN crapepr.dtmvtolt%TYPE
											         ,pr_dtfimref IN crapepr.dtmvtolt%TYPE) IS
      SELECT epr.nrctremp,
             decode(epr.cdorigem
                   ,1,'Ayllos Caracter'
                   ,2,'Caixa'
                   ,3,'Internet Bank'
                   ,4,'TAA'
                   ,5,'Ayllos Web'
                   ,6,'URA') dsorigem,
             epr.vlsdevat
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.cdfinemp = (SELECT pre.cdfinemp
                               FROM crappre pre
                              WHERE pre.cdcooper = epr.cdcooper
                                AND pre.inpessoa = 1 /* Pessoa Fisica */)
         AND epr.dtmvtolt BETWEEN pr_dtiniref AND pr_dtfimref;
      rw_crapepr_preaprv cr_crapepr_preaprv%ROWTYPE;
      
			-- Verifica cadastrado do seguro
			CURSOR cr_crapseg(pr_cdcooper IN crapseg.cdcooper%TYPE
			                 ,pr_nrdconta IN crapseg.nrdconta%TYPE
											 ,pr_dtiniref IN crapseg.dtmvtolt%TYPE
											 ,pr_dtfimref IN crapseg.dtmvtolt%TYPE) IS
		    SELECT 1
				  FROM crapseg seg
				 WHERE seg.cdcooper = pr_cdcooper
				   AND seg.nrdconta = pr_nrdconta
					 AND seg.tpseguro = 4
					 AND seg.dtmvtolt >= pr_dtiniref
					 AND seg.dtmvtolt <= pr_dtfimref;
			rw_crapseg cr_crapseg%ROWTYPE;
					
											 
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Registos da PLTable utilizada para gerar os relatórios  
			TYPE typ_reg_crapepr IS
				RECORD(cdcooper crapepr.cdcooper%TYPE
							,cdagenci crapepr.cdagenci%TYPE
							,nrdconta crapepr.nrdconta%TYPE
							,nmprimtl crapass.nmprimtl%TYPE
							,vlsdeved crapepr.vlsdeved%TYPE);
							
			-- PLTable utilizada para gerar os relatórios  
			TYPE typ_tab_crapepr IS
				TABLE OF typ_reg_crapepr
				INDEX BY VARCHAR2(11);
        
      -- Registros da PLTable utilizada para gerar o resumo pre-aprovado
      TYPE typ_reg_crdpa IS
        RECORD(cdcooper crapepr.cdcooper%TYPE
							,cdagenci crapepr.cdagenci%TYPE
							,nrdconta crapepr.nrdconta%TYPE
							,nmprimtl crapass.nmprimtl%TYPE
							,vlsdeved crapepr.vlsdeved%TYPE
              ,nrctremp crapepr.nrctremp%TYPE
              ,dsorigem varchar(100));
      
      -- PLTable utilizada para gerar o resumo
      TYPE typ_tab_crdpa IS
				TABLE OF typ_reg_crdpa
				INDEX BY VARCHAR2(30);
      ------------------------------- VARIAVEIS -------------------------------

      -- Variaveis usadas na tabela de parametros
			vr_vlminsde NUMBER;
			vr_dtiniseg DATE;

      -- Variavel usada na tabela craptsg
			vr_tab_nrdeanos NUMBER;
			
			-- Variaveis retornadas da CADA0001.pc_busca_idade
			vr_nrdeanos NUMBER;
			vr_nrdmeses NUMBER;
			vr_dsdidade VARCHAR2(100);
			
			-- Variaveis gerais
			vr_dtiniref DATE;
			vr_dtfimref DATE;
			vr_totsaldo NUMBER;
			vr_dsdemail crapprm.dsvlrprm%TYPE;
			
			--PLTables
			vr_cratepr typ_tab_crapepr;
      vr_crdpa   typ_tab_crdpa;
			
			-- Indicies PlTables
			vr_ind_cratepr VARCHAR2(20);
      vr_ind_crdpa   VARCHAR2(30);
			
			-- Variaveis para geração do relatório
			vr_des_xml     CLOB;                               --> Buffer de dados para gerar XML de dados por PA
			vr_des_xml_999 CLOB;                               --> Buffer de dados para gerar XML de dados do relatório geral
			vr_nom_dir     VARCHAR2(400);                      --> Path do relatório
			vr_nmarqimp    VARCHAR2(40) := 'crrl598_999.lst';  --> Nome do relatorio
			
      --------------------------- SUBROTINAS INTERNAS --------------------------
			
	    -- Procedure para escrever texto na variável CLOB do XML
			PROCEDURE pc_xml_tag(pr_des_dados IN VARCHAR2
				                  ,pr_flggeral  IN NUMBER) IS
			BEGIN
				IF pr_flggeral = 0 THEN
				  dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
				ELSE
					dbms_lob.writeappend(vr_des_xml_999, length(pr_des_dados), pr_des_dados);
				END IF;
			END pc_xml_tag;
      
    --
      
		PROCEDURE pc_processa
      IS
		BEGIN
      -- Capturar o path do arquivo
      vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
      -- Buscar parametros
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'SEGPRESTAM'
                     ,pr_tpregist => 0);
      FETCH cr_craptab INTO rw_craptab;
      
      IF cr_craptab%FOUND THEN
         -- Atribuir valor às variaveis pelo campo dstextab
         vr_vlminsde := to_number(gene0002.fn_busca_entrada(pr_postext => 3
                                                           ,pr_dstext => rw_craptab.dstextab
                                                           ,pr_delimitador => ' '));
                                       
         -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
         GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 
                                                                                                                
         vr_dtiniseg := to_date(SUBSTR(rw_craptab.dstextab, 40, 10), 'dd/mm/rrrr');
      END IF;
      CLOSE cr_craptab;
      
      -- Buscar idade limite
      OPEN cr_craptsg(pr_cdcooper => pr_cdcooper
                     ,pr_tpseguro => 4
                     ,pr_tpplaseg => 1
                     ,pr_cdsegura => 5011); -- Seguradora CHUBB
      FETCH cr_craptsg INTO rw_craptsg;
      
      IF cr_craptsg%NOTFOUND THEN
         vr_tab_nrdeanos := 0;
      ELSE
         vr_tab_nrdeanos := rw_craptsg.nrtabela;
      END IF;
      CLOSE cr_craptsg;

      -- Data de inicio de referencia é igual ao segundo dia do mês
      vr_dtiniref := rw_crapdat.dtmvtoan - to_number(to_char(rw_crapdat.dtmvtoan, 'D')) + 2;
      vr_dtfimref := rw_crapdat.dtmvtoan;
      
      -- Percorre os emprestimos não liquidados de pf
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper
                                  ,pr_dtiniref => vr_dtiniref
                                  ,pr_dtfimref => vr_dtfimref) LOOP
			
			  -- Zera valor total do saldo
			  vr_totsaldo := 0;

				-- Busca saldo devedor de emprestimo do cooperado
				FOR rw_crapsdv IN cr_crapsdv(pr_cdcooper => rw_crapepr.cdcooper
					                          ,pr_nrdconta => rw_crapepr.nrdconta
																		,pr_dtefetiv => vr_dtiniseg) LOOP
				
				  -- Acumula valor do saldo devedor total
				  vr_totsaldo := vr_totsaldo + rw_crapsdv.vldsaldo;
																		
				END LOOP;
			  
				IF vr_totsaldo <= vr_vlminsde THEN
           continue;					
				END IF;
										
				-- Busca idade do cooperado
				CADA0001.pc_busca_idade(pr_dtnasctl => rw_crapepr.dtnasctl
				                       ,pr_dtmvtolt => rw_crapepr.dtmvtolt
															 ,pr_nrdeanos => vr_nrdeanos
															 ,pr_nrdmeses => vr_nrdmeses
															 ,pr_dsdidade => vr_dsdidade
															 ,pr_des_erro => vr_des_erro);

	      -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
		    GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 
								
				IF vr_nrdeanos > vr_tab_nrdeanos THEN
					 continue;
				END IF;
				
				-- Verifica cadastro do seguro
				OPEN cr_crapseg(pr_cdcooper => rw_crapepr.cdcooper
				               ,pr_nrdconta => rw_crapepr.nrdconta
											 ,pr_dtiniref => vr_dtiniref
						           ,pr_dtfimref => vr_dtfimref);
				FETCH cr_crapseg INTO rw_crapseg;
				
				IF cr_crapseg%NOTFOUND THEN
					-- Alimenta o indice da PLTable -> PA(999) + Nr. da Conta(99999999)
					vr_ind_cratepr := to_char(rw_crapepr.cdagenci, 'fm000') || to_char(rw_crapepr.nrdconta, 'fm00000000');
					
					-- Alimenta registros da PLTable com os dados do emprestimo
					vr_cratepr(vr_ind_cratepr).cdcooper := rw_crapepr.cdcooper;
					vr_cratepr(vr_ind_cratepr).cdagenci := rw_crapepr.cdagenci;
					vr_cratepr(vr_ind_cratepr).nrdconta := rw_crapepr.nrdconta;
					vr_cratepr(vr_ind_cratepr).nmprimtl := rw_crapepr.nmprimtl;
					vr_cratepr(vr_ind_cratepr).vlsdeved := vr_totsaldo;
          
          -- Percorre os emprestimos pre-aprovado para o resumo.
          FOR rw_crapepr_preaprv IN cr_crapepr_preaprv(pr_cdcooper => rw_crapepr.cdcooper
                                                      ,pr_nrdconta => rw_crapepr.nrdconta
                                                      ,pr_dtiniref => vr_dtiniref
                                                      ,pr_dtfimref => vr_dtfimref) LOOP
            vr_ind_crdpa := to_char(rw_crapepr.cdagenci, 'fm000') || 
                            to_char(rw_crapepr.nrdconta, 'fm00000000') ||
                            to_char(rw_crapepr_preaprv.nrctremp, 'fm0000000000');
            vr_crdpa(vr_ind_crdpa).cdcooper := rw_crapepr.cdcooper;
            vr_crdpa(vr_ind_crdpa).cdagenci := rw_crapepr.cdagenci;
            vr_crdpa(vr_ind_crdpa).nrdconta := rw_crapepr.nrdconta;
            vr_crdpa(vr_ind_crdpa).nmprimtl := rw_crapepr.nmprimtl;
            vr_crdpa(vr_ind_crdpa).vlsdeved := rw_crapepr_preaprv.vlsdevat;
            vr_crdpa(vr_ind_crdpa).nrctremp := rw_crapepr_preaprv.nrctremp;
            vr_crdpa(vr_ind_crdpa).dsorigem := rw_crapepr_preaprv.dsorigem;
          END LOOP;          
				END IF;
				CLOSE cr_crapseg;
      END LOOP;																	
			
			-- Inicializar o CLOB do relatório por PA
			dbms_lob.createtemporary(vr_des_xml, TRUE, dbms_lob.CALL);
			dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
			-- Inicilizar as informações do XML
      pc_xml_tag('<?xml version="1.0" encoding="utf-8"?><root>',0);
			
			-- Inicializar o CLOB do relatório geral
			dbms_lob.createtemporary(vr_des_xml_999, TRUE);
			dbms_lob.open(vr_des_xml_999, dbms_lob.lob_readwrite);
			-- Inicilizar as informações do XML
      pc_xml_tag('<?xml version="1.0" encoding="utf-8"?><root dtiniref="' || to_char(vr_dtiniref, 'dd/mm/rrrr') || '" dtfimref="' || to_char(vr_dtfimref, 'dd/mm/rrrr') || '">',1);
			
			-- Atribui indice do primeiro registro da PLTable
			vr_ind_cratepr := vr_cratepr.first;
      vr_ind_crdpa   := vr_crdpa.first;
			-- Percorre a PLTable para geração do relatório
			WHILE vr_ind_cratepr IS NOT NULL LOOP
				
			  -- Insere as informações no xml do relatório por PA
        pc_xml_tag('<conta>' 
				           || '<cdagenci>' || vr_cratepr(vr_ind_cratepr).cdagenci || '</cdagenci>'      
									 || '<nrdconta>' || gene0002.fn_mask_conta(vr_cratepr(vr_ind_cratepr).nrdconta) || '</nrdconta>'
									 || '<nmprimtl>' || vr_cratepr(vr_ind_cratepr).nmprimtl || '</nmprimtl>'
									 || '<vlsdeved>' || vr_cratepr(vr_ind_cratepr).vlsdeved || '</vlsdeved>'
				        || '</conta>',0);
								
				-- Insere as informações no xml do relatório geral
        pc_xml_tag('<conta>' 
				           || '<cdagenci>' || vr_cratepr(vr_ind_cratepr).cdagenci || '</cdagenci>'      
									 || '<nrdconta>' || gene0002.fn_mask_conta(vr_cratepr(vr_ind_cratepr).nrdconta) || '</nrdconta>'
									 || '<nmprimtl>' || vr_cratepr(vr_ind_cratepr).nmprimtl || '</nmprimtl>'
									 || '<vlsdeved>' || vr_cratepr(vr_ind_cratepr).vlsdeved || '</vlsdeved>'
				        || '</conta>',1);
                                       
	      -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
		    GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 
			
			  -- Se o PA do proximo registro for diferente do atual, gera o relatório do PA atual
			  IF SUBSTR(vr_ind_cratepr,1,3) <> SUBSTR(vr_cratepr.NEXT(vr_ind_cratepr),1,3) THEN

          -- Inicio da geracao do resumo por agencia.
          pc_xml_tag('<resumo>',0);
          -- Enquanto for a mesma agencia
          WHILE (SUBSTR(vr_ind_crdpa,1,3) = SUBSTR(vr_ind_cratepr,1,3)) and 
                (vr_ind_crdpa IS NOT NULL) LOOP 
            pc_xml_tag('<preaprovado>'
                       || '<cdagenci>' || vr_crdpa(vr_ind_crdpa).cdagenci || '</cdagenci>'      
                       || '<nrdconta>' || gene0002.fn_mask_conta(vr_crdpa(vr_ind_crdpa).nrdconta) || '</nrdconta>'
                       || '<nmprimtl>' || vr_crdpa(vr_ind_crdpa).nmprimtl || '</nmprimtl>'
                       || '<vlsdeved>' || vr_crdpa(vr_ind_crdpa).vlsdeved || '</vlsdeved>'
                       || '<nrctremp>' || gene0002.fn_mask_contrato(vr_crdpa(vr_ind_crdpa).nrctremp) || '</nrctremp>'
                       || '<dsorigem>' || vr_crdpa(vr_ind_crdpa).dsorigem || '</dsorigem>'
                    || '</preaprovado>',0);
                                       
	          -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
		        GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 
            
            -- Atribui próximo indice da PLTable
            vr_ind_crdpa := vr_crdpa.NEXT(vr_ind_crdpa);
          END LOOP;
          
          -- Fecha tag principal
          pc_xml_tag('</resumo></root>',0);
					
  		    -- Imprimir o relatório
					-- Efetuar chamada de geração do PDF do relatório
					gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
																		 ,pr_cdprogra  => vr_cdprogra
																		 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
																		 ,pr_dsxml     => vr_des_xml
																		 ,pr_dsxmlnode => '/root'
																		 ,pr_dsjasper  => 'crrl598.jasper'
																		 ,pr_dsparams  => ''
																		 ,pr_dsarqsaid => vr_nom_dir || '/crrl598_'|| to_char(vr_cratepr(vr_ind_cratepr).cdagenci,'fm000') || '.lst'
																		 ,pr_flg_gerar => 'N'
																		 ,pr_qtcoluna  => 132
																		 ,pr_sqcabrel  => 1
																		 ,pr_cdrelato  => 598
																		 ,pr_flg_impri => 'S'
																		 ,pr_nrcopias  => 1
																		 ,pr_des_erro  => vr_dscritic);
                                       
	        -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
		      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 

					-- Liberar dados do CLOB da memória
					dbms_lob.close(vr_des_xml);
					dbms_lob.freetemporary(vr_des_xml);
				
				  -- Se o proximo registro não for nulo
				  IF vr_cratepr.NEXT(vr_ind_cratepr) IS NOT NULL THEN
						-- Inicializar o CLOB do proximo PA
						dbms_lob.createtemporary(vr_des_xml, TRUE, dbms_lob.CALL);
						dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
						-- Inicilizar as informações do XML
						pc_xml_tag('<?xml version="1.0" encoding="utf-8"?><root>',0);
					END IF;
				
				END IF;
			 
			  -- Atribui próximo indice da PLTable
			  vr_ind_cratepr := vr_cratepr.NEXT(vr_ind_cratepr);
			
			END LOOP;

      -- Inicio da geracao do resumo geral.
      pc_xml_tag('<resumo>',1);
      vr_ind_crdpa  := vr_crdpa.first;
      WHILE vr_ind_crdpa IS NOT NULL LOOP
        pc_xml_tag('<preaprovado>'
                   || '<cdagenci>' || vr_crdpa(vr_ind_crdpa).cdagenci || '</cdagenci>'      
                   || '<nrdconta>' || gene0002.fn_mask_conta(vr_crdpa(vr_ind_crdpa).nrdconta) || '</nrdconta>'
                   || '<nmprimtl>' || vr_crdpa(vr_ind_crdpa).nmprimtl || '</nmprimtl>'
                   || '<vlsdeved>' || vr_crdpa(vr_ind_crdpa).vlsdeved || '</vlsdeved>'
                   || '<nrctremp>' || gene0002.fn_mask_contrato(vr_crdpa(vr_ind_crdpa).nrctremp) || '</nrctremp>'
                   || '<dsorigem>' || vr_crdpa(vr_ind_crdpa).dsorigem || '</dsorigem>'
                || '</preaprovado>',1);
                                       
	    -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
		  GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 
            
        -- Atribui próximo indice da PLTable
        vr_ind_crdpa := vr_crdpa.NEXT(vr_ind_crdpa);
      END LOOP;
			-- Fecha tag principal
			pc_xml_tag('</resumo></root>',1);
			
			vr_dsdemail := GENE0001.fn_param_sistema('CRED',0,'CRRL598_EMAIL');
			-- Imprimir o relatório
			-- Efetuar chamada de geração do PDF do relatório
			gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                            -- Cooperativa
																 ,pr_cdprogra  => vr_cdprogra                            -- Programa
																 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                    -- Data de movimento
																 ,pr_dsxml     => vr_des_xml_999                         -- CLOB
																 ,pr_dsxmlnode => '/root'                                -- Nó principal
																 ,pr_dsjasper  => 'crrl598.jasper'                       -- Nome do jasper
																 ,pr_dsparams  => ''                                     -- Parametros adicionais
																 ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarqimp       -- Caminho e nome do PDF de saida
																 ,pr_flg_gerar => 'N'                                    -- Não Gerar na hora
																 ,pr_qtcoluna  => 132                                    -- Quantidade de colunas
																 ,pr_sqcabrel  => 1                                      -- Sequencia do cabrel
																 ,pr_cdrelato  => 598                                    -- Código do relatório
																 ,pr_flg_impri => 'S'                                    -- Imprimir
																 ,pr_nrcopias  => 1                                      -- Número de cópias
																 ,pr_fldosmail => 'S'                                    -- Flag para converter arquivo para dos antes de enviar email
 																 ,pr_dsmailcop => vr_dsdemail                            -- Email De Destinatario
																 ,pr_dsassmail => 'EMPRESTIMOS CONTRATADOS SEM SEGURO'   -- Assunto do email
																 ,pr_dsextmail => '.txt'                                 -- Extensão do arquivo enviado por email
																 ,pr_des_erro  => vr_dscritic);                          -- Código da crítica
                                       
	    -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
		  GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
            
			-- Liberar dados do CLOB da memória
			dbms_lob.close(vr_des_xml_999);
			dbms_lob.freetemporary(vr_des_xml_999);	
      
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 28/07/2017 - Chamado 721285        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        vr_dscritic := 'pc_processa com erro: ' || SQLERRM;
        RAISE vr_exc_saida;			
		END pc_processa;
    
    --

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

      -- Rodar somente na segunda-feira 
      IF TO_NUMBER(to_char(rw_crapdat.dtmvtolt, 'D')) > 
			   TO_NUMBER(to_char(rw_crapdat.dtmvtoan, 'D')) THEN
        NULL;
      ELSE
        pc_processa;
	  END IF;
	  --
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas			
      COMMIT;      

    EXCEPTION      
      WHEN vr_exc_saida THEN
        -- Ajustada chamada para buscar a descrição da critica - 31/07/2017 - Chamado 721285
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic);
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 31/07/2017 - Chamado 721285        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps597;
/
