CREATE OR REPLACE PROCEDURE CECRED.pc_crps262 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
	/* ..........................................................................

		 Programa: pc_crps262 (Fontes/crps262.p)
		 Sistema : Conta-Corrente - Cooperativa de Credito
		 Sigla   : CRED
		 Autor   : Odair
		 Data    : Maio/99.                            Ultima atualizacao: 22/09/2016

		 Dados referentes ao programa:

		 Frequencia: Diario (Batch).
		 Objetivo  : Emitir relacao de cheque especial emitido no dia 212.
								 Atende solicitacao 2, ordem  

		 Alteracoes: 21/07/99 - Nao gerar pedido no MTSPOOL (Odair)
	   
								 17/12/1999 - Nao listar cancelamentos por transferencia
															cdmotcan = 4 (Odair)

								 25/04/2003 - Classificar tambem por pac e conta (Margarete).
	               
								 24/06/2003 - Dividir em duas listas <= 1000 (Margarete).
	               
								 22/07/2003 - Substituicao do valor fixo de 1000, pela variavel
															aux_dstextab, no valor max do contrato (Julio).

								 06/08/2003 - Inclusao da coluna TIPO no relatorio (Julio).
	               
								 25/11/2003 - Alteracao na mascara do campo valor (Junior).

								 22/03/2005 - Listar apenas os limites cancelados (Edson).
	                
								 16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
	                
								 25/01/2007 - Alterado as variaveis do tipo DATE de "99/99/99"
															para "99/99/9999" (Elton).

								 24/07/2008 - Alterado para acertar na hora de listar os limites
															de cheques cancelados do relatorio 212 (Gabriel).

								 09/09/2013 - Nova forma de chamar as agencias, de PAC agora 
															a escrita será PA (André Euzébio - Supero).
	                            
								 14/01/2015 - Ajuste no limite de credito para verificar a situacao
															e nao somente a craplim.dtfimvig. (James)
	                            
								 18/03/2015 - Conversao Progress >> Oracle. (Reinert)
                 
								 22/09/2016 - Alterado para buscar o qtd dias de renovacao da tabela craprli
								  			      PRJ300 - Desconto de cheque (Odirlei-AMcom)
	............................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS262';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      
      -- Controle geração Arquivo
      vr_flggerou   BOOLEAN := FALSE;

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

			/* Contratos de limite de credito */
			CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE
			                  ,pr_dtfimvig IN craplim.dtfimvig%TYPE)IS
				SELECT lim.tpctrlim
				      ,lim.insitlim
							,lim.dtinivig
							,lim.qtdiavig
							,lim.nrctrlim
							,lim.vllimite
							,lim.dtpropos
							,ass.nrdconta
							,ass.nmprimtl
							,ass.cdagenci
					FROM craplim lim
					    ,crapass ass
				 WHERE lim.cdcooper = pr_cdcooper
				   AND lim.dtfimvig = pr_dtfimvig
					 AND lim.cdmotcan NOT IN(1,4)
					 AND ass.cdcooper = lim.cdcooper
					 AND ass.nrdconta = lim.nrdconta
				 ORDER BY ass.cdagenci;
			rw_craplim cr_craplim%ROWTYPE;
					 
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------		
      
      ------------------------------- VARIAVEIS -------------------------------
            
			-- Variaveis para geração do relatório
			vr_des_xml     CLOB;            --> Buffer de dados para gerar XML de dados
 			vr_nom_dir     VARCHAR2(400);   --> Path do relatório

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
			
			/* Contratos de limite de credito */
      FOR rw_craplim IN cr_craplim(pr_cdcooper => pr_cdcooper
										              ,pr_dtfimvig => rw_crapdat.dtmvtolt) LOOP       
          
          IF rw_craplim.tpctrlim IN (1,2) AND
						 rw_craplim.insitlim = 2 THEN /* Situação do Ativo */
						 -- Busca próximo registro do cursor
						 CONTINUE;
					END IF;
 		
          
          vr_flggerou := TRUE;	
						
					-- Monta xml com dados do relatório
					pc_xml_tag('<contrato>' 
										 || '<tpctrlim>' || rw_craplim.tpctrlim || '</tpctrlim>'
										 || '<nrctrlim>' || trim(gene0002.fn_mask_contrato(rw_craplim.nrctrlim)) || '</nrctrlim>'
										 || '<nrdconta>' || trim(gene0002.fn_mask_conta(rw_craplim.nrdconta)) || '</nrdconta>'									 
										 || '<nmprimtl>' || substr(rw_craplim.nmprimtl,1, 25) || '</nmprimtl>'
										 || '<vllimite>' || rw_craplim.vllimite || '</vllimite>'									 
										 || '<cdagenci>' || rw_craplim.cdagenci || '</cdagenci>'      
										 || '<dtpropos>' || to_char(rw_craplim.dtpropos, 'dd/mm/rrrr') || '</dtpropos>'      
									|| '</contrato>');
					
			END LOOP;																	
			
      IF vr_flggerou = FALSE THEN 
				-- Flag se houve cancelamentos no dia
				pc_xml_tag('<contrato>'
				          || '<dsregist>1</dsregist>'
								||'</contrato>');
			END IF;
      
			-- Fecha tag principal
			pc_xml_tag('</root>');
      
      -- Imprimir o relatório

			-- Efetuar chamada de geração do PDF do relatório
			gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
																 ,pr_cdprogra  => vr_cdprogra
																 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
																 ,pr_dsxml     => vr_des_xml
																 ,pr_dsxmlnode => '/root/contrato'
																 ,pr_dsjasper  => 'crrl212.jasper'
																 ,pr_dsparams  => ''
																 ,pr_dsarqsaid => vr_nom_dir || '/crrl212.lst'
																 ,pr_flg_gerar => 'N'
																 ,pr_qtcoluna  => 80
																 ,pr_sqcabrel  => 1
																 ,pr_cdrelato  => 212
																 ,pr_flg_impri => 'S'
																 ,pr_nrcopias  => 1
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

  END pc_crps262;
/
