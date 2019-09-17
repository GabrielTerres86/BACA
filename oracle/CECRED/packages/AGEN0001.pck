CREATE OR REPLACE PACKAGE CECRED.AGEN0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : AGEN0001
  --  Sistema  : Rotinas para busca de agendamentos
  --  Sigla    : AGEN
  --  Autor    : Ricardo Linhares
  --  Data     : Julho/2017.                   Ultima atualizacao: 16/07/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: - Sempre que chamado
  -- Objetivo  : Disponibilizar rotinas de busca de agendamentos para SOA
  --
  -- Alterações: 16/07/2018 - Incluido campo dsorigem de retorno no XML da procedure pc_lista_agendamentos, Prj. 363 (Jean Michel)
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_lista_agendamentos(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> Numero da Conta
                                 ,pr_dsorigem  IN VARCHAR2               --> Descricao da Origem
                                 ,pr_dtageini  IN crapdat.dtmvtolt%TYPE  --> Data de Agendamento Inicial
                                 ,pr_dtagefim  IN crapdat.dtmvtolt%TYPE  --> Data de Agendamento Final
                                 ,pr_insitlau  IN craplau.insitlau%TYPE  --> Situacao do Lancamento
                                 ,pr_iniconta  IN INTEGER                --> Numero de Registros da Tela
                                 ,pr_nrregist  IN INTEGER                --> Numero da Registros
																 ,pr_cdtipmod IN NUMBER                 --> Código do módulo da consulta
                                 ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                 ,pr_dsretorn OUT VARCHAR2);             --> Retorno de critica (OK ou NOK)

  PROCEDURE pc_detalhe_agendamento_ted(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                      ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                      ,pr_dsretorn OUT VARCHAR2);             --> Retorno de critica (OK ou NOK)
                                      
  PROCEDURE pc_detalhe_agendamento_trans(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                        ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2);             --> Retorno de critica (OK ou NOK)
                                        
  PROCEDURE pc_detalhe_agendamento_pagam(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                        ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2);             --> Retorno de critica (OK ou NOK)
                                        
  PROCEDURE pc_detalhe_agendamento_darf(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                       ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                       ,pr_dsretorn OUT VARCHAR2);             --> Retorno de critica (OK ou NOK)
																			 
	PROCEDURE pc_detalhe_age_pagto_gps(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                       ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                       ,pr_dsretorn OUT VARCHAR2);             --> Retorno de critica (OK ou NOK)
																			 
  PROCEDURE pc_detalhe_age_recarga_cel(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                       ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                       ,pr_dsretorn OUT VARCHAR2);             --> Retorno de critica (OK ou NOK)                                      																			 
                                       
  PROCEDURE pc_detalhe_agendamento (pr_cdtiptra  IN craplau.cdtiptra%TYPE  --> Tipo do Agendamento
                                   ,pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                   ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                   ,pr_dsretorn OUT VARCHAR2);             --> Retorno de critica (OK ou NOK)

  -- FGTS
  PROCEDURE pc_detalhe_agendamento_FGTS(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                       ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                       ,pr_dsretorn OUT VARCHAR2);
                                       
  -- DAE
  PROCEDURE pc_detalhe_agendamento_DAE( pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                       ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                       ,pr_dsretorn OUT VARCHAR2);                                                                          

