CREATE OR REPLACE PACKAGE CECRED.TELA_ESTORN AS
/*..............................................................................

   Programa: TELA_ESTORN
   Sistema : Cred
   Sigla   : CRED
   Autor   : Cassia de Oliveira (GFT)
   Data    : 17/09/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : 

   Alteracoes:
..............................................................................*/
  -- Cursor de lançamentos por título
  CURSOR cr_craptlb(pr_cdcooper crapbdt.cdcooper%TYPE,
                   pr_nrborder crapbdt.nrborder%TYPE,
                   pr_dtini DATE,
                   pr_dtfim DATE) IS
   SELECT 
     tlb.cdcooper,
     tlb.nrdconta,
     tlb.nrborder,
     tlb.nrtitulo,
     tlb.dtmvtolt,
     SUM(CASE WHEN tlb.cdhistor <> PREJ0005.vr_cdhistordsct_rec_abono THEN vllanmto ELSE 0 END) AS tolanmto, -- Total sem Abono
     SUM(CASE WHEN tlb.cdhistor  = PREJ0005.vr_cdhistordsct_rec_abono THEN vllanmto ELSE 0 END) AS tovlabono, -- Total do Abono
     tdb.dtvencto
   FROM tbdsct_lancamento_bordero tlb
   LEFT JOIN craptdb tdb 
     ON    tdb.cdcooper = tlb.cdcooper   
       AND tdb.nrdconta = tlb.nrdconta
       AND tdb.nrborder = tlb.nrborder
       AND tdb.nrtitulo = tlb.nrtitulo
   LEFT JOIN crapbdt bdt
     ON    bdt.cdcooper = tdb.cdcooper AND bdt.nrborder = tdb.nrborder
   WHERE tlb.cdcooper = pr_cdcooper 
     AND tlb.nrborder = pr_nrborder 
     AND tlb.cdorigem IN (5, 7) 
     AND tlb.dtmvtolt BETWEEN  pr_dtini AND pr_dtfim
     AND tlb.dtmvtolt >= (SELECT MAX(dtmvtolt) FROM tbdsct_lancamento_bordero WHERE cdcooper = pr_cdcooper AND  nrborder = pr_nrborder AND cdorigem IN (5, 7))
     AND tlb.dtmvtolt >= NVL((SELECT MAX(dtestorn) FROM tbdsct_lancamento_bordero WHERE cdcooper = pr_cdcooper AND nrborder = pr_nrborder AND cdorigem IN (5, 7)),pr_dtini)
     AND tlb.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono      -- ABONO PREJUIZO
                         ,PREJ0005.vr_cdhistordsct_rec_principal  -- PAG.PREJUIZO PRINCIP.
                         ,PREJ0005.vr_cdhistordsct_rec_jur_60     -- PGTO JUROS +60
                         ,PREJ0005.vr_cdhistordsct_rec_jur_atuali -- PAGTO JUROS  PREJUIZO
                         ,PREJ0005.vr_cdhistordsct_rec_mult_atras -- PGTO MULTA ATRASO
                         ,PREJ0005.vr_cdhistordsct_rec_jur_mora   -- PGTO JUROS MORA
     )
     AND tlb.dtestorn IS NULL
     GROUP BY tlb.cdcooper, tlb.nrdconta, tlb.nrborder, tlb.nrtitulo, tlb.dtmvtolt, tdb.dtvencto
     ORDER BY tlb.nrtitulo;
        
  PROCEDURE pc_tela_busca_lancto(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                        ,pr_cdtpprod IN NUMBER                --> 1-Emprestimo PP 2-Desconto de titulo
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);
                                        
  PROCEDURE pc_tela_valida_lancto(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                  ,pr_qtdlacto IN PLS_INTEGER           --> Quantidade de Lancamento
                                  ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
                                  ,pr_cdtpprod IN NUMBER                --> 1-Emprestimo PP 2-Desconto de titulo
               									  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
			      	          				  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
					      				          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
         		  	    						  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					                				,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
									  	            ,pr_des_erro OUT VARCHAR2);
                                  
  PROCEDURE pc_tela_estornar_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                  ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
               									  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
			      	          				  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
					      				          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
         		  	    						  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					                				,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
									  	            ,pr_des_erro OUT VARCHAR2);
                                     
  PROCEDURE pc_tela_imprimir_relatorio_web(pr_nrdconta IN crapbdt.nrdconta%TYPE        --> Numero da Conta
                                          ,pr_nrctremp IN crapbdt.nrborder%TYPE        --> Numero do Contrato
                                          ,pr_dtmvtolt IN VARCHAR2                     --> Data de Movimento
                                          ,pr_dtiniest IN VARCHAR2                     --> Data Inicio do Estorno
                                          ,pr_dtfinest IN VARCHAR2                     --> Data Fim do Estorno
                                          ,pr_cdagenci IN tbdsct_estorno.cdagenci%TYPE --> Agencia
                                          ,pr_cdtpprod IN NUMBER                       --> 1-Emprestimo PP 2-Desconto de titulo
                                          ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);
                               
   PROCEDURE pc_efetua_estorno_prj_web (pr_nrdconta      IN crapass.nrdconta%TYPE --> conta do associado
                                       ,pr_nrborder      IN crapbdt.nrborder%TYPE --> numero do bordero
                                       ,pr_justificativa IN VARCHAR2              --> Justificativa
                                       ,pr_xmllog        IN VARCHAR2              --> xml com informações de log
                                       --------> OUT <--------
                                       ,pr_cdcritic   OUT PLS_INTEGER             --> código da crítica
                                       ,pr_dscritic   OUT VARCHAR2                --> descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY xmltype      --> arquivo de retorno do xml
                                       ,pr_nmdcampo   OUT VARCHAR2                --> nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2                --> erros do processo
                                       );
