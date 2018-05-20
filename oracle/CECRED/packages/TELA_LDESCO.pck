CREATE OR REPLACE PACKAGE CECRED.TELA_LDESCO IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CONPRO
  --  Sistema  : Rotinas utilizadas pela Tela COMPRO
  --  Sigla    : EMPR
  --  Autor    : Daniel Zimmermann
  --  Data     : Março - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela CONPRO
  --
  -- Alteracoes: 11/10/2017 - Inclusao dos campos Modelo e % Mínimo Garantia na tela.
  --                          (Lombardi - PRJ404)
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  TYPE typ_reg_crawepr IS RECORD(
    cdcooper        tbepr_cobranca.cdcooper%TYPE,
    cdagenci        crapass.cdagenci%TYPE,
    nrctremp        tbepr_cobranca.nrctremp%TYPE,
    nrdconta        tbepr_cobranca.nrdconta%TYPE,
    vlemprst        NUMBER,
    qtpreemp        NUMBER,
    cdlcremp        crawepr.cdlcremp%TYPE,
    dtmvtolt        VARCHAR2(30),
    hrmvtolt        VARCHAR2(50),
    insitapr        VARCHAR2(40),
    dtenvest        VARCHAR2(50),
    hrenvest        VARCHAR2(50),
    insitest        VARCHAR2(50),
    parecer_ayllos  VARCHAR2(30),
    situacao_ayllos VARCHAR2(50),
    parecer_esteira VARCHAR2(50),
    cdopeste        VARCHAR2(50),
    nmoperad        VARCHAR2(50),
    nmorigem        VARCHAR2(50),
    efetivada       VARCHAR2(50),
    nmresage        VARCHAR2(50), --);
    
    acionamento VARCHAR2(100),
    nmagenci    VARCHAR2(100),
    cdoperad    VARCHAR2(100),
    operacao    VARCHAR2(100),
    -- dtmvtolt'); ?></td>
    retorno VARCHAR2(100)
    
    );

  -- Definicao de tabela que compreende os registros acima declarados
  TYPE typ_tab_crawepr IS TABLE OF typ_reg_crawepr INDEX BY BINARY_INTEGER;

  PROCEDURE pc_consulta_web(pr_cddopcao IN VARCHAR2
                           ,pr_cddlinha IN NUMBER
                           ,pr_tpdescto IN NUMBER
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_calcula_taxa(pr_txmensal IN NUMBER
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_excluir_linha(pr_cddlinha IN NUMBER
                            ,pr_tpdescto IN NUMBER
                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_atualizar_linha(pr_cddlinha IN NUMBER
                              ,pr_tpdescto IN NUMBER
                              ,pr_dsdlinha IN VARCHAR2
                              ,pr_txmensal IN NUMBER
                              ,pr_txjurmor IN NUMBER
                              ,pr_nrdevias IN NUMBER
                              ,pr_flgtarif IN NUMBER
                              ,pr_permingr IN crapldc.permingr%TYPE
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_incluir_linha(pr_cddlinha IN NUMBER
                            ,pr_tpdescto IN NUMBER
                            ,pr_dsdlinha IN VARCHAR2
                            ,pr_txmensal IN NUMBER
                            ,pr_txjurmor IN NUMBER
                            ,pr_nrdevias IN NUMBER
                            ,pr_flgtarif IN NUMBER
                            ,pr_tpctrato IN crapldc.tpctrato%TYPE
                            ,pr_permingr IN crapldc.permingr%TYPE
                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_lib_bloq_linha(pr_cddopcao IN VARCHAR2
                             ,pr_cddlinha IN NUMBER
                             ,pr_tpdescto IN NUMBER
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);

END TELA_LDESCO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_LDESCO IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_LDESCO
  --  Sistema  : Rotinas utilizadas pela Tela LDESCO
  --  Sigla    : EMPR
  --  Autor    : Daniel Zimmermann
  --  Data     : Março - 2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela LDESCO
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_consulta_web(pr_cddopcao IN VARCHAR2
                           ,pr_cddlinha IN NUMBER
                           ,pr_tpdescto IN NUMBER
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
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
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
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
    
      CURSOR cr_crapldc(pr_cdcooper IN crapldc.cdcooper%TYPE
                       ,pr_cddlinha IN crapldc.cddlinha%TYPE
                       ,pr_tpdescto IN crapldc.tpdescto%TYPE) IS
        SELECT DECODE(ldc.flgstlcr, 1, 'LIBERADA', 0, 'BLOQUEADA') dssitlcr,
               ldc.cddlinha,
               ldc.tpdescto,
               ldc.dsdlinha,
               ldc.txjurmor,
               ldc.nrdevias,
               ldc.txmensal,
               ldc.flgtarif,
               ldc.txdiaria,
               DECODE(ldc.flgsaldo, 1, ' COM SALDO', 0, ' SEM SALDO') flgsaldo,
               ldc.tpctrato,
               ldc.permingr
          FROM crapldc ldc
         WHERE ldc.cdcooper = pr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = pr_tpdescto;
      rw_crapldc cr_crapldc%ROWTYPE;
    
    BEGIN
      
      GENE0001.pc_informa_acesso(pr_module => 'LDESCO' 
                                ,pr_action => null);  
    
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
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_crapldc(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha,
                      pr_tpdescto => pr_tpdescto);
      FETCH cr_crapldc
        INTO rw_crapldc;
    
      -- Se nao encontrar
      IF cr_crapldc%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapldc;
      
        IF pr_cddopcao = 'IC' THEN
          RETURN;
        END IF;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Linha nao encontrada!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      ELSE
        IF pr_cddopcao = 'IC' THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Codigo já utilizado!';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        END IF;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_crapldc;
    
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
                             pr_tag_nova => 'dsdlinha',
                             pr_tag_cont => rw_crapldc.dsdlinha,
                             pr_des_erro => vr_dscritic);
    
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'txjurmor',
                             pr_tag_cont => to_char(rw_crapldc.txjurmor,
                                                    '990D000000',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nrdevias',
                             pr_tag_cont => rw_crapldc.nrdevias,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'txmensal',
                             pr_tag_cont => to_char(rw_crapldc.txmensal,
                                                    '990D000000',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'flgtarif',
                             pr_tag_cont => rw_crapldc.flgtarif,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'tpctrato',
                             pr_tag_cont => rw_crapldc.tpctrato,
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'permingr',
                             pr_tag_cont => to_char(rw_crapldc.permingr,
                                                    '990D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'txdiaria',
                             pr_tag_cont => to_char(rw_crapldc.txdiaria,
                                                    '990D0000000',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dssitlcr',
                             pr_tag_cont => rw_crapldc.dssitlcr || rw_crapldc.flgsaldo,
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
    END;
  END pc_consulta_web;

  PROCEDURE pc_calcula_taxa(pr_txmensal IN NUMBER
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_calcula_taxa
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para calcular taxa de juros
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
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
    
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
      vr_txdiaria NUMBER;
    
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
    
      -- Calcula Taxa Diaria
      vr_txdiaria := ROUND((POWER(1 + (pr_txmensal / 100), 1 / 30) - 1) * 100, 7);
    
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
                             pr_tag_nova => 'txdiaria',
                             pr_tag_cont => to_char(vr_txdiaria,
                                                    '990D0000000',
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
    END;
  END pc_calcula_taxa;

  PROCEDURE pc_excluir_linha(pr_cddlinha IN NUMBER
                            ,pr_tpdescto IN NUMBER
                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_excluir_linha
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para excluir linha Desconto
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
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
    
      vr_comando   VARCHAR2(4000);
      vr_nmdireto  VARCHAR2(200);
      vr_typ_saida VARCHAR2(3);
    
      CURSOR cr_crapldc(pr_cdcooper IN crapldc.cdcooper%TYPE
                       ,pr_cddlinha IN crapldc.cddlinha%TYPE
                       ,pr_tpdescto IN crapldc.tpdescto%TYPE) IS
        SELECT ldc.cdcooper,
               ldc.cddlinha,
               ldc.tpdescto,
               ldc.txmensal
          FROM crapldc ldc
         WHERE ldc.cdcooper = pr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = pr_tpdescto;
      rw_crapldc cr_crapldc%ROWTYPE;
    
      CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                       ,pr_cddlinha IN craplim.cddlinha%TYPE
                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
        SELECT lim.cdcooper
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.cddlinha = pr_cddlinha
           AND lim.tpctrlim = pr_tpctrlim;
      rw_craplim cr_craplim%ROWTYPE;
    
      -- Cursor generico de calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
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
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_crapldc(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha,
                      pr_tpdescto => pr_tpdescto);
      FETCH cr_crapldc
        INTO rw_crapldc;
    
      -- Se nao encontrar
      IF cr_crapldc%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapldc;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Linha nao encontrada!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_crapldc;
    
      OPEN cr_craplim(pr_cdcooper => rw_crapldc.cdcooper,
                      pr_cddlinha => rw_crapldc.cddlinha,
                      pr_tpctrlim => rw_crapldc.tpdescto);
      FETCH cr_craplim
        INTO rw_craplim;
    
      -- Se nao encontrar
      IF cr_craplim%FOUND THEN
        -- Fechar o cursor
        CLOSE cr_craplim;
      
        -- Montar mensagem de critica
        vr_cdcritic := 377;
        vr_dscritic := '';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_craplim;
    
      BEGIN
        DELETE FROM crapldc ldc
         WHERE ldc.cdcooper = vr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = pr_tpdescto;
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao excluir Linha de Desconto!';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        
      END;
    
      -- Define o diretório do arquivo
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,
                                           pr_cdcooper => vr_cdcooper);
    
      vr_comando := 'echo ' || to_char(trunc(rw_crapdat.dtmvtolt), 'DD/MM/YYYY') || ' as ' ||
                    to_char(SYSDATE, 'hh24:mi:ss') || ' - Excluindo linha de desconto ' ||
                    to_char(pr_cddlinha) || ' - ' || 'com taxa mensal de ' ||
                    to_char(rw_crapldc.txmensal) || ' por ' || vr_cdoperad || ' >> ' || vr_nmdireto ||
                    '/log/ldesco.log';
    
      GENE0001.pc_OScommand(pr_typ_comando => 'S',
                            pr_des_comando => vr_comando,
                            pr_typ_saida   => vr_typ_saida,
                            pr_des_saida   => pr_dscritic,
                            pr_flg_aguard  => 'S');
    
      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'Erro ao gerar registro de log.';
        RAISE vr_exc_saida;
      END IF;
    
      COMMIT;
      /*
            UNIX SILENT VALUE("echo " + 
                              STRING(glb_dtmvtolt,"99/99/9999") + " as " +
                              STRING(TIME,"HH:MM:SS") + " - " + 
                              "Excluindo linha de desconto " +
                              STRING(tel_cddlinha,"999") + " - " +
                              tel_dsdlinha + " com taxa mensal de " +
                              STRING(tel_txmensal,"zz9.999999") + " por " +
                              glb_cdoperad + "-" + glb_nmoperad +
                              " >> log/ldesco.log").
      */
    
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
    END;
  END pc_excluir_linha;

  PROCEDURE pc_atualizar_linha(pr_cddlinha IN NUMBER
                              ,pr_tpdescto IN NUMBER
                              ,pr_dsdlinha IN VARCHAR2
                              ,pr_txmensal IN NUMBER
                              ,pr_txjurmor IN NUMBER
                              ,pr_nrdevias IN NUMBER
                              ,pr_flgtarif IN NUMBER
                              ,pr_permingr IN crapldc.permingr%TYPE
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_atualizar_linha
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para atualizar linha Desconto
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
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
    
      vr_txdiaria NUMBER;
      vr_permingr crapldc.permingr%TYPE;
    
      vr_comando VARCHAR2(4000);
    
      vr_nmdireto VARCHAR2(200);
    
      vr_typ_saida VARCHAR2(3);
    
      CURSOR cr_crapldc(pr_cdcooper IN crapldc.cdcooper%TYPE
                       ,pr_cddlinha IN crapldc.cddlinha%TYPE
                       ,pr_tpdescto IN crapldc.tpdescto%TYPE) IS
        SELECT ldc.cdcooper,
               ldc.cddlinha,
               ldc.tpdescto,
               ldc.txmensal,
               ldc.tpctrato,
               ldc.permingr
          FROM crapldc ldc
         WHERE ldc.cdcooper = pr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = pr_tpdescto;
      rw_crapldc cr_crapldc%ROWTYPE;
    
      -- Cursor generico de calendario
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    BEGIN
      
      GENE0001.pc_informa_acesso(pr_module => 'LDESCO' 
                                ,pr_action => null);
      
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
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_crapldc(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha,
                      pr_tpdescto => pr_tpdescto);
      FETCH cr_crapldc
        INTO rw_crapldc;
    
      -- Se nao encontrar
      IF cr_crapldc%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapldc;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Linha nao encontrada!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_crapldc;
    
      IF pr_dsdlinha IS NULL THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Descricao da Linha deve ser preenchido!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_nrdevias <= 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Qt. Vias deve ser preenchido!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
            
      IF rw_crapldc.tpctrato <> 4 THEN
        vr_permingr := 0;
      ELSE
        vr_permingr := pr_permingr;
      END IF;
      
      IF rw_crapldc.tpctrato = 4 AND (vr_permingr < 0.01 OR vr_permingr > 300) THEN
        
        vr_dscritic := 'Percentual minimo da cobertura da garantia de aplicacao inválido. Deve ser entre "0.01" e "300".';
        pr_nmdcampo := 'permingr';
          
        RAISE  vr_exc_saida;
        
      END IF;
    
      -- Calcula Taxa Diaria
      vr_txdiaria := ROUND((POWER(1 + (pr_txmensal / 100), 1 / 30) - 1) * 100, 7);
    
      BEGIN
        UPDATE crapldc ldc
           SET ldc.dsdlinha = UPPER(pr_dsdlinha),
               ldc.txmensal = pr_txmensal,
               ldc.txjurmor = pr_txjurmor,
               ldc.nrdevias = pr_nrdevias,
               ldc.flgtarif = pr_flgtarif,
               ldc.txdiaria = vr_txdiaria,
               ldc.permingr = vr_permingr
         WHERE ldc.cdcooper = vr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = pr_tpdescto;
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar Linha de Desconto!';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        
      END;
    
      IF rw_crapldc.txmensal <> pr_txmensal THEN
      
        -- Define o diretório do arquivo
        vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,
                                             pr_cdcooper => vr_cdcooper);
      
        vr_comando := 'echo ' || to_char(trunc(rw_crapdat.dtmvtolt), 'DD/MM/YYYY') || ' as ' ||
                      to_char(SYSDATE, 'hh24:mi:ss') || ' - Linha de desconto ' ||
                      to_char(pr_cddlinha) || ' - ' || 'Descricao ' || to_char(pr_dsdlinha) ||
                      ' - ' || 'Taxa alterada de ' || to_char(rw_crapldc.txmensal) || ' para ' ||
                      to_char(pr_txmensal) || ' por ' || vr_cdoperad || ' >> ' || vr_nmdireto ||
                      '/log/ldesco.log';
      
        GENE0001.pc_OScommand(pr_typ_comando => 'S',
                              pr_des_comando => vr_comando,
                              pr_typ_saida   => vr_typ_saida,
                              pr_des_saida   => pr_dscritic,
                              pr_flg_aguard  => 'S');
      
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao gerar registro de log.';
          RAISE vr_exc_saida;
        END IF;
      
      END IF;
    
      IF rw_crapldc.permingr <> vr_permingr THEN
      
        -- Define o diretório do arquivo
        vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,
                                             pr_cdcooper => vr_cdcooper);
      
        vr_comando := 'echo ' || to_char(trunc(rw_crapdat.dtmvtolt), 'DD/MM/YYYY') || ' as ' ||
                      to_char(SYSDATE, 'hh24:mi:ss') || ' - Linha de desconto ' ||
                      to_char(pr_cddlinha) || ' - ' || 'Descricao ' || to_char(pr_dsdlinha) ||
                      ' - ' || 'Percentual minimo da cobertura da garantia de aplicacao alterado de ' || to_char(rw_crapldc.permingr) || ' para ' ||
                      to_char(vr_permingr) || ' por ' || vr_cdoperad || ' >> ' || vr_nmdireto ||
                      '/log/ldesco.log';
      
        GENE0001.pc_OScommand(pr_typ_comando => 'S',
                              pr_des_comando => vr_comando,
                              pr_typ_saida   => vr_typ_saida,
                              pr_des_saida   => pr_dscritic,
                              pr_flg_aguard  => 'S');
      
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'Erro ao gerar registro de log.';
          RAISE vr_exc_saida;
        END IF;
      
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
    END;
  END pc_atualizar_linha;

  PROCEDURE pc_incluir_linha(pr_cddlinha IN NUMBER
                            ,pr_tpdescto IN NUMBER
                            ,pr_dsdlinha IN VARCHAR2
                            ,pr_txmensal IN NUMBER
                            ,pr_txjurmor IN NUMBER
                            ,pr_nrdevias IN NUMBER
                            ,pr_flgtarif IN NUMBER
                            ,pr_tpctrato IN crapldc.tpctrato%TYPE
                            ,pr_permingr IN crapldc.permingr%TYPE
                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_incluir_linha
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para excluir linha Desconto
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
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
    
      vr_txdiaria NUMBER;
      vr_permingr crapldc.permingr%TYPE;
    
      CURSOR cr_crapldc(pr_cdcooper IN crapldc.cdcooper%TYPE
                       ,pr_cddlinha IN crapldc.cddlinha%TYPE
                       ,pr_tpdescto IN crapldc.tpdescto%TYPE) IS
        SELECT ldc.cdcooper,
               ldc.cddlinha,
               ldc.tpdescto,
               ldc.txmensal
          FROM crapldc ldc
         WHERE ldc.cdcooper = pr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = pr_tpdescto;
      rw_crapldc cr_crapldc%ROWTYPE;
    
    BEGIN
      
    GENE0001.pc_informa_acesso(pr_module => 'LDESCO' 
                              ,pr_action => null);
    
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
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_crapldc(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha,
                      pr_tpdescto => pr_tpdescto);
      FETCH cr_crapldc
        INTO rw_crapldc;
    
      -- Se nao encontrar
      IF cr_crapldc%FOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapldc;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Linha ja cadastrada!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_crapldc;
    
      IF pr_dsdlinha IS NULL THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Descricao da Linha deve ser preenchido!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_nrdevias <= 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Qt. Vias deve ser preenchido!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_tpctrato NOT IN (0,4) THEN
        
        vr_cdcritic := 529;
        pr_nmdcampo := 'tpctrato';
          
        RAISE  vr_exc_saida;
        
      END IF;
      
      IF pr_tpctrato <> 4 THEN
        vr_permingr := 0;
      ELSE
        vr_permingr := pr_permingr;
      END IF;
      
      IF pr_tpctrato = 4 AND (vr_permingr < 0.01 OR vr_permingr > 300) THEN
        
        vr_dscritic := 'Percentual minimo da cobertura da garantia de aplicacao inválido. Deve ser entre "0.01" e "300".';
        pr_nmdcampo := 'permingr';
          
        RAISE  vr_exc_saida;
        
      END IF;
      
      -- Calcular Taxa Diaria
      vr_txdiaria := ROUND((POWER(1 + (pr_txmensal / 100), 1 / 30) - 1) * 100, 7);
    
      BEGIN
        INSERT INTO crapldc ldc
          (ldc.cdcooper,
           ldc.cddlinha,
           ldc.tpdescto,
           ldc.dsdlinha,
           ldc.txmensal,
           ldc.tpctrato,
           ldc.txjurmor,
           ldc.nrdevias,
           ldc.flgtarif,
           ldc.permingr,
           ldc.txdiaria,
           ldc.flgsaldo,
           ldc.flgstlcr)
        VALUES
          (vr_cdcooper,
           pr_cddlinha,
           pr_tpdescto,
           UPPER(pr_dsdlinha),
           pr_txmensal,
           pr_tpctrato,
           pr_txjurmor,
           pr_nrdevias,
           pr_flgtarif,
           vr_permingr,
           vr_txdiaria,
           0,
           1);
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir Linha de Desconto!' || SQLERRM;
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        
      END;
    
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
    END;
  END pc_incluir_linha;

  PROCEDURE pc_lib_bloq_linha(pr_cddopcao IN VARCHAR2
                             ,pr_cddlinha IN NUMBER
                             ,pr_tpdescto IN NUMBER
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_lib_bloq_linha
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para excluir linha Desconto
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
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
    
      vr_flgstlcr NUMBER;
      vr_flgsaldo NUMBER;
    
      CURSOR cr_crapldc(pr_cdcooper IN crapldc.cdcooper%TYPE
                       ,pr_cddlinha IN crapldc.cddlinha%TYPE
                       ,pr_tpdescto IN crapldc.tpdescto%TYPE) IS
        SELECT ldc.cdcooper,
               ldc.cddlinha,
               ldc.tpdescto,
               ldc.txmensal
          FROM crapldc ldc
         WHERE ldc.cdcooper = pr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = pr_tpdescto;
      rw_crapldc cr_crapldc%ROWTYPE;
    
      CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                       ,pr_cddlinha IN craplim.cddlinha%TYPE
                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
        SELECT lim.cdcooper
          FROM craplim lim,
               crapbdc bdc,
               crapcdb cdb
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.cddlinha = pr_cddlinha
           AND lim.tpctrlim = pr_tpctrlim
           AND lim.insitlim = 2 -- Ativa
           AND bdc.cdcooper = lim.cdcooper
           AND bdc.nrdconta = lim.nrdconta
           AND bdc.nrctrlim = lim.nrctrlim
           AND cdb.cdcooper = bdc.cdcooper
           AND cdb.nrdconta = bdc.nrdconta
           AND cdb.nrborder = bdc.nrborder
           AND cdb.dtlibera >= trunc(SYSDATE)
           AND cdb.insitchq = 2; -- Processado
      rw_craplim cr_craplim%ROWTYPE;
    
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
    
      IF pr_cddlinha = 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo da Linha deve ser Informado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      OPEN cr_crapldc(pr_cdcooper => vr_cdcooper,
                      pr_cddlinha => pr_cddlinha,
                      pr_tpdescto => pr_tpdescto);
      FETCH cr_crapldc
        INTO rw_crapldc;
    
      -- Se nao encontrar
      IF cr_crapldc%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapldc;
      
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Linha nao encontrada!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
    
      -- Fechar o cursor
      CLOSE cr_crapldc;
    
      IF pr_cddopcao = 'B' THEN
        vr_flgstlcr := 0; -- Bloqueada
      ELSE
        vr_flgstlcr := 1; -- Liberada
      END IF;
    
      OPEN cr_craplim(pr_cdcooper => rw_crapldc.cdcooper,
                      pr_cddlinha => rw_crapldc.cddlinha,
                      pr_tpctrlim => rw_crapldc.tpdescto);
      FETCH cr_craplim
        INTO rw_craplim;
    
      -- Se nao encontrar
      IF cr_craplim%FOUND THEN
        vr_flgsaldo := 1;
      ELSE
        vr_flgsaldo := 0;
      END IF;
    
      CLOSE cr_craplim;
    
      BEGIN
        UPDATE crapldc ldc
           SET ldc.flgstlcr = vr_flgstlcr,
               ldc.flgsaldo = vr_flgsaldo
         WHERE ldc.cdcooper = vr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = pr_tpdescto;
      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          IF vr_flgstlcr = 0 THEN
            vr_dscritic := 'Erro ao bloquear Linha de Desconto!';
          ELSE
            vr_dscritic := 'Erro ao liberar Linha de Desconto!';
          END IF;
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        
      END;
    
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
    END;
  END pc_lib_bloq_linha;

END TELA_LDESCO;
/
