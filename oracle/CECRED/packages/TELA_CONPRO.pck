CREATE OR REPLACE PACKAGE CECRED.TELA_CONPRO IS

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
  -- Alteracoes:
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
    retorno VARCHAR2(150),
    nrctrprp NUMBER,
    dsprotocolo VARCHAR2(1000)
    );

  TYPE typ_reg_crapope IS RECORD(
    cdoperad crapope.cdoperad%TYPE,
    nmoperad crapope.nmoperad%TYPE);

  -- Definicao de tabela que compreende os registros acima declarados
  TYPE typ_tab_crawepr IS TABLE OF typ_reg_crawepr INDEX BY BINARY_INTEGER;

  -- Definicao de tabela que compreende os registros acima declarados
  TYPE typ_tab_crapope IS TABLE OF typ_reg_crapope INDEX BY VARCHAR2(20);

  PROCEDURE pc_consulta_proposta_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Nr. Contrato
                                    ,pr_codigopa IN crapass.cdagenci%TYPE --> Nr. PA
                                    ,pr_dtinicio IN VARCHAR2 -->
                                    ,pr_dtafinal IN VARCHAR2 -->
                                    ,pr_insitest IN NUMBER --> 
                                    ,pr_insitefe IN NUMBER --> 
                                    ,pr_insitapr IN NUMBER --> 
                                    ,pr_nriniseq IN NUMBER DEFAULT 1
                                    ,pr_nrregist IN NUMBER DEFAULT 100
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_consulta_proposta(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa
                                ,pr_cdagenci    IN crapass.cdagenci%TYPE DEFAULT 0 --> PA
                                ,pr_nrctremp    IN crawepr.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
                                ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                ,pr_dtinicio    IN DATE DEFAULT NULL
                                ,pr_dtafinal    IN DATE DEFAULT NULL
                                ,pr_insitest    IN NUMBER
                                ,pr_insitefe    IN NUMBER
                                ,pr_insitapr    IN NUMBER
                                ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Cód. Operador
                                ,pr_nrregist    IN NUMBER DEFAULT 1
                                ,pr_nriniseq    IN NUMBER DEFAULT 9999
                                ,pr_cdcritic    OUT crapcri.cdcritic%TYPE --> Cód. da crítica
                                ,pr_dscritic    OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                ,pr_tab_crawepr OUT typ_tab_crawepr
                                ,pr_totalreg    OUT NUMBER);

  PROCEDURE pc_impressao_proposta_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Nr. Contrato
                                     ,pr_codigopa IN crapass.cdagenci%TYPE --> Nr. PA
                                     ,pr_dtinicio IN VARCHAR2 -->
                                     ,pr_dtafinal IN VARCHAR2 -->
                                     ,pr_insitest IN NUMBER --> 
                                     ,pr_insitefe IN NUMBER --> 
                                     ,pr_insitapr IN NUMBER --> 
                                     ,pr_nriniseq IN NUMBER --> 
                                     ,pr_nrregist IN NUMBER --> 
                                     ,pr_xmllog   IN VARCHAR2 -->
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_tela_busca_contratos(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_consulta_acionamento_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Nr. Contrato   
                                       ,pr_dtinicio IN VARCHAR2 -->
                                       ,pr_dtafinal IN VARCHAR2 -->
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_consulta_acionamento(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrctremp    IN crawepr.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
                                   ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                   ,pr_dtinicio    IN DATE DEFAULT NULL
                                   ,pr_dtafinal    IN DATE DEFAULT NULL
                                   ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Cód. Operador
                                   ,pr_cdcritic    OUT crapcri.cdcritic%TYPE --> Cód. da crítica
                                   ,pr_dscritic    OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                   ,pr_tab_crawepr OUT typ_tab_crawepr);

  PROCEDURE pc_gera_arq_detalhe(pr_dsprotocolo IN tbepr_acionamento.dsprotocolo%TYPE -- Protocolo da Analise Automatica na Esteira
                               ,pr_xmllog      IN VARCHAR2                           -- XML com informacoes de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER                        -- Codigo da critica
                               ,pr_dscritic   OUT VARCHAR2                           -- Descricao da critica
                               ,pr_retxml  IN OUT NOCOPY XMLType                     -- Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2                           -- Nome do campo com erro
                               ,pr_des_erro   OUT VARCHAR2);                         -- Erros do processo

END TELA_CONPRO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONPRO IS
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
  -- Alteracoes: 18/04/2017 - Alterações referentes ao projeto 337 - Motor de Crédito. (Reinert)
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_consulta_proposta_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Nr. Contrato
                                    ,pr_codigopa IN crapass.cdagenci%TYPE --> Nr. PA
                                    ,pr_dtinicio IN VARCHAR2 -->
                                    ,pr_dtafinal IN VARCHAR2 -->
                                    ,pr_insitest IN NUMBER --> 
                                    ,pr_insitefe IN NUMBER --> 
                                    ,pr_insitapr IN NUMBER --> 
                                    ,pr_nriniseq IN NUMBER DEFAULT 1
                                    ,pr_nrregist IN NUMBER DEFAULT 100
                                    ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_proposta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para enviar consultar proposta de emprestimo
    
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
    
      -- PL/Table
      vr_tab_crawepr TELA_CONPRO.typ_tab_crawepr; -- PL/Table com os dados retornados da procedure
      vr_ind_crawepr INTEGER := 0; -- Indice para a PL/Table retornada da procedure
    
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    
      vr_dtinicio DATE;
      vr_dtafinal DATE;
    
      vr_totalreg NUMBER;
    
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
    
      vr_dtinicio := to_date(pr_dtinicio, 'DD/MM/RRRR');
      vr_dtafinal := to_date(pr_dtafinal, 'DD/MM/RRRR');
    
      TELA_CONPRO.pc_consulta_proposta(pr_cdcooper    => vr_cdcooper,
                                       pr_cdagenci    => pr_codigopa,
                                       pr_nrctremp    => pr_nrctremp,
                                       pr_nrdconta    => pr_nrdconta,
                                       pr_dtinicio    => vr_dtinicio,
                                       pr_dtafinal    => vr_dtafinal,
                                       pr_insitest    => pr_insitest,
                                       pr_insitefe    => pr_insitefe,
                                       pr_insitapr    => pr_insitapr,
                                       pr_cdoperad    => vr_cdoperad,
                                       pr_nrregist    => pr_nrregist,
                                       pr_nriniseq    => pr_nriniseq,
                                       pr_cdcritic    => vr_cdcritic,
                                       pr_dscritic    => vr_dscritic,
                                       pr_tab_crawepr => vr_tab_crawepr,
                                       pr_totalreg    => vr_totalreg); --> Pl/Table com os dados de cobrança de emprestimos
    
      -- Se retornou alguma crítica
      IF vr_cdcritic <> 0 OR
         vr_dscritic IS NOT NULL THEN
        -- Levantar exceção
        RAISE vr_exc_saida;
      END IF;
    
      -- Se PL/Table possuir algum registro
      IF vr_tab_crawepr.count() > 0 THEN
        -- Atribui registro inicial como indice
        vr_ind_crawepr := vr_tab_crawepr.FIRST;
        -- Se existe registro com o indice inicial
        IF vr_tab_crawepr.exists(vr_ind_crawepr) THEN
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'Dados',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
        
          LOOP
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
                                   pr_tag_nova => 'cdcooper',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).cdcooper,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'cdagenci',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).cdagenci,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nrctremp',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).nrctremp,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nrdconta',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).nrdconta,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'vlemprst',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).vlemprst,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'qtpreemp',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).qtpreemp,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'cdlcremp',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).cdlcremp,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'dtmvtolt',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).dtmvtolt,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'hrmvtolt',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).hrmvtolt,
                                   pr_des_erro => vr_dscritic);
          
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'insitapr',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).insitapr,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'dtenvest',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).dtenvest,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'hrenvest',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).hrenvest,
                                   pr_des_erro => vr_dscritic);
          
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'insitest',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).insitest,
                                   pr_des_erro => vr_dscritic);
          
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'parecer_ayllos',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).parecer_ayllos,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'situacao_ayllos',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).situacao_ayllos,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'parecer_esteira',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).parecer_esteira,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'cdopeste',
                                   pr_tag_cont => TRIM(vr_tab_crawepr(vr_ind_crawepr).cdopeste),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nmoperad',
                                   pr_tag_cont => TRIM(vr_tab_crawepr(vr_ind_crawepr).nmoperad),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nmorigem',
                                   pr_tag_cont => TRIM(vr_tab_crawepr(vr_ind_crawepr).nmorigem),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'efetivada',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).efetivada,
                                   pr_des_erro => vr_dscritic);
          
            -- Sai do loop se for o último registro ou se chegar no número de registros solicitados
            EXIT WHEN(vr_ind_crawepr = vr_tab_crawepr.LAST);
          
            -- Busca próximo indice
            vr_ind_crawepr := vr_tab_crawepr.NEXT(vr_ind_crawepr);
            vr_auxconta    := vr_auxconta + 1;
          
          END LOOP;
          -- Quantidade total de registros
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'Qtdregis',
                                 pr_tag_cont => vr_totalreg, -- vr_tab_crawepr.count(),
                                 pr_des_erro => vr_dscritic);
        END IF;
      ELSE
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Dados nao encontrados!';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
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
  END pc_consulta_proposta_web;

  PROCEDURE pc_consulta_proposta(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa
                                ,pr_cdagenci    IN crapass.cdagenci%TYPE DEFAULT 0 --> PA
                                ,pr_nrctremp    IN crawepr.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
                                ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                ,pr_dtinicio    IN DATE DEFAULT NULL
                                ,pr_dtafinal    IN DATE DEFAULT NULL
                                ,pr_insitest    IN NUMBER
                                ,pr_insitefe    IN NUMBER
                                ,pr_insitapr    IN NUMBER
                                ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Cód. Operador
                                ,pr_nrregist    IN NUMBER --> 
                                ,pr_nriniseq    IN NUMBER --> 
                                ,pr_cdcritic    OUT crapcri.cdcritic%TYPE --> Cód. da crítica
                                ,pr_dscritic    OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                ,pr_tab_crawepr OUT typ_tab_crawepr
                                ,pr_totalreg    OUT NUMBER) IS --> Pl/Table com os dados de cobrança de emprestimos
  BEGIN
    /* .............................................................................
    
      Programa: pc_consulta_proposta
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Daniel Zimmermann
      Data    : Março/16.                    Ultima atualizacao: 15/12/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina referente a busca propostas emprestimo
    
      Observacao: -----
    
      Alteracoes: 15/12/2017 - P337 - SM - Tratar campos de envio Motor e Esteira 
                               separadamente (Marcos-Supero)
    ..............................................................................*/
    DECLARE
      ----------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      vr_dtenvest DATE;
      vr_hrenvest VARCHAR2(10);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      vr_ind_crawepr INTEGER := 0;
    
      vr_tab_crapope TELA_CONPRO.typ_tab_crapope;
    
      ---------------------------- CURSORES -----------------------------------
      CURSOR cr_crawepr IS
        SELECT *
          FROM (SELECT rownum       rnum,
                       epr.cdcooper cdcooper,
                       epr.cdagenci cdagenci,
                       epr.nrctremp nrctremp,
                       epr.nrdconta nrdconta,
                       epr.vlemprst,
                       epr.qtpreemp,
                       epr.cdlcremp,
                       epr.dtmvtolt,
                       epr.hrinclus
                       -- Parecer Ayllos
                      ,
                       DECODE(pac.instatus, 1, 'Baixo@Risco', 2, 'Medio@Risco', 3, 'Alto@Risco') parecer_ayllos,
                       epr.dtenvest,
                       epr.hrenvest,
                       epr.dtenvmot,
                       epr.hrenvmot,
                       
                       -- Situação Ayllos
                       DECODE(epr.insitest,0,'Nao enviada'
														 ,1,'Env. p/@Analise@Autom.'
														 ,2,'Env. p/@Analise@Manual'
														 ,3,'Analise@Finalizada'
														 ,4,'Expirado','') situacao_ayllos
                       -- Parecer esteira
                      ,
                       DECODE(epr.insitapr,
                              0,
                              'Nao@Analisado',
                              1,
                              'Aprov'||decode(epr.cdopeapr,'MOTOR','.@Aut.','ESTEIRA','.@Man.','ada'),
                              2,
                              'Rejeit'||decode(epr.cdopeapr,'MOTOR','.@Aut.','ESTEIRA','.@Man.','ada'),
                              3,
                              'Com@Restricao',
                              4,
                              'Refazer',
                              5,
                              'Derivar',
                              6,
                              'Erro') parecer_esteira
                       
                       --  ,epr.cdopeste cdopeste
                      ,
                       UPPER(epr.cdopeste) cdopeste
                       
                       -- Efetivada verificar CRAPEPR
                       
                      ,
                       UPPER(epr.cdoperad) nmoperad -- Operador Inclusão
                       
                       -- ,epr.cdopeapr -- Origem
                      ,
                       UPPER(epr.cdopeapr) nmorigem
                       
                      ,
                       DECODE((SELECT 1
                                FROM crapepr
                               WHERE crapepr.cdcooper = epr.cdcooper
                                 AND crapepr.nrdconta = epr.nrdconta
                                 AND crapepr.nrctremp = epr.nrctremp),
                              1,
                              'Sim',
                              'Nao') efetivada
                       
                      ,
                       age.nmresage
                
                  FROM crawepr epr,
                       crapass ass,
                       crappac pac,
                       --   crapope ope,
                       crapage age
                 WHERE epr.cdcooper = pr_cdcooper --> Cód. cooperativa
                   AND (pr_cdagenci = 0 OR epr.cdagenci = pr_cdagenci) --> PA
                   AND (NVL(pr_nrdconta, 0) = 0 OR epr.nrdconta = pr_nrdconta) --> Nr. da Conta
                   AND (NVL(pr_nrctremp, 0) = 0 OR epr.nrctremp = pr_nrctremp) --> Nr. Contrato
                   AND (NVL(pr_insitest, 9) = 9 OR epr.insitest = pr_insitest) --> Situação Ayllos
                   AND (NVL(pr_insitapr, 9) = 9 OR epr.insitapr = pr_insitapr) -- Parecer Esteira
                   AND epr.dtmvtolt BETWEEN pr_dtinicio AND pr_dtafinal
                   AND ass.cdcooper = epr.cdcooper
                   AND ass.nrdconta = epr.nrdconta
                   AND pac.nrseqpac(+) = epr.nrseqpac
                      --     AND ope.cdcooper = epr.cdcooper
                      --    AND UPPER(ope.cdoperad) = UPPER(epr.cdoperad)
                   AND age.cdcooper = epr.cdcooper
                   AND age.cdagenci = epr.cdagenci
                   AND rownum <= (pr_nriniseq + pr_nrregist)
                 ORDER BY epr.cdagenci)
         WHERE rnum >= pr_nriniseq;
      rw_crawepr cr_crawepr%ROWTYPE;
    
      CURSOR cr_crapope IS
        SELECT TRIM(LOWER(operador) || ' - ' || INITCAP((SUBSTR(nome, 1, INSTR(nome, ' ') - 1)))) nmoperad,
               UPPER(operador) cdoperad
          FROM (SELECT TRIM(REPLACE(REPLACE(ope.nmoperad, 'CECRED', ' '), '-', ' ')) nome,
                       UPPER(ope.cdoperad) operador
                  FROM crapope ope
                 WHERE ope.cdcooper = pr_cdcooper);
    
      CURSOR cr_crawepr_total IS
        SELECT COUNT(*) total
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper --> Cód. cooperativa
           AND (pr_cdagenci = 0 OR epr.cdagenci = pr_cdagenci) --> PA
           AND (NVL(pr_nrdconta, 0) = 0 OR epr.nrdconta = pr_nrdconta) --> Nr. da Conta
           AND (NVL(pr_nrctremp, 0) = 0 OR epr.nrctremp = pr_nrctremp) --> Nr. Contrato
           AND (NVL(pr_insitest, 9) = 9 OR epr.insitest = pr_insitest) --> Situação Ayllos
           AND (NVL(pr_insitapr, 9) = 9 OR epr.insitapr = pr_insitapr) -- Parecer Esteiral
           AND epr.dtmvtolt BETWEEN pr_dtinicio AND pr_dtafinal;
      rw_crawepr_total cr_crawepr_total%ROWTYPE;
    BEGIN
    
      ---------------------------------- VALIDACOES INICIAIS --------------------------
    
      -- Gera exceção se informar data de inicio e não informar data final e vice-versa
      IF pr_dtinicio IS NULL THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Inicial deve ser informada.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_dtafinal IS NULL THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Final deve ser informada.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_dtafinal < pr_dtinicio THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Final deve ser superior a Data Inicial.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      FOR rw_crapope IN cr_crapope LOOP
      
        vr_tab_crapope(UPPER(rw_crapope.cdoperad)).cdoperad := rw_crapope.cdoperad;
        
        IF UPPER(rw_crapope.nmoperad) IN('MOTOR','ESTEIRA') THEN
          vr_tab_crapope(UPPER(rw_crapope.cdoperad)).nmoperad := INITCAP(rw_crapope.nmoperad);
        ELSE
          vr_tab_crapope(UPPER(rw_crapope.cdoperad)).nmoperad := rw_crapope.nmoperad;
        END IF;  
      
      END LOOP;
    
      OPEN cr_crawepr_total;
      FETCH cr_crawepr_total
        INTO rw_crawepr_total;
    
      IF cr_crawepr_total%FOUND THEN
        pr_totalreg := rw_crawepr_total.total;
      ELSE
        pr_totalreg := 0;
      END IF;
    
      CLOSE cr_crawepr_total;
    
      -- Abre cursor para atribuir os registros encontrados na PL/Table
      FOR rw_crawepr IN cr_crawepr LOOP
      
        -- Verifica Efetivação
        IF pr_insitefe <> 9 THEN
        
          IF pr_insitefe = 1 AND
             rw_crawepr.efetivada <> 'Sim' THEN
            CONTINUE;
          ELSE
            IF pr_insitefe = 0 AND
               rw_crawepr.efetivada <> 'Nao' THEN
              CONTINUE;
            END IF;
          END IF;
        
        END IF;
      
        -- Incrementa contador para utilizar como indice da PL/Table
        vr_ind_crawepr := vr_ind_crawepr + 1;
      
        --    pr_tab_cde(vr_ind_cde).cdcooper := rw_crapcob.cdcooper;
        pr_tab_crawepr(vr_ind_crawepr).cdagenci := rw_crawepr.cdagenci;
        pr_tab_crawepr(vr_ind_crawepr).nrctremp := rw_crawepr.nrctremp;
        pr_tab_crawepr(vr_ind_crawepr).nrdconta := rw_crawepr.nrdconta;
        pr_tab_crawepr(vr_ind_crawepr).vlemprst := rw_crawepr.vlemprst;
        pr_tab_crawepr(vr_ind_crawepr).qtpreemp := rw_crawepr.qtpreemp;
        pr_tab_crawepr(vr_ind_crawepr).cdlcremp := rw_crawepr.cdlcremp;
      
        pr_tab_crawepr(vr_ind_crawepr).dtmvtolt := to_char(rw_crawepr.dtmvtolt, 'DD/MM/YYYY');
        pr_tab_crawepr(vr_ind_crawepr).hrmvtolt := gene0002.fn_calc_hora(rw_crawepr.hrinclus);
      
        -- Enviar data e hora do ultimo envio (Motor ou Esteira)
        IF to_date(to_char(rw_crawepr.dtenvest,'ddmmrrrr')||to_char(rw_crawepr.hrenvest,'fm00000'),'ddmmrrrrsssss')
         > to_date(to_char(rw_crawepr.dtenvmot,'ddmmrrrr')||to_char(rw_crawepr.hrenvmot,'fm00000'),'ddmmrrrrsssss') THEN 
          -- Envio Esteira foi o ultimo 
          vr_dtenvest := rw_crawepr.dtenvest;
        IF rw_crawepr.hrenvest > 0 THEN
          vr_hrenvest := gene0002.fn_calc_hora(rw_crawepr.hrenvest);
        ELSE
          vr_hrenvest := ' ';
        END IF;
      
        ELSE
          -- Envio Motor foi o ultimo 
          vr_dtenvest := rw_crawepr.dtenvmot;
          IF rw_crawepr.hrenvmot > 0 THEN
            vr_hrenvest := gene0002.fn_calc_hora(rw_crawepr.hrenvmot);
          ELSE
            vr_hrenvest := ' ';
          END IF;
        END IF;
        pr_tab_crawepr(vr_ind_crawepr).dtenvest := LPAD(to_char(vr_dtenvest, 'DD/MM/YYYY'),
                                                        10,
                                                        ' ');
        pr_tab_crawepr(vr_ind_crawepr).hrenvest := LPAD(vr_hrenvest, 8, ' ');
      
        pr_tab_crawepr(vr_ind_crawepr).parecer_ayllos := rw_crawepr.parecer_ayllos;
        pr_tab_crawepr(vr_ind_crawepr).situacao_ayllos := rw_crawepr.situacao_ayllos;
        pr_tab_crawepr(vr_ind_crawepr).parecer_esteira := rw_crawepr.parecer_esteira;
      
        IF vr_tab_crapope.EXISTS(rw_crawepr.cdopeste) THEN
        
          pr_tab_crawepr(vr_ind_crawepr).cdopeste := vr_tab_crapope(rw_crawepr.cdopeste).nmoperad;
        ELSE
          pr_tab_crawepr(vr_ind_crawepr).cdopeste := ' ';
        END IF;
      
        IF vr_tab_crapope.EXISTS(rw_crawepr.nmoperad) THEN
          pr_tab_crawepr(vr_ind_crawepr).nmoperad := vr_tab_crapope(rw_crawepr.nmoperad).nmoperad;
        ELSE
          pr_tab_crawepr(vr_ind_crawepr).nmoperad := ' ';
        END IF;
      
        IF vr_tab_crapope.EXISTS(rw_crawepr.nmorigem) THEN
          pr_tab_crawepr(vr_ind_crawepr).nmorigem := vr_tab_crapope(rw_crawepr.nmorigem).nmoperad;
        ELSE
          pr_tab_crawepr(vr_ind_crawepr).nmorigem := ' ';
        END IF;
      
        pr_tab_crawepr(vr_ind_crawepr).efetivada := rw_crawepr.efetivada;
      
        pr_tab_crawepr(vr_ind_crawepr).nmresage := rw_crawepr.nmresage;
      
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se possui código de crítica e não foi informado a descrição
        IF vr_cdcritic <> 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- Busca descrição da crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
      
        -- Atribui exceção para os parametros de crítica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        -- Atribui exceção para os parametros de crítica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_CONPRO.pc_consulta_proposta: ' || SQLERRM;
      
    END;
  END pc_consulta_proposta;

  PROCEDURE pc_impressao_proposta_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Nr. Contrato
                                     ,pr_codigopa IN crapass.cdagenci%TYPE --> Nr. PA
                                     ,pr_dtinicio IN VARCHAR2 -->
                                     ,pr_dtafinal IN VARCHAR2 -->
                                     ,pr_insitest IN NUMBER --> 
                                     ,pr_insitefe IN NUMBER --> 
                                     ,pr_insitapr IN NUMBER --> 
                                     ,pr_nriniseq IN NUMBER --> 
                                     ,pr_nrregist IN NUMBER --> 
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_impressao_proposta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina impressão proposta de emprestimo
    
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
    
      -- PL/Table
      vr_tab_crawepr TELA_CONPRO.typ_tab_crawepr; -- PL/Table com os dados retornados da procedure
      vr_ind_crawepr INTEGER := 0; -- Indice para a PL/Table retornada da procedure
    
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    
      vr_dtinicio DATE;
      vr_dtafinal DATE;
    
      vr_nmdireto VARCHAR2(5000);
    
      vr_nmarqpdf VARCHAR2(100);
    
      vr_tab_erro gene0001.typ_tab_erro;
      vr_des_reto VARCHAR2(3);
    
      vr_clobxml CLOB;
    
      vr_dstextorel VARCHAR2(32600);
      vr_dstexto    VARCHAR2(32600);
    
      vr_totalreg NUMBER;
    
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
    
      vr_dtinicio := to_date(pr_dtinicio, 'DD/MM/RRRR');
      vr_dtafinal := to_date(pr_dtafinal, 'DD/MM/RRRR');
    
      TELA_CONPRO.pc_consulta_proposta(pr_cdcooper    => vr_cdcooper,
                                       pr_cdagenci    => pr_codigopa,
                                       pr_nrctremp    => pr_nrctremp,
                                       pr_nrdconta    => pr_nrdconta,
                                       pr_dtinicio    => vr_dtinicio,
                                       pr_dtafinal    => vr_dtafinal,
                                       pr_insitest    => pr_insitest,
                                       pr_insitefe    => pr_insitefe,
                                       pr_insitapr    => pr_insitapr,
                                       pr_cdoperad    => vr_cdoperad,
                                       pr_nrregist    => pr_nrregist,
                                       pr_nriniseq    => pr_nriniseq,
                                       pr_cdcritic    => vr_cdcritic,
                                       pr_dscritic    => vr_dscritic,
                                       pr_tab_crawepr => vr_tab_crawepr,
                                       pr_totalreg    => vr_totalreg); --> Pl/Table com os dados de cobrança de emprestimos
    
      -- Se retornou alguma crítica
      IF vr_cdcritic <> 0 OR
         vr_dscritic IS NOT NULL THEN
        -- Levantar exceção
        RAISE vr_exc_saida;
      END IF;
    
      -- Inicializar as informações do XML de dados para o relatório
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
    
      -- Se PL/Table possuir algum registro
      IF vr_tab_crawepr.count() > 0 THEN
        -- Atribui registro inicial como indice
        vr_ind_crawepr := vr_tab_crawepr.FIRST;
        -- Se existe registro com o indice inicial
        IF vr_tab_crawepr.exists(vr_ind_crawepr) THEN
          -- Criar cabeçalho do XML
          gene0002.pc_escreve_xml(vr_clobxml,
                                  vr_dstextorel,
                                  '<?xml version="1.0" encoding="UTF-8"?><Root><Dados>');
        
          vr_dstexto := '<dtinicio>' || pr_dtinicio || '</dtinicio>';
          vr_dstexto := vr_dstexto || '<dtafinal>' || pr_dtafinal || '</dtafinal>';
          gene0002.pc_escreve_xml(vr_clobxml, vr_dstextorel, vr_dstexto);
        
          LOOP
          
            -- Insere as tags
            vr_dstexto := '<proposta><cdcooper>' || vr_tab_crawepr(vr_ind_crawepr).cdcooper ||
                          '</cdcooper>';
            vr_dstexto := vr_dstexto || '<cdagenci>' || vr_tab_crawepr(vr_ind_crawepr).cdagenci ||
                          '</cdagenci>';
            vr_dstexto := vr_dstexto || '<nmresage>' || vr_tab_crawepr(vr_ind_crawepr).nmresage ||
                          '</nmresage>';
            vr_dstexto := vr_dstexto || '<nrctremp>' || vr_tab_crawepr(vr_ind_crawepr).nrctremp ||
                          '</nrctremp>';
            vr_dstexto := vr_dstexto || '<nrdconta>' ||
                          TRIM(gene0002.fn_mask_conta(vr_tab_crawepr(vr_ind_crawepr).nrdconta)) ||
                          '</nrdconta>';
            vr_dstexto := vr_dstexto || '<vlemprst>' || vr_tab_crawepr(vr_ind_crawepr).vlemprst ||
                          '</vlemprst>';
            vr_dstexto := vr_dstexto || '<qtpreemp>' || vr_tab_crawepr(vr_ind_crawepr).qtpreemp ||
                          '</qtpreemp>';
            vr_dstexto := vr_dstexto || '<cdlcremp>' || vr_tab_crawepr(vr_ind_crawepr).cdlcremp ||
                          '</cdlcremp>';
            vr_dstexto := vr_dstexto || '<dtmvtolt>' || vr_tab_crawepr(vr_ind_crawepr).dtmvtolt ||
                          '</dtmvtolt>';
            vr_dstexto := vr_dstexto || '<hrmvtolt>' || vr_tab_crawepr(vr_ind_crawepr).hrmvtolt ||
                          '</hrmvtolt>';
            vr_dstexto := vr_dstexto || '<insitapr>' || vr_tab_crawepr(vr_ind_crawepr).insitapr ||
                          '</insitapr>';
            vr_dstexto := vr_dstexto || '<dtenvest>' || vr_tab_crawepr(vr_ind_crawepr).dtenvest ||
                          '</dtenvest>';
            vr_dstexto := vr_dstexto || '<hrenvest>' || vr_tab_crawepr(vr_ind_crawepr).hrenvest ||
                          '</hrenvest>';
            vr_dstexto := vr_dstexto || '<insitest>' || vr_tab_crawepr(vr_ind_crawepr).insitest ||
                          '</insitest>';
          
            vr_dstexto := vr_dstexto || '<parecer_ayllos>' ||
                          REPLACE(vr_tab_crawepr(vr_ind_crawepr).parecer_ayllos, '@', ' ') ||
                          '</parecer_ayllos>';
            vr_dstexto := vr_dstexto || '<situacao_ayllos>' ||
                          REPLACE(vr_tab_crawepr(vr_ind_crawepr).situacao_ayllos, '@', ' ') ||
                          '</situacao_ayllos>';
            vr_dstexto := vr_dstexto || '<parecer_esteira>' ||
                          REPLACE(vr_tab_crawepr(vr_ind_crawepr).parecer_esteira, '@', ' ') ||
                          '</parecer_esteira>';
            vr_dstexto := vr_dstexto || '<cdopeste>' || vr_tab_crawepr(vr_ind_crawepr).cdopeste ||
                          '</cdopeste>';
            vr_dstexto := vr_dstexto || '<nmoperad>' || vr_tab_crawepr(vr_ind_crawepr).nmoperad ||
                          '</nmoperad>';
            vr_dstexto := vr_dstexto || '<nmorigem>' || vr_tab_crawepr(vr_ind_crawepr).nmorigem ||
                          '</nmorigem>';
            vr_dstexto := vr_dstexto || '<efetivada>' || vr_tab_crawepr(vr_ind_crawepr).efetivada ||
                          '</efetivada>';
          
            vr_dstexto := vr_dstexto || '</proposta>';
          
            gene0002.pc_escreve_xml(vr_clobxml, vr_dstextorel, vr_dstexto);
          
            -- Sai do loop se for o último registro ou se chegar no número de registros solicitados
            EXIT WHEN(vr_ind_crawepr = vr_tab_crawepr.LAST);
          
            -- Busca próximo indice
            vr_ind_crawepr := vr_tab_crawepr.NEXT(vr_ind_crawepr);
            vr_auxconta    := vr_auxconta + 1;
          
          END LOOP;
          -- Fechar arquivo XML
          gene0002.pc_escreve_xml(vr_clobxml, vr_dstextorel, '</Dados></Root>', TRUE);
        END IF;
      ELSE
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Dados nao encontrados!';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,
                                           pr_cdcooper => vr_cdcooper --> Cooperativa
                                          ,
                                           pr_nmsubdir => 'rl'); --> Utilizaremos o rl
    
      vr_nmarqpdf := 'rel_proposta' || TO_CHAR(SYSDATE, 'SSSSS') || '.pdf';
    
      -- Gera impressão do boleto
      gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper --> Cooperativa conectada
                                 ,
                                  pr_cdprogra  => 'CONPRO' --> Programa chamador
                                 ,
                                  pr_dtmvtolt  => TRUNC(SYSDATE) --> Data do movimento atual
                                 ,
                                  pr_dsxml     => vr_clobxml --> Arquivo XML de dados
                                 ,
                                  pr_dsxmlnode => '/Root/Dados/proposta' --> Nó base do XML para leitura dos dados
                                 ,
                                  pr_dsjasper  => 'crrl719.jasper' --> Arquivo de layout do iReport
                                 ,
                                  pr_dsparams  => NULL --> Parametros do boleto
                                 ,
                                  pr_dsarqsaid => vr_nmdireto || '/' || vr_nmarqpdf --> Arquivo final com o path
                                 ,
                                  pr_qtcoluna  => 234 --> Colunas do relatorio
                                 ,
                                  pr_cdrelato  => '719' --> Cód. relatório
                                 ,
                                  pr_flg_gerar => 'S' --> gerar PDF
                                 ,
                                  pr_nmformul  => '234col' --> Nome do formulário para impressão
                                 ,
                                  pr_nrcopias  => 1 --> Número de cópias
                                 ,
                                  pr_des_erro  => vr_dscritic); --> Saída com erro
    
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper --Codigo Cooperativa
                                  ,
                                   pr_cdagenci => 1 --Codigo Agencia
                                  ,
                                   pr_nrdcaixa => 1,
                                   pr_nmarqpdf => vr_nmdireto || '/' || vr_nmarqpdf --Nome Arquivo PDF
                                  ,
                                   pr_des_reto => vr_des_reto --Retorno OK/NOK
                                  ,
                                   pr_tab_erro => vr_tab_erro); --Tabela erro
    
      --Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        --Se tem erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Erro ao enviar arquivo para web.';
        END IF;
        --Sair
        RAISE vr_exc_saida;
      END IF;
    
      -- Remover relatorio da pasta rl apos gerar
      gene0001.pc_OScommand(pr_typ_comando => 'S',
                            pr_des_comando => 'rm ' || vr_nmdireto || '/' || vr_nmarqpdf,
                            pr_typ_saida   => vr_des_reto,
                            pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_des_reto = 'ERR' OR
         vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
    
      --Fechar Clob e Liberar Memoria
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);
    
      -- Criar XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
                                     vr_nmarqpdf || '</nmarqpdf>');
    
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
  END pc_impressao_proposta_web;

  PROCEDURE pc_tela_busca_contratos(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
    /* .............................................................................
    
    Programa: pc_tela_busca_contratos
    Sistema : Rotinas referentes ao limite de credito
    Sigla   : LIMI
    Autor   : James Prust Junior
    Data    : Setembro/15.                    Ultima atualizacao: 30/01/2017
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Buscar todos os contratos.
    
    Observacao: -----
    Alteracoes: 30/01/2017 - Alterado para listar todos os tipos de contrato. (Jaison/James - PRJ298)
    ..............................................................................*/
  
    DECLARE
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE) IS
        SELECT nrctremp,
               dtmvtolt,
               vlemprst,
               qtpreemp,
               vlpreemp,
               cdlcremp,
               cdfinemp
          FROM crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta;
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- Variaveis padrao
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_contador PLS_INTEGER := 0;
    
    BEGIN
    
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
    
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
      -- Busca todos os emprestimos de acordo com o numero da conta
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => vr_cdcooper,
                                   pr_nrdconta => pr_nrdconta) LOOP
      
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrctremp',
                               pr_tag_cont => rw_crapepr.nrctremp,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dtmvtolt',
                               pr_tag_cont => TO_CHAR(rw_crapepr.dtmvtolt, 'DD/MM/YYYY'),
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'qtpreemp',
                               pr_tag_cont => rw_crapepr.qtpreemp,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'vlemprst',
                               pr_tag_cont => rw_crapepr.vlemprst,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'vlpreemp',
                               pr_tag_cont => rw_crapepr.vlpreemp,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdlcremp',
                               pr_tag_cont => rw_crapepr.cdlcremp,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdfinemp',
                               pr_tag_cont => rw_crapepr.cdfinemp,
                               pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      
      END LOOP; /* END FOR rw_craplem */
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND
           vr_dscritic IS NULL THEN
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
        pr_dscritic := 'Erro geral em TELA_CONPRO.pc_tela_busca_contratos: ' || SQLERRM;
      
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
    END;
  
  END pc_tela_busca_contratos;

  PROCEDURE pc_consulta_acionamento_web(pr_nrdconta IN crawepr.nrdconta%TYPE --> Nr. da Conta
                                       ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Nr. Contrato   
                                       ,pr_dtinicio IN VARCHAR2 -->
                                       ,pr_dtafinal IN VARCHAR2 -->
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_consulta_proposta_web
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Daniel Zimmermann
        Data    : Março/16.                    Ultima atualizacao: 12/06/2017
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para enviar consultar proposta de emprestimo
    
        Observacao: -----
    
        Alteracoes: 12/06/2017 - Retornar o protocolo. (Jaison/Marcos - PRJ337)
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      -- PL/Table
      vr_tab_crawepr TELA_CONPRO.typ_tab_crawepr; -- PL/Table com os dados retornados da procedure
      vr_ind_crawepr INTEGER := 0; -- Indice para a PL/Table retornada da procedure
    
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
    
      vr_dtinicio DATE;
      vr_dtafinal DATE;
    
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
    
      vr_dtinicio := to_date(pr_dtinicio, 'DD/MM/RRRR');
      vr_dtafinal := to_date(pr_dtafinal, 'DD/MM/RRRR');
    
      TELA_CONPRO.pc_consulta_acionamento(pr_cdcooper    => vr_cdcooper,
                                          pr_nrctremp    => pr_nrctremp,
                                          pr_nrdconta    => pr_nrdconta,
                                          pr_dtinicio    => vr_dtinicio,
                                          pr_dtafinal    => vr_dtafinal,
                                          pr_cdoperad    => vr_cdoperad,
                                          pr_cdcritic    => vr_cdcritic,
                                          pr_dscritic    => vr_dscritic,
                                          pr_tab_crawepr => vr_tab_crawepr);
      -- Se retornou alguma crítica
      IF vr_cdcritic <> 0 OR
         vr_dscritic IS NOT NULL THEN
        -- Levantar exceção
        RAISE vr_exc_saida;
      END IF;
    
      -- Se PL/Table possuir algum registro
      IF vr_tab_crawepr.count() > 0 THEN
        -- Atribui registro inicial como indice
        vr_ind_crawepr := vr_tab_crawepr.FIRST;
        -- Se existe registro com o indice inicial
        IF vr_tab_crawepr.exists(vr_ind_crawepr) THEN
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'Dados',
                                 pr_tag_cont => NULL,
                                 pr_des_erro => vr_dscritic);
        
          LOOP
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
                                   pr_tag_nova => 'acionamento',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).acionamento,
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'parecer_esteira',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).cdagenci,
                                   pr_des_erro => vr_dscritic);
            IF vr_tab_crawepr(vr_ind_crawepr).cdoperad LIKE '%Esteira%' THEN
            
              gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                     pr_tag_pai  => 'inf',
                                     pr_posicao  => vr_auxconta,
                                     pr_tag_nova => 'cdoperad',
                                     pr_tag_cont => 'Esteira',
                                     pr_des_erro => vr_dscritic);
            ELSE
              gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                     pr_tag_pai  => 'inf',
                                     pr_posicao  => vr_auxconta,
                                     pr_tag_nova => 'cdoperad',
                                     pr_tag_cont => TRIM(vr_tab_crawepr(vr_ind_crawepr).cdoperad),
                                     pr_des_erro => vr_dscritic);
            END IF;
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'operacao',
                                   pr_tag_cont => TRIM(vr_tab_crawepr(vr_ind_crawepr).operacao),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'dtmvtolt',
                                   pr_tag_cont => TRIM(vr_tab_crawepr(vr_ind_crawepr).dtmvtolt),
                                   pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'retorno',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).retorno,
                                   pr_des_erro => vr_dscritic);
                                   
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nrctrprp',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).nrctrprp,
                                   pr_des_erro => vr_dscritic);                       
                                                                         
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nmagenci',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).nmagenci,
                                   pr_des_erro => vr_dscritic);
																	 
            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'dsprotocolo',
                                   pr_tag_cont => vr_tab_crawepr(vr_ind_crawepr).dsprotocolo,
                                   pr_des_erro => vr_dscritic);																	 																	 
																	 
            -- Sai do loop se for o último registro ou se chegar no número de registros solicitados
            EXIT WHEN(vr_ind_crawepr = vr_tab_crawepr.LAST);
          
            -- Busca próximo indice
            vr_ind_crawepr := vr_tab_crawepr.NEXT(vr_ind_crawepr);
            vr_auxconta    := vr_auxconta + 1;
          
          END LOOP;
          -- Quantidade total de registros
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'Root',
                                 pr_posicao  => 0,
                                 pr_tag_nova => 'Qtdregis',
                                 pr_tag_cont => vr_tab_crawepr.count(),
                                 pr_des_erro => vr_dscritic);
        END IF;
      ELSE
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Dados nao encontrados!';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
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
  END pc_consulta_acionamento_web;

  PROCEDURE pc_consulta_acionamento(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrctremp    IN crawepr.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
                                   ,pr_nrdconta    IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                   ,pr_dtinicio    IN DATE DEFAULT NULL
                                   ,pr_dtafinal    IN DATE DEFAULT NULL
                                   ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Cód. Operador
                                   ,pr_cdcritic    OUT crapcri.cdcritic%TYPE --> Cód. da crítica
                                   ,pr_dscritic    OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                   ,pr_tab_crawepr OUT typ_tab_crawepr) IS --> Pl/Table com os dados de cobrança de emprestimos
  BEGIN
    /* .............................................................................
    
      Programa: pc_consulta_proposta
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Daniel Zimmermann
      Data    : Março/16.                    Ultima atualizacao: 12/06/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina referente a busca propostas emprestimo
    
      Observacao: -----
    
      Alteracoes: 12/06/2017 - Retornar o protocolo. (Jaison/Marcos - PRJ337)
    ..............................................................................*/
    DECLARE
      ----------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
    
      vr_ind_crawepr INTEGER := 0;
    
      ---------------------------- CURSORES -----------------------------------
      CURSOR cr_cratbepr IS
        SELECT A.Idacionamento Acionamento,
               A.CDCOOPER cdcooper,
               A.NRDCONTA nrdconta,
               A.Nrctrprp nrctrprp,
               INITCAP(TO_CHAR(A.CDAGENCI_ACIONAMENTO) || ' - ' || P.NMRESAGE) nmagenci,
               upper(a.cdoperad) cdoperad,
               INITCAP(TO_CHAR(A.CDOPERAD) || ' - ' ||
                       INITCAP((SUBSTR(TRIM(REPLACE(REPLACE(O.NMOPERAD, 'CECRED', ' '), '-', ' ')),
                                       1,
                                       INSTR(TRIM(REPLACE(REPLACE(O.NMOPERAD, 'CECRED', ' '),
                                                          '-',
                                                          ' ')),
                                             ' ') - 1)))) nmoperad,
               INITCAP(A.DSOPERACAO) operacao,
               A.DHACIONAMENTO dtmvtolt,
               a.dsuriservico,               
               a.dsresposta_requisicao,
							 a.cdstatus_http,
               a.tpacionamento,
               decode(a.tpacionamento,2,a.dsprotocolo,NULL) dsprotocolo
        
          FROM tbepr_acionamento a
        
          LEFT JOIN crapope o
            ON o.cdcooper = a.cdcooper
           AND upper(o.cdoperad) = upper(a.cdoperad)
        
          LEFT JOIN crapass b
            ON b.cdcooper = a.cdcooper
           AND b.nrdconta = a.nrdconta
        
          LEFT JOIN crapage P
            ON a.cdcooper = p.cdcooper
           AND a.cdagenci_acionamento = p.cdagenci
        
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND ( a.nrctrprp = pr_nrctremp OR pr_nrctremp = 0)
           AND trunc(a.DHACIONAMENTO) >= pr_dtinicio
           AND trunc(a.DHACIONAMENTO) <= pr_dtafinal
           AND a.tpacionamento IN(1,2)
		 ORDER BY a.DHACIONAMENTO DESC;
      rw_crawepr cr_cratbepr%ROWTYPE;
      
     -- Descritivo Retorno
     vr_dsretorno VARCHAR2(1000); 
      
    BEGIN
    
      ---------------------------------- VALIDACOES INICIAIS --------------------------
    
      -- Gera exceção se informar data de inicio e não informar data final e vice-versa
      IF pr_dtinicio IS NULL THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Inicial deve ser informada.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_dtafinal IS NULL THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Final deve ser informada.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      IF pr_dtafinal < pr_dtinicio THEN
        -- Monta Crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Data Final deve ser superior a Data Inicial.';
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;
    
      -- Abre cursor para atribuir os registros encontrados na PL/Table
      FOR rw_crawepr IN cr_cratbepr LOOP
      
        -- Incrementa contador para utilizar como indice da PL/Table
        vr_ind_crawepr := vr_ind_crawepr + 1;
      
        -- pr_tab_cde(vr_ind_cde).cdcooper := rw_crapcob.cdcooper;
        pr_tab_crawepr(vr_ind_crawepr).acionamento := rw_crawepr.acionamento;
        pr_tab_crawepr(vr_ind_crawepr).nmagenci := substr(rw_crawepr.nmagenci,1,100);
        pr_tab_crawepr(vr_ind_crawepr).cdoperad := rw_crawepr.nmoperad;
        pr_tab_crawepr(vr_ind_crawepr).operacao := substr(rw_crawepr.operacao,1,100);
        pr_tab_crawepr(vr_ind_crawepr).dtmvtolt := to_char(rw_crawepr.dtmvtolt,
                                                           'DD/MM/YYYY hh24:mi:ss');
      
        vr_dscritic := NULL;
        IF rw_crawepr.CDSTATUS_HTTP = 400 THEN
          vr_dscritic := substr(ESTE0001.fn_retorna_critica(rw_crawepr.DSRESPOSTA_REQUISICAO),1,150);
        END IF;
        -- Se encontramos critica
        IF vr_dscritic IS NOT NULL THEN
          -- Retornaremos a mesma
          vr_dsretorno := vr_dscritic;
        ELSE
          -- Erros HTTP
          IF rw_crawepr.CDSTATUS_HTTP = 401 THEN
            vr_dsretorno := 'Credencias de acesso ao WebService Ibratan invalidas.';
          ELSIF rw_crawepr.CDSTATUS_HTTP = 403 THEN
            vr_dsretorno := 'Sem permissao de acesso ao Webservice Ibratan.';
          ELSIF rw_crawepr.CDSTATUS_HTTP = 404 THEN
            vr_dsretorno := 'Recurso nao encontrado no WebService Ibratan nao existe.';
          ELSIF rw_crawepr.CDSTATUS_HTTP = 412 THEN
            vr_dsretorno := 'Parametros do WebService Ibratan invalidos.';
          ELSIF rw_crawepr.CDSTATUS_HTTP = 429 THEN
            vr_dsretorno := 'Muitas requisicoes de retorno da Analise Automatica da esteira.';
          ELSIF rw_crawepr.CDSTATUS_HTTP BETWEEN 400 AND 499 THEN
            vr_dsretorno := 'Valor do(s) parametro(s) WebService invalidos.';
          ELSIF rw_crawepr.CDSTATUS_HTTP BETWEEN 500 AND 599 THEN
            vr_dsretorno := 'Falha na comunicacao com servico Ibratan.';
          ELSE 
            -- Tratar envios e retornos 
            IF rw_crawepr.CDSTATUS_HTTP = 200 THEN 
              IF INSTR(rw_crawepr.dsuriservico, 'cancelar') > 0 THEN   
                vr_dsretorno := 'Cancelamento da proposta enviado com sucesso para esteira.';
              ELSIF INSTR(rw_crawepr.dsuriservico, 'efetivar') > 0 THEN   
                vr_dsretorno := 'Proposta efetivada foi enviada para esteira com sucesso.';
              ELSIF INSTR(rw_crawepr.dsuriservico, 'numeroProposta') > 0 THEN   
                vr_dsretorno := 'Numero da proposta foi enviado para esteira com sucesso.';
              ELSIF rw_crawepr.cdoperad = 'MOTOR' THEN
                vr_dsretorno := 'Retorno da analise automatica da esteira recebido com sucesso.';
              ELSIF rw_crawepr.tpacionamento = 1 THEN
                vr_dsretorno := 'Proposta reenviada para esteira com sucesso.';  
              END IF;  
            ELSIF rw_crawepr.CDSTATUS_HTTP = 201 THEN
              vr_dsretorno := 'Proposta enviada para analise manual da esteira com sucesso.';
            ELSIF rw_crawepr.CDSTATUS_HTTP = 202 THEN
              -- Se foi no envio
              IF rw_crawepr.tpacionamento = 1 THEN  
                vr_dsretorno := 'Proposta enviada para analise automatica da esteira com sucesso.';
              ELSE
                vr_dsretorno := 'Retorno da analise automatica da esteira recebido com sucesso.';
              END IF;  
            ELSIF rw_crawepr.CDSTATUS_HTTP = 204 THEN
              vr_dsretorno := 'Proposta em processo de analise automatica da esteira.';
            END IF;
          END IF;	
        END IF;
        
        pr_tab_crawepr(vr_ind_crawepr).retorno := substr(vr_dsretorno,1,150);        
        pr_tab_crawepr(vr_ind_crawepr).nrctrprp := rw_crawepr.nrctrprp;
        pr_tab_crawepr(vr_ind_crawepr).dsprotocolo := rw_crawepr.dsprotocolo;
        
      
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se possui código de crítica e não foi informado a descrição
        IF vr_cdcritic <> 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- Busca descrição da crítica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
      
        -- Atribui exceção para os parametros de crítica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        -- Atribui exceção para os parametros de crítica
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_CONPRO.pc_consulta_acionamento: ' || SQLERRM;
      
    END;
  END pc_consulta_acionamento;

  PROCEDURE pc_gera_arq_detalhe(pr_dsprotocolo IN tbepr_acionamento.dsprotocolo%TYPE -- Protocolo da Analise Automatica na Esteira
                               ,pr_xmllog      IN VARCHAR2                           -- XML com informacoes de LOG
                               ,pr_cdcritic   OUT PLS_INTEGER                        -- Codigo da critica
                               ,pr_dscritic   OUT VARCHAR2                           -- Descricao da critica
                               ,pr_retxml  IN OUT NOCOPY XMLType                     -- Arquivo de retorno do XML
                               ,pr_nmdcampo   OUT VARCHAR2                           -- Nome do campo com erro
                               ,pr_des_erro   OUT VARCHAR2) IS                       -- Erros do processo
  /* .............................................................................
  
    Programa: pc_gera_arq_detalhe
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Junho/2017                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gerar o arquivo de detalhes da proposta.

    Alteracoes: 
  ..............................................................................*/

    -- Variaveis Locais
    vr_cdcooper       INTEGER;
    vr_nmdatela       VARCHAR2(100);
    vr_nmeacao        VARCHAR2(100);
    vr_cdagenci       VARCHAR2(100);
    vr_nrdcaixa       VARCHAR2(100);
    vr_idorigem       VARCHAR2(100);
    vr_cdoperad       VARCHAR2(100);
    vr_dsdirarq       VARCHAR2(1000);
    vr_nmarquiv       VARCHAR2(1000);
    vr_dscomando      VARCHAR2(1000);
       
    -- Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3);
    vr_tab_erro GENE0001.typ_tab_erro;
    
    -- Variaveis de Excecao
    vr_exc_saida EXCEPTION;
         
    BEGIN
      -- Inicializar Variavel
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      vr_nmarquiv := pr_dsprotocolo || '.pdf';

      -- Extrair dados do XML de requisicao
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Diretorio para salvar
      vr_dsdirarq := GENE0001.fn_diretorio (pr_tpdireto => 'C' --> usr/coop
                                           ,pr_cdcooper => 3
                                           ,pr_nmsubdir => '/log/webservices'); 

      -- Comando para download
      vr_dscomando := GENE0001.fn_param_sistema('CRED',3,'SCRIPT_DOWNLOAD_PDF_ANL');

      -- Substituir o caminho do arquivo a ser baixado
      vr_dscomando := replace(vr_dscomando
                             ,'[local-name]'
                             ,vr_dsdirarq || '/' || vr_nmarquiv);

      -- Substiruir a URL para Download
      vr_dscomando := REPLACE(vr_dscomando
                             ,'[remote-name]'
                             ,GENE0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA')
                             ||GENE0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA')
                             || '_result/' || pr_dsprotocolo || '/pdf');

      -- Executar comando para Download
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando);

      -- Se NAO encontrou o arquivo
      IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || '/' || vr_nmarquiv) THEN
        vr_dscritic := 'Problema na recepcao do Arquivo - Tente novamente mais tarde!';
        RAISE vr_exc_saida;
      END IF;

      -- Enviar arquivo para Web
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_nmarqpdf => vr_dsdirarq || '/' || vr_nmarquiv
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Erro ao enviar arquivo para web.';  
        END IF;
        RAISE vr_exc_saida;
      END IF;

      -- Comando para remover arquivo
      vr_dscomando := 'rm ' || vr_dsdirarq || '/' || vr_nmarquiv || ' 2>/dev/null';

      -- Remover Arquivo
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_des_reto
                           ,pr_des_saida   => vr_dscritic);
      -- Se ocorreu erro
      IF vr_des_reto = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarquiv, pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_CONPRO: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_gera_arq_detalhe;

END TELA_CONPRO;
/
