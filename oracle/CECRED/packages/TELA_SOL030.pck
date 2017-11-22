CREATE OR REPLACE PACKAGE CECRED.TELA_SOL030 AS
  
  -- Busca calculo sobras
  PROCEDURE pc_busca_calculo_sobras (pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
  -- Busca data informativo
  PROCEDURE pc_busca_data_informativo (pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
  
  -- Busca calculo sobras
  PROCEDURE pc_altera_calculo_sobras (pr_ininccmi  IN VARCHAR2
                                     ,pr_increret  IN VARCHAR2
                                     ,pr_txretorn  IN VARCHAR2
                                     ,pr_txjurcap  IN VARCHAR2
                                     ,pr_txjurapl  IN VARCHAR2
                                     ,pr_txjursdm  IN VARCHAR2
                                     ,pr_txjurtar  IN VARCHAR2
                                     ,pr_txreauat  IN VARCHAR2
                                     ,pr_inpredef  IN VARCHAR2
                                     ,pr_indeschq  IN VARCHAR2
                                     ,pr_indemiti  IN VARCHAR2
                                     ,pr_indestit  IN VARCHAR2
                                     ,pr_unsobdep  IN VARCHAR2
                                     ,pr_dssopfco  IN VARCHAR2
                                     ,pr_dssopjco  IN VARCHAR2
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
    
  -- Busca data informativo
  PROCEDURE pc_altera_data_informativo (pr_dtapinco  IN VARCHAR2           --> Data informativo
                                       ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
   
  -- Procedure para calculo e credito do retorno de sobras e juros sobre o capital. Emissao do relatorio CRRL043
  PROCEDURE pc_cal_retorno_sobras_web(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
  
END TELA_SOL030;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_SOL030 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_SOL030
  --    Autor   : lucas Lombardi
  --    Data    : Marco/2016                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela SOL030 (Ayllos Web)
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
  
  -- Busca calculo sobras
  PROCEDURE pc_busca_calculo_sobras (pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_busca_calculo_sobras
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Agosto/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cargas manuais do pre aprovado
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Busca Carga Solicitada/Executando
      CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT SUBSTR(dstextab,1,1)                                        ininccmi
              ,SUBSTR(dstextab,3,1)                                        increret
              ,to_char(to_number(SUBSTR(dstextab,5,12)),'FM990D00000000')  txretorn   
              ,to_char(to_number(SUBSTR(dstextab,20,13)),'FM990D00000000') txjurcap
              ,to_char(to_number(SUBSTR(dstextab,33,12)),'FM990D00000000') txjurapl
              ,to_char(to_number(SUBSTR(dstextab,54,12)),'FM990D00000000') txjursdm
              ,to_char(to_number(SUBSTR(dstextab,78,12)),'FM990D00000000') txjurtar
              ,to_char(to_number(SUBSTR(dstextab,91,12)),'FM990D00000000') txreauat
              ,SUBSTR(dstextab,18,1)                                       inpredef
              ,SUBSTR(dstextab,46,1)                                       indeschq
              ,SUBSTR(dstextab,50,1)                                       indemiti
              ,SUBSTR(dstextab,52,1)                                       indestit
              ,SUBSTR(dstextab,118,1)                                      unsobdep
              ,to_char(to_number(SUBSTR(dstextab,104,6)),'FM990D00')       dssopfco
              ,to_char(to_number(SUBSTR(dstextab,111,6)),'FM990D00')       dssopjco
          FROM craptab
         WHERE cdcooper = pr_cdcooper
           AND nmsistem = 'CRED'
           AND tptabela = 'GENERI'
           AND cdempres = 00
           AND cdacesso = 'EXEICMIRET'
           AND tpregist = 001;
      rw_craptab cr_craptab%ROWTYPE;
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis auxiliares
      vr_flgfound  BOOLEAN;
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
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
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        OPEN cr_craptab(vr_cdcooper);
        FETCH cr_craptab INTO rw_craptab;
        vr_flgfound := cr_craptab%FOUND;
        CLOSE cr_craptab;
        
        -- Se não encontrar registro
        IF NOT vr_flgfound THEN
          vr_cdcritic := 115;
          RAISE vr_exc_erro;
        END IF;

        -- Verifica se a cooperativa esta cadastrada
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'Dados',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);
        
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dtanoret',pr_tag_cont => to_char(rw_crapdat.dtmvtolt,'RRRR'),pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'ininccmi',pr_tag_cont => rw_craptab.ininccmi,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'increret',pr_tag_cont => rw_craptab.increret,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txretorn',pr_tag_cont => rw_craptab.txretorn,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txjurcap',pr_tag_cont => rw_craptab.txjurcap,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txjurapl',pr_tag_cont => rw_craptab.txjurapl,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txjursdm',pr_tag_cont => rw_craptab.txjursdm,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txjurtar',pr_tag_cont => rw_craptab.txjurtar,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txreauat',pr_tag_cont => rw_craptab.txreauat,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'inpredef',pr_tag_cont => rw_craptab.inpredef,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'indeschq',pr_tag_cont => rw_craptab.indeschq,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'indemiti',pr_tag_cont => rw_craptab.indemiti,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'indestit',pr_tag_cont => rw_craptab.indestit,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'unsobdep',pr_tag_cont => rw_craptab.unsobdep,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dssopfco',pr_tag_cont => rw_craptab.dssopfco,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dssopjco',pr_tag_cont => rw_craptab.dssopjco,pr_des_erro => vr_dscritic);
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_busca_calculo_sobras;
  
  -- Busca data informativo
  PROCEDURE pc_busca_data_informativo (pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_busca_data_informativo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Julho/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cargas manuais do pre aprovado
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Busca Carga Solicitada/Executando
      CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT SUBSTR(dstextab,67,10) dtinform
          FROM craptab
         WHERE cdcooper = pr_cdcooper
           AND nmsistem = 'CRED'
           AND tptabela = 'GENERI'
           AND cdempres = 00
           AND cdacesso = 'EXEICMIRET'
           AND tpregist = 001;
      rw_craptab cr_craptab%ROWTYPE;
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis auxiliares
      vr_flgfound  BOOLEAN;
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
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
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        OPEN cr_craptab(vr_cdcooper);
        FETCH cr_craptab INTO rw_craptab;
        vr_flgfound := cr_craptab%FOUND;
        CLOSE cr_craptab;
        
        -- Se não encontrar registro
        IF NOT vr_flgfound THEN
          vr_cdcritic := 115;
          RAISE vr_exc_erro;
        END IF;
        
        -- Verifica se a cooperativa esta cadastrada
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'Dados',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);
        
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dtinform',pr_tag_cont => rw_craptab.dtinform,pr_des_erro => vr_dscritic);
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_busca_data_informativo;
  
  -- Busca calculo sobras
  PROCEDURE pc_altera_calculo_sobras (pr_ininccmi  IN VARCHAR2
                                     ,pr_increret  IN VARCHAR2
                                     ,pr_txretorn  IN VARCHAR2
                                     ,pr_txjurcap  IN VARCHAR2
                                     ,pr_txjurapl  IN VARCHAR2
                                     ,pr_txjursdm  IN VARCHAR2
                                     ,pr_txjurtar  IN VARCHAR2
                                     ,pr_txreauat  IN VARCHAR2
                                     ,pr_inpredef  IN VARCHAR2
                                     ,pr_indeschq  IN VARCHAR2
                                     ,pr_indemiti  IN VARCHAR2
                                     ,pr_indestit  IN VARCHAR2
                                     ,pr_unsobdep  IN VARCHAR2
                                     ,pr_dssopfco  IN VARCHAR2
                                     ,pr_dssopjco  IN VARCHAR2
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_altera_calculo_sobras
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Agosto/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cargas manuais do pre aprovado
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Verifica lock na tabela
      CURSOR cr_craptab_lock (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT dstextab
          FROM craptab
         WHERE cdcooper = pr_cdcooper
           AND upper(craptab.nmsistem) = 'CRED'
           AND upper(craptab.tptabela) = 'GENERI'
           AND cdempres = 00
           AND upper(craptab.cdacesso) = 'EXEICMIRET'
           AND tpregist = 001 FOR UPDATE NOWAIT;
      rw_craptab_lock cr_craptab_lock%ROWTYPE;
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN  
      
      
        pr_des_erro := 'OK';
      
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
        
        BEGIN
          OPEN cr_craptab_lock(vr_cdcooper);
          FETCH cr_craptab_lock INTO rw_craptab_lock;
          CLOSE cr_craptab_lock;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Calculo das sobras já está sendo executado.';
            RAISE vr_exc_erro;
        END;
        
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Verifica se a cooperativa esta cadastrada
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        -- Tratar mês limite para calculo e distribuição
        IF to_char(rw_crapdat.dtmvtolt,'MM') > to_number(gene0001.fn_param_sistema('CRED', vr_cdcooper, 'NRMES_LIM_JURO_SOBRA')) THEN
          pr_nmdcampo := 'txretorn';
          vr_cdcritic := 282;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||gene0001.fn_param_sistema('CRED', vr_cdcooper, 'NRMES_LIM_JURO_SOBRA')||'.';
          RAISE vr_exc_erro;
        END IF;
        
        /* Deve ser selecionado pelo menos um dos percentuais */
        IF pr_txretorn + pr_txjurtar + pr_txreauat + 
           pr_txjurcap + pr_txjurapl + pr_txjursdm = 0 THEN
          pr_nmdcampo := 'txretorn';
          vr_cdcritic := 284;
          RAISE vr_exc_erro;
        END IF;

        /* Não pode ter sido selecionado valor negativo */
        IF pr_txretorn < 0 OR pr_txjurtar < 0 OR pr_txreauat < 0 
        OR pr_txjurcap < 0 OR pr_txjurapl < 0 OR pr_txjursdm < 0 THEN
          pr_nmdcampo := 'txretorn';
          vr_cdcritic := 180;
          RAISE vr_exc_erro;
        END IF;        
        
        /* Efetuar gravação na tabela de parâmetros */
        BEGIN
          UPDATE craptab
             SET dstextab = TRIM(pr_ininccmi)         || ' ' || 
                            TRIM(pr_increret)         || ' ' ||
                       lpad(TRIM(pr_txretorn),12,'0') || ' ' || 
                            TRIM(pr_inpredef)         || ' ' ||
                       lpad(TRIM(pr_txjurcap),12,'0') || ' ' || 
                       lpad(TRIM(pr_txjurapl),12,'0') || ' ' ||
                            TRIM(pr_indeschq)         ||'   '|| 
                            TRIM(pr_indemiti)         || ' ' ||
                            TRIM(pr_indestit)         || ' ' || 
                       lpad(TRIM(pr_txjursdm),12,'0') || ' ' ||
                     SUBSTR(dstextab,67,10)     || ' ' ||
                       lpad(TRIM(pr_txjurtar),12,'0') || ' ' || 
                       lpad(TRIM(pr_txreauat),12,'0') || ' ' ||
                       lpad(TRIM(pr_dssopfco),6,'0')  || ' ' || 
                       lpad(TRIM(pr_dssopjco),6,'0')  || ' ' ||
                       TRIM(pr_unsobdep)
          WHERE cdcooper = vr_cdcooper
            AND upper(nmsistem) = 'CRED'
            AND upper(tptabela) = 'GENERI'
            AND cdempres = 00
            AND upper(cdacesso) = 'EXEICMIRET'
            AND tpregist = 001;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possível alterar a data informativa. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Para processo prévio
        IF pr_inpredef = '0' THEN
           BEGIN
             INSERT INTO crapsol (nrsolici,dtrefere,nrseqsol,cdempres,dsparame,insitsol,nrdevias,cdcooper)
                          VALUES (106,rw_crapdat.dtmvtolt,01,11,'',1,1,vr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possível criar registro na crapsol. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
        
        COMMIT;        
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_altera_calculo_sobras;
  
  -- Busca data informativo
  PROCEDURE pc_altera_data_informativo (pr_dtapinco  IN VARCHAR2           --> Data informativo
                                       ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_altera_data_informativo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Agosto/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cargas manuais do pre aprovado
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
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
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        -- Verifica se a cooperativa esta cadastrada
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF;
        
        IF to_date(pr_dtapinco, 'DD/MM/RRRR') < TRUNC(rw_crapdat.dtmvtolt) THEN
          vr_dscritic := 'Data informada deve ser maior ou igual a data atual.';
          RAISE vr_exc_erro;
        END IF;
        
        BEGIN
          UPDATE craptab
             SET dstextab = SUBSTR(dstextab,1,66) || pr_dtapinco || SUBSTR(dstextab,77,117)
          WHERE cdcooper = vr_cdcooper
            AND nmsistem = 'CRED'
            AND tptabela = 'GENERI'
            AND cdempres = 00
            AND cdacesso = 'EXEICMIRET'
            AND tpregist = 001;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possível alterar a data informativa. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');

        COMMIT;
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_altera_data_informativo;
  
  -- Procedure para calculo e credito do retorno de sobras e juros sobre o capital. Emissao do relatorio CRRL043
  PROCEDURE pc_cal_retorno_sobras_web(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

     BEGIN

    /* .............................................................................
    Programa: pc_cal_retorno_sobras_web
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Agosto/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para acessar Procedure de calculo e credito do retorno
                de sobras e juros sobre o capital. Emissao do relatorio CRRL043.
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
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
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        -- Verifica se a cooperativa esta cadastrada
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF;
        
        sobr0001.pc_calculo_retorno_sobras(pr_cdcooper => vr_cdcooper  --> Cooperativa solicitada
                                          ,pr_cdprogra => 'SOL030'     --> Programa chamador
                                          ,pr_cdcritic => vr_cdcritic  --> Critica encontrada
                                          ,pr_dscritic => vr_dscritic);--> Texto de erro/critica encontrada
        
        IF vr_cdcritic IS NOT NULL OR
           vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        BEGIN
           DELETE FROM crapsol
            WHERE nrsolici = 106
              AND dtrefere = rw_crapdat.dtmvtolt
              AND nrseqsol = 01
              AND cdempres = 11
              AND dsparame IS NULL
              AND insitsol = 1
              AND nrdevias = 1
              AND cdcooper = vr_cdcooper;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao deletar registro na crapsol. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>Calculo efetuado com sucesso! Relatórios em processo de emissão...</Dados></Root>');

        COMMIT;
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_cal_retorno_sobras_web;
  
END TELA_SOL030;
/
