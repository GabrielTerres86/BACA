CREATE OR REPLACE PACKAGE CECRED.AGEN0001 IS

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

END AGEN0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.AGEN0001 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : AGEN0001
  --  Sistema  : Rotinas para busca de agendamentos
  --  Sigla    : AGEN
  --  Autor    : Ricardo Linhares
  --  Data     : Julho/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: - Sempre que chamado
  -- Objetivo  : Disponibilizar rotinas de busca de agendamentos para SOA
  --
  ---------------------------------------------------------------------------------------------------------------

  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
	-- Pessoa Fídica
	SELECT ass.cdcooper
				,ass.nrdconta
				,ass.inpessoa
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
          WHEN vr_cdtiptra = 10         THEN 
              
            vr_dsagenda := pr_tab_dados_agendamento.dsidpgto;
            
            IF TRIM(vr_dsagenda) IS NULL THEN
              vr_dsagenda := pr_tab_dados_agendamento.dsnomfon;
              IF TRIM(vr_dsagenda) IS NULL THEN
                vr_dsagenda := 'AGENDAMENTO DE ' || pr_tab_dados_agendamento.dstiptra;                
              END IF;
            END IF;
            
          WHEN vr_cdtiptra IN (1,3,4,5) THEN vr_dsagenda := substr(pr_tab_dados_agendamento.dsageban,1,4) || '/' || pr_tab_dados_agendamento.nrctadst;
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
     Data    : Julho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar agendamentos

     Observacao: -----

     Alteracoes: 18/10/2017 - Alterado o parametro de consulta de recarga de 3 para 5
                              (IF pr_cdtipmod = 3 -> IF pr_cdtipmod = 3 -- Recarga de Celular), Prj. 285 (Jean Michel).

     ..................................................................................*/   
     
   DECLARE
  
    vr_agendamento PAGA0002.typ_tab_dados_agendamento;    --> PL Table para armazenar registros
		vr_agendm_fltr PAGA0002.typ_tab_dados_agendamento;    --> PL Table para filtrar registros
		vr_tab_age_recarga   rcel0001.typ_tab_age_recarga;    --> PL Table para filtrar registros
    vr_exc_erro    EXCEPTION;
    vr_dstransa    VARCHAR2(500);
    vr_xml_temp    VARCHAR2(32726) := '';
    vr_cdcritic    crapcri.cdcritic%TYPE;
    vr_dscritic    crapcri.dscritic%TYPE;
    vr_qttotage    INTEGER;
		
		TYPE array_t IS TABLE OF craplau.cdtiptra%TYPE;
    vr_cdtiptra array_t := array_t();
                
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
									
			IF pr_cdtipmod = 5 THEN -- Recarga de Celular
				
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
			
			ELSE -- Pagamento, Transferências
				
			  IF pr_cdtipmod = 1 THEN -- Pagamento
					
					vr_cdtiptra.extend(4);
					vr_cdtiptra(1) := 1; -- Transferencias inter
					vr_cdtiptra(2) := 3; -- Credito salario
					vr_cdtiptra(3) := 4; -- TED
					vr_cdtiptra(4) := 5; -- Transferencias intra

				ELSIF pr_cdtipmod = 2 THEN -- Transferências 
					
					vr_cdtiptra.extend(2);
					vr_cdtiptra(1) := 2;  -- Pagamento
					vr_cdtiptra(2) := 10; -- DARF/DAS
								
				END IF;
						
				PAGA0002.pc_obtem_agendamentos(pr_cdcooper => pr_cdcooper
																			,pr_cdagenci => 90
																			,pr_nrdcaixa => 900
																			,pr_nrdconta => pr_nrdconta
																			,pr_dsorigem => pr_dsorigem
																			,pr_dtmvtolt => rw_crapdat.dtmvtolt
																			,pr_dtageini => pr_dtageini
																			,pr_dtagefim => pr_dtagefim
																			,pr_insitlau => pr_insitlau
																			,pr_iniconta => pr_iniconta
																			,pr_nrregist => pr_nrregist
																			,pr_dstransa => vr_dstransa
																			,pr_qttotage => vr_qttotage
																			,pr_tab_dados_agendamento => vr_agendm_fltr
																			,pr_cdcritic => vr_cdcritic
																			,pr_dscritic => vr_dscritic);                                    
				-- Verifica se retornou erro
				IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;
				
				-- Filtra retorno pelo tipo de protocolo solicitado
				vr_qttotage := 0;
				FOR vr_ind IN 1..vr_agendm_fltr.count LOOP				
					IF vr_agendm_fltr(vr_ind).cdtiptra MEMBER OF vr_cdtiptra THEN
						vr_agendamento(vr_agendamento.count + 1) := vr_agendm_fltr(vr_ind);
						vr_qttotage := vr_qttotage + 1;
					END IF;
				END LOOP;  
							
      END IF;
			
      -- Verifica se a quantidade de registro é zero
      IF nvl(vr_qttotage, 0) = 0 THEN
        vr_dscritic := 'Agendamento(s) nao encontrado(s).';
        RAISE vr_exc_erro;
      END IF;                                    

      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
			
			dbms_output.put_line(vr_agendamento.count);
			dbms_output.put_line(vr_tab_age_recarga.count);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Agendamentos>');       

      IF vr_agendamento.count > 0 THEN
				FOR vr_idx IN vr_agendamento.first..vr_agendamento.last LOOP
	      
					gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																 ,pr_texto_completo => vr_xml_temp      
																 ,pr_texto_novo     => 
																 '<Agendamento>' ||
																		'<idlancto>' || vr_agendamento(vr_idx).idlancto                                                               || '</idlancto>' ||
																		'<dtmvtopg>' || TO_CHAR(vr_agendamento(vr_idx).dtmvtopg, 'DD/MM/RRRR')                                        || '</dtmvtopg>' ||
																		'<cdtiptra>' || vr_agendamento(vr_idx).cdtiptra                                                               || '</cdtiptra>' ||
																		'<dstiptra>' || vr_agendamento(vr_idx).dstiptra                                                               || '</dstiptra>' ||
																		'<dsagenda>' || fn_descricao(vr_agendamento(vr_idx))                                                          || '</dsagenda>' ||
																		'<insitlau>' || vr_agendamento(vr_idx).insitlau                                                               || '</insitlau>' ||
																		'<dssitlau>' || vr_agendamento(vr_idx).dssitlau                                                               || '</dssitlau>' ||                                  
																		'<vldocmto>' || to_char(vr_agendamento(vr_idx).vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
																		'<incancel>' || vr_agendamento(vr_idx).incancel                                                               || '</incancel>');

					 IF pr_cdtipmod = 1 THEN -- Pagamentos
						 gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																		,pr_texto_completo => vr_xml_temp      
																		,pr_texto_novo     => '<dscritic>' || vr_agendamento(vr_idx).dscritic || '</dscritic>');
					 END IF;
					 
					 gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																	,pr_texto_completo => vr_xml_temp      
																	,pr_texto_novo     => '</Agendamento>' );
																															 
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
																		'<dsagenda>AGENDAMENTO DE RECARGA DE CELULAR</dsagenda>' ||
																		'<insitlau>' || CASE WHEN vr_tab_age_recarga(vr_idx).insit_operacao = 4 THEN 3
																												 WHEN vr_tab_age_recarga(vr_idx).insit_operacao = 5 THEN 4
																												 ELSE vr_tab_age_recarga(vr_idx).insit_operacao
																										END                                                                                                || '</insitlau>' ||
																		'<dssitlau>' || vr_tab_age_recarga(vr_idx).dssit_operacao                                                          || '</dssitlau>' ||                                  
																		'<vldocmto>' || to_char(vr_tab_age_recarga(vr_idx).vlrecarga,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
																		'<incancel>' || vr_tab_age_recarga(vr_idx).incancel                                                                || '</incancel>' ||
																		'<nrtelefo>' || gene0002.fn_mask(vr_tab_age_recarga(vr_idx).nrcelular,'99999-9999')                                || '</nrtelefo>' ||
																		'<nmoperad>' || vr_tab_age_recarga(vr_idx).nmoperadora                                                             || '</nmoperad>' ||
																		'<dscritic>' || vr_tab_age_recarga(vr_idx).dscritic                                                                || '</dscritic>' ||
																'</Agendamento>');
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

     ..................................................................................*/     
     
   DECLARE
  
    vr_exc_erro EXCEPTION;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_des_erro    VARCHAR2(4000);
    vr_nmoperad crapopi.nmoperad%TYPE := '';

    CURSOR cr_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
      SELECT to_char(lau.dttransa, 'DD/MM/RRRR') AS dttransa
            ,lau.cdcooper
            ,lau.nrdconta 
            ,lau.hrtransa
            ,lau.nrdocmto
            ,lau.insitlau
            , CASE lau.insitlau
                   WHEN 1 THEN 'Pendente'
                   WHEN 2 THEN 'Pendente'
                   WHEN 3 THEN 'Cancelado'
                   WHEN 4 THEN 'Nao Efetivado'
              END AS dssitlau
            ,TO_CHAR(lau.vllanaut,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') AS vllanaut
            ,lau.dtdebito
            ,NVL2(ban.cdbccxlt, LPAD(ban.cdbccxlt,4,'0') || ' - ' || REPLACE(UPPER(TRIM(ban.nmextbcc)),'&','e'),'Nao cadastrado') AS dsdbanco
            ,NVL2(agb.cdageban, LPAD(agb.cdageban,4,'0') || ' - ' || REPLACE(UPPER(TRIM(agb.nmageban)),'&','e'),'Nao cadastrado') AS dsdagenc
            ,TRIM(GENE0002.fn_mask_conta(cti.nrctatrf)) || ' - ' || cti.nmtitula AS dstitula
            ,lau.nmprepos
            ,lau.nrcpfpre
            ,lau.nrcpfope
       FROM craplau lau
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

      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Agendamento>');       
                             
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => 
                              '<dttransa>' || rw_agendamento.dttransa || '</dttransa>' ||
                              '<hrtransa>' || rw_agendamento.hrtransa || '</hrtransa>' ||
                              '<nrdocmto>' || rw_agendamento.nrdocmto || '</nrdocmto>' ||
                              '<insitlau>' || rw_agendamento.insitlau || '</insitlau>' ||
                              '<dssitlau>' || rw_agendamento.dssitlau || '</dssitlau>' ||
                              '<vllanaut>' || rw_agendamento.vllanaut || '</vllanaut>' ||
                              '<dtdebito>' || rw_agendamento.dtdebito || '</dtdebito>' ||
                              '<dsdbanco>' || rw_agendamento.dsdbanco || '</dsdbanco>' ||
                              '<dsdagenc>' || rw_agendamento.dsdagenc || '</dsdagenc>' ||
                              '<dstitula>' || rw_agendamento.dstitula || '</dstitula>' ||
                              '<nmprepos>' || rw_agendamento.nmprepos || '</nmprepos>' ||
                              '<nrcpfpre>' || rw_agendamento.nrcpfpre || '</nrcpfpre>' ||
                              '<nmoperad>' || vr_nmoperad             || '</nmoperad>' ||
                              '<nrcpfope>' || rw_agendamento.nrcpfope || '</nrcpfope>');   
     
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
      vr_nmoperad crapopi.nmoperad%TYPE := '';

      CURSOR cr_agendamento(pr_idlancto IN craplau.idlancto%TYPE) IS
        SELECT lau.dttransa
              ,lau.cdcooper
              ,lau.nrdconta
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
              ,lau.dtdebito
              ,LPAD(cop.cdagectl,4,'0') || ' - ' || cop.nmrescop AS dsdcoper
              ,TRIM(GENE0002.fn_mask_conta(lau.nrctadst)) || ' - ' || ass.nmprimtl AS dstitula
              ,lau.nmprepos
              ,lau.nrcpfpre
              ,lau.nrcpfope
         FROM craplau lau
    LEFT JOIN crapcop cop
           ON cop.cdagectl = lau.cdageban
    LEFT JOIN crapass ass
           ON ass.cdcooper = cop.cdcooper
          AND ass.nrdconta = lau.nrctadst
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

        dbms_lob.createtemporary(pr_retxml, TRUE);
        dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
         
         -- Criar cabecalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<Agendamento>');       
                               
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                                '<dttransa>' || rw_agendamento.dttransa || '</dttransa>' ||
                                '<hrtransa>' || rw_agendamento.hrtransa || '</hrtransa>' ||
                                '<nrdocmto>' || rw_agendamento.nrdocmto || '</nrdocmto>' ||
                                '<insitlau>' || rw_agendamento.insitlau || '</insitlau>' ||
                                '<dssitlau>' || rw_agendamento.dssitlau || '</dssitlau>' ||
                                '<vllanaut>' || rw_agendamento.vllanaut || '</vllanaut>' ||
                                '<dtdebito>' || rw_agendamento.dtdebito || '</dtdebito>' ||
                                '<dsdcoper>' || rw_agendamento.dsdcoper || '</dsdcoper>' ||
                                '<dstitula>' || rw_agendamento.dstitula || '</dstitula>' ||
                                '<nmprepos>' || rw_agendamento.nmprepos || '</nmprepos>' ||
                                '<nrcpfpre>' || rw_agendamento.nrcpfpre || '</nrcpfpre>' ||
                                '<nmoperad>' || vr_nmoperad             || '</nmoperad>' ||
                                '<nrcpfope>' || rw_agendamento.nrcpfope || '</nrcpfope>');
       
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
     Data    : Julho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento Pagamento

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campo nrcpfpre e nrcpfope, Prj. 285 (Jean Michel).

     ..................................................................................*/       
       
     DECLARE
    
      vr_exc_erro  EXCEPTION; 
			vr_exc_leave EXCEPTION;
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
						,lau.dttransa
						,lau.dtvencto
            ,lau.dtdebito
						,lau.dtmvtopg	
						,lau.nrcpfope
            ,lau.nmprepos
            ,lau.nrcpfpre
            ,lau.dscedent
            ,nvl(lau.dslindig, '') AS dslindig
						,lau.nrseqagp
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
				      ,lau.dttransa
							,lau.dtmvtopg
              ,gene0002.fn_converte_time_data(lau.hrtransa,'S') AS hrtransa
              ,lau.nrdocmto
              ,lau.insitlau
              , CASE lau.insitlau
                     WHEN 1 THEN 'Pendente'
                     WHEN 2 THEN 'Pendente'
                     WHEN 3 THEN 'Cancelado'
                     WHEN 4 THEN 'Nao Efetivado'
                END AS dssituac
              ,lau.dtdebito
              ,nvl(lau.nmprepos, '') AS nmprepos
              ,lau.nrcpfpre
							,lau.nrcpfope
              ,lau.dtvencto
							,lau.cdtiptra
							,lau.vllanaut
							,nvl(lau.dslindig, '') AS dslindig
              ,(CASE WHEN darf.tpcaptura = 1 THEN 'COM CÓDIGO DE BARRAS' ELSE 'SEM CÓDIGO DE BARRAS' END) AS dstipcap
              ,darf.dsidentif_pagto AS dsdpagto
              ,darf.dsnome_fone AS dsnomfon 
              ,darf.dtapuracao AS dtapurac
              ,darf.cdtributo AS cdreceit
              ,darf.nrrefere AS nrrefere
              ,darf.nrcpfcgc AS nrcpfcgc						
              ,darf.vlprincipal AS vlprinci 
              ,darf.vlmulta AS vlrmulta
              ,darf.vljuros AS vlrjuros
							,darf.dtvencto AS darf_dtvencto
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

  -- Das
  PROCEDURE pc_detalhe_agendamento_das(pr_idlancto  IN craplau.idlancto%TYPE  --> Id do Agendamento
                                      ,pr_retxml   OUT CLOB                   --> Arquivo de retorno do XML                                        
                                      ,pr_dsretorn OUT VARCHAR2) IS           --> Retorno de critica (OK ou NOK)
    BEGIN
      
    /* ................................................................................

     Programa: pc_detalhe_agendamento_das
     Sistema : Internet Banking
     Sigla   : AGEN0001
     Autor   : Ricardo Linhares
     Data    : Julho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para listar detalhe agendamento DAS

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfpre e nrcpfope ,Prj. 285 (Jean Michel)

     ..................................................................................*/       
       
     DECLARE
    
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
                ,lau.dttransa
								,lau.dtmvtopg
                ,gene0002.fn_converte_time_data(lau.hrtransa,'S') AS hrtransa
                ,lau.nrdocmto
                ,lau.insitlau
                , CASE lau.insitlau
                       WHEN 1 THEN 'Pendente'
                       WHEN 2 THEN 'Pendente'
                       WHEN 3 THEN 'Cancelado'
                       WHEN 4 THEN 'Nao Efetivado'
                  END AS dssituac
                ,lau.dtdebito
                ,nvl(lau.nmprepos, '') AS nmprepos 
                ,lau.nrcpfpre               
								,lau.nrcpfope
                ,lau.dtvencto
							  ,lau.cdtiptra
							  ,lau.vllanaut
							  ,nvl(lau.dslindig, '') AS dslindig
                ,(CASE WHEN darf.tpcaptura = 1 THEN 'COM CÓDIGO DE BARRAS' ELSE 'SEM CÓDIGO DE BARRAS' END) AS dstipcap
								,(CASE WHEN darf.tppagamento = 1 THEN 'DARF' ELSE 'DAS' END) AS dstiptra
                ,darf.dsidentif_pagto AS dsdpagto
                ,darf.dsnome_fone AS dsnomfon
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
																'<dstipcap>' || rw_agendamento.dstipcap || '</dstipcap>' ||
																'<dslinhad>' || rw_agendamento.dslindig || '</dslinhad>' ||																															  
                                '<dsnomfon>' || rw_agendamento.dsnomfon || '</dsnomfon>' ||
                                '<dsdpagto>' || rw_agendamento.dsdpagto || '</dsdpagto>' ||                                
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
      
  END pc_detalhe_agendamento_das;
		
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
						,lau.dttransa
						,lau.dtvencto
            ,lau.dtdebito
						,lau.dtmvtopg						
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
 
     CASE pr_cdtiptra
       WHEN 1 THEN
         pc_detalhe_agendamento_trans(pr_idlancto => pr_idlancto
                                     ,pr_retxml   => pr_retxml
                                     ,pr_dsretorn => pr_dsretorn);
       WHEN 2 THEN -- Pagamento (Conv/Boleto e GPS)
         pc_detalhe_agendamento_pagam(pr_idlancto => pr_idlancto
                                     ,pr_retxml   => pr_retxml
                                     ,pr_dsretorn => pr_dsretorn);                              
       WHEN 4 THEN
         pc_detalhe_agendamento_ted(pr_idlancto => pr_idlancto
                                   ,pr_retxml   => pr_retxml
                                   ,pr_dsretorn => pr_dsretorn);
       WHEN 10 THEN
         pc_detalhe_agendamento_darf(pr_idlancto => pr_idlancto
                                    ,pr_retxml   => pr_retxml
                                    ,pr_dsretorn => pr_dsretorn);                                   
       WHEN 11 THEN
         pc_detalhe_agendamento_das(pr_idlancto => pr_idlancto
                                   ,pr_retxml   => pr_retxml
                                   ,pr_dsretorn => pr_dsretorn);  																	 			
		   WHEN 20 THEN
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