END TELA_ESTORN;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ESTORN AS
/*..............................................................................

   Programa: TELA_ESTORN
   Sistema : Cred
   Sigla   : CRED
   Autor   : Cassia de Oliveira
   Data    : 17/09/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Roteamento de estorno de emprestimo e desconto de titulo

   Alteracoes:
..............................................................................*/

  -- Variáveis para armazenar as informações em XML
  vr_des_xml         clob;
  vr_texto_completo  varchar2(32600);
  
  -- Rotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml( pr_des_dados in varchar2
                          , pr_fecha_xml in boolean default false
                          ) is
  BEGIN
     gene0002.pc_escreve_xml( vr_des_xml
                            , vr_texto_completo
                            , pr_des_dados
                            , pr_fecha_xml );
  END pc_escreve_xml;
  
  PROCEDURE pc_tela_busca_lancto (pr_nrdconta IN crapepr.nrdconta%TYPE--> Numero da Conta
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato/Bordero
                                        ,pr_cdtpprod IN NUMBER                --> 1-Emprestimo PP 2-Desconto de titulo
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS
    /* .............................................................................

    Programa: pc_tela_busca_lancto_estorno
    Sistema :
    Sigla   : CRED
    Autor   : Cassia de Oliveira
    Data    : 17/09/2018                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Buscar lancamentos passiveis de estorno

    Alteracoes:

    ..............................................................................*/
    
    ---->> TRATAMENTO DE ERROS <<----- 
    vr_exc_erro    EXCEPTION;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
    vr_dscritic varchar2(1000);        --> desc. erro

    BEGIN
      IF pr_cdtpprod = 1 THEN
        EMPR0008.pc_tela_busca_lancto_estorno(pr_nrdconta => pr_nrdconta --> Numero da Conta
                                        ,pr_nrctremp => pr_nrctremp      --> Numero do Contrato
                                        ,pr_xmllog   => pr_xmllog        --> XML com informações de LOG
                                        ,pr_cdcritic => vr_cdcritic      --> Código da crítica
                                        ,pr_dscritic => vr_dscritic      --> Descrição da crítica
                                        ,pr_retxml   => pr_retxml        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo => pr_nmdcampo      --> Nome do campo com erro
                                        ,pr_des_erro => pr_des_erro );
      ELSIF  pr_cdtpprod = 2 THEN
        DSCT0005.pc_tela_busca_lancto_dscto(pr_nrdconta => pr_nrdconta --> Numero da Conta
                                        ,pr_nrborder => pr_nrctremp      --> Numero do Bordero
                                        ,pr_xmllog   => pr_xmllog        --> XML com informações de LOG
                                        ,pr_cdcritic => vr_cdcritic      --> Código da crítica
                                        ,pr_dscritic => vr_dscritic      --> Descrição da crítica
                                        ,pr_retxml   => pr_retxml        --> Arquivo de retorno do XML
                                        ,pr_nmdcampo => pr_nmdcampo      --> Nome do campo com erro
                                        ,pr_des_erro => pr_des_erro );
      END IF;    
      -- Verifica erro das procedures
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro nao tratado na rotina pc_tela_busca_lancto: ' ||SQLERRM;

  END pc_tela_busca_lancto;
  
  PROCEDURE pc_tela_valida_lancto(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                  ,pr_qtdlacto IN PLS_INTEGER           --> Quantidade de Lancamento
                                  ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
                                  ,pr_cdtpprod IN NUMBER                --> 1-Emprestimo PP 2-Desconto de titulo
               									  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
			      	          				  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
					      				          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
         		  	    						  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					                				,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
									  	            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
                                  
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_tela_valida_estorno
        Sistema  : 
        Sigla    : CRED
        Autor    : Cassia de Oliveira (GFT) (GFT)
        Data     : 19/09/2018
        Frequencia: Sempre que for chamado
        Objetivo  : 
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
      vr_dscritic varchar2(1000);        --> desc. erro
      
      BEGIN

      IF pr_cdtpprod = 1 THEN
        EMPR0008.pc_tela_valida_estorno(pr_nrdconta        => pr_nrdconta        --> Numero da Conta
                                       ,pr_nrctremp        => pr_nrctremp        --> Numero do Contrato
                                       ,pr_qtdlacto        => pr_qtdlacto        --> Quantidade de Lancamento
                                       ,pr_dsjustificativa => pr_dsjustificativa --> Justificativa
               									       ,pr_xmllog          => pr_xmllog          --> XML com informações de LOG
			      	          				       ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
					      				               ,pr_dscritic        => vr_dscritic        --> Descrição da crítica
         		  	    						       ,pr_retxml          => pr_retxml          --> Arquivo de retorno do XML
					                				     ,pr_nmdcampo        => pr_nmdcampo        --> Nome do campo com erro
									  	                 ,pr_des_erro        => pr_des_erro);

      ELSIF  pr_cdtpprod = 2 THEN
        DSCT0005.pc_tela_valida_lancto_dscto(pr_nrdconta        => pr_nrdconta        --> Numero da Conta
                                            ,pr_nrborder        => pr_nrctremp        --> Numero do Contrato
                                            ,pr_qtdlacto        => pr_qtdlacto        --> Quantidade de Lancamento
                                            ,pr_dsjustificativa => pr_dsjustificativa --> Justificativa
               									            ,pr_xmllog          => pr_xmllog          --> XML com informações de LOG
			      	          				            ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
					      				                    ,pr_dscritic        => vr_dscritic        --> Descrição da crítica
         		  	    						            ,pr_retxml          => pr_retxml          --> Arquivo de retorno do XML
					                				          ,pr_nmdcampo        => pr_nmdcampo        --> Nome do campo com erro
									  	                      ,pr_des_erro        => pr_des_erro);
      END IF; 
      -- Verifica erro das procedures
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
         
      EXCEPTION
        WHEN vr_exc_erro THEN 
          IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          END IF;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na rotina TELA_ESTORN.pc_tela_valida_lancto: ' || SQLERRM;
      
    END pc_tela_valida_lancto;
    
    PROCEDURE pc_tela_estornar_web(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                  ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
               									  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
			      	          				  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
					      				          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
         		  	    						  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					                				,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
									  	            ,pr_des_erro OUT VARCHAR2) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_tela_estornar
        Sistema  : 
        Sigla    : CRED
        Autor    : Cassia de Oliveira (GFT)
        Data     : 21/09/2018
        Frequencia: Sempre que for chamado
        Objetivo  : 
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
      vr_dscritic VARCHAR2(1000);        --> desc. erro
      
      ---->> VARIAVEIS <<-----
    
      vr_cdcooper        craptdb.cdcooper%TYPE;
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
                              
        DSCT0005.pc_tela_estornar_dscto(pr_cdcooper => vr_cdcooper               --> Cooperativa conectada
                                       ,pr_cdagenci => vr_cdagenci               --> Código da agência
                                       ,pr_nrdcaixa => vr_nrdcaixa               --> Número do caixa
                                       ,pr_cdoperad => vr_cdoperad               --> Código do Operador
                                       ,pr_nmdatela => vr_nmdatela               --> Nome da tela
                                       ,pr_idorigem => vr_idorigem               --> Id do módulo de sistema
                                       ,pr_nrdconta => pr_nrdconta               --> Número da conta
                                       ,pr_nrborder => pr_nrctremp               --> Número do bordero
                                       ,pr_dsjustificativa => pr_dsjustificativa --> Justificativa
                                       ,pr_cdcritic => vr_cdcritic               --> Codigo da Critica
                                       ,pr_dscritic => vr_dscritic);
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
   
      EXCEPTION
        WHEN vr_exc_erro THEN 
          IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          END IF;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na rotina TELA_ESTORN.pc_tela_estornar_web: ' || SQLERRM;
        
    END pc_tela_estornar_web;
    
    PROCEDURE pc_tela_imprimir_relatorio_web(pr_nrdconta IN crapbdt.nrdconta%TYPE        --> Numero da Conta
                                            ,pr_nrctremp IN crapbdt.nrborder%TYPE        --> Numero do Contrato
                                            ,pr_dtmvtolt IN VARCHAR2                     --> Data de Movimento
                                            ,pr_dtiniest IN VARCHAR2                     --> Data Inicio do Estorno
                                            ,pr_dtfinest IN VARCHAR2                     --> Data Fim do Estorno
                                            ,pr_cdagenci IN tbdsct_estorno.cdagenci%TYPE --> Agencia
                                            ,pr_cdtpprod IN NUMBER                       --> 1-Emprestimo PP 2-Desconto de titulo
                                            ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                            ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                            ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                            ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                            ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                            ,pr_des_erro OUT VARCHAR2) IS
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_tela_valida_estorno
        Sistema  : 
        Sigla    : CRED
        Autor    : Cassia de Oliveira (GFT) (GFT)
        Data     : 29/10/2018
        Frequencia: Sempre que for chamado
        Objetivo  : 
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
      vr_dscritic VARCHAR2(1000);        --> desc. erro
      
      BEGIN

      IF pr_cdtpprod = 1 THEN
        EMPR0008.pc_tela_imprimir_relatorio(pr_nrdconta        => pr_nrdconta        --> Numero da Conta
                                           ,pr_nrctremp       => pr_nrctremp        --> Numero do Contrato
                                           ,pr_dtmvtolt       => pr_dtmvtolt        --> Data de Movimento
                                           ,pr_dtiniest       => pr_dtiniest        --> Data Inicio do Estorno
                                           ,pr_dtfinest       => pr_dtfinest        --> Data Fim do Estorno
                                           ,pr_cdagenci       =>pr_cdagenci         --> Agencia
               									           ,pr_xmllog          => pr_xmllog         --> XML com informações de LOG
			      	          				           ,pr_cdcritic        => vr_cdcritic       --> Código da crítica
					      				                   ,pr_dscritic        => vr_dscritic       --> Descrição da crítica
         		  	    						           ,pr_retxml          => pr_retxml         --> Arquivo de retorno do XML
                                           ,pr_nmdcampo        => pr_nmdcampo       --> Nome do campo com erro
									  	                     ,pr_des_erro        => pr_des_erro);
      ELSIF  pr_cdtpprod = 2 THEN
        DSCT0005.pc_imprimir_relatorio_dsct(pr_nrdconta        => pr_nrdconta        --> Numero da Conta
                                           ,pr_nrborder        => pr_nrctremp        --> Numero do Contrato
                                           ,pr_dtmvtolt        => pr_dtmvtolt        --> Data de Movimento
                                           ,pr_dtiniest        => pr_dtiniest        --> Data Inicio do Estorno
                                           ,pr_dtfinest        => pr_dtfinest        --> Data Fim do Estorno
                                           ,pr_cdagenci        => pr_cdagenci         --> Agencia
               									           ,pr_xmllog          => pr_xmllog         --> XML com informações de LOG
			      	          				           ,pr_cdcritic        => vr_cdcritic       --> Código da crítica
					      				                   ,pr_dscritic        => vr_dscritic       --> Descrição da crítica
         		  	    						           ,pr_retxml          => pr_retxml         --> Arquivo de retorno do XML
                                           ,pr_nmdcampo        => pr_nmdcampo       --> Nome do campo com erro
									  	                     ,pr_des_erro        => pr_des_erro);
                                            
      END IF;
       
      -- Verifica erro das procedures
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      EXCEPTION
        WHEN vr_exc_erro THEN 
          IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          END IF;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na rotina TELA_ESTORN.pc_tela_valida_lancto: ' || SQLERRM;
      
    END pc_tela_imprimir_relatorio_web;

   PROCEDURE pc_efetua_estorno_prj_web (pr_nrdconta      IN crapass.nrdconta%TYPE --> conta do associado
                                       ,pr_nrborder      IN crapbdt.nrborder%TYPE --> numero do bordero
                                       ,pr_justificativa IN VARCHAR2              --> Justificativa
                                       ,pr_xmllog        IN VARCHAR2              --> xml com informações de log
                                       --------> OUT <--------
                                       ,pr_cdcritic   OUT PLS_INTEGER             --> código da crítica
                                       ,pr_dscritic   OUT VARCHAR2                --> descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY xmltype      --> arquivo de retorno do xml
                                       ,pr_nmdcampo   OUT VARCHAR2                --> nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2                --> erros do processo
                                       ) IS
       /*---------------------------------------------------------------------------------------------------------------------
         Programa : pc_efetua_estorno_prj_web
         Sistema  : 
         Sigla    : CRED
         Autor    : Vitor S. Assanuma (GFT)
         Data     : 06/11/2018
         Frequencia: Sempre que for chamado
         Objetivo  : Estornar lançamentos de Prejuízo.
       ---------------------------------------------------------------------------------------------------------------------*/
       -- Tratamento de erro
       vr_exc_erro EXCEPTION;
         
       -- Variável de críticas
       vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
       vr_dscritic varchar2(1000);        --> desc. erro
             
       -- Variaveis de entrada vindas no XML
       vr_cdcooper INTEGER;
       vr_nmdatela VARCHAR2(100);
       vr_nmeacao  VARCHAR2(100);
       vr_cdagenci VARCHAR2(100);
       vr_nrdcaixa VARCHAR2(100);
       vr_cdoperad VARCHAR2(100);
       vr_idorigem VARCHAR2(100);   
       
       -- Variáveis auxiliares
       vr_cdestorno NUMBER;     
       rw_crapdat   btch0001.rw_crapdat%TYPE; --> Tipo de registro de datas
     
       BEGIN
         -- Tratativa de Erros
         pr_des_erro := 'OK';
         pr_nmdcampo := NULL;
           
         -- Extração dos dados
         gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                                 , pr_cdcooper => vr_cdcooper
                                 , pr_nmdatela => vr_nmdatela
                                 , pr_nmeacao  => vr_nmeacao
                                 , pr_cdagenci => vr_cdagenci
                                 , pr_nrdcaixa => vr_nrdcaixa
                                 , pr_idorigem => vr_idorigem
                                 , pr_cdoperad => vr_cdoperad
                                 , pr_dscritic => vr_dscritic);        
         -- Verifica erro da chamada da procedure
         IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;
         
         -- Realiza o estorno do prejuízo.
         DSCT0005.pc_realiza_estorno_prejuizo(pr_cdcooper => vr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrborder => pr_nrborder
                                             ,pr_cdagenci => vr_cdagenci
                                             ,pr_cdoperad => vr_cdoperad
                                             ,pr_dsjustificativa => pr_justificativa
                                             -- OUT --
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
         -- Verifica erro da chamada da procedure
         IF TRIM(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
         END IF;
         
         -- Inicializar o clob
         vr_des_xml := null;
         dbms_lob.createtemporary(vr_des_xml, true);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
     
         -- Inicilizar as informaçoes do XML
         pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                             '<root><dados>');
         pc_escreve_xml('<OK>1</OK>');
         pc_escreve_xml ('</dados></root>',true);
         pr_retxml := xmltype.createxml(vr_des_xml);
     
         -- Liberando a memória alocada pro clob
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);                                              
       EXCEPTION 
         WHEN vr_exc_erro THEN 
           pr_des_erro := 'NOK';
           -- Se foi retornado apenas código busca a descrição
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN 
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           -- Variavel de erro recebe erro ocorrido
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
                
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
         WHEN OTHERS THEN 
           pr_des_erro := 'NOK';
           -- Montar descriçao de erro nao tratado
           pr_dscritic := 'erro nao tratado na tela.pc_efetua_estorno_prj_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
   END pc_efetua_estorno_prj_web;
   
END TELA_ESTORN;
/
