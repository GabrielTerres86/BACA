CREATE OR REPLACE PACKAGE CECRED.DSCT0005 AS
/*..............................................................................

   Programa: DSCT0005
   Sistema : Cred
   Sigla   : CRED
   Autor   : Cassia de Oliveira (GFT)
   Data    : 17/09/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Realizar estorno de desconto de titulo

   Alteracoes:
..............................................................................*/
  ---->> CURSORES <<-----
  CURSOR cr_tbdsct_lancamento_bordero(vr_cdcooper IN craptdb.cdcooper%TYPE,
                      vr_nrdconta IN craptdb.nrdconta%TYPE,
                      vr_nrborder IN craptdb.nrborder%TYPE,
                      vr_dtinimes IN DATE,
                      vr_dtultdia IN crapdat.dtultdia%TYPE) IS
     SELECT tlb.*,
            tdb.dtvencto,
            tdb.rowid AS id
       FROM tbdsct_lancamento_bordero tlb
       INNER JOIN craptdb tdb 
         ON    tdb.cdcooper = tlb.cdcooper   
           AND tdb.nrdconta = tlb.nrdconta
           AND tdb.nrborder = tlb.nrborder
           AND tdb.nrdocmto = tlb.nrdocmto
       INNER JOIN crapbdt bdt
         ON    bdt.cdcooper = tdb.cdcooper
           AND bdt.nrborder = tdb.nrborder
      WHERE tlb.cdcooper = vr_cdcooper 
        AND tlb.nrdconta = vr_nrdconta 
        AND tlb.nrborder = vr_nrborder 
        AND tlb.cdorigem IN (5, 7) 
        AND tlb.dtmvtolt BETWEEN vr_dtinimes AND vr_dtultdia
        AND tlb.dtmvtolt >= (SELECT MAX(dtmvtolt) FROM tbdsct_lancamento_bordero WHERE cdcooper = vr_cdcooper AND nrdconta = vr_nrdconta AND nrborder = vr_nrborder AND cdorigem IN (5, 7) AND cdhistor IN (2671,2682,2686,2675,2684,2688,2668,2669))
        AND tlb.dtmvtolt >= NVL((SELECT MAX(dtestorno) FROM tbdsct_estorno WHERE cdcooper = vr_cdcooper AND nrdconta = vr_nrdconta AND nrborder = vr_nrborder),vr_dtinimes)
        AND tlb.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtoopc
                            ,DSCT0003.vr_cdhistordsct_pgtoavalopc
                            ,DSCT0003.vr_cdhistordsct_pgtomultaopc
                            ,DSCT0003.vr_cdhistordsct_pgtomultaavopc
                            ,DSCT0003.vr_cdhistordsct_pgtojurosopc
                            ,DSCT0003.vr_cdhistordsct_pgtojurosavopc
                            ,DSCT0003.vr_cdhistordsct_apropjurmra
                            ,DSCT0003.vr_cdhistordsct_apropjurmta);
        
  TYPE typ_reg_lancto IS RECORD(
     cdcooper      tbdsct_lancamento_bordero.cdcooper%TYPE
    ,nrdconta      tbdsct_lancamento_bordero.nrdconta%TYPE
    ,nrborder      tbdsct_lancamento_bordero.nrborder%TYPE
    ,nrdocmto      tbdsct_lancamento_bordero.nrdocmto%TYPE
    ,nrtitulo      tbdsct_lancamento_bordero.nrtitulo%TYPE
    ,dtvencto      craptdb.dtvencto%TYPE
    ,dtmvtolt      tbdsct_lancamento_bordero.dtmvtolt%TYPE
    ,vllanmto      tbdsct_lancamento_bordero.vllanmto%TYPE
    ,vlpagmta      tbdsct_lancamento_bordero.vllanmto%TYPE
    ,vlpagmra      tbdsct_lancamento_bordero.vllanmto%TYPE
    ,cdhistor      tbdsct_lancamento_bordero.cdhistor%TYPE
    ,cdrecid       ROWID
    ,inprejuz      crapbdt.inprejuz%TYPE
    ,vlrabono      NUMBER(25,2));

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_lancto IS TABLE OF typ_reg_lancto INDEX BY BINARY_INTEGER;

  PROCEDURE pc_tela_busca_lancto_dscto (pr_nrdconta IN craptdb.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrborder IN craptdb.nrborder%TYPE --> Numero do Contrato
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                        
  PROCEDURE pc_tela_valida_lancto_dscto(pr_nrdconta IN craptdb.nrdconta%TYPE --> Numero da Conta
                                       ,pr_nrborder IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                       ,pr_qtdlacto IN PLS_INTEGER           --> Quantidade de Lancamento
                                       ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
               								         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
			      	          				       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
					      				               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
         		  	    						       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					                				     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
									  	                 ,pr_des_erro OUT VARCHAR2);
                                  
  PROCEDURE pc_tela_estornar_dscto(pr_cdcooper IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                       ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_nrborder IN crapepr.nrctremp%TYPE --> Número do bordero
                                       ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2);
                                       
  PROCEDURE pc_busca_lancto_dscto(pr_cdcooper   IN  crapbdt.cdcooper%TYPE
                                 ,pr_nrdconta   IN  crapbdt.nrdconta%TYPE
                                 ,pr_nrborder   IN  craptdb.nrborder%TYPE
                                 ,pr_vlpagtot   OUT tbdsct_lancamento_bordero.vllanmto%TYPE
                                 ,pr_tab_lancto OUT DSCT0005.typ_tab_lancto --> Lançamentos agrupados
                                 ,pr_cdcritic   OUT PLS_INTEGER          --> Codigo da Critica
                                 ,pr_dscritic   OUT VARCHAR2);
                                 
  PROCEDURE pc_realiza_estorno(pr_cdcooper        IN  crapbdt.cdcooper%TYPE
                              ,pr_nrborder        IN  craptdb.nrborder%TYPE
                              ,pr_vllanmto        IN  tbdsct_lancamento_bordero.vllanmto%TYPE
                              ,pr_vlpagmta        IN  tbdsct_lancamento_bordero.vllanmto%TYPE
                              ,pr_vlpagmra        IN  tbdsct_lancamento_bordero.vllanmto%TYPE
                              ,pr_cdrecid         IN  ROWID
                              ,pr_cdcritic        OUT PLS_INTEGER          --> Codigo da Critica
                              ,pr_dscritic        OUT VARCHAR2);
                              
  PROCEDURE pc_insere_estornolancamento(pr_cdcooper        IN  crapbdt.cdcooper%TYPE
                                       ,pr_nrdconta        IN  crapbdt.nrdconta%TYPE
                                       ,pr_nrborder        IN  craptdb.nrborder%TYPE
                                       ,pr_nrtitulo        IN  tbdsct_estornolancamento.nrtitulo%TYPE
                                       ,pr_dtvencto        IN  tbdsct_estornolancamento.dtvencto%TYPE
                                       ,pr_dtpagamento     IN  tbdsct_estornolancamento.dtpagamento%TYPE
                                       ,pr_vllanmto        IN  tbdsct_lancamento_bordero.vllanmto%TYPE
                                       ,pr_cdestorno       IN  NUMBER
                                       ,pr_cdhistor        IN  NUMBER
                                       ,pr_cdcritic        OUT PLS_INTEGER          --> Codigo da Critica
                                       ,pr_dscritic        OUT VARCHAR2);
                                       
  PROCEDURE pc_imprimir_relatorio_dsct(pr_nrdconta IN crapbdt.nrdconta%TYPE        --> Numero da Conta
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE        --> Numero do Contrato
                                      ,pr_dtmvtolt IN VARCHAR2                     --> Data de Movimento
                                      ,pr_dtiniest IN VARCHAR2                     --> Data Inicio do Estorno
                                      ,pr_dtfinest IN VARCHAR2                     --> Data Fim do Estorno
                                      ,pr_cdagenci IN tbdsct_estorno.cdagenci%TYPE  --> Agencia
                                      ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);
                                      
  PROCEDURE pc_insere_estorno(pr_cdcooper IN crapbdt.cdcooper%TYPE
                             ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                             ,pr_nrborder IN crapbdt.nrborder%TYPE
                             ,pr_cdoperad IN craptdb.cdoperad%TYPE 
                             ,pr_cdagenci IN crapbdt.cdagenci%TYPE
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                             ,pr_justific IN VARCHAR2
                             ,pr_cdestorno OUT tbdsct_estorno.cdestorno%TYPE
                             ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
					      				     ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                             );     
                             
  PROCEDURE pc_realiza_estorno_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                       ,pr_nrdconta  IN crapbdt.nrdconta%TYPE
                                       ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                       ,pr_cdagenci  IN crapbdt.cdagenci%TYPE
                                       ,pr_cdoperad  IN crapbdt.cdoperad%TYPE
                                       ,pr_dsjustificativa IN VARCHAR2
                                       -- OUT --
                                       ,pr_cdcritic OUT PLS_INTEGER
                                       ,pr_dscritic OUT VARCHAR2
                                       );

  PROCEDURE pc_realiza_estorno_cob(pr_cdcooper IN crapbdt.cdcooper%TYPE
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE
                                  ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                                  ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                                  ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE
                                  ,pr_nrdocmto IN craptdb.nrdocmto%TYPE
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                  -- OUT --
                                  ,pr_cdcritic OUT PLS_INTEGER
                                  ,pr_dscritic OUT VARCHAR2
                                  );
