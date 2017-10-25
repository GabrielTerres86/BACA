CREATE OR REPLACE PACKAGE CECRED.COMP0002 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COMP0002
  --  Sistema  : Rotinas para busca de comprovantes
  --  Sigla    : COMP
  --  Autor    : Ricardo Linhares
  --  Data     : Junho/2017.                   Ultima atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --  Frequencia: -
  --  Objetivo  : Rotinas para busca de comprovantes
  --
  ---------------------------------------------------------------------------------------------------------------
  TYPE typ_reg_info_sac IS
    RECORD(nrtelsac crapcop.nrtelsac%TYPE
          ,nrtelouv crapcop.nrtelouv%TYPE
          ,hrinisac VARCHAR2(5)
          ,hrfimsac VARCHAR2(5)
          ,hriniouv VARCHAR2(5)
          ,hrfimouv VARCHAR2(5));  

  FUNCTION fn_info_sac(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN typ_reg_info_sac;
		
  PROCEDURE pc_lista_comprovantes(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_dtinipro IN crappro.dtmvtolt%TYPE  --> Data inicial do protocolo
                                 ,pr_dtfimpro IN crappro.dtmvtolt%TYPE  --> Data final do protocolo
                                 ,pr_iniconta IN NUMBER                 --> Início da conta
                                 ,pr_nrregist IN NUMBER                 --> Número de registros
                                 ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
																 ,pr_cdtipmod IN NUMBER                 --> Código do módulo da consulta
                                 ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                 ,pr_dsretorn OUT VARCHAR2 );

  -- Transferencia
   PROCEDURE pc_detalhe_compr_transferencia(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                          ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                          ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                          ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                          ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                          ,pr_dsretorn OUT VARCHAR2);            --> Erros do processo
  
  -- Ted
  PROCEDURE pc_detalhe_compr_ted(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocoloento
                                ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                ,pr_retxml   OUT CLOB                      --> Arquivo de retorno do XML                                        
                                ,pr_dsretorn OUT VARCHAR2);        
      
  -- Aplicação Pós
  PROCEDURE pc_detalhe_compr_aplicacao_pos(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                          ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                          ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocoloento
                                          ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                          ,pr_retxml   OUT CLOB                      --> Arquivo de retorno do XML                                        
                                          ,pr_dsretorn OUT VARCHAR2);        
                                        
  -- Resgate Aplicação Pós                                        
  PROCEDURE pc_detalhe_compr_res_apli_pos(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                         ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                         ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocoloento
                                         ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                         ,pr_retxml   OUT CLOB                      --> Arquivo de retorno do XML                                        
                                         ,pr_dsretorn OUT VARCHAR2);           

  -- Pagamento
  PROCEDURE pc_detalhe_compr_pagamento(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                      ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                      ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocoloento
                                      ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                      ,pr_retxml   OUT CLOB                      --> Arquivo de retorno do XML                                        
                                      ,pr_dsretorn OUT VARCHAR2);        

  -- Recarga celular
  PROCEDURE pc_detalhe_compr_rec_cel(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocoloento
                                    ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                      --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2);        
  
  -- Cotas de Capital
  PROCEDURE pc_detalhe_compr_capital(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocoloento
                                    ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                      --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2);        

  -- GPS
  PROCEDURE pc_detalhe_compr_pag_gps(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocoloento
                                    ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                      --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2);                          

  -- Pagamento Débito Automático
  PROCEDURE pc_detalhe_compr_pag_deb_aut(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocoloento
                                        ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                        ,pr_retxml   OUT CLOB                      --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2);         
                                              
  -- Pagamento DARF                                      
  PROCEDURE pc_detalhe_compr_pag_darf(pr_cdcooper IN crappro.cdcooper%TYPE --> Código da cooperativa
                                     ,pr_nrdconta IN crappro.nrdconta%TYPE --> Número da conta
                                     ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocoloento
                                     ,pr_cdorigem IN NUMBER                --> Origem: 1-ayllos, 3-internet, 4-TAS
                                     ,pr_retxml   OUT CLOB                 --> Arquivo de retorno do XML                                        
                                     ,pr_dsretorn OUT VARCHAR2);           --> Erros do processo
                                   
  -- Agendamento DARF
  PROCEDURE pc_detalhe_compr_age_darf(pr_cdcooper IN crappro.cdcooper%TYPE --> Código da cooperativa
                                     ,pr_nrdconta IN crappro.nrdconta%TYPE --> Número da conta
                                     ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocoloento
                                     ,pr_cdorigem IN NUMBER                --> Origem: 1-ayllos, 3-internet, 4-TAS
                                     ,pr_retxml   OUT CLOB                 --> Arquivo de retorno do XML                                        
                                     ,pr_dsretorn OUT VARCHAR2);           --> Erros do processo

  -- Pagamento DAS
  PROCEDURE pc_detalhe_compr_pag_das(pr_cdcooper IN crappro.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocoloento
                                    ,pr_cdorigem IN NUMBER                --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                 --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2);           --> Erros do processo

  -- Agendamento DAS
  PROCEDURE pc_detalhe_compr_age_das(pr_cdcooper IN crappro.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocoloento
                                    ,pr_cdorigem IN NUMBER                --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                 --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2);           --> Erros do processo
                                    
   PROCEDURE pc_detalhe_comprovante(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                   ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
																	 ,pr_cdtippro IN crappro.cdtippro%TYPE  --> Tipo do Protocolo
                                   ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                   ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                   ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                   ,pr_dsretorn OUT VARCHAR2);
                                                                  
END COMP0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COMP0002 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COMP0002
  --  Sistema  : Rotinas para busca de comprovantes
  --  Sigla    : COMP
  --  Autor    : Ricardo Linhares
  --  Data     : Junho/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -
  -- Objetivo  : Rotinas para busca de comprovantes
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
  
  FUNCTION fn_descricao(pr_protocolo IN gene0006.typ_reg_protocolo) RETURN VARCHAR2 IS
    BEGIN
     DECLARE
      vr_dsprotoc  VARCHAR2(4000);
      vr_dsinfor2  VARCHAR2(4000); --> Descrição de informações      
      vr_split gene0002.typ_split;            
      vr_desc  VARCHAR2(500);
      vr_ult PLS_INTEGER;               
      
      BEGIN
    
        CASE
          WHEN pr_protocolo.cdtippro = 1 THEN -- Transferencia
            vr_dsinfor2 := TRIM(gene0002.fn_busca_entrada(2, pr_protocolo.dsinform##2, '#'));      
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(3, pr_protocolo.dsinform##2, '#')), '-')) || '/' || TRIM(gene0002.fn_busca_entrada(2, vr_dsinfor2, ':'));
          WHEN pr_protocolo.cdtippro IN (2,15) THEN -- Pagamento / Convenio
            vr_dsprotoc := pr_protocolo.dscedent;          
          WHEN pr_protocolo.cdtippro = 3 THEN -- Capital;
            vr_dsprotoc := pr_protocolo.dsinform##1;
          WHEN pr_protocolo.cdtippro = 9 THEN -- TED
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(4, pr_protocolo.dsinform##2, '#')) || ' - ' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo.dsinform##3, '#'));
          WHEN pr_protocolo.cdtippro IN(10,12) THEN -- Aplicacao POS - Resgate
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(3, pr_protocolo.dsinform##2, '#')), '-')) || '/' || TRIM(SUBSTR(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, pr_protocolo.dsinform##2, '#')), ':')),1,10));
          WHEN pr_protocolo.cdtippro = 13 THEN -- GPS       
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(1, pr_protocolo.dsinform##2, '#'));
          
          WHEN pr_protocolo.cdtippro in(16, 17, 18, 19) THEN -- DARF / DAS
            
             vr_split := gene0002.fn_quebra_string(pr_protocolo.dsinform##3,'#');
             vr_ult := vr_split.count();

            IF TRIM(vr_split(vr_ult)) IS NOT NULL THEN
               vr_desc := TRIM(gene0002.fn_busca_entrada(2, vr_split(vr_ult), ':'));
               IF vr_desc IS NULL THEN
                 vr_desc := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, pr_protocolo.dsinform##3, '#')), ':'));
                 IF vr_desc IS NULL THEN
                   vr_desc := UPPER(TRIM(pr_protocolo.dsinform##1));
                 END IF;
               END IF;
            END IF;
            
            vr_dsprotoc := vr_desc;
            
          WHEN pr_protocolo.cdtippro = 20 THEN -- Recarga
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(1, pr_protocolo.dsinform##2, '#')) || ' - ' || TRIM(gene0002.fn_busca_entrada(2, pr_protocolo.dsinform##2, '#'));
          ELSE
           vr_dsprotoc := pr_protocolo.dsinform##2;            
         END CASE;
     
        RETURN vr_dsprotoc;

    END;

  END;

  -- Busca informações de SAC
  FUNCTION fn_info_sac(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN typ_reg_info_sac IS
   BEGIN
    DECLARE
      vr_info_sac   typ_reg_info_sac;    --> PL Table para armazenar informações de SAC

      CURSOR cr_crapcop(pr_cdcooper IN crappro.cdcooper%TYPE) IS
        SELECT nrtelsac, 
               nrtelouv, 
               hrinisac, 
               hrfimsac, 
               hriniouv, 
               hrfimouv  
          FROM crapcop              
        WHERE cdcooper = pr_cdcooper;
        rw_crapcop cr_crapcop%ROWTYPE;

    BEGIN
      
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
      
      vr_info_sac.nrtelsac := rw_crapcop.nrtelsac;
      vr_info_sac.nrtelouv := rw_crapcop.nrtelouv;
      vr_info_sac.hrinisac := gene0002.fn_converte_time_data(rw_crapcop.hrinisac);
      vr_info_sac.hrfimsac := gene0002.fn_converte_time_data(rw_crapcop.hrfimsac);
      vr_info_sac.hriniouv := gene0002.fn_converte_time_data(rw_crapcop.hriniouv);
      vr_info_sac.hrfimouv := gene0002.fn_converte_time_data(rw_crapcop.hrfimouv);
      
      RETURN vr_info_sac;
    
    END;
    
   END;

  -- Todos
  PROCEDURE pc_lista_comprovantes(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_dtinipro IN crappro.dtmvtolt%TYPE  --> Data inicial do protocolo
                                 ,pr_dtfimpro IN crappro.dtmvtolt%TYPE  --> Data final do protocolo
                                 ,pr_iniconta IN NUMBER                 --> Início da conta
                                 ,pr_nrregist IN NUMBER                 --> Número de registros
                                 ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
																 ,pr_cdtipmod IN NUMBER                 --> Código do módulo da consulta
                                 ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                 ,pr_dsretorn OUT VARCHAR2) IS          --> Retorno de critica (OK ou NOK)

  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_comprovantes
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes

     Observacao: -----

     Alteracoes: Inclusão do campo

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
			vr_prot_fltr   gene0006.typ_tab_protocolo;    --> PL Table para filtrar registros (retorno protocolo)
      vr_dstransa    VARCHAR2(400);                 --> Descrição da transação
      vr_qttotreg    PLS_INTEGER;                   --> Quantidade de registros      
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_dsinfor2    VARCHAR2(4000);                --> Descrição de informações
      vr_xml_temp    VARCHAR2(32726) := '';
      vr_des_erro    VARCHAR2(4000);
      vr_dscritic    crapcri.dscritic%TYPE;
						    			
			TYPE array_t IS TABLE OF crappro.cdtippro%TYPE;
      vr_cdtippro array_t := array_t();
    
    BEGIN					  
			
		  IF pr_cdtipmod = 1 THEN -- Pagamento

				vr_cdtippro.extend(8);
			  vr_cdtippro(1) := 2;  -- Pagamento (Tit/Cnv)
				vr_cdtippro(2) := 11; -- Operações DebAut
				vr_cdtippro(3) := 13; -- Pagamento/Agendamento GPS
				vr_cdtippro(4) := 15; -- Pagamento DebAut
				vr_cdtippro(5) := 16; -- Pagamento DARF
				vr_cdtippro(6) := 17; -- Agendamento DARF
				vr_cdtippro(7) := 18; -- Pagamento DAS				
				vr_cdtippro(8) := 19; -- Agendamento DAS
			
			ELSIF pr_cdtipmod = 2 THEN -- Transferências 
				
				vr_cdtippro.extend(3);
			  vr_cdtippro(1) := 1;  -- Transferência
			  vr_cdtippro(2) := 4;  -- Credito Salario				
				vr_cdtippro(3) := 9;  -- TED				
								
			ELSIF pr_cdtipmod = 4 THEN -- Investimentos
				
				vr_cdtippro.extend(3);
			  vr_cdtippro(1) := 3;  -- Capital
			  vr_cdtippro(2) := 10; -- Aplicação Pre/Pos
				vr_cdtippro(3) := 12; -- Resgate Aplicação Pre/Pos
									
			ELSIF pr_cdtipmod = 5 THEN -- Recarga de Celular

				vr_cdtippro.extend(1);
				vr_cdtippro(1) := 20; -- Recarga de Celular
											
			END IF;
    
      gene0006.pc_lista_protocolos(pr_cdcooper  => pr_cdcooper
                                  ,pr_nrdconta  => pr_nrdconta
                                  ,pr_dtinipro  => pr_dtinipro
                                  ,pr_dtfimpro  => pr_dtfimpro
                                  ,pr_iniconta  => pr_iniconta
                                  ,pr_nrregist  => pr_nrregist
                                  ,pr_cdtippro  => 0          --> Todos
                                  ,pr_cdorigem  => pr_cdorigem
                                  ,pr_dstransa  => vr_dstransa
                                  ,pr_dscritic  => vr_dscritic
                                  ,pr_qttotreg  => vr_qttotreg
                                  ,pr_protocolo => vr_prot_fltr
                                  ,pr_des_erro  => vr_des_erro);

      -- Verifica se retornou erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
				vr_des_erro := 'Erro em pc_lista_protocolos';        
		    RAISE vr_exc_erro;
      END IF;
      			
			-- Filtra retorno pelo tipo de protocolo solicitado
			vr_qttotreg := 0;
			FOR vr_ind IN 1..vr_prot_fltr.count LOOP				
				IF vr_prot_fltr(vr_ind).cdtippro MEMBER OF vr_cdtippro THEN
					vr_protocolo(vr_protocolo.count + 1) := vr_prot_fltr(vr_ind);
					vr_qttotreg := vr_qttotreg + 1;
				END IF;
			END LOOP;
			
			-- Verifica se a quantidade de registro é zero
      IF nvl(vr_qttotreg, 0) = 0 THEN
        vr_des_erro := 'Protocolo(s) nao encontrado(s).';
        RAISE vr_exc_erro;
      END IF;
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML   
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovantes>');   
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
        
        vr_dsinfor2 := TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#'));      
      
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<Comprovante>'||
                                  '<nrdocmto>' || vr_protocolo(vr_ind).nrdocmto                                                               || '</nrdocmto>' ||
                                  '<cdtippro>' || vr_protocolo(vr_ind).cdtippro                                                             	|| '</cdtippro>' ||
                                  '<dstippro>' || vr_protocolo(vr_ind).dsinform##1                                                           	|| '</dstippro>' ||																																		
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
                                  '<dsdescri>' || fn_descricao(vr_protocolo(vr_ind)) || '</dsdescri>');     
																	
				IF pr_cdtipmod = 5 THEN			-- Recarga de celular							
					gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     =>
                                  '<nrtelefo>' || vr_protocolo(vr_ind).nrcelular   || '</nrtelefo>' ||
                                  '<nmoperad>' || vr_protocolo(vr_ind).nmoperadora || '</nmoperad>');   
				END IF;
				
	    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => '</Comprovante>');
																			 															 				
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovantes>'
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
    
  END pc_lista_comprovantes;
   
  -- Transferencia
  PROCEDURE pc_detalhe_compr_transferencia(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                          ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                          ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                          ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                          ,pr_retxml   OUT CLOB                      --> Arquivo de retorno do XML                                        
                                          ,pr_dsretorn OUT VARCHAR2) IS

  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_compr_transferencia
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro  EXCEPTION;       --> Controle de exceção      
      vr_dsinfor2  VARCHAR2(4000);                --> Descrição de informações
      vr_xml_temp  VARCHAR2(32726) := '';
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  crapcri.dscritic%TYPE;   
      vr_info_sac  typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);
    
    BEGIN
							
      pr_dsretorn := 'NOK';
			
			gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
																						,pr_nrdconta => pr_nrdconta
																						,pr_dsprotoc => pr_dsprotoc
																						,pr_cdorigem => pr_cdorigem
																						,pr_protocolo => vr_protocolo
																						,pr_cdcritic => vr_cdcritic
																						,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_lista_compr_transferencia:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');       
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
        
        vr_dsinfor2 := TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#'));      
      
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                      || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')      || '</hrautent>' ||
                                  '<vldocmto>' ||to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')  || '</vldocmto>' ||
                                  '<nrdocmto>' || vr_protocolo(vr_ind).nrdocmto                                             || '</nrdocmto>' ||
                                  '<nmfavore>' || TRIM(gene0002.fn_busca_entrada(2, vr_dsinfor2, ':'))                  	  || '</nmfavore>' ||
                                  '<dsdbanco>' || TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2, '#')) || '</dsdbanco>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                             || '</dsprotoc>' ||
                                  '<cdagenda>' || vr_protocolo(vr_ind).flgagend                                             || '</cdagenda>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                             || '</nrseqaut>' ||
                                  '<nmprepos>' || vr_protocolo(vr_ind).nmprepos                                             || '</nmprepos>' ||
                                  '<nrcpfpre>' || vr_protocolo(vr_ind).nrcpfpre                                             || '</nrcpfpre>' ||
                                  '<nmoperad>' || vr_protocolo(vr_ind).nmoperad                                             || '</nmoperad>' ||
                                  '<nrcpfope>' || vr_protocolo(vr_ind).nrcpfope                                             || '</nrcpfope>' ||
                                  '<infosac>' ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||
                                 '</dados>' );         
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>'
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
    
  END pc_detalhe_compr_transferencia;

  -- TED 
  PROCEDURE pc_detalhe_compr_ted(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                ,pr_dsretorn OUT VARCHAR2) IS

  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_compr_transferencia
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_info_sac typ_reg_info_sac;     
      vr_des_erro  VARCHAR2(4000);           
    
    BEGIN
      
      pr_dsretorn := 'NOK';
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_lista_compr_transferencia:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');       
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
      
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                      || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')      || '</hrautent>' ||
                                  '<vldocmto>' ||to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')  || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                             || '</dsprotoc>' ||
                                  '<cdagenda>' || vr_protocolo(vr_ind).flgagend                                             || '</cdagenda>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                             || '</nrseqaut>' ||
                                  '<dsdbanco>' || TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#')) || '</dsdbanco>' ||
                                  '<dsageban>' || TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2, '#')) || '</dsageban>' ||
                                  '<nrctafav>' || TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##2, '#')) || '</nrctafav>' ||
                                  '<nmfavore>' || TRIM(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##2, '#')) || '</nmfavore>' ||
                                  '<nrcpffav>' || TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')) || '</nrcpffav>' ||
                                  '<dsfinali>' || TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')) || '</dsfinali>' ||
                                  '<dstransf>' || TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')) || '</dstransf>' ||
                                  '<nmprepos>' || vr_protocolo(vr_ind).nmprepos                                             || '</nmprepos>' ||
                                  '<nrcpfpre>' || vr_protocolo(vr_ind).nrcpfpre                                             || '</nrcpfpre>' ||
                                  '<nmoperad>' || vr_protocolo(vr_ind).nmoperad                                             || '</nmoperad>' ||
                                  '<nrcpfope>' || vr_protocolo(vr_ind).nrcpfope                                             || '</nrcpfope>' ||
                                  '<infosac>' ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||                                  
                               '</dados>' );          
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>'
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
    
  END pc_detalhe_compr_ted;

  -- Aplicação Pós
  PROCEDURE pc_detalhe_compr_aplicacao_pos(pr_cdcooper IN crappro.cdcooper%TYPE --> Código da cooperativa
                                          ,pr_nrdconta IN crappro.nrdconta%TYPE --> Número da conta
                                          ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocoloento
                                          ,pr_cdorigem IN NUMBER                --> Origem: 1-ayllos, 3-internet, 4-TAS
                                          ,pr_retxml   OUT CLOB                 --> Arquivo de retorno do XML                                        
                                          ,pr_dsretorn OUT VARCHAR2) IS         --> Erros do processo

  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_compr_transferencia
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);            
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_lista_compr_transferencia:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');       
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Cecred><Protocolos>');       
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
      
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<vldocmto>' ||to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                         || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
                                  '<cdagenda>' || vr_protocolo(vr_ind).flgagend                                                                                      || '</cdagenda>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
                                  '<dssolicit>' || TRIM(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##2, '#'))                                         || '</dssolicit>' ||
                                  '<dtaplic>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtaplic>' ||
                                  '<nraplic>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nraplic>' ||
                                  '<txaplic>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</txaplic>' ||
                                  '<txminim>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</txminim>' ||
                                  '<dtvenci>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvenci>' ||
                                  '<dscaren>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dscaren>' ||
                                  '<dtcaren>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtcaren>' ||
                                  '<dsbanco>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsbanco>' ||
                                  '<cnpjban>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</cnpjban>' ||
                                  '<nmprepos>' || vr_protocolo(vr_ind).nmprepos                                             || '</nmprepos>' ||
                                  '<nrcpfpre>' || vr_protocolo(vr_ind).nrcpfpre                                             || '</nrcpfpre>' ||
                                  '<nmoperad>' || vr_protocolo(vr_ind).nmoperad                                             || '</nmoperad>' ||
                                  '<nrcpfope>' || vr_protocolo(vr_ind).nrcpfope                                             || '</nrcpfope>' ||
                                  '<infosac>' ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||
                                 '</dados>' );        
                                 
               /*
               
                - O trecho a seguir deve ser adicionado em alguma tag e deve ser armazenado em alguma tabela 
                  a fim de ser parametrizável.
               
                1) ATO COOPERATIVO CONFORME ART. 79 DA LEI 5764/71;
                2) INTRANSFERIVEL;
                3) DEPOSITOS EM CHEQUES SOMENTE TERAO VALIDADE APOS SUA
                LIQUIDACAO.
                4) SAQUES ANTERIORES A CARENCIA, ADMITIDOS A CRITERIO DA
                COOPERATIVA IMPLICAM EM PERDA DO RENDIMENTO SOBRE O
                VALOR SACADO.
                5) O RENDIMENTO SERA CALCULADO COM BASE NO CDI* DIARIO,
                CONSIDERANDO OS DIAS UTEIS DO PERIODO APLICADO E A
                TAXA CONTRATADA.
                6) OS VALORES RESGATADOS APOS A CARENCIA E ANTES DO VEN–
                CIMENTO, ADMITIDOS A CRITERIO DA COOPERATIVA, SERAO
                REMUNERADOS NA FORMA DO ITEM ANTERIOR, POREM, TOMANDO
                COMO BASE PARA CALCULO A TAXA MINIMA.
                7) SAQUES ANTES DO VENCIMENTO DEVERAO SER COMUNICADOS
                COM ANTECEDENCIA.
                8) CASO A TAXA CONTRATADA, DEDUZIDO O IRRF, SEJA MENOR
                QUE A TAXA DA POUPANCA, SERA GARANTIDO O RENDIMENTO
                DA POUPANCA.
                9) CASO OCORRA O RESGATE DA APLICACAO ANTES DO PRAZO DE
                VENCIMENTO ACIMA ACORDADO, A ALIQUOTA DO IRRF SEGUIRA
                A TABELA REGRESSIVA DE RENDA FIXA VIGENTE.
                *CDI – Certificado de Deposito Interfinanceiro.
                COOPERATIVA DE CREDITO DO VALE DO ITAJAI
                82.639.451/0001-38
                BLUMENAU, 15 DE DEZEMBRO DE 2016.
               
               */              
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>'
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
    
  END pc_detalhe_compr_aplicacao_pos;

  -- Resgate aplicação Pós
  PROCEDURE pc_detalhe_compr_res_apli_pos(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                         ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                         ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                         ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                         ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                         ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK
  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_compr_transferencia
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE; 
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);                 
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_lista_compr_transferencia:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');  
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
      
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<vlliquid>' ||to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                         || '</vlliquid>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
                                  '<cdagenda>' || vr_protocolo(vr_ind).flgagend                                                                                      || '</cdagenda>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
                                  '<dssolici>' || TRIM(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##2, '#'))                                          || '</dssolici>' ||
                                  '<dtresgat>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtresgat>' ||
                                  '<nraplic>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nraplic>' ||
                                  '<txirrf>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))  || '</txirrf>' ||
                                  '<txaliq>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))  || '</txaliq>' ||
                                  '<vlbruto>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlbruto>' ||
                                  '<dsbanco>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsbanco>' ||
                                  '<cnpjban>'  || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</cnpjban>' ||
                                  '<nmprepos>' || vr_protocolo(vr_ind).nmprepos                                             || '</nmprepos>' ||
                                  '<nrcpfpre>' || vr_protocolo(vr_ind).nrcpfpre                                             || '</nrcpfpre>' ||
                                  '<nmoperad>' || vr_protocolo(vr_ind).nmoperad                                             || '</nmoperad>' ||
                                  '<nrcpfope>' || vr_protocolo(vr_ind).nrcpfope                                             || '</nrcpfope>' ||
                                  '<infosac>' ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||                                  
                                 '</dados>' );           
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>'
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
    
  END pc_detalhe_compr_res_apli_pos;

  -- Pagamento
    PROCEDURE pc_detalhe_compr_pagamento(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                        ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK
  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_compr_pagamento
     Sistema : Internet Banking
     Sigla   : CECRED
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de pagamentos.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_dsinfor2    VARCHAR2(400);                 --> Descrição do Convenio
      vr_dsconven    VARCHAR2(100);                 --> Descrição do Convenio
      vr_dsinstit    VARCHAR2(100);                 --> Descrição do Banco
      vr_dscedent    VARCHAR2(100);                 --> Descrição do Cedente      
			vr_cdtippag    INTEGER;
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;       
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);   
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
							
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_pagamento:' || vr_dscritic;
							
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_lista_compr_transferencia:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);  
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');       
                             
      FOR vr_ind IN 1..vr_protocolo.count LOOP
      
        -- Verifica se é pagamento de convênio
        vr_dsinfor2 := TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#')), ':'));

        IF vr_dsinfor2 = 'Convenio'THEN
          vr_dsconven := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#')), ':'));
          vr_dscedent := '';
          vr_dsinstit := '';
					vr_cdtippag := 1;
        ELSE
          vr_dsinstit := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#')), ':'));
          vr_dscedent := vr_protocolo(vr_ind).dscedent;
          vr_dsconven := '';          
					vr_cdtippag := 2;
        END IF;
        
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 															 
															   '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																 '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
															   '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
															   '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
                                 '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                 '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
                                 '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||																 															   																 
																 '<cdtippag>' || to_char(vr_cdtippag)                                                                                               || '</cdtippag>' ||																 
																 '<dsinstit>' || to_char(vr_dsinstit)                                                                                               || '</dsinstit>' ||															 															   
																 '<dscedent>' || vr_dscedent                                                                                                        || '</dscedent>' ||                                  
															   '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||															 														                                   
                                 '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                 '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
																 '<dtdpagto>' || to_char(vr_protocolo(vr_ind).dtmvtolt, 'DD/MM/RRRR')                                                               || '</dtdpagto>' ||
																 '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
																 '<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dslinhad>' ||
																 '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||                                  
                                 '<nmprepos>' || vr_protocolo(vr_ind).nmprepos                                                                                      || '</nmprepos>' ||
                                 '<nrcpfpre>' || vr_protocolo(vr_ind).nrcpfpre                                                                                      || '</nrcpfpre>' ||
                                 '<nmoperad>' || vr_protocolo(vr_ind).nmoperad                                                                                      || '</nmoperad>' ||
                                 '<nrcpfope>' || vr_protocolo(vr_ind).nrcpfope                                                                                      || '</nrcpfope>' ||
                                 '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                 '</infosac>' );
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);   
                             
      pr_retxml := vr_clob;                          
                             
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
    
  END pc_detalhe_compr_pagamento;

  -- Recarga de Celular
  PROCEDURE pc_detalhe_compr_rec_cel(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                    ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK
  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_compr_rec_cel
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de recarga de celular.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;       
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);  
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
							
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_rec_cel:' || vr_dscritic;
							
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_detalhe_compr_rec_cel:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');  
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
															    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
                                  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                   || '</dstippro>' ||
                                  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||
															    '<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                      || '</nmprepos>' ||
                                  '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                      || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                      || '</nmoperad>' ||
                                  '<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                      || '</nrcpfope>' ||
															    '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
																	'<nmopetel>' || vr_protocolo(vr_ind).nmoperadora                                                            || '</nmopetel>' ||
																	'<nrdddtel>' || to_char(substr(vr_protocolo(vr_ind).nrcelular,2,2))                                         || '</nrdddtel>' ||
                                  '<nrtelefo>' || to_char(REPLACE(substr(vr_protocolo(vr_ind).nrcelular,6,10),'-',''))                        || '</nrtelefo>' ||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||
                                  '<dtdpagto>' || to_char(vr_protocolo(vr_ind).dtmvtolt, 'DD/MM/RRRR')                                        || '</dtdpagto>' ||
																	'<nrnsuope>' || vr_protocolo(vr_ind).nrnsuope                                                               || '</nrnsuope>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>');            

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_retxml := vr_clob;
			
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
    
  END pc_detalhe_compr_rec_cel;

  -- Cotas de Capital
  PROCEDURE pc_detalhe_compr_capital(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                    ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK

  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_compr_capital
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;       
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_info_sac typ_reg_info_sac;     
      vr_des_erro  VARCHAR2(4000); 
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
							
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_capital:' || vr_dscritic;
							
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
						
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_detalhe_compr_capital:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
															    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
                                  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                   || '</dstippro>' ||
                                  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
																	'<dsdplano>' || TRIM(vr_protocolo(vr_ind).dsinform##3)                                                      || '</dsdplano>' ||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                      || '</nmprepos>' ||
                                  '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                      || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                      || '</nmoperad>' ||
                                  '<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                      || '</nrcpfope>' ||
                                  '<infosac>' ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>');																	
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_retxml := vr_clob;
			
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
    
  END pc_detalhe_compr_capital;

  -- GPS 
  PROCEDURE pc_detalhe_compr_pag_gps(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                    ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK

  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_compr_pag_gps
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de pagamento GPS.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusao dos campos nrcpfpre e nrcpfope, Prj. 285 (JeanMichel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;       
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);      
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
							
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_rec_cel:' || vr_dscritic;
							
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_detalhe_compr_pag_gps:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 															    
															    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
															    '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
															    '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||																 															   																 
																	'<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
                                  '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                                             || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
                                	'<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                                             || '</nrcpfope>' ||
																	'<cdbarras>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</cdbarras>' ||
																	'<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dslinhad>' ||
																	'<cdpagmto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</cdpagmto>' ||
																	'<dtcompet>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtcompet>' ||
																	'<dsidenti>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsidenti>' ||
																	'<vldoinss>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vldoinss>' ||
																	'<vloutent>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vloutent>' ||
																	'<vlatmjur>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlatmjur>' ||																																		
															    '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
																	'<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
																	'<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
																  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>');               

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_retxml := vr_clob;
			
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
    
  END pc_detalhe_compr_pag_gps;

  -- Pagamento Débito Automático
  PROCEDURE pc_detalhe_compr_pag_deb_aut(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                        ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK
  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_compr_transferencia
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;       
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);      
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_lista_compr_transferencia:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');         
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
                                  '<cdagenda>' || vr_protocolo(vr_ind).flgagend                                                                                      || '</cdagenda>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
                                  '<dscedent>' || vr_protocolo(vr_ind).dscedent                                                                                      || '</dscedent>' ||
                                  '<nridenti>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nridenti>' ||
                                  '<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
                                  '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                                             || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
                                  '<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                                             || '</nrcpfope>' ||
                                  '<infosac>' ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||                                  
                               '</dados>' );                   

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>'
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
    
  END pc_detalhe_compr_pag_deb_aut;

  -- Pagamento DARF
  PROCEDURE pc_detalhe_compr_pag_darf(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                     ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                     ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                     ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                     ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                     ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK

  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_compr_transferencia
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campo nrcpfope e nrcpfpre, Prj. 285 (Jean Michel)

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;       
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_tpcaptur INTEGER;
			vr_cdempcon INTEGER;
			vr_cdtribut INTEGER;
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);
										    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
				
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_pag_darf:' || vr_dscritic;
				
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper =>  pr_cdcooper
                                            ,pr_nrdconta =>  pr_nrdconta
                                            ,pr_dsprotoc =>  pr_dsprotoc
                                            ,pr_cdorigem =>  pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic =>  vr_cdcritic
                                            ,pr_dscritic =>  vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_detalhe_compr_pag_darf:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

 		    vr_tpcaptur := TO_NUMBER(TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##3, '#')), ':')));

        IF vr_tpcaptur = 2 THEN
					
				  vr_cdtribut := TO_NUMBER(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9, vr_protocolo(vr_ind).dsinform##3, '#')), ':')));

          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     =>
																    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																		'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																		'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																		'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																		'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
																		'<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																		'<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
																		'<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
                                    '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                                             || '</nrcpfpre>' ||
																		'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
                                    '<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                                             || '</nrcpfope>' ||
																		'<cdtipcap>' || to_char(vr_tpcaptur)                                                                                               || '</cdtipcap>' ||
																		'<nmsolici>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmsolici>' ||
																		'<cdagesic>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdagesic>' ||
																		'<cdagearr>' || TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</cdagearr>' ||																
 																		'<nmagearr>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagearr>' ||
																		'<nmagenci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmagenci>' ||
																		'<dstipdoc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<dsnomfon>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsnomfon>' ||
																		'<dtapurac>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtapurac>' ||
																		'<nrcpfcgc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrcpfcgc>');
																		
					IF vr_cdtribut = 6106 THEN 
						gene0002.pc_escreve_xml(pr_xml            => vr_clob
																	 ,pr_texto_completo => vr_xml_temp      
																	 ,pr_texto_novo     =>
																			'<nrrefere>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrrefere>' ||
																			'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
																			'<vlrecbru>0,00</vlrecbru>'                                                                                                         ||
																			'<vlpercen>0</vlpercen>');
					ELSE
						gene0002.pc_escreve_xml(pr_xml            => vr_clob
																	 ,pr_texto_completo => vr_xml_temp      
																	 ,pr_texto_novo     =>
																			'<dtvencto></dtvencto>' ||
																			'<nrrefere></nrrefere>' ||
																			'<vlrecbru>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlrecbru>' ||
																			'<vlpercen>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlpercen>');
					END IF;
				  
					gene0002.pc_escreve_xml(pr_xml            => vr_clob
																 ,pr_texto_completo => vr_xml_temp      
																 ,pr_texto_novo     =>
																'<cdtribut>' || vr_cdtribut                                                                                                            || '</cdtribut>' ||
																'<vlprinci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(12, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</vlprinci>' ||
																'<vlrmulta>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(13, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</vlrmulta>' ||
																'<vlrjuros>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(14, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</vlrjuros>' ||
																'<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                            || '</vldocmto>' ||
																'<dsdpagto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(16, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</dsdpagto>' ||
																'<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                                   || '</dttransa>' ||
																'<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                                   || '</hrautent>' ||
                                '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                          || '</nrseqaut>' ||
																'<dsautsic>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(17, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</dsautsic>' ||
																'<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                          || '</dsprotoc>' ||
															'<infosac>' ||
																	'<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
																	'<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
																	'<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
																	'<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
																	'<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
																	'<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
															'</infosac>');   
        ELSE
					
				   vr_cdempcon := TO_NUMBER(SUBSTR(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), 16, 4));
          
           gene0002.pc_escreve_xml(pr_xml            => vr_clob
																  ,pr_texto_completo => vr_xml_temp      
																  ,pr_texto_novo     => 
																		'<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																		'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																		'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																		'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																		'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
																		'<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																		'<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
																		'<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
																		'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
																		'<cdtipcap>' || to_char(vr_tpcaptur)                                                                                               || '</cdtipcap>' ||
																		'<nmsolici>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmsolici>' ||
																		'<cdagearr>' || TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</cdagearr>' ||																
																		'<nmagearr>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagearr>' ||
																		'<nmagenci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagenci>' ||
																		'<dstipdoc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<cdempcon>' || to_char(vr_cdempcon)                                                                                               || '</cdempcon>' ||																				
																		'<dsnomfon>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsnomfon>' ||
																		'<cdbarras>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
																		'<nrdocdar>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrdocdar>' ||
																		'<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
																		'<dsdpagto>' || CASE vr_cdempcon 
																												WHEN 385 THEN TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(12, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))
																												ELSE TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))
																									END                                                                                                                  || '</dsdpagto>' ||
																		'<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
																		'<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
																		'<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
																		'<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
																		'<infosac>' ||
																				'<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
																				'<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
																				'<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
																				'<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
																				'<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
																				'<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
																		'</infosac>');
        END IF;

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_retxml := vr_clob;
			
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
    
  END pc_detalhe_compr_pag_darf;

  -- Agendamento DARF
  PROCEDURE pc_detalhe_compr_age_darf(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                     ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
																		 ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                     ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                     ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                     ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK

  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_compr_transferencia
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfpre e nrcpfope, Prj. 285 (Jean Michel).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;       
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_tpcaptur INTEGER;
			vr_cdtribut INTEGER;
			vr_cdempcon INTEGER;
			vr_dtagenda VARCHAR2(15);
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);      
    
    BEGIN
    
      pr_dsretorn := 'NOK';			
			
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
				
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_age_darf:' || vr_dscritic;
				
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_detalhe_compr_age_darf:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');     
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
				
        vr_dtagenda := '';
        vr_tpcaptur := TO_NUMBER(TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##3, '#')), ':')));

        IF vr_tpcaptur = 2 THEN
					
					vr_cdtribut := TO_NUMBER(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9, vr_protocolo(vr_ind).dsinform##3, '#')), ':')));
					
					IF (TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(18, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) = 'Data do Agendamento') THEN
						vr_dtagenda := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(18, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
				  END IF;

          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     =>
																    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																		'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																		'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																		'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																		'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
																		'<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																		'<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
																		'<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
                                    '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                                             || '</nrcpfpre>' ||
																		'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
                                    '<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                                             || '</nrcpfope>' ||
																		'<cdtipcap>' || to_char(vr_tpcaptur)                                                                                               || '</cdtipcap>' ||
																		'<nmsolici>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmsolici>' ||
																		'<cdagesic>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdagesic>' ||
                                    '<cdagearr>' || TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</cdagearr>' ||
																		'<nmagearr>' || TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagearr>' ||																
																		'<nmagenci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmagenci>' ||
																		'<dstipdoc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<dsnomfon>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsnomfon>' ||
																		'<dtapurac>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtapurac>' ||
																		'<nrcpfcgc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrcpfcgc>');
																		
					IF vr_cdtribut = 6106 THEN 
						gene0002.pc_escreve_xml(pr_xml            => vr_clob
																	 ,pr_texto_completo => vr_xml_temp      
																	 ,pr_texto_novo     =>
																			'<nrrefere>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrrefere>' ||
																			'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
																			'<vlrecbru>0,00</vlrecbru>'                                                                                                         ||
																			'<vlpercen>0</vlpercen>');
					ELSE
						gene0002.pc_escreve_xml(pr_xml            => vr_clob
																	 ,pr_texto_completo => vr_xml_temp      
																	 ,pr_texto_novo     =>
																			'<dtvencto></dtvencto>' ||
																			'<nrrefere></nrrefere>' ||
																			'<vlrecbru>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlrecbru>' ||
																			'<vlpercen>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlpercen>');
					END IF;
				  
					gene0002.pc_escreve_xml(pr_xml            => vr_clob
																 ,pr_texto_completo => vr_xml_temp      
																 ,pr_texto_novo     =>
																'<cdtribut>' || vr_cdtribut                                                                                                            || '</cdtribut>' ||
																'<vlprinci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(12, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</vlprinci>' ||
																'<vlrmulta>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(13, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</vlrmulta>' ||
																'<vlrjuros>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(14, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</vlrjuros>' ||
																'<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                            || '</vldocmto>' ||
																'<dsdpagto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(16, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</dsdpagto>' ||
																'<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                                   || '</dttransa>' ||
																'<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                                   || '</hrautent>' ||																
																'<dtagenda>' || vr_dtagenda                                                                                                            || '</dtagenda>' ||
                                '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                          || '</nrseqaut>' ||
																'<dsautsic>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(17, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</dsautsic>' ||
																'<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                          || '</dsprotoc>' ||
															'<infosac>' ||
																	'<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
																	'<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
																	'<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
																	'<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
																	'<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
																	'<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
															'</infosac>');						           
        ELSE
										
          vr_cdempcon := TO_NUMBER(SUBSTR(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), 16, 4));
					 
					 IF vr_cdempcon = 385 THEN
						 IF (TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(13, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) = 'Data do Agendamento') THEN
							 vr_dtagenda := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(13, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
						 END IF;
					 ELSE 					 
						 IF (TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(12, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) = 'Data do Agendamento') THEN
							 vr_dtagenda := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(12, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
						 END IF; 
           END IF;
					 
					 gene0002.pc_escreve_xml(pr_xml            => vr_clob
																	,pr_texto_completo => vr_xml_temp      
																	,pr_texto_novo     => 
																		'<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																		'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																		'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																		'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																		'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
																		'<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																		'<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
																		'<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
																		'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
																		'<cdtipcap>' || to_char(vr_tpcaptur)                                                                                               || '</cdtipcap>' ||
																		'<nmsolici>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmsolici>' ||
																		'<cdagearr>' || TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</cdagearr>' ||
																		'<nmagearr>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagearr>' ||
																		'<nmagenci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagenci>' ||
																		'<dstipdoc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<cdempcon>' || to_char(vr_cdempcon)                                                                                               || '</cdempcon>' ||																				
																		'<dsnomfon>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsnomfon>' ||
																		'<cdbarras>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<nrdocdar>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10,vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrdocdar>' ||
																		'<nrdocdar></nrdocdar>'                                                                                                            ||
																		'<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
																		'<dsdpagto>' || CASE vr_cdempcon 
																												WHEN 385 THEN TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(12, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))
																												ELSE TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':'))
																									END                                                                                                                  || '</dsdpagto>' ||
																		'<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
																		'<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
																		'<dtagenda>' || vr_dtagenda                                                                                                        || '</dtagenda>' ||
																		'<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
																		'<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
																		'<infosac>' ||
																				'<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
																				'<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
																				'<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
																				'<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
																				'<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
																				'<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
																		'</infosac>');                                 
        END IF;      

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_retxml := vr_clob;
			
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
    
  END pc_detalhe_compr_age_darf;
  
  -- Pagamento DAS
  PROCEDURE pc_detalhe_compr_pag_das(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                    ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK
  BEGIN
    
    /* ................................................................................

     Programa: pc_lista_compr_transferencia
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel)

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;       
			vr_cdempcon INTEGER;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);      
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
			        
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_pag_das:' || vr_dscritic;
				
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_detalhe_compr_pag_das:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
				
			  vr_cdempcon := TO_NUMBER(SUBSTR(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), 16, 4));

        gene0002.pc_escreve_xml(pr_xml            => vr_clob
															 ,pr_texto_completo => vr_xml_temp      
															 ,pr_texto_novo     => 
																'<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
																'<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																'<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
																'<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
                                '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                                             || '</nrcpfpre>' ||
																'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
                                '<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                                             || '</nrcpfope>' ||
																'<nmsolici>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmsolici>' ||
																'<cdagearr>' || TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</cdagearr>' ||
																'<nmagearr>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagearr>' ||
																'<nmagenci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagenci>' ||
																'<dstipdoc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																'<cdempcon>' || to_char(vr_cdempcon)                                                                                               || '</cdempcon>' ||																				
																'<dsnomfon>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsnomfon>' ||
																'<cdbarras>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																'<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
																'<nrdocdas>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10,vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrdocdas>' ||
																'<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
																'<dsdpagto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(12,vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsdpagto>' ||
																'<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
																'<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
																'<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
																'<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
																'<infosac>' ||
																		'<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
																		'<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
																		'<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
																		'<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
																		'<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
																		'<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
																'</infosac>');
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_retxml := vr_clob;
			
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
    
  END pc_detalhe_compr_pag_das;

  -- Agendamento DAS
   PROCEDURE pc_detalhe_compr_age_das(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                     ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                     ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                     ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                     ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                     ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK

  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_compr_age_das
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Ricardo Linhares
     Data    : Junho/17.                    Ultima atualizacao: 18/10/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de tranferências.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel)

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob CLOB;       
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
			vr_cdempcon INTEGER;
			vr_dtagenda VARCHAR2(15);
      vr_info_sac typ_reg_info_sac;
      vr_des_erro  VARCHAR2(4000);      
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
			        
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_age_das:' || vr_dscritic;
				
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			
      gene0006.pc_busca_protocolo_por_protoc(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsprotoc => pr_dsprotoc
                                            ,pr_cdorigem => pr_cdorigem
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_lista_compr_transferencia:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        vr_dtagenda := '';
        vr_cdempcon := TO_NUMBER(SUBSTR(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), 16, 4));
				
				IF (TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(18, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) = 'Data do Agendamento') THEN
					vr_dtagenda := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(18, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
				END IF;

        gene0002.pc_escreve_xml(pr_xml            => vr_clob
															 ,pr_texto_completo => vr_xml_temp      
															 ,pr_texto_novo     => 
																'<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
																'<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																'<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
																'<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
                                '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                                             || '</nrcpfpre>' ||
																'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
																'<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                                             || '</nrcpfope>' ||
																'<nmsolici>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmsolici>' ||
																'<cdagearr>' || TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</cdagearr>' ||
																'<nmagearr>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagearr>' ||
																'<nmagenci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagenci>' ||
																'<dstipdoc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																'<cdempcon>' || to_char(vr_cdempcon)                                                                                               || '</cdempcon>' ||																				
																'<dsnomfon>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsnomfon>' ||
																'<cdbarras>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																'<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
																'<nrdocdas>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10,vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrdocdas>' ||
																'<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
																'<dsdpagto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(12,vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsdpagto>' ||
																'<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
																'<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
																'<dtagenda>' || vr_dtagenda                                                                                                            || '</dtagenda>' ||
																'<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
																'<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
																'<infosac>' ||
																		'<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
																		'<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
																		'<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
																		'<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
																		'<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
																		'<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
																'</infosac>');                           

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_retxml := vr_clob;
			
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
    
  END pc_detalhe_compr_age_das;

   PROCEDURE pc_detalhe_comprovante(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                   ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
																	 ,pr_cdtippro IN crappro.cdtippro%TYPE  --> Tipo do Protocolo
                                   ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                   ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                   ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                   ,pr_dsretorn OUT VARCHAR2) IS
                                   
    BEGIN
      
      CASE
        WHEN pr_cdtippro = 1 THEN
          pc_detalhe_compr_ted(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dsprotoc => pr_dsprotoc
                              ,pr_cdorigem => pr_cdorigem
                              ,pr_retxml =>   pr_retxml
                              ,pr_dsretorn => pr_dsretorn);
															
        WHEN pr_cdtippro = 2 THEN
          pc_detalhe_compr_pagamento(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dsprotoc => pr_dsprotoc
                                    ,pr_cdorigem => pr_cdorigem
                                    ,pr_retxml =>   pr_retxml
                                    ,pr_dsretorn => pr_dsretorn);
        WHEN pr_cdtippro = 3 THEN
          pc_detalhe_compr_capital(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dsprotoc => pr_dsprotoc
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_retxml =>   pr_retxml
                                  ,pr_dsretorn => pr_dsretorn);    
        WHEN pr_cdtippro = 9 THEN
          pc_detalhe_compr_ted(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dsprotoc => pr_dsprotoc
                              ,pr_cdorigem => pr_cdorigem
                              ,pr_retxml =>   pr_retxml
                              ,pr_dsretorn => pr_dsretorn);                                                                  
                              
        WHEN pr_cdtippro = 10 THEN
          pc_detalhe_compr_aplicacao_pos(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_dsprotoc => pr_dsprotoc
                                        ,pr_cdorigem => pr_cdorigem
                                        ,pr_retxml =>   pr_retxml
                                        ,pr_dsretorn => pr_dsretorn);                              
         
        WHEN pr_cdtippro = 12 THEN
          pc_detalhe_compr_res_apli_pos(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_dsprotoc => pr_dsprotoc
                                       ,pr_cdorigem => pr_cdorigem
                                       ,pr_retxml =>   pr_retxml
                                       ,pr_dsretorn => pr_dsretorn);

        WHEN pr_cdtippro = 13 THEN
          pc_detalhe_compr_pag_gps(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dsprotoc => pr_dsprotoc
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_retxml =>   pr_retxml
                                  ,pr_dsretorn => pr_dsretorn);          
         
        WHEN pr_cdtippro = 15 THEN
          pc_detalhe_compr_pag_deb_aut(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_dsprotoc => pr_dsprotoc
                                      ,pr_cdorigem => pr_cdorigem
                                      ,pr_retxml =>   pr_retxml
                                      ,pr_dsretorn => pr_dsretorn);
                                      
        WHEN pr_cdtippro = 16 THEN
          pc_detalhe_compr_pag_darf(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dsprotoc => pr_dsprotoc
                                   ,pr_cdorigem => pr_cdorigem
                                   ,pr_retxml =>   pr_retxml
                                   ,pr_dsretorn => pr_dsretorn);

        WHEN pr_cdtippro = 17 THEN
          pc_detalhe_compr_pag_das(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dsprotoc => pr_dsprotoc
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_retxml =>   pr_retxml
                                  ,pr_dsretorn => pr_dsretorn);

        WHEN pr_cdtippro = 18 THEN
          pc_detalhe_compr_age_darf(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dsprotoc => pr_dsprotoc
                                   ,pr_cdorigem => pr_cdorigem
                                   ,pr_retxml =>   pr_retxml
                                   ,pr_dsretorn => pr_dsretorn);               
                                   
        WHEN pr_cdtippro = 19 THEN
          pc_detalhe_compr_age_das(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dsprotoc => pr_dsprotoc
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_retxml =>   pr_retxml
                                  ,pr_dsretorn => pr_dsretorn);
                                  
        WHEN pr_cdtippro = 20 THEN
          pc_detalhe_compr_rec_cel(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dsprotoc => pr_dsprotoc
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_retxml =>   pr_retxml
                                  ,pr_dsretorn => pr_dsretorn);                                  
                                  
                                           
      
       END CASE;
      
    END;

END;
/
