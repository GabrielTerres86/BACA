CREATE OR REPLACE PACKAGE cecred.tela_cadcat AS

  PROCEDURE pc_busca_categoria(pr_cdcatego IN crapcat.cdcatego%TYPE --> Código da categoria
                               
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_insere_categoria(pr_cdcatego crapcat.cdcatego%TYPE --> Código da categoria
                               ,pr_cdsubgru crapcat.cdsubgru%TYPE --> Código do sub-grupo de produtos
                               ,pr_cdtipcat crapcat.cdtipcat%TYPE --> Código do tipo de categoria
                               ,pr_dscatego crapcat.dscatego%TYPE --> Descrição da categoria
                               ,pr_fldesman crapcat.fldesman%TYPE --> Flag para permissao de desconto manual as tarifas da categoria
                               ,pr_flrecipr crapcat.flrecipr%TYPE --> Flag de vinculacao das tarifas da categoria com reciprocidade
                               ,pr_flcatcee crapcat.flcatcee%TYPE --> Flag de categoria de Cooperativa Emite e Expede (Cobranca)
                               ,pr_flcatcoo crapcat.flcatcoo%TYPE --> Flag de categoria de Cooperado Emite e Expede (Cobranca)
                                
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_atualiza_categoria(pr_cdcatego crapcat.cdcatego%TYPE --> Código da categoria
                                 ,pr_cdsubgru crapcat.cdsubgru%TYPE --> Código do sub-grupo de produtos
                                 ,pr_cdtipcat crapcat.cdtipcat%TYPE --> Código do tipo de categoria
                                 ,pr_dscatego crapcat.dscatego%TYPE --> Descrição da categoria
                                 ,pr_fldesman crapcat.fldesman%TYPE --> Flag para permissao de desconto manual as tarifas da categoria
                                 ,pr_flrecipr crapcat.flrecipr%TYPE --> Flag de vinculacao das tarifas da categoria com reciprocidade
                                 ,pr_flcatcee crapcat.flcatcee%TYPE --> Flag de categoria de Cooperativa Emite e Expede (Cobranca)
                                 ,pr_flcatcoo crapcat.flcatcoo%TYPE --> Flag de categoria de Cooperado Emite e Expede (Cobranca)
                                  
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_exclui_categoria(pr_cdcatego crapcat.cdcatego%TYPE --> Código da categoria
                                
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

END tela_cadcat;
/
CREATE OR REPLACE PACKAGE BODY cecred.tela_cadcat AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CADCAT
  --    Autor   : Dionathan
  --    Data    : Janeiro/2016                   Ultima Atualizacao: 01/04/2016
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela CADCAT
  --
  --    Alteracoes: 01/04/2016 - Adição de logs
  --    
  ---------------------------------------------------------------------------------------------------------------
  
  CURSOR cr_crapcat(pr_cdcatego crapcat.cdcatego%TYPE) IS
  SELECT *
    FROM crapcat cat
   WHERE cat.cdcatego = pr_cdcatego;
  
  PROCEDURE pc_busca_categoria(pr_cdcatego IN crapcat.cdcatego%TYPE --> Código da categoria
                              
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_categoria
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Dionathan
    Data    : Fevereiro/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as categorias (tabela CRAPCAT)
    
    Alteracoes: 
    ............................................................................. */
  
    --Cursor para pegar as categorias
    CURSOR cr_crapcat IS
      SELECT cat.cdcatego
            ,cat.dscatego
            ,tic.cdtipcat
            ,tic.dstipcat
            ,sgr.cdsubgru
            ,sgr.dssubgru
            ,gru.cddgrupo
            ,gru.dsdgrupo
            ,cat.fldesman
            ,cat.flrecipr
            ,cat.flcatcee
            ,cat.flcatcoo
        FROM crapcat cat
            ,craptic tic
            ,crapsgr sgr
            ,crapgru gru
       WHERE cat.cdtipcat = tic.cdtipcat(+)
         AND cat.cdsubgru = sgr.cdsubgru(+)
         AND sgr.cddgrupo = gru.cddgrupo(+)
         AND cat.cdcatego = pr_cdcatego;
    rw_crapcat cr_crapcat%ROWTYPE;
  
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    pr_des_erro := 'NOK';
    vr_tab_erro.delete;
  
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Busca os dados da categoria
    OPEN cr_crapcat;
    FETCH cr_crapcat
      INTO rw_crapcat;
    CLOSE cr_crapcat;
    
    -- Se nao encontrar categoria
    IF rw_crapcat.cdcatego IS NULL THEN
      -- Montar mensagem de critica
      vr_dscritic := 'Categoria inexistente!';
      --Campo com critica
      pr_nmdcampo := 'cdcatego';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    -- Se nao encontrar tipo de categoria
    IF rw_crapcat.cdtipcat IS NULL THEN
      -- Montar mensagem de critica
      vr_dscritic := 'Tipo de Categoria inexistente!';
      --Campo com critica
      pr_nmdcampo := 'cdtipcat';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
        
    -- Monta documento XML de RETORNO
    dbms_lob.createtemporary(vr_clobxml, TRUE);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);   
    
    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                             '<?xml version="1.0" encoding="UTF-8"?><Root><categorias>');
    --Escrever no XML
    gene0002.pc_escreve_xml(vr_clobxml
                           ,vr_dstexto
                           ,'<categoria>' ||
                              '<dscatego>' || rw_crapcat.dscatego || '</dscatego>' ||
                              '<cddgrupo>' || rw_crapcat.cddgrupo || '</cddgrupo>' ||
                              '<dsdgrupo>' || rw_crapcat.dsdgrupo || '</dsdgrupo>' ||
                              '<cdsubgru>' || rw_crapcat.cdsubgru || '</cdsubgru>' ||
                              '<dssubgru>' || rw_crapcat.dssubgru || '</dssubgru>' ||
                              '<dstipcat>' || rw_crapcat.dstipcat || '</dstipcat>' ||
                              '<cdtipcat>' || rw_crapcat.cdtipcat || '</cdtipcat>' ||
                              '<fldesman>' || rw_crapcat.fldesman || '</fldesman>' ||
                              '<flrecipr>' || rw_crapcat.flrecipr || '</flrecipr>' ||
                              '<flcatcee>' || rw_crapcat.flcatcee || '</flcatcee>' ||
                              '<flcatcoo>' || rw_crapcat.flcatcoo || '</flcatcoo>' ||
                            '</categoria>');
    
    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</categorias></Root>',TRUE);
                             
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clobxml);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clobxml);
                             
  
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADCAT.pc_busca_categoria --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_busca_categoria;

  PROCEDURE pc_insere_categoria(pr_cdcatego crapcat.cdcatego%TYPE --> Código da categoria
                               ,pr_cdsubgru crapcat.cdsubgru%TYPE --> Código do sub-grupo de produtos
                               ,pr_cdtipcat crapcat.cdtipcat%TYPE --> Código do tipo de categoria
                               ,pr_dscatego crapcat.dscatego%TYPE --> Descrição da categoria
                               ,pr_fldesman crapcat.fldesman%TYPE --> Flag para permissao de desconto manual as tarifas da categoria
                               ,pr_flrecipr crapcat.flrecipr%TYPE --> Flag de vinculacao das tarifas da categoria com reciprocidade
                               ,pr_flcatcee crapcat.flcatcee%TYPE --> Flag de categoria de Cooperativa Emite e Expede (Cobranca)
                               ,pr_flcatcoo crapcat.flcatcoo%TYPE --> Flag de categoria de Cooperado Emite e Expede (Cobranca)
                               
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_insere_categoria
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Dionathan
    Data    : Fevereiro/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir categoria (tabela CRAPCAT)
    
    Alteracoes:
    ............................................................................. */
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variaveis auxiliares
    vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
	  vr_dstransa VARCHAR2(1000) := 'Inclusao de Categoria';
	  vr_logrowid ROWID;
    
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    pr_des_erro := 'NOK';
    vr_tab_erro.delete;
  
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
		-- Alimenta descrição da origem
		vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));
    
    BEGIN
    
    INSERT INTO crapcat cat
      (cat.cdcatego
      ,cat.dscatego
      ,cat.cdsubgru
      ,cat.cdtipcat
      ,cat.fldesman
      ,cat.flrecipr
      ,cat.flcatcee
      ,cat.flcatcoo)
    VALUES
      (pr_cdcatego
      ,pr_dscatego
      ,pr_cdsubgru
      ,pr_cdtipcat
      ,NVL(pr_fldesman,0)
      ,NVL(pr_flrecipr,0)
      ,NVL(pr_flcatcee,0)
      ,NVL(pr_flcatcoo,0));
    EXCEPTION
      WHEN dup_val_on_index THEN
         vr_dscritic := 'Registro ja existente!';
         RAISE vr_exc_erro;
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir registro!';
         RAISE vr_exc_erro;
    END;
    
    -- Gera log na lgm
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => '',
                         pr_dsorigem => vr_dsorigem,
                         pr_dstransa => vr_dstransa,
                         pr_dttransa => TRUNC(SYSDATE),
                         pr_flgtrans => 1,
                         pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                         pr_idseqttl => 0,
                         pr_nmdatela => vr_nmdatela,
                         pr_nrdconta => 0,
                         pr_nrdrowid => vr_logrowid);
                                                      
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Codigo da Categoria'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_cdcatego);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Codigo do Sub-grupo'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_cdsubgru);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Codigo do Tipo de Categoria'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_cdtipcat);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Descricao'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_dscatego);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Permite Desconto Manual'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_fldesman);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Vinculado a Reciprocidade'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_flrecipr);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Coop. Emite e Expede'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_flcatcee);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Cooperado Emite e Expede'
                             ,pr_dsdadant => ''
                             ,pr_dsdadatu => pr_flcatcoo);
    
    COMMIT;
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADCAT.pc_insere_categoria --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_insere_categoria;

  PROCEDURE pc_atualiza_categoria(pr_cdcatego crapcat.cdcatego%TYPE --> Código da categoria
                                 ,pr_cdsubgru crapcat.cdsubgru%TYPE --> Código do sub-grupo de produtos
                                 ,pr_cdtipcat crapcat.cdtipcat%TYPE --> Código do tipo de categoria
                                 ,pr_dscatego crapcat.dscatego%TYPE --> Descrição da categoria
                                 ,pr_fldesman crapcat.fldesman%TYPE --> Flag para permissao de desconto manual as tarifas da categoria
                                 ,pr_flrecipr crapcat.flrecipr%TYPE --> Flag de vinculacao das tarifas da categoria com reciprocidade
                                 ,pr_flcatcee crapcat.flcatcee%TYPE --> Flag de categoria de Cooperativa Emite e Expede (Cobranca)
                                 ,pr_flcatcoo crapcat.flcatcoo%TYPE --> Flag de categoria de Cooperado Emite e Expede (Cobranca)
                               
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_atualiza_categoria
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Dionathan
    Data    : Fevereiro/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir categoria (tabela CRAPCAT)
    
    Alteracoes:
    ............................................................................. */
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variaveis auxiliares
    vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
	  vr_dstransa VARCHAR2(1000) := 'Alteração de Categoria';
    rw_crapcat cr_crapcat%ROWTYPE;
	  vr_logrowid ROWID;
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    pr_des_erro := 'NOK';
    vr_tab_erro.delete;
  
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
		-- Alimenta descrição da origem
		vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));
    
    -- Abre indicador 
    OPEN cr_crapcat(pr_cdcatego);
    FETCH cr_crapcat INTO rw_crapcat;
		
    -- Se não existe
    IF cr_crapcat%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapcat;
        -- Gera crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Categoria não encontrada!';
        -- Levanta exceção
        RAISE vr_exc_erro;
    END IF;

    -- Fecha cursor
    CLOSE cr_crapcat;
    
    BEGIN
    
    UPDATE crapcat cat
       SET cat.dscatego = pr_dscatego
          ,cat.cdsubgru = pr_cdsubgru
          ,cat.cdtipcat = pr_cdtipcat
          ,cat.fldesman = NVL(pr_fldesman,0)
          ,cat.flrecipr = NVL(pr_flrecipr,0)
          ,cat.flcatcee = NVL(pr_flcatcee,0)
          ,cat.flcatcoo = NVL(pr_flcatcoo,0)
     WHERE cat.cdcatego = pr_cdcatego;
    
    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro!';
         RAISE vr_exc_erro;
    END;
    
    IF SQL%ROWCOUNT = 0 THEN
     vr_dscritic := 'Registro não encontrado!';
     RAISE vr_exc_erro;
    END IF;
    
    -- Gera log na lgm
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => '',
                         pr_dsorigem => vr_dsorigem,
                         pr_dstransa => vr_dstransa,
                         pr_dttransa => TRUNC(SYSDATE),
                         pr_flgtrans => 1,
                         pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                         pr_idseqttl => 0,
                         pr_nmdatela => vr_nmdatela,
                         pr_nrdconta => 0,
                         pr_nrdrowid => vr_logrowid);
                         
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Codigo da Categoria'
                             ,pr_dsdadant => rw_crapcat.cdcatego
                             ,pr_dsdadatu => pr_cdcatego);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Codigo do Sub-grupo'
                             ,pr_dsdadant => rw_crapcat.cdsubgru
                             ,pr_dsdadatu => pr_cdsubgru);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Codigo do Tipo de Categoria'
                             ,pr_dsdadant => rw_crapcat.cdtipcat
                             ,pr_dsdadatu => pr_cdtipcat);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Descricao'
                             ,pr_dsdadant => rw_crapcat.dscatego
                             ,pr_dsdadatu => pr_dscatego);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Permite Desconto Manual'
                             ,pr_dsdadant => rw_crapcat.fldesman
                             ,pr_dsdadatu => pr_fldesman);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Vinculado a Reciprocidade'
                             ,pr_dsdadant => rw_crapcat.flrecipr
                             ,pr_dsdadatu => pr_flrecipr);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Coop. Emite e Expede'
                             ,pr_dsdadant => rw_crapcat.flcatcee
                             ,pr_dsdadatu => pr_flcatcee);
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Cooperado Emite e Expede'
                             ,pr_dsdadant => rw_crapcat.flcatcoo
                             ,pr_dsdadatu => pr_flcatcoo);
    
    COMMIT;
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADCAT.pc_atualiza_categoria --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_atualiza_categoria;

  PROCEDURE pc_exclui_categoria(pr_cdcatego crapcat.cdcatego%TYPE --> Código da categoria
                               
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_exclui_categoria
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Dionathan
    Data    : Fevereiro/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir categoria (tabela CRAPCAT)
    
    Alteracoes:
    ............................................................................. */
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variaveis auxiliares
    vr_dsorigem VARCHAR2(1000); -- Descrição da origem do ambiente
	  vr_dstransa VARCHAR2(1000) := 'Exclusão de Categoria';
    rw_crapcat cr_crapcat%ROWTYPE;
	  vr_logrowid ROWID;
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    pr_des_erro := 'NOK';
    vr_tab_erro.delete;
  
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
		-- Alimenta descrição da origem
		vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));
    
    -- Abre indicador 
    OPEN cr_crapcat(pr_cdcatego);
    FETCH cr_crapcat INTO rw_crapcat;
		
    -- Se não existe
    IF cr_crapcat%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapcat;
        -- Gera crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Categoria não encontrada!';
        -- Levanta exceção
        RAISE vr_exc_erro;
    END IF;

    -- Fecha cursor
    CLOSE cr_crapcat;
    
    BEGIN
    
    DELETE
      FROM crapcat cat
     WHERE cat.cdcatego = pr_cdcatego;
    
    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao excluir registro!';
         RAISE vr_exc_erro;
    END;
    
    IF SQL%ROWCOUNT = 0 THEN
     vr_dscritic := 'Registro não encontrado!';
     RAISE vr_exc_erro;
    END IF;
    
    -- Gera log na lgm
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => '',
                         pr_dsorigem => vr_dsorigem,
                         pr_dstransa => vr_dstransa,
                         pr_dttransa => TRUNC(SYSDATE),
                         pr_flgtrans => 1,
                         pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSS')),
                         pr_idseqttl => 0,
                         pr_nmdatela => vr_nmdatela,
                         pr_nrdconta => 0,
                         pr_nrdrowid => vr_logrowid);
                         
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Codigo da Categoria'
                             ,pr_dsdadant => rw_crapcat.cdcatego
                             ,pr_dsdadatu => '');
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Codigo do Sub-grupo'
                             ,pr_dsdadant => rw_crapcat.cdsubgru
                             ,pr_dsdadatu => '');
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Codigo do Tipo de Categoria'
                             ,pr_dsdadant => rw_crapcat.cdtipcat
                             ,pr_dsdadatu => '');
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Descricao'
                             ,pr_dsdadant => rw_crapcat.dscatego
                             ,pr_dsdadatu => '');
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Permite Desconto Manual'
                             ,pr_dsdadant => rw_crapcat.fldesman
                             ,pr_dsdadatu => '');
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Vinculado a Reciprocidade'
                             ,pr_dsdadant => rw_crapcat.flrecipr
                             ,pr_dsdadatu => '');
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Coop. Emite e Expede'
                             ,pr_dsdadant => rw_crapcat.flcatcee
                             ,pr_dsdadatu => '');
                             
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_logrowid
                             ,pr_nmdcampo => 'Cooperado Emite e Expede'
                             ,pr_dsdadant => rw_crapcat.flcatcoo
                             ,pr_dsdadatu => '');
    
    COMMIT;
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADCAT.pc_exclui_categoria --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_exclui_categoria;

END tela_cadcat;
/
