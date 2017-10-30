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
  
  FUNCTION fn_descricao(pr_protocolo IN gene0006.typ_reg_protocolo,
                        pr_cdtipmod NUMBER) RETURN VARCHAR2 IS
    BEGIN
     DECLARE
      vr_dsprotoc  VARCHAR2(4000);
      vr_dsinfor2  VARCHAR2(4000); --> Descrição de informações      
      vr_split gene0002.typ_split;            
      vr_desc  VARCHAR2(500);
      vr_ult PLS_INTEGER;               
      
      BEGIN
    
        CASE
          WHEN pr_protocolo.cdtippro = 1 AND pr_cdtipmod = 1 THEN -- Transferencia Realizada
            vr_dsinfor2 := TRIM(gene0002.fn_busca_entrada(2, pr_protocolo.dsinform##2, '#'));      
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(1, TRIM(gene0002.fn_busca_entrada(3, pr_protocolo.dsinform##2, '#')), '-')) || '/' || TRIM(gene0002.fn_busca_entrada(2, vr_dsinfor2, ':'));
          WHEN pr_protocolo.cdtippro = 1 AND pr_cdtipmod = 3 THEN -- Transferencia Recebida
            vr_dsprotoc := pr_protocolo.dsinform##2;
          WHEN pr_protocolo.cdtippro IN (2,15) THEN -- Pagamento / Convenio
            vr_dsprotoc := pr_protocolo.dscedent;          
          WHEN pr_protocolo.cdtippro = 3 THEN -- Capital;
            vr_dsprotoc := pr_protocolo.dsinform##1;
          WHEN pr_protocolo.cdtippro = 9 AND pr_cdtipmod = 1 THEN -- TED Realizada
            vr_dsprotoc := TRIM(gene0002.fn_busca_entrada(4, pr_protocolo.dsinform##2, '#')) || ' - ' || TRIM(gene0002.fn_busca_entrada(1, pr_protocolo.dsinform##3, '#'));
          WHEN pr_protocolo.cdtippro = 9 AND pr_cdtipmod = 3 THEN -- TED Recebida
            vr_dsprotoc := pr_protocolo.dsinform##2;
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
			
      IF pr_cdtipmod = 3 THEN -- Transferências Recebidas
        pc_comprovantes_recebidos (pr_cdcooper  => pr_cdcooper
                                  ,pr_nrdconta  => pr_nrdconta
                                  ,pr_cdorigem  => pr_cdorigem
                                  ,pr_dtinipro  => pr_dtinipro
                                  ,pr_dtfimpro  => pr_dtfimpro
                                  ,pr_iniconta  => pr_iniconta
                                  ,pr_nrregist  => pr_nrregist
                                  ,pr_protocolo => vr_protocolo
                                  ,pr_dsretorn  => vr_des_erro);
                                   
        -- Verifica se retornou erro
        IF TRIM(vr_des_erro) = 'NOK' THEN
          vr_des_erro := 'Não foi possível consultar os comprovantes recebidos.';        
          RAISE vr_exc_erro;
        END IF;                          
      ELSE
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
  			
        ELSIF pr_cdtipmod = 2 THEN -- Transferências Realizadas
  				
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
          vr_des_erro := 'Não foi possível consultar os comprovantes.';        
          RAISE vr_exc_erro;
        END IF;
        			
        -- Filtra retorno pelo tipo de protocolo solicitado
        FOR vr_ind IN 1..vr_prot_fltr.count LOOP				
          IF vr_prot_fltr(vr_ind).cdtippro MEMBER OF vr_cdtippro THEN
            vr_protocolo(vr_protocolo.count + 1) := vr_prot_fltr(vr_ind);
          END IF;
        END LOOP;  			
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
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                        || '</dttransa>' ||
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
                                  '<dsdescri>' || fn_descricao(vr_protocolo(vr_ind),pr_cdtipmod) || '</dsdescri>');     
												
        IF pr_cdtipmod = 3 THEN			-- Transferências Recebidas
					gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     =>
                                  '<cdhistor>' || vr_protocolo(vr_ind).cdhistor   || '</cdhistor>');             
        ELSE
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     => 
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc || '</dsprotoc>');
        END IF;					
        
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
								 								  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
								 							    '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
								 							    '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||																 															   																                                
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                      || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')      || '</hrautent>' ||
                                  '<vldocmto>' ||to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')  || '</vldocmto>' ||
                                  '<nrctadst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(2, vr_dsinfor2, ':'),2,10))      	  || '</nrctadst>' ||
                                  '<nmtitdst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(2, vr_dsinfor2, ':'),15))           || '</nmtitdst>' ||
                                  '<cdagedst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2,'#'),1,4)) || '</cdagedst>' ||
                                  '<nmcopdst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2,'#'),8))   || '</nmcopdst>' ||
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
      
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
								 	 						    '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
								 								  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
								 							    '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
								 							    '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
                                  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
                                  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
                                  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||																 															   																                                                               
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                      || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')      || '</hrautent>' ||
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                             || '</dsprotoc>' ||                                  
                                  '<nrseqaut>' || vr_protocolo(vr_ind).nrseqaut                                             || '</nrseqaut>' ||                                  
                                  '<cdbandst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#'),1,3)) || '</cdbandst>' ||
                                  '<dsbandst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(2, vr_protocolo(vr_ind).dsinform##2, '#'),7))   || '</dsbandst>' ||                                                                   
                                  '<cdagedst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2, '#'),1,4)) || '</cdagedst>' ||
                                  '<dsagedst>' || TRIM(SUBSTR(gene0002.fn_busca_entrada(3, vr_protocolo(vr_ind).dsinform##2, '#'),8))   || '</dsagedst>' ||                                                                    
                                  '<dsctadst>' || TRIM(gene0002.fn_busca_entrada(4, vr_protocolo(vr_ind).dsinform##2, '#')) || '</dsctadst>' ||
                                  '<dstitdst>' || TRIM(gene0002.fn_busca_entrada(1, vr_protocolo(vr_ind).dsinform##2, '#')) || '</dstitdst>' ||
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
       
       -- Criar cabecalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Cecred><Protocolos>');       
      
      FOR vr_ind IN 1..vr_protocolo.count LOOP
      
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
																  '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
															 	  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
															 	  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<vldocmto>' ||to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                         || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
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
      
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
																  '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
																  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
 																  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<vlliquid>' ||to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                         || '</vlliquid>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
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

        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<dados>'||
																  '<cdtippro>' || to_char(vr_protocolo(vr_ind).cdtippro)                                                                             || '</cdtippro>' ||
																  '<dstippro>' || to_char(vr_protocolo(vr_ind).dsinform##1)                                                                          || '</dstippro>' ||
																  '<nrdocmto>' || to_char(vr_protocolo(vr_ind).nrdocmto)                                                                             || '</nrdocmto>' ||
																  '<cdbcoctl>' || to_char(vr_protocolo(vr_ind).cdbcoctl)                                                                             || '</cdbcoctl>' ||
																  '<cdagectl>' || to_char(vr_protocolo(vr_ind).cdagectl)                                                                             || '</cdagectl>' ||
																  '<nrdconta>' || to_char(pr_nrdconta)                                                                                               || '</nrdconta>' ||
																  '<nmtitula>' || to_char(rw_crapass.nmextttl)                                                                                       || '</nmtitula>' ||
                                  '<dttransa>' || to_char(vr_protocolo(vr_ind).dttransa, 'DD/MM/RRRR')                                                               || '</dttransa>' ||
                                  '<hrautent>' || to_char(to_date(vr_protocolo(vr_ind).hrautent,'SSSSS'),'hh24:mi:ss')                                               || '</hrautent>' ||
                                  '<vldocmto>' || to_char(vr_protocolo(vr_ind).vldocmto,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')                        || '</vldocmto>' ||
                                  '<dsprotoc>' || vr_protocolo(vr_ind).dsprotoc                                                                                      || '</dsprotoc>' ||
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

     ..................................................................................*/  
    
    DECLARE                                
                                   
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
            
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_temp      
                             ,pr_texto_novo     => 
                             '<dados>'||
                                '<cdtippro>9</cdtippro>' ||
                                '<dstippro>' || vr_tab_logspb_detalhe(vr_idx_ted).dstiptra || '</dstippro>' ||
                                '<cdbanrem>' || LPAD(TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).cdbanrem),3,0) || '</cdbanrem>' ||
                                '<cdagerem>' || LPAD(TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).cdagerem),4,0) || '</cdagerem>' ||
                                '<nrctarem>' || TRIM(GENE0002.fn_mask_conta(vr_tab_logspb_detalhe(vr_idx_ted).nrctarem)) || '</nrctarem>' ||
                                --'<nrcpfrem>' || GENE0002.fn_mask_cpf_cnpj(vr_tab_logspb_detalhe(vr_idx_ted).nrcpfrem,vr_inpesrem) || '</nrcpfrem>' ||
                                '<nrcpfrem>' || TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).dscpfrem) || '</nrcpfrem>' ||
                                '<nmremete>' || vr_tab_logspb_detalhe(vr_idx_ted).dsnomrem || '</nmremete>' ||
                                '<cdbandst>' || LPAD(TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).cdbandst),3,0) || '</cdbandst>' ||
                                '<cdagedst>' || LPAD(TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).cdagedst),4,0) || '</cdagedst>' ||
                                '<nrctadst>' || TRIM(GENE0002.fn_mask_conta(vr_tab_logspb_detalhe(vr_idx_ted).nrctadst)) || '</nrctadst>' ||
                                --'<nrcpfdst>' || GENE0002.fn_mask_cpf_cnpj(vr_tab_logspb_detalhe(vr_idx_ted).nrcpfdst,vr_inpesdst) || '</nrcpfdst>' ||
                                '<nrcpfdst>' || TO_CHAR(vr_tab_logspb_detalhe(vr_idx_ted).dscpfdst) || '</nrcpfdst>' ||
                                '<nmdestin>' || vr_tab_logspb_detalhe(vr_idx_ted).dsnomdst || '</nmdestin>' ||
                                '<vldocmto>' || to_char(vr_tab_logspb_detalhe(vr_idx_ted).vltransa,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.')  || '</vldocmto>' ||
                                '<dttransa>' || to_char(vr_tab_logspb_detalhe(vr_idx_ted).dttransa, 'DD/MM/RRRR')         || '</dttransa>' ||
                                '<hrautent>' || to_char(to_date(vr_tab_logspb_detalhe(vr_idx_ted).hrtransa,'sssss'),'hh24:mi:ss') || '</hrautent>' ||                                
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
                                  ,pr_nrregist => 9999999
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
        
        IF (vr_qtregist < pr_iniconta) OR (vr_qtregist > (pr_iniconta + pr_nrregist)) THEN
          vr_idx := vr_tab_logspb_detalhe.NEXT(vr_idx);
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

END;
/
