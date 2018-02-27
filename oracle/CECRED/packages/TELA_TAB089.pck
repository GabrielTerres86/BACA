CREATE OR REPLACE PACKAGE CECRED.TELA_TAB089 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB089
  --  Sistema  : Rotinas utilizadas pela Tela TAB089
  --  Sigla    : EMPR
  --  Autor    : Guilherme/AMcom
  --  Data     : Janeiro/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB089
  --
  -- Alteracoes:  12/01/2018 - Conversão Ayllos Web (Guilherme/AMcom)
  --
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------



  ---------------------------------- ROTINAS --------------------------------
  PROCEDURE pc_consultar(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_alterar( pr_prtlmult  IN INTEGER
                       ,pr_prestorn  IN INTEGER
                       ,pr_prpropos  IN VARCHAR
                       ,pr_vlempres  IN NUMBER
                       ,pr_pzmaxepr  IN INTEGER
                       ,pr_vlmaxest  IN NUMBER
                       -- Novos Campos
                       ,pr_pcaltpar  IN NUMBER -- Alteração de parcela - PORCENTAGEM
                       ,pr_vltolemp  IN NUMBER -- Tolerância por valor de empréstimo - REAIS
                       -- PROPOSTAS PA - Prazo de validade da análise para efetivação 
                       ,pr_qtdpaimo  IN INTEGER -- Imovel - Quantidade Dias PA Imovel
                       ,pr_qtdpaaut  IN INTEGER -- Automovel - Quantidade Dias PA Automovel
                       ,pr_qtdpaava  IN INTEGER -- Aval - Quantidade Dias PA Aval
                       ,pr_qtdpaapl  IN INTEGER -- Aplicacao - Quantidade Dias PA Aplicacao
                       ,pr_qtdpasem  IN INTEGER -- Sem Garantia - Quantidade Dias PA Sem Garantia
                        -- PROPOSTAS Mobile/IB/TAA - Prazo de validade da análise para efetivação 
                       ,pr_qtdibaut  IN INTEGER -- Automovel
                       ,pr_qtdibapl  IN INTEGER -- Aplicacao
                       ,pr_qtdibsem  IN INTEGER -- Sem Garantia
                                             
                       ,pr_xmllog      IN VARCHAR2  --> XML com informações de LOG
                       ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

END TELA_TAB089;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TAB089 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB089
  --  Sistema  : Rotinas utilizadas pela Tela TAB089
  --  Sigla    : EMPR
  --  Autor    : Guilherme/AMcom
  --  Data     : Janeiro/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB089
  --
  -- Alteracoes:  12/01/2018 - Conversão Ayllos Web (Guilherme/AMcom)
  --
  --
  ---------------------------------------------------------------------------
  PROCEDURE pc_consultar(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Guilherme/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar Op. Taxas Pre-fixadas

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      
      vr_dstextab craptab.dstextab%TYPE;

      vr_prtlmult INTEGER :=0;
      vr_prestorn INTEGER :=0;
      vr_prpropos VARCHAR2(8);
      vr_vlempres NUMBER  :=0;
      vr_pzmaxepr INTEGER :=0;
      vr_vlmaxest NUMBER  :=0;
      vr_pcaltpar NUMBER  :=0;
      vr_vltolemp NUMBER  :=0;
      vr_qtdpaimo INTEGER :=0; 
      vr_qtdpaaut INTEGER :=0;
      vr_qtdpaava INTEGER :=0;
      vr_qtdpaapl INTEGER :=0;
      vr_qtdpasem INTEGER :=0;
      vr_qtdibaut INTEGER :=0;      
      vr_qtdibapl INTEGER :=0;      
      vr_qtdibsem INTEGER :=0;      
      
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      ---------->> CURSORES <<--------



    BEGIN

      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
      

      -- Buscar dados da TAB
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPREST'
                                               ,pr_tpregist => 01);

      --Se nao encontrou parametro
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_cdcritic := 55;
        RAISE vr_exc_saida;
      ELSE
        -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
        vr_prtlmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,3));
        vr_prestorn := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,9,3));
        vr_prpropos := SUBSTR(vr_dstextab,13,8);
        vr_vlempres := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,22,12));
        vr_pzmaxepr := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,35,4));
        vr_vlmaxest := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,40,12));
        --
        vr_pcaltpar := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,53,6)),0);
        vr_vltolemp := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,60,12)),0);
        --
        vr_qtdpaimo := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,73,3)),0);
        vr_qtdpaaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,77,3)),0);
        vr_qtdpaava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,81,3)),0);
        vr_qtdpaapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,85,3)),0);
        vr_qtdpasem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,89,3)),0);
        --
        vr_qtdibaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,93,3)),0);
        vr_qtdibapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,97,3)),0);
        vr_qtdibsem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,101,3)),0);

      END IF;

      -- PASSA OS DADOS PARA O XML RETORNO      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      
      -- CAMPOS
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'prtlmult',
                             pr_tag_cont => to_char(vr_prtlmult),
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'prestorn',
                             pr_tag_cont => to_char(vr_prestorn),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'prpropos',
                             pr_tag_cont => vr_prpropos,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlempres',
                             pr_tag_cont => to_char(vr_vlempres,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pzmaxepr',
                             pr_tag_cont => to_char(vr_pzmaxepr,
                                                    '9990',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmaxest',
                             pr_tag_cont => to_char(vr_vlmaxest,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
                                  
      -- NOVOS (2)
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcaltpar',
                             pr_tag_cont => to_char(vr_pcaltpar,
                                                    '999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vltolemp',
                             pr_tag_cont => to_char(vr_vltolemp,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      -- NOVOS (5)
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpaimo',
                             pr_tag_cont => to_char(vr_qtdpaimo),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpaaut',
                             pr_tag_cont => to_char(vr_qtdpaaut),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpaava',
                             pr_tag_cont => to_char(vr_qtdpaava),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpaapl',
                             pr_tag_cont => to_char(vr_qtdpaapl),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdpasem',
                             pr_tag_cont => to_char(vr_qtdpasem),
                             pr_des_erro => vr_dscritic);

      -- NOVOS (3)
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdibaut',
                             pr_tag_cont => to_char(vr_qtdibaut),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdibapl',
                             pr_tag_cont => to_char(vr_qtdibapl),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdibsem',
                             pr_tag_cont => to_char(vr_qtdibsem),
                             pr_des_erro => vr_dscritic);


  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consultar;

  PROCEDURE pc_alterar( pr_prtlmult  IN INTEGER
                       ,pr_prestorn  IN INTEGER
                       ,pr_prpropos  IN VARCHAR
                       ,pr_vlempres  IN NUMBER
                       ,pr_pzmaxepr  IN INTEGER
                       ,pr_vlmaxest  IN NUMBER
                       
                       ,pr_pcaltpar  IN NUMBER
                       ,pr_vltolemp  IN NUMBER
                       
                       ,pr_qtdpaimo  IN INTEGER
                       ,pr_qtdpaaut  IN INTEGER
                       ,pr_qtdpaava  IN INTEGER
                       ,pr_qtdpaapl  IN INTEGER
                       ,pr_qtdpasem  IN INTEGER
                       
                       ,pr_qtdibaut  IN INTEGER
                       ,pr_qtdibapl  IN INTEGER
                       ,pr_qtdibsem  IN INTEGER

                       ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Guilherme/AMcom
        Data    : Janeiro/2018                 Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para alterar Op. Taxas Pre-fixadas

        Observacao: -----

        Alteracoes:
    ..............................................................................*/

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_cdacesso VARCHAR2(100);

    vr_dstextab craptab.dstextab%TYPE;

    vr_prtlmult INTEGER :=0;
    vr_prestorn INTEGER :=0;
    vr_prpropos VARCHAR2(8);
    vr_vlempres NUMBER  :=0;
    vr_pzmaxepr INTEGER :=0;
    vr_vlmaxest NUMBER  :=0;
    vr_pcaltpar NUMBER  :=0;
    vr_vltolemp NUMBER  :=0;
    vr_qtdpaimo INTEGER :=0; 
    vr_qtdpaaut INTEGER :=0;
    vr_qtdpaava INTEGER :=0;
    vr_qtdpaapl INTEGER :=0;
    vr_qtdpasem INTEGER :=0;
    vr_qtdibaut INTEGER :=0;      
    vr_qtdibapl INTEGER :=0;      
    vr_qtdibsem INTEGER :=0;

    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --------------->>> SUB-ROTINA <<<-----------------
    --> Gerar Log da tela
    PROCEDURE pc_log_tab089(pr_cdcooper IN crapcop.cdcooper%TYPE,
                            pr_cdoperad IN crapope.cdoperad%TYPE,
                            pr_dscdolog IN VARCHAR2) IS
      vr_dscdolog VARCHAR2(500);
    BEGIN

      vr_dscdolog := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||' '|| to_char(SYSDATE,'HH24:MI:SS') ||
                     ' --> '|| vr_cdacesso || ' --> '|| 'Operador '|| pr_cdoperad ||
                     ' '||pr_dscdolog;

      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log  => vr_dscdolog,
                                 pr_nmarqlog => 'tab089',
                                 pr_flfinmsg => 'N');
    END;



  BEGIN

    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    

    -- Buscar dados da TAB
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'PAREMPREST'
                                             ,pr_tpregist => 01);

    --Se encontrou parametro, atribui valor. Caso contrario, mantem Zero 
    IF TRIM(vr_dstextab) IS NOT NULL THEN
      -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
      vr_prtlmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,3));
      vr_prestorn := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,9,3));
      vr_prpropos := SUBSTR(vr_dstextab,13,8);
      vr_vlempres := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,22,12));
      vr_pzmaxepr := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,35,4));
      vr_vlmaxest := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,40,12));
      --
      vr_pcaltpar := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,53,6)),0);
      vr_vltolemp := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,60,12)),0);
      --                                                                
      vr_qtdpaimo := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,73,3)),0);
      vr_qtdpaaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,77,3)),0);
      vr_qtdpaava := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,81,3)),0);
      vr_qtdpaapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,85,3)),0);
      vr_qtdpasem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,89,3)),0);
      --                                                                
      vr_qtdibaut := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,93,3)),0);
      vr_qtdibapl := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,97,3)),0);
      vr_qtdibsem := NVL(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,101,3)),0);

    END IF;

    vr_dstextab := to_char(pr_prtlmult,   'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(0          ,   'FM000')       || ' ' ||  -- POSICAO NAO UTILIZADA
                   to_char(pr_prestorn,   'FM000')       || ' ' ||
                   pr_prpropos                           || ' ' ||
                   to_char(pr_vlempres,   'FM000000000D00'  , 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_pzmaxepr,   'FM0000', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_vlmaxest,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   
                   to_char(pr_pcaltpar,   'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_vltolemp,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   
                   to_char(pr_qtdpaimo,   'FM000')       || ' ' ||
                   to_char(pr_qtdpaaut,   'FM000')       || ' ' ||
                   to_char(pr_qtdpaava,   'FM000')       || ' ' ||
                   to_char(pr_qtdpaapl,   'FM000')       || ' ' ||
                   to_char(pr_qtdpasem,   'FM000')       || ' ' ||
                   
                   to_char(pr_qtdibaut,   'FM000')       || ' ' ||
                   to_char(pr_qtdibapl,   'FM000')       || ' ' ||
                   to_char(pr_qtdibsem,   'FM000')       ||'';

    BEGIN
      UPDATE craptab tab
         SET tab.dstextab = vr_dstextab
       WHERE tab.cdcooper        = vr_cdcooper
         AND upper(tab.nmsistem) = 'CRED'
         AND upper(tab.tptabela) = 'USUARI'
         AND tab.cdempres        = 11
         AND upper(tab.cdacesso) = 'PAREMPREST'
         AND tab.tpregist        = 01;
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Parametros Emprestimos!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;

    END;


    IF vr_prtlmult <> pr_prtlmult THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Prazo de tolerancia para incidencia de multa e juros de mora de ' ||
                                    to_char(vr_prtlmult,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_prtlmult,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_prestorn <> pr_prestorn THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Prazo maximo para estorno de contratos com alienacao/hipoteca de imoveis de ' ||
                                    to_char(vr_prestorn,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_prestorn,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

    IF vr_prpropos <> pr_prpropos THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Prazo maximo de validade da proposta de ' ||
                                    vr_prpropos ||
                                    ' para ' || pr_prpropos);

    END IF;

    IF vr_vlempres <> pr_vlempres THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Valor minimo para cobranca de emprestimo de ' ||
                                    to_char(vr_vlempres,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_vlempres,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

    IF vr_pzmaxepr <> pr_pzmaxepr THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Prazo maximo para liberacao do emprestimo de ' ||
                                    to_char(vr_pzmaxepr,'FM0000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_pzmaxepr,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_vlmaxest <> pr_vlmaxest THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Vl. max. de estorno perm. sem autorizacao da coordenacao/gerencia de ' ||
                                    to_char(vr_vlmaxest,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_vlmaxest,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

    IF vr_pcaltpar <> pr_pcaltpar THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou % Alteracao de parcela de ' ||
                                    to_char(vr_pcaltpar,'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_pcaltpar,'FM000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));

    END IF;

    IF vr_vltolemp <> pr_vltolemp THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Tolerancia por valor de emprestimo de ' ||
                                    to_char(vr_vltolemp,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_vltolemp,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpaimo <> pr_qtdpaimo THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao com garantia de Imovel de ' ||
                                    to_char(vr_qtdpaimo,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpaimo,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpaaut <> pr_qtdpaaut THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao com garantia de Automovel de ' ||
                                    to_char(vr_qtdpaaut,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpaaut,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpaava <> pr_qtdpaava THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao com garantia de Aval de ' ||
                                    to_char(vr_qtdpaava,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpaava,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpaapl <> pr_qtdpaapl THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao com garantia de Aplicacao de ' ||
                                    to_char(vr_qtdpaapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpaapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdpasem <> pr_qtdpasem THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou PA - Prazo de validade Operacao Sem Garantia de ' ||
                                    to_char(vr_qtdpasem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdpasem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;


    IF vr_qtdibaut <> pr_qtdibaut THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Mobile/IB/TAA - Prazo de validade Operacao com garantia de Automovel de ' ||
                                    to_char(vr_qtdibaut,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdibaut,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdibapl <> pr_qtdibapl THEN
      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Mobile/IB/TAA - Prazo de validade Operacao com garantia de Aplicacao de ' ||
                                    to_char(vr_qtdibapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdibapl,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_qtdibsem <> pr_qtdibsem THEN

      --> gerar log da tela
      pc_log_tab089(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Mobile/IB/TAA - Prazo de validade Operacao Sem Garantia de ' ||
                                    to_char(vr_qtdibsem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_qtdibsem,'FM000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;



    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_alterar;

END TELA_TAB089;
/
