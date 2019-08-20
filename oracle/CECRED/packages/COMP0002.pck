CREATE OR REPLACE PACKAGE CECRED.COMP0002 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COMP0002
  --  Sistema  : Rotinas para busca de comprovantes
  --  Sigla    : COMP
  --  Autor    : Ricardo Linhares
  --  Data     : Junho/2017.                   Ultima atualizacao: 14/08/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -
  -- Objetivo  : Rotinas para busca de comprovantes
  --
  -- Alteracoes: 14/08/2018 - Adicionado procedure pc_detalhe_compr_doc. (Reinert)
  ---------------------------------------------------------------------------------------------------------------
  TYPE typ_reg_info_sac IS
    RECORD(nrtelsac crapcop.nrtelsac%TYPE
          ,nrtelouv crapcop.nrtelouv%TYPE
          ,hrinisac VARCHAR2(5)
          ,hrfimsac VARCHAR2(5)
          ,hriniouv VARCHAR2(5)
          ,hrfimouv VARCHAR2(5));  
          
  TYPE typ_reg_trf_recebida IS
    RECORD(dttransa craplcm.dtmvtolt%TYPE
          ,hrautent craplcm.hrtransa%TYPE
          ,vldocmto craplcm.vllanmto%TYPE      
          ,cdbanrem crapcop.cdbcoctl%TYPE
          ,cdagerem crapcop.cdagectl%TYPE
          ,nrctarem crapass.nrdconta%TYPE
          ,dsnomrem crapass.nmprimtl%TYPE
          ,nrcpfrem crapass.nrcpfcgc%TYPE
          ,inpesrem crapass.inpessoa%TYPE      
          ,cdbandst crapcop.cdbcoctl%TYPE
          ,cdagedst crapcop.cdagectl%TYPE
          ,nrctadst crapass.nrdconta%TYPE
          ,dsnomdst crapass.nmprimtl%TYPE
          ,nrcpfdst crapass.nrcpfcgc%TYPE
          ,inpesdst crapass.inpessoa%TYPE);
          
  TYPE typ_tab_trf_recebida IS TABLE OF typ_reg_trf_recebida INDEX BY PLS_INTEGER;          
    
  FUNCTION fn_info_sac(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN typ_reg_info_sac;
		
  PROCEDURE pc_lista_comprovantes(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_dtinipro IN crappro.dtmvtolt%TYPE  --> Data inicial do protocolo
                                 ,pr_dtfimpro IN crappro.dtmvtolt%TYPE  --> Data final do protocolo
                                 ,pr_dsprotoc IN VARCHAR2 DEFAULT NULL  --> Lista de protocolos a serem buscados
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
                                              
	PROCEDURE pc_detalhe_compr_incl_debaut(pr_cdcooper  IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta  IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML
																				,pr_dsretorn OUT VARCHAR2              -- OK/NOK
                                        ,pr_dscritic OUT VARCHAR2);
																				
  PROCEDURE pc_detalhe_compr_alte_debaut(pr_cdcooper  IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta  IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML
																				,pr_dsretorn OUT VARCHAR2              -- OK/NOK
                                        ,pr_dscritic OUT VARCHAR2);	
																																							
  PROCEDURE pc_detalhe_compr_excl_debaut(pr_cdcooper  IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta  IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML
																				,pr_dsretorn OUT VARCHAR2              -- OK/NOK
                                        ,pr_dscritic OUT VARCHAR2);
																				
	PROCEDURE pc_detalhe_compr_isus_debaut(pr_cdcooper  IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta  IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML
																				,pr_dsretorn OUT VARCHAR2              -- OK/NOK
                                        ,pr_dscritic OUT VARCHAR2);	
																																						
	PROCEDURE pc_detalhe_compr_esus_debaut(pr_cdcooper  IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta  IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML
																				,pr_dsretorn OUT VARCHAR2              -- OK/NOK
                                        ,pr_dscritic OUT VARCHAR2);			
																																				
	PROCEDURE pc_detalhe_compr_bloq_debaut(pr_cdcooper  IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta  IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML
																				,pr_dsretorn OUT VARCHAR2              -- OK/NOK
                                        ,pr_dscritic OUT VARCHAR2);	
																																						
  PROCEDURE pc_detalhe_compr_libr_debaut(pr_cdcooper  IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta  IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML
																				,pr_dsretorn OUT VARCHAR2              -- OK/NOK
                                        ,pr_dscritic OUT VARCHAR2);																																							                                             
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
                                  ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                  ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                  ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                  ,pr_dsretorn OUT VARCHAR2);
                                   
  PROCEDURE pc_detalhe_compr_recebido(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da conta
                                     ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
				        						  			 ,pr_cdtippro IN crappro.cdtippro%TYPE  --> Tipo do Protocolo
                                     ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                     ,pr_cdhistor IN craphis.cdhistor%TYPE  --> Código do histórico
                                     ,pr_dttransa IN crappro.dttransa%TYPE  --> Data da transação
                                     ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                     ,pr_dsretorn OUT VARCHAR2); 
  
  -- Transferencia recebida                                       
  PROCEDURE pc_detalhe_compr_trf_recebida(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                         ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                         ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                         ,pr_cdhistor IN craphis.cdhistor%TYPE  --> Código do histórico
                                         ,pr_dttransa IN crappro.dttransa%TYPE  --> Data da transação                                                   
                                         ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                         ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                         ,pr_dsretorn OUT VARCHAR2);                                            
                                           
  -- TED Recebida
  PROCEDURE pc_detalhe_compr_ted_recebida (pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                          ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                          ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                          ,pr_dttransa IN crappro.dttransa%TYPE  --> Data da transação                                          
                                          ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                          ,pr_cdhistor IN NUMBER DEFAULT 0       --> Historico
                                          ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                          ,pr_dsretorn OUT VARCHAR2);  
                                          
  PROCEDURE pc_comprovantes_recebidos (pr_cdcooper IN crappro.cdcooper%TYPE         --> Código da cooperativa
                                      ,pr_nrdconta IN crappro.nrdconta%TYPE         --> Número da conta
                                      ,pr_cdorigem IN NUMBER                        --> Origem: 1-ayllos, 3-internet, 4-TAS
                                      ,pr_dtinipro IN crappro.dtmvtolt%TYPE         --> Data inicial do protocolo
                                      ,pr_dtfimpro IN crappro.dtmvtolt%TYPE         --> Data final do protocolo
                                      ,pr_iniconta IN NUMBER                 --> Início da conta
                                      ,pr_nrregist IN NUMBER                 --> Número de registros
                                      ,pr_protocolo OUT GENE0006.typ_tab_protocolo  --> PL Table de registros
                                      ,pr_dsretorn  OUT VARCHAR2);                                                                                                                    
                                                                  
  -- Pagamento FGTS
  PROCEDURE pc_detalhe_compr_pag_fgts( pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                      ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                      ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                      ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAA
                                      ,pr_retxml   OUT xmltype               --> Arquivo de retorno do XML                                        
                                      ,pr_dsretorn OUT VARCHAR2);            -- OK/NOK

  -- Pagamento DAE
  PROCEDURE pc_detalhe_compr_pag_dae ( pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                      ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                      ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                      ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAA
                                      ,pr_retxml   OUT xmltype               --> Arquivo de retorno do XML                                        
                                      ,pr_dsretorn OUT VARCHAR2);            -- OK/NOK                                      
                                                                                                                                                        
  PROCEDURE pc_detalhe_compr_deposito(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                     ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                     ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                     ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                     ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                     ,pr_dsretorn OUT VARCHAR2);          -- OK/NOK                                                                  
                                                                  
  PROCEDURE pc_detalhe_compr_doc ( pr_cdcooper IN craplcm.cdcooper%TYPE  --> Código da cooperativa
																	,pr_nrdconta IN craplcm.nrdconta%TYPE  --> Número da conta
																	,pr_dttransa IN craplcm.dtmvtolt%TYPE  --> Data da transação
																	,pr_cdhistor IN craplcm.cdhistor%TYPE  --> Código do histórico
																	,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Nr. documento
																	,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor de Lançamento
																	,pr_retxml   OUT xmltype               --> Arquivo de retorno do XML                                        
																	,pr_dsretorn OUT VARCHAR2);            -- OK/NOK	                                                                                                                                           
                                                                  
END COMP0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COMP0002 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COMP0002
  --  Sistema  : Rotinas para busca de comprovantes
  --  Sigla    : COMP
  --  Autor    : Ricardo Linhares
  --  Data     : Junho/2017.                   Ultima atualizacao: 14/08/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -
  -- Objetivo  : Rotinas para busca de comprovantes
  --
	-- Alteracoes: 14/08/2018 - Adicionado procedure pc_detalhe_compr_doc. (Reinert)
  --
  --             30/03/2019 - Adicionado novas informações de TEDs recebidas.
  --                          Jose Dill - Mouts (P475 - REQ40)
  --             11/06/2019 - Tratamento para listar TED Judicial.
  --                          Jose Dill - Mouts (P475 - REQ39)
  --
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
  
  FUNCTION fn_descricao(pr_protocolo IN gene0006.typ_reg_protocolo,
                        pr_realizado IN BOOLEAN) RETURN VARCHAR2 IS
    BEGIN
     DECLARE
      vr_dsprotoc  VARCHAR2(4000);
      vr_dsinfor2  VARCHAR2(4000); --> Descrição de informações      
      
      BEGIN
    
      IF pr_realizado = TRUE THEN
        CASE
          WHEN (pr_protocolo.cdtippro = 1 OR pr_protocolo.cdtippro = 4) THEN -- Transferencia Realizada
            vr_dsinfor2 := TRIM(gene0002.fn_busca_entrada(2, pr_protocolo.dsinform##2, '#'));      
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(3, pr_protocolo.dsinform##2, '#')), '-')) || '/' || TRIM(gene0002.fn_busca_entrada(2, vr_dsinfor2, ':'));
          WHEN pr_protocolo.cdtippro IN (2,6,15) THEN -- Pagamento / Convenio
            vr_dsprotoc := pr_protocolo.dscedent;          
          WHEN pr_protocolo.cdtippro = 3 THEN -- Capital;
            vr_dsprotoc := pr_protocolo.dsinform##1;
          WHEN pr_protocolo.cdtippro = 9 THEN -- TED Realizada
            /*REQ39*/
            IF UPPER(TRIM(gene0002.fn_busca_entrada(3, pr_protocolo.dsinform##3, '#'))) <> 'DEPOSITO JUDICIAL' THEN
               vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(4, pr_protocolo.dsinform##2, '#')) || ' - ' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo.dsinform##3, '#'));
            ELSE   
               vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(2, pr_protocolo.dsinform##2, '#'));
            END IF;
            
          WHEN pr_protocolo.cdtippro IN(10,12) THEN -- Aplicacao POS - Resgate
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(3, pr_protocolo.dsinform##2, '#')), '-')) || '/' || TRIM(SUBSTR(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, pr_protocolo.dsinform##2, '#')), ':')),1,10));
          WHEN pr_protocolo.cdtippro = 13 THEN -- GPS       
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(1, pr_protocolo.dsinform##2, '#'));
          WHEN pr_protocolo.cdtippro in(16, 17) THEN -- DARF / DAS
			vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(16, pr_protocolo.dsinform##3, '#')), ':'));            
          WHEN pr_protocolo.cdtippro in(18, 19) THEN -- Agendamento de DARF / DAS
            vr_dsprotoc := pr_protocolo.dscedent;
          WHEN pr_protocolo.cdtippro = 20 THEN -- Recarga
          vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(3, pr_protocolo.dsinform##2, '#')) || ' - ' || TRIM(gene0002.fn_busca_entrada(2, pr_protocolo.dsinform##2, '#'));
          WHEN pr_protocolo.cdtippro IN (23,24) THEN -- DAE/FGTS
            --> buscar texto do campo Descrição do Pagamento
            vr_dsprotoc := SUBSTR(pr_protocolo.dsinform##3,INSTR(pr_protocolo.dsinform##3,'#Descrição do Pagamento:')+1);
            vr_dsprotoc := SUBSTR(vr_dsprotoc,1,INSTR(vr_dsprotoc,'#')-1);
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(2, vr_dsprotoc, ':'));
          ELSE
           vr_dsprotoc := pr_protocolo.dsinform##2;            
         END CASE;
      ELSE -- Comprovantes Recebidos
        vr_dsprotoc := pr_protocolo.dsinform##2;
      END IF;
     
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

   -- Função para retornar a descrição do tipo de protocolo - permite a ocorrencia de acento para o novo IB
   -- Complementar sempre que necessario.
   FUNCTION fn_busca_dstippro(pr_reg_protocolo IN gene0006.typ_reg_protocolo) RETURN VARCHAR2 IS
   BEGIN
     DECLARE
       vr_dstippro varchar(1000);     
     BEGIN   
       vr_dstippro := pr_reg_protocolo.dsinform##1;
       CASE pr_reg_protocolo.cdtippro
         WHEN 1 THEN
           vr_dstippro := 'Transferência';
         WHEN 16 THEN -- Pagamento de DARF
           vr_dstippro := 'Pagamento de ' || vr_dstippro;
         WHEN 17 THEN --Pagamento de DAS
           vr_dstippro := 'Pagamento de ' || vr_dstippro;
         WHEN 23 THEN --Pagamento de DAE
           vr_dstippro := 'Pagamento de ' || vr_dstippro;
         WHEN 24 THEN --Pagamento de FGTS
           vr_dstippro := 'Pagamento de ' || vr_dstippro;
       END CASE;
       RETURN vr_dstippro;
     EXCEPTION        
        WHEN OTHERS THEN  
  				RETURN pr_reg_protocolo.dsinform##1;       
     END;
   END;

  -- Todos
    PROCEDURE pc_lista_comprovantes(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_dtinipro IN crappro.dtmvtolt%TYPE  --> Data inicial do protocolo
                                 ,pr_dtfimpro IN crappro.dtmvtolt%TYPE  --> Data final do protocolo
                                 ,pr_dsprotoc IN VARCHAR2 DEFAULT NULL  --> Lista de protocolos a serem buscados
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

     Alteracoes: 06/12/2017 - Alterado chamada da procedure GENE006.pc_lista_protocolos_por_tipos
                              (P285 - Ricardo Linhares)

                 03/01/2017 - Incluido tratativas para arrecadação de FGTS.
                              PRJ406-FGTS(Odirlei-AMcom)
     ..................................................................................*/  
    
    DECLARE
    
			vr_prot_fltr   gene0006.typ_tab_protocolo;    --> PL Table para filtrar registros (retorno protocolo)
      vr_dstransa    VARCHAR2(400);                 --> Descrição da transação
      vr_qttotreg    PLS_INTEGER;                   --> Quantidade de registros      
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_dsinfor2    VARCHAR2(4000);                --> Descrição de informações
      vr_xml_temp    VARCHAR2(32726) := '';
      vr_des_erro    VARCHAR2(4000);
      vr_dscritic    crapcri.dscritic%TYPE;
      vr_dstippro    VARCHAR2(100);
      vr_realizados  BOOLEAN;
    
    BEGIN					  
			
      IF pr_cdtipmod = 3 THEN -- Transferências Recebidas
        vr_realizados := FALSE;
        pc_comprovantes_recebidos (pr_cdcooper  => pr_cdcooper
                                  ,pr_nrdconta  => pr_nrdconta
                                  ,pr_cdorigem  => pr_cdorigem
                                  ,pr_dtinipro  => pr_dtinipro
                                  ,pr_dtfimpro  => pr_dtfimpro
                                  ,pr_iniconta  => pr_iniconta
                                  ,pr_nrregist  => pr_nrregist
                                  ,pr_protocolo => vr_prot_fltr
                                  ,pr_dsretorn  => vr_des_erro);
                                   
        -- Verifica se retornou erro
        IF TRIM(vr_des_erro) = 'NOK' THEN
          vr_des_erro := 'Não foi possível consultar os comprovantes recebidos.';        
          RAISE vr_exc_erro;
        END IF;                          
      ELSE
        vr_realizados := TRUE;
        IF pr_cdtipmod = 1 THEN -- Pagamento
          -- Pagamento (Tit/Cnv); Operações DebAut; Pagamento/Agendamento GPS; Pagamento DebAut; Pagamento DARF; Agendamento DARF; Pagamento DAS; Agendamento DAS
          vr_dstippro := '2;6;11;13;15;16;17;18;19'||
                         --;Pagamento FGTS;Pagamento DAE
                         ';24;23'; 
  			
        ELSIF pr_cdtipmod = 2 THEN -- Transferências Realizadas
  				
          vr_dstippro := '1;4;9'; --Transferência; Credito Salario; TED
  								
        ELSIF pr_cdtipmod = 4 THEN -- Investimentos
  				
          vr_dstippro := '3;10;12'; -- Capital; Aplicação Pre/Pos; Resgate Aplicação Pre/Pos
  									
        ELSIF pr_cdtipmod = 5 THEN -- Recarga de Celular

          vr_dstippro := '20'; -- Recarga de Celular

        ELSIF pr_cdtipmod = 0 THEN -- Todos
  											
          vr_dstippro := '0';

        END IF;
      
        gene0006.pc_lista_protocolos_por_tipos(pr_cdcooper  => pr_cdcooper
                                      ,pr_nrdconta  => pr_nrdconta
                                      ,pr_dtinipro  => pr_dtinipro
                                      ,pr_dtfimpro  => pr_dtfimpro
                                      ,pr_dsprotoc  => pr_dsprotoc
                                      ,pr_iniconta  => pr_iniconta - 1 /* Necessário subtrair pois o controle de paginação interno é realizado com posição inicial 0 */
                                      ,pr_nrregist  => pr_nrregist
                                      ,pr_cdtippro  => vr_dstippro 
                                      ,pr_cdorigem  => pr_cdorigem
                                      ,pr_dstransa  => vr_dstransa
                                      ,pr_dscritic  => vr_dscritic
                                      ,pr_qttotreg  => vr_qttotreg
                                      ,pr_protocolo => vr_prot_fltr
                                      ,pr_des_erro  => vr_des_erro);

        -- Verifica se retornou erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          vr_des_erro := 'Não foi possível consultar os comprovantes.';        
          RAISE vr_exc_erro;
        END IF;
        
      END IF;
        
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML   
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovantes>');   
      
      FOR vr_ind IN 1..vr_prot_fltr.count LOOP
        
        vr_dsinfor2 := TRIM(gene0002.fn_busca_entrada(2, vr_prot_fltr(vr_ind).dsinform##2, '#'));      
      
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<Comprovante>'||
                                  '<nrdocmto>' || vr_prot_fltr(vr_ind).nrdocmto                                                               || '</nrdocmto>' ||
                                  '<cdtippro>' || vr_prot_fltr(vr_ind).cdtippro                                                             	|| '</cdtippro>' ||
                                  '<dstippro>' || fn_busca_dstippro(vr_prot_fltr(vr_ind))                                                     	|| '</dstippro>' ||																																		
                                  '<dttransa>' || to_char(vr_prot_fltr(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<vldocmto>' || to_char(vr_prot_fltr(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
                                  '<dsdescri>' || fn_descricao(vr_prot_fltr(vr_ind),vr_realizados) || '</dsdescri>');     
												
        IF pr_cdtipmod = 3 THEN			-- Transferências Recebidas
					gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     =>
                                  '<cdhistor>' || vr_prot_fltr(vr_ind).cdhistor   || '</cdhistor>');             
        ELSE
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     => 
                                  '<dsprotoc>' || vr_prot_fltr(vr_ind).dsprotoc || '</dsprotoc>');
        END IF;					
        
				IF pr_cdtipmod = 5 THEN			-- Recarga de celular							
					gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     =>
                                  '<nrdddtel>' || TRIM(gene0002.fn_busca_entrada(1, vr_prot_fltr(vr_ind).nrcelular, ' ')) || '</nrdddtel>' ||
                                  '<nrtelefo>' || TRIM(gene0002.fn_busca_entrada(2, vr_prot_fltr(vr_ind).nrcelular, ' ')) || '</nrtelefo>' ||
                                  '<nmoperad>' || vr_prot_fltr(vr_ind).nmoperadora || '</nmoperad>');   
				END IF;
				
	    gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     =>   '<idlstdom>' || vr_prot_fltr(vr_ind).idlstdom || '</idlstdom>' ||
                                                       '<dsorigem>' || vr_prot_fltr(vr_ind).dsorigem || '</dsorigem>' ||
                                                     '</Comprovante>');
																			 															 				
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
      
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
							
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_transferencia:' || vr_dscritic;
							
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
								 	 						    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
								 								  '<dstippro>' || fn_busca_dstippro(vr_protocolo(vr_ind))                                                                          || '</dstippro>' ||
								 							    '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
								 							    '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||																 															   																                                
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                      || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')      || '</hrautent>' ||
                                  '<vldocmto>' ||to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
                                  '<nrctadst>' || TRIM(gene0002.fn_busca_entrada(1,gene0002.fn_busca_entrada(2, vr_dsinfor2, ':'),' - '))    || '</nrctadst>' ||
                                  '<nmtitdst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(2,gene0002.fn_busca_entrada(2, vr_dsinfor2, ':'),' - '),3)) || '</nmtitdst>' ||
                                  '<cdagedst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2,'#'),1,4))       || '</cdagedst>' ||
                                  '<nmcopdst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2,'#'),8))         || '</nmcopdst>' ||
                                  '<dttransf>' || to_char(vr_protocolo(vr_ind).dtmvtolt, 'DD/MM/RRRR')                      || '</dttransf>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                             || '</dsprotoc>' ||
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
                                 /* Projeto 363 - Novo ATM */
                                 '<idlstdom>' || vr_protocolo(vr_ind).idlstdom                                             || '</idlstdom>' ||
                                 '<dsorigem>' || vr_protocolo(vr_ind).dsorigem                                             || '</dsorigem>' ||
                                 '</dados>' );         
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_info_sac typ_reg_info_sac;     
      vr_des_erro  VARCHAR2(4000);           
      vr_cdbccxlt crapban.cdbccxlt%TYPE;
    
      FUNCTION fn_retorna_ispb(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) RETURN NUMBER IS
      BEGIN
        DECLARE          
          CURSOR cr_crapban(pr_cdbccxlt crapban.cdbccxlt%TYPE) IS
            SELECT ban.nrispbif
              FROM crapban ban
             WHERE ban.cdbccxlt = pr_cdbccxlt;
          rw_crapban cr_crapban%ROWTYPE;
        BEGIN
          OPEN cr_crapban(pr_cdbccxlt => pr_cdbccxlt);
           FETCH cr_crapban INTO rw_crapban;          
          CLOSE cr_crapban;
          RETURN nvl(rw_crapban.nrispbif,0);
        EXCEPTION
          WHEN OTHERS THEN
            RETURN 0;
        END;
      END fn_retorna_ispb;
    
    BEGIN
      
      pr_dsretorn := 'NOK';
      
			-- Buscar dados do associado
			OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
											 pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;

			IF cr_crapass%NOTFOUND THEN
				CLOSE cr_crapass;
							
				vr_dscritic := 'Associado nao cadastrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_ted:' || vr_dscritic;
							
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');       
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
      
        /* Busca codigo do banco */
        BEGIN
          vr_cdbccxlt := TO_NUMBER(TRIM(SUBSTR(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#'),1,3)));
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdbccxlt := 0;
        END;

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
								 	 						    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
								 								  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
								 							    '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
								 							    '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||																 															   																                                                               
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                      || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')      || '</hrautent>' ||
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                             || '</dsprotoc>' ||                                  
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                             || '</nrseqaut>' ||                                  
                                  '<cdbandst>' || lpad(vr_cdbccxlt,3,'0')                                                   || '</cdbandst>' ||
                                  '<dsbandst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#'),7))   || '</dsbandst>' ||                                                                   
                                  '<nrispbif>' || fn_retorna_ispb(vr_cdbccxlt)                                              || '</nrispbif>' ||
                                  '<cdagedst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2, '#'),1,4)) || '</cdagedst>' ||
                                  '<dsagedst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2, '#'),8))   || '</dsagedst>' ||                                                                    
                                  '<dsctadst>' || TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##2, '#')) || '</dsctadst>' ||
                                  '<dstitdst>' || TRIM(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##3, '#')) || '</dstitdst>' ||
                                  '<dscpfdst>' || TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')) || '</dscpfdst>' ||
                                  '<dsfinali>' || TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')) || '</dsfinali>' ||
                                  '<dsidenti>' || TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')) || '</dsidenti>' ||
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
                                 /* Projeto 363 - Novo ATM */ 
                                 '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                 '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' ||
                               '</dados>' );          
      END LOOP;
      
       gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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

                 26/03/2018 - Adicao do numero sequencial nas tags de clausula (Anderson P285).

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_info_sac typ_reg_info_sac;
      vr_des_erro VARCHAR2(4000);  
      vr_txminima VARCHAR2(100);
      vr_idxvenct INTEGER;
      vr_dsaplica crapcpc.nmprodut%TYPE;
      vr_nmdindex VARCHAR2(100);
    
      FUNCTION fn_retorna_clausulas(vr_dsaplica IN VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        DECLARE
          vr_idx PLS_INTEGER := 0;
          TYPE typ_tab_dsclausula IS TABLE of VARCHAR2(10000) INDEX BY PLS_INTEGER;
          vr_tab_dsclausula typ_tab_dsclausula;
          vr_xml VARCHAR2(32726) := '';
          
          FUNCTION fn_get_idx RETURN PLS_INTEGER IS
          BEGIN
            vr_idx := vr_idx + 1;
            RETURN vr_idx;
          END;                        
          
        BEGIN
          vr_tab_dsclausula(fn_get_idx()) := 'ATO COOPERATIVO CONFORME ART. 79 DA LEI 5764/71';
          vr_tab_dsclausula(fn_get_idx()) := 'INTRANSFERIVEL';
          vr_tab_dsclausula(fn_get_idx()) := 'DEPOSITOS EM CHEQUES SOMENTE TERAO VALIDADE APOS SUA LIQUIDACAO';
          vr_tab_dsclausula(fn_get_idx()) := 'SAQUES ANTERIORES A CARENCIA, ADMITIDOS A CRITERIO DA COOPERATIVA IMPLICAM EM PERDA DO RENDIMENTO SOBRE O VALOR SACADO';          
          IF vr_dsaplica = 'RDCPOS' THEN
            vr_tab_dsclausula(fn_get_idx()) := 'O RENDIMENTO SERA CALCULADO COM BASE NO CDI* DIARIO, CONSIDERANDO OS DIAS UTEIS DO PERIODO APLICADO E A TAXA CONTRATADA';
            vr_tab_dsclausula(fn_get_idx()) := 'OS VALORES RESGATADOS APOS A CARENCIA E ANTES DO VENCIMENTO, ADMITIDOS A CRITERIO DA COOPERATIVA, SERAO REMUNERADOS NA FORMA DO ITEM ANTERIOR, POREM, TOMANDO COMO BASE PARA CALCULO A TAXA MINIMA';
            vr_tab_dsclausula(fn_get_idx()) := 'SAQUES ANTES DO VENCIMENTO DEVERAO SER COMUNICADOS COM ANTECEDENCIA';
            vr_tab_dsclausula(fn_get_idx()) := 'CASO OCORRA O RESGATE DA APLICACAO ANTES DO PRAZO DE VENCIMENTO ACIMA ACORDADO, A ALIQUOTA DO IRRF SEGUIRA A TABELA REGRESSIVA DE RENDA FIXA VIGENTE';
          END if;
          
          FOR vr_idx IN 1..vr_tab_dsclausula.count LOOP
            vr_xml := vr_xml || 
                     '<clausula>'||
                        '<nrsequen>'|| vr_idx || '</nrsequen>' ||
                        '<dsclausu>'|| vr_tab_dsclausula(vr_idx)|| '</dsclausu>' ||
                     '</clausula>';
          END LOOP;
          
          RETURN vr_xml;
        EXCEPTION
          WHEN OTHERS THEN
            RETURN '<clausula><nrsequen>0</nrsequen><dsclausu>NAO FOI POSSIVEL MONTAR AS CLAUSULAS - ENTRE EM CONTATO COM A COOPERATIVA</dsclausu></clausula>';
        END;
      END fn_retorna_clausulas;

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
                                            ,pr_flgativo => 2 /* todos */
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_lista_compr_transferencia:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');              
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP          
          
          IF TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3,'#')) = 'N' THEN -- Aplicação de nova estrutura 
             vr_txminima := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
             vr_idxvenct := 5;  -- Posicao do vencimento dentro dentro de dsinform##3            
             vr_dsaplica := TRIM(gene0002.fn_busca_entrada(12, vr_protocolo(vr_ind).dsinform##3, '#')); 
             vr_nmdindex := ' '; 
          ELSE             
             vr_nmdindex := 'CDI - Certificado de Deposito Interfinanceiro'; 
             
             IF TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) = '7' THEN -- RDCPRE
               vr_txminima := ' '; 
               vr_idxvenct := 4;  -- Posicao do vencimento dentro dentro de dsinform##3
               vr_dsaplica := 'RDCPRE';
             ELSE
               vr_txminima := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
               vr_idxvenct := 5;  -- Posicao do vencimento dentro dentro de dsinform##3
               vr_dsaplica := 'RDCPOS';
             END IF;
          END IF;
      
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
																  '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																  '<dstippro>' || fn_busca_dstippro(vr_protocolo(vr_ind))                                                                            || '</dstippro>' ||
																  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
															 	  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
															 	  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
                                  '<nmprepos>' || vr_protocolo(vr_ind).nmprepos                                                                                      || '</nmprepos>' ||
                                  '<nrcpfpre>' || vr_protocolo(vr_ind).nrcpfpre                                                                                      || '</nrcpfpre>' ||
                                  '<nmoperad>' || vr_protocolo(vr_ind).nmoperad                                                                                      || '</nmoperad>' ||
                                  '<nrcpfope>' || vr_protocolo(vr_ind).nrcpfope                                                                                      || '</nrcpfope>' ||                                  
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<nraplica>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nraplica>' ||                                  
                                  '<dsaplica>' || vr_dsaplica                                                                                                        || '</dsaplica>' || 
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||                                  
                                  '<txcontra>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</txcontra>' ||
                                  '<txminima>' || vr_txminima                                                                                                        || '</txminima>' ||
                                  '<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(vr_idxvenct, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
                                  '<qtdiacar>' || REPLACE(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(vr_idxvenct + 1, vr_protocolo(vr_ind).dsinform##3, '#')), ':')),' DIA(S)','') || '</qtdiacar>' ||
                                  '<dtcarenc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(vr_idxvenct + 2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtcarenc>' ||                                  
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
                                  '<nmdindex>' || vr_nmdindex                                                                                                        || '</nmdindex>' ||     
                                  '<nmextcop>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(vr_idxvenct + 3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmextcop>' ||
                                  '<nrcnpjco>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(vr_idxvenct + 4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrcnpjco>' ||
                                  '<dtextens>' || TRIM(gene0002.fn_busca_entrada(vr_idxvenct + 5, vr_protocolo(vr_ind).dsinform##3,'#'))                                          || '</dtextens>' ||                                  
                                  '<clausulas>' ||
                                      fn_retorna_clausulas(vr_dsaplica) ||                                      
                                  '</clausulas>' ||
                                  '<infosac>'   ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>'  ||
                                 /* Projeto 363 - Novo ATM */ 
                                 '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                 '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' ||
                                 '</dados>' );        
                                           
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE; 
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
                                            ,pr_flgativo => 2 /* todos */
                                            ,pr_protocolo => vr_protocolo
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

      -- Verifica se retornou erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_des_erro := 'Erro em pc_lista_compr_transferencia:' || vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');  
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
      
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
																  '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
																  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
 																  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
                                  '<nmprepos>' || vr_protocolo(vr_ind).nmprepos                                                                                      || '</nmprepos>' ||
                                  '<nrcpfpre>' || vr_protocolo(vr_ind).nrcpfpre                                                                                      || '</nrcpfpre>' ||
                                  '<nmoperad>' || vr_protocolo(vr_ind).nmoperad                                                                                      || '</nmoperad>' ||
                                  '<nrcpfope>' || vr_protocolo(vr_ind).nrcpfope                                                                                      || '</nrcpfope>' ||                                  
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<nraplica>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nraplica>' ||
                                  '<vlrbruto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlrbruto>' ||
                                  '<vlrdirrf>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlrdirrf>' ||
                                  '<aliquota>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</aliquota>' ||
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
                                  '<nmextcop>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmextcop>' ||
                                  '<infosac>' ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||                                  
                                  /* Projeto 363 - Novo ATM */ 
                                  '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                  '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' ||
                                 '</dados>' );           
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
     Data    : Junho/17.                    Ultima atualizacao: 12/02/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de pagamentos.

     Observacao: -----

     Alteracoes: 18/10/2017 - Inclusão dos campos nrcpfope e nrcpfpre, Prj. 285 (Jean Michel).

                 12/02/2018 - Inclusao de detalhes para comprovamte Bancoob.
                              PRJ406-FGTS (Odirlei-AMcom)

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_dslindig VARCHAR2(100);
      vr_dsinstit VARCHAR2(100);                 --> Descrição do Banco
      vr_dscedent VARCHAR2(100);                 --> Descrição do Cedente      
      vr_nmpagado VARCHAR2(100);
      vr_nrcpfpag VARCHAR2(100);
      vr_nrcpfben VARCHAR2(100);
      vr_vltitulo VARCHAR2(100);
      vr_vlencarg VARCHAR2(100);
      vr_vldescto VARCHAR2(100);
      vr_dtvencto VARCHAR2(100);     
			vr_cdtippag INTEGER;
      vr_exc_erro EXCEPTION;       --> Controle de exceção 
      vr_contador NUMBER;     
      vr_xml_temp VARCHAR2(32726) := '';
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_info_sac typ_reg_info_sac;
      vr_des_erro VARCHAR2(4000); 
      vr_split    gene0002.typ_split := gene0002.typ_split();  
      vr_cdbarras  VARCHAR2(100);
      vr_dsdlinha  VARCHAR2(30000); 
      vr_cdorigem  INTEGER; --> Código de origem
			vr_tparrecd  crapcon.tparrecd%TYPE;
    
      --> Buscar código da agência da cooperativa cadastrada no bancoob
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
				SELECT crapcop.cdagebcb
					FROM crapcop
				 WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;            
      
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);  
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');       
                             
      FOR vr_ind IN 1..vr_protocolo.count LOOP
      
        -- Verifica se é pagamento de convênio
        vr_dslindig := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));

        IF LENGTH(vr_dslindig) = 55 THEN -- Convênio
          vr_dsinstit := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#')), ':'));
          vr_dscedent := NVL(vr_protocolo(vr_ind).dscedent,'');
					vr_cdtippag := 1;
        ELSE
          vr_dsinstit := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#')), ':'));
          vr_dscedent := vr_protocolo(vr_ind).dscedent;
					vr_cdtippag := 2;
          
          vr_split := gene0002.fn_quebra_string(pr_string  => vr_protocolo(vr_ind).dsinform##3 
                                               ,pr_delimit => '#');
          
          vr_contador := vr_split.last;
          
          IF vr_contador > 3 THEN
            vr_nmpagado := NVL(TRIM(gene0002.fn_busca_entrada(2, TRIM(vr_split(4)), ':')),'');
            vr_nrcpfpag := NVL(TRIM(gene0002.fn_busca_entrada(2, TRIM(vr_split(5)), ':')),'');
            vr_nrcpfben := NVL(TRIM(gene0002.fn_busca_entrada(2, TRIM(vr_split(10)), ':')),'');
            vr_vltitulo := NVL(TRIM(gene0002.fn_busca_entrada(2, TRIM(vr_split(7)), ':')),'0,00');
            vr_vlencarg := NVL(TRIM(gene0002.fn_busca_entrada(2, TRIM(vr_split(8)), ':')),'0,00');
            vr_vldescto := NVL(TRIM(gene0002.fn_busca_entrada(2, TRIM(vr_split(9)), ':')),'0,00');
            vr_dtvencto := NVL(TRIM(gene0002.fn_busca_entrada(2, TRIM(vr_split(6)), ':')),'');
          ELSE
            vr_nmpagado := '';
            vr_nrcpfpag := '';
            vr_nrcpfben := '';
            vr_vltitulo := '0,00';
            vr_vlencarg := '0,00';
            vr_vldescto := '0,00';
            vr_dtvencto := '';
          END IF;            
        END IF;
        
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 															 
															   '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																 '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
															   '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
															   '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
                                 '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                 '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                 '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
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
																 '<dslinhad>' || vr_dslindig                                                                                                        || '</dslinhad>' ||
																 '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||                                  
                                 '<nmprepos>' || vr_protocolo(vr_ind).nmprepos                                                                                      || '</nmprepos>' ||
                                 '<nrcpfpre>' || vr_protocolo(vr_ind).nrcpfpre                                                                                      || '</nrcpfpre>' ||
                                 '<nmoperad>' || vr_protocolo(vr_ind).nmoperad                                                                                      || '</nmoperad>' ||
                                 '<nrcpfope>' || vr_protocolo(vr_ind).nrcpfope                                                                                      || '</nrcpfope>' ||
                                 '<nmpagado>' || vr_nmpagado                                                                                                        || '</nmpagado>' ||
                                 '<nrcpfpag>' || vr_nrcpfpag                                                                                                        || '</nrcpfpag>' ||
                                 '<nrcpfben>' || vr_nrcpfben                                                                                                        || '</nrcpfben>' ||
                                 '<vltitulo>' || vr_vltitulo                                                                                                        || '</vltitulo>' ||
                                 '<vlencarg>' || vr_vlencarg                                                                                                        || '</vlencarg>' ||
                                 '<vldescto>' || vr_vldescto                                                                                                        || '</vldescto>' ||
                                 '<dtvencto>' || vr_dtvencto                                                                                                        || '</dtvencto>' ||
                                 '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                 '</infosac>' ||
                                 /* Projeto 363 - Novo ATM */ 
                                 '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                 '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' 
                                  );
      
        vr_cdbarras := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
        
        vr_tparrecd := to_number(NVL(TRIM(gene0002.fn_busca_entrada(2, REGEXP_substr(vr_protocolo(vr_ind).dsinform##3, 'Tipo Arrecadao:[^#]+'), ':')),0));
        
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
															 ,pr_texto_completo => vr_xml_temp      
															 ,pr_texto_novo     => '<tparrecd>' || to_char(vr_tparrecd) || '</tparrecd>'); 
        
        -- Caso for um convenio Bancoob
        IF vr_tparrecd = 2 THEN
				
					-- Buscar dados da cooperativa			
					OPEN cr_crapcop(pr_cdcooper);
					FETCH cr_crapcop INTO rw_crapcop;

					IF cr_crapcop%NOTFOUND THEN
						CLOSE cr_crapcop;
						        
						vr_dscritic := 'Cooperativa nao encontrada.';
						vr_des_erro := 'Erro em pc_detalhe_compr_pagamento:' || vr_dscritic;
							
						RAISE vr_exc_erro;
					ELSE
						CLOSE cr_crapcop;
					END IF;			
				
          vr_dsdlinha := NULL;      
          vr_dsdlinha := '<infbancoob>'||
												 '<nmrescen>'|| vr_protocolo(vr_ind).nmrescop_central || '</nmrescen>'||
												 '<nmextcen>'|| vr_protocolo(vr_ind).nmextcop_central || '</nmextcen>'||
												 '<nmressin>'|| vr_protocolo(vr_ind).nmrescop         || '</nmressin>';
                                          
          --Tipo de Protocolo
          vr_cdorigem := 0;
          IF vr_protocolo(vr_ind).cdtippro = 6 THEN --> TAA
            vr_cdorigem := 4;
          ELSIF vr_protocolo(vr_ind).cdtippro = 2 THEN --> Internet 
            vr_cdorigem := 3;
          END IF;
          
          IF vr_cdorigem > 0 THEN
            vr_dsdlinha := vr_dsdlinha || '<cdorigem>'|| to_char(vr_cdorigem) ||'</cdorigem>';
          END IF;
					
          vr_dsdlinha := vr_dsdlinha ||     
                           '<nrtelsac>'|| vr_protocolo(vr_ind).nrtelsac ||'</nrtelsac>'||
                           '<nrtelouv>'|| vr_protocolo(vr_ind).nrtelouv ||'</nrtelouv>'||
                           '<cdbarras>'|| vr_cdbarras ||'</cdbarras>'||		
											     '<cdagebcb>'|| rw_crapcop.cdagebcb || '</cdagebcb>' ||													 
                         '</infbancoob> ';
          
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     => vr_dsdlinha); 
        
        
        END IF;
        
      
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');  
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
															    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
                                  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                   || '</dstippro>' ||
                                  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                      || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
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
                                  '</infosac>'||
                                  /* Projeto 363 - Novo ATM */ 
                                  '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                  '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' );

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
															    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
                                  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                   || '</dstippro>' ||
                                  '<nrdplano>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdplano>' ||
                                  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                      || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                      || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
																	'<dsdplano>' || TRIM(vr_protocolo(vr_ind).dsinform##3)                                                      || '</dsdplano>' ||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||
                                  '<dtmvtolt>' || to_char(vr_protocolo(vr_ind).dtmvtolt, 'DD/MM/RRRR')                                        || '</dtmvtolt>' ||
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
                                  '</infosac>' ||
                                 /* Projeto 363 - Novo ATM */ 
                                 '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                 '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>');
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 															    
															    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
															    '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
															    '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
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
                                  '<flgagend>' || to_char(vr_protocolo(vr_ind).flgagend)                                                                             || '</flgagend>' ||
																  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||
                                  /* Projeto 363 - Novo ATM */ 
                                  '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                  '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>');

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');         
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
																  '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
																  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dtmvtolt, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                                                      || '</nrseqaut>' ||
                                  '<nmconven>' || vr_protocolo(vr_ind).dscedent                                                                                      || '</nmconven>' ||
                                  '<idconsum >' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</idconsum>' ||
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
                                 /* Projeto 363 - Novo ATM */ 
                                 '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                 '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' ||
                               '</dados>' );                   

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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

	-- Operar Débito Automático
	PROCEDURE pc_detalhe_compr_oper_debaut(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                        ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK
  BEGIN
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção 
      vr_dscritic    crapcri.dscritic%TYPE;
      vr_cdcritic    crapcri.cdcritic%TYPE;
      vr_des_erro    VARCHAR2(4000);      
    
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
        vr_des_erro := vr_dscritic || ' (' || vr_protocolo(vr_protocolo.FIRST).dsinform##1 || ')';
        RAISE vr_exc_erro;
      END IF;			                  		
			
			CASE vr_protocolo(vr_protocolo.FIRST).dsinform##1
        WHEN 'Cadastro - Inclusao' THEN
					pc_detalhe_compr_incl_debaut(pr_cdcooper  => pr_cdcooper
																			,pr_nrdconta  => pr_nrdconta
																			,pr_protocolo => vr_protocolo
																			,pr_retxml    => pr_retxml
																			,pr_dsretorn  => pr_dsretorn
																			,pr_dscritic  => vr_dscritic);
																			
				WHEN 'Cadastro - Alteracao' THEN
					pc_detalhe_compr_alte_debaut(pr_cdcooper  => pr_cdcooper
																			,pr_nrdconta  => pr_nrdconta
																			,pr_protocolo => vr_protocolo
																			,pr_retxml    => pr_retxml
																			,pr_dsretorn  => pr_dsretorn
																			,pr_dscritic  => vr_dscritic);
																			
				WHEN 'Cadastro - Exclusao' THEN
					pc_detalhe_compr_excl_debaut(pr_cdcooper  => pr_cdcooper
																			,pr_nrdconta  => pr_nrdconta
																			,pr_protocolo => vr_protocolo
																			,pr_retxml    => pr_retxml
																			,pr_dsretorn  => pr_dsretorn
																			,pr_dscritic  => vr_dscritic);
																			
				WHEN 'Suspensao - Inclusao' THEN
					pc_detalhe_compr_isus_debaut(pr_cdcooper  => pr_cdcooper
																			,pr_nrdconta  => pr_nrdconta
																			,pr_protocolo => vr_protocolo
																			,pr_retxml    => pr_retxml
																			,pr_dsretorn  => pr_dsretorn
																			,pr_dscritic  => vr_dscritic);
																			
				WHEN 'Suspensao - Exclusao' THEN
					pc_detalhe_compr_esus_debaut(pr_cdcooper  => pr_cdcooper
																			,pr_nrdconta  => pr_nrdconta
																			,pr_protocolo => vr_protocolo
																			,pr_retxml    => pr_retxml
																			,pr_dsretorn  => pr_dsretorn
																			,pr_dscritic  => vr_dscritic);
																			
				WHEN 'Bloqueio de Debito - Inclusao' THEN
					pc_detalhe_compr_bloq_debaut(pr_cdcooper  => pr_cdcooper
																			,pr_nrdconta  => pr_nrdconta
																			,pr_protocolo => vr_protocolo
																			,pr_retxml    => pr_retxml
																			,pr_dsretorn  => pr_dsretorn
																			,pr_dscritic  => vr_dscritic);
																			
				WHEN 'Bloqueio de Debito - Exclusao' THEN
					pc_detalhe_compr_libr_debaut(pr_cdcooper  => pr_cdcooper
																			,pr_nrdconta  => pr_nrdconta
																			,pr_protocolo => vr_protocolo
																			,pr_retxml    => pr_retxml
																			,pr_dsretorn  => pr_dsretorn
																			,pr_dscritic  => vr_dscritic);
																							
			END CASE;
				
			-- Verifica se retornou erro
			IF pr_dsretorn <> 'OK' OR vr_dscritic IS NOT NULL THEN
				vr_des_erro := vr_dscritic || ' (' || vr_protocolo(vr_protocolo.FIRST).dsinform##1 || ')';
				RAISE vr_exc_erro;
			END IF;       			
			
			EXCEPTION								
				WHEN vr_exc_erro THEN
					pr_retxml := '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_retxml :=   '<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>';
					pr_dsretorn := 'NOK'; 
			
			END;
			
  END pc_detalhe_compr_oper_debaut;

  PROCEDURE pc_detalhe_compr_incl_debaut(pr_cdcooper  IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta  IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML
																				,pr_dsretorn OUT VARCHAR2              -- OK/NOK
                                        ,pr_dscritic OUT VARCHAR2) IS          
  BEGIN
    
    DECLARE
		
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
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
								
				vr_des_erro := 'Associado nao cadastrado.';
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			     
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');         
      
      FOR vr_ind IN 1..pr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
				                          '<cdtippro>' || to_char(pr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
                                  '<dstippro>' || 'Cadastro de Débito Automático - Inclusão'                                                  || '</dstippro>' ||
                                  '<nrdocmto>' || to_char(pr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(pr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(pr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(pr_protocolo(vr_ind).nmrescop)                                                      || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(pr_protocolo(vr_ind).nmrescop_central)                                      || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||																	
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
																	'<nmprepos>' || to_char(pr_protocolo(vr_ind).nmprepos)                                                      || '</nmprepos>' ||
																	'<nrcpfpre>' || to_char(pr_protocolo(vr_ind).nrcpfpre)                                                      || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(pr_protocolo(vr_ind).nmoperad)                                                      || '</nmoperad>' ||
																	'<nrcpfope>' || to_char(pr_protocolo(vr_ind).nrcpfope)                                                      || '</nrcpfope>' ||
																	'<nmconven>' || to_char(pr_protocolo(vr_ind).dscedent)                                                      || '</nmconven>' ||
																	'<dttransa>' || to_char(pr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(pr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||
																	'<idconsum>' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</idconsum>' ||
																	'<vlmaxdeb>' || TRIM(gene0002.fn_busca_entrada(2, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</vlmaxdeb>' ||
																	'<dshisext>' || TRIM(gene0002.fn_busca_entrada(3, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</dshisext>' ||
                                  '<dsprotoc>' || pr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>'||
                                 /* Projeto 363 - Novo ATM */ 
                                 '<idlstdom>' || pr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                 '<dsorigem>' || pr_protocolo(vr_ind).dsorigem  || '</dsorigem>' );
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';      
    END;
    
  END pc_detalhe_compr_incl_debaut;
			
	PROCEDURE pc_detalhe_compr_alte_debaut(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2
																				,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    
    DECLARE
    
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
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
				
				vr_des_erro := 'Associado nao cadastrado.';				
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
									      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');         
      
      FOR vr_ind IN 1..pr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
				                          '<cdtippro>' || to_char(pr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
                                  '<dstippro>' || 'Cadastro de Débito Automático - Alteração'                                                 || '</dstippro>' ||
																	'<nrdocmto>' || to_char(pr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(pr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(pr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(pr_protocolo(vr_ind).nmrescop)                                                      || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(pr_protocolo(vr_ind).nmrescop_central)                                      || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||																	
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
																	'<nmprepos>' || to_char(pr_protocolo(vr_ind).nmprepos)                                                      || '</nmprepos>' ||
																	'<nrcpfpre>' || to_char(pr_protocolo(vr_ind).nrcpfpre)                                                      || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(pr_protocolo(vr_ind).nmoperad)                                                      || '</nmoperad>' ||
																	'<nrcpfope>' || to_char(pr_protocolo(vr_ind).nrcpfope)                                                      || '</nrcpfope>' ||
																	'<nmconven>' || to_char(pr_protocolo(vr_ind).dscedent)                                                      || '</nmconven>' ||
																	'<dttransa>' || to_char(pr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(pr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||
																	'<idconsum>' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</idconsum>' ||
																	'<vlmaxdeb_ant>'  || TRIM(gene0002.fn_busca_entrada(4, pr_protocolo(vr_ind).dsinform##3, '#'))              || '</vlmaxdeb_ant>'  ||
																	'<dshisext_ant>'  || TRIM(gene0002.fn_busca_entrada(2, pr_protocolo(vr_ind).dsinform##3, '#'))              || '</dshisext_ant>'  ||
																  '<vlmaxdeb_novo>' || TRIM(gene0002.fn_busca_entrada(5, pr_protocolo(vr_ind).dsinform##3, '#'))              || '</vlmaxdeb_novo>' ||
																	'<dshisext_novo>' || TRIM(gene0002.fn_busca_entrada(3, pr_protocolo(vr_ind).dsinform##3, '#'))              || '</dshisext_novo>' ||
                                  '<dsprotoc>' || pr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||
                                  /* Projeto 363 - Novo ATM */ 
                                  '<idlstdom>' || pr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                  '<dsorigem>' || pr_protocolo(vr_ind).dsorigem  || '</dsorigem>');

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';	      
    END;
    
  END pc_detalhe_compr_alte_debaut;

	PROCEDURE pc_detalhe_compr_excl_debaut(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2
																				,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    
    DECLARE
    
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
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
				
				vr_des_erro := 'Associado nao cadastrado.';				
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');         
      
      FOR vr_ind IN 1..pr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
				                          '<cdtippro>' || to_char(pr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
																	'<dstippro>' || 'Cadastro de Débito Automático - Exclusão'                                                  || '</dstippro>' ||
                                  '<nrdocmto>' || to_char(pr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(pr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(pr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(pr_protocolo(vr_ind).nmrescop)                                                      || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(pr_protocolo(vr_ind).nmrescop_central)                                      || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||																	
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
																	'<nmprepos>' || to_char(pr_protocolo(vr_ind).nmprepos)                                                      || '</nmprepos>' ||
																	'<nrcpfpre>' || to_char(pr_protocolo(vr_ind).nrcpfpre)                                                      || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(pr_protocolo(vr_ind).nmoperad)                                                      || '</nmoperad>' ||
																	'<nrcpfope>' || to_char(pr_protocolo(vr_ind).nrcpfope)                                                      || '</nrcpfope>' ||
																	'<nmconven>' || to_char(pr_protocolo(vr_ind).dscedent)                                                      || '</nmconven>' ||
																	'<dttransa>' || to_char(pr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(pr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||
																	'<idconsum>' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</idconsum>' ||
																	'<vlmaxdeb>' || TRIM(gene0002.fn_busca_entrada(2, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</vlmaxdeb>' ||
																	'<dshisext>' || TRIM(gene0002.fn_busca_entrada(3, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</dshisext>' ||
                                  '<dsprotoc>' || pr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>'||
                                  /* Projeto 363 - Novo ATM */ 
                                  '<idlstdom>' || pr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                  '<dsorigem>' || pr_protocolo(vr_ind).dsorigem  || '</dsorigem>' );
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK'; 
    END;
    
  END pc_detalhe_compr_excl_debaut;

	PROCEDURE pc_detalhe_compr_isus_debaut(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2
																				,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    
    DECLARE
    
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
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
				
        vr_des_erro := 'Associado nao cadastrado.';
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');         
      
      FOR vr_ind IN 1..pr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
				                          '<cdtippro>' || to_char(pr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
																	'<dstippro>' || 'Suspensão de Débito Automático - Inclusão'                                                 || '</dstippro>' ||
                                  '<nrdocmto>' || to_char(pr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(pr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(pr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(pr_protocolo(vr_ind).nmrescop)                                                      || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(pr_protocolo(vr_ind).nmrescop_central)                                      || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||																	
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
																	'<nmprepos>' || to_char(pr_protocolo(vr_ind).nmprepos)                                                      || '</nmprepos>' ||
																	'<nrcpfpre>' || to_char(pr_protocolo(vr_ind).nrcpfpre)                                                      || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(pr_protocolo(vr_ind).nmoperad)                                                      || '</nmoperad>' ||
																	'<nrcpfope>' || to_char(pr_protocolo(vr_ind).nrcpfope)                                                      || '</nrcpfope>' ||
																	'<nmconven>' || to_char(pr_protocolo(vr_ind).dscedent)                                                      || '</nmconven>' ||
																	'<dttransa>' || to_char(pr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(pr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||																	
																	'<idconsum>' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</idconsum>' ||
																	'<vlmaxdeb>' || TRIM(gene0002.fn_busca_entrada(2, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</vlmaxdeb>' ||
																	'<dtinisus>' || TRIM(gene0002.fn_busca_entrada(3, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</dtinisus>' ||
																	'<dtfimsus>' || TRIM(gene0002.fn_busca_entrada(4, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</dtfimsus>' ||																	
                                  '<dsprotoc>' || pr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||
                                  /* Projeto 363 - Novo ATM */ 
                                  '<idlstdom>' || pr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                  '<dsorigem>' || pr_protocolo(vr_ind).dsorigem  || '</dsorigem>' );
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';     
    END;
    
  END pc_detalhe_compr_isus_debaut;

	PROCEDURE pc_detalhe_compr_esus_debaut(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo --> registro
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2
																				,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    
    DECLARE
    
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
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
				
        vr_des_erro := 'Associado nao cadastrado.';
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
			      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');         
      
      FOR vr_ind IN 1..pr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
				                          '<cdtippro>' || to_char(pr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
																	'<dstippro>' || 'Suspensão de Débito Automático - Exclusão'                                                 || '</dstippro>' ||
                                  '<nrdocmto>' || to_char(pr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(pr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(pr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(pr_protocolo(vr_ind).nmrescop)                                                      || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(pr_protocolo(vr_ind).nmrescop_central)                                      || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||																	
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
																	'<nmprepos>' || to_char(pr_protocolo(vr_ind).nmprepos)                                                      || '</nmprepos>' ||
																	'<nrcpfpre>' || to_char(pr_protocolo(vr_ind).nrcpfpre)                                                      || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(pr_protocolo(vr_ind).nmoperad)                                                      || '</nmoperad>' ||
																	'<nrcpfope>' || to_char(pr_protocolo(vr_ind).nrcpfope)                                                      || '</nrcpfope>' ||
																	'<nmconven>' || to_char(pr_protocolo(vr_ind).dscedent)                                                      || '</nmconven>' ||
																	'<dttransa>' || to_char(pr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(pr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||																	
																	'<idconsum>' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</idconsum>' ||
																	'<vlmaxdeb>' || TRIM(gene0002.fn_busca_entrada(2, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</vlmaxdeb>' ||
																	'<dtinisus>' || TRIM(gene0002.fn_busca_entrada(3, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</dtinisus>' ||
																	'<dtfimsus>' || TRIM(gene0002.fn_busca_entrada(4, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</dtfimsus>' ||																	
                                  '<dsprotoc>' || pr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||
                                  /* Projeto 363 - Novo ATM */ 
                                  '<idlstdom>' || pr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                  '<dsorigem>' || pr_protocolo(vr_ind).dsorigem  || '</dsorigem>');
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';
    END;
    
  END pc_detalhe_compr_esus_debaut;
	
	PROCEDURE pc_detalhe_compr_bloq_debaut(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo --> registro
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2
																				,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    
    DECLARE
    
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
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
				
        vr_des_erro := 'Associado nao cadastrado.';
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');         
      
      FOR vr_ind IN 1..pr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
				                          '<cdtippro>' || to_char(pr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
																	'<dstippro>' || 'Bloqueio de Débito Automático - Inclusão'                                                  || '</dstippro>' ||
                                  '<nrdocmto>' || to_char(pr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(pr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(pr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(pr_protocolo(vr_ind).nmrescop)                                                      || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(pr_protocolo(vr_ind).nmrescop_central)                                      || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||																	
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
																	'<nmprepos>' || to_char(pr_protocolo(vr_ind).nmprepos)                                                      || '</nmprepos>' ||
																	'<nrcpfpre>' || to_char(pr_protocolo(vr_ind).nrcpfpre)                                                      || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(pr_protocolo(vr_ind).nmoperad)                                                      || '</nmoperad>' ||
																	'<nrcpfope>' || to_char(pr_protocolo(vr_ind).nrcpfope)                                                      || '</nrcpfope>' ||
																	'<nmconven>' || to_char(pr_protocolo(vr_ind).dscedent)                                                      || '</nmconven>' ||
																	'<dttransa>' || to_char(pr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(pr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||																	
																	'<idconsum>' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</idconsum>' ||
																	'<vlmaxdeb>' || TRIM(gene0002.fn_busca_entrada(2, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</vlmaxdeb>' ||
																	'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(3, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</dtvencto>' ||
																	'<vldocmto>' || TRIM(gene0002.fn_busca_entrada(4, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</vldocmto>' ||
                                  '<dsprotoc>' || pr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>'||
                                  /* Projeto 363 - Novo ATM */ 
                                  '<idlstdom>' || pr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                  '<dsorigem>' || pr_protocolo(vr_ind).dsorigem  || '</dsorigem>' );
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';
			END;
    
  END pc_detalhe_compr_bloq_debaut;
	
	PROCEDURE pc_detalhe_compr_libr_debaut(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_protocolo IN gene0006.typ_tab_protocolo --> registro
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2
																				,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    
    DECLARE
    
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
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
				
        vr_des_erro := 'Associado nao cadastrado.';
				RAISE vr_exc_erro;
			ELSE
				CLOSE cr_crapass;
			END IF;

      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');         
      
      FOR vr_ind IN 1..pr_protocolo.count LOOP

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
				                          '<cdtippro>' || to_char(pr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
																	'<dstippro>' || 'Bloqueio de Débito Automático - Exclusão'                                                  || '</dstippro>' ||																
                                  '<nrdocmto>' || to_char(pr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(pr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(pr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || to_char(pr_protocolo(vr_ind).nmrescop)                                                      || '</nmrescop>' ||
                                  '<nmrescop_central>' || to_char(pr_protocolo(vr_ind).nmrescop_central)                                      || '</nmrescop_central>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||																	
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
																	'<nmprepos>' || to_char(pr_protocolo(vr_ind).nmprepos)                                                      || '</nmprepos>' ||
																	'<nrcpfpre>' || to_char(pr_protocolo(vr_ind).nrcpfpre)                                                      || '</nrcpfpre>' ||
																	'<nmoperad>' || to_char(pr_protocolo(vr_ind).nmoperad)                                                      || '</nmoperad>' ||
																	'<nrcpfope>' || to_char(pr_protocolo(vr_ind).nrcpfope)                                                      || '</nrcpfope>' ||
																	'<nmconven>' || to_char(pr_protocolo(vr_ind).dscedent)                                                      || '</nmconven>' ||
																	'<dttransa>' || to_char(pr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(pr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||
																	'<idconsum>' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</idconsum>' ||																	
																	'<vlmaxdeb>' || TRIM(gene0002.fn_busca_entrada(2, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</vlmaxdeb>' ||
																	'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(3, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</dtvencto>' ||
																	'<vldocmto>' || TRIM(gene0002.fn_busca_entrada(4, pr_protocolo(vr_ind).dsinform##3, '#'))                   || '</vldocmto>' ||
                                  '<dsprotoc>' || pr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<infosac>'  ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||
                                  /* Projeto 363 - Novo ATM */ 
                                  '<idlstdom>' || pr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                  '<dsorigem>' || pr_protocolo(vr_ind).dsorigem  || '</dsorigem>');
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';
																 
				WHEN OTHERS THEN								
					vr_des_erro := 'Erro ao criar XML: ' || SQLERRM;
					pr_dscritic := vr_des_erro;
					pr_dsretorn := 'NOK';            
      
    END;
    
  END pc_detalhe_compr_libr_debaut;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

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
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_nrrefere VARCHAR2(50) := '';
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

 		    vr_tpcaptur := TO_NUMBER(TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##3, '#')), ':')));

        IF vr_tpcaptur = 2 THEN
					
				  vr_cdtribut := TO_NUMBER(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9, vr_protocolo(vr_ind).dsinform##3, '#')), ':')));

          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     =>
																    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																		'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																		'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																		'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																		'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                    '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                    '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
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
																		
					IF vr_cdtribut <> 6106 THEN 
            vr_nrrefere := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
						gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																	 ,pr_texto_completo => vr_xml_temp      
																	 ,pr_texto_novo     =>
																			'<nrrefere>' || vr_nrrefere || '</nrrefere>' ||
																			'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
																			'<vlrecbru>0,00</vlrecbru>'                                                                                                         ||
																			'<vlpercen>0</vlpercen>');
					ELSE
						gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																	 ,pr_texto_completo => vr_xml_temp      
																	 ,pr_texto_novo     =>
																			'<dtvencto></dtvencto>' ||
																			'<nrrefere></nrrefere>' ||
																			'<vlrecbru>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlrecbru>' ||
																			'<vlpercen>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlpercen>');
					END IF;
				  
					gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																 ,pr_texto_completo => vr_xml_temp      
																 ,pr_texto_novo     =>
																'<cdtribut>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9,  vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</cdtribut>' ||
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
          
           gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																  ,pr_texto_completo => vr_xml_temp      
																  ,pr_texto_novo     => 
																		'<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																		'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																		'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																		'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																		'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                    '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                    '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
																		'<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																		'<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
																		'<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
                                    '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                                             || '</nrcpfpre>' ||
																		'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
                                    '<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                                             || '</nrcpfope>' ||
																		'<cdtipcap>' || to_char(vr_tpcaptur)                                                                                               || '</cdtipcap>' ||
																		'<nmsolici>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmsolici>' ||
																		'<cdagearr>' || TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</cdagearr>' ||																
																		'<nmagearr>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagearr>' ||
																		'<nmagenci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagenci>' ||
																		'<dstipdoc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<cdempcon>' || to_char(vr_cdempcon)                                                                                               || '</cdempcon>' ||																				
																		'<dsnomfon>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsnomfon>' ||
																		'<cdbarras>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</cdbarras>' ||
																		'<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dslinhad>' ||
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

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => /* Projeto 363 - Novo ATM */ 
                                                     '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                                     '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' );

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_nrrefere VARCHAR2(50) := '';
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
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

          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     =>
																    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																		'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																		'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																		'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																		'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                    '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                    '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
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
																		
					IF vr_cdtribut <> 6106 THEN 
            vr_nrrefere := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
						gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																	 ,pr_texto_completo => vr_xml_temp      
																	 ,pr_texto_novo     =>
																			'<nrrefere>' || vr_nrrefere || '</nrrefere>' ||
																			'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
																			'<vlrecbru>0,00</vlrecbru>'                                                                                                         ||
																			'<vlpercen>0</vlpercen>');
					ELSE
						gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																	 ,pr_texto_completo => vr_xml_temp      
																	 ,pr_texto_novo     =>
																			'<dtvencto></dtvencto>' ||
																			'<nrrefere></nrrefere>' ||
																			'<vlrecbru>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlrecbru>' ||
																			'<vlpercen>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(11, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</vlpercen>');
					END IF;
				  
					gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																 ,pr_texto_completo => vr_xml_temp      
																 ,pr_texto_novo     =>
																'<cdtribut>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9,  vr_protocolo(vr_ind).dsinform##3, '#')), ':'))    || '</cdtribut>' ||
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
					 
					 gene0002.pc_escreve_xml(pr_xml            => pr_retxml
																	,pr_texto_completo => vr_xml_temp      
																	,pr_texto_novo     => 
																		'<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																		'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																		'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																		'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																		'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                    '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                    '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
																		'<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																		'<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
																		'<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)                                                                             || '</nmprepos>' ||
																		'<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)                                                                             || '</nrcpfpre>' ||
																		'<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)                                                                             || '</nmoperad>' ||
																		'<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)                                                                             || '</nrcpfope>' ||
																		'<cdtipcap>' || to_char(vr_tpcaptur)                                                                                               || '</cdtipcap>' ||
																		'<nmsolici>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nmsolici>' ||
																		'<cdagearr>' || TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</cdagearr>' ||
																		'<nmagearr>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagearr>' ||
																		'<nmagenci>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), '-')) || '</nmagenci>' ||
																		'<dstipdoc>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(5, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dstipdoc>' ||
																		'<cdempcon>' || to_char(vr_cdempcon)                                                                                               || '</cdempcon>' ||																				
																		'<dsnomfon>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(6, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsnomfon>' ||
																		'<cdbarras>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</cdbarras>' ||
																		'<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dslinhad>' ||
																		'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
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

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => /* Projeto 363 - Novo ATM */ 
                                                     '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                                     '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' );

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
				
			  vr_cdempcon := TO_NUMBER(SUBSTR(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), 16, 4));

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
															 ,pr_texto_completo => vr_xml_temp      
															 ,pr_texto_novo     => 
																'<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
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
																'<cdbarras>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</cdbarras>' ||
																'<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dslinhad>' ||
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
																'</infosac>'||
                                                                /* Projeto 363 - Novo ATM */ 
                                                                '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                                                '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' );
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP

        vr_dtagenda := '';
        vr_cdempcon := TO_NUMBER(SUBSTR(TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')), 16, 4));
				
				IF (TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(18, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) = 'Data do Agendamento') THEN
					vr_dtagenda := TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(18, vr_protocolo(vr_ind).dsinform##3, '#')), ':'));
				END IF;

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
															 ,pr_texto_completo => vr_xml_temp      
															 ,pr_texto_novo     => 
																'<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																'<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																'<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																'<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																'<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)                                                                             || '</nmrescop>' ||
                                '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central)                                                             || '</nmrescop_central>' ||
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
																'<cdbarras>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(7, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</cdbarras>' ||
																'<dslinhad>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(8, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dslinhad>' ||
																'<dtvencto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(9, vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dtvencto>' ||
																'<nrdocdas>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(10,vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</nrdocdas>' ||
																'<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
																'<dsdpagto>' || TRIM(gene0002.fn_busca_entrada(2, TRIM(gene0002.fn_busca_entrada(12,vr_protocolo(vr_ind).dsinform##3, '#')), ':')) || '</dsdpagto>' ||
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
																'</infosac>'||
                                                                /* Projeto 363 - Novo ATM */ 
                                                                '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                                                '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>');

      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
    
END pc_detalhe_compr_age_das;

PROCEDURE pc_detalhe_comprovante(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
    														,pr_cdtippro IN crappro.cdtippro%TYPE  --> Tipo do Protocolo
                                ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                ,pr_dsretorn OUT VARCHAR2) IS
  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_comprovante
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : David
     Data    : Outubro/17.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de detalhamento de comprovantes realizados.

     Observacao: -----

     Alteracoes: 03/01/2017 - Incluido tratativas para arrecadação de FGTS.
                              PRJ406-FGTS(Odirlei-AMcom)

     ..................................................................................*/  
    
    DECLARE                                
                                   
      vr_retxml xmltype;
                                    
                                   
    BEGIN
      
      CASE
        WHEN pr_cdtippro = 1 OR pr_cdtippro = 4 THEN
          pc_detalhe_compr_transferencia(pr_cdcooper => pr_cdcooper
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
        WHEN pr_cdtippro = 5 THEN
          pc_detalhe_compr_deposito(pr_cdcooper => pr_cdcooper
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
				WHEN pr_cdtippro = 11 THEN
					pc_detalhe_compr_oper_debaut(pr_cdcooper => pr_cdcooper
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
                                  
        WHEN pr_cdtippro = 23 THEN
          pc_detalhe_compr_pag_dae(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dsprotoc => pr_dsprotoc
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_retxml =>   vr_retxml
                                  ,pr_dsretorn => pr_dsretorn);                                  
                                           
          pr_retxml := vr_retxml.getclobval();                                  
      
        WHEN pr_cdtippro = 24 THEN
          pc_detalhe_compr_pag_fgts(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dsprotoc => pr_dsprotoc
                                  ,pr_cdorigem => pr_cdorigem
                                  ,pr_retxml =>   vr_retxml
                                  ,pr_dsretorn => pr_dsretorn);                                  
      
         pr_retxml := vr_retxml.getclobval();
       END CASE;
 
   END;
      
END pc_detalhe_comprovante;
    
-- Comprovantes recebidos  
PROCEDURE pc_detalhe_compr_recebido(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da conta
                                     ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
				        										 ,pr_cdtippro IN crappro.cdtippro%TYPE  --> Tipo do Protocolo
                                     ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                     ,pr_cdhistor IN craphis.cdhistor%TYPE  --> Código do histórico
                                     ,pr_dttransa IN crappro.dttransa%TYPE  --> Data da transação
                                     ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                     ,pr_dsretorn OUT VARCHAR2) IS
  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_comprovante
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : David
     Data    : Outubro/17.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de detalhamento de comprovantes realizados.

     Observacao: -----

     Alteracoes: 
               30/03/2019 - Adicionado novas informações de TEDs recebidas.
                            Jose Dill - Mouts (P475 - REQ40)

     ..................................................................................*/  
    
    DECLARE 
                                       
    BEGIN
      
      CASE
        WHEN pr_cdtippro = 1 THEN
          pc_detalhe_compr_trf_recebida(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrdocmto => pr_nrdocmto
                                       ,pr_cdhistor => pr_cdhistor
                                       ,pr_dttransa => pr_dttransa
                                       ,pr_cdorigem => pr_cdorigem
                                       ,pr_retxml =>   pr_retxml
                                       ,pr_dsretorn => pr_dsretorn);
															
        WHEN pr_cdtippro = 9 THEN
          pc_detalhe_compr_ted_recebida(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrdocmto => pr_nrdocmto
                                       ,pr_dttransa => pr_dttransa
                                       ,pr_cdorigem => pr_cdorigem
                                       ,pr_cdhistor => pr_cdhistor --REQ40 
                                       ,pr_retxml =>   pr_retxml
                                       ,pr_dsretorn => pr_dsretorn);      
       END CASE;

    END;       
      
END pc_detalhe_compr_recebido;    

-- Coleta dados da transferencia recebida
PROCEDURE pc_dados_compr_trf_recebida(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                     ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                     ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                     ,pr_cdhistor IN craphis.cdhistor%TYPE  --> Código do histórico
                                     ,pr_dttransa IN crappro.dttransa%TYPE  --> Data da transação                                         
                                     ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                     ,pr_trf_recebida OUT typ_tab_trf_recebida                  --> PLTable com os dados da transferência
                                     ,pr_dsretorn     OUT VARCHAR2) IS

  BEGIN
    
    /* ................................................................................

     Programa: pc_dados_compr_trf_recebida            
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : David
     Data    : Outubro/17.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de coleta de dados de transferência recebida.

     Observacao: -----

     Alteracoes: 

     ..................................................................................*/  
    
    DECLARE
       
      vr_exc_erro EXCEPTION;     
      vr_nrctarem crapass.nrdconta%TYPE;        
      
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Código da cooperativa
                        ,pr_cdagectl IN crapcop.cdagectl%TYPE) IS --> Código de agência da cooperativa na Central
        SELECT c.cdcooper
              ,c.cdbcoctl
              ,c.cdagectl
          FROM crapcop c
         WHERE (pr_cdcooper <> 0 AND c.cdcooper = pr_cdcooper)
            OR (pr_cdagectl <> 0 AND c.cdagectl = pr_cdagectl);
      rw_crapcop cr_crapcop%ROWTYPE;
      
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE     --> Código da cooperativa
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS --> Número da conta
        SELECT a.nrdconta
              ,a.nmprimtl
              ,a.nrcpfcgc
              ,a.inpessoa
          FROM crapass a
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;      
      
      CURSOR cr_craplcm (pr_cdcooper IN crappro.cdcooper%TYPE     --> Código da cooperativa
                        ,pr_nrdconta IN crappro.nrdconta%TYPE     --> Número da conta
                        ,pr_dttransa IN crappro.dttransa%TYPE     --> Data do lançamento
                        ,pr_nrdocmto IN crappro.nrdocmto%TYPE     --> Número do documento
                        ,pr_cdhistor IN craplcm.cdhistor%TYPE) IS --> Código do histórico
        SELECT l.cdcooper
              ,l.nrdconta
              ,l.nrdocmto
              ,l.dtmvtolt
              ,l.hrtransa
              ,l.vllanmto
              ,l.cdhistor
              ,l.cdpesqbb
              ,l.nrdctabb
          FROM craplcm l
         WHERE l.cdcooper = pr_cdcooper 
           AND l.nrdconta = pr_nrdconta
           AND l.dtmvtolt = pr_dttransa 
           AND l.cdhistor = pr_cdhistor
           AND l.nrdocmto = pr_nrdocmto;
      rw_craplcm cr_craplcm%ROWTYPE;
    
    BEGIN	
            
		  OPEN cr_craplcm(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dttransa => pr_dttransa
                     ,pr_nrdocmto => pr_nrdocmto
                     ,pr_cdhistor => pr_cdhistor);
      FETCH cr_craplcm INTO rw_craplcm;
      -- Se nao encontrar
      IF cr_craplcm%NOTFOUND THEN  
        CLOSE cr_craplcm;      
        RAISE vr_exc_erro; 	
      END IF;
      CLOSE cr_craplcm;     
      
      pr_trf_recebida(1).dttransa := rw_craplcm.dtmvtolt;
      pr_trf_recebida(1).hrautent := rw_craplcm.hrtransa;
      pr_trf_recebida(1).vldocmto := rw_craplcm.vllanmto;
      
      IF pr_cdhistor IN (539,1015) THEN
        OPEN cr_crapcop(pr_cdcooper => rw_craplcm.cdcooper
                       ,pr_cdagectl => 0);
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se nao encontrar
        IF cr_crapcop%NOTFOUND THEN  
          CLOSE cr_crapcop;      
          RAISE vr_exc_erro; 	
        END IF;
        CLOSE cr_crapcop;
        
        IF pr_cdhistor = 539 THEN
          vr_nrctarem := TO_NUMBER(SUBSTR(rw_craplcm.cdpesqbb,45,8));
        ELSE
          vr_nrctarem := rw_craplcm.nrdctabb;
        END IF;
        
        OPEN cr_crapass(pr_cdcooper => rw_craplcm.cdcooper
                       ,pr_nrdconta => vr_nrctarem);
        FETCH cr_crapass INTO rw_crapass;
        -- Se nao encontrar
        IF cr_crapass%NOTFOUND THEN  
          CLOSE cr_crapass;      
          RAISE vr_exc_erro; 	
        END IF;
        CLOSE cr_crapass;
        
        pr_trf_recebida(1).cdbanrem := rw_crapcop.cdbcoctl;
        pr_trf_recebida(1).cdagerem := rw_crapcop.cdagectl;
        pr_trf_recebida(1).nrctarem := rw_crapass.nrdconta;
        pr_trf_recebida(1).dsnomrem := rw_crapass.nmprimtl;
        pr_trf_recebida(1).nrcpfrem := rw_crapass.nrcpfcgc;
        pr_trf_recebida(1).inpesrem := rw_crapass.inpessoa;                
        
        OPEN cr_crapass(pr_cdcooper => rw_craplcm.cdcooper
                       ,pr_nrdconta => rw_craplcm.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        -- Se nao encontrar
        IF cr_crapass%NOTFOUND THEN  
          CLOSE cr_crapass;      
          RAISE vr_exc_erro; 	
        END IF;
        CLOSE cr_crapass;
        
        pr_trf_recebida(1).cdbandst := rw_crapcop.cdbcoctl;
        pr_trf_recebida(1).cdagedst := rw_crapcop.cdagectl;
        pr_trf_recebida(1).nrctadst := rw_crapass.nrdconta;
        pr_trf_recebida(1).dsnomdst := rw_crapass.nmprimtl;
        pr_trf_recebida(1).nrcpfdst := rw_crapass.nrcpfcgc;
        pr_trf_recebida(1).inpesdst := rw_crapass.inpessoa;
      ELSIF pr_cdhistor = 1011 THEN
        OPEN cr_crapcop(pr_cdcooper => 0
                       ,pr_cdagectl => TO_NUMBER(SUBSTR(rw_craplcm.cdpesqbb,10,4)));
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se nao encontrar
        IF cr_crapcop%NOTFOUND THEN  
          CLOSE cr_crapcop;      
          RAISE vr_exc_erro; 	
        END IF;
        CLOSE cr_crapcop;
        
        OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_nrdconta => rw_craplcm.nrdctabb);
        FETCH cr_crapass INTO rw_crapass;
        -- Se nao encontrar
        IF cr_crapass%NOTFOUND THEN  
          CLOSE cr_crapass;      
          RAISE vr_exc_erro; 	
        END IF;
        CLOSE cr_crapass;
        
        pr_trf_recebida(1).cdbanrem := rw_crapcop.cdbcoctl;
        pr_trf_recebida(1).cdagerem := rw_crapcop.cdagectl;
        pr_trf_recebida(1).nrctarem := rw_crapass.nrdconta;
        pr_trf_recebida(1).dsnomrem := rw_crapass.nmprimtl;
        pr_trf_recebida(1).nrcpfrem := rw_crapass.nrcpfcgc;
        pr_trf_recebida(1).inpesrem := rw_crapass.inpessoa;       
        
        OPEN cr_crapcop(pr_cdcooper => rw_craplcm.cdcooper
                       ,pr_cdagectl => 0);
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se nao encontrar
        IF cr_crapcop%NOTFOUND THEN  
          CLOSE cr_crapcop;      
          RAISE vr_exc_erro; 	
        END IF;
        CLOSE cr_crapcop;
        
        OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_nrdconta => rw_craplcm.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        -- Se nao encontrar
        IF cr_crapass%NOTFOUND THEN  
          CLOSE cr_crapass;      
          RAISE vr_exc_erro; 	
        END IF;
        CLOSE cr_crapass;
        
        pr_trf_recebida(1).cdbandst := rw_crapcop.cdbcoctl;
        pr_trf_recebida(1).cdagedst := rw_crapcop.cdagectl;
        pr_trf_recebida(1).nrctadst := rw_crapass.nrdconta;
        pr_trf_recebida(1).dsnomdst := rw_crapass.nmprimtl;
        pr_trf_recebida(1).nrcpfdst := rw_crapass.nrcpfcgc;
        pr_trf_recebida(1).inpesdst := rw_crapass.inpessoa;               
      ELSE
        -- Histórico incorreto
        RAISE vr_exc_erro;        
      END IF; 
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN  												
					pr_dsretorn := 'NOK';																 
				WHEN OTHERS THEN								
					pr_dsretorn := 'NOK';          
    END;          
					   
END pc_dados_compr_trf_recebida;
    
-- Transferencia recebida
PROCEDURE pc_detalhe_compr_trf_recebida(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                       ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                       ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                       ,pr_cdhistor IN craphis.cdhistor%TYPE  --> Código do histórico
                                       ,pr_dttransa IN crappro.dttransa%TYPE  --> Data da transação                                         
                                       ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                       ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                       ,pr_dsretorn OUT VARCHAR2) IS

  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_compr_trf_recebida
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : David
     Data    : Outubro/17.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de detalhamento de comprovante de transferência recebida.

     Observacao: -----

     Alteracoes: 

     ..................................................................................*/  
    
    DECLARE
    
      vr_trf_recebida typ_tab_trf_recebida;      
      vr_exc_erro EXCEPTION;       
      vr_idx      NUMBER;
      vr_xml_temp VARCHAR2(32726) := ''; 
      vr_dsretorn VARCHAR2(4000);
      vr_info_sac typ_reg_info_sac;      
    
    BEGIN	
      
      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
      pc_dados_compr_trf_recebida(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrdocmto => pr_nrdocmto
                                 ,pr_cdhistor => pr_cdhistor
                                 ,pr_dttransa => pr_dttransa
                                 ,pr_cdorigem => pr_cdorigem
                                 ,pr_trf_recebida => vr_trf_recebida
                                 ,pr_dsretorn => vr_dsretorn);
                                 
      IF vr_dsretorn <> 'OK' OR vr_trf_recebida.count = 0 THEN
        RAISE vr_exc_erro;
      END IF;
      
      vr_idx := vr_trf_recebida.FIRST;
              			     
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');       
            
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => 
                             '<dados>'||
                                '<cdtippro>1</cdtippro>' ||
                                '<dstippro>Transferência</dstippro>' ||
                                '<cdbanrem>' || LPAD(TO_CHAR(vr_trf_recebida(vr_idx).cdbanrem),3,'0') || '</cdbanrem>' ||
                                '<cdagerem>' || LPAD(TO_CHAR(vr_trf_recebida(vr_idx).cdagerem),4,'0') || '</cdagerem>' ||
                                '<nrctarem>' || TRIM(GENE0002.fn_mask_conta(vr_trf_recebida(vr_idx).nrctarem)) || '</nrctarem>' ||
                                '<nrcpfrem>' || GENE0002.fn_mask_cpf_cnpj(vr_trf_recebida(vr_idx).nrcpfrem,vr_trf_recebida(vr_idx).inpesrem) || '</nrcpfrem>' ||
                                '<nmremete>' || vr_trf_recebida(vr_idx).dsnomrem || '</nmremete>' ||
                                '<cdbandst>' || LPAD(TO_CHAR(vr_trf_recebida(vr_idx).cdbandst),3,'0') || '</cdbandst>' ||
                                '<cdagedst>' || LPAD(TO_CHAR(vr_trf_recebida(vr_idx).cdagedst),4,'0') || '</cdagedst>' ||
                                '<nrctadst>' || TRIM(GENE0002.fn_mask_conta(vr_trf_recebida(vr_idx).nrctadst)) || '</nrctadst>' ||
                                '<nrcpfdst>' || GENE0002.fn_mask_cpf_cnpj(vr_trf_recebida(vr_idx).nrcpfdst,vr_trf_recebida(vr_idx).inpesdst) || '</nrcpfdst>' ||
                                '<nmdestin>' || vr_trf_recebida(vr_idx).dsnomdst || '</nmdestin>' ||
                                '<vldocmto>' || to_char(vr_trf_recebida(vr_idx).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')  || '</vldocmto>' ||
                                '<dttransa>' || to_char(vr_trf_recebida(vr_idx).dttransa, 'DD/MM/RRRR')         || '</dttransa>' ||
                                '<hrautent>' || to_char(to_date(vr_trf_recebida(vr_idx).hrautent,'sssss'),'hh24:mi:ss') || '</hrautent>' ||                                
                                '<infosac>' ||
                                    '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                    '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                    '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                    '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                    '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                    '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                '</infosac>' ||
                             '</dados>' );         
                                   
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN  												
					pr_dsretorn := 'NOK';																 
				WHEN OTHERS THEN								
					pr_dsretorn := 'NOK';
          
    END;          
					   
END pc_detalhe_compr_trf_recebida;

-- TED Recebida
PROCEDURE pc_detalhe_compr_ted_recebida (pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                        ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                        ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                        ,pr_dttransa IN crappro.dttransa%TYPE  --> Data da transação                                          
                                        ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                        ,pr_cdhistor IN NUMBER DEFAULT 0       --> Historico
                                        ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                        ,pr_dsretorn OUT VARCHAR2) IS

  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_compr_ted_recebida
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : David
     Data    : Outubro/17.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de detalhamento de comprovante de TED recebida.

     Observacao: -----

     Alteracoes: 
               30/03/2019 - Adicionado novas informações de TEDs recebidas.
                            Jose Dill - Mouts (P475 - REQ40)
     ..................................................................................*/  
    
    DECLARE
    
      vr_tab_logspb         SSPB0001.typ_tab_logspb;   
      vr_tab_logspb_detalhe SSPB0001.typ_tab_logspb_detalhe;
      vr_tab_logspb_totais  SSPB0001.typ_tab_logspb_totais;  
      vr_tab_erro           GENE0001.typ_tab_erro;     
      
      vr_exc_erro EXCEPTION;       
      vr_xml_temp VARCHAR2(32726) := '';
      vr_dscritic VARCHAR2(1000); 
      vr_idx_ted  NUMBER := 0;
      vr_info_sac typ_reg_info_sac;     
      vr_inpesrem INTEGER := 0;
      vr_inpesdst INTEGER := 0;
      vr_finalidade VARCHAR2(100); --REQ40
      vr_pessoa_rem VARCHAR2(10); --REQ40
      vr_pessoa_dst VARCHAR2(10); --REQ40
      vr_cdagerem crapcop.cdbcoctl%type; --REQ40
      vr_nrctarem VARCHAR2(20);  --REQ40
      vr_dscpfrem VARCHAR2(100); --REQ40


    BEGIN
            
      SSPB0001.pc_obtem_log_cecred(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => 90
                                  ,pr_nrdcaixa => 900
                                  ,pr_cdoperad => 996
                                  ,pr_nmdatela => 'INTERNETBANK'
                                  ,pr_cdorigem => 0
                                  ,pr_dtmvtini => pr_dttransa
                                  ,pr_dtmvtfim => pr_dttransa
                                  ,pr_numedlog => 2
                                  ,pr_cdsitlog => 'P'
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrsequen => pr_nrdocmto
                                  ,pr_nriniseq => 0
                                  ,pr_nrregist => 9999999
                                  ,pr_inestcri => 0
                                  ,pr_cdifconv => 3
                                  ,pr_vlrdated => 0
                                  ,pr_cdhistor => pr_cdhistor --REQ40
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_logspb         => vr_tab_logspb        
                                  ,pr_tab_logspb_detalhe => vr_tab_logspb_detalhe
                                  ,pr_tab_logspb_totais  => vr_tab_logspb_totais 
                                  ,pr_tab_erro           => vr_tab_erro);
      
      IF vr_tab_logspb_detalhe.count = 0 THEN       
        RAISE vr_exc_erro;        
      END IF;     
      
      vr_idx_ted := vr_tab_logspb_detalhe.FIRST; 
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');       
  
      IF LENGTH(vr_tab_logspb_detalhe(vr_idx_ted).dscpfrem) <= 11 THEN    
        vr_inpesrem := 1; -- FISICA
      ELSE
        vr_inpesrem := 2; -- JURIDICA
      END IF;

      IF LENGTH(vr_tab_logspb_detalhe(vr_idx_ted).dscpfdst) <= 11 THEN    
        vr_inpesdst := 1; -- FISICA
      ELSE
        vr_inpesdst := 2; -- JURIDICA
      END IF;
      --
      --REQ40
      IF vr_tab_logspb_detalhe(vr_idx_ted).cdagerem = 0 THEN
         vr_cdagerem:= NULL;
      ELSE
         vr_cdagerem:=   vr_tab_logspb_detalhe(vr_idx_ted).cdagerem;
      END IF;  
 
      IF NVL(vr_tab_logspb_detalhe(vr_idx_ted).nrctarem,0) <> 0 THEN
        vr_nrctarem:= TRIM(GENE0002.fn_mask_conta(vr_tab_logspb_detalhe(vr_idx_ted).nrctarem));
      ELSE
        vr_nrctarem:= NULL;
      END IF;     
      
      IF NVL(vr_tab_logspb_detalhe(vr_idx_ted).dscpfrem,0) <> 0 THEN 
        vr_dscpfrem:= GENE0002.fn_mask_cpf_cnpj(vr_tab_logspb_detalhe(vr_idx_ted).dscpfrem,vr_inpesrem);  
      ELSE
        vr_dscpfrem:= NULL;
      END IF;      
      --
      IF NVL(pr_cdhistor,0) <> 600 THEN
        --REQ40 - Encaminhar uma lista (array) com o label e o valor do campo. Se o valor estiver nulo, a informação não deverá ser incluída no xml
        vr_finalidade := tabe0001.fn_busca_dstextab( pr_cdcooper => 1
                                                    ,pr_nmsistem => 'CRED'
                                                    ,pr_tptabela => 'GENERI'
                                                    ,pr_cdempres => 00
                                                    ,pr_cdacesso => 'FINTRFTEDS'
                                                    ,pr_tpregist => vr_tab_logspb_detalhe(vr_idx_ted).finalid   );

        IF vr_tab_logspb_detalhe(vr_idx_ted).tpesdst = 'J' THEN
          vr_pessoa_dst := 'Juridica';
        ELSE
          vr_pessoa_dst := 'Fisica';
        END IF;  
        IF vr_tab_logspb_detalhe(vr_idx_ted).tpesrem = 'J' THEN
          vr_pessoa_rem := 'Juridica';
        ELSE
          vr_pessoa_rem := 'Fisica';
        END IF; 
      ELSE
        vr_cdagerem:= NULL;
        vr_nrctarem:= NULL;
        vr_dscpfrem:= NULL;
                  
      END IF; 
              
  
         
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => 
                             '<dados>'||
                                '<cdtippro>9</cdtippro>' ||
                                '<dstippro>' || vr_tab_logspb_detalhe(vr_idx_ted).dstiptra || '</dstippro>' ||
                                '<cdbanrem>' || LPAD(TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).cdbanrem),3,0) || '</cdbanrem>' ||
                                --'<cdagerem>' || NVL(LPAD(TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).cdagerem),4,0),'') || '</cdagerem>' ||
                                '<cdagerem>' || LPAD(TO_CHAR(vr_cdagerem),4,0) || '</cdagerem>' ||                                
                                '<nrctarem>' || vr_nrctarem || '</nrctarem>' ||                       
                                --'<nrctarem>' || TRIM(GENE0002.fn_mask_conta(vr_tab_logspb_detalhe(vr_idx_ted).nrctarem)) || '</nrctarem>' ||
                                --'<nrcpfrem>' || GENE0002.fn_mask_cpf_cnpj(vr_tab_logspb_detalhe(vr_idx_ted).dscpfrem,vr_inpesrem) || '</nrcpfrem>' ||
                                '<nrcpfrem>' ||   vr_dscpfrem || '</nrcpfrem>' ||
                                
                                --'<nrcpfrem>' || TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).dscpfrem) || '</nrcpfrem>' || JMD
                                '<nmremete>' || vr_tab_logspb_detalhe(vr_idx_ted).dsnomrem || '</nmremete>' ||
                                '<cdbandst>' || LPAD(TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).cdbandst),3,0) || '</cdbandst>' ||
                                '<cdagedst>' || LPAD(TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).cdagedst),4,0) || '</cdagedst>' ||
                                '<nrctadst>' || TRIM(GENE0002.fn_mask_conta(vr_tab_logspb_detalhe(vr_idx_ted).nrctadst)) || '</nrctadst>' ||
                                '<nrcpfdst>' || GENE0002.fn_mask_cpf_cnpj(vr_tab_logspb_detalhe(vr_idx_ted).dscpfdst,vr_inpesdst) || '</nrcpfdst>' ||
                                --'<nrcpfdst>' || TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).dscpfdst) || '</nrcpfdst>' || JMD
                                '<nmdestin>' || vr_tab_logspb_detalhe(vr_idx_ted).dsnomdst || '</nmdestin>' ||
                                '<vldocmto>' || to_char(vr_tab_logspb_detalhe(vr_idx_ted).vltransa,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')  || '</vldocmto>' ||
                                '<dttransa>' || to_char(vr_tab_logspb_detalhe(vr_idx_ted).dttransa, 'DD/MM/RRRR')         || '</dttransa>' ||
                                '<hrautent>' || to_char(to_date(vr_tab_logspb_detalhe(vr_idx_ted).hrtransa,'sssss'),'hh24:mi:ss') || '</hrautent>' ||                                
                                --REQ40 - Novas informações para o recebimento de TEDs
                                '<tpctarem>'||vr_tab_logspb_detalhe(vr_idx_ted).tpctrem||'</tpctarem>'||
                                '<tppesrem>'||vr_pessoa_rem||'</tppesrem>'||
                                '<tpctadst>'||vr_tab_logspb_detalhe(vr_idx_ted).tpctdst||'</tpctadst>'||
                                '<tppesdst>'||vr_pessoa_dst||'</tppesdst>'||                               
                                '<dsfinali>'||vr_finalidade||'</dsfinali>'||
                                '<dsindeti>'||vr_tab_logspb_detalhe(vr_idx_ted).cdidtra||'</dsindeti>'||
                                '<dshistor>'||vr_tab_logspb_detalhe(vr_idx_ted).histori||'</dshistor>'||
                                '<nrctrcre>'||LTRIM(vr_tab_logspb_detalhe(vr_idx_ted).nropecr)||'</nrctrcre>'||
                                '<dsmotdev>'||LTRIM(vr_tab_logspb_detalhe(vr_idx_ted).cddvtra)||'</dsmotdev>'||
                                '<infosac>' ||
                                    '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                    '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                    '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                    '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                    '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                    '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                '</infosac>' ||
                             '</dados>' );         
                                   
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
                             ,pr_fecha_xml      => TRUE);      
                             
      pr_dsretorn := 'OK';   
       
      EXCEPTION								
				WHEN vr_exc_erro THEN  												
					pr_dsretorn := 'NOK';																 
				WHEN OTHERS THEN								
					pr_dsretorn := 'NOK';
      
    END;
    
  END pc_detalhe_compr_ted_recebida;    
  
  PROCEDURE pc_comprovantes_recebidos (pr_cdcooper IN crappro.cdcooper%TYPE         --> Código da cooperativa
                                      ,pr_nrdconta IN crappro.nrdconta%TYPE         --> Número da conta
                                      ,pr_cdorigem IN NUMBER                        --> Origem: 1-ayllos, 3-internet, 4-TAS
                                      ,pr_dtinipro IN crappro.dtmvtolt%TYPE         --> Data inicial do protocolo
                                      ,pr_dtfimpro IN crappro.dtmvtolt%TYPE         --> Data final do protocolo
                                      ,pr_iniconta IN NUMBER                 --> Início da conta
                                      ,pr_nrregist IN NUMBER                 --> Número de registros
                                      ,pr_protocolo OUT GENE0006.typ_tab_protocolo  --> PL Table de registros
                                      ,pr_dsretorn  OUT VARCHAR2) IS

  BEGIN
    
    /* ................................................................................

     Programa: pc_comprovantes_recebidos
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : David
     Data    : Outubro/17.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de comprovantes recebidos.

     Observacao: -----

     Alteracoes: 

     ..................................................................................*/  
    
    DECLARE    
      
      TYPE typ_reg_trf IS
      RECORD(cdtippro crappro.cdtippro%TYPE            
            ,dttransa crappro.dttransa%TYPE
            ,hrautent crappro.hrautent%TYPE
            ,vldocmto crappro.vldocmto%TYPE
            ,nrdocmto crappro.nrdocmto%TYPE
            ,dsinform##1 crappro.dsinform##1%TYPE
            ,dsinform##2 crappro.dsinform##2%TYPE
            ,cdhistor craphis.cdhistor%TYPE);
      TYPE typ_tab_trf IS TABLE OF typ_reg_trf INDEX BY VARCHAR(40);    
      
      vr_trf_recebida       typ_tab_trf_recebida;    
      vr_filtro_trf         typ_tab_trf;
      vr_tab_logspb         SSPB0001.typ_tab_logspb;   
      vr_tab_logspb_detalhe SSPB0001.typ_tab_logspb_detalhe;
      vr_tab_logspb_totais  SSPB0001.typ_tab_logspb_totais;  
      vr_tab_erro           GENE0001.typ_tab_erro;      
      
      vr_des_erro   VARCHAR2(4000);   
      vr_dscritic   VARCHAR2(1000);   
      vr_idx        VARCHAR2(40);      
      vr_idx_ted    VARCHAR2(30);
      vr_qtregist   NUMBER := 0;
      vr_idx_pro    NUMBER := 0;
      
      CURSOR cr_compr_recebidos (pr_cdcooper IN crappro.cdcooper%TYPE      --> Código da cooperativa
                                ,pr_nrdconta IN crappro.nrdconta%TYPE      --> Número da conta
                                ,pr_dtfimpro IN crappro.dtmvtolt%TYPE      --> Data final do protocolo
                                ,pr_dtinipro IN crappro.dttransa%TYPE) IS  --> Data inicial do protocolo
        SELECT l.cdcooper
              ,l.nrdconta
              ,l.nrdocmto
              ,l.dtmvtolt
              ,l.hrtransa
              ,l.vllanmto
              ,l.cdhistor
          FROM craplcm l
         WHERE l.cdcooper = pr_cdcooper 
           AND l.nrdconta = pr_nrdconta
           AND l.dtmvtolt BETWEEN pr_dtinipro AND pr_dtfimpro
           AND l.cdhistor IN (539,1011,1015)
      ORDER BY l.dtmvtolt DESC
              ,l.hrtransa DESC;
      rw_compr_recebidos cr_compr_recebidos%ROWTYPE;
    
    BEGIN
      
      -- Consultar Transferências
      FOR rw_compr_recebidos IN cr_compr_recebidos (pr_cdcooper => pr_cdcooper
                                                   ,pr_nrdconta => pr_nrdconta
                                                   ,pr_dtfimpro => pr_dtfimpro
                                                   ,pr_dtinipro => pr_dtinipro) LOOP
                                                   
          pc_dados_compr_trf_recebida(pr_cdcooper => rw_compr_recebidos.cdcooper
                                     ,pr_nrdconta => rw_compr_recebidos.nrdconta
                                     ,pr_nrdocmto => rw_compr_recebidos.nrdocmto
                                     ,pr_cdhistor => rw_compr_recebidos.cdhistor
                                     ,pr_dttransa => rw_compr_recebidos.dtmvtolt
                                     ,pr_cdorigem => pr_cdorigem
                                     ,pr_trf_recebida => vr_trf_recebida
                                     ,pr_dsretorn => vr_des_erro);
                                 
          IF vr_des_erro <> 'OK' OR vr_trf_recebida.count = 0 THEN
            CONTINUE;
          END IF;
      
          vr_idx_pro := vr_trf_recebida.FIRST;
        
          vr_idx := TO_CHAR(rw_compr_recebidos.dtmvtolt,'RRRRmmdd') || 
                    TO_CHAR(TO_DATE(rw_compr_recebidos.hrtransa,'sssss'),'hh24miss') ||
                    '1' ||
                    LPAD(TO_CHAR(rw_compr_recebidos.nrdocmto),25,'0'); 
                    
          vr_filtro_trf(vr_idx).cdtippro := 1;
          vr_filtro_trf(vr_idx).dttransa := rw_compr_recebidos.dtmvtolt;
          vr_filtro_trf(vr_idx).hrautent := rw_compr_recebidos.hrtransa;
          vr_filtro_trf(vr_idx).vldocmto := rw_compr_recebidos.vllanmto;
          vr_filtro_trf(vr_idx).nrdocmto := rw_compr_recebidos.nrdocmto;
          vr_filtro_trf(vr_idx).cdhistor := rw_compr_recebidos.cdhistor;
          vr_filtro_trf(vr_idx).dsinform##1 := 'Transferência';
          vr_filtro_trf(vr_idx).dsinform##2 := LPAD(TO_CHAR(vr_trf_recebida(vr_idx_pro).cdagerem),4,'0') || '/' ||
                                               TRIM(GENE0002.fn_mask_conta(vr_trf_recebida(vr_idx_pro).nrctarem)) || ' - ' ||
                                               vr_trf_recebida(vr_idx_pro).dsnomrem;
      
      END LOOP;
      
      -- Consultar TEDs
      SSPB0001.pc_obtem_log_cecred(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => 90
                                  ,pr_nrdcaixa => 900
                                  ,pr_cdoperad => 996
                                  ,pr_nmdatela => 'INTERNETBANK'
                                  ,pr_cdorigem => 0
                                  ,pr_dtmvtini => pr_dtinipro
                                  ,pr_dtmvtfim => pr_dtfimpro
                                  ,pr_numedlog => 2
                                  ,pr_cdsitlog => 'P'
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrsequen => 0
                                  ,pr_nriniseq => 0
                                  ,pr_nrregist => 999999999
                                  ,pr_inestcri => 0
                                  ,pr_cdifconv => 3
                                  ,pr_vlrdated => 0
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_tab_logspb         => vr_tab_logspb        
                                  ,pr_tab_logspb_detalhe => vr_tab_logspb_detalhe
                                  ,pr_tab_logspb_totais  => vr_tab_logspb_totais 
                                  ,pr_tab_erro           => vr_tab_erro);
      
      IF vr_tab_logspb_detalhe.count > 0 THEN       
        vr_idx_ted := vr_tab_logspb_detalhe.FIRST;

        --Percorrer todos os registros
        WHILE vr_idx_ted IS NOT NULL LOOP
          
          vr_idx := TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).dttransa,'RRRRmmdd') || 
                    TO_CHAR(TO_DATE(vr_tab_logspb_detalhe(vr_idx_ted).hrtransa,'sssss'),'hh24miss') ||
                    '9' ||
                    LPAD(TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).nrseqlog),25,'0');
                    
          vr_filtro_trf(vr_idx).cdtippro := 9;
          vr_filtro_trf(vr_idx).dttransa := vr_tab_logspb_detalhe(vr_idx_ted).dttransa;
          vr_filtro_trf(vr_idx).hrautent := vr_tab_logspb_detalhe(vr_idx_ted).hrtransa;
          vr_filtro_trf(vr_idx).vldocmto := vr_tab_logspb_detalhe(vr_idx_ted).vltransa;
          vr_filtro_trf(vr_idx).nrdocmto := vr_tab_logspb_detalhe(vr_idx_ted).nrseqlog;
          vr_filtro_trf(vr_idx).cdhistor := 0;
          vr_filtro_trf(vr_idx).dsinform##1 := vr_tab_logspb_detalhe(vr_idx_ted).dstiptra; 
          vr_filtro_trf(vr_idx).dsinform##2 := TRIM(GENE0002.fn_mask_conta(vr_tab_logspb_detalhe(vr_idx_ted).nrctarem)) || ' - ' ||
                                               vr_tab_logspb_detalhe(vr_idx_ted).dsnomrem;
          
          vr_idx_ted := vr_tab_logspb_detalhe.NEXT(vr_idx_ted);
        
        END LOOP;
      END IF;  
      
      vr_idx := vr_filtro_trf.FIRST;
      
      --Percorrer todos os registros
      WHILE vr_idx IS NOT NULL LOOP     
        
        vr_qtregist := vr_qtregist + 1; 
        
        IF (vr_qtregist < pr_iniconta) OR (vr_qtregist >= (pr_iniconta + pr_nrregist)) THEN
          vr_idx := vr_filtro_trf.NEXT(vr_idx);
          CONTINUE;
        END IF;   
        
        vr_idx_pro := pr_protocolo.count + 1;
                         
        pr_protocolo(vr_idx_pro).cdtippro := vr_filtro_trf(vr_idx).cdtippro;
        pr_protocolo(vr_idx_pro).dttransa := vr_filtro_trf(vr_idx).dttransa;
        pr_protocolo(vr_idx_pro).hrautent := vr_filtro_trf(vr_idx).hrautent;
        pr_protocolo(vr_idx_pro).vldocmto := vr_filtro_trf(vr_idx).vldocmto;
        pr_protocolo(vr_idx_pro).nrdocmto := vr_filtro_trf(vr_idx).nrdocmto;
        pr_protocolo(vr_idx_pro).cdhistor := vr_filtro_trf(vr_idx).cdhistor;
        pr_protocolo(vr_idx_pro).dsinform##1 := vr_filtro_trf(vr_idx).dsinform##1;        
        pr_protocolo(vr_idx_pro).dsinform##2 := vr_filtro_trf(vr_idx).dsinform##2;
        
        vr_idx := vr_filtro_trf.NEXT(vr_idx);
        
      END LOOP;
      
      dbms_output.put_line(to_char(pr_protocolo.count));
                             
      pr_dsretorn := 'OK';
       
      EXCEPTION				
				WHEN OTHERS THEN
					pr_dsretorn := 'NOK';                                                              
    END;
    
END pc_comprovantes_recebidos;    

  -- Pagamento FGTS
  PROCEDURE pc_detalhe_compr_pag_fgts( pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                      ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                      ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                      ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                      ,pr_retxml   OUT xmltype              --> Arquivo de retorno do XML                                        
                                      ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK
    
    /* ................................................................................

     Programa: pc_detalhe_compr_pag_fgts
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Odirlei Busana -  AMcom
     Data    : Janeiro/2018.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de Pagamento FGTS.

     Observacao: -----

     Alteracoes: 

     ..................................................................................*/  
    
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp    VARCHAR2(32726) := '';
      vr_dsdlinha    VARCHAR2(32726) := '';
      vr_cdempcon    INTEGER;
      vr_dscritic    VARCHAR2(4000);
      vr_cdcritic    crapcri.cdcritic%TYPE;
      vr_info_sac    typ_reg_info_sac;
      vr_des_erro    VARCHAR2(4000);
      vr_cdtipdoc    VARCHAR2(100);
      vr_retxml      CLOB;
      vr_dataaux     DATE;
      
      
      TYPE typ_tab_campos IS TABLE OF VARCHAR2(2000)
           INDEX BY VARCHAR2(40);
      vr_tab_campos typ_tab_campos;
      vr_idx VARCHAR2(40);
      vr_split_reg   gene0002.typ_split;
      vr_split_campo gene0002.typ_split;
            
      --> Buscar código da agência da cooperativa cadastrada no bancoob
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
				SELECT crapcop.cdagebcb
					FROM crapcop
				 WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;            
    
  BEGIN
    
    pr_dsretorn := 'NOK';
			
    -- Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
			        
      vr_dscritic := 'Associado nao cadastrado.';
      vr_des_erro := 'Erro em pc_detalhe_compr_pag_fgts:' || vr_dscritic;
				
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
		
		-- Buscar dados da cooperativa			
		OPEN cr_crapcop(pr_cdcooper);
		FETCH cr_crapcop INTO rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
			        
      vr_dscritic := 'Cooperativa nao encontrada.';
      vr_des_erro := 'Erro em pc_detalhe_compr_pag_fgts:' || vr_dscritic;
				
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
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
      vr_des_erro := 'Erro em pc_detalhe_compr_pag_fgts:' || vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
                      
    vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
    dbms_lob.createtemporary(vr_retxml, TRUE);
    dbms_lob.open(vr_retxml, dbms_lob.lob_readwrite);
       
     -- Criar cabecalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<Comprovante>');        
      
    FOR vr_ind IN 1..vr_protocolo.count LOOP
				
      vr_tab_campos.delete;
    
      --> Quebrar registros para não pegar posicional, evitando que se mudem a ordem ou incluam campo e prejudique o programa
      vr_split_reg := gene0002.fn_quebra_string(vr_protocolo(vr_ind).dsinform##3,'#');
      
      --> Varrer dados
      IF vr_split_reg.count > 0 THEN
        FOR i IN vr_split_reg.first..vr_split_reg.last LOOP
          vr_split_campo := NULL;
          vr_split_campo := gene0002.fn_quebra_string(vr_split_reg(i),':');
          
          IF vr_split_campo.count > 0 THEN
          
            --> Montar index, conforme label do campo
            vr_split_campo(1) := upper(REPLACE(vr_split_campo(1),':'));        
            CASE vr_split_campo(1)
              WHEN 'TIPO DE DOCUMENTO' THEN
                vr_idx := 'DSTIPDOC';            
              WHEN 'CÓDIGO DE BARRAS' THEN
                vr_idx := 'CDBARRAS';
              WHEN 'LINHA DIGITÁVEL' THEN
                vr_idx := 'DSLINHAD';
              WHEN 'CNPJ/CEI EMPRESA' THEN
                vr_idx := 'NRIDENTIFICACAO';
              WHEN 'COD. CONVÊNIO' THEN
                vr_idx := 'CDEMPCON';
              WHEN 'DATA DA VALIDADE' THEN
                vr_idx := 'DTVENCTO';
              WHEN 'COMPETÊNCIA' THEN
                vr_idx := 'COMPETENCIA';
              WHEN 'IDENTIFICADOR' THEN
                vr_idx := 'IDENTIFICADOR';
              WHEN 'VALOR TOTAL' THEN
                vr_idx := 'VLDOCMTO';
              WHEN 'DESCRIÇÃO DO PAGAMENTO' THEN
                vr_idx := 'DSDPAGTO';
              WHEN 'DATA DO PAGAMENTO' THEN
                vr_idx := 'DTTRANSA';
              WHEN 'HORARIO DO PAGAMENTO' THEN
                vr_idx := 'HRAUTENT';
              WHEN 'CANAL DE RECEBIMENTO' THEN
                vr_idx := 'DSORIGEM';              
              ELSE
                vr_idx := NULL;
            END CASE;  
          
            IF vr_idx IS NOT NULL THEN
              vr_tab_campos(vr_idx) := vr_split_campo(2);          
            END IF;
             
          END IF;
        END LOOP;
      END IF;
      
      vr_dsdlinha := '';
      vr_dsdlinha := '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                  || '</cdtippro>' ||
                     '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)        || '</dstippro>' ||
                     '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)           || '</nrdocmto>' ||
                     '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)           || '</cdbcoctl>' ||
                     '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)           || '</cdagectl>' ||
                     '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)           || '</nmrescop>' ||
                     '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central) || '</nmrescop_central>' ||
                     '<nrdconta>' || to_char(pr_nrdconta)                             || '</nrdconta>' ||
                     '<nmtitula>' || to_char(rw_crapass.nmextttl)                     || '</nmtitula>' ||
                     '<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)           || '</nmprepos>' ||
                     '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)           || '</nrcpfpre>' ||
                     '<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)           || '</nmoperad>' ||
                     '<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)           || '</nrcpfope>' ;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha); 
                                    
      vr_dsdlinha := '';
      IF vr_tab_campos.exists(UPPER('dstipdoc')) THEN
        vr_dsdlinha := vr_dsdlinha || '<dstipdoc>' || vr_tab_campos(UPPER('dstipdoc')) || '</dstipdoc>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('cdbarras')) THEN
        vr_dsdlinha := vr_dsdlinha || '<cdbarras>' || vr_tab_campos(UPPER('cdbarras')) || '</cdbarras>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('dslinhad')) THEN
        vr_dsdlinha := vr_dsdlinha || '<dslinhad>' || vr_tab_campos(UPPER('dslinhad')) || '</dslinhad>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('nridentificacao')) THEN
        vr_dsdlinha := vr_dsdlinha || '<nridentificacao>' || vr_tab_campos(UPPER('nridentificacao')) || '</nridentificacao>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('cdempcon')) THEN
        vr_dsdlinha := vr_dsdlinha || '<cdempcon>' || vr_tab_campos(UPPER('cdempcon')) || '</cdempcon>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('dtvencto')) THEN
        vr_dsdlinha := vr_dsdlinha || '<dtvencto>' || vr_tab_campos(UPPER('dtvencto')) || '</dtvencto>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('competencia')) THEN
      
        IF vr_tab_campos.exists(UPPER('cdempcon')) AND 
           vr_tab_campos(UPPER('cdempcon')) IN (0178,0240) THEN
          vr_dsdlinha := vr_dsdlinha || '<nrseqgrde>' || vr_tab_campos(UPPER('competencia')) || '</nrseqgrde>';
        ELSE
          BEGIN
            vr_dataaux := to_date('01/'||TRIM(vr_tab_campos(UPPER('competencia'))),'DD/MM/RRRR');
          EXCEPTION 
            WHEN OTHERS THEN
              vr_dataaux := vr_tab_campos(UPPER('competencia'));
          END;
          vr_dsdlinha := vr_dsdlinha || '<competencia>' || to_char(vr_dataaux,'DD/MM/RRRR')  || '</competencia>';
        END IF;
      END IF;
      
      IF vr_tab_campos.exists(UPPER('identificador')) THEN
        vr_dsdlinha := vr_dsdlinha || '<identificador>' || vr_tab_campos(UPPER('identificador')) || '</identificador>';
      END IF;
      
      vr_dsdlinha := vr_dsdlinha ||'<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>';
      
      IF vr_tab_campos.exists(UPPER('dsdpagto')) THEN
        vr_dsdlinha := vr_dsdlinha || '<dsdpagto>' || vr_tab_campos(UPPER('dsdpagto')) || '</dsdpagto>';
      END IF;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha);
      
      vr_dsdlinha := NULL;      
      --> Deve ser utilizado a data gravada no dsinfom3, para garantir a validacao VALPRO
      IF vr_tab_campos.exists(UPPER('dttransa')) THEN
        vr_dsdlinha := vr_dsdlinha || '<dttransa>' || vr_tab_campos(UPPER('dttransa')) || '</dttransa>';
      END IF;
      
      vr_dsdlinha := vr_dsdlinha || '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')    || '</hrautent>';
      
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha);
      
      vr_dsdlinha := NULL;      
      vr_dsdlinha := '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                 || '</nrseqaut>' ||
                     '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                 || '</dsprotoc>' ||
                     '<infosac>' ||
                         '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                         '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                         '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                         '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                         '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                         '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                     '</infosac>';
                     
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha); 
                                            
      IF vr_tab_campos.exists(UPPER('cdempcon')) THEN
        IF vr_tab_campos(UPPER('cdempcon')) IN (178,240) THEN
          vr_cdtipdoc := 'FGTS – GRDE';
        ELSIF vr_tab_campos(UPPER('cdempcon')) IN (179,180,181) THEN
          vr_cdtipdoc := 'FGTS - GRF';
        ELSIF vr_tab_campos(UPPER('cdempcon')) IN (249) THEN
          vr_cdtipdoc := 'FGTS - GRRF';
        ELSIF vr_tab_campos(UPPER('cdempcon')) IN (451) THEN
          vr_cdtipdoc := 'FGTS - GRFGTS';
        END IF;    
      
      END IF;

      vr_dsdlinha := NULL;      
      vr_dsdlinha := '<infbancoob>'||
                       '<nmrescen>'|| vr_protocolo(vr_ind).nmrescop_central || '</nmrescen>'||
                       '<nmextcen>'|| vr_protocolo(vr_ind).nmextcop_central || '</nmextcen>'||
                       '<nmressin>'|| vr_protocolo(vr_ind).nmrescop         || '</nmressin>'||
                       '<dsresdoc>'|| vr_cdtipdoc                           || '</dsresdoc>';
                       
      IF vr_tab_campos.exists('DSORIGEM') THEN
        vr_dsdlinha := vr_dsdlinha || '<cdorigem>'|| vr_tab_campos('DSORIGEM') ||'</cdorigem>	';
      END IF;
      vr_dsdlinha := vr_dsdlinha ||     
                       '<nrtelsac>'|| vr_protocolo(vr_ind).nrtelsac ||'</nrtelsac>'||
                       '<nrtelouv>'|| vr_protocolo(vr_ind).nrtelouv ||'</nrtelouv>	'||
											 '<cdagebcb>'|| rw_crapcop.cdagebcb || '</cdagebcb>' ||											 
                     '</infbancoob> ';
      
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha);               
                     
      /* Projeto 363 - Novo ATM */
      vr_dsdlinha := NULL;      
      vr_dsdlinha := '<idlstdom>' || vr_protocolo(vr_ind).idlstdom || '</idlstdom>' ||
                     '<dsorigem>' || vr_protocolo(vr_ind).dsorigem || '</dsorigem>';

      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha);  
                     
    END LOOP;
      
    gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Comprovante>'
                           ,pr_fecha_xml      => TRUE);      
			
    
    pr_retxml := XMLTYPE.CREATEXML(vr_retxml);
    pr_dsretorn := 'OK';   
       
  EXCEPTION								
    WHEN vr_exc_erro THEN  							
					
      pr_retxml :=XMLTYPE.CREATEXML('<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>');
      pr_dsretorn := 'NOK';
																 
    WHEN OTHERS THEN
								
      vr_des_erro := 'Erro ao criar XML(FGTS): ' || SQLERRM;
      pr_retxml :=   XMLTYPE.CREATEXML('<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>');
      pr_dsretorn := 'NOK';
			    
  END pc_detalhe_compr_pag_fgts;

  -- Pagamento DAE
  PROCEDURE pc_detalhe_compr_pag_dae ( pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                      ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                      ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                      ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                      ,pr_retxml   OUT xmltype               --> Arquivo de retorno do XML                                        
                                      ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK
    
    /* ................................................................................

     Programa: pc_detalhe_compr_pag_dae
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Odirlei Busana -  AMcom
     Data    : Janeiro/2018.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de Pagamento DAE.

     Observacao: -----

     Alteracoes: 

     ..................................................................................*/  
    
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp    VARCHAR2(32726) := '';
      vr_dsdlinha    VARCHAR2(32726) := '';
      vr_cdempcon    INTEGER;
      vr_dscritic    VARCHAR2(4000);
      vr_cdcritic    crapcri.cdcritic%TYPE;
      vr_info_sac    typ_reg_info_sac;
      vr_des_erro    VARCHAR2(4000);
      
      vr_retxml      CLOB;
      
      TYPE typ_tab_campos IS TABLE OF VARCHAR2(2000)
           INDEX BY VARCHAR2(40);
      vr_tab_campos typ_tab_campos;
      vr_idx VARCHAR2(40);
      vr_split_reg   gene0002.typ_split;
      vr_split_campo gene0002.typ_split;
            
      --> Buscar código da agência da cooperativa cadastrada no bancoob
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
				SELECT crapcop.cdagebcb
					FROM crapcop
				 WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
    
  BEGIN
    
    pr_dsretorn := 'NOK';
			
    -- Buscar dados do associado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
			        
      vr_dscritic := 'Associado nao cadastrado.';
      vr_des_erro := 'Erro em pc_detalhe_compr_pag_dae:' || vr_dscritic;
				
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
			
		-- Buscar dados da cooperativa			
		OPEN cr_crapcop(pr_cdcooper);
		FETCH cr_crapcop INTO rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
			        
      vr_dscritic := 'Cooperativa nao encontrada.';
      vr_des_erro := 'Erro em pc_detalhe_compr_pag_dae:' || vr_dscritic;
				
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
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
      vr_des_erro := 'Erro em pc_detalhe_compr_pag_dae:' || vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
      
    vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
    dbms_lob.createtemporary(vr_retxml, TRUE);
    dbms_lob.open(vr_retxml, dbms_lob.lob_readwrite);
       
     -- Criar cabecalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<Comprovante>');        
      
    FOR vr_ind IN 1..vr_protocolo.count LOOP
			
      --> Quebrar registros para não pegar posicional, evitando que se mudem a ordem ou incluam campo e prejudique o programa
      vr_split_reg := gene0002.fn_quebra_string(vr_protocolo(vr_ind).dsinform##3,'#');
      
      --> Varrer dados
      IF vr_split_reg.count > 0 THEN
        FOR i IN vr_split_reg.first..vr_split_reg.last LOOP
        
          vr_split_campo := NULL;
          vr_split_campo := gene0002.fn_quebra_string(vr_split_reg(i),':');
          
          IF vr_split_campo.count > 0 THEN
    
            --> Montar index, conforme label do campo
            vr_split_campo(1) := upper(REPLACE(vr_split_campo(1),':'));        
            CASE vr_split_campo(1)
              WHEN 'TIPO DE DOCUMENTO' THEN
                vr_idx := 'DSTIPDOC';    
              WHEN 'AGENTE ARRECADADOR' THEN
                vr_IDX := 'NMAGEARR';                              
              WHEN 'CÓDIGO DE BARRAS' THEN
                vr_idx := 'CDBARRAS';
              WHEN 'LINHA DIGITÁVEL' THEN
                VR_IDX := 'DSLINHAD';
              WHEN 'NÚMERO DE DOCUMENTO(DAE)' THEN
                VR_IDX := 'NRDOCDAE';
              WHEN 'VALOR TOTAL' THEN
                vr_idx := 'VLDOCMTO';
              WHEN 'DESCRIÇÃO DO PAGAMENTO' THEN
                vr_idx := 'DSDPAGTO';
              WHEN 'DATA DO PAGAMENTO' THEN
                vr_idx := 'DTTRANSA';
              WHEN 'HORARIO DO PAGAMENTO' THEN
                vr_idx := 'HRAUTENT';
              WHEN 'CANAL DE RECEBIMENTO' THEN
                vr_idx := 'DSORIGEM';              
              ELSE
                vr_idx := NULL;
            END CASE;  
          
            IF vr_idx IS NOT NULL THEN
              vr_tab_campos(vr_idx) := vr_split_campo(2);          
            END IF;
             
          END IF;
        END LOOP;
      END IF;
      
      vr_dsdlinha := '';
      vr_dsdlinha := '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                  || '</cdtippro>' ||
                     '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)        || '</dstippro>' ||
                     '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)           || '</nrdocmto>' ||
                     '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)           || '</cdbcoctl>' ||
                     '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)           || '</cdagectl>' ||
                     '<nmrescop>' || to_char(vr_protocolo(vr_ind).nmrescop)           || '</nmrescop>' ||
                     '<nmrescop_central>' || to_char(vr_protocolo(vr_ind).nmrescop_central) || '</nmrescop_central>' ||
                     '<nrdconta>' || to_char(pr_nrdconta)                             || '</nrdconta>' ||
                     '<nmtitula>' || to_char(rw_crapass.nmextttl)                     || '</nmtitula>' ||
                     '<nmprepos>' || to_char(vr_protocolo(vr_ind).nmprepos)           || '</nmprepos>' ||
                     '<nrcpfpre>' || to_char(vr_protocolo(vr_ind).nrcpfpre)           || '</nrcpfpre>' ||
                     '<nmoperad>' || to_char(vr_protocolo(vr_ind).nmoperad)           || '</nmoperad>' ||
                     '<nrcpfope>' || to_char(vr_protocolo(vr_ind).nrcpfope)           || '</nrcpfope>' ;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha); 
                                    
      vr_dsdlinha := '';
      IF vr_tab_campos.exists(UPPER('dstipdoc')) THEN
        vr_dsdlinha := vr_dsdlinha || '<dstipdoc>' || vr_tab_campos(UPPER('dstipdoc')) || '</dstipdoc>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('nmagearr')) THEN
        vr_dsdlinha := vr_dsdlinha || '<nmagearr>' || vr_tab_campos(UPPER('nmagearr')) || '</nmagearr>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('cdbarras')) THEN
        vr_dsdlinha := vr_dsdlinha || '<cdbarras>' || vr_tab_campos(UPPER('cdbarras')) || '</cdbarras>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('dslinhad')) THEN
        vr_dsdlinha := vr_dsdlinha || '<dslinhad>' || vr_tab_campos(UPPER('dslinhad')) || '</dslinhad>';
      END IF;
      
      IF vr_tab_campos.exists(UPPER('nrdocdae')) THEN
        vr_dsdlinha := vr_dsdlinha || '<nrdocdae>' || vr_tab_campos(UPPER('nrdocdae')) || '</nrdocdae>';
      END IF;
      
      vr_dsdlinha := vr_dsdlinha ||'<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>';
      
      IF vr_tab_campos.exists(UPPER('dsdpagto')) THEN
        vr_dsdlinha := vr_dsdlinha || '<dsdpagto>' || vr_tab_campos(UPPER('dsdpagto')) || '</dsdpagto>';
      END IF;
      
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha);
      
      vr_dsdlinha := NULL;      
      IF vr_tab_campos.exists(UPPER('dttransa')) THEN
        vr_dsdlinha := vr_dsdlinha || '<dttransa>' || vr_tab_campos(UPPER('dttransa')) || '</dttransa>';
      END IF;
      
      vr_dsdlinha := vr_dsdlinha || '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')    || '</hrautent>';
      
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha);
      
      vr_dsdlinha := NULL;      
      vr_dsdlinha := '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                 || '</nrseqaut>' ||
                     '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                 || '</dsprotoc>' ||
                     '<infosac>' ||
                         '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                         '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                         '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                         '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                         '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                         '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                     '</infosac>';
                     
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha);               
                     
      vr_dsdlinha := NULL;      
      vr_dsdlinha := '<infbancoob>'||                       
                       '<nmressin>'|| vr_protocolo(vr_ind).nmrescop || '</nmressin>';
      IF vr_tab_campos.exists('DSORIGEM') THEN
        vr_dsdlinha := vr_dsdlinha || '<cdorigem>'|| vr_tab_campos('DSORIGEM') ||'</cdorigem>	';
      END IF;
      vr_dsdlinha := vr_dsdlinha ||     
                       '<nrtelsac>'|| vr_protocolo(vr_ind).nrtelsac ||'</nrtelsac>'||
                       '<nrtelouv>'|| vr_protocolo(vr_ind).nrtelouv ||'</nrtelouv>	'||
											 '<cdagebcb>'|| rw_crapcop.cdagebcb || '</cdagebcb>' ||
                     '</infbancoob> ';
                     
      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha);               
                     
      /* Projeto 363 - Novo ATM */
      vr_dsdlinha := NULL;      
      vr_dsdlinha := '<idlstdom>' || vr_protocolo(vr_ind).idlstdom || '</idlstdom>' ||
                     '<dsorigem>' || vr_protocolo(vr_ind).dsorigem || '</dsorigem>';

      gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => vr_dsdlinha);  
    END LOOP;
      
    gene0002.pc_escreve_xml(pr_xml            => vr_retxml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Comprovante>'
                           ,pr_fecha_xml      => TRUE);      
			
    pr_retxml := XMLTYPE.CREATEXML(vr_retxml);
    
    pr_dsretorn := 'OK';   
       
       
  EXCEPTION								
    WHEN vr_exc_erro THEN  							
					
      pr_retxml := XMLTYPE.CREATEXML('<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>');
      pr_dsretorn := 'NOK';
																 
    WHEN OTHERS THEN
								
      vr_des_erro := 'Erro ao criar XML(DAE): ' || SQLERRM;
      pr_retxml :=   XMLTYPE.CREATEXML('<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>');
      pr_dsretorn := 'NOK';
			    
  END pc_detalhe_compr_pag_dae;

  -- Comprovante de Depósito
  PROCEDURE pc_detalhe_compr_deposito(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                    ,pr_dsprotoc IN crappro.dsprotoc%TYPE --> Protocolo
                                    ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                    ,pr_retxml   OUT CLOB                  --> Arquivo de retorno do XML                                        
                                    ,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK

  BEGIN
    
    /* ................................................................................

     Programa: pc_detalhe_compr_deposito
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Douglas Quisinski
     Data    : Abril/2018                   Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de depósito

     Observacao: -----

     Alteracoes: 

     ..................................................................................*/  
    
    DECLARE
    
      vr_protocolo   gene0006.typ_tab_protocolo;    --> PL Table para armazenar registros (retorno protocolo)
      vr_exc_erro    EXCEPTION;       --> Controle de exceção      
      vr_xml_temp VARCHAR2(32726) := '';
      vr_dscritic crapcri.dscritic%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_info_sac typ_reg_info_sac;     
      vr_des_erro  VARCHAR2(4000);
      
      vr_nmrescop crapcop.nmrescop%TYPE;
      vr_dstippro VARCHAR2(35);
      vr_dadostaa VARCHAR2(15);
      vr_dsinform1 VARCHAR2(130);
      vr_dsinform2 VARCHAR2(50);
      vr_dstextab craptab.dstextab%TYPE;
      vr_flghorar BOOLEAN;
      
      CURSOR cr_crapcop (pr_cdagectl IN crapcop.cdagectl%TYPE) IS --> Código de agência da cooperativa na Central
        SELECT c.cdcooper
              ,c.cdbcoctl
              ,c.cdagectl
              ,c.nmrescop
          FROM crapcop c
         WHERE c.cdagectl = pr_cdagectl;
      rw_crapcop cr_crapcop%ROWTYPE;

      CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                       ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
        SELECT fer.cdcooper, fer.dtferiad
          FROM crapfer fer
         WHERE fer.cdcooper = pr_cdcooper
           AND fer.dtferiad = pr_dtferiad;
      rw_crapfer cr_crapfer%ROWTYPE;
    
    BEGIN
    
      pr_dsretorn := 'NOK';
			
      -- Buscar dados do associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
					
        vr_dscritic := 'Associado nao cadastrado.';
        vr_des_erro := 'Erro em pc_detalhe_compr_deposito:' || vr_dscritic;
							
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
      
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<Comprovante>');        
      
      vr_dsinform1 := 'A CONFIRMACAO DO DEPOSITO NA CONTA DO FAVORECIDO ' ||
                      'SERA EFETUADA APOS A ABERTURA DO ENVELOPE E A ' ||
                      'VERIFICACAO DOS VALORES CONTIDOS.';
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
        
        IF UPPER(vr_protocolo(vr_ind).dsinform##1) = 'DEPOSITO TAA - CHQ' THEN
          vr_dstippro := 'COMPROVANTE DE DEPOSITO EM CHEQUE';
        ELSE 
          vr_dstippro := 'COMPROVANTE DE DEPOSITO EM DINHEIRO';
        END IF;
        
        OPEN cr_crapcop (pr_cdagectl => vr_protocolo(vr_ind).cdagectl);
        FETCH cr_crapcop INTO rw_crapcop;
        
        vr_nmrescop := '';
        IF cr_crapcop%FOUND THEN
          vr_nmrescop := rw_crapcop.nmrescop;
        END IF;
        CLOSE cr_crapcop;
        
        
        vr_dadostaa := replace(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##3, '#'), 'TAA:' , null);

        vr_dsinform2 := '';
        -- Essa regra foi verificada no programas do TAA
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => to_number(GENE0002.fn_busca_entrada(1, vr_dadostaa, '/' ))
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRTRENVELO'
                                                 ,pr_tpregist => to_number(GENE0002.fn_busca_entrada(2, vr_dadostaa, '/' )));

        IF TRIM(vr_dstextab) IS NOT NULL THEN
          IF  vr_protocolo(vr_ind).hrautent > to_number(SUBSTR(vr_dstextab,1,5))  THEN
            vr_flghorar := false;
          ELSE
            vr_flghorar := true;
          END IF;
        ELSE
          vr_flghorar := false;
        END IF;

        /* no caso de fim de semana ou feriado, faz corte para 
           o proximo dia util */
        OPEN cr_crapfer(pr_cdcooper => to_number(GENE0002.fn_busca_entrada(1, vr_dadostaa, '/' ))
                       ,pr_dtferiad => vr_protocolo(vr_ind).dttransa);
        FETCH cr_crapfer INTO rw_crapfer;

        -- Se não encontrar
        IF cr_crapfer%FOUND OR to_char(vr_protocolo(vr_ind).dttransa,'D') IN (1,7) THEN
          -- Fechar o cursor
          CLOSE cr_crapfer;
          vr_flghorar := false;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapfer;
        END IF;

        IF NOT vr_flghorar THEN
          vr_dsinform2 := 'ESTE ENVELOPE SERA PROCESSADO NO PROXIMO DIA UTIL';
        END IF;

        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                                  '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                      || '</cdtippro>' ||
                                  '<dstippro>' || vr_dstippro                                                                                 || '</dstippro>' ||
                                  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                      || '</nrdocmto>' ||
                                  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                      || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                      || '</cdagectl>' ||
                                  '<nmrescop>' || vr_nmrescop                                                                                 || '</nmrescop>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                        || '</nrdconta>' ||
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                || '</nmtitula>' ||																	
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                        || '</hrautent>' ||
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                                               || '</nrseqaut>' ||
                                  '<dtmvtolt>' || to_char(vr_protocolo(vr_ind).dtmvtolt, 'DD/MM/RRRR')                                        || '</dtmvtolt>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                               || '</dsprotoc>' ||
                                  '<infosac>' ||
                                      '<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
                                      '<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
                                      '<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
                                      '<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
                                      '<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
                                      '<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
                                  '</infosac>' ||
                                 /* Projeto 363 - Novo ATM */ 
                                 '<idlstdom>' || vr_protocolo(vr_ind).idlstdom  || '</idlstdom>' ||
                                 '<dsorigem>' || vr_protocolo(vr_ind).dsorigem  || '</dsorigem>' ||
                                 '<dsinform1>' || vr_dsinform1 || '</dsinform1>' ||
                                 '<dsinform2>' || vr_dsinform2 || '</dsinform2>' );
      END LOOP;
      
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Comprovante>'
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
    
  END pc_detalhe_compr_deposito;

PROCEDURE pc_detalhe_compr_doc ( pr_cdcooper IN craplcm.cdcooper%TYPE  --> Código da cooperativa
																	,pr_nrdconta IN craplcm.nrdconta%TYPE  --> Número da conta
																	,pr_dttransa IN craplcm.dtmvtolt%TYPE  --> Data da transação
																	,pr_cdhistor IN craplcm.cdhistor%TYPE  --> Código do histórico
																	,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Nr. documento
																	,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor de Lançamento
																	,pr_retxml   OUT xmltype               --> Arquivo de retorno do XML                                        
																	,pr_dsretorn OUT VARCHAR2) IS          -- OK/NOK
    /* ................................................................................

     Programa: pc_detalhe_compr_doc
     Sistema : Internet Banking
     Sigla   : COMP
     Autor   : Lucas Reinert
     Data    : Agosto/2018.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta comprovantes de DOC.

     Observacao: -----

     Alteracoes: 

     ..................................................................................*/  

		vr_exc_erro    EXCEPTION;       --> Controle de exceção      
		vr_xml_temp    VARCHAR2(32726) := '';
		vr_dscritic    VARCHAR2(4000);
		vr_cdcritic    crapcri.cdcritic%TYPE;
		vr_info_sac    typ_reg_info_sac;
		vr_des_erro    VARCHAR2(4000);
      
		-- Variáveis auxiliares
		vr_cdbanrem    NUMBER;
		vr_cdagerem    NUMBER;
		vr_nrctarem    VARCHAR2(20);
		vr_nrcpfrem    NUMBER;
		vr_dsnomrem    VARCHAR2(100);
		vr_cdbandst    NUMBER;
		vr_cdagedst    NUMBER;
		vr_nrctadst    VARCHAR2(20);
		vr_nrcpfdst    NUMBER;
		vr_dsnomdst    VARCHAR2(100);
		vr_stsnrcal_rem BOOLEAN;
		vr_stsnrcal_dst BOOLEAN;
		vr_inpessoa_rem INTEGER;
		vr_inpessoa_dst INTEGER;
			
		vr_retxml      CLOB;
      
		TYPE typ_tab_campos IS TABLE OF VARCHAR2(2000)
				 INDEX BY VARCHAR2(40);
		vr_tab_campos typ_tab_campos;
		vr_idx VARCHAR2(40);
		vr_split_reg   gene0002.typ_split;
		vr_split_campo gene0002.typ_split;
            
		--> Buscar código da agência da cooperativa cadastrada no bancoob
		CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
			SELECT cop.cdbcoctl
						,cop.cdagectl
				FROM crapcop cop
			 WHERE cop.cdcooper = pr_cdcooper;
		rw_crapcop cr_crapcop%ROWTYPE;
			
		-- Cursor para detalhar DOCs enviados
		CURSOR cr_craptvl (pr_cdcooper IN craptvl.cdcooper%TYPE
											,pr_dtmvtolt IN craptvl.dtmvtolt%TYPE
											,pr_nrdconta IN craptvl.nrdconta%TYPE
											,pr_nrdocmto IN craptvl.nrdocmto%TYPE
											,pr_vllanmto IN craptvl.vldocrcb%TYPE) IS
			SELECT tvl.nrdconta
						,tvl.cpfcgemi
						,tvl.nmpesemi
						,tvl.cdbccrcb
						,tvl.cdagercb
						,tvl.nrcctrcb
						,tvl.cpfcgrcb
						,tvl.nmpesrcb
				FROM craptvl tvl
			 WHERE tvl.cdcooper = pr_cdcooper
				 AND tvl.dtmvtolt = pr_dtmvtolt
				 AND tvl.nrdconta = pr_nrdconta
				 AND tvl.nrdocmto = pr_nrdocmto
				 AND tvl.vldocrcb = pr_vllanmto;
		rw_craptvl cr_craptvl%ROWTYPE; 			
			
		-- Cursor para detalhar DOCs recebidos
		CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
											,pr_nrdconta IN craplcm.nrdconta%TYPE
											,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
											,pr_nrdocmto IN craplcm.nrdocmto%TYPE
											,pr_vllanmto IN craplcm.vllanmto%TYPE) IS
			SELECT lcm.cdbanchq
						,lcm.cdagechq
						,lcm.nrctachq
				FROM craplcm lcm
			 WHERE lcm.cdcooper = pr_cdcooper
				 AND lcm.nrdconta = pr_nrdconta
				 AND lcm.dtmvtolt = pr_dtmvtolt
				 AND lcm.nrdocmto = pr_nrdocmto
				 AND lcm.vllanmto = pr_vllanmto;
		rw_craplcm cr_craplcm%ROWTYPE;
		
		-- Cursor para detalhar DOCs recebidos
		CURSOR cr_gncpdoc (pr_cdcooper IN gncpdoc.cdcooper%TYPE
		                  ,pr_nrdconta IN gncpdoc.nrdconta%TYPE
											,pr_dtmvtolt IN gncpdoc.dtmvtolt%TYPE
											,pr_nrdocmto IN gncpdoc.nrdocmto%TYPE) IS
      SELECT doc.cpfcgemi
			      ,doc.nmpesemi
			  FROM gncpdoc doc
			 WHERE doc.cdcooper = pr_cdcooper
			   AND doc.nrdconta = pr_nrdconta
				 AND doc.dtmvtolt = pr_dtmvtolt
				 AND doc.nrdocmto = pr_nrdocmto;
		rw_gncpdoc cr_gncpdoc%ROWTYPE;
		
		-- Buscar dados do destinatário do DOC recebido
		CURSOR cr_crapass_doc(pr_cdcooper IN crapass.cdcooper%TYPE
		                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
			SELECT ass.nrdconta
			      ,ass.nrcpfcgc
						,ass.nmprimtl
			  FROM crapass ass
			 WHERE ass.cdcooper = pr_cdcooper
			   AND ass.nrdconta = pr_nrdconta;
		rw_crapass_doc cr_crapass_doc%ROWTYPE;
  BEGIN																	
		-- Buscar dados da cooperativa			
		OPEN cr_crapcop(pr_cdcooper);
		FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrou registro de cooperativa
    IF cr_crapcop%NOTFOUND THEN
			-- Fechar cursor
      CLOSE cr_crapcop;
			-- Gerar crítica
      vr_dscritic := 'Cooperativa nao encontrada.';
      vr_des_erro := 'Erro em pc_detalhe_compr_doc: ' || vr_dscritic;
			-- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
		-- Fechar cursor
    CLOSE cr_crapcop;
					
		-- Débito		
		IF pr_cdhistor IN (103, 355) THEN
			-- Buscar detalhe do DOC enviado
			OPEN cr_craptvl(pr_cdcooper => pr_cdcooper
			               ,pr_dtmvtolt => pr_dttransa
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrdocmto => pr_nrdocmto
										 ,pr_vllanmto => pr_vllanmto);
			FETCH cr_craptvl INTO rw_craptvl;

      -- Se não encontrou registro			
			IF cr_craptvl%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_craptvl;
				-- Gerar crítica
				vr_dscritic := 'Detalhe de DOC não encontrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_doc: ' || vr_dscritic;
				-- Levantar exceção
				RAISE vr_exc_erro;				
			END IF;
			-- Fechar cursor
			CLOSE cr_craptvl;			
			
			-- Atribuir detalhes às variáveis auxiliares
			vr_cdbanrem := rw_crapcop.cdbcoctl;
			vr_cdagerem := rw_crapcop.cdagectl;
			vr_nrctarem := LPAD(to_char(rw_craptvl.nrdconta), 14, '0');
			vr_nrcpfrem := rw_craptvl.cpfcgemi;
			vr_dsnomrem := rw_craptvl.nmpesemi;
			vr_cdbandst := rw_craptvl.cdbccrcb;
			vr_cdagedst := rw_craptvl.cdagercb;
			vr_nrctadst := LPAD(to_char(rw_craptvl.nrcctrcb), 14, '0');
			vr_nrcpfdst := rw_craptvl.cpfcgrcb;
			vr_dsnomdst := rw_craptvl.nmpesrcb;
		-- Crédito
		ELSE
			-- Buscar detalhe do DOC recebido
			OPEN cr_craplcm(pr_cdcooper => pr_cdcooper
			               ,pr_nrdconta => pr_nrdconta
										 ,pr_dtmvtolt => pr_dttransa
										 ,pr_nrdocmto => pr_nrdocmto
										 ,pr_vllanmto => pr_vllanmto);
			FETCH cr_craplcm INTO rw_craplcm;
			
			-- Se não encontrou
			IF cr_craplcm%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_craplcm;
				
				-- Gerar crítica
				vr_dscritic := 'Detalhe de DOC não encontrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_doc: ' || vr_dscritic;
				-- Levantar exceção
				RAISE vr_exc_erro;								
			END IF;
			-- Fechar cursor
			CLOSE cr_craplcm;
			
			-- Buscar dados do destinatário do DOC recebido
			OPEN cr_crapass_doc(pr_cdcooper => pr_cdcooper
			                   ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass_doc INTO rw_crapass_doc;
			
			-- Se não encontrou registro
			IF cr_crapass_doc%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapass_doc;
				
				-- Gerar crítica
				vr_dscritic := 'Destinatário não encontrado.';
				vr_des_erro := 'Erro em pc_detalhe_compr_doc: ' || vr_dscritic;
				-- Levantar exceção
				RAISE vr_exc_erro;												
			END IF;
			-- Fechar cursor
			CLOSE cr_crapass_doc;
			
			-- Buscar detalhe do DOC recebido			
			OPEN cr_gncpdoc(pr_cdcooper => pr_cdcooper
			               ,pr_nrdconta => pr_nrdconta
										 ,pr_dtmvtolt => pr_dttransa
										 ,pr_nrdocmto => pr_nrdocmto);
			FETCH cr_gncpdoc INTO rw_gncpdoc;
			
			-- Se encontrou registro
			IF cr_gncpdoc%FOUND THEN
			  -- Atribuir detalhes às variáveis auxiliares				
				vr_nrcpfrem := rw_gncpdoc.cpfcgemi;
				vr_dsnomrem := rw_gncpdoc.nmpesemi;			
			END IF;
			-- Fechar cursor
			CLOSE cr_gncpdoc;
			
			-- Atribuir detalhes às variáveis auxiliares
			vr_cdbanrem := rw_craplcm.cdbanchq;
			vr_cdagerem := rw_craplcm.cdagechq;
			vr_nrctarem := LPAD(to_char(rw_craplcm.nrctachq), 14, '0');
			vr_cdbandst := rw_crapcop.cdbcoctl;
			vr_cdagedst := rw_crapcop.cdagectl;
			vr_nrctadst := LPAD(to_char(rw_crapass_doc.nrdconta), 14, '0');
			vr_nrcpfdst := rw_crapass_doc.nrcpfcgc;
			vr_dsnomdst := rw_crapass_doc.nmprimtl;
			
		END IF;

    -- Verificar se é CPF ou CNPJ				
		gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_nrcpfrem
		                           ,pr_stsnrcal => vr_stsnrcal_rem
															 ,pr_inpessoa => vr_inpessoa_rem);
															 
		gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_nrcpfdst
		                           ,pr_stsnrcal => vr_stsnrcal_dst
															 ,pr_inpessoa => vr_inpessoa_dst);															 
		
		vr_info_sac := fn_info_sac(pr_cdcooper => pr_cdcooper);
      
		dbms_lob.createtemporary(vr_retxml, TRUE);
		dbms_lob.open(vr_retxml, dbms_lob.lob_readwrite);
       
		 -- Criar cabecalho do XML
		gene0002.pc_escreve_xml(pr_xml            => vr_retxml
													 ,pr_texto_completo => vr_xml_temp
													 ,pr_texto_novo     => '<Comprovante>');       
      
		gene0002.pc_escreve_xml(pr_xml            => vr_retxml
													 ,pr_texto_completo => vr_xml_temp      
													 ,pr_texto_novo     => 
														 '<dados>'||
														        '<dttransa>' || to_char(pr_dttransa,'DD/MM/RRRR') || '</dttransa>' ||
															    '<vllanmto>' || to_char(pr_vllanmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vllanmto>' ||
																'<cdbanrem>' || vr_cdbanrem                       || '</cdbanrem>' ||
																'<cdagerem>' || vr_cdagerem                       || '</cdagerem>' ||
																'<nrctarem>' || vr_nrctarem                       || '</nrctarem>' ||
																'<dsnomrem>' || vr_dsnomrem                       || '</dsnomrem>' ||
																'<nrcpfrem>' || gene0002.fn_mask_cpf_cnpj(vr_nrcpfrem, vr_inpessoa_rem) || '</nrcpfrem>' ||
																'<cdbandst>' || vr_cdbandst                       || '</cdbandst>' ||
																'<cdagedst>' || vr_cdagedst                       || '</cdagedst>' ||
																'<nrctadst>' || vr_nrctadst                       || '</nrctadst>' ||
																'<dsnomdst>' || vr_dsnomdst                       || '</dsnomdst>' ||
																'<nrcpfdst>' || gene0002.fn_mask_cpf_cnpj(vr_nrcpfdst, vr_inpessoa_dst) || '</nrcpfdst>' ||
																'<idlstdom>41</idlstdom>' ||
																'<infosac>' ||
																		'<nrtelsac>' || vr_info_sac.nrtelsac || '</nrtelsac>' ||
																		'<nrtelouv>' || vr_info_sac.nrtelouv || '</nrtelouv>' || 
																		'<hrinisac>' || vr_info_sac.hrinisac || '</hrinisac>' || 
																		'<hrfimsac>' || vr_info_sac.hrfimsac || '</hrfimsac>' || 
																		'<hriniouv>' || vr_info_sac.hriniouv || '</hriniouv>' || 
																		'<hrfimouv>' || vr_info_sac.hrfimouv || '</hrfimouv>' ||   
																'</infosac>' ||                                  
														 '</dados>' );          
      
	  gene0002.pc_escreve_xml(pr_xml            => vr_retxml
												 	 ,pr_texto_completo => vr_xml_temp
												   ,pr_texto_novo     => '</Comprovante>'
												   ,pr_fecha_xml      => TRUE);      
                          
	  pr_retxml := XMLTYPE.CREATEXML(vr_retxml);
		    
	  pr_dsretorn := 'OK';		
							
  EXCEPTION								
    WHEN vr_exc_erro THEN  							
					
      pr_retxml := XMLTYPE.CREATEXML('<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>');
      pr_dsretorn := 'NOK';
																 
    WHEN OTHERS THEN
								
      vr_des_erro := 'Erro ao detalhar comprovante de DOC: ' || SQLERRM;
      pr_retxml :=   XMLTYPE.CREATEXML('<dsmsgerr>'|| vr_des_erro ||'</dsmsgerr>');
      pr_dsretorn := 'NOK';
																	
END pc_detalhe_compr_doc;

END;
/
