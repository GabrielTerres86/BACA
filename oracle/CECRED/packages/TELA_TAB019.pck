CREATE OR REPLACE PACKAGE CECRED.TELA_TAB019 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CONPRO
  --  Sistema  : Rotinas utilizadas pela Tela COMPRO
  --  Sigla    : EMPR
  --  Autor    : Daniel Zimmermann/Odirlei Busana - AMcom
  --  Data     : Março - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CONPRO
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  
  ---------------------------------- ROTINAS --------------------------------
  PROCEDURE pc_consulta_web(pr_inpessoa IN NUMBER
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_alterar_tab019(pr_inpessoa    IN NUMBER
                             ,pr_vllimite    IN VARCHAR2
                             ,pr_vllimite_c  IN VARCHAR2
                             ,pr_qtdiavig    IN VARCHAR2
                             ,pr_qtdiavig_c  IN VARCHAR2
                             ,pr_qtprzmin    IN VARCHAR2
                             ,pr_qtprzmin_c  IN VARCHAR2
                             ,pr_qtprzmax    IN VARCHAR2
                             ,pr_qtprzmax_c  IN VARCHAR2
                             ,pr_txdmulta    IN VARCHAR2
                             ,pr_txdmulta_c  IN VARCHAR2
                             ,pr_vlconchq    IN VARCHAR2
                             ,pr_vlconchq_c  IN VARCHAR2
                             ,pr_vlmaxemi    IN VARCHAR2
                             ,pr_vlmaxemi_c  IN VARCHAR2
                             ,pr_pcchqloc    IN VARCHAR2
                             ,pr_pcchqloc_c  IN VARCHAR2
                             ,pr_pcchqemi    IN VARCHAR2
                             ,pr_pcchqemi_c  IN VARCHAR2
                             ,pr_qtdiasoc    IN VARCHAR2
                             ,pr_qtdiasoc_c  IN VARCHAR2
                             ,pr_qtdevchq    IN VARCHAR2
                             ,pr_qtdevchq_c  IN VARCHAR2
                             ,pr_pctollim    IN VARCHAR2
                             ,pr_pctollim_c  IN VARCHAR2
                             ,pr_qtdiasli    IN VARCHAR2
                             ,pr_qtdiasli_c  IN VARCHAR2
                             ,pr_horalimt    IN VARCHAR2
                             ,pr_horalimt_c  IN VARCHAR2
                             ,pr_minlimit    IN VARCHAR2
                             ,pr_minlimit_c  IN VARCHAR2
                             ,pr_Flemipar    IN VARCHAR2  -- Verificar se Emitente é Conjugue do Cooperado
                             ,pr_Flemipar_c  IN VARCHAR2  -- Verificar se Emitente é Conjugue do Cooperado
                             ,pr_Przmxcmp    IN VARCHAR2  -- Prazo Máximo de Compensação
                             ,pr_Przmxcmp_c  IN VARCHAR2  -- Prazo Máximo de Compensação
                             ,pr_Flpjzemi    IN VARCHAR2  -- Verificar Prejuízo do Emitente
                             ,pr_Flpjzemi_c  IN VARCHAR2  -- Verificar Prejuízo do Emitente
                             ,pr_Flemisol    IN VARCHAR2  -- Verificar Emitente x Conta Solicitante
                             ,pr_Flemisol_c  IN VARCHAR2  -- Verificar Emitente x Conta Solicitante
                             ,pr_Prcliqui    IN VARCHAR2  -- Percentual de Liquidez
                             ,pr_Prcliqui_c  IN VARCHAR2  -- Percentual de Liquidez
                             ,pr_Qtmesliq    IN VARCHAR2  -- Qtd. Meses Cálculo Percentual de Liquidez
                             ,pr_Qtmesliq_c  IN VARCHAR2  -- Qtd. Meses Cálculo Percentual de Liquidez                  
                             ,pr_Vlrenlim    IN VARCHAR2  -- Renda x Limite Desconto
                             ,pr_Vlrenlim_c  IN VARCHAR2  -- Renda x Limite Desconto
                             ,pr_Qtmxrede    IN VARCHAR2  -- Qtd. Máxima Redesconto
                             ,pr_Qtmxrede_c  IN VARCHAR2  -- Qtd. Máxima Redesconto
                             ,pr_Fldchqdv    IN VARCHAR2  -- Permitir Desconto Cheque Devolvido
                             ,pr_Fldchqdv_c  IN VARCHAR2  -- Permitir Desconto Cheque Devolvido
                             ,pr_Vlmxassi    IN VARCHAR2  -- Valor Máximo Dispensa Assinatura
                             ,pr_Vlmxassi_c  IN VARCHAR2  -- Valor Máximo Dispensa Assinatura
                             ,pr_xmllog      IN VARCHAR2  --> XML com informações de LOG
                             ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro   OUT VARCHAR2);

END TELA_TAB019;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TAB019 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB019
  --  Sistema  : Rotinas utilizadas pela Tela TAB019
  --  Sigla    : EMPR
  --  Autor    : Daniel Zimmermann
  --  Data     : Março - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB019
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_consulta_web(pr_inpessoa IN NUMBER             --> Tipo de pessoa (1-Fisica e 2-Juridica)
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann/ Odirlei Busana
        Data    : Março/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para consultar linha de desconto
    
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
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
                 
      vr_tab_lim_desconto dscc0001.typ_tab_lim_desconto;      
      
      ---------->> CURSORES <<--------
      --> Buscar dados operador    
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT ope.dsdepart
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;
    
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
      
      DSCC0001.pc_busca_tab_limdescont
                              ( pr_cdcooper => vr_cdcooper    --> Codigo da cooperativa 
                               ,pr_inpessoa => pr_inpessoa    --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                               ,pr_tab_lim_desconto => vr_tab_lim_desconto  --> Temptable com os dados do limite de desconto                                     
                               ,pr_cdcritic => vr_cdcritic    --> Código da crítica
                               ,pr_dscritic => vr_dscritic);  --> Descrição da crítica                
    
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL OR 
        nvl(vr_cdcritic,0) > 0 THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;              
      
      --> Buscar dados do operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper, 
                      pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
    
      -- Se nao encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapope;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Operador não encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_crapope;
    
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
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dsdepart',
                             pr_tag_cont => rw_crapope.dsdepart,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimite',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).vllimite,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vllimite_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).vllimite_c,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiavig',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiavig),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiavig_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiavig_c),
                             pr_des_erro => vr_dscritic);    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmin',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtprzmin),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmin_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtprzmin_c),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmax',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtprzmax),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtprzmax_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtprzmax_c),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'txdmulta',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).txdmulta,
                                                    '990D000000',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'txdmulta_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).txdmulta_c,
                                                    '990D000000',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlconchq',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).vlconchq,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlconchq_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).vlconchq_c,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmaxemi',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).vlmaxemi,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vlmaxemi_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).vlmaxemi_c,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcchqloc',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).pcchqloc),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcchqloc_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).pcchqloc_c),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcchqemi',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).pcchqemi),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pcchqemi_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).pcchqemi_c),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiasoc',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiasoc),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiasoc_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiasoc_c),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdevchq',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdevchq),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdevchq_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdevchq_c),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctollim',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).pctollim),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pctollim_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).pctollim_c),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiasoc',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiasoc),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiasoc_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiasoc_c),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiasli',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiasli),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'qtdiasli_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiasli_c),
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'horalimt',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).horalimt),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'minlimit',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).minlimit),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'horalimt_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).horalimt_c),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'minlimit_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).minlimit_c),
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Flemipar',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Flemipar),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Flemipar_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Flemipar_c),
                             pr_des_erro => vr_dscritic);
                             
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Przmxcmp',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Przmxcmp),
                             pr_des_erro => vr_dscritic);  
                                                                                      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Przmxcmp_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Przmxcmp_c),
                             pr_des_erro => vr_dscritic);
                              
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Flpjzemi',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Flpjzemi),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Flpjzemi_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Flpjzemi_c),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Flemisol',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Flemisol),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Flemisol_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Flemisol_c),
                             pr_des_erro => vr_dscritic);
                                                
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Prcliqui',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Prcliqui),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Prcliqui_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Prcliqui_c),
                             pr_des_erro => vr_dscritic);
                      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Qtmesliq',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Qtmesliq),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Qtmesliq_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Qtmesliq_c),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Vlrenlim',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Vlrenlim),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Vlrenlim_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Vlrenlim_c),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Qtmxrede',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Qtmxrede),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Qtmxrede_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Qtmxrede_c),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Fldchqdv',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Fldchqdv),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Fldchqdv_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Fldchqdv_c),
                             pr_des_erro => vr_dscritic);                             

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Vlmxassi',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Vlmxassi,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'Vlmxassi_c',
                             pr_tag_cont => to_char(vr_tab_lim_desconto(pr_inpessoa).Vlmxassi_c,
                                                    'fm9g999g999g999g999g990d00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
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
  END pc_consulta_web;

  PROCEDURE pc_alterar_tab019(pr_inpessoa    IN NUMBER
                             ,pr_vllimite    IN VARCHAR2
                             ,pr_vllimite_c  IN VARCHAR2
                             ,pr_qtdiavig    IN VARCHAR2
                             ,pr_qtdiavig_c  IN VARCHAR2
                             ,pr_qtprzmin    IN VARCHAR2
                             ,pr_qtprzmin_c  IN VARCHAR2
                             ,pr_qtprzmax    IN VARCHAR2
                             ,pr_qtprzmax_c  IN VARCHAR2
                             ,pr_txdmulta    IN VARCHAR2
                             ,pr_txdmulta_c  IN VARCHAR2
                             ,pr_vlconchq    IN VARCHAR2
                             ,pr_vlconchq_c  IN VARCHAR2
                             ,pr_vlmaxemi    IN VARCHAR2
                             ,pr_vlmaxemi_c  IN VARCHAR2
                             ,pr_pcchqloc    IN VARCHAR2
                             ,pr_pcchqloc_c  IN VARCHAR2
                             ,pr_pcchqemi    IN VARCHAR2
                             ,pr_pcchqemi_c  IN VARCHAR2
                             ,pr_qtdiasoc    IN VARCHAR2
                             ,pr_qtdiasoc_c  IN VARCHAR2
                             ,pr_qtdevchq    IN VARCHAR2
                             ,pr_qtdevchq_c  IN VARCHAR2
                             ,pr_pctollim    IN VARCHAR2
                             ,pr_pctollim_c  IN VARCHAR2
                             ,pr_qtdiasli    IN VARCHAR2
                             ,pr_qtdiasli_c  IN VARCHAR2
                             ,pr_horalimt    IN VARCHAR2
                             ,pr_horalimt_c  IN VARCHAR2
                             ,pr_minlimit    IN VARCHAR2
                             ,pr_minlimit_c  IN VARCHAR2
                             ,pr_Flemipar    IN VARCHAR2  -- Verificar se Emitente é Conjugue do Cooperado
                             ,pr_Flemipar_c  IN VARCHAR2  -- Verificar se Emitente é Conjugue do Cooperado
                             ,pr_Przmxcmp    IN VARCHAR2   -- Prazo Máximo de Compensação
                             ,pr_Przmxcmp_c  IN VARCHAR2   -- Prazo Máximo de Compensação
                             ,pr_Flpjzemi    IN VARCHAR2  -- Verificar Prejuízo do Emitente
                             ,pr_Flpjzemi_c  IN VARCHAR2  -- Verificar Prejuízo do Emitente
                             ,pr_Flemisol    IN VARCHAR2  -- Verificar Emitente x Conta Solicitante
                             ,pr_Flemisol_c  IN VARCHAR2  -- Verificar Emitente x Conta Solicitante
                             ,pr_Prcliqui    IN VARCHAR2  -- Percentual de Liquidez
                             ,pr_Prcliqui_c  IN VARCHAR2  -- Percentual de Liquidez
                             ,pr_Qtmesliq    IN VARCHAR2  -- Qtd. Meses Cálculo Percentual de Liquidez
                             ,pr_Qtmesliq_c  IN VARCHAR2  -- Qtd. Meses Cálculo Percentual de Liquidez                  
                             ,pr_Vlrenlim    IN VARCHAR2   -- Renda x Limite Desconto
                             ,pr_Vlrenlim_c  IN VARCHAR2   -- Renda x Limite Desconto
                             ,pr_Qtmxrede    IN VARCHAR2  -- Qtd. Máxima Redesconto
                             ,pr_Qtmxrede_c  IN VARCHAR2  -- Qtd. Máxima Redesconto
                             ,pr_Fldchqdv    IN VARCHAR2  -- Permitir Desconto Cheque Devolvido
                             ,pr_Fldchqdv_c  IN VARCHAR2  -- Permitir Desconto Cheque Devolvido
                             ,pr_Vlmxassi    IN VARCHAR2   -- Valor Máximo Dispensa Assinatura
                             ,pr_Vlmxassi_c  IN VARCHAR2   -- Valor Máximo Dispensa Assinatura
                             ,pr_xmllog      IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para consultar linha de desconto
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
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
    vr_dsccampo VARCHAR2(1000);
      
    vr_tab_lim_desconto DSCC0001.typ_tab_lim_desconto;      
    
    vr_horalimt NUMBER;
    vr_horalim2 NUMBER;
    
    vr_dstextab VARCHAR2(2000);
        
    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;          
    
    CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT ope.dsdepart
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE;
    
    
    --------------->>> SUB-ROTINA <<<-----------------
    --> Gerar Log da tela
    PROCEDURE pc_log_tab019(pr_cdcooper IN crapcop.cdcooper%TYPE,
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
                                 pr_nmarqlog => 'tab019', 
                                 pr_flfinmsg => 'N');        
    END;
    
    --Retornar descrição do indicador
    FUNCTION fn_retdsind (pr_indicador IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
      IF pr_indicador = 1 THEN
        RETURN 'Sim';
      ELSIF pr_indicador = 0 THEN
        RETURN 'Nao';
      END IF;
       
      RETURN NULL;
    
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
    
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;    
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;
    
    IF pr_inpessoa = 1 THEN
      vr_cdacesso := 'LIMDESCONTPF';
    ELSE
      vr_cdacesso := 'LIMDESCONTPJ';
    END IF;
    
    DSCC0001.pc_busca_tab_limdescont
                            ( pr_cdcooper => vr_cdcooper    --> Codigo da cooperativa 
                             ,pr_inpessoa => pr_inpessoa    --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                             ,pr_tab_lim_desconto => vr_tab_lim_desconto  --> Temptable com os dados do limite de desconto                                     
                             ,pr_cdcritic => vr_cdcritic    --> Código da crítica
                             ,pr_dscritic => vr_dscritic);  --> Descrição da crítica                
    
    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL OR 
      nvl(vr_cdcritic,0) > 0 THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
      
    
    OPEN cr_crapope(pr_cdcooper => vr_cdcooper, pr_cdoperad => vr_cdoperad);
    FETCH cr_crapope
      INTO rw_crapope;
    
    -- Se nao encontrar
    IF cr_crapope%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapope;
      
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao localizar operador!';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
      
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_crapope;
    
    IF pr_qtprzmin > pr_qtprzmax OR
       pr_qtprzmax > 360 THEN
      -- Montar mensagem de critica
      vr_cdcritic := 26;
      vr_dscritic := '';
      pr_nmdcampo := 'qtprzmin';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
      
    END IF;
    
    IF pr_vllimite > pr_vllimite_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vllimite';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
      
    END IF;
    
    IF pr_vlmaxemi > pr_vlmaxemi_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vlmaxemi';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
      
    END IF;
    
    IF pr_qtprzmax > pr_qtprzmax_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtprzmax';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    IF to_number(pr_pctollim) > to_number(pr_pctollim_c) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'pctollim';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    IF pr_txdmulta > 2 THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Valor nao deve ser superior a 2% (Exigencia Legal)';
      pr_nmdcampo := 'txdmulta';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    IF pr_qtdiasli < pr_qtdiasli_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'A qtd de dias deve ser superior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtdiasli';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    IF pr_qtdiasli = pr_qtdiasli_c THEN
      
      IF pr_horalimt > pr_horalimt_c THEN
        
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'O horario deve ser inferior ou igual ao estipulado pela CECRED';
        pr_nmdcampo := 'horalimt';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
        
      END IF;
      
      IF (pr_horalimt = pr_horalimt_c) AND
         (pr_minlimit > pr_minlimit_c) THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'O horario deve ser inferior ou igual ao estipulado pela CECRED';
        pr_nmdcampo := 'minlimit';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
        
      END IF;
    END IF;

    -- Validações Cecred
    IF pr_vllimite > pr_vllimite_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor não pode ser menor que o da cooperativa';
      pr_nmdcampo := 'vllimite';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
      
    END IF;
    
    IF pr_vlmaxemi > pr_vlmaxemi_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor não pode ser menor que o da cooperativa';
      pr_nmdcampo := 'vlmaxemi';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
      
    END IF;
    IF pr_qtprzmax > pr_qtprzmax_c THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor não pode ser menor que o da cooperativa';
      pr_nmdcampo := 'qtprzmax';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;        
    
    IF to_number(pr_Przmxcmp) > to_number(pr_Przmxcmp_c) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'przmxcmp';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    IF to_number(pr_Prcliqui) > 100 THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor percentual de liquidez não pode ser maior que 100%';
      pr_nmdcampo := 'prcliqui';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    IF to_number(pr_Prcliqui_c) > 100 THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor percentual de liquidez não pode ser maior que 100%';
      pr_nmdcampo := 'prcliqui_c';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    IF to_number(pr_Prcliqui) > to_number(pr_Prcliqui_c) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'prcliqui';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    IF to_number(pr_Qtmesliq) > to_number(pr_Qtmesliq_c) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtmesliq';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
      
    IF to_number(pr_Vlrenlim) > to_number(pr_Vlrenlim_c) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vlrenlim';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
      
    IF to_number(pr_Qtmxrede) > to_number(pr_Qtmxrede_c) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'qtmxrede';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    IF to_number(pr_Vlmxassi) > to_number(pr_Vlmxassi_c) THEN
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'O valor deve ser inferior ou igual ao estipulado pela CECRED';
      pr_nmdcampo := 'vlmxassi';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    
    vr_horalimt := ((pr_horalimt * 60) * 60) + (pr_minlimit * 60);
    vr_horalim2 := ((pr_horalimt_c * 60) * 60) + (pr_minlimit_c * 60);
    
    vr_dstextab := to_char(pr_vllimite,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' || 
                   to_char(pr_vllimite_c, 'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_qtdiavig_c, 'FM0000')      || ' ' ||
                   to_char(pr_qtprzmin,   'FM000')       || ' ' ||
                   to_char(pr_qtprzmax,   'FM000')       || ' ' ||
                   to_char(pr_qtprzmax_c, 'FM000')       || ' ' ||
                   to_char(pr_txdmulta,   'FM000D000000'  , 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_vlconchq,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_vlmaxemi,   'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' || 
                   to_char(pr_vlmaxemi_c, 'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' || 
                   to_char(pr_pcchqloc,   'FM000')       || ' ' ||
                   to_char(pr_pcchqemi,   'FM000')       || ' ' ||
                   to_char(pr_qtdiasoc,   'FM000')       || ' ' ||
                   to_char(pr_qtdevchq,   'FM000')       || ' ' ||
                   to_char(pr_pctollim,   'FM000')       || ' ' ||
                   to_char(pr_pctollim_c, 'FM000')       || ' ' ||
                   to_char(pr_qtdiasli,   'FM00')        || ' ' ||
                   to_char(vr_horalimt,   'FM00000')     || ' ' ||
                   to_char(pr_qtdiasli_c, 'FM00')        || ' ' ||
                   to_char(vr_horalim2,   'FM00000')     || ' ' ||
                   to_char(pr_Flemipar,   'FM0')         || ' ' ||  
                   to_char(pr_Flemipar_c, 'FM0')         || ' ' ||
                   to_char(pr_Przmxcmp  , 'FM0000')      || ' ' ||
                   to_char(pr_Przmxcmp_c, 'FM0000')      || ' ' ||
                   to_char(pr_Flpjzemi  , 'FM0')         || ' ' ||
                   to_char(pr_Flpjzemi_c, 'FM0')         || ' ' ||
                   to_char(pr_Flemisol  , 'FM0')         || ' ' ||
                   to_char(pr_Flemisol_c, 'FM0')         || ' ' ||
                   to_char(pr_Prcliqui  , 'FM000')       || ' ' ||
                   to_char(pr_Prcliqui_c, 'FM000')       || ' ' ||
                   to_char(pr_Qtmesliq  , 'FM0000')      || ' ' ||
                   to_char(pr_Qtmesliq_c, 'FM0000')      || ' ' ||
                   to_char(pr_Vlrenlim  , 'FM0000')      || ' ' ||
                   to_char(pr_Vlrenlim_c, 'FM0000')      || ' ' ||
                   to_char(pr_Qtmxrede  , 'FM00')        || ' ' ||
                   to_char(pr_Qtmxrede_c, 'FM00')        || ' ' ||
                   to_char(pr_Fldchqdv  , 'FM0')         || ' ' ||
                   to_char(pr_Fldchqdv_c, 'FM0')         || ' ' ||
                   to_char(pr_Vlmxassi  , 'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' ' || 
                   to_char(pr_Vlmxassi_c, 'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''')
                    ||'';
    
    BEGIN
      UPDATE craptab tab
         SET tab.dstextab = vr_dstextab
       WHERE tab.cdcooper = vr_cdcooper
         AND upper(tab.nmsistem) = 'CRED'
         AND upper(tab.tptabela) = 'USUARI'
         AND tab.cdempres = 11
         AND upper(tab.cdacesso) = upper(vr_cdacesso)
         AND tab.tpregist = 0;
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Linha de Desconto!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
        
    END;    
    
    IF vr_tab_lim_desconto(pr_inpessoa).vllimite <> pr_vllimite THEN
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o limite maximo do contrato de R$ ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).vllimite,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                    ' para R$ ' || to_char(pr_vllimite,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).vllimite_c <> pr_vllimite_c THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o limite maximo do contrato CECRED de R$ ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).vllimite_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                    ' para R$ ' || to_char(pr_vllimite_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));  
      
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).qtdiavig <> pr_qtdiavig_c THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias da vigencia minima de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiavig) || 
                                    ' para ' || to_char(pr_qtdiavig_c));                                            
      
    END IF;        
    
    IF vr_tab_lim_desconto(pr_inpessoa).qtprzmin <> pr_qtprzmin THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias de prazo minimo do cheque de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).qtprzmin) || 
                                    ' para ' || to_char(pr_qtprzmin));                                                                            
      
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).qtprzmax <> pr_qtprzmax THEN
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias de prazo maximo do cheque de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).qtprzmax) || 
                                    ' para ' || to_char(pr_qtprzmax));
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).qtprzmax_c <> pr_qtprzmax_c THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de dias de prazo maximo do cheque CECRED de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).qtprzmax_c) || 
                                    ' para ' || to_char(pr_qtprzmax_c));
      
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).txdmulta <> pr_txdmulta THEN
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o percentual de multa sobre devolucao de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).txdmulta) || 
                                    ' para ' || to_char(pr_txdmulta));
      
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).vlconchq <> pr_vlconchq THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor do cheque a ser consultado de R$ ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).vlconchq,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                    ' para R$ ' || to_char(pr_vlconchq,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).vlmaxemi <> pr_vlmaxemi THEN
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente de R$ ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).vlmaxemi,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                    ' para R$ ' || to_char(pr_vlmaxemi,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));                                          
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).vlmaxemi_c <> pr_vlmaxemi_c THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor maximo permitido por emitente CECRED de R$ ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).vlmaxemi_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || 
                                    ' para R$ ' || to_char(pr_vlmaxemi_c,'FM9999999990D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).pcchqloc <> pr_pcchqloc THEN
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o percentual de cheques da COMPE local de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).pcchqloc) || 
                                    ' para ' || to_char(pr_pcchqloc));
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).pcchqemi <> pr_pcchqemi THEN
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o percentual de cheques por emitente de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).pcchqemi) || 
                                    ' para ' || to_char(pr_pcchqemi));
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).qtdiasoc <> pr_qtdiasoc THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o tempo minimo de filiacao de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiasoc) || 
                                    ' para ' || to_char(pr_qtdiasoc));      
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).qtdevchq <> pr_qtdevchq THEN
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a qtd. de cheques devolvidos por emitente de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).qtdevchq) || 
                                    ' para ' || to_char(pr_qtdevchq)); 
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).pctollim <> pr_pctollim THEN
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a tolencia para limite excedido no contrato de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).pctollim) || 
                                    ' para ' || to_char(pr_pctollim)); 
    END IF;
    
    IF vr_tab_lim_desconto(pr_inpessoa).pctollim_c <> pr_pctollim_c THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a tolencia para limite excedido no contrato CECRED de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).pctollim_c) || 
                                    ' para ' || to_char(pr_pctollim_c)); 
    END IF;
    
    IF ((vr_tab_lim_desconto(pr_inpessoa).qtdiasli <> pr_qtdiasli) OR 
        (vr_tab_lim_desconto(pr_inpessoa).horalimt <> pr_horalimt) OR
        (vr_tab_lim_desconto(pr_inpessoa).minlimit <> pr_minlimit)) THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a quantidade de dias/hora limite para resgate de cheque de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiasli,'FM99') || ' dia(s) ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).horalimt,'FM99') || ':' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).minlimit,'FM00')   || 'h para ' ||
                                    
                                    to_char(pr_qtdiasli,'FM99') || ' dia(s) ' ||
                                    to_char(pr_horalimt,'FM99') || ':' ||
                                    to_char(pr_minlimit,'FM00') || 'h'); 
      
    END IF;
    
    IF ((vr_tab_lim_desconto(pr_inpessoa).qtdiasli_c <> pr_qtdiasli_c) OR 
        (vr_tab_lim_desconto(pr_inpessoa).horalimt_c <> pr_horalimt_c) OR
        (vr_tab_lim_desconto(pr_inpessoa).minlimit_c <> pr_minlimit_c)) THEN
      
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou a quantidade de dias/hora limite para resgate de cheque CECRED de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).qtdiasli_c,'FM99') || ' dia(s) ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).horalimt_c,'FM99') || ':' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).minlimit_c,'FM00')   || 'h para ' ||
                                    
                                    to_char(pr_qtdiasli_c,'FM99') || ' dia(s) ' ||
                                    to_char(pr_horalimt_c,'FM99') || ':' ||
                                    to_char(pr_minlimit_c,'FM00') || 'h');   
    END IF;
    
    -- Flemipar    -- Verificar se Emitente é Conjugue do Cooperado
    IF vr_tab_lim_desconto(pr_inpessoa).flemipar <> pr_Flemipar THEN
      IF pr_inpessoa = 1 THEN
        vr_dsccampo := 'indicador se Verifica se Emitente é Conjugue do Cooperado';
      ELSE
        vr_dsccampo := 'indicador se Verifica se Emitente é Sócio do Cooperado';
      END IF;  
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    fn_retdsind(vr_tab_lim_desconto(pr_inpessoa).flemipar) || 
                                    ' para ' || fn_retdsind(pr_flemipar)); 
    END IF;
    
    -- Flemipar_c    -- Verificar se Emitente é Conjugue do Cooperado
    IF vr_tab_lim_desconto(pr_inpessoa).flemipar_c <> pr_Flemipar_c THEN
      IF pr_inpessoa = 1 THEN
        vr_dsccampo := 'indicador se Verifica se Emitente é Conjugue do Cooperado CECRED';
      ELSE
        vr_dsccampo := 'indicador se Verifica se Emitente é Sócio do Cooperado CECRED';
      END IF;
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    fn_retdsind(vr_tab_lim_desconto(pr_inpessoa).flemipar_c) || 
                                    ' para ' || fn_retdsind(pr_flemipar_c)); 
    END IF;
        
    --Przmxcmp    -- Prazo Máximo de Compensação    
    IF vr_tab_lim_desconto(pr_inpessoa).Przmxcmp <> pr_Przmxcmp THEN
      vr_dsccampo := 'Prazo Máximo de Compensação';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Przmxcmp) || 
                                    ' para ' || to_char(pr_Przmxcmp)); 
    END IF;
    
    --Przmxcmp_c  -- Prazo Máximo de Compensação
    IF vr_tab_lim_desconto(pr_inpessoa).Przmxcmp_c <> pr_Przmxcmp_c THEN
      vr_dsccampo := 'Prazo Máximo de Compensação CECRED';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Przmxcmp_c) || 
                                    ' para ' || to_char(pr_Przmxcmp_c)); 
    END IF;
    
    --Flpjzemi    -- Verificar Prejuízo do Emitente
    IF vr_tab_lim_desconto(pr_inpessoa).Flpjzemi <> pr_Flpjzemi THEN
      vr_dsccampo := 'indicador Verificar Prejuízo do Emitente';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    fn_retdsind(vr_tab_lim_desconto(pr_inpessoa).Flpjzemi) || 
                                    ' para ' || fn_retdsind(pr_Flpjzemi)); 
    END IF; 
     
     
    -- Flpjzemi_c  -- Verificar Prejuízo do Emitente
    IF vr_tab_lim_desconto(pr_inpessoa).Flpjzemi_c <> pr_Flpjzemi_c THEN
      vr_dsccampo := 'indicador Verificar Prejuízo do Emitente CECRED';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    fn_retdsind(vr_tab_lim_desconto(pr_inpessoa).Flpjzemi_c) || 
                                    ' para ' || fn_retdsind(pr_Flpjzemi_c)); 
    END IF;   
     
    -- Flemisol -- Verificar Emitente x Conta Solicitante
    IF vr_tab_lim_desconto(pr_inpessoa).Flemisol <> pr_Flemisol THEN
      vr_dsccampo := 'indicador Verificar Emitente x Conta Solicitante';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    fn_retdsind(vr_tab_lim_desconto(pr_inpessoa).Flemisol) || 
                                    ' para ' || fn_retdsind(pr_Flemisol)); 
    END IF; 
    
    -- Flemisol -- Verificar Emitente x Conta Solicitante
    IF vr_tab_lim_desconto(pr_inpessoa).Flemisol_c <> pr_Flemisol_c THEN
      vr_dsccampo := 'indicador Verificar Emitente x Conta Solicitante CECRED';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    fn_retdsind(vr_tab_lim_desconto(pr_inpessoa).Flemisol_c) || 
                                    ' para ' || fn_retdsind(pr_Flemisol_c)); 
    END IF;
    
    -- Prcliqui  -- Percentual de Liquidez
    IF vr_tab_lim_desconto(pr_inpessoa).Prcliqui <> pr_Prcliqui THEN
      vr_dsccampo := 'Percentual de Liquidez';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Prcliqui) || 
                                    ' para ' || to_char(pr_Prcliqui)); 
    END IF;
    
    -- Prcliqui  -- Percentual de Liquidez
    IF vr_tab_lim_desconto(pr_inpessoa).Prcliqui_c <> pr_Prcliqui_c THEN
      vr_dsccampo := 'Percentual de Liquidez CECRED';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Prcliqui_c) || 
                                    ' para ' || to_char(pr_Prcliqui_c)); 
    END IF;
    
    --Qtmesliq    -- Qtd. Meses Cálculo Percentual de Liquidez
    IF vr_tab_lim_desconto(pr_inpessoa).Qtmesliq <> pr_Qtmesliq THEN
      vr_dsccampo := 'Qtd. Meses Cálculo Percentual de Liquidez';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Qtmesliq) || 
                                    ' para ' || to_char(pr_Qtmesliq)); 
    END IF;
    
    --Qtmesliq    -- Qtd. Meses Cálculo Percentual de Liquidez
    IF vr_tab_lim_desconto(pr_inpessoa).Qtmesliq_c <> pr_Qtmesliq_c THEN
      vr_dsccampo := 'Qtd. Meses Cálculo Percentual de Liquidez CECRED';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Qtmesliq_c) || 
                                    ' para ' || to_char(pr_Qtmesliq_c)); 
    END IF;
        
    -- Vlrenlim    -- Renda x Limite Desconto
    IF vr_tab_lim_desconto(pr_inpessoa).Vlrenlim <> pr_Vlrenlim THEN
      vr_dsccampo := 'Renda x Limite Desconto';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Vlrenlim) || 
                                    ' para ' || to_char(pr_Vlrenlim)); 
    END IF; 
     
    -- Vlrenlim    -- Renda x Limite Desconto
    IF vr_tab_lim_desconto(pr_inpessoa).Vlrenlim_c <> pr_Vlrenlim_c THEN
      vr_dsccampo := 'Renda x Limite Desconto CECRED';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Vlrenlim_c) || 
                                    ' para ' || to_char(pr_Vlrenlim_c)); 
    END IF;
        
    -- Qtmxrede    -- Qtd. Máxima Redesconto    
    IF vr_tab_lim_desconto(pr_inpessoa).Qtmxrede <> pr_Qtmxrede THEN
      vr_dsccampo := 'Qtd. Máxima Redesconto';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Qtmxrede) || 
                                    ' para ' || to_char(pr_Qtmxrede)); 
    END IF;
    
    -- Qtmxrede    -- Qtd. Máxima Redesconto    
    IF vr_tab_lim_desconto(pr_inpessoa).Qtmxrede_c <> pr_Qtmxrede_c THEN
      vr_dsccampo := 'Qtd. Máxima Redesconto CECRED';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Qtmxrede_c) || 
                                    ' para ' || to_char(pr_Qtmxrede_c)); 
    END IF;
    
    -- Fldchqdv -- Permitir Desconto Cheque Devolvido
    IF vr_tab_lim_desconto(pr_inpessoa).Fldchqdv <> pr_Fldchqdv THEN
      vr_dsccampo := 'indicador Permitir Desconto Cheque Devolvido';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    fn_retdsind(vr_tab_lim_desconto(pr_inpessoa).Fldchqdv) || 
                                    ' para ' || fn_retdsind(pr_Fldchqdv)); 
    END IF;
    
    -- Fldchqdv -- Permitir Desconto Cheque Devolvido
    IF vr_tab_lim_desconto(pr_inpessoa).Fldchqdv_c <> pr_Fldchqdv_c THEN
      vr_dsccampo := 'indicador Permitir Desconto Cheque Devolvido';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    fn_retdsind(vr_tab_lim_desconto(pr_inpessoa).Fldchqdv_c) || 
                                    ' para ' || fn_retdsind(pr_Fldchqdv_c)); 
    END IF;
    
    -- Vlmxassi    -- Valor Máximo Dispensa Assinatura
    IF vr_tab_lim_desconto(pr_inpessoa).Vlmxassi <> pr_Vlmxassi THEN
      vr_dsccampo := 'Valor Máximo Dispensa Assinatura';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Vlmxassi) || 
                                    ' para ' || to_char(pr_Vlmxassi)); 
    END IF;
    
    -- Vlmxassi    -- Valor Máximo Dispensa Assinatura
    IF vr_tab_lim_desconto(pr_inpessoa).Vlmxassi_c <> pr_Vlmxassi_c THEN
      vr_dsccampo := 'Valor Máximo Dispensa Assinatura';
      --> gerar log da tela
      pc_log_tab019(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou '|| vr_dsccampo ||' de ' ||
                                    to_char(vr_tab_lim_desconto(pr_inpessoa).Vlmxassi_c) || 
                                    ' para ' || to_char(pr_Vlmxassi_c)); 
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
  END pc_alterar_tab019;

END TELA_TAB019;
/