END AGEN0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.AGEN0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : AGEN0001
  --  Sistema  : Rotinas para busca de agendamentos
  --  Sigla    : AGEN
  --  Autor    : Ricardo Linhares
  --  Data     : Julho/2017.                   Ultima atualizacao: 16/07/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: - Sempre que chamado
  -- Objetivo  : Disponibilizar rotinas de busca de agendamentos para SOA
  --
  -- Alterações: 16/07/2018 - Incluido campo dsorigem de retorno no XML da procedure pc_lista_agendamentos, Prj. 363 (Jean Michel)
  --             12/06/2019 - Incluido tratamento para TED Judicial. 
  --                          Jose Dill - Mouts (P475 - REQ39)
  ---------------------------------------------------------------------------------------------------------------

  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
	-- Pessoa Fídica
	SELECT ass.cdcooper
				,ass.nrdconta
				,ass.inpessoa
                ,ttl.nrcpfcgc
				,ttl.nmextttl
		FROM crapass ass
				,crapttl ttl
	 WHERE ass.cdcooper = ttl.cdcooper
		 AND ass.nrdconta = ttl.nrdconta
		 AND ass.inpessoa = 1 -- Pessoa Física

		 AND ass.cdcooper = pr_cdcooper
		 AND ass.nrdconta = pr_nrdconta
		 AND ttl.idseqttl = 1
	UNION ALL
	-- Pessoa Jurídica
	SELECT ass.cdcooper
				,ass.nrdconta
				,ass.inpessoa
                ,ass.nrcpfcgc
				,ass.nmprimtl nmextttl
		FROM crapass ass
	 WHERE ass.inpessoa <> 1 -- Pessoa Jurídica
		 AND ass.cdcooper = pr_cdcooper
		 AND ass.nrdconta = pr_nrdconta
		 AND ROWNUM = 1;
	rw_crapass cr_crapass%ROWTYPE;
	
	CURSOR cr_crapopi(pr_cdcooper IN crapopi.cdcooper%TYPE
									 ,pr_nrdconta IN crapopi.nrdconta%TYPE
									 ,pr_nrcpfope IN crapopi.nrcpfope%TYPE) IS

	SELECT opi.nmoperad
		FROM crapopi opi
	 WHERE opi.cdcooper = pr_cdcooper
		 AND opi.nrdconta = pr_nrdconta
		 AND opi.nrcpfope = pr_nrcpfope;
	rw_crapopi cr_crapopi%ROWTYPE;

  -- Obtem a descrição de acordo com o tipo do agendamento
  FUNCTION fn_descricao (pr_tab_dados_agendamento IN PAGA0002.typ_reg_dados_agendamento) RETURN VARCHAR2 IS
  BEGIN
    
    DECLARE
    
      vr_cdtiptra INTEGER;
      vr_dsagenda VARCHAR2(100);
    
      BEGIN
        
        vr_cdtiptra := pr_tab_dados_agendamento.cdtiptra;
        
        CASE
          WHEN vr_cdtiptra = 2          THEN vr_dsagenda := pr_tab_dados_agendamento.dscedent;
          WHEN vr_cdtiptra IN (10,12,13) THEN 
              
            vr_dsagenda := pr_tab_dados_agendamento.dsidpgto;
            
            IF TRIM(vr_dsagenda) IS NULL THEN
              vr_dsagenda := pr_tab_dados_agendamento.dsnomfon;
              IF TRIM(vr_dsagenda) IS NULL THEN
                vr_dsagenda := 'AGENDAMENTO DE ' || pr_tab_dados_agendamento.dstiptra;                
              END IF;
            END IF;
            
          WHEN vr_cdtiptra IN (1,3,4,5) THEN vr_dsagenda := substr(pr_tab_dados_agendamento.dsageban,1,4) || '/' || pr_tab_dados_agendamento.nrctadst;
          --REQ39
          WHEN vr_cdtiptra = 22 THEN vr_dsagenda := pr_tab_dados_agendamento.dsageban;
        END CASE;

        RETURN vr_dsagenda;
      
      END;    
  
  END;

  -- Listar Agendamentos
  PROCEDURE pc_lista_agendamentos(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> Numero da Conta
                                 ,pr_dsorigem  IN VARCHAR2               --> Descricao da Origem
                                 ,pr_dtageini  IN crapdat.dtmvtolt%TYPE  --> Data de Agendamento Inicial
                                 ,pr_dtagefim  IN crapdat.dtmvtolt%TYPE  --> Data de Agendamento Final
                                 ,pr_insitlau  IN craplau.insitlau%TYPE  --> Situacao do Lancamento
                                 ,pr_iniconta  IN INTEGER                --> Numero de Registros da Tela
                                 ,pr_nrregist  IN INTEGER                --> Numero da Registros
																 ,pr_cdtipmod  IN NUMBER                 --> Código do módulo da consulta
                                 ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                 ,pr_dsretorn OUT VARCHAR2) IS          --> Retorno de critica (OK ou NOK)

  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_agendamentos
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Ricardo Linhares
     Data    : Julho/17.                    Ultima atualizacao: 16/07/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar agendamentos

     Observacao: -----

     Alteracoes: 18/10/2017 - Alterado o parametro de consulta de recarga de 3 para 5
                              (IF pr_cdtipmod = 3 -> IF pr_cdtipmod = 3 -- Recarga de Celular), Prj. 285 
                              (Jean Michel).
                              
                 06/12/2017 - Adicionado filtro por tipo de transação
                              (p285 - Ricardo Linhares)                              

                 03/01/2017 - Incluido tipos de guias FGTS e DAE.
                              PRJ406-FGTS(Odirlei-AMcom)                                     

                 16/07/2018 - Incluido campo dsorigem de retorno no XML, Prj. 363 (Jean Michel)                                     
     ..................................................................................*/   
     
   DECLARE
  
		vr_agendm_fltr PAGA0002.typ_tab_dados_agendamento;    --> PL Table para filtrar registros
		vr_tab_age_recarga   rcel0001.typ_tab_age_recarga;    --> PL Table para filtrar registros
    vr_exc_erro    EXCEPTION;
    vr_dstransa    VARCHAR2(500);
    vr_xml_temp    VARCHAR2(32726) := '';
    vr_cdcritic    crapcri.cdcritic%TYPE;
    vr_dscritic    crapcri.dscritic%TYPE;
    vr_qttotage    INTEGER;
    vr_dstiptra    VARCHAR2(100);
                
    CURSOR cr_crapdat(pr_cdcooper crapdat.cdcooper%TYPE) IS
      SELECT dtmvtolt
        FROM crapdat
       WHERE cdcooper = pr_cdcooper;
      rw_crapdat cr_crapdat%ROWTYPE;        
  
    BEGIN      
      -- Busca o Lançamento
      OPEN cr_crapdat(pr_cdcooper);
      FETCH cr_crapdat INTO rw_crapdat;
      
      IF cr_crapdat%notfound THEN
        CLOSE cr_crapdat;
        vr_dscritic := 'crapdat não encontrado';
        pr_dsretorn := 'NOK';
        RAISE vr_exc_erro;        
      END IF;     

      CLOSE cr_crapdat;
			
      IF pr_cdtipmod = 1 OR pr_cdtipmod = 2 OR pr_cdtipmod = 0 THEN -- Pagamento, Transferências
				
			  IF pr_cdtipmod = 1 THEN -- Pagamento
                vr_dstiptra := '2;10;12;13'; -- Pagamento; DARF/DAS/FGTS/DAE
  			ELSIF pr_cdtipmod = 2 THEN -- Transferências 
          vr_dstiptra := '1;3;4;5;22'; --Transferencias inter; Credito salario; TED; Transferencias intra

				END IF;
						
				PAGA0002.pc_obtem_agendamentos(pr_cdcooper => pr_cdcooper
																			,pr_cdagenci => NULL
																			,pr_nrdcaixa => 900
																			,pr_nrdconta => pr_nrdconta
																			,pr_dsorigem => NULL
																			,pr_dtmvtolt => rw_crapdat.dtmvtolt
																			,pr_dtageini => pr_dtageini
																			,pr_dtagefim => pr_dtagefim
																			,pr_insitlau => pr_insitlau
																			,pr_iniconta => pr_iniconta - 1 /* Necessário subtrair pois o controle de paginação interno é realizado com posição inicial 0 */
																			,pr_nrregist => pr_nrregist
                                      ,pr_cdtiptra => vr_dstiptra
																			,pr_dstransa => vr_dstransa
																			,pr_qttotage => vr_qttotage
																			,pr_tab_dados_agendamento => vr_agendm_fltr
																			,pr_cdcritic => vr_cdcritic
																			,pr_dscritic => vr_dscritic);                                    
				-- Verifica se retornou erro
				IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;
 							
      END IF;
      
			IF pr_cdtipmod = 5 OR pr_cdtipmod = 0 THEN -- Recarga de Celular
				
				rcel0001.pc_carrega_agend_recarga(pr_cdcooper        => pr_cdcooper
															           ,pr_nrdconta        => pr_nrdconta
															           ,pr_situacao        => CASE WHEN pr_insitlau = 3 THEN 4
                                                                     WHEN pr_insitlau = 4 THEN 5
                                                                     ELSE pr_insitlau
																																END
															           ,pr_dtinicial       => pr_dtageini
															           ,pr_dtfinal         => pr_dtagefim
															           ,pr_tab_age_recarga => vr_tab_age_recarga
																				 ,pr_qttotage        => vr_qttotage
															           ,pr_cdcritic        => vr_cdcritic
															           ,pr_dscritic        => vr_dscritic);																				 
				-- Verifica se retornou erro
				IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;	
      END IF;

      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
			
			--dbms_output.put_line(vr_agendm_fltr.count);
			--dbms_output.put_line(vr_tab_age_recarga.count);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Agendamentos>');       

      IF vr_agendm_fltr.count > 0 THEN
				FOR vr_idx IN vr_agendm_fltr.first..vr_agendm_fltr.last LOOP
	      
					gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																 ,pr_texto_completo => vr_xml_temp      
																 ,pr_texto_novo     => 
																 '<Agendamento>' ||
																		'<idlancto>' || vr_agendm_fltr(vr_idx).idlancto                                                               || '</idlancto>' ||
																		'<dtmvtopg>' || TO_CHAR(vr_agendm_fltr(vr_idx).dtmvtopg, 'DD/MM/RRRR')                                        || '</dtmvtopg>' ||
																		'<cdtiptra>' || vr_agendm_fltr(vr_idx).cdtiptra                                                               || '</cdtiptra>' ||
																		'<dstiptra>' || vr_agendm_fltr(vr_idx).dstiptra                                                               || '</dstiptra>' ||
																		'<idlstdom>' || vr_agendm_fltr(vr_idx).idlstdom                                                               || '</idlstdom>' ||                                    
																		'<dsagenda>' || fn_descricao(vr_agendm_fltr(vr_idx))                                                          || '</dsagenda>' ||
																		'<insitlau>' || vr_agendm_fltr(vr_idx).insitlau                                                               || '</insitlau>' ||
																		'<dssitlau>' || vr_agendm_fltr(vr_idx).dssitlau                                                               || '</dssitlau>' ||                                  
																		'<vldocmto>' || to_char(vr_agendm_fltr(vr_idx).vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
																		'<incancel>' || vr_agendm_fltr(vr_idx).incancel                                                               || '</incancel>' ||
																		'<dscritic>' || vr_agendm_fltr(vr_idx).dscritic                                                               || '</dscritic>' ||
                                    '<dsorigem>' || vr_agendm_fltr(vr_idx).dsorigem                                                               || '</dsorigem>' ||
																	'</Agendamento>');																															 
				END LOOP;
			END IF;
			
			IF vr_tab_age_recarga.count > 0 THEN
				FOR vr_idx IN vr_tab_age_recarga.first..vr_tab_age_recarga.last LOOP -- Agendamentos de recarga de celular
					
					gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																 ,pr_texto_completo => vr_xml_temp      
																 ,pr_texto_novo     => 
																 '<Agendamento>' ||
																		'<idlancto>' || vr_tab_age_recarga(vr_idx).idoperacao                                                              || '</idlancto>' ||
																		'<dtmvtopg>' || TO_CHAR(vr_tab_age_recarga(vr_idx).dtrecarga, 'DD/MM/RRRR')                                        || '</dtmvtopg>' ||
																		'<cdtiptra>20</cdtiptra>' ||
																		'<dstiptra>Recarga de celular</dstiptra>' ||
                                    '<idlstdom>20</idlstdom>' ||
																		'<dsagenda>AGENDAMENTO DE RECARGA DE CELULAR</dsagenda>' ||
																		'<insitlau>' || CASE WHEN vr_tab_age_recarga(vr_idx).insit_operacao = 4 THEN 3
																												 WHEN vr_tab_age_recarga(vr_idx).insit_operacao = 5 THEN 4
																												 ELSE vr_tab_age_recarga(vr_idx).insit_operacao
																										END                                                                                                || '</insitlau>' ||
																		'<dssitlau>' || vr_tab_age_recarga(vr_idx).dssit_operacao                                                          || '</dssitlau>' ||                                  
																		'<vldocmto>' || to_char(vr_tab_age_recarga(vr_idx).vlrecarga,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
																		'<incancel>' || vr_tab_age_recarga(vr_idx).incancel                                                                || '</incancel>' ||
                                    '<nrdddtel>' || gene0002.fn_mask(vr_tab_age_recarga(vr_idx).nrddd,'(99)')                                          || '</nrdddtel>' ||
																		'<nrtelefo>' || gene0002.fn_mask(vr_tab_age_recarga(vr_idx).nrcelular,'99999-9999')                                || '</nrtelefo>' ||
																		'<nmoperad>' || vr_tab_age_recarga(vr_idx).nmoperadora                                                             || '</nmoperad>' ||
																		'<dscritic>' || vr_tab_age_recarga(vr_idx).dscritic                                                                || '</dscritic>' ||
                                    '<dsorigem>' || vr_tab_age_recarga(vr_idx).dsorigem                                                               || '</dsorigem>' ||
																'</Agendamento>');
                                
            IF vr_idx > pr_nrregist THEN
              EXIT;
            END IF;
                                
				END LOOP;
			END IF;
			      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Agendamentos>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';                             

      EXCEPTION        
        WHEN vr_exc_erro THEN  
					
					IF vr_cdcritic <> 0 THEN
						vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
					END IF;
				
				  pr_retxml := '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
				  pr_dsretorn := 'NOK';
					             
        WHEN OTHERS THEN
					
          vr_dscritic := 'Erro ao criar XML: ' || SQLERRM;
          pr_retxml :=   '<dsmsgerr>'|| vr_dscritic ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';    
    END;                                        

  END pc_lista_agendamentos;

  -- TED
  PROCEDURE pc_detalhe_agendamento_ted(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                      ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                      ,pr_dsretorn OUT VARCHAR2) IS

  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_agendamento_ted
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Ricardo Linhares
     Data    : Julho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento TED

     Observacao: -----

     Alteracoes: 18/10/217 - Inclusão do campo nrcpfpre, Prj. 285 (Jean Michel).

                 25/04/2018 - Alterar comportamento da descricao das agencias de destino
                              para as TEDs, pois nao devemos colocar a descricao "Nao
                              cadastrado", pois existem agencias que de fato nao temos a
                              descricao. (Anderson P285).

                 17/06/2019 - Atribuir o identificador de deposito judicial ao comprovante.
                              Jose Dill - Mouts (P475 - Req39)
                              
     ..................................................................................*/     
     
   DECLARE
  
    vr_exc_erro EXCEPTION;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_des_erro    VARCHAR2(4000);
    vr_nmoperad crapopi.nmoperad%TYPE := '';
		vr_info_sac COMP0002.typ_reg_info_sac;

    CURSOR cr_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
      SELECT LPAD(cop.cdagectl,4,'0') AS cdagectl
			      ,LPAD(cop.cdbcoctl,3,'0') AS cdbcoctl
			      ,to_char(lau.dttransa, 'DD/MM/RRRR') AS dttransa
						,to_char(lau.dtmvtopg, 'DD/MM/RRRR') AS dtmvtopg
            ,lau.cdcooper
            ,lau.nrdconta 
            ,TRIM(GENE0002.fn_mask_conta(lau.nrdconta)) AS dsdconta
						,lau.cdtiptra
            ,'TED' AS dstiptra 
            ,gene0002.fn_converte_time_data(lau.hrtransa,'S') AS hrtransa
            ,lau.nrdocmto
            ,lau.insitlau
            , CASE lau.insitlau
                   WHEN 1 THEN 'Pendente'
                   WHEN 2 THEN 'Pendente'
                   WHEN 3 THEN 'Cancelado'
                   WHEN 4 THEN 'Nao Efetivado'
              END AS dssitlau
            ,lau.vllanaut AS vllanaut
						,to_char(lau.dtdebito, 'DD/MM/RRRR') AS dtdebito
            ,NVL2(ban.cdbccxlt, LPAD(ban.cdbccxlt,4,'0') || ' - ' || REPLACE(UPPER(TRIM(ban.nmextbcc)),'&','e'),'Nao cadastrado') AS dsdbanco
            ,NVL2(agb.cdageban, LPAD(agb.cdageban,4,'0') || ' - ' || REPLACE(UPPER(TRIM(agb.nmageban)),'&','e'),'Nao cadastrado') AS dsdagenc
						,NVL(ban.cdbccxlt, 0) AS cdbandst
						,NVL2(ban.cdbccxlt, REPLACE(UPPER(TRIM(ban.nmextbcc)),'&','e'),'Nao cadastrado') AS dsbandst						
					 	,NVL(lau.cdageban, 0) AS cdagedst
						,NVL2(agb.cdageban, REPLACE(UPPER(TRIM(agb.nmageban)),'&','e'),' ') AS dsagedst						
            ,TRIM(GENE0002.fn_mask_conta(cti.nrctatrf)) || ' - ' || cti.nmtitula AS dstitula
            ,TRIM(GENE0002.fn_mask_conta(cti.nrctatrf)) AS dsctadst
						,cti.nmtitula AS dstitdst
            ,lau.nmprepos
            ,lau.nrcpfpre
            ,lau.nrcpfope
            ,tda.dsidentific dsidenti
       FROM craplau lau
	LEFT JOIN crapcop cop
         ON cop.cdcooper = lau.cdcooper
  LEFT JOIN crapban ban
         ON ban.cdbccxlt = lau.cddbanco
  LEFT JOIN crapagb agb
         ON agb.cddbanco = lau.cddbanco
        AND agb.cdageban = lau.cdageban
  LEFT JOIN crapcti cti
         ON cti.cdcooper = lau.cdcooper
        AND cti.nrdconta = lau.nrdconta
        AND cti.cddbanco = lau.cddbanco
        AND cti.cdageban = lau.cdageban
        AND cti.nrctatrf = lau.nrctadst
  LEFT JOIN tbted_det_agendamento tda
         ON lau.idlancto = tda.idlancto /*REQ39*/      
      WHERE lau.idlancto = pr_idlancto; 
      rw_agendamento cr_agendamento%ROWTYPE;                
  
    BEGIN
      
      vr_nmoperad := '';

      -- Busca o Lançamento
      OPEN cr_agendamento(pr_idlancto);
      FETCH cr_agendamento INTO rw_agendamento;
      
      IF cr_agendamento%notfound THEN
        CLOSE cr_agendamento;
        vr_des_erro := 'Lancamento nao encontrado';
        RAISE vr_exc_erro;        
      END IF;     

      CLOSE cr_agendamento;
      
      IF rw_agendamento.nrcpfope > 0 THEN 
        OPEN cr_crapopi(pr_cdcooper => rw_agendamento.cdcooper
                       ,pr_nrdconta => rw_agendamento.nrdconta
                       ,pr_nrcpfope => rw_agendamento.nrcpfope);

        FETCH cr_crapopi INTO rw_crapopi;

        IF cr_crapopi%FOUND THEN
          -- Fecha cursor
          CLOSE cr_crapopi;
          vr_nmoperad := nvl(rw_crapopi.nmoperad, '');
        ELSE
          -- Fecha cursor
          CLOSE cr_crapopi;
        END IF;
      END IF;

			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => rw_agendamento.cdcooper,
											 pr_nrdconta => rw_agendamento.nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;								
				vr_des_erro := 'Associado nao cadastrado.';								
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
				
			vr_info_sac := COMP0002.fn_info_sac(pr_cdcooper => rw_agendamento.cdcooper);

      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Agendamento>');       
                             
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => 
															'<cdtiptra>' || rw_agendamento.cdtiptra || '</cdtiptra>' ||
															'<dstiptra>' || rw_agendamento.dstiptra || '</dstiptra>' ||
														  '<idlstdom>4</idlstdom>'                                 ||
                              '<nrdocmto>' || rw_agendamento.nrdocmto || '</nrdocmto>' ||
															'<cdbcoctl>' || rw_agendamento.cdbcoctl || '</cdbcoctl>' ||
															'<cdagectl>' || rw_agendamento.cdagectl || '</cdagectl>' ||
															'<nrdconta>' || rw_agendamento.nrdconta || '</nrdconta>' ||
															'<nmtitula>' || rw_crapass.nmextttl     || '</nmtitula>' ||
                              '<nmprepos>' || rw_agendamento.nmprepos || '</nmprepos>' ||
                              '<nrcpfpre>' || rw_agendamento.nrcpfpre || '</nrcpfpre>' ||
                              '<nmoperad>' || vr_nmoperad             || '</nmoperad>' ||
															'<nrcpfope>' || rw_agendamento.nrcpfope || '</nrcpfope>' ||
															'<cdbandst>' || rw_agendamento.cdbandst || '</cdbandst>' ||
															'<dsbandst>' || rw_agendamento.dsbandst || '</dsbandst>' ||
															'<cdagedst>' || rw_agendamento.cdagedst || '</cdagedst>' ||
															'<dsagedst>' || rw_agendamento.dsagedst || '</dsagedst>' ||
															'<dsctadst>' || rw_agendamento.dsctadst || '</dsctadst>' ||
															'<dstitdst>' || rw_agendamento.dstitdst || '</dstitdst>' ||
															'<dttransa>' || rw_agendamento.dttransa || '</dttransa>' ||
															'<hrautent>' || rw_agendamento.hrtransa || '</hrautent>' ||
															'<dtmvtopg>' || rw_agendamento.dtmvtopg || '</dtmvtopg>' ||																
															'<vldocmto>' || to_char(rw_agendamento.vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||																
														  '<dsidenti>' || rw_agendamento.dsidenti ||'</dsidenti>'  || /*REQ39*/
                             	'<dssituac>' || rw_agendamento.dssitlau || '</dssituac>' ||
															'<infosac>'  ||
																	'<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
																	'<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
																	'<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
																	'<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
																	'<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
																	'<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
															'</infosac>');
     
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Agendamento>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';                             

      EXCEPTION								
				WHEN vr_exc_erro THEN  							
					
					pr_retxml := '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN
								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_retxml :=   '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';  
          
     END;
    
  END pc_detalhe_agendamento_ted;
   
  -- Transferencia 
  PROCEDURE pc_detalhe_agendamento_trans(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                        ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2) IS           --> Retorno de critica (OK ou NOK)

    BEGIN
      
    /* ................................................................................

     Programa: pc_detalhe_agendamento_trans
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Ricardo Linhares
     Data    : Julho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento Transaferencia

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão do campo nrcpfpre, Prj. 285 (Jean Michel)

     ..................................................................................*/       
       
     DECLARE
    
      vr_exc_erro EXCEPTION;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_des_erro VARCHAR2(4000);
      vr_idlstdom NUMBER;
      vr_nmoperad crapopi.nmoperad%TYPE := '';
			vr_info_sac COMP0002.typ_reg_info_sac;

      CURSOR cr_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
        SELECT LPAD(cop_origem.cdagectl,4,'0') AS cdagectl
				      ,LPAD(cop_origem.cdbcoctl,3,'0') AS cdbcoctl
				      ,cop_destino.nmrescop AS nmcopdst
							,LPAD(cop_destino.cdagectl,4,'0') AS cdagedst
							,ass_origem.nmprimtl
							,ass_destino.nmprimtl AS nmtitdst
							,lau.nrctadst
				      ,to_char(lau.dttransa, 'DD/MM/RRRR') AS dttransa
              ,lau.cdcooper
              ,lau.nrdconta
              ,TRIM(GENE0002.fn_mask_conta(lau.nrdconta)) AS dsdconta
							,lau.cdtiptra
							,DECODE(lau.cdtiptra, 1, 'Transferencia', 3, 'Crédito de Salário', 'Transferencia') AS dstiptra
              ,gene0002.fn_converte_time_data(lau.hrtransa,'S') AS hrtransa
              ,lau.nrdocmto
              ,lau.insitlau
              , CASE lau.insitlau
                     WHEN 1 THEN 'Pendente'
                     WHEN 2 THEN 'Pendente'
                     WHEN 3 THEN 'Cancelado'
                     WHEN 4 THEN 'Nao Efetivado'
                END AS dssitlau
              ,lau.vllanaut
              ,to_char(lau.dtdebito, 'DD/MM/RRRR') AS dtdebito
              ,LPAD(cop_destino.cdagectl,4,'0') || ' - ' || cop_destino.nmrescop AS dsdcoper
              ,TRIM(GENE0002.fn_mask_conta(lau.nrctadst)) || ' - ' || ass_destino.nmprimtl AS dstitula
              ,to_char(lau.dtmvtopg, 'DD/MM/RRRR') AS dtmvtopg
              ,lau.nmprepos
              ,lau.nrcpfpre
							,lau.dscedent
              ,lau.nrcpfope
         FROM craplau lau
    LEFT JOIN crapcop cop_origem
           ON cop_origem.cdcooper = lau.cdcooper
		LEFT JOIN crapcop cop_destino
           ON cop_destino.cdagectl = lau.cdageban
		LEFT JOIN crapass ass_origem
           ON ass_origem.cdcooper = lau.cdcooper
          AND ass_origem.nrdconta = lau.nrdconta
    LEFT JOIN crapass ass_destino
           ON ass_destino.cdcooper = cop_destino.cdcooper
          AND ass_destino.nrdconta = lau.nrctadst		
    LEFT JOIN crapcti cti
           ON cti.cdcooper = lau.cdcooper
          AND cti.nrdconta = lau.nrdconta
          AND cti.cddbanco = lau.cddbanco
          AND cti.cdageban = lau.cdageban
          AND cti.nrctatrf = lau.nrctadst
        WHERE lau.idlancto = pr_idlancto; 
        rw_agendamento cr_agendamento%ROWTYPE;                
    
      BEGIN
        
        vr_nmoperad := '';

        -- Busca o Lançamento
        OPEN cr_agendamento(pr_idlancto);
        FETCH cr_agendamento INTO rw_agendamento;
        
        IF cr_agendamento%notfound THEN
          CLOSE cr_agendamento;
          vr_des_erro := 'Lancamento nao encontrado';     
          RAISE vr_exc_erro; 
        END IF;     

        CLOSE cr_agendamento;
        
        IF rw_agendamento.nrcpfope > 0 THEN 
          OPEN cr_crapopi(pr_cdcooper => rw_agendamento.cdcooper
                         ,pr_nrdconta => rw_agendamento.nrdconta
                         ,pr_nrcpfope => rw_agendamento.nrcpfope);

          FETCH cr_crapopi INTO rw_crapopi;

          IF cr_crapopi%FOUND THEN
            -- Fecha cursor
            CLOSE cr_crapopi;
            vr_nmoperad := nvl(rw_crapopi.nmoperad, '');
          ELSE
            -- Fecha cursor
            CLOSE cr_crapopi;
          END IF;
        END IF;

				-- Buscar dados do associado
				OPEN cr_crapass (pr_cdcooper => rw_agendamento.cdcooper,
												 pr_nrdconta => rw_agendamento.nrdconta);
				FETCH cr_crapass INTO rw_crapass;

				IF cr_crapass%NOTFOUND THEN
					CLOSE cr_crapass;								
					vr_des_erro := 'Associado nao cadastrado.';								
					RAISE vr_exc_erro;
				ELSE
					CLOSE cr_crapass;
				END IF;
				
				vr_info_sac := COMP0002.fn_info_sac(pr_cdcooper => rw_agendamento.cdcooper);

        IF rw_agendamento.cdtiptra = 1 THEN
          vr_idlstdom := 5; -- Transf. Intracoop
        ELSIF rw_agendamento.cdtiptra = 5 THEN
          vr_idlstdom := 6; -- Transf. Intercoop
        ELSE
          vr_idlstdom := 3; -- Crédito Salário
        END IF;

        dbms_lob.createtemporary(pr_retxml, TRUE);
        dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
         
         -- Criar cabecalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<Agendamento>');       
                               
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
															  '<cdtiptra>' || rw_agendamento.cdtiptra || '</cdtiptra>' ||
																'<dstiptra>' || rw_agendamento.dstiptra || '</dstiptra>' ||
																'<idlstdom>' || TO_CHAR(vr_idlstdom)    || '</idlstdom>' ||                                
                                '<nrdocmto>' || rw_agendamento.nrdocmto || '</nrdocmto>' ||
																'<cdbcoctl>' || rw_agendamento.cdbcoctl || '</cdbcoctl>' ||
																'<cdagectl>' || rw_agendamento.cdagectl || '</cdagectl>' ||
																'<nrdconta>' || rw_agendamento.nrdconta || '</nrdconta>' ||
																'<nmtitula>' || rw_crapass.nmextttl     || '</nmtitula>' ||
                                '<nmprepos>' || rw_agendamento.nmprepos || '</nmprepos>' ||
                                '<nrcpfpre>' || rw_agendamento.nrcpfpre || '</nrcpfpre>' ||
                                '<nmoperad>' || vr_nmoperad             || '</nmoperad>' ||
																'<nrcpfope>' || rw_agendamento.nrcpfope || '</nrcpfope>' ||
																'<cdagedst>' || rw_agendamento.cdagedst || '</cdagedst>' ||
																'<nmcopdst>' || rw_agendamento.nmcopdst || '</nmcopdst>' ||
																'<nrctadst>' || rw_agendamento.nrctadst || '</nrctadst>' ||
																'<nmtitdst>' || rw_agendamento.nmtitdst || '</nmtitdst>' ||
                                '<dttransa>' || rw_agendamento.dttransa || '</dttransa>' ||
                                '<hrautent>' || rw_agendamento.hrtransa || '</hrautent>' ||
																'<dtmvtopg>' || rw_agendamento.dtmvtopg || '</dtmvtopg>' ||																
																'<vldocmto>' || to_char(rw_agendamento.vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||																
																'<dssituac>' || rw_agendamento.dssitlau || '</dssituac>' ||
                                '<infosac>'  ||
                                    '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                    '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                    '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                    '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                    '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                    '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                '</infosac>');
       
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Agendamento>'
                               ,pr_fecha_xml      => TRUE);      
                               
      pr_dsretorn := 'OK';                             

      EXCEPTION								
				WHEN vr_exc_erro THEN  							
					
					pr_retxml := '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN
								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_retxml :=   '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';
					          
      END;      
      
    END pc_detalhe_agendamento_trans;

  -- Pagamento
  PROCEDURE pc_detalhe_agendamento_pagam(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                        ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2) IS           --> Retorno de critica (OK ou NOK)
    BEGIN
      
    /* ................................................................................

     Programa: pc_detalhe_agendamento_pagam
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Ricardo Linhares
     Data    : Julho/17.                    Ultima atualizacao: 01/05/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento Pagamento

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfpre e nrcpfope, Prj. 285 (Jean Michel).

                 01/05/2018 - Inclusão dos campos: vr_nmpagado, vr_nrcpfpag, vr_vltitulo, vr_vlencarg,
                              vr_vldescto, vr_nrcpfben, Prj. 363 - Novo ATM. (Jean Michel).

     ..................................................................................*/       
       
     DECLARE
    
      vr_exc_erro  EXCEPTION; 
			vr_exc_leave EXCEPTION;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_des_erro VARCHAR2(4000);  
			vr_nmoperad VARCHAR2(100) := '';
      vr_idlstdom NUMBER;
			vr_info_sac COMP0002.typ_reg_info_sac;    
      
      vr_nmpagado VARCHAR2(100) := '';
      vr_nrcpfpag VARCHAR2(100) := '';
      vr_nrcpfben VARCHAR2(100) := '';
      vr_vltitulo VARCHAR2(100) := '0,00';
      vr_vlencarg VARCHAR2(100) := '0,00';
      vr_vldescto VARCHAR2(100) := '0,00';
      vr_cdbccxlt INTEGER       := 0;
      vr_nmextbcc crapban.nmextbcc%TYPE := '';

      --> Buscar dados da consulta
      CURSOR cr_cons_titulo (pr_cdctrlcs IN tbcobran_consulta_titulo.cdctrlcs%TYPE ) IS
        SELECT con.dsxml,
               con.flgcontingencia
          FROM tbcobran_consulta_titulo con
         WHERE con.cdctrlcs = pr_cdctrlcs;
             
      --Selecionar informacoes dos bancos
      CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
        SELECT crapban.nmresbcc
              ,crapban.nmextbcc
              ,crapban.cdbccxlt
        FROM crapban
        WHERE crapban.cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;
         
      rw_cons_titulo cr_cons_titulo%ROWTYPE;
      vr_tbtitulo   NPCB0001.typ_reg_TituloCIP;

      CURSOR cr_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
      SELECT cop.cdcooper
				    ,cop.cdbcoctl
            ,cop.cdagectl						
						,lau.nrdconta
						,lau.cdtiptra
						,'Pagamento' AS dstiptra			      
            ,gene0002.fn_converte_time_data(lau.hrtransa,'S') AS hrtransa
            ,lau.nrdocmto
            ,lau.insitlau
            , CASE lau.insitlau
                   WHEN 1 THEN 'Pendente'
                   WHEN 2 THEN 'Pendente'
                   WHEN 3 THEN 'Cancelado'
                   WHEN 4 THEN 'Nao Efetivado'
              END AS dssitlau
            ,lau.vllanaut
						,to_char(lau.dttransa, 'DD/MM/RRRR') AS dttransa
						,to_char(lau.dtvencto, 'DD/MM/RRRR') AS dtvencto
            ,to_char(lau.dtdebito, 'DD/MM/RRRR') AS dtdebito
						,to_char(lau.dtmvtopg, 'DD/MM/RRRR') AS dtmvtopg
						,lau.nrcpfope
            ,lau.nmprepos
            ,lau.nrcpfpre
            ,lau.dscedent
            ,nvl(lau.dslindig, '') AS dslindig
						,lau.nrseqagp
            ,lau.cdctrlcs
       FROM craplau lau
  LEFT JOIN crapcop cop
	       ON cop.cdcooper = lau.cdcooper
      WHERE lau.idlancto = pr_idlancto;
      rw_agendamento cr_agendamento%ROWTYPE;                
    
      BEGIN
				vr_nmoperad := '';				
        
        -- Busca o Lançamento
        OPEN cr_agendamento(pr_idlancto);
        FETCH cr_agendamento INTO rw_agendamento;
        
        IF cr_agendamento%notfound THEN
          CLOSE cr_agendamento;
          vr_des_erro := 'Lancamento nao encontrado';       
          RAISE vr_exc_erro; 
        END IF;     

        CLOSE cr_agendamento;
				
				-- Redireciona para pagamento de GPS
				IF rw_agendamento.nrseqagp > 0 THEN
					 pc_detalhe_age_pagto_gps(pr_idlancto => pr_idlancto
                                   ,pr_retxml   => pr_retxml
                                   ,pr_dsretorn => pr_dsretorn);
					RAISE vr_exc_leave;
				END IF;				
				
				-- Buscar dados do associado
				OPEN cr_crapass (pr_cdcooper => rw_agendamento.cdcooper,
												 pr_nrdconta => rw_agendamento.nrdconta);
				FETCH cr_crapass INTO rw_crapass;

				IF cr_crapass%NOTFOUND THEN
					CLOSE cr_crapass;								
					vr_des_erro := 'Associado nao cadastrado.';								
					RAISE vr_exc_erro;
				ELSE
					CLOSE cr_crapass;
				END IF;
								
        IF rw_agendamento.nrcpfope > 0 THEN 
					OPEN cr_crapopi(pr_cdcooper => rw_agendamento.cdcooper
												 ,pr_nrdconta => rw_agendamento.nrdconta
												 ,pr_nrcpfope => rw_agendamento.nrcpfope);

					FETCH cr_crapopi INTO rw_crapopi;

					IF cr_crapopi%FOUND THEN
						-- Fecha cursor
						CLOSE cr_crapopi;
						vr_nmoperad := nvl(rw_crapopi.nmoperad, '');
					ELSE
						-- Fecha cursor
						CLOSE cr_crapopi;
					END IF;
				END IF;
				
				vr_info_sac := COMP0002.fn_info_sac(pr_cdcooper => rw_agendamento.cdcooper);
        
        IF LENGTH(NVL(rw_agendamento.dslindig,'')) = 55 THEN
          vr_idlstdom := 2; -- Convênio
        ELSE
          vr_idlstdom := 1; -- Título
        END IF;
        
        
        IF TRIM(rw_agendamento.cdctrlcs) IS NOT NULL THEN -- Consulta na CIP
          --> Buscar dados da consulta
          OPEN cr_cons_titulo (pr_cdctrlcs => rw_agendamento.cdctrlcs);
          FETCH cr_cons_titulo INTO rw_cons_titulo;
              
          IF cr_cons_titulo%NOTFOUND THEN
            CLOSE cr_cons_titulo;
            vr_des_erro := 'Não foi possivel localizar consulta NPC ' || TO_CHAR(rw_agendamento.cdctrlcs);
            RAISE vr_exc_erro;  
          ELSE
            CLOSE cr_cons_titulo;
          END IF;

          BEGIN
            --> Rotina para retornar dados do XML para temptable
            NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => rw_cons_titulo.dsxml
                                              ,pr_tbtitulo => vr_tbtitulo
                                              ,pr_des_erro => vr_des_erro
                                              ,pr_dscritic => vr_des_erro);

            -- Se for retornado um erro
            IF vr_des_erro = 'NOK' THEN
              RAISE vr_exc_erro; 
            END IF;    

          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Erro ao validar titulo CIP: ' || TO_CHAR(rw_agendamento.cdctrlcs);
            RAISE vr_exc_erro; 
          END;

          vr_nmpagado := TRIM(vr_tbtitulo.Nom_RzSocPagdr);
          vr_nrcpfpag := TRIM(vr_tbtitulo.CNPJ_CPFPagdr);
          vr_vltitulo := TO_CHAR(vr_tbtitulo.VlrTit,'fm999g999g990d00');
          vr_vlencarg := TRIM(to_char((nvl(vr_tbtitulo.TabCalcTit(1).VlrCalcdJuros,0) + nvl(vr_tbtitulo.TabCalcTit(1).VlrCalcdMulta,0)), 'fm999g999g990d00'));
          vr_vldescto := TRIM(to_char((nvl(vr_tbtitulo.TabCalcTit(1).VlrCalcdDesct,0) + nvl(vr_tbtitulo.TabCalcTit(1).VlrCalcdAbatt,0)), 'fm999g999g990d00'));
          vr_nrcpfben := TRIM(vr_tbtitulo.CNPJ_CPFBenfcrioOr);

        ELSE
          -- Se não for boleto registrado na CIP
          vr_nmpagado := TRIM(rw_crapass.nmextttl);
          vr_nrcpfpag := TRIM(rw_crapass.nrcpfcgc);
          vr_vltitulo := to_char(rw_agendamento.vllanaut,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS=,.');
          vr_vlencarg := '0,00';
          vr_vldescto := '0,00';

        END IF;
        
        -- verificar se existe a linah digitável
        IF TRIM(rw_agendamento.dslindig) IS NOT NULL THEN
          -- Buscar o Banco
          vr_cdbccxlt:= TO_NUMBER(SUBSTR(rw_agendamento.dslindig,1,3));
          --Selecionar Banco
          OPEN cr_crapban (pr_cdbccxlt => vr_cdbccxlt);
          --Posicionar no proximo registro
          FETCH cr_crapban INTO rw_crapban;
          --Se encontrar
          IF cr_crapban%FOUND THEN
            -- Nome do Banco
            vr_nmextbcc := TRIM(rw_crapban.nmextbcc);
          END IF;
          --Fechar Cursor
          CLOSE cr_crapban;        
        END IF;
        
        
        dbms_lob.createtemporary(pr_retxml, TRUE);
        dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
         
         -- Criar cabecalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<Agendamento>');       
                               
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => '<cdtiptra>' || rw_agendamento.cdtiptra || '</cdtiptra>' ||
																'<dstiptra>' || rw_agendamento.dstiptra || '</dstiptra>' ||
																'<idlstdom>' || TO_CHAR(vr_idlstdom)    || '</idlstdom>' ||                                                                
															  '<nrdocmto>' || rw_agendamento.nrdocmto || '</nrdocmto>' ||
																'<cdbcoctl>' || rw_agendamento.cdbcoctl || '</cdbcoctl>' ||
																'<cdagectl>' || rw_agendamento.cdagectl || '</cdagectl>' ||
																'<nrdconta>' || rw_agendamento.nrdconta || '</nrdconta>' ||
																'<nmtitula>' || rw_crapass.nmextttl     || '</nmtitula>' ||
																'<nmprepos>' || rw_agendamento.nmprepos || '</nmprepos>' ||
																'<nrcpfpre>' || rw_agendamento.nrcpfpre || '</nrcpfpre>' ||
																'<nmoperad>' || vr_nmoperad             || '</nmoperad>' ||																																
																'<nrcpfope>' || rw_agendamento.nrcpfope || '</nrcpfope>' ||
																'<dscedent>' || rw_agendamento.dscedent || '</dscedent>' ||
                                '<dttransa>' || rw_agendamento.dttransa || '</dttransa>' ||
                                '<hrautent>' || rw_agendamento.hrtransa || '</hrautent>' ||
																'<dtmvtopg>' || rw_agendamento.dtmvtopg || '</dtmvtopg>' ||
																'<dtvencto>' || rw_agendamento.dtvencto || '</dtvencto>' ||
																'<vldocmto>' || to_char(rw_agendamento.vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
																'<dssituac>' || rw_agendamento.dssitlau || '</dssituac>' ||
																'<dslinhad>' || rw_agendamento.dslindig || '</dslinhad>' ||
                                                     '<nmpagado>' || TO_CHAR(vr_nmpagado)    || '</nmpagado>' ||
                                                     '<nrcpfpag>' || TO_CHAR(vr_nrcpfpag)    || '</nrcpfpag>' ||
                                                     '<vltitulo>' || TO_CHAR(vr_vltitulo)    || '</vltitulo>' ||
                                                     '<vlencarg>' || TO_CHAR(vr_vlencarg)    || '</vlencarg>' ||
                                                     '<vldescto>' || TO_CHAR(vr_vldescto)    || '</vldescto>' ||
                                                     '<nrcpfben>' || TO_CHAR(vr_nrcpfben)    || '</nrcpfben>' ||
                                                     '<cdbccxlt>' || TO_CHAR(vr_cdbccxlt) || '</cdbccxlt>' || 
                                                     '<nmextbcc>' || vr_nmextbcc     || '</nmextbcc>' || 
                                '<infosac>'  ||
                                    '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                    '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                    '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                    '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                    '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                    '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                '</infosac>');
       
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Agendamento>'
                               ,pr_fecha_xml      => TRUE);      
                               
      pr_dsretorn := 'OK';                             

      EXCEPTION								
				WHEN vr_exc_erro THEN  							
					
					pr_retxml := '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';
					
        WHEN vr_exc_leave THEN
          NULL;
						 																 
				WHEN OTHERS THEN
								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_retxml :=   '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';                              
      
      END;     
      
    END pc_detalhe_agendamento_pagam;

  -- Darf
  PROCEDURE pc_detalhe_agendamento_darf(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                       ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                       ,pr_dsretorn OUT VARCHAR2) IS           --> Retorno de critica (OK ou NOK)

    BEGIN
      
    /* ................................................................................

     Programa: pc_detalhe_agendamento_darf
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Ricardo Linhares
     Data    : Julho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento DARF

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfpre e nrcpfope, Prj. 285 (Jean Michel) 

     ..................................................................................*/       
       
     DECLARE
    
      vr_exc_erro EXCEPTION;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_des_erro VARCHAR2(4000);
			vr_nmoperad VARCHAR2(100) := '';
			vr_info_sac COMP0002.typ_reg_info_sac;
      
      CURSOR cr_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
        SELECT cop.cdcooper
				      ,cop.cdbcoctl
              ,cop.cdagectl
							,lau.nrdconta
				      ,to_char(lau.dttransa, 'DD/MM/RRRR') AS dttransa
							,to_char(lau.dtmvtopg, 'DD/MM/RRRR') AS dtmvtopg
              ,gene0002.fn_converte_time_data(lau.hrtransa,'S') AS hrtransa
              ,lau.nrdocmto
              ,lau.insitlau
              , CASE lau.insitlau
                     WHEN 1 THEN 'Pendente'
                     WHEN 2 THEN 'Pendente'
                     WHEN 3 THEN 'Cancelado'
                     WHEN 4 THEN 'Nao Efetivado'
                END AS dssituac
              ,to_char(lau.dtdebito, 'DD/MM/RRRR') AS dtdebito
              ,nvl(lau.nmprepos, '') AS nmprepos
              ,lau.nrcpfpre
							,lau.nrcpfope
              ,to_char(lau.dtvencto, 'DD/MM/RRRR') AS dtvencto
							,lau.cdtiptra
							,lau.vllanaut
							,nvl(lau.dslindig, '') AS dslindig
              ,(CASE WHEN darf.tpcaptura = 1 THEN 'COM CÓDIGO DE BARRAS' ELSE 'SEM CÓDIGO DE BARRAS' END) AS dstipcap
              ,darf.dsidentif_pagto AS dsdpagto
              ,darf.dsnome_fone AS dsnomfon 
              ,to_char(darf.dtapuracao, 'DD/MM/RRRR') AS dtapurac
              ,darf.cdtributo AS cdreceit
              ,darf.nrrefere AS nrrefere
              ,darf.nrcpfcgc AS nrcpfcgc						
              ,darf.vlprincipal AS vlprinci 
              ,darf.vlmulta AS vlrmulta
              ,darf.vljuros AS vlrjuros
							,to_char(darf.dtvencto, 'DD/MM/RRRR') AS darf_dtvencto
              ,NVL(darf.vlprincipal,0) + NVL(darf.vlmulta,0) + NVL(darf.vljuros,0) AS vlrtotal
							,(CASE WHEN darf.tppagamento = 1 THEN 'DARF' ELSE 'DAS' END) AS dstiptra
              ,darf.vlreceita_bruta AS vlrrecbr
              ,darf.vlpercentual AS vlrperce
							,darf.tpcaptura
         FROM craplau lau
    LEFT JOIN tbpagto_agend_darf_das darf
           ON darf.idlancto = lau.idlancto
	  LEFT JOIN crapcop cop
		       ON cop.cdcooper = lau.cdcooper
        WHERE lau.idlancto = pr_idlancto;
      rw_agendamento cr_agendamento%ROWTYPE;                
    
      BEGIN

        vr_nmoperad := '';							

        -- Busca o Lançamento
        OPEN cr_agendamento(pr_idlancto);
        FETCH cr_agendamento INTO rw_agendamento;
        
        IF cr_agendamento%notfound THEN
          CLOSE cr_agendamento;
          vr_des_erro := 'Lancamento nao encontrado';
          RAISE vr_exc_erro; 
        END IF;     

        CLOSE cr_agendamento;
				
				-- Buscar dados do associado
				OPEN cr_crapass (pr_cdcooper => rw_agendamento.cdcooper,
												 pr_nrdconta => rw_agendamento.nrdconta);
				FETCH cr_crapass INTO rw_crapass;

				IF cr_crapass%NOTFOUND THEN
					CLOSE cr_crapass;								
					vr_des_erro := 'Associado nao cadastrado.';								
					RAISE vr_exc_erro;
				ELSE
					CLOSE cr_crapass;
				END IF;
								
        IF rw_agendamento.nrcpfope > 0 THEN 
					OPEN cr_crapopi(pr_cdcooper => rw_agendamento.cdcooper
												 ,pr_nrdconta => rw_agendamento.nrdconta
												 ,pr_nrcpfope => rw_agendamento.nrcpfope);

					FETCH cr_crapopi INTO rw_crapopi;

					IF cr_crapopi%FOUND THEN
						-- Fecha cursor
						CLOSE cr_crapopi;
						vr_nmoperad := nvl(rw_crapopi.nmoperad, '');
					ELSE
						-- Fecha cursor
						CLOSE cr_crapopi;
					END IF;
				END IF;
				
				vr_info_sac := COMP0002.fn_info_sac(pr_cdcooper => rw_agendamento.cdcooper);
        
        dbms_lob.createtemporary(pr_retxml, TRUE);
        dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
         
         -- Criar cabecalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<Agendamento>');       
                               
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
															  '<cdtiptra>' || rw_agendamento.cdtiptra || '</cdtiptra>' ||
																'<dstiptra>' || rw_agendamento.dstiptra || '</dstiptra>' ||
																'<idlstdom>7</idlstdom>'                                 ||
															  '<nrdocmto>' || rw_agendamento.nrdocmto || '</nrdocmto>' ||
																'<cdbcoctl>' || rw_agendamento.cdbcoctl || '</cdbcoctl>' ||
																'<cdagectl>' || rw_agendamento.cdagectl || '</cdagectl>' ||
																'<nrdconta>' || rw_agendamento.nrdconta || '</nrdconta>' ||
																'<nmtitula>' || rw_crapass.nmextttl     || '</nmtitula>' ||
																'<nmprepos>' || rw_agendamento.nmprepos || '</nmprepos>' ||
                                '<nrcpfpre>' || rw_agendamento.nrcpfpre || '</nrcpfpre>' ||
																'<nmoperad>' || vr_nmoperad             || '</nmoperad>' ||																
                                '<nrcpfope>' || rw_agendamento.nrcpfope || '</nrcpfope>' ||
                                '<dttransa>' || rw_agendamento.dttransa || '</dttransa>' ||
                                '<hrautent>' || rw_agendamento.hrtransa || '</hrautent>' ||
																'<dtmvtopg>' || rw_agendamento.dtmvtopg || '</dtmvtopg>' ||
																'<dssituac>' || rw_agendamento.dssituac || '</dssituac>' ||
																'<dstipcap>' || rw_agendamento.dstipcap || '</dstipcap>');
																
															  IF rw_agendamento.tpcaptura = 1 THEN																																														
																	gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																												 ,pr_texto_completo => vr_xml_temp      
																												 ,pr_texto_novo     => 
																                          '<dslinhad>' || rw_agendamento.dslindig || '</dslinhad>');
															  END IF;
																
				gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 												
																'<dsnomfon>' || rw_agendamento.dsnomfon || '</dsnomfon>' ||
																'<dsdpagto>' || rw_agendamento.dsdpagto || '</dsdpagto>');
																
																IF rw_agendamento.tpcaptura = 2 THEN																																	
																	gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																												 ,pr_texto_completo => vr_xml_temp      
																												 ,pr_texto_novo     => 																
																													'<dtapurac>' || rw_agendamento.dtapurac || '</dtapurac>' ||
																													'<nrcpfcgc>' || rw_agendamento.nrcpfcgc || '</nrcpfcgc>' ||																
																													'<cdtribut>' || rw_agendamento.cdreceit || '</cdtribut>' ||
																													'<nrrefere>' || rw_agendamento.nrrefere || '</nrrefere>' ||
																													'<dtvencto>' || rw_agendamento.darf_dtvencto || '</dtvencto>' ||
																													'<vlrecbru>' || rw_agendamento.vlrrecbr || '</vlrecbru>' ||
																													'<vlpercen>' || rw_agendamento.vlrperce || '</vlpercen>' ||   
																													'<vlprinci>' || rw_agendamento.vlprinci || '</vlprinci>' ||
																													'<vlrmulta>' || rw_agendamento.vlrmulta || '</vlrmulta>' ||
																													'<vlrjuros>' || rw_agendamento.vlrjuros || '</vlrjuros>');																				
															  END IF;
				
				gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 																
																'<vldocmto>' || to_char(rw_agendamento.vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||																
																'<infosac>'  ||
																		'<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
																		'<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
																		'<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
																		'<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
																		'<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
																		'<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
																'</infosac>');
																
       
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Agendamento>'
                               ,pr_fecha_xml      => TRUE);      
                               
      pr_dsretorn := 'OK';                             

      EXCEPTION								
				WHEN vr_exc_erro THEN  							
					
					pr_retxml := '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN
								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_retxml :=   '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';                             
      
    END;  
      
    END pc_detalhe_agendamento_darf;

	-- Pagamento GPS
  PROCEDURE pc_detalhe_age_pagto_gps(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                    ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2) IS           --> Retorno de critica (OK ou NOK)
    BEGIN
      
    /* ................................................................................

     Programa: pc_detalhe_age_pagto_gps
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Lucas Lunelli
     Data    : Set/2017.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento Pagamento GPS

     Observacao: -----

     Alteracoes: 

     ..................................................................................*/       
       
     DECLARE
    
      vr_exc_erro EXCEPTION;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_des_erro VARCHAR2(4000);  
			vr_nmoperad VARCHAR2(100) := '';
			vr_info_sac COMP0002.typ_reg_info_sac;    
      
      CURSOR cr_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
      SELECT cop.cdcooper
				    ,cop.cdbcoctl
            ,cop.cdagectl						
						,lau.nrdconta
						,lau.cdtiptra
						,'Pagamento' AS dstiptra			      
            ,gene0002.fn_converte_time_data(lau.hrtransa,'S') AS hrtransa
            ,lau.nrdocmto
            ,lau.insitlau
            , CASE lau.insitlau
                   WHEN 1 THEN 'Pendente'
                   WHEN 2 THEN 'Pendente'
                   WHEN 3 THEN 'Cancelado'
                   WHEN 4 THEN 'Nao Efetivado'
              END AS dssitlau
            ,lau.vllanaut
						,to_char(lau.dttransa, 'DD/MM/RRRR') AS dttransa
						,to_char(lau.dtvencto, 'DD/MM/RRRR') AS dtvencto
            ,to_char(lau.dtdebito, 'DD/MM/RRRR') AS dtdebito
						,to_char(lau.dtmvtopg, 'DD/MM/RRRR') AS dtmvtopg
						,lau.nrcpfope
            ,lau.nmprepos
            ,lau.nrcpfpre
            ,lau.dscedent
            ,nvl(lau.dslindig, '') AS dslindig						
						,TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, pro.dsinform##3, '#')), ':')) cddpagto
            ,TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, pro.dsinform##3, '#')), ':')) dscompet
            ,TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, pro.dsinform##3, '#')), ':')) cdidenti              
            ,TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, pro.dsinform##3, '#')), ':')) vlrdinss
            ,TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, pro.dsinform##3, '#')), ':')) vlrouent
            ,TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, pro.dsinform##3, '#')), ':')) vlrjuros						
       FROM craplau lau
  LEFT JOIN crapcop cop
	       ON cop.cdcooper = lau.cdcooper
	LEFT JOIN crappro pro
				 ON pro.cdcooper = lau.cdcooper
				AND pro.nrdconta = lau.nrdconta
				AND pro.nrseqaut = lau.nrseqagp
				AND pro.dtmvtolt = lau.dtmvtolt
				AND pro.cdtippro = 13 -- GPS	 
      WHERE lau.idlancto = pr_idlancto;
      rw_agendamento cr_agendamento%ROWTYPE;                
    
      BEGIN
				vr_nmoperad := '';				
        
        -- Busca o Lançamento
        OPEN cr_agendamento(pr_idlancto);
        FETCH cr_agendamento INTO rw_agendamento;
        
        IF cr_agendamento%notfound THEN
          CLOSE cr_agendamento;
          vr_des_erro := 'Lancamento nao encontrado';       
          RAISE vr_exc_erro; 
        END IF;     

        CLOSE cr_agendamento;
				
				-- Buscar dados do associado
				OPEN cr_crapass (pr_cdcooper => rw_agendamento.cdcooper,
												 pr_nrdconta => rw_agendamento.nrdconta);
				FETCH cr_crapass INTO rw_crapass;

				IF cr_crapass%NOTFOUND THEN
					CLOSE cr_crapass;								
					vr_des_erro := 'Associado nao cadastrado.';								
					RAISE vr_exc_erro;
				ELSE
					CLOSE cr_crapass;
				END IF;
								
        IF rw_agendamento.nrcpfope > 0 THEN 
					OPEN cr_crapopi(pr_cdcooper => rw_agendamento.cdcooper
												 ,pr_nrdconta => rw_agendamento.nrdconta
												 ,pr_nrcpfope => rw_agendamento.nrcpfope);

					FETCH cr_crapopi INTO rw_crapopi;

					IF cr_crapopi%FOUND THEN
						-- Fecha cursor
						CLOSE cr_crapopi;
						vr_nmoperad := nvl(rw_crapopi.nmoperad, '');
					ELSE
						-- Fecha cursor
						CLOSE cr_crapopi;
					END IF;
				END IF;
				
				vr_info_sac := COMP0002.fn_info_sac(pr_cdcooper => rw_agendamento.cdcooper);
        
        dbms_lob.createtemporary(pr_retxml, TRUE);
        dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
         
         -- Criar cabecalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<Agendamento>');       
                               
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
															  '<cdtiptra>' || rw_agendamento.cdtiptra || '</cdtiptra>'  ||
																'<dstiptra>' || rw_agendamento.dstiptra || '</dstiptra>'  ||
   															'<idlstdom>9</idlstdom>'                                  ||                                
															  '<nrdocmto>' || rw_agendamento.nrdocmto || '</nrdocmto>'  ||
																'<cdbcoctl>' || rw_agendamento.cdbcoctl || '</cdbcoctl>'  ||
																'<cdagectl>' || rw_agendamento.cdagectl || '</cdagectl>'  ||
																'<nrdconta>' || rw_agendamento.nrdconta || '</nrdconta>'  ||
																'<nmtitula>' || rw_crapass.nmextttl     || '</nmtitula>'  ||
																'<nmprepos>' || rw_agendamento.nmprepos || '</nmprepos>'  ||
                                '<nrcpfpre>' || rw_agendamento.nrcpfpre || '</nrcpfpre>'  ||
																'<nmoperad>' || vr_nmoperad             || '</nmoperad>'  ||																																
																'<nrcpfope>' || rw_agendamento.nrcpfope || '</nrcpfope>'  ||
                                '<dscedent>' || rw_agendamento.dscedent || '</dscedent>'  ||
																'<dslinhad>' || rw_agendamento.dslindig || '</dslinhad>'  ||																																
																'<cdpagmto>' || rw_agendamento.cddpagto || '</cdpagmto>'  ||
																'<dtcompet>' || rw_agendamento.dscompet || '</dtcompet>'  ||
																'<dsidenti>' || rw_agendamento.cdidenti || '</dsidenti>'  ||
																'<vldoinss>' || rw_agendamento.vlrdinss || '</vldoinss>'  ||
																'<vloutent>' || rw_agendamento.vlrouent || '</vloutent>'  ||
																'<vlatmjur>' || rw_agendamento.vlrjuros || '</vlatmjur>'  ||																																																																																
                                '<dttransa>' || rw_agendamento.dttransa || '</dttransa>'  ||																
                                '<hrautent>' || rw_agendamento.hrtransa || '</hrautent>'  ||
																'<dtmvtopg>' || rw_agendamento.dtmvtopg || '</dtmvtopg>'  ||																
																'<dtvencto>' || rw_agendamento.dtvencto || '</dtvencto>'  ||																												
																'<vldocmto>' || to_char(rw_agendamento.vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
																'<dssituac>' || rw_agendamento.dssitlau || '</dssituac>'  ||																
                                '<infosac>'  ||
                                    '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                    '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                    '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                    '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                    '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                    '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                '</infosac>');
       
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Agendamento>'
                               ,pr_fecha_xml      => TRUE);      
                               
      pr_dsretorn := 'OK';                             

      EXCEPTION								
				WHEN vr_exc_erro THEN  							
					
					pr_retxml := '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN
								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_retxml :=   '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';                              
      
      END;
	END pc_detalhe_age_pagto_gps;
	
	PROCEDURE pc_detalhe_age_recarga_cel(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                      ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                      ,pr_dsretorn OUT VARCHAR2) IS           --> Retorno de critica (OK ou NOK)
    BEGIN
      
    /* ................................................................................

     Programa: pc_detalhe_age_recarga_cel
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Lucas Lunelli
     Data    : Set/2017.                    Ultima atualizacao: 18/10/2017 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento de Recarga de Celular

     Observacao: -----

     Alteracoes: Inclusçao dos campos nrcpfpre e nrcpfope, Prj. 285 (Jean Michel)

     ..................................................................................*/       
       
     DECLARE
    
      vr_exc_erro EXCEPTION;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_des_erro VARCHAR2(4000);  
			vr_info_sac COMP0002.typ_reg_info_sac;    
      
      CURSOR cr_agendamento(pr_idoperacao IN craplau.idlancto%TYPE) IS
				SELECT cop.cdcooper
							,cop.cdbcoctl
							,cop.cdagectl
							,opc.nrdconta
							,opc.idoperacao
							,opc.dtrecarga AS dtmvtopg
							,opc.dttransa
							,to_char(opc.vlrecarga,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') AS vldocmto
							,opc.insit_operacao
							,'20' AS cdtiptra
							,'Recarga de celular' AS dstiptra
							,(CASE WHEN opc.insit_operacao = 1 THEN 'Pendente'
										 WHEN opc.insit_operacao = 4 THEN 'Cancelado'
										 ELSE 'Nao efetivado'
							 END) dssitlau
							,(CASE WHEN opc.insit_operacao = 1 THEN 1
										 ELSE 2
							 END) incancel
							,opc.nrddd 
							,opc.nrcelular
							,opa.nmoperadora
							,opc.nrddd AS nrdddtel
              ,opc.nrcelular AS nrtelefo
							,to_char(opc.dttransa,'hh24:mi:ss') AS hrautent
					FROM tbrecarga_operacao opc
		 LEFT JOIN crapcop cop
					  ON cop.cdcooper = opc.cdcooper
		 LEFT JOIN tbrecarga_operadora opa			 
					  ON opa.cdoperadora = opc.cdoperadora
				 WHERE opc.idoperacao = pr_idoperacao;
      rw_agendamento cr_agendamento%ROWTYPE;                
    
      BEGIN
        -- Busca o Lançamento
        OPEN cr_agendamento(pr_idlancto);
        FETCH cr_agendamento INTO rw_agendamento;
        
        IF cr_agendamento%notfound THEN
          CLOSE cr_agendamento;
          vr_des_erro := 'Lancamento nao encontrado';       
          RAISE vr_exc_erro; 
        END IF;     

        CLOSE cr_agendamento;
				
				-- Buscar dados do associado
				OPEN cr_crapass (pr_cdcooper => rw_agendamento.cdcooper,
												 pr_nrdconta => rw_agendamento.nrdconta);
				FETCH cr_crapass INTO rw_crapass;

				IF cr_crapass%NOTFOUND THEN
					CLOSE cr_crapass;								
					vr_des_erro := 'Associado nao cadastrado.';								
					RAISE vr_exc_erro;
				ELSE
					CLOSE cr_crapass;
				END IF;
																
				vr_info_sac := COMP0002.fn_info_sac(pr_cdcooper => rw_agendamento.cdcooper);
        
        dbms_lob.createtemporary(pr_retxml, TRUE);
        dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
         
         -- Criar cabecalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<Agendamento>');       
                           
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
															  '<cdtiptra>' || rw_agendamento.cdtiptra         || '</cdtiptra>'  ||
																'<dstiptra>' || rw_agendamento.dstiptra || '</dstiptra>'  ||
   															'<idlstdom>20</idlstdom>'                                  ||                                                                
															  '<nrdocmto>' || rw_agendamento.idoperacao || '</nrdocmto>'  ||
																'<cdbcoctl>' || rw_agendamento.cdbcoctl || '</cdbcoctl>'  ||
																'<cdagectl>' || rw_agendamento.cdagectl || '</cdagectl>'  ||
																'<nrdconta>' || rw_agendamento.nrdconta || '</nrdconta>'  ||
																'<nmtitula>' || rw_crapass.nmextttl     || '</nmtitula>'  ||
																'<nmprepos></nmprepos>'  ||
																'<nrcpfpre></nrcpfpre>'  ||
																'<nmoperad></nmoperad>'  ||																
																'<nrcpfope></nrcpfope>'  ||
																'<nmopetel>' || rw_agendamento.nmoperadora || '</nmopetel>'  ||
																'<nrdddtel>' || rw_agendamento.nrdddtel || '</nrdddtel>'  ||
                                '<nrtelefo>' || rw_agendamento.nrtelefo || '</nrtelefo>'  ||
                                '<dttransa>' || TO_CHAR(rw_agendamento.dttransa,'DD/MM/RRRR') || '</dttransa>'  ||																
                                '<hrautent>' || rw_agendamento.hrautent || '</hrautent>'  ||
																'<dtmvtopg>' || TO_CHAR(rw_agendamento.dtmvtopg,'DD/MM/RRRR') || '</dtmvtopg>'  ||																
																'<vldocmto>' || rw_agendamento.vldocmto || '</vldocmto>' ||
																'<dssituac>' || rw_agendamento.dssitlau || '</dssituac>'  ||																
                                '<infosac>'  ||
                                    '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                    '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                    '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                    '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                    '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                    '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                '</infosac>');
       
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Agendamento>'
                               ,pr_fecha_xml      => TRUE);      
                               
      pr_dsretorn := 'OK';                             

      EXCEPTION								
				WHEN vr_exc_erro THEN  							
					
					pr_retxml := '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN
								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_retxml :=   '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';                              
      
      END;
	END pc_detalhe_age_recarga_cel;
    
  -- FGTS
  PROCEDURE pc_detalhe_agendamento_FGTS(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                       ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                       ,pr_dsretorn OUT VARCHAR2) IS           --> Retorno de critica (OK ou NOK)  
      
    /* ................................................................................

     Programa: pc_detalhe_agendamento_FGTS
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Odirlei Busana - AMcom
     Data    : Janeiro/2018.                    Ultima atualizacao: 03/01/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento FGTS

     Observacao: -----

     Alteracoes: 

    ..................................................................................*/              
    
    vr_exc_erro EXCEPTION;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_nmoperad VARCHAR2(100) := '';
    vr_des_erro VARCHAR2(4000);        
    vr_info_sac COMP0002.typ_reg_info_sac;
      
    CURSOR cr_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
       SELECT  cop.cdcooper
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,lau.nrdconta
              ,to_char(lau.dttransa, 'DD/MM/RRRR') AS dttransa
              ,to_char(lau.dtmvtopg, 'DD/MM/RRRR') AS dtmvtopg
              ,gene0002.fn_converte_time_data(lau.hrtransa,'S') AS hrtransa
              ,lau.nrdocmto
              ,lau.dscodbar
              ,lau.insitlau              
              , CASE lau.insitlau
                     WHEN 1 THEN 'Pendente'
                     WHEN 2 THEN 'Pendente'
                     WHEN 3 THEN 'Cancelado'
                     WHEN 4 THEN 'Nao Efetivado'
                END AS dssituac
              ,to_char(lau.dtdebito, 'DD/MM/RRRR') AS dtdebito
              ,nvl(lau.nmprepos, '') AS nmprepos 
              ,lau.nrcpfpre               
              ,lau.nrcpfope
              ,to_char(lau.dtvencto, 'DD/MM/RRRR') AS dtvencto
              ,lau.cdtiptra
              ,lau.vllanaut
              ,nvl(lau.dslindig, '') AS dslindig
              ,(CASE WHEN trib.tpleitura_docto = 1 THEN 'COM CÓDIGO DE BARRAS' ELSE 'SEM CÓDIGO DE BARRAS' END) AS dstipcap
              ,(CASE trib.tppagamento 
                  WHEN  3 THEN 'Agendamento de FGTS' 
                  WHEN  4 THEN 'Agendamento de DAE' 
                  ELSE '' 
                END) AS dstiptra
              ,trib.dsidenti_pagto AS dsdpagto
              ,trib.tpleitura_docto
              ,to_char(trib.dtcompetencia, 'MM/RRRR') AS dtapuracao
              ,trib.cdtributo
              ,trib.nridentificacao
              ,trib.nridentificador
              ,trib.nrseqgrde
         FROM craplau lau
    LEFT JOIN tbpagto_agend_tributos trib
           ON trib.idlancto = lau.idlancto
    LEFT JOIN crapcop cop
         ON cop.cdcooper = lau.cdcooper
        WHERE lau.idlancto = pr_idlancto;

    rw_agendamento cr_agendamento%ROWTYPE;
    
    --> Buscar nome do convenio
    CURSOR cr_crapcon( pr_cdempcon crapcon.cdempcon%TYPE,
                       pr_cdsegmto crapcon.cdsegmto%TYPE) IS 
      SELECT con.nmextcon
        FROM crapcon con
       WHERE con.cdempcon = pr_cdempcon
         AND con.cdsegmto = pr_cdsegmto;   
    rw_crapcon cr_crapcon%ROWTYPE;  
    
  BEGIN
    vr_nmoperad := '';
												
    -- Busca o Lançamento
    OPEN cr_agendamento(pr_idlancto);
    FETCH cr_agendamento INTO rw_agendamento;
        
    IF cr_agendamento%notfound THEN
      CLOSE cr_agendamento;
      vr_des_erro := 'Lancamento nao encontrado';
      RAISE vr_exc_erro;         
    END IF;     

    CLOSE cr_agendamento;
				
    -- Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => rw_agendamento.cdcooper,
                     pr_nrdconta => rw_agendamento.nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;								
      vr_des_erro := 'Associado nao cadastrado.';								
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
								
    IF rw_agendamento.nrcpfope > 0 THEN 
      OPEN cr_crapopi(pr_cdcooper => rw_agendamento.cdcooper
                     ,pr_nrdconta => rw_agendamento.nrdconta
                     ,pr_nrcpfope => rw_agendamento.nrcpfope);

      FETCH cr_crapopi INTO rw_crapopi;

      IF cr_crapopi%FOUND THEN
        -- Fecha cursor
        CLOSE cr_crapopi;
        vr_nmoperad := nvl(rw_crapopi.nmoperad, '');
      ELSE
        -- Fecha cursor
        CLOSE cr_crapopi;
      END IF;
    END IF;
    
    
    --> Buscar nome do convenio
    rw_crapcon := NULL;
    OPEN cr_crapcon( pr_cdempcon => rw_agendamento.cdtributo,
                     pr_cdsegmto => SUBSTR(rw_agendamento.dscodbar, 2,1));
				
    FETCH cr_crapcon INTO rw_crapcon;
    CLOSE cr_crapcon;
    
    vr_info_sac := COMP0002.fn_info_sac(pr_cdcooper => rw_agendamento.cdcooper);
        
    dbms_lob.createtemporary(pr_retxml, TRUE);
    dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
         
     -- Criar cabecalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<Agendamento>');       
                               
    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<cdtiptra>'     || rw_agendamento.cdtiptra                     || '</cdtiptra>' ||
                                                 '<dstiptra>'     || rw_agendamento.dstiptra                     || '</dstiptra>' ||
                                                 '<idlstdom>'     || '10'                                        || '</idlstdom>' ||
                                                 '<nrdocmto>'     || rw_agendamento.nrdocmto                     || '</nrdocmto>' ||
                                                 '<cdbcoctl>'     || rw_agendamento.cdbcoctl                     || '</cdbcoctl>' ||
                                                 '<cdagectl>'     || rw_agendamento.cdagectl                     || '</cdagectl>' ||
                                                 '<nrdconta>'     || rw_agendamento.nrdconta                     || '</nrdconta>' ||
                                                 '<nmtitula>'     || rw_crapass.nmextttl                         || '</nmtitula>' ||
                                                 '<nmprepos>'     || rw_agendamento.nmprepos                     || '</nmprepos>' ||
                                                 '<nrcpfpre>'     || rw_agendamento.nrcpfpre                     || '</nrcpfpre>' ||
                                                 '<nmoperad>'     || vr_nmoperad                                 || '</nmoperad>' ||
                                                 '<dstipdoc>'     || rw_crapcon.nmextcon                         || '</dstipdoc>' ||
                                                 '<cdbarras>'     || rw_agendamento.dscodbar                     || '</cdbarras>' || 
                                                 '<dslinhad>'     || rw_agendamento.dslindig                     || '</dslinhad>' ||
                                                 '<nridentificacao>' || rw_agendamento.nridentificacao           || '</nridentificacao>' ||
                                                 '<cdempcon>'     || rw_agendamento.cdtributo                    || '</cdempcon>'     || 
                                                 '<dtvencto>'     || rw_agendamento.dtvencto                     || '</dtvencto>'     || 
                                                 '<competencia>'  || rw_agendamento.dtapuracao                   || '</competencia>'  || 
                                                 '<nrseqgrde>'    || rw_agendamento.nrseqgrde                    || '</nrseqgrde>'    || 
                                                 '<identificador>'|| rw_agendamento.nridentificador              || '</identificador>'|| 
                                                 '<dsdpagto>'     || rw_agendamento.dsdpagto                     || '</dsdpagto>'     ||
                                                 '<dttransa>'     || rw_agendamento.dttransa                     || '</dttransa>' ||
                                                 '<hrautent>'     || rw_agendamento.hrtransa 	                   || '</hrautent>' ||
                                                 '<dtmvtopg>'     || rw_agendamento.dtmvtopg                     || '</dtmvtopg>' ||
                                                 '<dssituac>'     || rw_agendamento.dssituac                     || '</dssituac>' );


    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<vldocmto>' || to_char(rw_agendamento.vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||                                
                            '<infosac>'  ||
                                '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                            '</infosac>');
       
    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Agendamento>'
                           ,pr_fecha_xml      => TRUE);
                               
    pr_dsretorn := 'OK';                             

  EXCEPTION								
    WHEN vr_exc_erro THEN  							
					
      pr_retxml := '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';
																 
    WHEN OTHERS THEN
								
      vr_des_erro := 'Erro ao criar XML(FGTS): ' || SQLERRM;
      pr_retxml :=   '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';                               
        
      
  END pc_detalhe_agendamento_FGTS;
		
    
  -- DAE
  PROCEDURE pc_detalhe_agendamento_DAE( pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                       ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                       ,pr_dsretorn OUT VARCHAR2) IS           --> Retorno de critica (OK ou NOK)  
      
    /* ................................................................................

     Programa: pc_detalhe_agendamento_DAE
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Odirlei Busana - AMcom
     Data    : Janeiro/2018.                    Ultima atualizacao: 03/01/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento DAE

     Observacao: -----

     Alteracoes: 

    ..................................................................................*/              
    
    vr_exc_erro EXCEPTION;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_nmoperad VARCHAR2(100) := '';
    vr_des_erro VARCHAR2(4000);        
    vr_info_sac COMP0002.typ_reg_info_sac;
      
    CURSOR cr_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
       SELECT  cop.cdcooper
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,lau.nrdconta
              ,to_char(lau.dttransa, 'DD/MM/RRRR') AS dttransa
              ,to_char(lau.dtmvtopg, 'DD/MM/RRRR') AS dtmvtopg
              ,gene0002.fn_converte_time_data(lau.hrtransa,'S') AS hrtransa
              ,lau.nrdocmto
              ,lau.dscodbar
              ,lau.insitlau              
              , CASE lau.insitlau
                     WHEN 1 THEN 'Pendente'
                     WHEN 2 THEN 'Pendente'
                     WHEN 3 THEN 'Cancelado'
                     WHEN 4 THEN 'Nao Efetivado'
                END AS dssituac
              ,to_char(lau.dtdebito, 'DD/MM/RRRR') AS dtdebito
              ,nvl(lau.nmprepos, '') AS nmprepos 
              ,lau.nrcpfpre               
              ,lau.nrcpfope
              ,to_char(lau.dtvencto, 'DD/MM/RRRR') AS dtvencto
              ,lau.cdtiptra
              ,lau.vllanaut
              ,nvl(lau.dslindig, '') AS dslindig
              ,(CASE WHEN trib.tpleitura_docto = 1 THEN 'COM CÓDIGO DE BARRAS' ELSE 'SEM CÓDIGO DE BARRAS' END) AS dstipcap
              ,(CASE trib.tppagamento 
                  WHEN  3 THEN 'Agendamento de FGTS' 
                  WHEN  4 THEN 'Agendamento de DAE' 
                  ELSE '' 
                END) AS dstiptra
              ,trib.dsidenti_pagto AS dsdpagto
              ,trib.tpleitura_docto
              ,to_char(trib.dtcompetencia, 'DD/MM/RRRR') AS dtapuracao
              ,trib.cdtributo
              ,trib.nridentificacao
              ,trib.nridentificador
              ,trib.nrseqgrde
         FROM craplau lau
    LEFT JOIN tbpagto_agend_tributos trib
           ON trib.idlancto = lau.idlancto
    LEFT JOIN crapcop cop
         ON cop.cdcooper = lau.cdcooper
        WHERE lau.idlancto = pr_idlancto;

    rw_agendamento cr_agendamento%ROWTYPE;
    
    --> Buscar nome do convenio
    CURSOR cr_crapcon( pr_cdempcon crapcon.cdempcon%TYPE,
                       pr_cdsegmto crapcon.cdsegmto%TYPE) IS 
      SELECT con.nmextcon
        FROM crapcon con
       WHERE con.cdempcon = pr_cdempcon
         AND con.cdsegmto = pr_cdsegmto;   
    rw_crapcon cr_crapcon%ROWTYPE;  
    
  BEGIN
    vr_nmoperad := '';
												
    -- Busca o Lançamento
    OPEN cr_agendamento(pr_idlancto);
    FETCH cr_agendamento INTO rw_agendamento;
        
    IF cr_agendamento%notfound THEN
      CLOSE cr_agendamento;
      vr_des_erro := 'Lancamento nao encontrado';
      RAISE vr_exc_erro;         
    END IF;     

    CLOSE cr_agendamento;
				
    -- Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => rw_agendamento.cdcooper,
                     pr_nrdconta => rw_agendamento.nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;								
      vr_des_erro := 'Associado nao cadastrado.';								
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
								
    IF rw_agendamento.nrcpfope > 0 THEN 
      OPEN cr_crapopi(pr_cdcooper => rw_agendamento.cdcooper
                     ,pr_nrdconta => rw_agendamento.nrdconta
                     ,pr_nrcpfope => rw_agendamento.nrcpfope);

      FETCH cr_crapopi INTO rw_crapopi;

      IF cr_crapopi%FOUND THEN
        -- Fecha cursor
        CLOSE cr_crapopi;
        vr_nmoperad := nvl(rw_crapopi.nmoperad, '');
      ELSE
        -- Fecha cursor
        CLOSE cr_crapopi;
      END IF;
    END IF;
    
    
    --> Buscar nome do convenio
    rw_crapcon := NULL;
    OPEN cr_crapcon( pr_cdempcon => rw_agendamento.cdtributo,
                     pr_cdsegmto => SUBSTR(rw_agendamento.dscodbar, 2,1));
				
    FETCH cr_crapcon INTO rw_crapcon;
    CLOSE cr_crapcon;
    
    vr_info_sac := COMP0002.fn_info_sac(pr_cdcooper => rw_agendamento.cdcooper);
        
    dbms_lob.createtemporary(pr_retxml, TRUE);
    dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
         
     -- Criar cabecalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<Agendamento>');       
                               
    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<cdtiptra>'     || rw_agendamento.cdtiptra                     || '</cdtiptra>' ||
                                                 '<dstiptra>'     || rw_agendamento.dstiptra                     || '</dstiptra>' ||
                                                 '<idlstdom>'     || '11'                                          || '</idlstdom>' ||
                                                 '<nrdocmto>'     || rw_agendamento.nrdocmto                     || '</nrdocmto>' ||
                                                 '<cdbcoctl>'     || rw_agendamento.cdbcoctl                     || '</cdbcoctl>' ||
                                                 '<cdagectl>'     || rw_agendamento.cdagectl                     || '</cdagectl>' ||
                                                 '<nrdconta>'     || rw_agendamento.nrdconta                     || '</nrdconta>' ||
                                                 '<nmtitula>'     || rw_crapass.nmextttl                         || '</nmtitula>' ||
                                                 '<nmprepos>'     || rw_agendamento.nmprepos                     || '</nmprepos>' ||
                                                 '<nrcpfpre>'     || rw_agendamento.nrcpfpre                     || '</nrcpfpre>' ||
                                                 '<nmoperad>'     || vr_nmoperad                                 || '</nmoperad>' ||
                                                 '<dstipdoc>'     || rw_crapcon.nmextcon                         || '</dstipdoc>' ||
                                                 '<cdbarras>'     || rw_agendamento.dscodbar                     || '</cdbarras>' || 
                                                 '<dslinhad>'     || rw_agendamento.dslindig                     || '</dslinhad>' ||
                                                 '<nrdocdae>'     || rw_agendamento.nridentificador              || '</nrdocdae>' ||
                                                 '<dsdpagto>'     || rw_agendamento.dsdpagto                     || '</dsdpagto>' ||
                                                 '<dttransa>'     || rw_agendamento.dttransa                     || '</dttransa>' ||
                                                 '<hrautent>'     || rw_agendamento.hrtransa 	                   || '</hrautent>' ||
                                                 '<dtmvtopg>'     || rw_agendamento.dtmvtopg                     || '</dtmvtopg>' ||
                                                 '<dssituac>'     || rw_agendamento.dssituac                     || '</dssituac>' );


    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<vldocmto>' || to_char(rw_agendamento.vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||                                
                            '<infosac>'  ||
                                '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                            '</infosac>');
       
    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Agendamento>'
                           ,pr_fecha_xml      => TRUE);
                               
    pr_dsretorn := 'OK';                             

  EXCEPTION								
    WHEN vr_exc_erro THEN  							
					
      pr_retxml := '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';
																 
    WHEN OTHERS THEN
								
      vr_des_erro := 'Erro ao criar XML(DAE): ' || SQLERRM;
      pr_retxml :=   '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
      pr_dsretorn := 'NOK';                               
        
      
  END pc_detalhe_agendamento_DAE;
		
  PROCEDURE pc_detalhe_agendamento (pr_cdtiptra  IN craplau.cdtiptra%TYPE  --> Tipo do Agendamento
                                   ,pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                   ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                   ,pr_dsretorn OUT VARCHAR2) IS             --> Retorno de critica (OK ou NOK)

   BEGIN    
     