END DSCT0005;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DSCT0005 AS
/*..............................................................................

   Programa: DSCT0005
   Sistema : Cred
   Sigla   : CRED
   Autor   : Cassia de Oliveira
   Data    : 17/09/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Realizar estorno de desconto de titulo

   Alteracoes:
..............................................................................*/

  PROCEDURE pc_tela_busca_lancto_dscto (pr_nrdconta IN craptdb.nrdconta%TYPE --> Numero da Conta
                                        ,pr_nrborder IN craptdb.nrborder%TYPE --> Numero do Contrato
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................

    Programa: pc_tela_busca_lancto_dscto
    Sistema :
    Sigla   : CRED
    Autor   : Cassia de Oliveira
    Data    : 17/09/2018                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Busca lancamentos passiveis de estorno

    Alteracoes: 

    ..............................................................................*/

    ---->> VARIAVEIS <<-----
    
    vr_cdcooper        craptdb.cdcooper%TYPE;
    vr_cdoperad        VARCHAR2(100);
    vr_nmdatela        VARCHAR2(100);
    vr_nmeacao         VARCHAR2(100);
    vr_cdagenci        VARCHAR2(100);
    vr_nrdcaixa        VARCHAR2(100);
    vr_idorigem        VARCHAR2(100);
    vr_clob            CLOB;
    vr_xml_temp        VARCHAR2(32726) := '';
    vr_vlpagtot        tbdsct_lancamento_bordero.vllanmto%TYPE;
    vr_qtdlacto        PLS_INTEGER     := 0; 
    vr_nrdocmto        tbdsct_lancamento_bordero.nrdocmto%TYPE;
    
    pr_tab_lancto      typ_tab_lancto;
    
    ---->> TRATAMENTO DE ERROS <<----- 
    vr_cdcritic    NUMBER(3);
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

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
                              
          
      DSCT0005.pc_busca_lancto_dscto(pr_cdcooper   => vr_cdcooper
                                    ,pr_nrdconta   => pr_nrdconta
                                    ,pr_nrborder   => pr_nrborder
                                    ,pr_vlpagtot   => vr_vlpagtot
                                    ,pr_tab_lancto => pr_tab_lancto
                                    ,pr_cdcritic   => pr_cdcritic
                                    ,pr_dscritic   => pr_dscritic);

      -- Verifica se retornou registro
      IF pr_tab_lancto.COUNT = 0 THEN
        vr_cdcritic := 1;
        vr_dscritic := 'Não há pagamentos no mês atual, passíveis de estorno, para a conta e o borderô selecionados.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Monta documento XML
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados><Lancamentos>');
      
      vr_nrdocmto := pr_tab_lancto.FIRST;
      WHILE vr_nrdocmto IS NOT NULL LOOP
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<lancamento>'||
                                                        '<inprejuz>' || pr_tab_lancto(vr_nrdocmto).inprejuz                         ||'</inprejuz>'||
                                                        '<nrdconta>' || pr_tab_lancto(vr_nrdocmto).nrdconta                         ||'</nrdconta>'||
                                                        '<nrborder>' || pr_tab_lancto(vr_nrdocmto).nrborder                         ||'</nrborder>'||
                                                        '<nrparepr>' || pr_tab_lancto(vr_nrdocmto).nrdocmto                         ||'</nrparepr>'||
                                                        '<dtvencto>' || TO_CHAR(pr_tab_lancto(vr_nrdocmto).dtvencto,'DD/MM/YYYY')   ||'</dtvencto>'||
                                                        '<dtdpagto>' || TO_CHAR(pr_tab_lancto(vr_nrdocmto).dtmvtolt,'DD/MM/YYYY')   ||'</dtdpagto>'||
                                                        '<vlpagpar>' || pr_tab_lancto(vr_nrdocmto).vllanmto                         ||'</vlpagpar>'||
                                                        '<vlpagmta>' || pr_tab_lancto(vr_nrdocmto).vlpagmta                         ||'</vlpagmta>'||
                                                        '<vlpagmra>' || pr_tab_lancto(vr_nrdocmto).vlpagmra                         ||'</vlpagmra>'||
                                                        '<vlrabono>' || pr_tab_lancto(vr_nrdocmto).vlrabono                         ||'</vlrabono>'||
                                                     '</lancamento>');
        --Proximo registro
        vr_nrdocmto := pr_tab_lancto.NEXT(vr_nrdocmto);
      END LOOP;      
      -- Quantidade de Lancamentos
      vr_qtdlacto := NVL(pr_tab_lancto.COUNT,0);      
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
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        ROLLBACK;
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := 'Erro nao tratado na rotina pc_tela_busca_lancto_dscto: ' ||SQLERRM;

  END pc_tela_busca_lancto_dscto;
  
  PROCEDURE pc_tela_valida_lancto_dscto(pr_nrdconta IN craptdb.nrdconta%TYPE --> Numero da Conta
                                       ,pr_nrborder IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                       ,pr_qtdlacto IN PLS_INTEGER           --> Quantidade de Lancamento
                                       ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
               								         ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
			      	          				       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
					      				               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
         		  	    						       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					                				     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
									  	                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
                                       
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_tela_valida_lancto_dscto
        Sistema  : 
        Sigla    : CRED
        Autor    : Cassia de Oliveira (GFT)
        Data     : 19/09/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Valida se o lançamento é passivel de estorno
      ---------------------------------------------------------------------------------------------------------------------*/
      ---->> CURSORES <<-----
      CURSOR cr_crapbdt(pr_cdcooper IN craptdb.cdcooper%TYPE) IS
      SELECT crapbdt.inprejuz 
        FROM crapbdt 
       WHERE cdcooper = pr_cdcooper 
         AND nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE;
        
      CURSOR cr_crapprm(pr_cdcooper IN CRAPCOP.CDCOOPER%TYPE) IS
      SELECT TO_NUMBER(REPLACE(dsvlrprm,',','.'),'999999999.99')
        FROM crapprm
       WHERE cdcooper = pr_cdcooper
         AND cdacesso = 'VL_MAX_ESTORN_DST';
         
      CURSOR cr_cyber(pr_cdcooper IN CRAPCOP.CDCOOPER%TYPE,
                      pr_nrtitulo IN craptdb.nrtitulo%TYPE) IS
      SELECT nrctrdsc 
        FROM tbdsct_titulo_cyber 
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder
         AND nrtitulo = pr_nrtitulo;
      
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
        
      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_cdoperad        VARCHAR2(100);
      vr_flgretativo     INTEGER := 0;
      vr_flgretquitado   INTEGER := 0;
      vr_flgretcancelado INTEGER := 0;
      vr_vlmaxest        NUMBER;
      vr_vlpagtot        tbdsct_lancamento_bordero.vllanmto%TYPE;
      pr_tab_lancto      typ_tab_lancto;
      idx                NUMBER;
      vr_nrcyber         tbdsct_titulo_cyber.nrctrdsc%TYPE;
      
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
                              
      -- Buscar valor max para desc de titulo
      OPEN cr_crapprm(pr_cdcooper => vr_cdcooper);
        FETCH cr_crapprm
         INTO vr_vlmaxest;
         CLOSE cr_crapprm;
    
      --Se encontrou parametro valor max para estorno de desconto de titulo, atribui valor. Caso contrario, mantem Zero
      IF vr_vlmaxest IS NULL THEN
         vr_vlmaxest := 0;
      END IF;
      
      -- Busca parcelas para estorno
      pc_busca_lancto_dscto(pr_cdcooper   => vr_cdcooper
                           ,pr_nrdconta   => pr_nrdconta
                           ,pr_nrborder   => pr_nrborder
                           ,pr_vlpagtot   => vr_vlpagtot
                           ,pr_tab_lancto => pr_tab_lancto
                           ,pr_cdcritic   => pr_cdcritic
                           ,pr_dscritic   => pr_dscritic);
                             
      -- Verifica se retornou registro
      IF pr_tab_lancto.COUNT = 0 THEN
        vr_cdcritic := 1;
        vr_dscritic := 'Não há pagamentos no mês atual, passíveis de estorno, para a conta e o borderô selecionados.';
        RAISE vr_exc_erro;
      END IF;
                              
      -- Validar a quantidade de caracter do campo Justificativa 
      IF NVL(LENGTH(TRIM(pr_dsjustificativa)),0) = 0 THEN
        vr_dscritic := 'O campo Justificativa não foi informado';
        RAISE vr_exc_erro;
      
      ELSIF NVL(LENGTH(TRIM(pr_dsjustificativa)),0) < 10 THEN
        vr_dscritic := 'É necessario detalhar mais o campo Justificativa';
        RAISE vr_exc_erro;
        
      ELSIF NVL(LENGTH(TRIM(pr_dsjustificativa)),0) > 250 THEN
        vr_dscritic := 'O tamanho do texto do campo Justificativa excedeu o tamanho maximo';
        RAISE vr_exc_erro;
      END IF;  
      idx := pr_tab_lancto.first;
      WHILE idx IS NOT NULL LOOP
        -- Busca numero cyber    
        OPEN cr_cyber(pr_cdcooper => vr_cdcooper,
                      pr_nrtitulo => pr_tab_lancto(idx).nrtitulo);
          FETCH cr_cyber
           INTO vr_nrcyber;
           CLOSE cr_cyber;
      
        --Se encontrou parametro valor max para estorno de desconto de titulo, atribui valor. Caso contrario, mantem Zero
        IF vr_nrcyber IS NULL THEN
          idx := pr_tab_lancto.NEXT(idx);
          continue;
        END IF;
    
        RECP0001.pc_verifica_situacao_acordo(pr_cdcooper        => vr_cdcooper
                                            ,pr_nrdconta        => pr_nrdconta
                                            ,pr_nrctremp        => vr_nrcyber
                                            ,pr_cdorigem        => 4
                                            ,pr_flgretativo     => vr_flgretativo    
                                            ,pr_flgretquitado   => vr_flgretquitado  
                                           	,pr_flgretcancelado => vr_flgretcancelado
                                            ,pr_cdcritic        => vr_cdcritic
                                            ,pr_dscritic        => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Se estiver ATIVO
        IF vr_flgretativo = 1 THEN
          vr_dscritic := 'Estorno não permitido, desconto de título em acordo.';
          RAISE vr_exc_erro;
        END IF;
                   
        -- Se estiver QUITADO
        IF vr_flgretquitado = 1 THEN
          vr_dscritic := 'Lançamento não permitido, título liquidado através de acordo.';
          RAISE vr_exc_erro;
        END IF;
        idx := pr_tab_lancto.NEXT(idx);
      END LOOP;
      
      OPEN cr_crapbdt(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapbdt
        INTO rw_crapbdt;
      -- Se nao encontrar
      IF cr_crapbdt%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapbdt;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := 'Lançamento não permitido, borderô não encontrado.';
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapbdt;
      END IF;
      
      -- Caso não esteja em prejuízo, valida se está sendo lançado todos
      IF rw_crapbdt.inprejuz = 0 THEN
        -- Valida se a quantidade de pagamentos a ser estornada consiste com a quantidade de pagamentos selecionada em tela
        IF pr_qtdlacto <> pr_tab_lancto.COUNT THEN
          vr_dscritic := 'Lançamento não permitido, quantidade de lançamentos a ser estornado não é consistente com a quantidade apresentado em tela.';
          RAISE vr_exc_erro;
        END IF;  
      END IF;
     
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      
      -- Verifica o Valor maximo de estorno permitido sem autorizacao da coordenacao/gerencia
      IF vr_vlpagtot >= vr_vlmaxest THEN
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgsenha', pr_tag_cont => 1, pr_des_erro => vr_dscritic);
      ELSE
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgsenha', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
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
          pr_dscritic := 'Erro geral na rotina DSCT0005.pc_tela_valida_lancto_dscto: ' || SQLERRM;
      
  END pc_tela_valida_lancto_dscto;
  
  PROCEDURE pc_insere_estorno(pr_cdcooper IN crapbdt.cdcooper%TYPE
                             ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                             ,pr_nrborder IN crapbdt.nrborder%TYPE
                             ,pr_cdoperad IN craptdb.cdoperad%TYPE 
                             ,pr_cdagenci IN crapbdt.cdagenci%TYPE
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                             ,pr_justific IN VARCHAR2
                             ,pr_cdestorno OUT tbdsct_estorno.cdestorno%TYPE
                             ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
					      				     ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                             ) IS
    /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_insere_estorno
        Sistema  : 
        Sigla    : CRED
        Autor    : Vitor S. Assanuma (GFT)
        Data     : 06/11/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Insere na tabela de estorno e retorna o código.
      ---------------------------------------------------------------------------------------------------------------------*/                             
    BEGIN
      INSERT INTO tbdsct_estorno
         (cdcooper
         ,cdestorno
         ,nrdconta
         ,nrborder
         ,cdoperad
         ,cdagenci
         ,dtestorno
         ,hrestorno
         ,dsjustificativa)
      VALUES
         (pr_cdcooper
         ,fn_sequence('TBDSCT_ESTORNO','CDESTORNO',pr_cdcooper)
         ,pr_nrdconta
         ,pr_nrborder
         ,pr_cdoperad
         ,pr_cdagenci
         ,pr_dtmvtolt
         ,gene0002.fn_busca_time
         ,pr_justific)
      RETURNING tbdsct_estorno.cdestorno INTO pr_cdestorno;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao inserir na tabela de tbdsct_estorno. ' ||SQLERRM;
  END pc_insere_estorno;
  
  PROCEDURE pc_tela_estornar_dscto(pr_cdcooper IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                       ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                       ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                       ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                       ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                       ,pr_idorigem IN INTEGER               --> Id do módulo de sistema
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_nrborder IN crapepr.nrctremp%TYPE --> Número do bordero
                                       ,pr_dsjustificativa IN VARCHAR2       --> Justificativa
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS         --> Erros do processo
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_tela_estornar_pagamentos_dscto
        Sistema  : 
        Sigla    : CRED
        Autor    : Cassia de Oliveira (GFT)
        Data     : 20/09/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Realiza o estorno do lançamento
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
        
      -- Variável de Data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variáveis padrão
      vr_vlpagtot        tbdsct_lancamento_bordero.vllanmto%TYPE;
      pr_tab_lancto      typ_tab_lancto;
      vr_nrdocmto        tbdsct_lancamento_bordero.nrdocmto%TYPE;
      rw_dsctlcbd        cr_tbdsct_lancamento_bordero%ROWTYPE;
      vr_cdhistor        craplcm.cdhistor%TYPE;
      vr_cdestorno       NUMBER;
      
    -- Cursor
    CURSOR cr_craplcm(vr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                      vr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
      SELECT craplcm.*
        FROM craplcm
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.nrdconta = pr_nrdconta
         AND craplcm.dtmvtolt = vr_dtmvtolt
         AND craplcm.nrdocmto = vr_nrdocmto
         AND craplcm.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtocc
                                 ,DSCT0003.vr_cdhistordsct_pgtomultacc
                                 ,DSCT0003.vr_cdhistordsct_pgtojuroscc
                                 ,DSCT0003.vr_cdhistordsct_pgtoavalcc
                                 ,DSCT0003.vr_cdhistordsct_pgtomultaavcc
                                 ,DSCT0003.vr_cdhistordsct_pgtojurosavcc
         )
         AND craplcm.cdpesqbb LIKE '%'||pr_nrborder||'%';
     rw_craplcm cr_craplcm%ROWTYPE;
      
    BEGIN
      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
              
      -- Busca parcelas para estorno
      DSCT0005.pc_busca_lancto_dscto(pr_cdcooper   => pr_cdcooper
                                    ,pr_nrdconta   => pr_nrdconta
                                    ,pr_nrborder   => pr_nrborder
                                    ,pr_vlpagtot   => vr_vlpagtot
                                    ,pr_tab_lancto => pr_tab_lancto
                                    ,pr_cdcritic   => pr_cdcritic
                                    ,pr_dscritic   => pr_dscritic);
      -- Verifica se retornou registro
      IF pr_tab_lancto.COUNT = 0 THEN
        vr_cdcritic := 1;
        vr_dscritic := 'Não há pagamentos no mês atual, passíveis de estorno, para a conta e o borderô selecionados.';
        RAISE vr_exc_erro;
      END IF;
      
      vr_nrdocmto := pr_tab_lancto.FIRST;
      
      -- Se a data do lançamento é a data atual
      IF pr_tab_lancto(vr_nrdocmto).dtmvtolt = rw_crapdat.dtmvtolt THEN
        -- Percorre os titulos para realizar o estorno de lançamentos
        WHILE vr_nrdocmto IS NOT NULL LOOP   
          --Cria o registro do Estorno
          pc_insere_estorno(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrborder => pr_nrborder
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_justific => pr_dsjustificativa
                           -- OUT --
                           ,pr_cdestorno => vr_cdestorno
                           ,pr_cdcritic  => vr_cdcritic
                           ,pr_dscritic  => vr_dscritic
                           );
                           
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             vr_cdcritic := 0;
             RAISE vr_exc_erro;
          END IF;           
          -- Atualiza a situação do bordero e do titulo e insere registro de estorno
          pc_realiza_estorno(pr_cdcooper        => pr_cdcooper
                            ,pr_nrborder        => pr_nrborder
                            ,pr_vllanmto        => pr_tab_lancto(vr_nrdocmto).vllanmto
                            ,pr_vlpagmta        => pr_tab_lancto(vr_nrdocmto).vlpagmta
                            ,pr_vlpagmra        => pr_tab_lancto(vr_nrdocmto).vlpagmra
                            ,pr_cdrecid         => pr_tab_lancto(vr_nrdocmto).cdrecid
                            ,pr_cdcritic        => pr_cdcritic
                            ,pr_dscritic        => pr_dscritic);

          IF TRIM(pr_dscritic) IS NOT NULL THEN
            vr_cdcritic := 0;
            vr_dscritic := pr_dscritic;
            RAISE vr_exc_erro;
          END IF; 
            FOR rw_craplcm IN cr_craplcm (vr_dtmvtolt => pr_tab_lancto(vr_nrdocmto).dtmvtolt
                                         ,vr_nrdocmto => pr_tab_lancto(vr_nrdocmto).nrdocmto) LOOP
              pc_insere_estornolancamento(pr_cdcooper    => pr_cdcooper
                                         ,pr_nrdconta    => pr_nrdconta
                                         ,pr_nrborder    => pr_nrborder
                                         ,pr_nrtitulo    => pr_tab_lancto(vr_nrdocmto).nrtitulo
                                         ,pr_dtvencto    => pr_tab_lancto(vr_nrdocmto).dtvencto
                                         ,pr_dtpagamento => rw_craplcm.dtmvtolt
                                         ,pr_vllanmto    => rw_craplcm.vllanmto
                                         ,pr_cdestorno   => vr_cdestorno
                                         ,pr_cdhistor    => rw_craplcm.cdhistor
                                         ,pr_cdcritic    => pr_cdcritic
                                         ,pr_dscritic    => pr_dscritic);
              IF TRIM(pr_dscritic) IS NOT NULL THEN
                vr_cdcritic := 0;
                vr_dscritic := pr_dscritic;
                RAISE vr_exc_erro;
              END IF; 
            END LOOP;
          -- Exclui registros de lancamento
          BEGIN
            DELETE FROM craplcm
             WHERE craplcm.cdcooper = pr_cdcooper
               AND craplcm.nrdconta = pr_nrdconta
               AND craplcm.dtmvtolt = rw_crapdat.dtmvtolt
               AND craplcm.nrdocmto = pr_tab_lancto(vr_nrdocmto).nrdocmto
               AND craplcm.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtocc,
                                        DSCT0003.vr_cdhistordsct_pgtomultacc,
                                        DSCT0003.vr_cdhistordsct_pgtojuroscc,
                                        DSCT0003.vr_cdhistordsct_pgtoavalcc,
                                        DSCT0003.vr_cdhistordsct_pgtomultaavcc,
                                        DSCT0003.vr_cdhistordsct_pgtojurosavcc)
               AND craplcm.cdpesqbb LIKE '%'||pr_nrborder||'%';
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel excluir os lancamentos da conta corrente';
              RAISE vr_exc_erro;
          END;
          
          -- Exclui os lancamentos da Conta Corrente
          BEGIN
            DELETE FROM tbdsct_lancamento_bordero
             WHERE tbdsct_lancamento_bordero.cdcooper = pr_cdcooper
               AND tbdsct_lancamento_bordero.nrdconta = pr_nrdconta
               AND tbdsct_lancamento_bordero.nrborder = pr_nrborder
               AND tbdsct_lancamento_bordero.nrdocmto = pr_tab_lancto(vr_nrdocmto).nrdocmto
               AND tbdsct_lancamento_bordero.dtmvtolt = pr_tab_lancto(vr_nrdocmto).dtmvtolt
               AND tbdsct_lancamento_bordero.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtoopc,
                                                          DSCT0003.vr_cdhistordsct_pgtomultaopc,
                                                          DSCT0003.vr_cdhistordsct_pgtojurosopc,
                                                          DSCT0003.vr_cdhistordsct_pgtoavalopc,
                                                          DSCT0003.vr_cdhistordsct_pgtomultaavopc,
                                                          DSCT0003.vr_cdhistordsct_pgtojurosavopc,
                                                          DSCT0003.vr_cdhistordsct_apropjurmra,
                                                          DSCT0003.vr_cdhistordsct_apropjurmta);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel excluir os lancamentos de bordero';
              RAISE vr_exc_erro;
          END;                           
          -- Proximo titulo
          vr_nrdocmto := pr_tab_lancto.NEXT(vr_nrdocmto);
        END LOOP;
      -- Se o lançamento é anterior a data atual  
      ELSE
        -- Percorre os titulos para realizar o estorno de lançamentos
        WHILE vr_nrdocmto IS NOT NULL LOOP
          -- Atualiza a situação do bordero e do titulo
          pc_realiza_estorno(pr_cdcooper        => pr_cdcooper
                            ,pr_nrborder        => pr_nrborder
                            ,pr_vllanmto        => pr_tab_lancto(vr_nrdocmto).vllanmto
                            ,pr_vlpagmta        => pr_tab_lancto(vr_nrdocmto).vlpagmta
                            ,pr_vlpagmra        => pr_tab_lancto(vr_nrdocmto).vlpagmra
                            ,pr_cdrecid         => pr_tab_lancto(vr_nrdocmto).cdrecid
                            ,pr_cdcritic        => pr_cdcritic
                            ,pr_dscritic        => pr_dscritic);

          IF TRIM(pr_dscritic) IS NOT NULL THEN
            vr_cdcritic := 0;
            vr_dscritic := pr_dscritic;
            RAISE vr_exc_erro;
          END IF;
         
          -- Busca os dados para fazer o lancamento do estorno com historico correspondente a cada lancamento
          FOR rw_dsctlcbd IN cr_tbdsct_lancamento_bordero (vr_cdcooper => pr_cdcooper
                                                          ,vr_nrdconta => pr_nrdconta
                                                          ,vr_nrborder => pr_nrborder
                                                          ,vr_dtinimes => rw_crapdat.dtinimes
                                                          ,vr_dtultdia => rw_crapdat.dtultdia) LOOP
            CASE rw_dsctlcbd.cdhistor
              WHEN DSCT0003.vr_cdhistordsct_pgtoopc        THEN vr_cdhistor := DSCT0003.vr_cdhistordsct_est_pgto;
              WHEN DSCT0003.vr_cdhistordsct_pgtomultaopc   THEN vr_cdhistor := DSCT0003.vr_cdhistordsct_est_multa;
              WHEN DSCT0003.vr_cdhistordsct_pgtojurosopc   THEN vr_cdhistor := DSCT0003.vr_cdhistordsct_est_juros;
              WHEN DSCT0003.vr_cdhistordsct_pgtoavalopc    THEN vr_cdhistor := DSCT0003.vr_cdhistordsct_est_pgto_ava;
              WHEN DSCT0003.vr_cdhistordsct_pgtomultaavopc THEN vr_cdhistor := DSCT0003.vr_cdhistordsct_est_multa_ava;
              WHEN DSCT0003.vr_cdhistordsct_pgtojurosavopc THEN vr_cdhistor := DSCT0003.vr_cdhistordsct_est_juros_ava;
              WHEN DSCT0003.vr_cdhistordsct_apropjurmra    THEN vr_cdhistor := DSCT0003.vr_cdhistordsct_est_apro_juros;
              WHEN DSCT0003.vr_cdhistordsct_apropjurmta    THEN vr_cdhistor := DSCT0003.vr_cdhistordsct_est_apro_multa;
            END CASE;
            -- Inserir registros de lancamento de estorno do borderô na tabela tbdsct_lancamento_border
            DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper, 
                                                   pr_nrdconta => pr_nrdconta, 
                                                   pr_nrborder => pr_nrborder, 
                                                   pr_dtmvtolt => rw_crapdat.dtmvtolt, 
                                                   pr_cdorigem => rw_dsctlcbd.cdorigem, 
                                                   pr_cdhistor => vr_cdhistor, 
                                                   pr_vllanmto => rw_dsctlcbd.vllanmto, 
                                                   pr_cdbandoc => rw_dsctlcbd.cdbandoc, 
                                                   pr_nrdctabb => rw_dsctlcbd.nrdctabb, 
                                                   pr_nrcnvcob => rw_dsctlcbd.nrcnvcob, 
                                                   pr_nrdocmto => rw_dsctlcbd.nrdocmto, 
                                                   pr_nrtitulo => rw_dsctlcbd.nrtitulo, 
                                                   pr_dscritic => pr_dscritic);
             IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_erro;
             END IF;
          END LOOP;
          -- Atualiza lancamentos de pagamento inserindo data de estorno
          BEGIN
            UPDATE tbdsct_lancamento_bordero 
                 SET tbdsct_lancamento_bordero.dtestorn = rw_crapdat.dtmvtolt
               WHERE tbdsct_lancamento_bordero.cdcooper = pr_cdcooper
                 AND tbdsct_lancamento_bordero.nrdconta = pr_nrdconta
                 AND tbdsct_lancamento_bordero.nrborder = pr_nrborder
                 AND tbdsct_lancamento_bordero.nrdocmto = pr_tab_lancto(vr_nrdocmto).nrdocmto
                 AND tbdsct_lancamento_bordero.dtmvtolt = pr_tab_lancto(vr_nrdocmto).dtmvtolt
                 AND tbdsct_lancamento_bordero.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtoopc,
                                                            DSCT0003.vr_cdhistordsct_pgtomultaopc,
                                                            DSCT0003.vr_cdhistordsct_pgtojurosopc,
                                                            DSCT0003.vr_cdhistordsct_pgtoavalopc,
                                                            DSCT0003.vr_cdhistordsct_pgtomultaavopc,
                                                            DSCT0003.vr_cdhistordsct_pgtojurosavopc,
                                                            DSCT0003.vr_cdhistordsct_apropjurmra,
                                                            DSCT0003.vr_cdhistordsct_apropjurmta);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel atualizar a data de estorno dos lancamentos de bordero';
              RAISE vr_exc_erro;
          END;
          --Cria o registro do Estorno
          pc_insere_estorno(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrborder => pr_nrborder
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_justific => pr_dsjustificativa
                           -- OUT --
                           ,pr_cdestorno => vr_cdestorno
                           ,pr_cdcritic  => vr_cdcritic
                           ,pr_dscritic  => vr_dscritic
                           );
                           
          IF TRIM(vr_dscritic) IS NOT NULL THEN
             vr_cdcritic := 0;
             RAISE vr_exc_erro;
          END IF;           
          -- Busca os dados para fazer o lancamento do estorno correspondente a cada lancamento
          FOR rw_craplcm IN cr_craplcm (vr_dtmvtolt => pr_tab_lancto(vr_nrdocmto).dtmvtolt
                                       ,vr_nrdocmto => pr_tab_lancto(vr_nrdocmto).nrdocmto) LOOP 
            CASE rw_craplcm.cdhistor
              WHEN DSCT0003.vr_cdhistordsct_pgtomultacc   THEN vr_cdhistor := DSCT0003.vr_cdhistorlcm_multa;
              WHEN DSCT0003.vr_cdhistordsct_pgtocc        THEN vr_cdhistor := DSCT0003.vr_cdhistorlcm_pgto;
              WHEN DSCT0003.vr_cdhistordsct_pgtojuroscc   THEN vr_cdhistor := DSCT0003.vr_cdhistorlcm_juros;
              WHEN DSCT0003.vr_cdhistordsct_pgtoavalcc    THEN vr_cdhistor := DSCT0003.vr_cdhistorlcm_pgto_ava;
              WHEN DSCT0003.vr_cdhistordsct_pgtomultaavcc THEN vr_cdhistor := DSCT0003.vr_cdhistorlcm_multa_ava;
              WHEN DSCT0003.vr_cdhistordsct_pgtojurosavcc THEN vr_cdhistor := DSCT0003.vr_cdhistorlcm_juros_ava;
            END CASE;
            pc_insere_estornolancamento(pr_cdcooper    => pr_cdcooper
                                       ,pr_nrdconta    => pr_nrdconta
                                       ,pr_nrborder    => pr_nrborder
                                       ,pr_nrtitulo    => pr_tab_lancto(vr_nrdocmto).nrtitulo
                                       ,pr_dtvencto    => pr_tab_lancto(vr_nrdocmto).dtvencto
                                       ,pr_dtpagamento => rw_craplcm.dtmvtolt
                                       ,pr_vllanmto    => rw_craplcm.vllanmto
                                       ,pr_cdestorno   => vr_cdestorno
                                       ,pr_cdhistor    => rw_craplcm.cdhistor
                                       ,pr_cdcritic    => pr_cdcritic
                                       ,pr_dscritic    => pr_dscritic);
                                       
            IF TRIM(pr_dscritic) IS NOT NULL THEN
              vr_cdcritic := 0;
              vr_dscritic := pr_dscritic;
              RAISE vr_exc_erro;
            END IF; 
            -- Realizar Lançamento do estorno na craplcm de Desconto de Títulos
            DSCT0003.pc_efetua_lanc_cc(pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                       pr_cdagenci => pr_cdagenci, 
                                       pr_cdbccxlt => rw_craplcm.cdbccxlt, 
                                       pr_nrdconta => pr_nrdconta, 
                                       pr_vllanmto => rw_craplcm.vllanmto, 
                                       pr_cdhistor => vr_cdhistor, 
                                       pr_cdcooper => pr_cdcooper, 
                                       pr_cdoperad => pr_cdoperad, 
                                       pr_nrborder => pr_nrborder, 
                                       pr_cdpactra => NULL, 
                                       pr_nrdocmto => rw_craplcm.nrdocmto, 
                                       pr_cdcritic => pr_cdcritic, 
                                       pr_dscritic => pr_dscritic);
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END LOOP;
          -- Proximo titulo
          vr_nrdocmto := pr_tab_lancto.NEXT(vr_nrdocmto);
        END LOOP;
      END IF;
      COMMIT;
      EXCEPTION
        WHEN vr_exc_erro THEN 
          -- Desfaz a Transacao
          ROLLBACK;
          IF NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
          END IF;
        WHEN OTHERS THEN
          ROLLBACK;
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral na rotina DSCT0005.pc_tela_estornar_dscto: ' || SQLERRM;
      
  END pc_tela_estornar_dscto;
  
  PROCEDURE pc_busca_lancto_dscto(pr_cdcooper   IN  crapbdt.cdcooper%TYPE
                                 ,pr_nrdconta   IN  crapbdt.nrdconta%TYPE
                                 ,pr_nrborder   IN  craptdb.nrborder%TYPE
                                 ,pr_vlpagtot   OUT tbdsct_lancamento_bordero.vllanmto%TYPE
                                 ,pr_tab_lancto OUT DSCT0005.typ_tab_lancto --> Lançamentos agrupados
                                 ,pr_cdcritic   OUT PLS_INTEGER          --> Codigo da Critica
                                 ,pr_dscritic   OUT VARCHAR2) IS
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_busca_lancto_dscto
        Sistema  : 
        Sigla    : CRED
        Autor    : Cassia de Oliveira (GFT)
        Data     : 21/09/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Busca lançamentos passiveis de estorno
        Alterações:
          - 08/11/2018 - Vitor S. Assanuma: Inserção da busca quando borderô em Prejuízo.
      ---------------------------------------------------------------------------------------------------------------------*/
    
      rw_dsctlcbd cr_tbdsct_lancamento_bordero%ROWTYPE;
        
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
        
      -- Variável de Data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Cursor para verificar se o bordero está em Prejuizo
      CURSOR cr_crapbdt(pr_cdcooper crapbdt.cdcooper%TYPE
                       ,pr_nrborder crapbdt.nrborder%TYPE) IS
        SELECT bdt.inprejuz
        FROM crapbdt bdt
        WHERE
          bdt.cdcooper     = pr_cdcooper
          AND bdt.nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE; 
      
      -- Cursor de Lançamentos do borderô em prejuízo
      CURSOR cr_craptlb(pr_cdcooper  crapbdt.cdcooper%TYPE
                       ,pr_nrborder  crapbdt.nrborder%TYPE 
                       ,pr_dtini     DATE
                       ,pr_dtfim     DATE) IS
        SELECT tlb.dtmvtolt
          ,tlb.nrdconta
          ,tlb.nrborder
          ,SUM(CASE WHEN cdhistor <> PREJ0005.vr_cdhistordsct_rec_abono THEN vllanmto ELSE 0 END) AS vllanmto
          ,SUM(CASE WHEN cdhistor  = PREJ0005.vr_cdhistordsct_rec_abono THEN vllanmto ELSE 0 END) AS vlrabono
        FROM tbdsct_lancamento_bordero tlb
        WHERE tlb.cdcooper = pr_cdcooper 
          AND tlb.nrdconta = pr_nrdconta 
          AND tlb.nrborder = pr_nrborder 
          AND tlb.cdorigem IN (5, 7) 
          AND tlb.dtmvtolt BETWEEN pr_dtini AND pr_dtfim
          AND tlb.dtmvtolt >= (SELECT MAX(lan.dtmvtolt) 
                               FROM tbdsct_lancamento_bordero lan
                               INNER JOIN craphis his ON lan.cdcooper = his.cdcooper AND lan.cdhistor = his.cdhistor AND his.indebcre = 'C'
                               WHERE lan.cdcooper = pr_cdcooper 
                                 AND lan.nrdconta = pr_nrdconta 
                                 AND lan.nrborder = pr_nrborder 
                                 AND lan.cdorigem IN (5, 7)
                                 AND lan.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono
                                                     ,PREJ0005.vr_cdhistordsct_rec_principal
                                                     ,PREJ0005.vr_cdhistordsct_rec_jur_60
                                                     ,PREJ0005.vr_cdhistordsct_rec_jur_atuali
                                                     ,PREJ0005.vr_cdhistordsct_rec_mult_atras
                                                     ,PREJ0005.vr_cdhistordsct_rec_jur_mora
                                 ))
          AND tlb.dtmvtolt >= NVL((SELECT MAX(dtestorno) FROM tbdsct_estorno WHERE cdcooper = pr_cdcooper AND nrdconta = pr_nrdconta AND nrborder = pr_nrborder),pr_dtini)
          AND tlb.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono
                              ,PREJ0005.vr_cdhistordsct_rec_principal
                              ,PREJ0005.vr_cdhistordsct_rec_jur_60
                              ,PREJ0005.vr_cdhistordsct_rec_jur_atuali
                              ,PREJ0005.vr_cdhistordsct_rec_mult_atras
                              ,PREJ0005.vr_cdhistordsct_rec_jur_mora
          )
          -- Se algum título estiver em acordo, não lista.
          AND (tlb.nrborder, tlb.nrtitulo) NOT IN (
            SELECT ttc.nrborder, ttc.nrtitulo
            FROM tbdsct_titulo_cyber ttc
              INNER JOIN tbrecup_acordo_contrato tac ON ttc.nrctrdsc = tac.nrctremp
              INNER JOIN tbrecup_acordo ta           ON tac.nracordo = ta.nracordo
                 -- FALTAVAM ESTES CAMPOS NA CLAUSULA
                AND ta.cdcooper = ttc.cdcooper
                AND ta.nrdconta = ttc.nrdconta
            WHERE tac.cdorigem   = 4 -- Desconto de Títulos
              AND ta.cdsituacao <> 3 -- Acordo não está cancelado
              AND tlb.cdcooper = ttc.cdcooper
              AND tlb.nrdconta = ttc.nrdconta
              AND tlb.nrborder = ttc.nrborder
          )
          AND tlb.dtestorn IS NULL
          GROUP BY tlb.dtmvtolt, tlb.nrdconta, tlb.nrborder ;
     rw_craptlb cr_craptlb%ROWTYPE;
     
    BEGIN
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
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      OPEN cr_crapbdt(pr_cdcooper => pr_cdcooper
                     ,pr_nrborder => pr_nrborder);
      FETCH cr_crapbdt INTO rw_crapbdt;
      CLOSE cr_crapbdt;
      
      IF rw_crapbdt.inprejuz = 0 THEN 
        -- Busca os dados
        FOR rw_dsctlcbd IN cr_tbdsct_lancamento_bordero (vr_cdcooper => pr_cdcooper
                        ,vr_nrdconta => pr_nrdconta
                        ,vr_nrborder => pr_nrborder
                        ,vr_dtinimes => rw_crapdat.dtinimes
                        ,vr_dtultdia => rw_crapdat.dtultdia) LOOP
                        
          -- Agrupa lancamentos por nrdocmto
          pr_tab_lancto(rw_dsctlcbd.nrtitulo).nrdconta := rw_dsctlcbd.nrdconta;
          pr_tab_lancto(rw_dsctlcbd.nrtitulo).nrborder := rw_dsctlcbd.nrborder;
          pr_tab_lancto(rw_dsctlcbd.nrtitulo).nrdocmto := rw_dsctlcbd.nrdocmto;
          pr_tab_lancto(rw_dsctlcbd.nrtitulo).nrtitulo := rw_dsctlcbd.nrtitulo;
          pr_tab_lancto(rw_dsctlcbd.nrtitulo).dtmvtolt := rw_dsctlcbd.dtmvtolt;
          pr_tab_lancto(rw_dsctlcbd.nrtitulo).dtvencto := rw_dsctlcbd.dtvencto;
          pr_tab_lancto(rw_dsctlcbd.nrtitulo).inprejuz := rw_crapbdt.inprejuz;
          
          IF rw_dsctlcbd.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtoopc, DSCT0003.vr_cdhistordsct_pgtoavalopc) THEN -- Se for valor do titulo
            pr_tab_lancto(rw_dsctlcbd.nrtitulo).vllanmto := NVL(pr_tab_lancto(rw_dsctlcbd.nrtitulo).vllanmto,0) + NVL(rw_dsctlcbd.vllanmto,0);
          ELSIF rw_dsctlcbd.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtomultaopc, DSCT0003.vr_cdhistordsct_pgtomultaavopc) THEN -- Se for valor da multa
            pr_tab_lancto(rw_dsctlcbd.nrtitulo).vlpagmta := NVL(pr_tab_lancto(rw_dsctlcbd.nrtitulo).vlpagmta,0) + NVL(rw_dsctlcbd.vllanmto,0);
          ELSIF rw_dsctlcbd.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtojurosopc, DSCT0003.vr_cdhistordsct_pgtojurosavopc) THEN -- Se for valor de juras de mora
            pr_tab_lancto(rw_dsctlcbd.nrtitulo).vlpagmra := NVL(pr_tab_lancto(rw_dsctlcbd.nrtitulo).vlpagmra,0) + NVL(rw_dsctlcbd.vllanmto,0);
          END IF;
          
          pr_tab_lancto(rw_dsctlcbd.nrtitulo).cdrecid := rw_dsctlcbd.id;
          -- Valor Pago Total
          IF rw_dsctlcbd.cdhistor NOT IN (DSCT0003.vr_cdhistordsct_apropjurmra, DSCT0003.vr_cdhistordsct_apropjurmta) THEN
             pr_vlpagtot := NVL(pr_vlpagtot,0) + NVL(rw_dsctlcbd.vllanmto,0);
          END IF;
        END LOOP;
      ELSE
        OPEN cr_craptlb(pr_cdcooper => pr_cdcooper
                       ,pr_nrborder => pr_nrborder
                       ,pr_dtini    => rw_crapdat.dtinimes
                       ,pr_dtfim    => rw_crapdat.dtultdia);
        FETCH cr_craptlb INTO rw_craptlb;
        CLOSE cr_craptlb;
        
        pr_tab_lancto(rw_craptlb.nrborder).nrdconta := rw_craptlb.nrdconta;
        pr_tab_lancto(rw_craptlb.nrborder).nrborder := rw_craptlb.nrborder;
        pr_tab_lancto(rw_craptlb.nrborder).dtmvtolt := rw_craptlb.dtmvtolt;
        pr_tab_lancto(rw_craptlb.nrborder).inprejuz := rw_crapbdt.inprejuz;
        pr_tab_lancto(rw_craptlb.nrborder).vllanmto := NVL(rw_craptlb.vllanmto,0);
        pr_tab_lancto(rw_craptlb.nrborder).vlrabono := NVL(rw_craptlb.vlrabono,0);
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
          pr_dscritic := 'Erro geral na rotina DSCT0005.pc_busca_lancto_dscto: ' || SQLERRM;
  END pc_busca_lancto_dscto;
  
  PROCEDURE pc_realiza_estorno(pr_cdcooper        IN  crapbdt.cdcooper%TYPE
                              ,pr_nrborder        IN  craptdb.nrborder%TYPE
                              ,pr_vllanmto        IN  tbdsct_lancamento_bordero.vllanmto%TYPE
                              ,pr_vlpagmta        IN  tbdsct_lancamento_bordero.vllanmto%TYPE
                              ,pr_vlpagmra        IN  tbdsct_lancamento_bordero.vllanmto%TYPE
                              ,pr_cdrecid         IN  ROWID
                              ,pr_cdcritic        OUT PLS_INTEGER          --> Codigo da Critica
                              ,pr_dscritic        OUT VARCHAR2) IS
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_realiza_estorno
        Sistema  : 
        Sigla    : CRED
        Autor    : Cassia de Oliveira (GFT)
        Data     : 25/10/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Atualiza a situação do titulo e do bordero
      ---------------------------------------------------------------------------------------------------------------------*/
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
      
    BEGIN
      UPDATE crapbdt bdt
         SET bdt.insitbdt = 3
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrborder = pr_nrborder;
         
      -- Verifica quanto deve ser estornado do juros 60
      UPDATE craptdb tdb
         SET tdb.insittit = 4
            ,tdb.dtdebito = NULL
            ,tdb.vlsldtit = tdb.vlsldtit + NVL(pr_vllanmto,0)
            ,tdb.vlpagmta = tdb.vlpagmta - NVL(pr_vlpagmta,0)
            ,tdb.vlpagmra = tdb.vlpagmra - NVL(pr_vlpagmra,0)
            ,tdb.vlpgjm60 = CASE WHEN (NVL(pr_vlpagmra,0) >= tdb.vlpgjm60) THEN 0 ELSE (tdb.vlpgjm60 - NVL(pr_vlpagmra,0)) END
       WHERE tdb.rowid    = pr_cdrecid;	
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Nao foi possivel atualizar a situcao dos titulos e do bordero';
  END pc_realiza_estorno;
  
  PROCEDURE pc_realiza_estor_tit_prj(pr_cdcooper        IN crapbdt.cdcooper%TYPE
                                    ,pr_nrborder        IN craptdb.nrborder%TYPE
                                    ,pr_nrtitulo        IN craptdb.nrtitulo%TYPE
                                    ,pr_vlsdprej        IN craptdb.vlsdprej%TYPE DEFAULT 0
                                    ,pr_vlpgjmpr        IN craptdb.vlpgjmpr%TYPE DEFAULT 0
                                    ,pr_vlpgmupr        IN craptdb.vlpgmupr%TYPE DEFAULT 0
                                    ,pr_vlpgjrpr        IN craptdb.vlpgjrpr%TYPE DEFAULT 0
                                    ,pr_cdcritic        OUT PLS_INTEGER          --> Codigo da Critica
                                    ,pr_dscritic        OUT VARCHAR2) IS
   /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_realiza_estor_tit_prj
      Sistema  : 
      Sigla    : CRED
      Autor    : Vitor S. Assanuma
      Data     : 08/11/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Atualiza a situação do titulo em prejuizo
    ---------------------------------------------------------------------------------------------------------------------*/
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
    vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
      
    BEGIN
      UPDATE craptdb tdb
         SET tdb.insittit = 4
            ,tdb.dtdebito = NULL
            ,tdb.vlsdprej = tdb.vlsdprej + NVL(pr_vlsdprej, 0) -- Saldo Prejuizo
            ,tdb.vlpgjmpr = tdb.vlpgjmpr - NVL(pr_vlpgjmpr, 0) -- Juros Mora
            ,tdb.vlpgmupr = tdb.vlpgmupr - NVL(pr_vlpgmupr, 0) -- Multa
            ,tdb.vlpgjrpr = tdb.vlpgjrpr - NVL(pr_vlpgjrpr, 0) -- Acumulado
            ,tdb.vlpgjm60 = CASE WHEN (NVL(pr_vlpgjmpr,0) >= tdb.vlpgjm60) THEN 0 ELSE (tdb.vlpgjm60 - NVL(pr_vlpgjmpr,0)) END
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrborder = pr_nrborder
         AND tdb.nrtitulo = pr_nrtitulo;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Não foi possivel atualizar a situção dos títulos.';
  END pc_realiza_estor_tit_prj;
  
  PROCEDURE pc_insere_estornolancamento(pr_cdcooper        IN  crapbdt.cdcooper%TYPE
                                       ,pr_nrdconta        IN  crapbdt.nrdconta%TYPE
                                       ,pr_nrborder        IN  craptdb.nrborder%TYPE
                                       ,pr_nrtitulo        IN  tbdsct_estornolancamento.nrtitulo%TYPE
                                       ,pr_dtvencto        IN  tbdsct_estornolancamento.dtvencto%TYPE
                                       ,pr_dtpagamento     IN  tbdsct_estornolancamento.dtpagamento%TYPE
                                       ,pr_vllanmto        IN  tbdsct_lancamento_bordero.vllanmto%TYPE
                                       ,pr_cdestorno       IN  NUMBER
                                       ,pr_cdhistor        IN  NUMBER
                                       ,pr_cdcritic        OUT PLS_INTEGER          --> Codigo da Critica
                                       ,pr_dscritic        OUT VARCHAR2) IS
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_insere_estornolancamento
        Sistema  : 
        Sigla    : CRED
        Autor    : Cassia de Oliveira (GFT)
        Data     : 26/10/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Realiza insert na tabela tbdsct_estornolancamento
      ---------------------------------------------------------------------------------------------------------------------*/
            
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      
      -- Variáveis padrão
      vr_cdlancamento NUMBER;
      
    BEGIN
      -- Sequencia da tabela de pagamentos das parcelas
      vr_cdlancamento := fn_sequence('TBDSCT_ESTORNOLANCAMENTO','CDLANCAMENTO',pr_cdcooper || ';' || 
                                                                              pr_nrdconta || ';' || 
                                                                              pr_nrborder || ';' ||
                                                                              pr_cdestorno);
              
      INSERT INTO tbdsct_estornolancamento
             (cdcooper
             ,nrdconta
             ,nrborder
             ,cdestorno
             ,cdlancamento
             ,nrtitulo
             ,dtvencto
             ,dtpagamento
             ,vllancamento
             ,cdhistor)
      VALUES (pr_cdcooper
             ,pr_nrdconta
             ,pr_nrborder
             ,pr_cdestorno
             ,vr_cdlancamento
             ,pr_nrtitulo
             ,pr_dtvencto
             ,pr_dtpagamento
             ,pr_vllanmto
             ,pr_cdhistor);

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao inserir na tabela de tbdsct_estornolancamento. ';
  END pc_insere_estornolancamento;
  
  PROCEDURE pc_imprimir_relatorio_dsct(pr_nrdconta IN crapbdt.nrdconta%TYPE        --> Numero da Conta
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE        --> Numero do Contrato
                                      ,pr_dtmvtolt IN VARCHAR2                     --> Data de Movimento
                                      ,pr_dtiniest IN VARCHAR2                     --> Data Inicio do Estorno
                                      ,pr_dtfinest IN VARCHAR2                     --> Data Fim do Estorno
                                      ,pr_cdagenci IN tbdsct_estorno.cdagenci%TYPE  --> Agencia
                                      ,pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS                --> Erros do processo                                       
  BEGIN
    /* .............................................................................

     Programa: pc_imprimir_relatorio_dsct
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : CRED
     Autor   : Cássia de Oliveira - GFT
     Data    : outubro/18.                    Ultima atualizacao:

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
               est.nrborder,
               est.cdagenci,
               est.cdestorno,
               est.cdoperad,
               est.dsjustificativa,
               est.dtestorno,                              
               lcto.nrtitulo,
               lcto.dtpagamento,
               lcto.cdhistor,
               lcto.vllancamento,
               bdt.inprejuz,
               COUNT(*) over (PARTITION BY lcto.cdcooper, lcto.nrdconta, lcto.nrborder, lcto.cdestorno, lcto.nrtitulo, lcto.dtpagamento) totreg,
               row_number() over (PARTITION BY lcto.cdcooper, lcto.nrdconta, lcto.nrborder, lcto.cdestorno, lcto.nrtitulo, lcto.dtpagamento
                                      ORDER BY lcto.cdcooper, lcto.nrdconta, lcto.nrborder, lcto.cdestorno, lcto.nrtitulo, lcto.dtpagamento) nrseq
          FROM tbdsct_estorno est
    INNER JOIN tbdsct_estornolancamento lcto
            ON lcto.cdcooper  = est.cdcooper
           AND lcto.nrdconta  = est.nrdconta
           AND lcto.nrborder  = est.nrborder
           AND lcto.cdestorno = est.cdestorno
    INNER JOIN crapbdt bdt 
            ON bdt.cdcooper = est.cdcooper
           AND bdt.nrdconta = est.nrdconta
           AND bdt.nrborder = est.nrborder            
         WHERE est.cdcooper = pr_cdcooper 
           AND est.dtestorno BETWEEN pr_dtiniest AND pr_dtfinest
           AND (nvl(pr_nrdconta,0) = 0 OR est.nrdconta = pr_nrdconta)
           AND (nvl(pr_nrctremp,0) = 0 OR est.nrborder = pr_nrborder)
           AND (nvl(pr_cdagenci,0) = 0 OR est.cdagenci = pr_cdagenci)
      ORDER BY lcto.cdcooper, 
               lcto.nrdconta, 
               lcto.nrborder,
               lcto.cdestorno, 
               lcto.nrborder, 
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
      
      /*
      CURSOR cr_crapbdt(pr_cdcooper IN tbepr_estorno.cdcooper%TYPE) IS
      SELECT bdt.inprejuz
             ,bdt.nrborder
        FROM crapbdt bdt
       WHERE bdt.cdcooper = pr_cdcooper
        AND (nvl(pr_nrborder,0) = 0 OR bdt.nrborder = pr_nrborder);
      rw_crapbdt cr_crapbdt%ROWTYPE; 
      */
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
      vr_inprejuz        crapbdt.inprejuz%TYPE;
          
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
        vr_dscritic := 'O campo data inicial nao foi preenchido';
        RAISE vr_exc_saida;
      END IF;
      
      IF vr_dtfinest IS NULL THEN
        vr_dscritic := 'O campo data final nao foi preenchido';
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
                                     pr_nrctremp => pr_nrborder,
                                     pr_dtiniest => vr_dtiniest,
                                     pr_dtfinest => vr_dtfinest,
                                     pr_cdagenci => pr_cdagenci) LOOP
            
        IF rw_estorno.inprejuz = 0 THEN  
            
          -- Possui registros
          vr_bltemreg := TRUE;

          -- Credito de Pagamento
          IF rw_estorno.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtocc, DSCT0003.vr_cdhistordsct_pgtoavalcc) THEN
            vr_vlpagpar := NVL(vr_vlpagpar,0) + NVL(rw_estorno.vllancamento,0);
          
          -- Juros de Mora
          ELSIF rw_estorno.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtojuroscc,  DSCT0003.vr_cdhistordsct_pgtojurosavcc) THEN
            vr_vlpagmra := NVL(vr_vlpagmra,0) + NVL(rw_estorno.vllancamento,0);
            
          -- Multa
          ELSIF rw_estorno.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtomultacc,  DSCT0003.vr_cdhistordsct_pgtomultaavcc) THEN
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
                                                            <nrborder>'||rw_estorno.nrborder||'</nrborder>
                                                            <cdestorno>'||rw_estorno.cdestorno||'</cdestorno>
                                                            <cdoperad>'||rw_estorno.cdoperad||'</cdoperad>
                                                            <nmoperad>'||vr_nmoperad||'</nmoperad>
                                                            <dtestorno>'||TO_CHAR(rw_estorno.dtestorno,'DD/MM/YYYY')||'</dtestorno>
                                                            <cdagenci>'||rw_estorno.cdagenci||'</cdagenci>
                                                            <nmextage>'||vr_nmextage||'</nmextage>
                                                            <dsjustificativa>'||rw_estorno.dsjustificativa||'</dsjustificativa>                                                          
                                                            <nrtitulo>'||rw_estorno.nrtitulo||'</nrtitulo>
                                                            <dtpagamento>'||TO_CHAR(rw_estorno.dtpagamento,'DD/MM/YYYY')||'</dtpagamento>
                                                            <vlpagpar>'||TO_CHAR(vr_vlpagpar,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagpar>
                                                            <vlpagmta>'||TO_CHAR(vr_vlpagmta,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagmta>
                                                            <vlpagmra>'||TO_CHAR(vr_vlpagmra,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagmra>
                                                          </Dados>');
                                                          
            vr_vlpagpar := 0;
            vr_vlpagmta := 0;
            vr_vlpagmra := 0;
                                                  
          END IF; -- END IF rw_estorno.nrseq = rw_estorno.totreg THEN
      ELSE
            -- Possui registros
            vr_bltemreg := TRUE;
            -- Busca o nome da Agencia
            OPEN cr_crapage(vr_cdcooper, rw_estorno.cdagenci);
            FETCH cr_crapage INTO vr_nmextage;
            CLOSE cr_crapage;       
            
            -- Busca o nome do Operador                                       
            OPEN cr_crapope(vr_cdcooper, rw_estorno.cdoperad);
            FETCH cr_crapope INTO vr_nmoperad;        
            CLOSE cr_crapope;
            
            -- Verifica se é valor de abono e concatena na justificativa
            IF rw_estorno.cdhistor = PREJ0005.vr_cdhistordsct_rec_abono THEN
              rw_estorno.dsjustificativa := rw_estorno.dsjustificativa || ' (Abono)';
            END IF;

            gene0002.pc_escreve_xml(pr_xml            => vr_xml
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<Dados>
                                                            <nrdconta>'||rw_estorno.nrdconta||'</nrdconta>
                                                            <nrborder>'||rw_estorno.nrborder||'</nrborder>
                                                            <cdestorno>'||rw_estorno.cdestorno||'</cdestorno>
                                                            <cdoperad>'||rw_estorno.cdoperad||'</cdoperad>
                                                            <nmoperad>'||vr_nmoperad||'</nmoperad>
                                                            <dtestorno>'||TO_CHAR(rw_estorno.dtestorno,'DD/MM/YYYY')||'</dtestorno>
                                                            <cdagenci>'||rw_estorno.cdagenci||'</cdagenci>
                                                            <nmextage>'||vr_nmextage||'</nmextage>
                                                            <dsjustificativa>'||rw_estorno.dsjustificativa||'</dsjustificativa>                                                          
                                                            <nrtitulo>'||rw_estorno.nrtitulo||'</nrtitulo>
                                                            <dtpagamento>'||TO_CHAR(rw_estorno.dtpagamento,'DD/MM/YYYY')||'</dtpagamento>
                                                            <vlpagpar>'||TO_CHAR(rw_estorno.vllancamento,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagpar>
                                                            <vlpagmta>'||TO_CHAR(vr_vlpagmta,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagmta>
                                                            <vlpagmra>'||TO_CHAR(vr_vlpagmra,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlpagmra>
                                                          </Dados>');
      END IF;
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
      vr_nmarqimp := 'crrl770_' || TO_CHAR(SYSTIMESTAMP,'SSSSSFF5') || '.pdf';
      
      -- Solicitar geração do relatorio
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper --> Cooperativa conectada
                                 ,pr_cdprogra  => 'ESTORN' --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/Relatorio/Dados' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl770.jasper' --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto || '/' ||vr_nmarqimp --> Arquivo final com o path
                                 ,pr_cdrelato  => 770
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
        pr_dscritic := 'Erro geral em DSCT0005.pc_imprimir_relatorio_dsct: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;  
  
  END pc_imprimir_relatorio_dsct;

  PROCEDURE pc_realiza_estorno_prejuizo(pr_cdcooper  IN crapbdt.cdcooper%TYPE
                                       ,pr_nrdconta  IN crapbdt.nrdconta%TYPE
                                       ,pr_nrborder  IN crapbdt.nrborder%TYPE
                                       ,pr_cdagenci  IN crapbdt.cdagenci%TYPE
                                       ,pr_cdoperad  IN crapbdt.cdoperad%TYPE
                                       ,pr_dsjustificativa IN VARCHAR2
                                       -- OUT --
                                       ,pr_cdcritic OUT PLS_INTEGER
                                       ,pr_dscritic OUT VARCHAR2
                                       ) IS
   /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_realiza_estorno_prejuizo
      Sistema  : 
      Sigla    : CRED
      Autor    : Vitor S. Assanuma (GFT)
      Data     : 08/11/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Realizar o Estorno do Borderô em Prejuízo
      Alterações:
      -- Lucas Negoseki (GFT) - Adicionado novo histórico 2876 na busca de lançamentos borderô
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erro
    vr_exc_erro EXCEPTION;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
    vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
      
    -- Variável de Data
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variáveis locais
    vr_cdestorno       NUMBER;
    vr_est_abono       NUMBER(25,2);
    vr_cdhistor        NUMBER;
    vr_vllanmto_tot    NUMBER(25,2);
    
    -- Cursor para verificar se há algum titulo do bordero em acordo
    CURSOR cr_crapaco IS
      SELECT
        COUNT(1) AS in_acordo
      FROM
        tbdsct_titulo_cyber ttc
      INNER JOIN tbrecup_acordo ta ON ta.cdcooper = ttc.cdcooper AND ta.nrdconta = ttc.nrdconta
      INNER JOIN tbrecup_acordo_contrato tac ON ttc.nrctrdsc = tac.nrctremp AND tac.nracordo = ta.nracordo
      WHERE ttc.cdcooper = pr_cdcooper
        AND ttc.nrdconta = pr_nrdconta
        AND ttc.nrborder = pr_nrborder
        AND tac.cdorigem = 4   -- Desconto de Títulos
        AND ta.cdsituacao <> 3; -- Diferente de Cancelado
    rw_crapaco cr_crapaco%ROWTYPE;
    
    -- Cursor de lançamentos
    CURSOR cr_craplan(pr_dtini DATE,
                      pr_dtfim DATE) IS
      SELECT 
        tlb.cdcooper,
        tlb.nrdconta,
        tlb.nrborder,
        tlb.cdbandoc, 
        tlb.nrdctabb, 
        tlb.nrcnvcob, 
        tlb.nrdocmto, 
        tlb.nrtitulo,
        tlb.dtmvtolt,
        tlb.vllanmto,
        tlb.cdhistor,
        tlb.cdorigem,
        tlb.progress_recid AS id
      FROM tbdsct_lancamento_bordero tlb
      WHERE tlb.cdcooper = pr_cdcooper 
        AND tlb.nrborder = pr_nrborder 
        AND tlb.cdorigem IN (5, 7) 
        AND tlb.dtmvtolt BETWEEN  pr_dtini AND pr_dtfim
         AND tlb.dtmvtolt >= (SELECT MAX(lan.dtmvtolt) 
                              FROM tbdsct_lancamento_bordero lan
                              INNER JOIN craphis his ON lan.cdcooper = his.cdcooper AND lan.cdhistor = his.cdhistor AND his.indebcre = 'C'
                              WHERE lan.cdcooper = pr_cdcooper 
                                AND lan.nrdconta = pr_nrdconta 
                                AND lan.nrborder = pr_nrborder 
                                AND lan.cdorigem IN (5, 7)
                                AND tlb.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono      -- ABONO PREJUIZO        [2689]
                                                    ,PREJ0005.vr_cdhistordsct_rec_principal  -- PAG.PREJUIZO PRINCIP. [2770]
                                                    ,PREJ0005.vr_cdhistordsct_rec_jur_60     -- PGTO JUROS +60        [2771]
                                                    ,PREJ0005.vr_cdhistordsct_rec_jur_atuali -- PAGTO JUROS  PREJUIZO [2772]
                                                    ,PREJ0005.vr_cdhistordsct_rec_mult_atras -- PGTO MULTA ATRASO     [2773]
                                                    ,PREJ0005.vr_cdhistordsct_rec_jur_mora   -- PGTO JUROS MORA       [2774]
                                                    ,DSCT0003.vr_cdhistordsct_sumjratuprejuz -- SOMATORIO DOS JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO [2798]
                                                    ,PREJ0005.vr_cdhistordsct_rec_preju      -- PAGTO RECUPERAÇÃO PREJUIZO                                        
                                                    )
                              )
        AND tlb.dtmvtolt >= NVL((SELECT MAX(dtestorno) FROM tbdsct_estorno WHERE cdcooper = pr_cdcooper AND nrdconta = pr_nrdconta AND nrborder = pr_nrborder),pr_dtini)
        AND tlb.cdhistor IN (PREJ0005.vr_cdhistordsct_rec_abono      -- ABONO PREJUIZO        [2689]
                            ,PREJ0005.vr_cdhistordsct_rec_principal  -- PAG.PREJUIZO PRINCIP. [2770]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_60     -- PGTO JUROS +60        [2771]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_atuali -- PAGTO JUROS  PREJUIZO [2772]
                            ,PREJ0005.vr_cdhistordsct_rec_mult_atras -- PGTO MULTA ATRASO     [2773]
                            ,PREJ0005.vr_cdhistordsct_rec_jur_mora   -- PGTO JUROS MORA       [2774]
                            ,DSCT0003.vr_cdhistordsct_sumjratuprejuz -- SOMATORIO DOS JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO [2798]
                            ,PREJ0005.vr_cdhistordsct_rec_preju      -- PAGTO RECUPERAÇÃO PREJUIZO                                        
                            )
        -- Se algum título estiver em acordo, não lista.
        AND (tlb.cdcooper, tlb.nrborder) NOT IN ( 
          SELECT
            ttc.cdcooper, ttc.nrborder
          FROM
            tbdsct_titulo_cyber ttc
          INNER JOIN tbrecup_acordo ta ON ta.cdcooper = ttc.cdcooper AND ta.nrdconta = ttc.nrdconta
          INNER JOIN tbrecup_acordo_contrato tac ON ttc.nrctrdsc = tac.nrctremp AND tac.nracordo = ta.nracordo
          WHERE ttc.cdcooper = pr_cdcooper
            AND ttc.nrdconta = pr_nrdconta
            AND ttc.nrborder = pr_nrborder
            AND tac.cdorigem = 4   -- Desconto de Títulos
            AND ta.cdsituacao <> 3 -- Diferente de Cancelado
        )
        AND tlb.dtestorn IS NULL
      ORDER BY tlb.nrtitulo;
    rw_craplan cr_craplan%ROWTYPE;
    
    -- Cursor de lançamento do estorno
    CURSOR cr_craplcm IS
      SELECT lcm.dtmvtolt,
          NVL(SUM(lcm.vllanmto), 0) AS vllanmto,
          lcm.cdhistor,
          lcm.cdbccxlt,
          lcm.nrdocmto
      FROM craplcm lcm
      WHERE lcm.cdcooper = pr_cdcooper
        AND lcm.nrdconta = pr_nrdconta
        AND lcm.nrdocmto = pr_nrborder
        AND lcm.cdhistor = PREJ0005.vr_cdhistordsct_recup_preju
      GROUP BY lcm.dtmvtolt, lcm.cdhistor, lcm.cdbccxlt, lcm.nrdocmto
      ORDER BY lcm.dtmvtolt DESC;
    rw_craplcm cr_craplcm%ROWTYPE;
    
    -- Cursor para saber se houve algum estorno no dia
    CURSOR cr_crapestorno(pr_cdcooper crapbdt.cdcooper%TYPE
                         ,pr_nrdconta crapbdt.nrdconta%TYPE
                         ,pr_nrborder crapbdt.nrborder%TYPE
                         ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT NVL(SUM(vllancamento),0) vllancamento
      FROM
        tbdsct_estornolancamento tbe
      WHERE tbe.cdcooper    = pr_cdcooper
        AND tbe.nrdconta    = pr_nrdconta
        AND tbe.nrborder    = pr_nrborder
        AND tbe.dtpagamento = pr_dtmvtolt;
    rw_crapestorno cr_crapestorno%ROWTYPE;
    
    BEGIN
      -- Verificar se está em acordo
      OPEN cr_crapaco;
      FETCH cr_crapaco INTO rw_crapaco;
      CLOSE cr_crapaco;
      IF rw_crapaco.in_acordo > 0 THEN
        vr_dscritic := 'O borderô possui títulos em acordo, não é possível efetuar o estorno.';
        RAISE vr_exc_erro;
      END IF;  
    
      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1; -- Cooperativa sem data de nmovimento
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;
      
      vr_est_abono       := 0;
      -- Abre o cursor de lançamentos para efetuar os de estorno.
      OPEN cr_craplan(pr_dtini => rw_crapdat.dtinimes,
                      pr_dtfim => rw_crapdat.dtultdia);
      LOOP
        FETCH cr_craplan INTO rw_craplan;
        EXIT WHEN cr_craplan%NOTFOUND;
        
        -- Verifica qual o histórico de estorno deve ser lançado
        CASE rw_craplan.cdhistor            
          -- Abono
          WHEN PREJ0005.vr_cdhistordsct_rec_abono      THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_abono;
            vr_est_abono := vr_est_abono + rw_craplan.vllanmto;
                      
          -- Principal
          WHEN PREJ0005.vr_cdhistordsct_rec_principal  THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_principal;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlsdprej => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Principal retira do saldo
          -- Juros +60
          WHEN PREJ0005.vr_cdhistordsct_rec_jur_60     THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_jur_60;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlsdprej => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Juros+60 retira do saldo
          -- Atualização
          WHEN PREJ0005.vr_cdhistordsct_rec_jur_atuali THEN 
            vr_cdhistor        := PREJ0005.vr_cdhistordsct_est_jur_prej;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlpgjrpr => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Juros de Atualização
          -- Multa
          WHEN PREJ0005.vr_cdhistordsct_rec_mult_atras THEN 
            vr_cdhistor  := PREJ0005.vr_cdhistordsct_est_mult_atras;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlpgmupr => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Multa
          -- Mora
          WHEN PREJ0005.vr_cdhistordsct_rec_jur_mora   THEN 
            vr_cdhistor := PREJ0005.vr_cdhistordsct_est_jur_mor;
            -- Atualiza o valor do título
            pc_realiza_estor_tit_prj(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrtitulo => rw_craplan.nrtitulo
                                  ,pr_vlpgjmpr => rw_craplan.vllanmto
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic); -- Mora
          -- Juros de atualização
          WHEN DSCT0003.vr_cdhistordsct_sumjratuprejuz THEN
            vr_cdhistor := DSCT0003.vr_cdhistordsct_sumjratuprejuz;
            
          WHEN PREJ0005.vr_cdhistordsct_rec_preju THEN
            vr_cdhistor := PREJ0005.vr_cdhistordsct_est_preju;
        END CASE;
        
        -- Verifica se houve crítica   
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Caso o lançamento seja o mesmo dia de movimento deleta os lançamentos.
        IF (rw_craplan.dtmvtolt = rw_crapdat.dtmvtolt) THEN
          BEGIN
            DELETE FROM tbdsct_lancamento_bordero WHERE progress_recid = rw_craplan.id;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel remover o lançamento dos Lançamentos de Borderô.';
              RAISE vr_exc_erro;
          END; 
        ELSIF vr_cdhistor <> DSCT0003.vr_cdhistordsct_sumjratuprejuz THEN -- lançamento de juros de atualização
          -- Inserir registros de lancamento de estorno do borderô na tabela tbdsct_lancamento_border
          DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper, 
                                                 pr_nrdconta => pr_nrdconta, 
                                                 pr_nrborder => pr_nrborder, 
                                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                                 pr_cdorigem => rw_craplan.cdorigem, 
                                                 pr_cdhistor => vr_cdhistor, 
                                                 pr_vllanmto => rw_craplan.vllanmto, 
                                                 pr_cdbandoc => rw_craplan.cdbandoc, 
                                                 pr_nrdctabb => rw_craplan.nrdctabb, 
                                                 pr_nrcnvcob => rw_craplan.nrcnvcob, 
                                                 pr_nrdocmto => rw_craplan.nrdocmto, 
                                                 pr_nrtitulo => rw_craplan.nrtitulo, 
                                                 pr_dscritic => pr_dscritic);
          -- Verifica se houve crítica   
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Atualiza o campo de estorno
          BEGIN
            UPDATE tbdsct_lancamento_bordero SET dtestorn = rw_crapdat.dtmvtolt WHERE progress_recid = rw_craplan.id;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Nao foi possivel atualizar a data de estorno dos Lançamentos de Borderô.';
              RAISE vr_exc_erro;
          END; 
        END IF;
      END LOOP;
      CLOSE cr_craplan; 
        
      -- Atualiza o Borderô 
      BEGIN
        UPDATE crapbdt bdt
        SET bdt.insitbdt = 3,
            bdt.dtliqprj = NULL,
            bdt.vlaboprj = bdt.vlaboprj - vr_est_abono
        WHERE bdt.cdcooper = pr_cdcooper 
          AND bdt.nrborder = pr_nrborder;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel atualizar a situação do Borderô.';
          RAISE vr_exc_erro;
      END;
      
      vr_vllanmto_tot := 0;
      -- Faz o estorno do último lançamento da LCM
      OPEN  cr_craplcm;
      FETCH cr_craplcm INTO rw_craplcm;
      CLOSE cr_craplcm;
      
      --Cria o registro do Estorno
      pc_insere_estorno(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrborder => pr_nrborder
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_justific => pr_dsjustificativa
                       -- OUT --
                       ,pr_cdestorno => vr_cdestorno
                       ,pr_cdcritic  => vr_cdcritic
                       ,pr_dscritic  => vr_dscritic
                       );
                       
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         vr_cdcritic := 0;
         RAISE vr_exc_erro;
      END IF;
      
      OPEN cr_crapestorno(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         );
      FETCH cr_crapestorno INTO rw_crapestorno;
      CLOSE cr_crapestorno;
      
      -- Caso tenha lançamentos no dia, retirar o que já foi lançado.
      vr_vllanmto_tot := rw_craplcm.vllanmto - rw_crapestorno.vllancamento;
      
      -- Insere o estorno na tabela de lançamentos de estorno
      pc_insere_estornolancamento(pr_cdcooper    => pr_cdcooper
                                 ,pr_nrdconta    => pr_nrdconta
                                 ,pr_nrborder    => pr_nrborder
                                 ,pr_nrtitulo    => 0           -- É do borderô
                                 ,pr_dtvencto    => NULL        -- É do borderô
                                 ,pr_dtpagamento => rw_craplcm.dtmvtolt
                                 ,pr_vllanmto    => vr_vllanmto_tot
                                 ,pr_cdestorno   => vr_cdestorno
                                 ,pr_cdhistor    => rw_craplcm.cdhistor
                                 ,pr_cdcritic    => pr_cdcritic
                                 ,pr_dscritic    => pr_dscritic);
                                       
      IF TRIM(pr_dscritic) IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := pr_dscritic;
        RAISE vr_exc_erro;      
      END IF;
      
      -- Caso tenha abono faz mais um lançamento dentro do estorno_lancamento
      IF vr_est_abono > 0 THEN
        -- Insere o estorno na tabela de lançamentos de estorno
        pc_insere_estornolancamento(pr_cdcooper    => pr_cdcooper
                                   ,pr_nrdconta    => pr_nrdconta
                                   ,pr_nrborder    => pr_nrborder
                                   ,pr_nrtitulo    => 0           -- É do borderô
                                   ,pr_dtvencto    => NULL        -- É do borderô
                                   ,pr_dtpagamento => rw_craplcm.dtmvtolt
                                   ,pr_vllanmto    => vr_est_abono
                                   ,pr_cdestorno   => vr_cdestorno
                                   ,pr_cdhistor    => PREJ0005.vr_cdhistordsct_rec_abono
                                   ,pr_cdcritic    => pr_cdcritic
                                   ,pr_dscritic    => pr_dscritic);
                                         
        IF TRIM(pr_dscritic) IS NOT NULL THEN
          vr_cdcritic := 0;
          vr_dscritic := pr_dscritic;
          RAISE vr_exc_erro;      
        END IF;
      END IF;
      
      -- Caso o lançamento seja do mesmo dia deleta os lançamentos, senão lança na CC o estorno.
      IF (rw_craplcm.dtmvtolt = rw_crapdat.dtmvtolt) THEN
        BEGIN
          DELETE FROM craplcm lcm WHERE lcm.cdcooper = pr_cdcooper 
                                    AND lcm.nrdconta = pr_nrdconta
                                    AND lcm.nrdocmto = pr_nrborder 
                                    AND lcm.dtmvtolt  = rw_craplcm.dtmvtolt
                                    AND lcm.cdhistor = PREJ0005.vr_cdhistordsct_recup_preju;
        EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel remover os registros na craplcm.';
          RAISE vr_exc_erro;
        END; 
      ELSE
        -- Realizar Lançamento do estorno na craplcm de Desconto de Títulos
        DSCT0003.pc_efetua_lanc_cc(pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_cdagenci => pr_cdagenci, 
                                   pr_cdbccxlt => rw_craplcm.cdbccxlt, 
                                   pr_nrdconta => pr_nrdconta, 
                                   pr_vllanmto => vr_vllanmto_tot,
                                   pr_cdhistor => PREJ0005.vr_cdhistordsct_est_rec_princi, 
                                   pr_cdcooper => pr_cdcooper, 
                                   pr_cdoperad => pr_cdoperad, 
                                   pr_nrborder => pr_nrborder, 
                                   pr_cdpactra => NULL, 
                                   pr_nrdocmto => rw_craplcm.nrdocmto, 
                                   pr_cdcritic => pr_cdcritic, 
                                   pr_dscritic => pr_dscritic);
                                   
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
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
        pr_dscritic := 'Erro geral na rotina DSCT0005.pc_realiza_estorno_prejuizo: ' || SQLERRM;
    
  END pc_realiza_estorno_prejuizo;

  PROCEDURE pc_realiza_estorno_cob(pr_cdcooper IN crapbdt.cdcooper%TYPE
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE
                                  ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                                  ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                                  ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE
                                  ,pr_nrdocmto IN craptdb.nrdocmto%TYPE
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                  -- OUT --
                                  ,pr_cdcritic OUT PLS_INTEGER
                                  ,pr_dscritic OUT VARCHAR2
                                  ) IS         --> Erros do processo
     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_realiza_estorno_cob
        Sistema  : 
        Sigla    : CRED
        Autor    : Lucas Lazari da Silva (GFT)
        Data     : 06/03/2019
        Frequencia: Sempre que for chamado
        Objetivo  : Realiza o estorno de pagamento de título descontado
      ---------------------------------------------------------------------------------------------------------------------*/
    
    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0) IS
     SELECT crapass.cdcooper
           ,crapass.nrdconta
           ,crapass.inpessoa
           ,crapass.vllimcre
           ,crapass.nmprimtl
           ,crapass.nrcpfcgc
           ,crapass.dtdemiss
           ,crapass.inadimpl
       FROM crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = DECODE(pr_nrdconta,0,crapass.nrdconta,pr_nrdconta);
    rw_crapass cr_crapass%ROWTYPE;
  
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                      ,pr_nrborder IN crapbdt.nrborder%type) IS
      SELECT rowid
            ,crapbdt.txmensal
            ,crapbdt.flverbor
            ,crapbdt.vltaxiof
            ,crapbdt.vltxmult
            ,crapbdt.vltxmora
            ,crapbdt.inprejuz
      FROM crapbdt
      WHERE crapbdt.cdcooper = pr_cdcooper
      AND   crapbdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;
  
    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN craptdb.nrdconta%TYPE
                     ,pr_nrborder IN craptdb.nrborder%TYPE
                     ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                     ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                     ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                     ,pr_nrdocmto IN craptdb.nrdocmto%TYPE) IS
      SELECT ROWID,
             craptdb.nrdocmto,
             craptdb.dtvencto,
             craptdb.insittit,
             craptdb.dtlibbdt,
             craptdb.nrtitulo,
             craptdb.vltitulo,
             craptdb.vlsldtit,
             craptdb.vliofcpl,
             craptdb.vlmtatit,
             craptdb.vlmratit,
             craptdb.vlpagiof,
             craptdb.vlpagmta,
             craptdb.vlpagmra,
             craptdb.vlsldtit + (craptdb.vliofcpl - craptdb.vlpagiof) + (craptdb.vlmtatit - craptdb.vlpagmta) + (craptdb.vlmratit - craptdb.vlpagmra) AS vltitulo_total,
             (craptdb.vliofcpl - craptdb.vlpagiof) AS vliofcpl_restante,
             (craptdb.vlmtatit - craptdb.vlpagmta) AS vlmtatit_restante,
             (craptdb.vlmratit - craptdb.vlpagmra) AS vlmratit_restante,
             (craptdb.vljura60 - craptdb.vlpgjm60) AS vljura60_restante
        FROM craptdb
       WHERE craptdb.cdcooper = pr_cdcooper
         AND craptdb.nrdconta = pr_nrdconta
         AND craptdb.nrborder = pr_nrborder
         AND craptdb.cdbandoc = pr_cdbandoc
         AND craptdb.nrdctabb = pr_nrdctabb
         AND craptdb.nrcnvcob = pr_nrcnvcob
         AND craptdb.nrdocmto = pr_nrdocmto;
    rw_craptdb cr_craptdb%ROWTYPE;
    
    -- Busca o lançamento do crédito do pagamento do título dentro da operação
    CURSOR cr_lanc_bordero_cred_ope (pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS --> Data do movimento atual
                                    
      SELECT lbd.rowid,
             lbd.vllanmto
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.cdcooper = pr_cdcooper
         AND lbd.nrdconta = pr_nrdconta
         AND lbd.nrborder = pr_nrborder
         AND lbd.cdbandoc = pr_cdbandoc
         AND lbd.nrdctabb = pr_nrdctabb
         AND lbd.nrcnvcob = pr_nrcnvcob
         AND lbd.nrdconta = pr_nrdconta
         AND lbd.nrdocmto = pr_nrdocmto
         AND lbd.cdhistor IN (DSCT0003.vr_cdhistordsct_pgtocompe, -- Compe
                              DSCT0003.vr_cdhistordsct_pgtocooper) -- Caixa/IB/TAA
         AND lbd.cdorigem IN (1,2,3,4); -- Ayllos/IB/TAA/Caixa On-Line;
         
    rw_lanc_bordero_cred_ope cr_lanc_bordero_cred_ope%ROWTYPE;
    
    -- Busca todos os lançamentos da operação que foram gerados pelo pagamento do título
    CURSOR cr_lanc_bordero_cob (pr_dtmvtolt IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                               ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                               )IS
      SELECT lbd.rowid,
             lbd.vllanmto
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.cdcooper = pr_cdcooper
         AND lbd.nrdconta = pr_nrdconta
         AND lbd.nrborder = pr_nrborder
         AND lbd.cdbandoc = pr_cdbandoc
         AND lbd.nrdctabb = pr_nrdctabb
         AND lbd.nrcnvcob = pr_nrcnvcob
         AND lbd.nrdconta = pr_nrdconta
         AND lbd.nrdocmto = pr_nrdocmto
         AND lbd.cdhistor = pr_cdhistor
         AND lbd.cdorigem IN (1,2,3,4); -- Ayllos/IB/TAA/Caixa On-Line;
         
    rw_lanc_bordero_cob cr_lanc_bordero_cob%ROWTYPE;
    
    -- Busca todos os lançamentos da operação que foram gerados pelo pagamento através da conta do cooperado
    CURSOR cr_lanc_bordero_cc (pr_dtmvtolt IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                              ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                              )IS
      SELECT lbd.rowid,
             lbd.vllanmto
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.cdcooper = pr_cdcooper
         AND lbd.nrdconta = pr_nrdconta
         AND lbd.nrborder = pr_nrborder
         AND lbd.cdbandoc = pr_cdbandoc
         AND lbd.nrdctabb = pr_nrdctabb
         AND lbd.nrcnvcob = pr_nrcnvcob
         AND lbd.nrdconta = pr_nrdconta
         AND lbd.nrdocmto = pr_nrdocmto
         AND lbd.cdhistor = pr_cdhistor
         AND lbd.cdorigem IN (7); -- Raspada
         
    rw_lanc_bordero_cc cr_lanc_bordero_cc%ROWTYPE;
    
    CURSOR cr_craplcm (pr_dtmvtolt IN craplcm.dtmvtolt%TYPE 
                      ,pr_cdagenci IN craplcm.cdagenci%TYPE
                      ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                      ,pr_cdhistor IN craplcm.cdhistor%TYPE
                      ) IS
      SELECT craplcm.rowid
            ,craplcm.vllanmto
      FROM craplcm craplcm
      WHERE craplcm.cdcooper = pr_cdcooper
      AND   craplcm.nrdconta = pr_nrdconta
      AND   craplcm.dtmvtolt = pr_dtmvtolt
      AND   craplcm.cdagenci = pr_cdagenci
      AND   craplcm.cdbccxlt = pr_cdbccxlt
      AND   craplcm.cdhistor = pr_cdhistor
      AND   craplcm.nrdocmto = pr_nrdocmto;

    rw_craplcm cr_craplcm%ROWTYPE;
    
    CURSOR cr_craplcm_tarifa (pr_dtmvtolt IN craplcm.dtmvtolt%TYPE 
                             ,pr_cdhistor IN craplcm.cdhistor%TYPE) IS
              SELECT craplcm.rowid
                    ,craplcm.vllanmto
              FROM craplcm craplcm
              WHERE craplcm.cdcooper = pr_cdcooper
              AND   craplcm.dtmvtolt = pr_dtmvtolt
              AND   craplcm.nrdconta = pr_nrdconta
              AND   craplcm.cdagenci = 1
              AND   craplcm.cdbccxlt = 100
              AND   craplcm.nrdolote = 8452
              AND   craplcm.nrdctabb = pr_nrdconta
              AND   craplcm.cdhistor = pr_cdhistor
              AND   craplcm.cdpesqbb = pr_nrdocmto;

    rw_craplcm_tarifa cr_craplcm_tarifa%ROWTYPE;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    vr_vliofcpl craptdb.vliofcpl%TYPE;
    vr_vlmtatit craptdb.vlmtatit%TYPE;
    vr_vlmratit craptdb.vlmratit%TYPE;
    vr_vlpagtit craptdb.vlsldtit%TYPE;
    vr_vlpgtocc craptdb.vlsldtit%TYPE;
    vr_vlpagmaior craptdb.vlsldtit%TYPE;
    
    TYPE typ_dados_tarifa IS RECORD
      (cdfvlcop crapcop.cdcooper%TYPE
      ,cdhistor craphis.cdhistor%TYPE
      ,vlrtarif NUMBER
      ,vltottar NUMBER);
    
    
    vr_cdbattar     VARCHAR2(1000);
    vr_cdhisest     INTEGER;
    vr_dtdivulg     DATE;
    vr_dtvigenc     DATE;
    vr_cdestorno NUMBER;
    
    
    vr_dados_tarifa typ_dados_tarifa;
    vr_tab_erro GENE0001.typ_tab_erro; --Tabela de erros
    
    vr_tab_dados_dsctit    cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Registrada
    vr_tab_cecred_dsctit   cecred.dsct0002.typ_tab_cecred_dsctit;
    
    vr_exc_erro  EXCEPTION;

    
  BEGIN
    
    -- Valida a existência do título
    OPEN cr_craptdb (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrborder => pr_nrborder
                    ,pr_cdbandoc => pr_cdbandoc
                    ,pr_nrdctabb => pr_nrdctabb
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_nrdocmto => pr_nrdocmto);
    FETCH cr_craptdb INTO rw_craptdb;

    IF cr_craptdb%NOTFOUND THEN
      CLOSE cr_craptdb;
      vr_cdcritic := 1108;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craptdb;

    -- Valida existência do borderô do respectivo título
    OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                    ,pr_nrborder => pr_nrborder);
    FETCH cr_crapbdt INTO rw_crapbdt;

    IF cr_crapbdt%NOTFOUND THEN
      vr_cdcritic := 1166; --Bordero nao encontrado. Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      CLOSE cr_crapbdt;
    RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapbdt;
    
    -- 1) Busca o valor do histórico de crédito do boleto dentro da operação
    OPEN cr_lanc_bordero_cred_ope (pr_dtmvtolt => pr_dtmvtolt);
    FETCH cr_lanc_bordero_cred_ope INTO rw_lanc_bordero_cred_ope;
    
    IF cr_lanc_bordero_cred_ope%FOUND THEN
      -- Atribui valor do IOF complementar para atualizar os saldos no final do processo
      vr_vlpagtit := rw_lanc_bordero_cred_ope.vllanmto;
      
      -- Exclui o registro da tabela de lançamentos do borderô
      DELETE
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.rowid = rw_lanc_bordero_cred_ope.rowid;
       
    END IF;                          
    CLOSE cr_lanc_bordero_cred_ope;
     
    -- 2) Busca o valor do histórico de IOF lançado na operação
    OPEN cr_lanc_bordero_cob (pr_dtmvtolt => pr_dtmvtolt,
                         	    pr_cdhistor => DSCT0003.vr_cdhistordsct_iofcompleoper);
    FETCH cr_lanc_bordero_cob INTO rw_lanc_bordero_cob;
    
    IF cr_lanc_bordero_cob%FOUND THEN
      -- Atribui valor do IOF complementar para atualizar os saldos no final do processo
      vr_vliofcpl := rw_lanc_bordero_cob.vllanmto;
      
      -- Exclui o registro da tabela de lançamentos do borderô
      DELETE
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.rowid = rw_lanc_bordero_cob.rowid;
       
    END IF;                          
    CLOSE cr_lanc_bordero_cob;   
    
    
    -- 3) Busca o valor de apropriação de multa lançado na operação
    OPEN cr_lanc_bordero_cob (pr_dtmvtolt => pr_dtmvtolt,
                         	    pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmta);
    FETCH cr_lanc_bordero_cob INTO rw_lanc_bordero_cob;
    
    IF cr_lanc_bordero_cob%FOUND THEN
      -- Atribui valor da multa para atualizar os saldos no final do processo
      vr_vlmtatit := rw_lanc_bordero_cob.vllanmto;
      
      -- Exclui o registro da tabela de lançamentos do borderô
      DELETE
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.rowid = rw_lanc_bordero_cob.rowid;
       
    END IF;                          
    CLOSE cr_lanc_bordero_cob; 
    
    -- 4) Busca o valor de apropriação de juros lançado na operação
    OPEN cr_lanc_bordero_cob (pr_dtmvtolt => pr_dtmvtolt,
                         	    pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra);
    FETCH cr_lanc_bordero_cob INTO rw_lanc_bordero_cob;
    
    IF cr_lanc_bordero_cob%FOUND THEN
      -- Atribui valor dos juros de mora para atualizar os saldos no final do processo
      vr_vlmratit := rw_lanc_bordero_cob.vllanmto;
      
      -- Exclui o registro da tabela de lançamentos do borderô
      DELETE
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.rowid = rw_lanc_bordero_cob.rowid;
       
    END IF;                          
    CLOSE cr_lanc_bordero_cob; 
    
    -- 5) Busca o valor de ajuste de pagamento a maior
    OPEN cr_lanc_bordero_cob (pr_dtmvtolt => pr_dtmvtolt,
                         	    pr_cdhistor => DSCT0003.vr_cdhistordsct_deboppagmaior);
    FETCH cr_lanc_bordero_cob INTO rw_lanc_bordero_cob;
    
    IF cr_lanc_bordero_cob%FOUND THEN
      
      vr_vlpagmaior := rw_lanc_bordero_cob.vllanmto;
    
      -- Exclui o registro da tabela de lançamentos do borderô
      DELETE
        FROM tbdsct_lancamento_bordero lbd
       WHERE lbd.rowid = rw_lanc_bordero_cob.rowid;
       
    END IF;                          
    CLOSE cr_lanc_bordero_cob;
    
    -- 6) Busca o valor de crédito na conta do cooperado no caso de pagamento a maior
    OPEN cr_craplcm (pr_dtmvtolt => pr_dtmvtolt
                    ,pr_cdagenci => 1
                    ,pr_cdbccxlt => 100
                    ,pr_cdhistor => DSCT0003.vr_cdhistordsct_credpagmaior
                    );
    FETCH cr_craplcm INTO rw_craplcm;
    
    IF cr_craplcm%FOUND THEN
      
      -- Exclui o registro da tabela de lançamentos do borderô
      DELETE
        FROM craplcm lcm
       WHERE lcm.rowid = rw_craplcm.rowid;
       
    END IF;                          
    CLOSE cr_craplcm;
    
    -- 7) Busca o valor de crédito na conta do cooperado no caso de devolução por pagamento antecipado
    OPEN cr_craplcm (pr_dtmvtolt => pr_dtmvtolt
                    ,pr_cdagenci => 1
                    ,pr_cdbccxlt => 100
                    ,pr_cdhistor => DSCT0003.vr_cdhistordsct_rendapgtoant
                    );
    FETCH cr_craplcm INTO rw_craplcm;
    
    IF cr_craplcm%FOUND THEN
      
      -- Exclui o registro da tabela de lançamentos do borderô
      DELETE
        FROM craplcm lcm
       WHERE lcm.rowid = rw_craplcm.rowid;
       
    END IF;                          
    CLOSE cr_craplcm;
    
    -- busca os dados do associado/cooperado para só então encontrar seus dados na tabela de parâmetros
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;
    
    -- Busca os Parâmetros para o Cooperado e Cobrança Com Registro
    dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                        NULL, --Agencia de operação
                                        NULL, --Número do caixa
                                        NULL, --Operador
                                        NULL, -- Data da Movimentação
                                        NULL, --Identificação de origem
                                        1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                        rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                        vr_tab_dados_dsctit,
                                        vr_tab_cecred_dsctit,
                                        vr_cdcritic,
                                        vr_dscritic);
    
    vr_vlpgtocc := 0;                                    
    -- Se o estorno ocorreu dentro do período de carência, devemos remover qualquer pagamento via raspada que possa ter ocorrido
    IF pr_dtmvtolt > rw_craptdb.dtvencto AND pr_dtmvtolt < (rw_craptdb.dtvencto + vr_tab_dados_dsctit(1).cardbtit_c) THEN 
      
      -- Busca todas as raspadas que podem ter ocorrido entre o pagamento e o estorno do mesmo
      
      -- Lançamentos na operação
      FOR rw_lanc_bordero_cc IN cr_lanc_bordero_cc (pr_dtmvtolt => pr_dtmvtolt,
                                                    pr_cdhistor => DSCT0003.vr_cdhistordsct_pgtoopc) LOOP
      
        -- Acumula os valores                                              
        vr_vlpgtocc := vr_vlpgtocc + rw_lanc_bordero_cc.vllanmto;
        
        -- Exclui o registro da tabela de lançamentos do borderô
        DELETE
          FROM tbdsct_lancamento_bordero lbd
         WHERE lbd.rowid = rw_lanc_bordero_cc.rowid;
        
      
      END LOOP;
      
      -- Lançamentos na conta-corrente do cooperado
      FOR rw_craplcm IN cr_craplcm (pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdagenci => 1
                                   ,pr_cdbccxlt => 100
                                   ,pr_cdhistor => DSCT0003.vr_cdhistordsct_pgtocc
                                   ) LOOP
      
        -- Exclui o registro da tabela de lançamentos do borderô
        DELETE
          FROM craplcm lcm
         WHERE lcm.rowid = rw_craplcm.rowid;
      
      END LOOP;
    END IF;
    
    -- Se a operação foi baixada com o pagamento do títulos, devemos estornar a tarifa cobrada na conta corrente do cooperado
    IF rw_craptdb.insittit = 2 THEN 
    
      -- Define qual tipo de tarifa a ser cobrada
      IF rw_crapass.inpessoa = 1 THEN
        vr_cdbattar:= 'DSTTITCRPF';
      ELSE
        vr_cdbattar:= 'DSTTITCRPJ';
      END IF;
      
      /*  Busca valor da tarifa sem registro*/
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper               --Codigo Cooperativa
                                            ,pr_cdbattar  => vr_cdbattar               --Codigo Tarifa
                                            ,pr_vllanmto  => 1                         --Valor Lancamento
                                            ,pr_cdprogra  => NULL                      --Codigo Programa
                                            ,pr_cdhistor  => vr_dados_tarifa.cdhistor  --Codigo Historico
                                            ,pr_cdhisest  => vr_cdhisest               --Historico Estorno
                                            ,pr_vltarifa  => vr_dados_tarifa.vlrtarif  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg               --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc               --Data Vigencia
                                            ,pr_cdfvlcop  => vr_dados_tarifa.cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic               --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic               --Descricao Critica
                                            ,pr_tab_erro  => vr_tab_erro);             --Tabela erros

      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := vr_dscritic||' pr_nrdconta:' || pr_nrdconta || ' ,pr_nrborder:' || pr_nrborder||',';
        RAISE vr_exc_erro;
      END IF;
      
      -- Remove o lançamento da conta-corrente do cooperado
      OPEN cr_craplcm_tarifa (pr_dtmvtolt => pr_dtmvtolt
                             ,pr_cdhistor => vr_dados_tarifa.cdhistor);
      FETCH cr_craplcm_tarifa INTO rw_craplcm_tarifa;
      
      IF cr_craplcm_tarifa%FOUND THEN
        
        -- Exclui o registro da tabela de lançamentos do borderô
        DELETE
          FROM craplcm lcm
         WHERE lcm.rowid = rw_craplcm_tarifa.rowid;
         
      END IF;                          
      CLOSE cr_craplcm_tarifa;
      
    END IF;  
    
    -- Atualiza os saldos das tabela
    UPDATE craptdb tdb
       SET tdb.vlsldtit = tdb.vlsldtit + NVL(vr_vlpgtocc,0) + (NVL(vr_vlpagtit,0) - NVL(vr_vliofcpl,0) - NVL(vr_vlmratit,0) - NVL(vr_vlmtatit,0) - NVL(vr_vlpagmaior,0)),
           tdb.vlpagmta = tdb.vlpagmta - NVL(vr_vlmtatit,0),
           tdb.vlpagmra = tdb.vlpagmra - NVL(vr_vlmratit,0),
           tdb.vlpagiof = tdb.vlpagiof - NVL(vr_vliofcpl,0),
           tdb.dtdebito = NULL,
           tdb.dtdpagto = NULL,
           tdb.insittit = 4
     WHERE tdb.rowid = rw_craptdb.rowid;
    
    -- Atualiza a situação do borderô
    UPDATE crapbdt bdt
       SET bdt.insitbdt = 3
     WHERE bdt.rowid = rw_crapbdt.rowid;
       
    -- Realiza o registro do histórico de estorno
    pc_insere_estorno(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrborder => pr_nrborder
                     ,pr_cdoperad => '1'
                     ,pr_cdagenci => 1
                     ,pr_dtmvtolt => pr_dtmvtolt
                     ,pr_justific => 'Estorno de Pagamento de Título'
                     -- OUT --
                     ,pr_cdestorno => vr_cdestorno
                     ,pr_cdcritic  => vr_cdcritic
                     ,pr_dscritic  => vr_dscritic
                     );
                     
    IF TRIM(pr_dscritic) IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := pr_dscritic;
      RAISE vr_exc_erro;
    END IF;   
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina DSCT0005.pc_realiza_estorno_cob: ' || SQLERRM;
  END pc_realiza_estorno_cob; 
END DSCT0005;
/
