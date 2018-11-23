CREATE OR REPLACE PACKAGE CECRED.EMPR0008 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0008
  --  Sistema  : Rotinas referentes a Portabilidade de Credito
  --  Sigla    : EMPR
  --  Autor    : James Prust Junior
  --  Data     : Setembro - 2015.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao Estorno de Parcelas do PP
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  
  TYPE typ_reg_lancto_parcelas IS RECORD(
     cdcooper      craplem.cdcooper%TYPE
    ,nrdconta      craplem.nrdconta%TYPE
    ,nrctremp      craplem.nrctremp%TYPE
    ,nrparepr      craplem.nrparepr%TYPE
    ,dtmvtolt      craplem.dtmvtolt%TYPE
    ,cdhistor      craplem.cdhistor%TYPE
    ,dtvencto      DATE
    ,vllanmto      craplem.vllanmto%TYPE
    ,dtpagemp      craplem.dtpagemp%TYPE
    ,txjurepr      craplem.txjurepr%TYPE
    ,vlpreemp      craplem.vlpreemp%TYPE
    ,flgestor      BOOLEAN
    ,nrdrecid      craplem.progress_recid%TYPE);

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_lancto_parcelas IS TABLE OF typ_reg_lancto_parcelas INDEX BY BINARY_INTEGER;
  
   -- Procedure da Tela: ESTORN, Acao: Estornar
   PROCEDURE pc_tela_busca_lancto_estorno(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                         ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
              						 			 				 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
				    	          	 			 				 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
						    				         				 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
          			    										 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					              							 	 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										              		 	 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
   
  -- Procedure Reponsavel por efetuar o estorno da parcela pago no mesmo dia
	PROCEDURE pc_efetua_estor_pgto_no_dia(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                       ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE --> Data de Movimento
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                       ,pr_nrparepr IN crappep.nrparepr%TYPE --> Numero da Parcela
                                       ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro);
   
   -- Procedure da Tela: ESTORN, Acao: Valida Estorno
   PROCEDURE pc_tela_valida_estorno(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                   ,pr_qtdlacto IN PLS_INTEGER           --> Quantidade de Lancamento
                                   ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
                									 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
				      	          				 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
						      				         ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
          		  	    						 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					                				 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
									  	             ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                                                               
   -- Procedure da Tela: ESTORN, Acao: Estornar
   PROCEDURE pc_tela_estornar_pagamentos(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                        ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                                        ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                        ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE --> Movimento atual
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da Critica
                                        ,pr_dscritic OUT VARCHAR2);           --> Descricao da Critica
                                         
   -- Procedure da Tela: ESTORN, Acao: Consultar
   PROCEDURE pc_tela_consultar_estornos(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
              						 			 			 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
 				    	          	 			 			 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
						    				         			 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
          			    									 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					              							 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										              		 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                       
   -- Procedure da Tela: ESTORN, Acao: Consultar
   PROCEDURE pc_tela_consultar_detalhe_est(pr_nrdconta  IN crapepr.nrdconta%TYPE        --> Numero da Conta
                                          ,pr_nrctremp  IN crapepr.nrctremp%TYPE        --> Numero do Contrato
                                          ,pr_cdestorno IN tbepr_estorno.cdestorno%TYPE --> Codigo do Estorno
                						 			 			  ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
 	  			    	          	 			 			  ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
		  				    				         			  ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
            			    									  ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
				  	              							  ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
					  					              		  ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo
                                          
   -- Procedure da Tela: ESTORN, Acao: Relatorio
   PROCEDURE pc_tela_imprimir_relatorio(pr_nrdconta IN crapepr.nrdconta%TYPE        --> Numero da Conta
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE        --> Numero do Contrato
                                       ,pr_dtmvtolt IN VARCHAR2                     --> Data de Movimento
                                       ,pr_dtiniest IN VARCHAR2                     --> Data Inicio do Estorno
                                       ,pr_dtfinest IN VARCHAR2                     --> Data Fim do Estorno
                                       ,pr_cdagenci IN tbepr_estorno.cdagenci%TYPE  --> Agencia
                						 			 		 ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
 	  			    	          	 			 		 ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
		  				    				         		 ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
            			    								 ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
				  	              						 ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
					  					              	 ,pr_des_erro OUT VARCHAR2);                  --> Erros do processo                                       
                                                                            
   -- Procedure da Tela: ESTORN, para buscar todos os contratos PP
   PROCEDURE pc_tela_busca_contratos_pp(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
				    	          	     			 	 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
						    				               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
          			    							     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					              					     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                                       

   -- Procedure Reponsavel para buscar quais os lancamentos que deverao ser estornados
	 PROCEDURE pc_busca_lancamentos_pagto(pr_cdcooper            IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci            IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa            IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad            IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela            IN VARCHAR2 --> Nome da tela
                                       ,pr_idorigem            IN INTEGER --> Id do módulo de sistema
                                       ,pr_nrdconta            IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_idseqttl            IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_nrctremp            IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                       ,pr_des_reto            OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro            OUT gene0001.typ_tab_erro --> Tabela com possíves erros
                                       ,pr_tab_lancto_parcelas OUT EMPR0008.typ_tab_lancto_parcelas); --> Tabela com registros de estorno
         
   -- Calcula os dias uteis de acordo com o periodo passado como parametro                                  
   FUNCTION fn_retorna_data_util(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                ,pr_dtiniper IN DATE                      --> Data de Inicio do Periodo
                                ,pr_qtdialib IN PLS_INTEGER) RETURN DATE; --> Quantidade de dias para acrescentar
END EMPR0008;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0008 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0008
  --  Sistema  : Rotinas referentes a Portabilidade de Credito
  --  Sigla    : EMPR
  --  Autor    : James Prust Junior
  --  Data     : Julho - 2015.                   Ultima atualizacao: 16/10/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas ao Estorno de Parcelas do PP
  --
  -- Alteracoes:
  /*
  31/01/2018 - #826621 Conforme posicionamento da área, os contratos de portabilidade também poderão 
               ser estornados. Regra retirada do sistema. (Carlos)
               
  03/05/2018 - P404 - Inclusão do novo tipo de contrato 4, para permitir estornos e não lançar a crítica
               linha de crédito não permitida (Lucas Skroch - Supero)
               
  16/08/2018 - 9140:Estorno do Pagamento de Empréstimos Rangel Decker (AMcom) 
                    - pc_tela_estornar_pagamentos
                    - pc_efetua_estor_pgto_no_dia            
                    
  16/10/2018 - 11017:Avaliação necessidade tratamento no DELETE LCM programa empr0008.pck (Heckmann - AMcom)
               - Substituição do Delete da CRAPLCM pela chamada da rotina LANC0001.pc_estorna_lancto_conta
  */
  ---------------------------------------------------------------------------  
  PROCEDURE pc_tela_busca_lancto_estorno(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_busca_lancto_estorno
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Setembro/15.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para buscar os lancamento de pagamento

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      TYPE typ_reg_estorno_parcel IS RECORD(     
         nrparepr crappep.nrparepr%TYPE
        ,dtvencto crappep.dtvencto%TYPE
        ,dtdpagto craplem.dtmvtolt%TYPE    
        ,vlpagpar crappep.vlpagpar%TYPE
        ,vlpagmta crappep.vlpagmta%TYPE
        ,vlpagmra crappep.vlpagmra%TYPE);

      /* Definicao de tabela que compreende os registros acima declarados */
      TYPE typ_tab_estorno_parcel IS TABLE OF typ_reg_estorno_parcel INDEX BY VARCHAR2(20);
      
      vr_tab_erro               GENE0001.typ_tab_erro;
      vr_tab_lancto_parcelas    EMPR0008.typ_tab_lancto_parcelas;
      vr_tab_estorno_parcel     typ_tab_estorno_parcel;
    
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_des_reto      VARCHAR2(3);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_ind_estorno     VARCHAR2(20);
      vr_contador        PLS_INTEGER := 0;      
      vr_vlpagpar        crappep.vlpagpar%TYPE;
      vr_vlpagmta        crappep.vlpagmta%TYPE;
      vr_vlpagmra        crappep.vlpagmra%TYPE;
      vr_vlpagtot        crappep.vlpagpar%TYPE;
      vr_qtdlacto        PLS_INTEGER     := 0;      
      vr_xml_temp        VARCHAR2(32726) := '';
      vr_clob            CLOB;
          
    BEGIN
      vr_tab_estorno_parcel.DELETE;
      vr_tab_lancto_parcelas.DELETE;

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);  
  
      -- Busca os lancamento que podem ser estornados para o contrato informado                     
      pc_busca_lancamentos_pagto(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_idorigem => vr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => 1
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_tab_lancto_parcelas => vr_tab_lancto_parcelas);
                                           
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Buscar o erro encontrado para gravar na vr_des_erro
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      -- Vamos verificar se possui registro
      IF vr_tab_lancto_parcelas.COUNT <= 0 THEN
        vr_dscritic := 'Lancamento de pagamento nao encontrado';
        RAISE vr_exc_saida;
      END IF;
      
      /* Percorre todos os lancamentos de acordo com a data de movimento */
      FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP
        -- Vamos verificar quais sao os lancamentos que vamos apresentar em Tela
        IF vr_tab_lancto_parcelas(idx).flgestor = FALSE THEN
          CONTINUE;
        END IF;      
      
        -- Indice da nova Temp-Table
        vr_ind_estorno := TO_CHAR(LPAD(vr_tab_lancto_parcelas(idx).nrparepr,4,'0'))|| '_' ||TO_CHAR(vr_tab_lancto_parcelas(idx).dtmvtolt,'DD/MM/YYYY');
        vr_vlpagpar    := 0;
        vr_vlpagmra    := 0;
        vr_vlpagmta    := 0;
        
        -- Credito de Pagamento
        IF vr_tab_lancto_parcelas(idx).cdhistor IN (1039,1044,1045,1057) THEN
          vr_vlpagpar := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
        
        -- Juros de Mora
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1619,1077,1620,1078) THEN
          vr_vlpagmra := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          
        -- Multa
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1540,1047,1618,1076) THEN
          vr_vlpagmta := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);          
          
        ELSE
          vr_dscritic := 'Historico nao permitido para efetuar o estorno. Codigo: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).cdhistor);
          RAISE vr_exc_saida;
        END IF;

        -- Valor Pago Total
        vr_vlpagtot := NVL(vr_vlpagtot,0) + NVL(vr_vlpagpar,0) + NVL(vr_vlpagmta,0) + NVL(vr_vlpagmra,0);        
        -- Agrupa os lancamentos por Parcela e Data de Movimento
        IF vr_tab_estorno_parcel.EXISTS(vr_ind_estorno) THEN
          vr_tab_estorno_parcel(vr_ind_estorno).vlpagpar := NVL(vr_tab_estorno_parcel(vr_ind_estorno).vlpagpar,0) + NVL(vr_vlpagpar,0);
          vr_tab_estorno_parcel(vr_ind_estorno).vlpagmta := NVL(vr_tab_estorno_parcel(vr_ind_estorno).vlpagmta,0) + NVL(vr_vlpagmta,0);
          vr_tab_estorno_parcel(vr_ind_estorno).vlpagmra := NVL(vr_tab_estorno_parcel(vr_ind_estorno).vlpagmra,0) + NVL(vr_vlpagmra,0);
        ELSE
          vr_tab_estorno_parcel(vr_ind_estorno).nrparepr := vr_tab_lancto_parcelas(idx).nrparepr;
          vr_tab_estorno_parcel(vr_ind_estorno).dtvencto := vr_tab_lancto_parcelas(idx).dtvencto;
          vr_tab_estorno_parcel(vr_ind_estorno).dtdpagto := vr_tab_lancto_parcelas(idx).dtmvtolt;
          vr_tab_estorno_parcel(vr_ind_estorno).vlpagpar := NVL(vr_vlpagpar,0);
          vr_tab_estorno_parcel(vr_ind_estorno).vlpagmta := NVL(vr_vlpagmta,0);
          vr_tab_estorno_parcel(vr_ind_estorno).vlpagmra := NVL(vr_vlpagmra,0);
        END IF;
      END LOOP;
      
      -- Monta documento XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados><Lancamentos>');
      
      vr_ind_estorno := vr_tab_estorno_parcel.FIRST;
      WHILE vr_ind_estorno IS NOT NULL LOOP
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<lancamento>'||
                                                        '<nrparepr>' || vr_tab_estorno_parcel(vr_ind_estorno).nrparepr                          ||'</nrparepr>'||
                                                        '<dtvencto>' || TO_CHAR(vr_tab_estorno_parcel(vr_ind_estorno).dtvencto,'DD/MM/YYYY')    ||'</dtvencto>'||
                                                        '<dtdpagto>' || TO_CHAR(vr_tab_estorno_parcel(vr_ind_estorno).dtdpagto,'DD/MM/YYYY')    ||'</dtdpagto>'||
                                                        '<vlpagpar>' || vr_tab_estorno_parcel(vr_ind_estorno).vlpagpar                          ||'</vlpagpar>'||
                                                        '<vlpagmta>' || vr_tab_estorno_parcel(vr_ind_estorno).vlpagmta                          ||'</vlpagmta>'||
                                                        '<vlpagmra>' || vr_tab_estorno_parcel(vr_ind_estorno).vlpagmra                          ||'</vlpagmra>'||
                                                     '</lancamento>');
        --Proximo registro
        vr_contador    := vr_contador + 1;
        vr_ind_estorno := vr_tab_estorno_parcel.NEXT(vr_ind_estorno);
      END LOOP;      
      -- Quantidade de Lancamentos
      vr_qtdlacto := NVL(vr_tab_lancto_parcelas.COUNT,0);      
      -- Cria a Tag com os Totais
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '  </Lancamentos>'||
                                                   '  <Total>'||
                                                   '    <vlpagtot>'|| vr_vlpagtot ||'</vlpagtot>' ||
                                                   '    <qtdlacto>'|| vr_qtdlacto ||'</qtdlacto>' ||
                                                   '  </Total>'||
                                                   '</Dados>'
                             ,pr_fecha_xml      => TRUE);
    
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_busca_lancto_estorno: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;  
  
  END pc_tela_busca_lancto_estorno;
  
  PROCEDURE pc_tela_busca_contratos_pp(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
		     	    	          					  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
				     	    				            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
         			    							      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
				              					      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_busca_contratos_pp
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Setembro/15.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Buscar todos os contratos PP

     Observacao: -----
     Alteracoes:
     ..............................................................................*/

    DECLARE
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE,
                        pr_nrdconta IN crapepr.nrdconta%TYPE,
                        pr_tpemprst IN crapepr.tpemprst%TYPE) IS
			  SELECT nrctremp,
               dtmvtolt,
               vlemprst,
               qtpreemp,
               vlpreemp,
               cdlcremp,
               cdfinemp
				  FROM crapepr
				 WHERE crapepr.cdcooper = pr_cdcooper
				 	 AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.tpemprst = pr_tpemprst;
           
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      vr_contador      PLS_INTEGER := 0;

    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);  
                              
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');                        
                 
      -- Busca todos os emprestimos de acordo com o numero da conta
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => vr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_tpemprst => 1) LOOP

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_crapepr.nrctremp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(rw_crapepr.dtmvtolt,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtpreemp', pr_tag_cont => rw_crapepr.qtpreemp, pr_des_erro => vr_dscritic);        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlemprst', pr_tag_cont => rw_crapepr.vlemprst, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlpreemp', pr_tag_cont => rw_crapepr.vlpreemp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdlcremp', pr_tag_cont => rw_crapepr.cdlcremp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdfinemp', pr_tag_cont => rw_crapepr.cdfinemp, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;

      END LOOP; /* END FOR rw_craplem */
          
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;


        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_busca_contratos_pp: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;  
             
  END pc_tela_busca_contratos_pp;
  
  /* Criar e Atualizar Tabela Temporaria Lancamento Conta  */
  PROCEDURE pc_cria_atualiza_ttlanconta(pr_cdcooper      IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_nrctremp      IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_cdhistor      IN craphis.cdhistor%TYPE --> Codigo Historico
                                       ,pr_dtmvtolt      IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_cdoperad      IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_cdpactra      IN INTEGER               --> P.A. da transação                                       
                                       ,pr_nrdolote      IN craplot.nrdolote%TYPE --> Numero do Lote
                                       ,pr_nrdconta      IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_vllanmto      IN NUMBER                --> Valor lancamento
                                       ,pr_nrseqava      IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
                                       ,pr_tab_lancconta IN OUT empr0001.typ_tab_lancconta --> Tabela Lancamentos Conta                                                                              
                                       ,pr_des_erro      OUT VARCHAR              --> Retorno OK / NOK
                                       ,pr_dscritic      OUT VARCHAR2) IS         --> descricao do erro
  BEGIN
    /* .............................................................................
    
       Programa: pc_cria_atualiza_ttlanconta                 Antigo: 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Setembro/2015                        Ultima atualizacao:
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Rotina para Efetuar Criacao/Atualizacao da ttlancconta
    
       Alteracoes:     
    ............................................................................. */
  
    DECLARE
      --Variaveis Erro
      vr_dscritic VARCHAR2(4000);
    
      --Variaveis de Indices
      vr_index     VARCHAR2(80); 
    BEGIN  
      
      --Montar Indice para acesso
      vr_index:= lpad(pr_cdcooper,10,'0')||
                 lpad(pr_nrctremp,10,'0')||
                 lpad(pr_nrdconta,10,'0')||
                 lpad(pr_cdhistor,10,'0');
      --Se nao encontrou
      IF pr_tab_lancconta.EXISTS(vr_index) THEN
        --Atualizar Lancamento
        pr_tab_lancconta(vr_index).vllanmto := nvl(pr_tab_lancconta(vr_index).vllanmto,0) + pr_vllanmto;
      ELSE
        --Cadastrar Lancamento
        pr_tab_lancconta(vr_index).cdcooper:= pr_cdcooper;
        pr_tab_lancconta(vr_index).nrctremp:= pr_nrctremp;
        pr_tab_lancconta(vr_index).cdhistor:= pr_cdhistor;
        pr_tab_lancconta(vr_index).dtmvtolt:= pr_dtmvtolt;
        pr_tab_lancconta(vr_index).cdagenci:= pr_cdpactra;
        pr_tab_lancconta(vr_index).cdbccxlt:= 100;
        pr_tab_lancconta(vr_index).cdoperad:= pr_cdoperad;
        pr_tab_lancconta(vr_index).nrdolote:= pr_nrdolote;
        pr_tab_lancconta(vr_index).nrdconta:= pr_nrdconta;
        pr_tab_lancconta(vr_index).vllanmto:= pr_vllanmto;
        pr_tab_lancconta(vr_index).cdpactra:= pr_cdpactra;
        pr_tab_lancconta(vr_index).nrseqava:= pr_nrseqava;
      END IF;
      
      pr_des_erro:= 'OK';
          
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        -- Devolvemos a critica encontradas das variaveis locais        
        pr_dscritic := 'Erro geral em EMPR0008.pc_cria_atualiza_ttlanconta: ' ||SQLERRM;
    END;
  END pc_cria_atualiza_ttlanconta;

  -- Procedure Reponsavel por efetuar o estorno da parcela pago no mesmo dia
	PROCEDURE pc_efetua_estor_pgto_no_dia(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                       ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE --> Data de Movimento
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                       ,pr_nrparepr IN crappep.nrparepr%TYPE --> Numero da Parcela
                                       ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
	BEGIN											 
	  /* .............................................................................

      Programa: pc_efetua_estor_pgto_no_dia
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : James Prust Junior
      Data    : Setembro/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente ao Estorno de pagamento de parcelas do mesmo dia

      Observacao: -----

      Alteracoes: 
    ..............................................................................*/
		DECLARE  
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      
        --Valor dos lançamentos envolvidos  no estorno
			CURSOR cr_craplem (pr_cdcooper IN craplcm.cdcooper%TYPE,
                           pr_nrdconta IN craplcm.nrdconta%TYPE,
                         pr_nrctremp IN craplem.nrctremp%TYPE,
                         pr_nrparepr IN craplem.nrparepr%TYPE,
												 pr_dtmvtolt IN craplcm.dtmvtolt%TYPE)  IS
			SELECT SUM(craplem.vllanmto) vllanmto 
        FROM craplem,
             craphis 
       WHERE craphis.cdcooper = craplem.cdcooper
         AND craphis.cdhistor = craplem.cdhistor
         AND craphis.indcalem = 'S'
         AND craplem.cdcooper = pr_cdcooper
         AND craplem.nrdconta = pr_nrdconta
         AND craplem.nrctremp = pr_nrctremp
         AND craplem.nrparepr = pr_nrparepr
         AND craplem.dtmvtolt = pr_dtmvtolt
         AND craplem.cdbccxlt = 100
         AND craplem.nrdolote > 600000
         AND craplem.nrdolote < 650000
         AND craplem.cdhistor IN (1038,1039,1037,1044,1540,1619,1050,1045,1047,
                                  1077,1048,1049,1618,1620,1051,1057,1076,1078);
			rw_craplem cr_craplem%ROWTYPE;
      
      -- Cursor para buscar o ROWID da CRAPLCM para exclusão do registro pela centralizadora
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE,
												 pr_nrdconta IN craplcm.nrdconta%TYPE,
                         pr_nrctremp IN craplem.nrctremp%TYPE,
                         pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
      SELECT craplcm.rowid
        FROM craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
           AND craplcm.nrdconta = pr_nrdconta
           AND craplcm.dtmvtolt = pr_dtmvtolt
           AND craplcm.nrdolote > 600000
           AND craplcm.nrdolote < 650000
           AND craplcm.cdbccxlt = 100
           AND craplcm.cdhistor IN (108,1539,1541,1543,1060,1071,1542,1544,1070,1072)
           AND TO_NUMBER(TRIM(REPLACE(craplcm.cdpesqbb,'.',''))) = pr_nrctremp;
      rw_craplcm cr_craplcm%ROWTYPE;
      
    BEGIN
      IF NOT PREJ0003.fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta) THEN
      -- Exclui os lancamentos da Conta Corrente
      BEGIN
        OPEN cr_craplcm( pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctremp => pr_nrctremp,
                         pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_craplcm INTO rw_craplcm;
        
        IF cr_craplcm%NOTFOUND THEN
          CLOSE cr_craplcm;
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel recuperar os dados do lancamento para estornar.';
          RAISE vr_exc_saida;
        END IF;
        
        -- Chamada da rotina centralizadora em substituição ao DELETE
        LANC0001.pc_estorna_lancto_conta(pr_cdcooper => NULL
                                       , pr_dtmvtolt => NULL
                                       , pr_cdagenci => NULL
                                       , pr_cdbccxlt => NULL
                                       , pr_nrdolote => NULL
                                       , pr_nrdctabb => NULL
                                       , pr_nrdocmto => NULL
                                       , pr_cdhistor => NULL
                                       , pr_nrctachq => NULL
                                       , pr_nrdconta => NULL
                                       , pr_cdpesqbb => NULL
                                       , pr_rowid    => rw_craplcm.rowid
                                       , pr_cdcritic => vr_cdcritic
                                       , pr_dscritic => vr_dscritic);
                                       
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel excluir os lancamentos da conta corrente';
          RAISE vr_exc_saida;
      END;
    ELSE
        OPEN cr_craplem( pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctremp => pr_nrctremp,
                         pr_nrparepr => pr_nrparepr,
                         pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_craplem INTO rw_craplem;

        IF cr_craplem%NOTFOUND THEN
          CLOSE cr_craplem;

          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel recuperar os dados do lancamento para estornar.';
          RAISE vr_exc_saida;
        END IF;

        CLOSE cr_craplem; 
        
        IF nvl(rw_craplem.vllanmto,0) > 0 THEN
  			
          PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
                                      , pr_nrdconta => pr_nrdconta
                                      , pr_cdoperad => pr_cdoperad
                                      , pr_vlrlanc  => rw_craplem.vllanmto
                                      , pr_dtmvtolt => pr_dtmvtolt
                                      , pr_cdcritic => vr_cdcritic
                                      , pr_dscritic => vr_dscritic);

          IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            RAISE vr_exc_saida; 
          END IF;

                                     
        END IF;                                 
      END IF;
		 
      -- Exclui os lancamentos do extratdo do empréstimo
      BEGIN
        DELETE FROM craplem
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.nrparepr = pr_nrparepr
           AND craplem.dtmvtolt = pr_dtmvtolt
           AND craplem.cdbccxlt = 100
           AND craplem.nrdolote > 600000
           AND craplem.nrdolote < 650000
           AND craplem.cdhistor IN (1038,1039,1037,1044,1540,1619,1050,1045,1047,
                                    1077,1048,1049,1618,1620,1051,1057,1076,1078);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel excluir os lancamentos do emprestimo';
          RAISE vr_exc_saida;
      END;
      
      pr_des_reto := 'OK';

		EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
			WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na EMPR0008.pc_efetua_estor_pgto_no_dia ' || sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

		END;
          
  END pc_efetua_estor_pgto_no_dia;
  
  -- Procedure Reponsavel por efetuar o estorno da parcela pago em dias diferentes
	PROCEDURE pc_efetua_estor_pgto_outro_dia(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                          ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                          ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                          ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                          ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                          ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                          ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                          ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE --> Data de Movimento
                                          ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                          ,pr_nrparepr IN crappep.nrparepr%TYPE --> Numero da Parcela
                                          ,pr_cdhisest IN craphis.cdhisest%TYPE --> Codigo do Historico de Estorno
                                          ,pr_vllanmto IN craplem.vllanmto%TYPE --> Valor do Lancamento
                                          ,pr_nrdrecid IN craplem.progress_recid%TYPE
                                          ,pr_dtpagemp IN craplem.dtpagemp%TYPE
                                          ,pr_txjurepr IN craplem.txjurepr%TYPE
                                          ,pr_vlpreemp IN craplem.vlpreemp%TYPE
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
	BEGIN											 
	  /* .............................................................................

      Programa: pc_efetua_estor_pgto_outro_dia
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : James Prust Junior
      Data    : Setembro/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente ao Estorno de pagamento de parcelas com pagamento em Outro dia

      Observacao: 02/02/2016 - Incluso novo parametro cdorigem na chamada da procedure 
	                           EMPR0001.pc_cria_lancamento_lem (Daniel) 

      Alteracoes: 
    ..............................................................................*/
		DECLARE  
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
    
      -- A cada lancamento sera gravado a data que foi realizado o estorno
      BEGIN
        UPDATE craplem
           SET craplem.dtestorn = pr_dtmvtolt
         WHERE craplem.progress_recid = pr_nrdrecid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar na tabela de craplem. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Cria o lancamento de estorno
      EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data Emprestimo
                                     ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                     ,pr_cdbccxlt => 100           --Codigo Caixa
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_cdpactra => pr_cdagenci   --Posto Atendimento
                                     ,pr_tplotmov => 5             --Tipo movimento
                                     ,pr_nrdolote => 600031        --Numero Lote
                                     ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                     ,pr_cdhistor => pr_cdhisest   --Codigo Historico                            
                                     ,pr_nrctremp => pr_nrctremp   --Numero Contrato
                                     ,pr_vllanmto => pr_vllanmto   --Valor Lancamento
                                     ,pr_dtpagemp => pr_dtpagemp   --Data Pagamento Emprestimo                            
                                     ,pr_txjurepr => pr_txjurepr   --Taxa Juros Emprestimo
                                     ,pr_vlpreemp => pr_vlpreemp   --Valor Emprestimo
                                     ,pr_nrsequni => 0             --Numero Sequencia
                                     ,pr_nrparepr => pr_nrparepr   --Numero Parcelas Emprestimo
                                     ,pr_flgincre => FALSE         --Indicador Credito
                                     ,pr_flgcredi => FALSE         --Credito                            
                                     ,pr_nrseqava => 0             --Pagamento: Sequencia do avalista
                                     ,pr_cdorigem => pr_idorigem
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Erro
                                     ,pr_dscritic => vr_dscritic); --Descricao Erro
                                     
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      pr_des_reto := 'OK';

		EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
			WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na EMPR0008.pc_efetua_estor_pgto_outro_dia ' || sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

		END;
          
  END pc_efetua_estor_pgto_outro_dia;
  
  PROCEDURE pc_tela_valida_estorno(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                  ,pr_qtdlacto IN PLS_INTEGER           --> Quantidade de Lancamento
                                  ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
               									  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
			      	          				  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
					      				          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
         		  	    						  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					                				,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
									  	            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_valida_estorno
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Setembro/15.                    Ultima atualizacao: 14/02/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Validacao para efetuar o estorno

     Observacao: -----

     Alteracoes: 14/02/2017 - Nao permitir estorno para situacao Ativo ou Quitado. (Jaison/James - PRJ302)

     ..............................................................................*/
    DECLARE
      vr_tab_erro                  GENE0001.typ_tab_erro;
      vr_tab_lancto_parcelas       EMPR0008.typ_tab_lancto_parcelas;
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_des_reto      VARCHAR2(3);
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_dstextab        craptab.dstextab%TYPE;
      vr_vlmaxest        NUMBER(15,2) := 0;
      vr_vltotest        NUMBER(15,2) := 0;
      vr_flgretativo     INTEGER := 0;
      vr_flgretquitado   INTEGER := 0;
      vr_flgretcancelado INTEGER := 0;
    
    BEGIN
      vr_tab_erro.DELETE;
      vr_tab_lancto_parcelas.DELETE;
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      /* Validar a quantidade de caracter do campo Justificativa */
      IF NVL(LENGTH(TRIM(pr_dsjustificativa)),0) = 0 THEN
        vr_dscritic := 'O campo Justificativa nao foi informado';
        RAISE vr_exc_saida;
      
      ELSIF NVL(LENGTH(TRIM(pr_dsjustificativa)),0) < 10 THEN
        vr_dscritic := 'E necessario detalhar mais o campo Justificativa';
        RAISE vr_exc_saida;
        
      ELSIF NVL(LENGTH(TRIM(pr_dsjustificativa)),0) > 250 THEN
        vr_dscritic := 'O tamanho do texto do campo Justificativa excedeu o tamanho maximo';
        RAISE vr_exc_saida;      
      END IF;                        

      RECP0001.pc_verifica_situacao_acordo(pr_cdcooper        => vr_cdcooper
                                          ,pr_nrdconta        => pr_nrdconta
                                          ,pr_nrctremp        => pr_nrctremp
                                          ,pr_cdorigem        => 3
                                          ,pr_flgretativo     => vr_flgretativo    
                                          ,pr_flgretquitado   => vr_flgretquitado  
                                         	,pr_flgretcancelado => vr_flgretcancelado
                                          ,pr_cdcritic        => vr_cdcritic
                                          ,pr_dscritic        => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se estiver ATIVO
      IF vr_flgretativo = 1 THEN
        vr_dscritic := 'Estorno nao permitido, emprestimo em acordo.';
        RAISE vr_exc_saida;
      END IF;
                 
      -- Se estiver QUITADO
      IF vr_flgretquitado = 1 THEN
        vr_dscritic := 'Lancamento nao permitido, contrato liquidado atraves de acordo.';
        RAISE vr_exc_saida;
      END IF;

      vr_vlmaxest := 0;
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPREST'
                                               ,pr_tpregist => 1);
      --Se nao encontrou parametro
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_cdcritic := 55;
        RAISE vr_exc_saida;
      ELSE
        vr_vlmaxest := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 40, 12)),0);
      END IF;      
      
      -- Busca os lancamento que podem ser estornados para o contrato informado
      pc_busca_lancamentos_pagto(pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_idorigem => vr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => 1
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_tab_lancto_parcelas => vr_tab_lancto_parcelas);
                                           
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Buscar o erro encontrado para gravar na vr_des_erro
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;
            
      -- Verifica se a quantidade de registros que serao estornado eh igual aos registros que estao na consulta
      IF vr_tab_lancto_parcelas.COUNT <> pr_qtdlacto THEN
        vr_dscritic := 'Contrato foi alterado por outro operador, recarregue a tela';
        RAISE vr_exc_saida;
        
      END IF;
      
      vr_vltotest := 0;
      -- Vamos percorrer todos os lancamentos que serao estornados
      FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP
        -- Somente vamos somar o que for para estornar  
        IF vr_tab_lancto_parcelas(idx).flgestor = TRUE THEN
          vr_vltotest := vr_vltotest +  NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          
        END IF;                                 
       
      END LOOP;

      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      
      -- Vamos verificar o Valor maximo de estorno permitido sem autorizacao da coordenacao/gerencia
      IF vr_vltotest >= vr_vlmaxest THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgsenha', pr_tag_cont => 1, pr_des_erro => vr_dscritic);
      ELSE
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgsenha', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
        
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_valida_estorno: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;  
  
  END pc_tela_valida_estorno;
  
  PROCEDURE pc_tela_estornar_pagamentos(pr_cdcooper IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                       ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE --> Movimento atual
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_estornar_pagamentos
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Setembro/15.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Buscar todos os contratos PP

     Observacao: -----
     Alteracoes:
     ..............................................................................*/

    DECLARE
      -- Cursor do Lancamento do Emprestimo
      CURSOR cr_craplem_max(pr_cdcooper IN craplem.cdcooper%TYPE,
                            pr_nrdconta IN craplem.nrdconta%TYPE,
                            pr_nrctremp IN craplem.nrctremp%TYPE,
                            pr_nrparepr IN craplem.nrparepr%TYPE) IS
			  SELECT MAX(craplem.dtmvtolt) as dtmvtolt
				  FROM craplem
				 WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.nrparepr = pr_nrparepr
           AND craplem.dtestorn IS NULL
           AND craplem.cdhistor IN (1039,1044,1045,1057);
      
      /* Cursor para buscar o lancamento de Juros Remuneratorio */
      CURSOR cr_craplem_juros(pr_cdcooper IN craplem.cdcooper%TYPE,
                              pr_nrdconta IN craplem.nrdconta%TYPE,
                              pr_nrctremp IN craplem.nrctremp%TYPE,
                              pr_nrparepr IN craplem.nrparepr%TYPE,
                              pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
			  SELECT craplem.vllanmto,
               count(1) over() qtde_registro
				  FROM craplem
				 WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.nrparepr = pr_nrparepr
           AND craplem.dtmvtolt = pr_dtmvtolt
           AND craplem.cdhistor IN (1050,1051);
      rw_craplem_juros cr_craplem_juros%ROWTYPE;     
      
      -- Cursor para buscar a ultima parcela que foi paga
      CURSOR cr_crappep_max_pagto(pr_cdcooper IN crappep.cdcooper%TYPE,
                                  pr_nrdconta IN crappep.nrdconta%TYPE,
                                  pr_nrctremp IN crappep.nrctremp%TYPE) IS
			  SELECT MAX(crappep.dtultpag) dtultpag
				  FROM crappep
				 WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp;
      vr_dtultpag crappep.dtultpag%TYPE;
      
      -- Cursor para buscar a primeira parcela que nao foi paga
      CURSOR cr_crappep_min_dtvencto(pr_cdcooper IN crappep.cdcooper%TYPE,
                                     pr_nrdconta IN crappep.nrdconta%TYPE,
                                     pr_nrctremp IN crappep.nrctremp%TYPE) IS
			  SELECT MIN(crappep.dtvencto) dtvencto
				  FROM crappep
				 WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.inliquid = 0;
      vr_dtvencto crappep.dtvencto%TYPE;     
      
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE,
                        pr_nrdconta IN crappep.nrdconta%TYPE,
                        pr_nrctremp IN crappep.nrctremp%TYPE,
                        pr_nrparepr IN crappep.nrparepr%TYPE) IS
			  SELECT inliquid,
               dtultpag
				  FROM crappep
				 WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      
      -- Cursor para buscar os bens do emprestimo
      CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE,
                        pr_nrdconta IN crapbpr.nrdconta%TYPE,
                        pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
        SELECT COUNT(1) total
          FROM crapbpr
         WHERE crapbpr.cdcooper = pr_cdcooper
           AND crapbpr.nrdconta = pr_nrdconta
           AND crapbpr.nrctrpro = pr_nrctremp
           AND crapbpr.tpctrpro IN (90,99)
           AND crapbpr.cdsitgrv IN (0,2)
           AND crapbpr.flgbaixa = 1           
           AND crapbpr.tpdbaixa = 'A';
      vr_existbpr PLS_INTEGER := 0;
      
      -- Cursor para o historico do lancamento     
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE,
                        pr_cdhistor IN craphis.cdhistor%TYPE) IS
			  SELECT cdhisest
				  FROM craphis
				 WHERE craphis.cdcooper = pr_cdcooper
           AND craphis.cdhistor = pr_cdhistor;
      vr_cdhisest craphis.cdhisest%TYPE;
           
      -- Verifica se alguma parcela ficou com saldo negativo
      CURSOR cr_crappep_saldo(pr_cdcooper IN crappep.cdcooper%TYPE,
                              pr_nrdconta IN crappep.nrdconta%TYPE,
                              pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT 1
				  FROM crappep
				 WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND (crappep.vlpagpar < 0 OR
                crappep.vlsdvpar < 0 OR
                crappep.vlsdvsji < 0 OR
                crappep.vldespar < 0 OR
                crappep.vlpagmra < 0 OR
                crappep.vlpagmta < 0);                       
      vr_flgnegat PLS_INTEGER := 0;
           
      vr_tab_erro                  GENE0001.typ_tab_erro;
      vr_tab_lancto_parcelas       EMPR0008.typ_tab_lancto_parcelas;
      vr_tab_lancto_cc             EMPR0001.typ_tab_lancconta;
      vr_cdestorno                 tbepr_estorno.cdestorno%TYPE;
      vr_cdlancamento              tbepr_estornolancamento.cdlancamento%TYPE;
      vr_vlpagpar                  crappep.vlpagpar%TYPE;
      vr_vlpagmta                  crappep.vlpagmta%TYPE;
      vr_vlpagmra                  crappep.vlpagmra%TYPE;
      vr_vljuratr                  craplem.vllanmto%TYPE;
      vr_vldescto                  craplem.vllanmto%TYPE;      
      vr_dtmvtolt                  DATE;      
      vr_index_lanc                VARCHAR2(80);
      vr_cdhislcm                  PLS_INTEGER;
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_des_reto      VARCHAR2(3);

    BEGIN
      vr_tab_erro.DELETE;
      vr_tab_lancto_parcelas.DELETE;
      vr_tab_lancto_cc.DELETE;
           
      -- Busca os lancamento que podem ser estornados para o contrato informado                     
      pc_busca_lancamentos_pagto(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_idorigem => pr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nrctremp => pr_nrctremp
                                ,pr_des_reto => vr_des_reto
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_tab_lancto_parcelas => vr_tab_lancto_parcelas);
                                           
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Buscar o erro encontrado para gravar na vr_des_erro
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;
            
      --Cria o registro do Estorno
      BEGIN
        INSERT INTO tbepr_estorno
          (cdcooper
          ,cdestorno
          ,nrdconta
          ,nrctremp
          ,cdoperad
          ,cdagenci
          ,dtestorno
          ,hrestorno
          ,dsjustificativa)
        VALUES
          (pr_cdcooper
          ,fn_sequence('TBEPR_ESTORNO','CDESTORNO',pr_cdcooper)
          ,pr_nrdconta
          ,pr_nrctremp
          ,pr_cdoperad
          ,pr_cdagenci
          ,pr_dtmvtolt
          ,gene0002.fn_busca_time
          ,pr_dsjustificativa)
          RETURNING tbepr_estorno.cdestorno INTO vr_cdestorno;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir na tabela de tbepr_estorno. ' ||SQLERRM;
          RAISE vr_exc_saida;
      END;      
      
      -- Cursor para verificar se precisa fazer as baixas dos bens
      OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => pr_nrctremp);
      FETCH cr_crapbpr
       INTO vr_existbpr;
      CLOSE cr_crapbpr;
                       
      IF NVL(vr_existbpr,0) > 0 THEN
        -- Solicita a baixa no gravames
        GRVM0001.pc_desfazer_baixa_automatica(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrctrpro => pr_nrctremp
                                             ,pr_des_reto => vr_des_reto
                                             ,pr_tab_erro => vr_tab_erro);
        IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            -- Buscar o erro encontrado para gravar na vr_des_erro
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            RAISE vr_exc_saida;
          END IF;  
        END IF;
        
      END IF; -- END IF NVL(vr_existbpr,0) > 0 THEN
        
      -- Percorre todos os lancamentos de acordo com a data de movimento
      FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP
        vr_cdhislcm := 0; -- Historico de lancamento na conta corrente
        vr_vlpagpar := 0; -- Valor do Pagamento
        vr_vlpagmta := 0; -- Valor Pago na Multa
        vr_vlpagmra := 0; -- Valor Pago no Juros de Mora
        vr_vljuratr := 0; -- Valor do Juros em Atraso
        vr_vldescto := 0; -- Valor de Desconto
        
        -- Busca os dados da parcela
        OPEN cr_crappep (pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                         pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                         pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                         pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr);
        FETCH cr_crappep INTO rw_crappep;
        -- Verifica se a retornou registro
        IF cr_crappep%NOTFOUND THEN
          CLOSE cr_crappep;
          vr_dscritic := 'Parcela nao encontrada' ||
                         '. Conta: '    || TO_CHAR(vr_tab_lancto_parcelas(idx).nrdconta) ||
                         '. Contrato: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).nrctremp) ||
                         '. Parcela: '  || TO_CHAR(vr_tab_lancto_parcelas(idx).nrparepr);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas Fecha o Cursor
          CLOSE cr_crappep;
        END IF;
        
        -- Vamos verificar se o historico do lancamento possui historico de estorno cadastrado
        OPEN cr_craphis (pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                         pr_cdhistor => vr_tab_lancto_parcelas(idx).cdhistor);
        FETCH cr_craphis
         INTO vr_cdhisest;
        CLOSE cr_craphis;
        
        IF NVL(vr_cdhisest,0) = 0 THEN
          vr_dscritic := 'Historico nao possui codigo de estorno cadastrado. Historico: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).cdhistor);
          RAISE vr_exc_saida;
        END IF;
        
        -- Verifica se o historico eh pagamento
        IF vr_tab_lancto_parcelas(idx).cdhistor IN (1039,1044,1045,1057) THEN
          -- Valor do Pagamento da Parcela
          vr_vlpagpar := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor IN (1045,1057) THEN
            vr_cdhislcm := 1539;
          ELSE
            vr_cdhislcm := 108;
          END IF;
          
        -- Juros de Mora
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1619,1077,1620,1078) THEN
          vr_vlpagmra := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor = 1619 THEN
            vr_cdhislcm := 1543;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1077 THEN
            vr_cdhislcm := 1071;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1620 THEN
            vr_cdhislcm := 1544;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1078 THEN
            vr_cdhislcm := 1072;
          END IF;
          
        -- Multa
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1540,1047,1618,1076) THEN
          vr_vlpagmta := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor = 1540 THEN
            vr_cdhislcm := 1541;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1047 THEN
            vr_cdhislcm := 1060;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1618 THEN
            vr_cdhislcm := 1542;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1076 THEN
            vr_cdhislcm := 1070;
          END IF;
          
        -- Juros de Atraso  
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1050,1051) THEN
          vr_vljuratr := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          
        -- Valor de Desconto
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1048,1049) THEN
          vr_vldescto := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          
        ELSE
          vr_dscritic := 'Historico nao permitido para efetuar o estorno. Codigo: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).cdhistor);
          RAISE vr_exc_saida;
          
        END IF;
        
        -- Atualiza os dados da Parcela
        BEGIN
          UPDATE crappep
             SET crappep.vlpagpar = nvl(crappep.vlpagpar,0) - nvl(vr_vlpagpar,0)
                ,crappep.vlsdvpar = nvl(crappep.vlsdvpar,0) + nvl(vr_vlpagpar,0) - nvl(vr_vljuratr,0) + nvl(vr_vldescto,0)
                ,crappep.vlsdvsji = nvl(crappep.vlsdvsji,0) + nvl(vr_vlpagpar,0) - nvl(vr_vljuratr,0) + nvl(vr_vldescto,0)
                ,crappep.vldespar = nvl(crappep.vldespar,0) - nvl(vr_vldescto,0)
                ,crappep.vlpagjin = nvl(crappep.vlpagjin,0) - nvl(vr_vljuratr,0)
                ,crappep.inliquid = 0            
                ,crappep.vlpagmra = nvl(crappep.vlpagmra,0) - nvl(vr_vlpagmra,0)
                ,crappep.vlpagmta = nvl(crappep.vlpagmta,0) - nvl(vr_vlpagmta,0)
           WHERE crappep.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crappep.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crappep.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
             AND crappep.nrparepr = vr_tab_lancto_parcelas(idx).nrparepr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crappep. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Atualiza os dados do Emprestimo
        BEGIN
          UPDATE crapepr
             SET crapepr.vlsdeved = crapepr.vlsdeved + vr_vlpagpar,
                 crapepr.qtprepag = crapepr.qtprepag - DECODE(rw_crappep.inliquid,1,1,0),
                 crapepr.qtprecal = crapepr.qtprepag - DECODE(rw_crappep.inliquid,1,1,0),
                 crapepr.dtultest = pr_dtmvtolt,
                 crapepr.dtliquid = NULL
           WHERE crapepr.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crapepr.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crapepr.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crapepr. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        /* Lancamentos de Desconto e Juros de Atraso, sera apenas atualizado a data de estorno */
        IF vr_tab_lancto_parcelas(idx).flgestor = FALSE THEN
          BEGIN
            UPDATE craplem
               SET craplem.dtestorn = pr_dtmvtolt
             WHERE craplem.progress_recid = vr_tab_lancto_parcelas(idx).nrdrecid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar a tabela craplem. ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          -- Pula para o proximo lancamento
          CONTINUE;
        END IF;
        
        -- Sequencia da tabela de pagamentos das parcelas
        vr_cdlancamento := fn_sequence('TBEPR_ESTORNOLANCAMENTO','CDLANCAMENTO',pr_cdcooper                          || ';' || 
                                                                                vr_tab_lancto_parcelas(idx).nrdconta || ';' || 
                                                                                vr_tab_lancto_parcelas(idx).nrctremp || ';' ||
                                                                                vr_cdestorno);

        BEGIN
          INSERT INTO tbepr_estornolancamento
            (cdcooper
            ,nrdconta
            ,nrctremp
            ,cdestorno
            ,cdlancamento
            ,nrparepr
            ,dtvencto
            ,dtpagamento
            ,vllancamento
            ,cdhistor)
          VALUES
            (pr_cdcooper
            ,vr_tab_lancto_parcelas(idx).nrdconta
            ,vr_tab_lancto_parcelas(idx).nrctremp
            ,vr_cdestorno
            ,vr_cdlancamento
            ,vr_tab_lancto_parcelas(idx).nrparepr
            ,vr_tab_lancto_parcelas(idx).dtvencto
            ,vr_tab_lancto_parcelas(idx).dtmvtolt
            ,vr_tab_lancto_parcelas(idx).vllanmto
            ,vr_tab_lancto_parcelas(idx).cdhistor);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na tabela de tbepr_estornolancamento. ' ||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Condicao para estornar o pagamento efetuado no mesmo dia
        IF vr_tab_lancto_parcelas(idx).dtmvtolt = pr_dtmvtolt THEN  
 
          pc_efetua_estor_pgto_no_dia(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nmdatela => pr_nmdatela
                                     ,pr_idorigem => pr_idorigem
                                     ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta
                                     ,pr_idseqttl => pr_idseqttl
                                     ,pr_dtmvtolt => vr_tab_lancto_parcelas(idx).dtmvtolt
                                     ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp
                                     ,pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr
                                     ,pr_des_reto => vr_des_reto
                                     ,pr_tab_erro => vr_tab_erro);
                                     
          IF vr_des_reto = 'NOK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
              -- Buscar o erro encontrado para gravar na vr_des_erro
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              RAISE vr_exc_saida;
            END IF;   
          END IF;
        
        -- Condicao para estornar o pagamento retroativo
        ELSE
          
          pc_efetua_estor_pgto_outro_dia(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nmdatela => pr_nmdatela
                                        ,pr_idorigem => pr_idorigem
                                        ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp
                                        ,pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr
                                        ,pr_cdhisest => vr_cdhisest
                                        ,pr_vllanmto => vr_tab_lancto_parcelas(idx).vllanmto
                                        ,pr_nrdrecid => vr_tab_lancto_parcelas(idx).nrdrecid
                                        ,pr_dtpagemp => vr_tab_lancto_parcelas(idx).dtpagemp
                                        ,pr_txjurepr => vr_tab_lancto_parcelas(idx).txjurepr
                                        ,pr_vlpreemp => vr_tab_lancto_parcelas(idx).vlpreemp
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_tab_erro => vr_tab_erro);
                                     
          IF vr_des_reto = 'NOK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
              -- Buscar o erro encontrado para gravar na vr_des_erro
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              RAISE vr_exc_saida;
            END IF;
          END IF;
          
          -- Armazena o Valor estornado para fazer um unico lancamento em Conta Corrente
          pc_cria_atualiza_ttlanconta (pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper --> Cooperativa conectada
                                      ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp --> Número do contrato de empréstimo
                                      ,pr_cdhistor => vr_cdhislcm                          --> Codigo Historico
                                      ,pr_dtmvtolt => pr_dtmvtolt                          --> Movimento atual
                                      ,pr_cdoperad => pr_cdoperad                          --> Código do Operador
                                      ,pr_cdpactra => pr_cdagenci                          --> P.A. da transação                                       
                                      ,pr_nrdolote => 600031                               --> Numero do Lote
                                      ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta --> Número da conta
                                      ,pr_vllanmto => vr_tab_lancto_parcelas(idx).vllanmto --> Valor lancamento
                                      ,pr_nrseqava => 0                                    --> Pagamento: Sequencia do avalista
                                      ,pr_tab_lancconta => vr_tab_lancto_cc                --> Tabela Lancamentos Conta
                                      ,pr_des_erro => vr_des_reto                          --> Retorno OK / NOK
                                      ,pr_dscritic => vr_dscritic);                        --> descricao do erro
                                      
          IF vr_des_reto = 'NOK' THEN
            RAISE vr_exc_saida;
          END IF;
          
        END IF; 
        
        -- Busca a data do ultimo pagamento da parcela
        OPEN cr_craplem_max(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                            pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                            pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                            pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr);
        FETCH cr_craplem_max
         INTO vr_dtultpag;
        CLOSE cr_craplem_max;
        
        -- Atualiza a data de pagamento da ultima parcela paga
        BEGIN
          UPDATE crappep
             SET crappep.dtultpag = vr_dtultpag
           WHERE crappep.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crappep.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crappep.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
             AND crappep.nrparepr = vr_tab_lancto_parcelas(idx).nrparepr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crappep. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        
      END LOOP; /* END FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP */
      
      -- Vamos verificar se os valores das parcelas ficaram com saldos negativos
      OPEN cr_crappep_saldo(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_saldo
       INTO vr_flgnegat;
      CLOSE cr_crappep_saldo;                        
      
      IF NVL(vr_flgnegat,0) = 1 THEN
        vr_cdcritic := 968;
        RAISE vr_exc_saida;
      END IF;
   
      -- Busca a data do ultimo pagamento do Emprestimo
      OPEN cr_crappep_max_pagto(pr_cdcooper => pr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_max_pagto
       INTO vr_dtultpag;
      CLOSE cr_crappep_max_pagto;
      
      -- Busca a data do primeiro vencimento da parcela nao pago
      OPEN cr_crappep_min_dtvencto(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp);
      FETCH cr_crappep_min_dtvencto
       INTO vr_dtvencto;
      CLOSE cr_crappep_min_dtvencto;
      
      -- Atualiza os dados do Emprestimo
      BEGIN
        UPDATE crapepr
           SET crapepr.dtultpag = vr_dtultpag
              ,crapepr.dtdpagto = vr_dtvencto
              ,crapepr.inliquid = 0
              ,crapepr.dtliquid = NULL
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar a tabela crapepr. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      --Percorrer os Lancamentos
      vr_index_lanc := vr_tab_lancto_cc.FIRST;
      WHILE vr_index_lanc IS NOT NULL LOOP
        
        -- Vamos verificar se o historico do lancamento possui historico de estorno cadastrado
        OPEN cr_craphis (pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper,
                         pr_cdhistor => vr_tab_lancto_cc(vr_index_lanc).cdhistor);
        FETCH cr_craphis
         INTO vr_cdhisest;
        CLOSE cr_craphis;
        
        IF NVL(vr_cdhisest,0) = 0 THEN
          vr_dscritic := 'Historico nao possui codigo de estorno cadastrado. Historico: ' || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).cdhistor);
          RAISE vr_exc_saida;
        END IF;
        
        --> Verificar se conta nao está em prejuizo
        IF NOT PREJ0003.fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta) THEN 
        
        /* Lanca em C/C e atualiza o lote */
        EMPR0001.pc_cria_lancamento_cc (pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper --> Cooperativa conectada
                                       ,pr_dtmvtolt => vr_tab_lancto_cc(vr_index_lanc).dtmvtolt --> Movimento atual
                                       ,pr_cdagenci => vr_tab_lancto_cc(vr_index_lanc).cdagenci --> Código da agência
                                       ,pr_cdbccxlt => vr_tab_lancto_cc(vr_index_lanc).cdbccxlt --> Número do caixa
                                       ,pr_cdoperad => vr_tab_lancto_cc(vr_index_lanc).cdoperad --> Código do Operador
                                       ,pr_cdpactra => vr_tab_lancto_cc(vr_index_lanc).cdpactra --> P.A. da transação
                                       ,pr_nrdolote => vr_tab_lancto_cc(vr_index_lanc).nrdolote --> Numero do Lote
                                       ,pr_nrdconta => vr_tab_lancto_cc(vr_index_lanc).nrdconta --> Número da conta
                                       ,pr_cdhistor => vr_cdhisest                              --> Codigo historico
                                       ,pr_vllanmto => vr_tab_lancto_cc(vr_index_lanc).vllanmto --> Valor da parcela emprestimo
                                       ,pr_nrparepr => 0                                        --> Número parcelas empréstimo
                                       ,pr_nrctremp => vr_tab_lancto_cc(vr_index_lanc).nrctremp --> Número do contrato de empréstimo
                                       ,pr_nrseqava => vr_tab_lancto_cc(vr_index_lanc).nrseqava --> Pagamento: Sequencia do avalista
                                       ,pr_des_reto => vr_des_reto                              --> Retorno OK / NOK
                                       ,pr_tab_erro => vr_tab_erro);                            --> Tabela com possíves erros  
      
        IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            -- Buscar o erro encontrado para gravar na vr_des_erro
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            RAISE vr_exc_saida;
          END IF;
        END IF;
   ELSE
          --> Caso esteja o credito de estono deve ser direcionado ao bloqueio prejuizo
          PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper, --> Cooperativa conectada
                                      pr_nrdconta =>  vr_tab_lancto_cc(vr_index_lanc).nrdconta, --> Número da conta,
                                      pr_cdoperad =>  vr_tab_lancto_cc(vr_index_lanc).cdoperad, --> Código do Operador,
                                      pr_vlrlanc  => vr_tab_lancto_cc(vr_index_lanc).vllanmto, --> Valor da parcela emprestimo,
                                      pr_dtmvtolt => vr_tab_lancto_cc(vr_index_lanc).dtmvtolt, --> Movimento atual
                                       
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);   
         
        
       IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_saida;
       END IF;
          
   END IF; 
        --Proximo registro
        vr_index_lanc := vr_tab_lancto_cc.NEXT(vr_index_lanc);        
      END LOOP;     
      
      COMMIT;
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Desfaz a Transacao
        ROLLBACK;
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Desfaz a Transacao
        ROLLBACK;        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_estornar_pagamentos: ' || SQLERRM;
    END;  
             
  END pc_tela_estornar_pagamentos;

  PROCEDURE pc_tela_consultar_estornos(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
              						 		 			  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
 				    	          	 		 			  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
						    				         			,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
          			    									,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					              							,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										              		,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN                                   
    /* .............................................................................

     Programa: pc_tela_consultar_estornos
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Setembro/15.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar os estornos

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor dos estornos
      CURSOR cr_tbepr_estorno(pr_cdcooper IN tbepr_estorno.cdcooper%TYPE,
                              pr_nrdconta IN tbepr_estorno.nrdconta%TYPE,
                              pr_nrctremp IN tbepr_estorno.nrctremp%TYPE) IS
			  SELECT cdestorno,
               cdoperad,
               dtestorno,
               hrestorno
				  FROM tbepr_estorno
				 WHERE tbepr_estorno.cdcooper = pr_cdcooper
           AND tbepr_estorno.nrdconta = pr_nrdconta
           AND tbepr_estorno.nrctremp = pr_nrctremp;
           
      -- Cursor do Operador
      CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE,
                        pr_cdoperad crapope.cdoperad%TYPE) IS
        SELECT crapope.nmoperad
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
			vr_nmoperad crapope.nmoperad%TYPE;
           
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_contador      PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
          
    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);  

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      
      FOR rw_tbepr_estorno IN cr_tbepr_estorno(pr_cdcooper => vr_cdcooper,
                                               pr_nrdconta => pr_nrdconta,
                                               pr_nrctremp => pr_nrctremp) LOOP
        -- Busca o nome do Operador                                       
        OPEN cr_crapope(vr_cdcooper, rw_tbepr_estorno.cdoperad);
        FETCH cr_crapope INTO vr_nmoperad;        
        CLOSE cr_crapope;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdestorno', pr_tag_cont => rw_tbepr_estorno.cdestorno, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_tbepr_estorno.cdoperad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => vr_nmoperad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtestorno', pr_tag_cont => TO_CHAR(rw_tbepr_estorno.dtestorno,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'hrestorno', pr_tag_cont => GENE0002.fn_calc_hora(rw_tbepr_estorno.hrestorno), pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;

      END LOOP; /* END FOR rw_tbepr_estorno */
      
      IF vr_contador <= 0 THEN
        vr_dscritic := 'Nao existe estorno para a conta informada.';
        RAISE vr_exc_saida;        
      
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_consultar_estornos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;  
  
  END pc_tela_consultar_estornos;
  
  PROCEDURE pc_tela_consultar_detalhe_est(pr_nrdconta  IN crapepr.nrdconta%TYPE        --> Numero da Conta
                                         ,pr_nrctremp  IN crapepr.nrctremp%TYPE        --> Numero do Contrato
                                         ,pr_cdestorno IN tbepr_estorno.cdestorno%TYPE --> Codigo do Estorno
               						 			 			   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
	  			    	          	 			 			 ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
		  				    				         			 ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
            			    									 ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
				  	              							 ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
					  					              		 ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo
  BEGIN                                   
    /* .............................................................................

     Programa: pc_tela_consultar_detalhe_est
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Setembro/15.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar o detalhe do estorno

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor dos estornos
      CURSOR cr_tbepr_estorno(pr_cdcooper  IN tbepr_estorno.cdcooper%TYPE,
                              pr_nrdconta  IN tbepr_estorno.nrdconta%TYPE,
                              pr_nrctremp  IN tbepr_estorno.nrctremp%TYPE,
                              pr_cdestorno IN tbepr_estorno.cdestorno%TYPE) IS
			  SELECT cdestorno,
               cdoperad,
               dsjustificativa,
               dtestorno,
               hrestorno
				  FROM tbepr_estorno
				 WHERE tbepr_estorno.cdcooper  = pr_cdcooper
           AND tbepr_estorno.nrdconta  = pr_nrdconta
           AND tbepr_estorno.nrctremp  = pr_nrctremp
           AND tbepr_estorno.cdestorno = pr_cdestorno;
      rw_tbepr_estorno cr_tbepr_estorno%ROWTYPE;
      
      CURSOR cr_tbepr_estornolancamento(pr_cdcooper  IN tbepr_estorno.cdcooper%TYPE,
                                        pr_nrdconta  IN tbepr_estorno.nrdconta%TYPE,
                                        pr_nrctremp  IN tbepr_estorno.nrctremp%TYPE,
                                        pr_cdestorno IN tbepr_estorno.cdestorno%TYPE) IS
			  SELECT tbepr_estornolancamento.nrparepr,
               tbepr_estornolancamento.dtvencto,
               tbepr_estornolancamento.dtpagamento,
               tbepr_estornolancamento.cdhistor,
               craphis.dshistor,
               tbepr_estornolancamento.vllancamento
				  FROM tbepr_estornolancamento
          JOIN craphis
            ON craphis.cdcooper = tbepr_estornolancamento.cdcooper
           AND craphis.cdhistor = tbepr_estornolancamento.cdhistor
				 WHERE tbepr_estornolancamento.cdcooper  = pr_cdcooper
           AND tbepr_estornolancamento.nrdconta  = pr_nrdconta
           AND tbepr_estornolancamento.nrctremp  = pr_nrctremp
           AND tbepr_estornolancamento.cdestorno = pr_cdestorno;
           
      -- Cursor do Operador
      CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE,
                        pr_cdoperad crapope.cdoperad%TYPE) IS
        SELECT crapope.nmoperad
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
			vr_nmoperad crapope.nmoperad%TYPE;
           
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);      
      vr_xml_temp        VARCHAR2(32726) := '';
      vr_clob            CLOB;
          
    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      -- Busca os dados do Estorno
      OPEN cr_tbepr_estorno (pr_cdcooper  => vr_cdcooper
                            ,pr_nrdconta  => pr_nrdconta
                            ,pr_nrctremp  => pr_nrctremp
                            ,pr_cdestorno => pr_cdestorno);
      FETCH cr_tbepr_estorno INTO rw_tbepr_estorno;
      -- Verifica se a retornou registro
      IF cr_tbepr_estorno%NOTFOUND THEN
        CLOSE cr_tbepr_estorno;
        vr_dscritic := 'Estorno nao cadastrado. Codigo: ' || TO_CHAR(pr_cdestorno);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_tbepr_estorno;
      END IF;                              

      -- Busca o nome do Operador                                       
      OPEN cr_crapope(vr_cdcooper, rw_tbepr_estorno.cdoperad);
      FETCH cr_crapope INTO vr_nmoperad;        
      CLOSE cr_crapope;
        
      -- Monta documento XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>
                                                      <Estorno>
                                                        <cdestorno>'||rw_tbepr_estorno.cdestorno||'</cdestorno>
                                                        <cdoperad>'||rw_tbepr_estorno.cdoperad||'</cdoperad>
                                                        <nmoperad>'||vr_nmoperad||'</nmoperad>
                                                        <dtestorno>'||TO_CHAR(rw_tbepr_estorno.dtestorno,'DD/MM/YYYY')||'</dtestorno>
                                                        <hrestorno>'||GENE0002.fn_calc_hora(rw_tbepr_estorno.hrestorno)||'</hrestorno>
                                                        <dsjustificativa>'||rw_tbepr_estorno.dsjustificativa||'</dsjustificativa>                                                        
                                                      </Estorno>
                                                      <Detalhes>');
      
      -- Percorre todos os lancamentos que foram estornados                       
      FOR rw_tbepr_estornolancamento IN cr_tbepr_estornolancamento(pr_cdcooper  => vr_cdcooper,
                                                                   pr_nrdconta  => pr_nrdconta,
                                                                   pr_nrctremp  => pr_nrctremp,
                                                                   pr_cdestorno => pr_cdestorno) LOOP

        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<Inf>
                                                        <nrparepr>'||rw_tbepr_estornolancamento.nrparepr||'</nrparepr>
                                                        <dtvencto>'||TO_CHAR(rw_tbepr_estornolancamento.dtvencto,'DD/MM/YYYY')||'</dtvencto>
                                                        <dtpagamento>'||TO_CHAR(rw_tbepr_estornolancamento.dtpagamento,'DD/MM/YYYY')||'</dtpagamento>
                                                        <cdhistor>'||rw_tbepr_estornolancamento.cdhistor||'</cdhistor>
                                                        <dshistor>'||rw_tbepr_estornolancamento.dshistor||'</dshistor>
                                                        <vllanmto>'||rw_tbepr_estornolancamento.vllancamento||'</vllanmto>
                                                      </Inf>');

      END LOOP; /* END FOR rw_tbepr_estornolancamento */
      
      -- Cria a Tag com os Totais
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '  </Detalhes>'||
                                                   '</Dados>'
                             ,pr_fecha_xml      => TRUE);
    
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_consultar_detalhe_est: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;  
  
  END pc_tela_consultar_detalhe_est;

  PROCEDURE pc_tela_imprimir_relatorio(pr_nrdconta IN crapepr.nrdconta%TYPE        --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE        --> Numero do Contrato
                                      ,pr_dtmvtolt IN VARCHAR2                     --> Data de Movimento
                                      ,pr_dtiniest IN VARCHAR2                     --> Data Inicio do Estorno
                                      ,pr_dtfinest IN VARCHAR2                     --> Data Fim do Estorno
                                      ,pr_cdagenci IN tbepr_estorno.cdagenci%TYPE  --> Agencia
                						 		 		  ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
 	  			    	          	 		 		  ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
		  				    				        	  ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
            			    							  ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
				  	              					  ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
					  					                ,pr_des_erro OUT VARCHAR2) IS                --> Erros do processo                                       
  BEGIN
    /* .............................................................................

     Programa: pc_tela_imprimir_relatorio
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Setembro/15.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela do relatorio do Estorno

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE

      -- Cursor dos estornos
      CURSOR cr_estorno(pr_cdcooper IN tbepr_estorno.cdcooper%TYPE,
                        pr_nrdconta IN tbepr_estorno.nrdconta%TYPE,
                        pr_nrctremp IN tbepr_estorno.nrctremp%TYPE,
                        pr_dtiniest IN tbepr_estorno.dtestorno%TYPE,
                        pr_dtfinest IN tbepr_estorno.dtestorno%TYPE,
                        pr_cdagenci IN tbepr_estorno.cdagenci%TYPE) IS
		    SELECT est.nrdconta,
               est.nrctremp,
               est.cdagenci,
               est.cdestorno,
               est.cdoperad,
               est.dsjustificativa,
               est.dtestorno,                              
               lcto.nrparepr,
               lcto.dtpagamento,
               lcto.cdhistor,
               lcto.vllancamento,
               COUNT(*) over (PARTITION BY lcto.cdcooper, lcto.nrdconta, lcto.nrctremp, lcto.cdestorno, lcto.nrparepr, lcto.dtpagamento) totreg,
               row_number() over (PARTITION BY lcto.cdcooper, lcto.nrdconta, lcto.nrctremp, lcto.cdestorno, lcto.nrparepr, lcto.dtpagamento
                                      ORDER BY lcto.cdcooper, lcto.nrdconta, lcto.nrctremp, lcto.cdestorno, lcto.nrparepr, lcto.dtpagamento) nrseq
          FROM tbepr_estorno est
          JOIN tbepr_estornolancamento lcto
            ON lcto.cdcooper  = est.cdcooper
           AND lcto.nrdconta  = est.nrdconta
           AND lcto.nrctremp  = est.nrctremp
           AND lcto.cdestorno = est.cdestorno
         WHERE est.cdcooper = pr_cdcooper 
           AND est.dtestorno BETWEEN pr_dtiniest AND pr_dtfinest
           AND (nvl(pr_nrdconta,0) = 0 OR est.nrdconta = pr_nrdconta)
           AND (nvl(pr_nrctremp,0) = 0 OR est.nrctremp = pr_nrctremp)
           AND (nvl(pr_cdagenci,0) = 0 OR est.cdagenci = pr_cdagenci)
      ORDER BY lcto.cdcooper, 
               lcto.nrdconta, 
               lcto.nrctremp,
               lcto.cdestorno, 
               lcto.nrparepr, 
               lcto.dtpagamento;
               
      -- Cursor para encontrar o nome do PA
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT nmextage
        FROM crapage
       WHERE cdcooper = pr_cdcooper 
         AND cdagenci = pr_cdagenci;     
      vr_nmextage crapage.nmextage%TYPE;
      
      -- Cursor do Operador
      CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE,
                        pr_cdoperad crapope.cdoperad%TYPE) IS
        SELECT crapope.nmoperad
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
			vr_nmoperad crapope.nmoperad%TYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_des_reto      VARCHAR2(3);
      vr_typ_saida     VARCHAR2(3);
      
      vr_tab_erro      GENE0001.typ_tab_erro;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);      
      vr_xml_temp        VARCHAR2(32726) := '';
      vr_xml             CLOB;
      vr_nom_direto      VARCHAR2(500);
      vr_nmarqimp        VARCHAR2(100);
      vr_dtmvtolt        DATE;
      vr_dtiniest        DATE;
      vr_dtfinest        DATE;
      vr_vlpagpar        crappep.vlpagpar%TYPE := 0;
      vr_vlpagmta        crappep.vlpagmta%TYPE := 0;
      vr_vlpagmra        crappep.vlpagmra%TYPE := 0;
      vr_bltemreg        BOOLEAN := FALSE;
          
    BEGIN
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/YYYY');
      vr_dtiniest := TO_DATE(pr_dtiniest,'DD/MM/YYYY');
      vr_dtfinest := TO_DATE(pr_dtfinest,'DD/MM/YYYY');

      -- Valida se a data Inicial e Final Foram preenchidas
      IF vr_dtiniest IS NULL THEN
        vr_dscritic := 'O campo data inicial nao foi preenchida';
        RAISE vr_exc_saida;
      END IF;
      
      IF vr_dtfinest IS NULL THEN
        vr_dscritic := 'O campo data final nao foi preenchida';
        RAISE vr_exc_saida;
      END IF;
      
      -- Validar se a agencia informada existe na cooperativa
      IF NVL(pr_cdagenci,0) <> 0 THEN
        -- Busca a cidade do PA do associado
        OPEN cr_crapage(pr_cdcooper => vr_cdcooper
                       ,pr_cdagenci => pr_cdagenci);                             
        FETCH cr_crapage INTO vr_nmextage;
        IF cr_crapage%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapage;
          vr_cdcritic:= 962;
          RAISE vr_exc_saida;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapage;                
        END IF;
        
      END IF; -- END IF NVL(pr_cdagenci,0) <> 0 THEN
      
      -- Monta documento XML
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Relatorio>
                                                      <Filtros>
                                                        <data_inicial>'||TO_CHAR(vr_dtiniest,'DD/MM/YYYY')||'</data_inicial>
                                                        <data_final>'||TO_CHAR(vr_dtfinest,'DD/MM/YYYY')||'</data_final>
                                                      </Filtros>');

      -- Percorre todos os lancamentos que foram estornados
      FOR rw_estorno IN cr_estorno(pr_cdcooper => vr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp,
                                   pr_dtiniest => vr_dtiniest,
                                   pr_dtfinest => vr_dtfinest,
                                   pr_cdagenci => pr_cdagenci) LOOP
        -- Possui registros
        vr_bltemreg := TRUE;

        -- Credito de Pagamento
        IF rw_estorno.cdhistor IN (1039,1044,1045,1057) THEN
          vr_vlpagpar := NVL(vr_vlpagpar,0) + NVL(rw_estorno.vllancamento,0);
        
        -- Juros de Mora
        ELSIF rw_estorno.cdhistor IN (1619,1077,1620,1078) THEN
          vr_vlpagmra := NVL(vr_vlpagmra,0) + NVL(rw_estorno.vllancamento,0);
          
        -- Multa
        ELSIF rw_estorno.cdhistor IN (1540,1047,1618,1076) THEN
          vr_vlpagmta := NVL(vr_vlpagmta,0) + NVL(rw_estorno.vllancamento,0);          
          
        END IF;
        
        -- Somente vamos criar o XML quando terminar o agrupamento por parcela
        IF rw_estorno.nrseq = rw_estorno.totreg THEN
          
          -- Busca o nome da Agencia
          OPEN cr_crapage(vr_cdcooper, rw_estorno.cdagenci);
          FETCH cr_crapage INTO vr_nmextage;
          CLOSE cr_crapage;       
          
          -- Busca o nome do Operador                                       
          OPEN cr_crapope(vr_cdcooper, rw_estorno.cdoperad);
          FETCH cr_crapope INTO vr_nmoperad;        
          CLOSE cr_crapope;
        
          gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<Dados>
                                                          <nrdconta>'||rw_estorno.nrdconta||'</nrdconta>
                                                          <nrctremp>'||rw_estorno.nrctremp||'</nrctremp>
                                                          <cdestorno>'||rw_estorno.cdestorno||'</cdestorno>
                                                          <cdoperad>'||rw_estorno.cdoperad||'</cdoperad>
                                                          <nmoperad>'||vr_nmoperad||'</nmoperad>
                                                          <dtestorno>'||TO_CHAR(rw_estorno.dtestorno,'DD/MM/YYYY')||'</dtestorno>
                                                          <cdagenci>'||rw_estorno.cdagenci||'</cdagenci>
                                                          <nmextage>'||vr_nmextage||'</nmextage>
                                                          <dsjustificativa>'||rw_estorno.dsjustificativa||'</dsjustificativa>                                                          
                                                          <nrparepr>'||rw_estorno.nrparepr||'</nrparepr>
                                                          <dtpagamento>'||TO_CHAR(rw_estorno.dtpagamento,'DD/MM/YYYY')||'</dtpagamento>
                                                          <vlpagpar>'||TO_CHAR(vr_vlpagpar,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagpar>
                                                          <vlpagmta>'||TO_CHAR(vr_vlpagmta,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagmta>
                                                          <vlpagmra>'||TO_CHAR(vr_vlpagmra,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagmra>
                                                        </Dados>');
                                                        
          vr_vlpagpar := 0;
          vr_vlpagmta := 0;
          vr_vlpagmra := 0;
                                                
        END IF; -- END IF rw_estorno.nrseq = rw_estorno.totreg THEN
          
      END LOOP; -- END FOR rw_estorno

      -- Caso nao possua registros
      IF NOT vr_bltemreg THEN
        vr_dscritic := 'Nenhum registro encontrado para os filtros informados';
        RAISE vr_exc_saida;
      END IF;

      -- Cria a Tag com os Totais
      gene0002.pc_escreve_xml(pr_xml            => vr_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Relatorio>'
                             ,pr_fecha_xml      => TRUE);
    
      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      
      -- Definir nome do relatorio
      vr_nmarqimp := 'crrl710_' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || '.pdf';
      
      -- Solicitar geração do relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper --> Cooperativa conectada
                                 ,pr_cdprogra  => 'ESTORN' --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/Relatorio/Dados' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl710.jasper' --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo final com o path
                                 ,pr_cdrelato  => 710
                                 ,pr_qtcoluna  => 132 --> 80 colunas
                                 ,pr_flg_gerar => 'S' --> Geraçao na hora
                                 ,pr_flg_impri => 'N' --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''  --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1   --> Número de cópias
                                 ,pr_sqcabrel  => 1   --> Qual a seq do cabrel
                                 ,pr_des_erro  => vr_dscritic); --> Saída com erro
      -- Tratar erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Enviar relatorio para intranet
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper --> Cooperativa conectada
                                  ,pr_cdagenci => vr_cdagenci --> Codigo da agencia para erros
                                  ,pr_nrdcaixa => vr_nrdcaixa --> Codigo do caixa para erros
                                  ,pr_nmarqpdf => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo PDF  a ser gerado
                                  ,pr_des_reto => vr_des_reto --> Saída com erro
                                  ,pr_tab_erro => vr_tab_erro); --> tabela de erros
      
      -- caso apresente erro na operação
      IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;          
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Remover relatorio da pasta rl apos gerar
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm ' || vr_nom_direto || '/' ||vr_nmarqimp
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);
      
      -- Criar XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||vr_nmarqimp || '</nmarqpdf>');
      
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_imprimir_relatorio: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;  
  
  END pc_tela_imprimir_relatorio;
                                        
  PROCEDURE pc_busca_lancamentos_pagto(pr_cdcooper            IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                      ,pr_cdagenci            IN crapass.cdagenci%TYPE --> Código da agência
                                      ,pr_nrdcaixa            IN craperr.nrdcaixa%TYPE --> Número do caixa
                                      ,pr_cdoperad            IN crapdev.cdoperad%TYPE --> Código do Operador
                                      ,pr_nmdatela            IN VARCHAR2 --> Nome da tela
                                      ,pr_idorigem            IN INTEGER --> Id do módulo de sistema
                                      ,pr_nrdconta            IN crapepr.nrdconta%TYPE --> Número da conta
                                      ,pr_idseqttl            IN crapttl.idseqttl%TYPE --> Seq titula
                                      ,pr_nrctremp            IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                      ,pr_des_reto            OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro            OUT gene0001.typ_tab_erro --> Tabela com possíves erros
                                      ,pr_tab_lancto_parcelas OUT EMPR0008.typ_tab_lancto_parcelas) IS --> Tabela com registros de estorno
	BEGIN											 
	  /* .............................................................................

      Programa: pc_busca_lancamentos_pagto
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : James Prust Junior
      Data    : Setembro/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente ao Estorno de pagamento de parcelas

      Observacao: -----

      Alteracoes: 
    ..............................................................................*/
		DECLARE
		
		  -- Cursor do Emprestimo
		  CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE,
                        pr_nrdconta IN crapepr.nrdconta%TYPE,
                        pr_nrctremp IN crapepr.nrctremp%TYPE) IS
			  SELECT crapepr.inprejuz,
               crapepr.dtultpag,
               crapepr.dtliquid,
               crapepr.dtultest,
               crapepr.tpemprst,
               crapepr.flgpagto,
               crapepr.cdlcremp,
               crapepr.inliquid,
               crapepr.cdfinemp,
               crawepr.dtvencto,
               crawepr.idquapro,
               crawepr.dtlibera
				  FROM crapepr
          
          JOIN crawepr ON crawepr.cdcooper = crapepr.cdcooper
                      AND crawepr.nrdconta = crapepr.nrdconta
                      AND crawepr.nrctremp = crapepr.nrctremp
          
				 WHERE crapepr.cdcooper = pr_cdcooper 
				 	 AND crapepr.nrdconta = pr_nrdconta
					 AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      -- Cursor da Linha de Credito
		  CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE,
                        pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
			  SELECT tpctrato
				  FROM craplcr
				 WHERE craplcr.cdcooper = pr_cdcooper 
				 	 AND craplcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      
      -- Cursor da Finalidade
		  CURSOR cr_crapfin(pr_cdcooper IN crapfin.cdcooper%TYPE,
                        pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
			  SELECT tpfinali
				  FROM crapfin
				 WHERE crapfin.cdcooper = pr_cdcooper 
				 	 AND crapfin.cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;
      
      -- Cursor da Parcela do Emprestimo
		  CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE,
                        pr_nrdconta IN crappep.nrdconta%TYPE,
                        pr_nrctremp IN crappep.nrctremp%TYPE,
                        pr_nrparepr IN crappep.nrparepr%TYPE) IS
			  SELECT dtvencto
				  FROM crappep
				 WHERE crappep.cdcooper = pr_cdcooper 
				 	 AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Cursor para buscar os bens do emprestimo
      CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE,
                        pr_nrdconta IN crapbpr.nrdconta%TYPE,
                        pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
        SELECT cdsitgrv,
               tpdbaixa
          FROM crapbpr
         WHERE crapbpr.cdcooper = pr_cdcooper
           AND crapbpr.nrdconta = pr_nrdconta
           AND crapbpr.nrctrpro = pr_nrctremp
           AND crapbpr.tpctrpro in (90,99);
               
      -- Cursor dos Lancamentos do Emprestimo
      CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE,
                        pr_nrdconta IN craplem.nrdconta%TYPE,
                        pr_nrctremp IN craplem.nrctremp%TYPE,     
                        pr_dtmvtolt IN craplem.dtmvtolt%TYPE,
                        pr_dtultest IN crapepr.dtultest%TYPE) IS
        SELECT craplem.nrdconta,
               craplem.nrctremp,
               craplem.nrparepr,
               craplem.dtmvtolt,
               craplem.cdhistor,
               craplem.vllanmto,
               craplem.dtpagemp,
               craplem.txjurepr,
               craplem.vlpreemp,
               craphis.cdhisest,
               craplem.progress_recid        
          FROM craplem

          JOIN craphis  
            ON craphis.cdcooper = craplem.cdcooper
           AND craphis.cdhistor = craplem.cdhistor
           
         WHERE craplem.cdcooper = pr_cdcooper
           AND craplem.nrdconta = pr_nrdconta
           AND craplem.nrctremp = pr_nrctremp
           AND craplem.dtmvtolt = pr_dtmvtolt                      
           AND (nvl(pr_dtultest,SYSDATE) = SYSDATE OR craplem.dtmvtolt >= pr_dtultest)
           AND craplem.nrparepr > 0    
           AND craphis.cdhisest > 0
      ORDER BY craplem.nrparepr,
               craplem.dtmvtolt;
       		
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);


      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      
      vr_nrdiaest      PLS_INTEGER;
      vr_ind_estorno   VARCHAR(20);
      vr_dtliquid      DATE;
      vr_dstextab      craptab.dstextab%TYPE;
      vr_dtvenmes      DATE;

		BEGIN
		  pr_tab_lancto_parcelas.DELETE;	
    
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat
        INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
                                      
      -- Busca os dados do emprestimo
      OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      -- Verifica se a retornou registro
      IF cr_crapepr%NOTFOUND THEN
        CLOSE cr_crapepr;
        vr_cdcritic := 356;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_crapepr;
      END IF;
      
      -- Somente o produto PP ira ter estorno
      IF rw_crapepr.tpemprst <> 1 THEN
        vr_cdcritic := 946;
        RAISE vr_exc_saida;
      END IF;
      
      -- Contrato de Emprestimo nao pode estar em Prejuizo
      IF rw_crapepr.inprejuz <> 0 THEN
        vr_dscritic := 'Nao e permitido efetuar o estorno de um contrato em prejuizo';
        RAISE vr_exc_saida;
      END IF;
      
      -- Contrato de emprestimo nao pode debitar em Folha
      IF rw_crapepr.flgpagto <> 0 THEN
        vr_dscritic := 'Nao e permitido efetuar o estorno de um contrato em folha';
        RAISE vr_exc_saida;
      END IF;
      
      -- O ultimo pagamento precisa estar dentro do mês
      IF NOT(rw_crapepr.dtultpag >= rw_crapdat.dtinimes AND rw_crapepr.dtultpag <= rw_crapdat.dtultdia) THEN
        vr_dscritic := 'A data do ultimo pagamento deve estar dentro do mes';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca os dados da linha de credito
      OPEN cr_craplcr (pr_cdcooper => pr_cdcooper
                      ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Verifica se a retornou registro
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        vr_dscritic := 'Linha de credito nao cadastrada. Codigo: ' || TO_CHAR(rw_crapepr.cdlcremp);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_craplcr;
      END IF;
      
      -- Emprestimo/Financiamento, Alienacao de Veiculo, Hipoteca de Imoveis, Aplicacao
      IF rw_craplcr.tpctrato NOT IN (1,2,3,4) THEN
        vr_dscritic := 'Tipo de contrato da linha de credito nao permitida';
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca os dados da Finalidade
      OPEN cr_crapfin (pr_cdcooper => pr_cdcooper
                      ,pr_cdfinemp => rw_crapepr.cdfinemp);
      FETCH cr_crapfin INTO rw_crapfin;
      -- Verifica se a retornou registro
      IF cr_crapfin%NOTFOUND THEN
        CLOSE cr_crapfin;
        vr_dscritic := 'Finalidade nao cadastrada. Codigo: ' || TO_CHAR(rw_crapepr.cdfinemp);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_crapfin;
      END IF;
      
      -- Emprestimo/Financiamento nao pode ser do tipo Portabilidade
      /* 31/01/2018 #826621 - Conforme posicionamento da área, os contratos de portabilidade também
         poderão ser estornados. Regra retirada do sistema.
      IF rw_crapfin.tpfinali = 2 THEN
        vr_dscritic := 'Nao e permitido efetuar o estorno, contrato de portabilidade';
        RAISE vr_exc_saida;
      END IF; */
     
      -- Caso o contrato de emprestimo estiver liquidado, precisamos fazer algumas validacoes  
      IF rw_crapepr.inliquid = 1 THEN
        
        -- A data de liquidacao precisa estar dentro do mês
        IF NOT(rw_crapepr.dtliquid >= rw_crapdat.dtinimes AND rw_crapepr.dtliquid <= rw_crapdat.dtultdia) THEN
          vr_dscritic := 'Nao e permitido efetuar o estorno, pois a liquidacao esta fora do mes';
          RAISE vr_exc_saida;
        END IF;
        
        -- Alienacao de Veiculo  
        IF rw_craplcr.tpctrato = 2 THEN
        
          -- Vamos verificar se os bens estao alienados ao contrato
          FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_nrctremp => pr_nrctremp) LOOP            
             
            IF UPPER(rw_crapbpr.tpdbaixa) = 'M' THEN
              vr_dscritic := 'Nao e possivel efetuar o estorno, contrato liquidado.';
              RAISE vr_exc_saida;
            END IF;
            
            IF rw_crapbpr.cdsitgrv NOT IN (0,2) THEN
              vr_dscritic := 'Nao e possivel efetuar o estorno, Gravames em processamento, verifique a tela Gravam.';
              RAISE vr_exc_saida;
            END IF; /* END IF rw_crapbpr.cdsitgrv NOT IN (0,2) THEN */
            
          END LOOP; /* END FOR rw_crapbpr */
          
        -- Alienacao/Hipoteca de Imoveis
        ELSIF rw_craplcr.tpctrato = 3 THEN
          
          vr_nrdiaest := 0;
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'USUARI'
                                                   ,pr_cdempres => 11
                                                   ,pr_cdacesso => 'PAREMPREST'
                                                   ,pr_tpregist => 1);
          --Se nao encontrou parametro
          IF TRIM(vr_dstextab) IS NULL THEN
            vr_cdcritic := 55;
            RAISE vr_exc_saida;
          ELSE
            vr_nrdiaest := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 9, 3)),0);

          END IF;
          
          -- Retorna a data de liquidacao somado com os dias configurados
          vr_dtliquid := fn_retorna_data_util(pr_cdcooper => pr_cdcooper,
                                              pr_dtiniper => rw_crapepr.dtliquid,
                                              pr_qtdialib => vr_nrdiaest);
          
          -- A data de liquidacao nao pode ser maior que os dias configurados
          IF NOT(vr_dtliquid >= rw_crapdat.dtmvtolt) THEN
            vr_dscritic := 'Nao e possivel efetuar o estorno, contrato liquidado.';
            RAISE vr_exc_saida;
          END IF;
          
        END IF; /* END IF rw_crapepr.tpctrato = 3 THEN */
        
      END IF;
      
      /* Calcular o vencimento dentro do mês */
      vr_dtvenmes := TO_DATE(TO_CHAR(rw_crapepr.dtvencto, 'DD') || 
                           TO_CHAR(rw_crapdat.dtmvtolt, 'MMYYYY'), 'DDMMYYYY'); 
      /* Regra para não permitir estornar pagamentos antes do vencimento no mês 
      que no dia do vencimento não ocorreu nenhum pagamento, irá gerar residuo
      no contrato será avaliada uma solução definitiva posteriormente */  
      IF  (rw_crapdat.dtmvtolt > vr_dtvenmes)
      AND (rw_crapepr.dtultpag < vr_dtvenmes) 
      -- garantir que irá permitir estorno dentro da carencia - Rafael Maciel (RKAM)
      AND ( (rw_crapepr.dtvencto < rw_crapdat.dtmvtolt) 
          AND (rw_crapepr.tpemprst = 1)
          AND (rw_crapepr.idquapro = 0)
          AND (rw_crapepr.dtlibera > rw_crapdat.dtmvtolt)
      ) THEN
          vr_dscritic := 'Contrato nao pode ser estornado.';
          RAISE vr_exc_saida;
      END IF; 

      -- Vamos buscar todos os lancamentos que podem ser estornados
      FOR rw_craplem IN cr_craplem(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp,
                                   pr_dtmvtolt => rw_crapepr.dtultpag,
                                   pr_dtultest => rw_crapepr.dtultest) LOOP            
                                   
        -- Busca os dados da parcela
        OPEN cr_crappep (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctremp => pr_nrctremp,
                         pr_nrparepr => rw_craplem.nrparepr);
        FETCH cr_crappep INTO rw_crappep;
        -- Verifica se a retornou registro
        IF cr_crappep%NOTFOUND THEN
          CLOSE cr_crappep;
          vr_dscritic := 'Parcela nao encontrada'               ||
                         '. Conta: '    || TO_CHAR(pr_nrdconta) ||
                         '. Contrato: ' || TO_CHAR(pr_nrctremp) ||
                         '. Parcela: '  || TO_CHAR(rw_craplem.nrparepr);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas Fecha o Cursor
          CLOSE cr_crappep;
        END IF;
        
        
        vr_ind_estorno := pr_tab_lancto_parcelas.COUNT() + 1;
        pr_tab_lancto_parcelas(vr_ind_estorno).cdcooper := pr_cdcooper;
        pr_tab_lancto_parcelas(vr_ind_estorno).nrdconta := pr_nrdconta;
        pr_tab_lancto_parcelas(vr_ind_estorno).nrctremp := pr_nrctremp;
        pr_tab_lancto_parcelas(vr_ind_estorno).nrparepr := rw_craplem.nrparepr;
        pr_tab_lancto_parcelas(vr_ind_estorno).dtmvtolt := rw_craplem.dtmvtolt;
        pr_tab_lancto_parcelas(vr_ind_estorno).cdhistor := rw_craplem.cdhistor;
        pr_tab_lancto_parcelas(vr_ind_estorno).dtvencto := rw_crappep.dtvencto;
        pr_tab_lancto_parcelas(vr_ind_estorno).vllanmto := rw_craplem.vllanmto;
        pr_tab_lancto_parcelas(vr_ind_estorno).nrdrecid := rw_craplem.progress_recid;
        pr_tab_lancto_parcelas(vr_ind_estorno).flgestor := TRUE;        
        pr_tab_lancto_parcelas(vr_ind_estorno).dtpagemp := rw_craplem.dtpagemp;
        pr_tab_lancto_parcelas(vr_ind_estorno).txjurepr := NVL(rw_craplem.txjurepr,0);
        pr_tab_lancto_parcelas(vr_ind_estorno).vlpreemp := NVL(rw_craplem.vlpreemp,0);
        
        /* Regra definida pelo Oscar, caso o Historico for igual ao historico de Estorno
           nao sera realizado o estorno do lancamento                                    */
        IF rw_craplem.cdhistor = rw_craplem.cdhisest THEN
          pr_tab_lancto_parcelas(vr_ind_estorno).flgestor := FALSE;
        END IF;
        
      END LOOP; -- END FOR rw_craplem
      
      pr_des_reto := 'OK';

		EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;
       
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';                    	
			WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na EMPR0008.pc_busca_lancamentos_pagto ' || sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

		END;
    
  END pc_busca_lancamentos_pagto;
  
  FUNCTION fn_retorna_data_util(pr_cdcooper IN crapcop.cdcooper%TYPE        --> Cooperativa
                               ,pr_dtiniper IN DATE                        --> Data de Inicio do Periodo
                               ,pr_qtdialib IN PLS_INTEGER) RETURN DATE IS --> Quantidade de dias para acrescentar
	BEGIN											 
	  /* .............................................................................

      Programa: pc_retorna_data_util
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : James Prust Junior
      Data    : Setembro/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para calcular proxima data util a partir do numero de dias uteis informado

      Observacao: -----

      Alteracoes: 
    ..............................................................................*/

		DECLARE
      -- Buscar informacoes dos feriados
      CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE,
                        pr_dtferiad IN crapfer.dtferiad%TYPE) IS
        SELECT 1
          FROM crapfer
         WHERE cdcooper = pr_cdcooper
           AND dtferiad = pr_dtferiad;

      vr_flgferia NUMBER;
              
      vr_nrdialib PLS_INTEGER := 0;
      vr_datadper DATE;    
    BEGIN
      vr_datadper := pr_dtiniper;      
      
      WHILE vr_nrdialib < pr_qtdialib LOOP
        
        vr_datadper := vr_datadper + 1;
        -- Condicao para verificar se eh Final de Semana
        IF (TO_CHAR(vr_datadper,'d') NOT IN(1,7)) THEN
          -- Condicao para verificar se eh Feriado
          OPEN cr_crapfer(pr_cdcooper => pr_cdcooper,
                          pr_dtferiad => vr_datadper);
          FETCH cr_crapfer INTO vr_flgferia;
          -- Se nao tiver cr_crapfer
          IF cr_crapfer%NOTFOUND THEN
            vr_nrdialib := vr_nrdialib + 1;
          END IF;

          CLOSE cr_crapfer;
          
        END IF;        
      
      END LOOP;


      RETURN vr_datadper;
                            
		END;

  END fn_retorna_data_util;
                                                            	
END EMPR0008;
/