/* ................................................................................

     Programa: pc_detalhe_agendamento
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Ricardo Linhares
     Data    : Julho/17.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento

     Observacao: -----

     Alteracoes: 

     ..................................................................................*/          
 
     CASE 
       WHEN pr_cdtiptra = 1 OR pr_cdtiptra = 3 OR pr_cdtiptra = 5 THEN -- Transferência Intra e Intercooperativa ou Crédito Salário
         pc_detalhe_agendamento_trans(pr_idlancto => pr_idlancto
                                     ,pr_retxml   => pr_retxml
                                     ,pr_dsretorn => pr_dsretorn);
       WHEN pr_cdtiptra = 2 THEN -- Pagamento (Conv/Boleto e GPS)
         pc_detalhe_agendamento_pagam(pr_idlancto => pr_idlancto
                                     ,pr_retxml   => pr_retxml
                                     ,pr_dsretorn => pr_dsretorn);                              
       WHEN pr_cdtiptra IN (4, 22) THEN /*REQ39*/
         pc_detalhe_agendamento_ted(pr_idlancto => pr_idlancto
                                   ,pr_retxml   => pr_retxml
                                   ,pr_dsretorn => pr_dsretorn);
       WHEN pr_cdtiptra = 10 THEN
         pc_detalhe_agendamento_darf(pr_idlancto => pr_idlancto
                                    ,pr_retxml   => pr_retxml
                                    ,pr_dsretorn => pr_dsretorn);
		   WHEN pr_cdtiptra = 12 THEN
         pc_detalhe_agendamento_FGTS(pr_idlancto => pr_idlancto
                                    ,pr_retxml   => pr_retxml
                                    ,pr_dsretorn => pr_dsretorn);  																	 			
                                    
		   WHEN pr_cdtiptra = 13 THEN
         pc_detalhe_agendamento_dae(pr_idlancto => pr_idlancto
                                   ,pr_retxml   => pr_retxml
                                   ,pr_dsretorn => pr_dsretorn);		   
       
		   WHEN pr_cdtiptra = 20 THEN
         pc_detalhe_age_recarga_cel(pr_idlancto => pr_idlancto
                                   ,pr_retxml   => pr_retxml
                                   ,pr_dsretorn => pr_dsretorn);  
       ELSE
         pr_dsretorn := 'NOK';
         pr_retxml := '<dsmsgerr>Operacao inexistente</dsmsgerr>';                                                    
                                     
     END CASE;
 
   END;
 

END AGEN0001;
/
