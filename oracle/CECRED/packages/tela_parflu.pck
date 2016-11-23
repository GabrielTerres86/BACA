CREATE OR REPLACE PACKAGE CECRED.TELA_PARFLU IS

  PROCEDURE pc_busca_conta_sysphera(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_distribuicao(pr_cdconta  IN tbfin_distrib_contas_sysphera.cdconta%TYPE --> Conta Sysphera
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_remessa(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_historicos(pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico
                               ,pr_dshistor IN craphis.dshistor%TYPE --> Descricao do historico
                               ,pr_nriniseq IN PLS_INTEGER --> Numero inicial do registro para enviar
                               ,pr_nrregist IN PLS_INTEGER --> Numero de registros que deverao ser retornados
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_lista_historicos(pr_cdremessa IN tbfin_histor_fluxo_caixa.cdremessa%TYPE --> Remessa de Fluxo de Caixa
                               ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_horario(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                            ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_margem(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_dados_sysphera(pr_cdconta  IN tbfin_conta_sysphera.cdconta%TYPE --> Codigo da Conta Sysphera
                                   ,pr_nmconta  IN tbfin_conta_sysphera.nmconta%TYPE --> Nome da conta Sysphera
                                   ,pr_dspercen IN VARCHAR2 --> Contem os percentuais e prazos
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_dados_histor(pr_cdremessa IN tbfin_remessa_fluxo_caixa.cdremessa%TYPE --> Codigo da remessa
                                 ,pr_nmremessa IN tbfin_remessa_fluxo_caixa.nmremessa%TYPE --> Nome da Remessa
                                 ,pr_tpfluxo_e IN tbfin_remessa_fluxo_caixa.tpfluxo_entrada%TYPE --> Tipo do Fluxo na Entrada (Projetado / Realizado)
                                 ,pr_tpfluxo_s IN tbfin_remessa_fluxo_caixa.tpfluxo_saida%TYPE --> Tipo do Fluxo na Saida (Projetado / Realizado)
                                 ,pr_flremdina IN tbfin_remessa_fluxo_caixa.flremessa_dinamica%TYPE --> Remessa dinamica (0-Nao / 1-Sim)
                                 ,pr_strrehifl IN VARCHAR2 --> Contem os percentuais e prazos
                                 ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_horario(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                            ,pr_dshora   IN VARCHAR2 --> Horario bloqueio
                            ,pr_inallcop IN VARCHAR2 --> Indicador de todas as cooperativas
                            ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_margem(pr_margem_doc IN VARCHAR2 --> Margem SR Doc
                           ,pr_margem_chq IN VARCHAR2 --> Margem SR Cheques
                           ,pr_margem_tit IN VARCHAR2 --> Margem SR Titulos
                           ,pr_devolu_chq IN VARCHAR2 --> Base de Calculo Devolucao Cheques
                           ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

END TELA_PARFLU;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARFLU IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PARFLU
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Outubro - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela PARFLU
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  -- Busca operador
  CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                   ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
    SELECT dsdepart
      FROM crapope
     WHERE crapope.cdcooper = pr_cdcooper
       AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
  rw_crapope cr_crapope%ROWTYPE;

  PROCEDURE pc_busca_conta_sysphera(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_conta_sysphera
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar parametrizacao das contas sysphera.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar as contas sysphera
      CURSOR cr_contas IS
        SELECT cdconta
              ,nmconta
          FROM tbfin_conta_sysphera
      ORDER BY cdconta;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis Gerais
      vr_contador INTEGER := 0;

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de contas
      FOR rw_contas IN cr_contas LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'conta'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'conta'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'cdconta'
                              ,pr_tag_cont => rw_contas.cdconta
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'conta'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmconta'
                              ,pr_tag_cont => rw_contas.nmconta
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_conta_sysphera;

  PROCEDURE pc_busca_distribuicao(pr_cdconta  IN tbfin_distrib_contas_sysphera.cdconta%TYPE --> Conta Sysphera
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_distribuicao
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar distribuicao dos percentuais.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados da parametrizacao
      CURSOR cr_param(pr_cdconta IN tbfin_distrib_contas_sysphera.cdconta%TYPE) IS 
        SELECT cdprazo
              ,perdistrib
          FROM tbfin_distrib_contas_sysphera
         WHERE cdconta = pr_cdconta;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_contador INTEGER := 0;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_busca_distribuicao'
                                ,pr_action => NULL);

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de parametrizacao das distribuicoes de prazos
      FOR rw_param IN cr_param(pr_cdconta => pr_cdconta) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'distrib'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'distrib'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'cdprazo'
                              ,pr_tag_cont => rw_param.cdprazo
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'distrib'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'perdistrib'
                              ,pr_tag_cont => TO_CHAR(rw_param.perdistrib,'fm999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_distribuicao;

  PROCEDURE pc_busca_remessa(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_remessa
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as remessas.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar as remessas
      CURSOR cr_remessas IS
        SELECT cdremessa
              ,nmremessa
              ,tpfluxo_entrada
              ,tpfluxo_saida
              ,flremessa_dinamica
          FROM tbfin_remessa_fluxo_caixa
      ORDER BY cdremessa;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis Gerais
      vr_contador INTEGER := 0;

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de contas
      FOR rw_remessas IN cr_remessas LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'remessa'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'remessa'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'cdremessa'
                              ,pr_tag_cont => rw_remessas.cdremessa
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'remessa'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmremessa'
                              ,pr_tag_cont => rw_remessas.nmremessa
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'remessa'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'tpfluxo_entrada'
                              ,pr_tag_cont => rw_remessas.tpfluxo_entrada
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'remessa'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'tpfluxo_saida'
                              ,pr_tag_cont => rw_remessas.tpfluxo_saida
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'remessa'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'flremessa_dinamica'
                              ,pr_tag_cont => rw_remessas.flremessa_dinamica
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_remessa;

  PROCEDURE pc_busca_historicos(pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico
                               ,pr_dshistor IN craphis.dshistor%TYPE --> Descricao do historico
                               ,pr_nriniseq IN PLS_INTEGER --> Numero inicial do registro para enviar
                               ,pr_nrregist IN PLS_INTEGER --> Numero de registros que deverao ser retornados
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo

    /* .............................................................................

    Programa: pc_busca_historicos
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os historicos.

    Alteracoes: -----
    ..............................................................................*/

      -- Listagem dos historicos
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE
                       ,pr_dshistor IN craphis.dshistor%TYPE) IS
        SELECT cdhistor,
               dshistor,
               DECODE(indebcre,'D','Débito','Crédito') tphistor,
               count(1) over() retorno
          FROM craphis
         WHERE cdcooper = pr_cdcooper
           AND cdhistor = DECODE(NVL(pr_cdhistor,0),0,cdhistor, pr_cdhistor)
           AND (TRIM(pr_dshistor) IS NULL
            OR  dshistor LIKE '%'||pr_dshistor||'%')
         ORDER BY cdhistor;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
    BEGIN
        -- Extrai os dados vindos do XML
        GENE0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

        -- Criar cabeçalho do XML
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        -- Listagem de historicos
        FOR rw_craphis IN cr_craphis(pr_cdcooper => vr_cdcooper
                                    ,pr_cdhistor => pr_cdhistor
                                    ,pr_dshistor => pr_dshistor) LOOP

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
          IF vr_posreg = 1 THEN
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<histor qtregist="' || rw_craphis.retorno || '">');
          END IF;

          -- Enviar somente se a linha for superior a linha inicial
          IF NVL(pr_nriniseq,0) <= vr_posreg THEN

            -- Carrega os dados
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
                                                            '<cdhistor>' || rw_craphis.cdhistor ||'</cdhistor>'||
                                                            '<dshistor>' || rw_craphis.dshistor ||'</dshistor>'||
                                                            '<tphistor>' || rw_craphis.tphistor ||'</tphistor>'||
                                                         '</inf>');
            vr_contador := vr_contador + 1;
          END IF;

          -- Deve-se sair se o total de registros superar o total solicitado
          EXIT WHEN vr_contador > nvl(pr_nrregist,99999);

        END LOOP;

        -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
        IF vr_posreg = 0 THEN
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<histor qtregist="0">');
        END IF;

        -- Encerrar a tag raiz
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</histor></Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na busca do CNAE: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_busca_historicos;

  PROCEDURE pc_lista_historicos(pr_cdremessa IN tbfin_histor_fluxo_caixa.cdremessa%TYPE --> Remessa de Fluxo de Caixa
                               ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_lista_historicos
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar os historicos.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados do historico
      CURSOR cr_historico(pr_cdremessa IN tbfin_histor_fluxo_caixa.cdremessa%TYPE) IS 
        SELECT ch.cdhistor
              ,ch.dshistor
              ,DECODE(ch.indebcre,'D','Débito','Crédito') tphistor
              ,DECODE(th.tpfluxo,'E','Entrada','Saída') tpfluxo
              ,th.cdbccxlt
          FROM tbfin_histor_fluxo_caixa th
              ,craphis ch
         WHERE ch.cdhistor  = th.cdhistor
           AND ch.cdcooper  = 3
           AND th.cdremessa = pr_cdremessa;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_contador INTEGER := 0;

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de historicos
      FOR rw_historico IN cr_historico(pr_cdremessa => pr_cdremessa) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'histor'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'histor'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'cdhistor'
                              ,pr_tag_cont => rw_historico.cdhistor
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'histor'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dshistor'
                              ,pr_tag_cont => rw_historico.dshistor
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'histor'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'tphistor'
                              ,pr_tag_cont => rw_historico.tphistor
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'histor'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'tpfluxo'
                              ,pr_tag_cont => rw_historico.tpfluxo
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'histor'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'cdbccxlt'
                              ,pr_tag_cont => rw_historico.cdbccxlt
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_lista_historicos;

  PROCEDURE pc_busca_horario(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                            ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_horario
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar horario de bloqueio.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_dshora VARCHAR2(5);

    BEGIN
      vr_dshora := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 00
                                             ,pr_cdacesso => 'PARFLUXOFINAN'
                                             ,pr_tpregist => 0);

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'horario'
                            ,pr_tag_cont => vr_dshora
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_horario;

  PROCEDURE pc_busca_margem(pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_margem
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as margens de seguranca.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_dstextab  craptab.dstextab%TYPE;

    BEGIN
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'PARFLUXOFINAN'
                                               ,pr_tpregist => 0);

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'margem_doc'
                            ,pr_tag_cont => GENE0002.fn_busca_entrada(2,vr_dstextab,';')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'margem_chq'
                            ,pr_tag_cont => GENE0002.fn_busca_entrada(3,vr_dstextab,';')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'margem_tit'
                            ,pr_tag_cont => GENE0002.fn_busca_entrada(4,vr_dstextab,';')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'devolu_chq'
                            ,pr_tag_cont => GENE0002.fn_busca_entrada(5,vr_dstextab,';')
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_margem;

  PROCEDURE pc_grava_dados_sysphera(pr_cdconta  IN tbfin_conta_sysphera.cdconta%TYPE --> Codigo da Conta Sysphera
                                   ,pr_nmconta  IN tbfin_conta_sysphera.nmconta%TYPE --> Nome da conta Sysphera
                                   ,pr_dspercen IN VARCHAR2 --> Contem os percentuais e prazos
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados_sysphera
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os dados.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar a conta sysphera
      CURSOR cr_conta(pr_cdconta IN tbfin_conta_sysphera.cdconta%TYPE) IS
        SELECT 1
          FROM tbfin_conta_sysphera
         WHERE cdconta = pr_cdconta;
      rw_conta cr_conta%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_dspercen GENE0002.typ_split;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;

      -- Se NAO fizer parte dos departamentos abaixo
      IF rw_crapope.dsdepart <> 'COORD.ADM/FINANCEIRO' AND
         rw_crapope.dsdepart <> 'TI'                   AND
         rw_crapope.dsdepart <> 'FINANCEIRO'           THEN
        vr_dscritic := 'Permissao de acesso negada.';
        RAISE vr_exc_saida;
      END IF;

      -- Efetua a busca do registro
      OPEN cr_conta(pr_cdconta => pr_cdconta);
      FETCH cr_conta INTO rw_conta;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_conta%FOUND;
      -- Fecha cursor
      CLOSE cr_conta;

      -- Se NAO achou faz raise
      IF NOT vr_blnfound THEN
        vr_dscritic := 'Conta Sysphera nao encontrada.';
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        UPDATE tbfin_conta_sysphera
           SET nmconta = pr_nmconta
         WHERE cdconta = pr_cdconta;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar Conta Sysphera: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      BEGIN
        DELETE
          FROM tbfin_distrib_contas_sysphera
         WHERE cdconta = pr_cdconta;

        vr_dspercen := GENE0002.fn_quebra_string(pr_string  => pr_dspercen
                                                ,pr_delimit => '#');

        FOR vr_ind IN 1..vr_dspercen.COUNT() LOOP
          INSERT INTO tbfin_distrib_contas_sysphera
                     (cdconta
                     ,cdprazo
                     ,perdistrib
                     ,cdoperador
                     ,dtalteracao)
               VALUES(pr_cdconta
                     ,GENE0002.fn_busca_entrada(1,vr_dspercen(vr_ind),'|')
                     ,GENE0002.fn_busca_entrada(2,vr_dspercen(vr_ind),'|')
                     ,vr_cdoperad
                     ,SYSDATE);
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar prazos: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_dados_sysphera;

  PROCEDURE pc_grava_dados_histor(pr_cdremessa IN tbfin_remessa_fluxo_caixa.cdremessa%TYPE --> Codigo da remessa
                                 ,pr_nmremessa IN tbfin_remessa_fluxo_caixa.nmremessa%TYPE --> Nome da Remessa
                                 ,pr_tpfluxo_e IN tbfin_remessa_fluxo_caixa.tpfluxo_entrada%TYPE --> Tipo do Fluxo na Entrada (Projetado / Realizado)
                                 ,pr_tpfluxo_s IN tbfin_remessa_fluxo_caixa.tpfluxo_saida%TYPE --> Tipo do Fluxo na Saida (Projetado / Realizado)
                                 ,pr_flremdina IN tbfin_remessa_fluxo_caixa.flremessa_dinamica%TYPE --> Remessa dinamica (0-Nao / 1-Sim)
                                 ,pr_strrehifl IN VARCHAR2 --> Contem os percentuais e prazos
                                 ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados_histor
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os dados.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar a remessa
      CURSOR cr_remessa(pr_cdremessa IN tbfin_remessa_fluxo_caixa.cdremessa%TYPE) IS
        SELECT 1
          FROM tbfin_remessa_fluxo_caixa
         WHERE cdremessa = pr_cdremessa;
      rw_remessa cr_remessa%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_dsrehifl GENE0002.typ_split;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;

      -- Se NAO fizer parte dos departamentos abaixo
      IF rw_crapope.dsdepart <> 'COORD.ADM/FINANCEIRO' AND
         rw_crapope.dsdepart <> 'TI'                   AND
         rw_crapope.dsdepart <> 'FINANCEIRO'           THEN
        vr_dscritic := 'Permissao de acesso negada.';
        RAISE vr_exc_saida;
      END IF;

      -- Efetua a busca do registro
      OPEN cr_remessa(pr_cdremessa => pr_cdremessa);
      FETCH cr_remessa INTO rw_remessa;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_remessa%FOUND;
      -- Fecha cursor
      CLOSE cr_remessa;

      -- Se nao achou faz raise
      IF NOT vr_blnfound THEN
        vr_dscritic := 'Remessa nao encontrada.';
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        UPDATE tbfin_remessa_fluxo_caixa
           SET nmremessa          = pr_nmremessa
              ,tpfluxo_entrada    = pr_tpfluxo_e
              ,tpfluxo_saida      = pr_tpfluxo_s
              ,flremessa_dinamica = pr_flremdina
         WHERE cdremessa = pr_cdremessa;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar Remessa: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      BEGIN
        DELETE
          FROM tbfin_histor_fluxo_caixa
         WHERE cdremessa = pr_cdremessa;

        vr_dsrehifl := GENE0002.fn_quebra_string(pr_string  => pr_strrehifl
                                                ,pr_delimit => '#');

        FOR vr_ind IN 1..vr_dsrehifl.COUNT() LOOP
          INSERT INTO tbfin_histor_fluxo_caixa
                     (cdremessa
                     ,cdhistor
                     ,tpfluxo
                     ,cdbccxlt
                     ,cdoperador
                     ,dtalteracao)
               VALUES(pr_cdremessa
                     ,GENE0002.fn_busca_entrada(2,vr_dsrehifl(vr_ind),'_')
                     ,GENE0002.fn_busca_entrada(3,vr_dsrehifl(vr_ind),'_')
                     ,GENE0002.fn_busca_entrada(4,vr_dsrehifl(vr_ind),'_')
                     ,vr_cdoperad
                     ,SYSDATE);
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar historicos: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_dados_histor;

  PROCEDURE pc_grava_horario(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                            ,pr_dshora   IN VARCHAR2 --> Horario bloqueio
                            ,pr_inallcop IN VARCHAR2 --> Indicador de todas as cooperativas
                            ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_horario
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar o horario.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cdcooper
          FROM crapcop
         WHERE cdcooper <> 3
           AND flgativo = 1
           AND cdcooper = DECODE(pr_cdcooper, 0, cdcooper, pr_cdcooper);

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis gerais
      vr_dshora   DATE;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;

      -- Se NAO fizer parte dos departamentos abaixo
      IF rw_crapope.dsdepart <> 'COORD.ADM/FINANCEIRO' AND
         rw_crapope.dsdepart <> 'TI'                   AND
         rw_crapope.dsdepart <> 'FINANCEIRO'           THEN
        vr_dscritic := 'Permissao de acesso negada.';
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        vr_dshora := TO_DATE(pr_dshora, 'hh24:mi');
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Horario invalido!';
        RAISE vr_exc_saida;
      END;

      -- Listagem de cooperativa
      FOR rw_crapcop IN cr_crapcop(pr_cdcooper => (CASE WHEN pr_inallcop = 1 THEN 0 ELSE pr_cdcooper END)) LOOP

        BEGIN
          UPDATE craptab
             SET dstextab        = TO_CHAR(vr_dshora,'hh24:mi')
           WHERE cdcooper        = rw_crapcop.cdcooper
             AND UPPER(nmsistem) = 'CRED'
             AND UPPER(tptabela) = 'GENERI'
             AND cdempres        = 00
             AND UPPER(cdacesso) = 'PARFLUXOFINAN'
             AND tpregist        = 0;
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao atualizar PARFLUXOFINAN: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

      END LOOP; -- cr_crapcop

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_horario;

  PROCEDURE pc_grava_margem(pr_margem_doc IN VARCHAR2 --> Margem SR Doc
                           ,pr_margem_chq IN VARCHAR2 --> Margem SR Cheques
                           ,pr_margem_tit IN VARCHAR2 --> Margem SR Titulos
                           ,pr_devolu_chq IN VARCHAR2 --> Base de Calculo Devolucao Cheques
                           ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro   OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_margem
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar o horario.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_dstextab  craptab.dstextab%TYPE;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;

      -- Se NAO fizer parte dos departamentos abaixo
      IF rw_crapope.dsdepart <> 'COORD.ADM/FINANCEIRO' AND
         rw_crapope.dsdepart <> 'TI'                   AND
         rw_crapope.dsdepart <> 'FINANCEIRO'           THEN
        vr_dscritic := 'Permissao de acesso negada.';
        RAISE vr_exc_saida;
      END IF;

      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'PARFLUXOFINAN'
                                               ,pr_tpregist => 0);

      vr_dstextab := GENE0002.fn_busca_entrada(1,vr_dstextab,';')
                  || ';' || pr_margem_doc
                  || ';' || pr_margem_chq
                  || ';' || pr_margem_tit
                  || ';' || pr_devolu_chq;

      BEGIN
        UPDATE craptab
           SET dstextab        = vr_dstextab
         WHERE cdcooper        = 3
           AND UPPER(nmsistem) = 'CRED'
           AND UPPER(tptabela) = 'GENERI'
           AND cdempres        = 00
           AND UPPER(cdacesso) = 'PARFLUXOFINAN'
           AND tpregist        = 0;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar PARFLUXOFINAN: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela PARFLU: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_margem;

END TELA_PARFLU;
/
