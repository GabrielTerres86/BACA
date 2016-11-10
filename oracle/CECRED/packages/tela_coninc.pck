CREATE OR REPLACE PACKAGE CECRED.TELA_CONINC IS

  PROCEDURE pc_busca_departamento(pr_cdcooper IN crapdpo.cdcooper%TYPE --> Cooperativa
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_inconsistencia(pr_cdcooper IN tbgen_inconsist.cdcooper%TYPE --> Cooperativa
                                   ,pr_iddgrupo IN tbgen_inconsist.idinconsist_grp%TYPE --> Codigo do Grupo
                                   ,pr_dtrefini IN VARCHAR2 --> Data inicial
                                   ,pr_dtreffim IN VARCHAR2 --> Data final
                                   ,pr_dsincons IN tbgen_inconsist.dsinconsist%TYPE --> Descricao
                                   ,pr_dsregist IN tbgen_inconsist.dsregistro_referencia%TYPE --> Registro de referencia
                                   ,pr_tpdsaida IN VARCHAR2 --> Tipo de saida: XML / CSV
                                   ,pr_nrregist IN INTEGER --> Numero Registros
                                   ,pr_nriniseq IN INTEGER --> Numero Sequencia Inicial
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_acesso(pr_cdcooper IN tbgen_inconsist_acesso_grp.cdcooper%TYPE --> Cooperativa
                           ,pr_iddgrupo IN tbgen_inconsist_acesso_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                           ,pr_nrregist IN INTEGER --> Numero Registros
                           ,pr_nriniseq IN INTEGER --> Numero Sequencia Inicial
                           ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_email(pr_cdcooper IN tbgen_inconsist_email_grp.cdcooper%TYPE --> Cooperativa
                          ,pr_iddgrupo IN tbgen_inconsist_email_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                          ,pr_nrregist IN INTEGER --> Numero Registros
                          ,pr_nriniseq IN INTEGER --> Numero Sequencia Inicial
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_grupo(pr_iddgrupo IN tbgen_inconsist_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                          ,pr_nrregist IN INTEGER --> Numero Registros
                          ,pr_nriniseq IN INTEGER --> Numero Sequencia Inicial
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_pesquisa_grupo(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                             ,pr_iddgrupo IN tbgen_inconsist_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                             ,pr_nmdgrupo IN tbgen_inconsist_grp.nminconsist_grp%TYPE --> Descricao do Grupo
                             ,pr_cddopcao IN VARCHAR2 --> Opcao selecionada
                             ,pr_nrregist IN PLS_INTEGER --> Numero de registros que deverao ser retornados
                             ,pr_nriniseq IN PLS_INTEGER --> Numero inicial do registro para enviar
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_grupo(pr_iddgrup2 IN tbgen_inconsist_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                          ,pr_nmdgrupo IN tbgen_inconsist_grp.nminconsist_grp%TYPE --> Nome do grupo
                          ,pr_indconte IN tbgen_inconsist_grp.tpconfig_email%TYPE --> (0-Nao enviar e-mail, 1-Somente erros, 2-Erros e alertas)
                          ,pr_dsassunt IN tbgen_inconsist_grp.dsassunto_email%TYPE --> Descricao do assunto do e-mail
                          ,pr_indperio IN tbgen_inconsist_grp.tpperiodicidade_email%TYPE --> Periodicidade (1-OnLine, 2-Diario)
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_grupo(pr_iddgrupo IN tbgen_inconsist_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                           ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_acesso_email(pr_cddopcao IN VARCHAR2 --> Opcao: A-Acesso / E-Email
                                 ,pr_dsoperac IN VARCHAR2 --> Operacao: I-Inclusao / E-Exclusao
                                 ,pr_vlcampos IN VARCHAR2 --> Dados dos campos
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Erros do processo

END TELA_CONINC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONINC IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CONINC
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Novembro - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CONINC
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  -- Busca operador
  CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                   ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
    SELECT dsdepart
      FROM crapope
     WHERE cdcooper = pr_cdcooper
       AND UPPER(cdoperad) = UPPER(pr_cdoperad);
  rw_crapope cr_crapope%ROWTYPE;

  PROCEDURE pc_busca_departamento(pr_cdcooper IN crapdpo.cdcooper%TYPE --> Cooperativa
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_departamento
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar departamentos do operador.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os departamentos
      CURSOR cr_crapdpo(pr_cdcooper IN crapdpo.cdcooper%TYPE) IS
        SELECT cddepart
              ,dsdepart
          FROM crapdpo
         WHERE insitdpo = 1 -- Ativo
           AND cdcooper = DECODE(pr_cdcooper, 0 , cdcooper, pr_cdcooper)
      GROUP BY cddepart
              ,dsdepart
      ORDER BY dsdepart;

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

      -- Listagem de departamentos
      FOR rw_crapdpo IN cr_crapdpo(pr_cdcooper => pr_cdcooper) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'depto'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'depto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'cddepart'
                              ,pr_tag_cont => rw_crapdpo.cddepart
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'depto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dsdepart'
                              ,pr_tag_cont => rw_crapdpo.dsdepart
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CONINC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_departamento;

  PROCEDURE pc_busca_inconsistencia(pr_cdcooper IN tbgen_inconsist.cdcooper%TYPE --> Cooperativa
                                   ,pr_iddgrupo IN tbgen_inconsist.idinconsist_grp%TYPE --> Codigo do Grupo
                                   ,pr_dtrefini IN VARCHAR2 --> Data inicial
                                   ,pr_dtreffim IN VARCHAR2 --> Data final
                                   ,pr_dsincons IN tbgen_inconsist.dsinconsist%TYPE --> Descricao
                                   ,pr_dsregist IN tbgen_inconsist.dsregistro_referencia%TYPE --> Registro de referencia
                                   ,pr_tpdsaida IN VARCHAR2 --> Tipo de saida: XML / CSV
                                   ,pr_nrregist IN INTEGER --> Numero Registros
                                   ,pr_nriniseq IN INTEGER --> Numero Sequencia Inicial
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_inconsistencia
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar as inconsistencias no processo.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar as inconsistencias
      CURSOR cr_inconsistencia(pr_cdcooper IN tbgen_inconsist_acesso_grp.cdcooper%TYPE
                              ,pr_iddgrupo IN tbgen_inconsist_acesso_grp.idinconsist_grp%TYPE
                              ,pr_dsincons IN tbgen_inconsist.dsinconsist%TYPE
                              ,pr_dsregist IN tbgen_inconsist.dsregistro_referencia%TYPE
                              ,pr_dtrefini IN DATE
                              ,pr_dtreffim IN DATE) IS
        SELECT cop.nmrescop
              ,inc.tpinconsist
              ,DECODE(inc.tpinconsist, 1, 'Aviso', 'Erro') dstipinc
              ,inc.dhinconsist
              ,inc.dsinconsist
              ,inc.dsregistro_referencia
          FROM tbgen_inconsist inc
              ,crapcop         cop
         WHERE inc.cdcooper        = cop.cdcooper
           AND inc.cdcooper        = DECODE(pr_cdcooper, 0, inc.cdcooper, pr_cdcooper)
           AND inc.idinconsist_grp = pr_iddgrupo
           AND (TRIM(pr_dsincons) IS NULL OR
                UPPER(inc.dsinconsist) LIKE '%' || UPPER(pr_dsincons) || '%')
           AND (TRIM(pr_dsregist) IS NULL OR
                UPPER(inc.dsregistro_referencia) LIKE '%' || UPPER(pr_dsregist) || '%')
           AND TRUNC(inc.dhinconsist) BETWEEN pr_dtrefini AND pr_dtreffim
      ORDER BY cop.nmrescop;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_tab_erro  GENE0001.typ_tab_erro;
      vr_des_reto  VARCHAR2(10);
      vr_typ_saida VARCHAR2(3);

      -- Variaveis de log
      vr_cdoperad VARCHAR2(100);
      vr_cdcooper NUMBER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis Gerais
      vr_contador INTEGER := 0;
      vr_qtregist INTEGER := 0;
      vr_qtavisos INTEGER := 0;
      vr_qtderros INTEGER := 0;
      vr_nrregist INTEGER := pr_nrregist;
      vr_dtrefini crapdat.dtmvtolt%TYPE;
      vr_dtreffim crapdat.dtmvtolt%TYPE;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      vr_dserro   VARCHAR2(50);
      vr_dsdireto VARCHAR2(100);
      vr_nmarquiv VARCHAR2(100);

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

      -- Saida XML
      IF pr_tpdsaida = 'XML' THEN
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
      -- Saida CSV
      ELSE
        -- Cria a variavel CLOB
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

        -- Busca diretorio base da cooperativa
        vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => vr_cdcooper
                                            ,pr_nmsubdir => '/rl'); -- Gerado no diretorio /rl
        -- Nome do arquivo
        vr_nmarquiv := 'CONINC_' || TO_CHAR(SYSDATE,'HHMISS') || '.csv';

        -- Criar cabecalho do CSV
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => 'Cooperativa;Tipo;Data/Hora;Inconsistencia;Registro de Referencia'||chr(10));
      END IF;

      -- Data de referencia
      vr_dtrefini := TO_DATE(pr_dtrefini,'DD/MM/RRRR');
      vr_dtreffim := TO_DATE(pr_dtreffim,'DD/MM/RRRR');

      -- Listagem de inconsistencias
      FOR rw_inconsistencia IN cr_inconsistencia(pr_cdcooper => pr_cdcooper
                                                ,pr_iddgrupo => pr_iddgrupo
                                                ,pr_dsincons => pr_dsincons 
                                                ,pr_dsregist => pr_dsregist
                                                ,pr_dtrefini => vr_dtrefini
                                                ,pr_dtreffim => vr_dtreffim) LOOP

        -- Saida XML
        IF pr_tpdsaida = 'XML' THEN
          -- Incrementa totais
          IF rw_inconsistencia.tpinconsist = 1 THEN
            vr_qtavisos := vr_qtavisos + 1;
          ELSE 
            vr_qtderros := vr_qtderros + 1;
          END IF;
          
          -- Incrementar contador
          vr_qtregist:= NVL(vr_qtregist,0) + 1;

          -- Controles da paginacao
          IF (vr_qtregist < pr_nriniseq) OR
             (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
            -- Proximo
            CONTINUE;
          END IF;

          -- Numero de Registros
          IF vr_nrregist > 0 THEN

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'inconsistencia'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inconsistencia'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'nmrescop'
                                  ,pr_tag_cont => rw_inconsistencia.nmrescop
                                  ,pr_des_erro => vr_dscritic);

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inconsistencia'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dstipinc'
                                  ,pr_tag_cont => rw_inconsistencia.dstipinc
                                  ,pr_des_erro => vr_dscritic);

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inconsistencia'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dhincons'
                                  ,pr_tag_cont => TO_CHAR(rw_inconsistencia.dhinconsist,'DD/MM/RRRR hh24:mi')
                                  ,pr_des_erro => vr_dscritic);

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inconsistencia'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dsincons'
                                  ,pr_tag_cont => rw_inconsistencia.dsinconsist
                                  ,pr_des_erro => vr_dscritic);

            GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inconsistencia'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dsregist'
                                  ,pr_tag_cont => rw_inconsistencia.dsregistro_referencia
                                  ,pr_des_erro => vr_dscritic);

          END IF; -- vr_nrregist > 0

          -- Diminuir registros
          vr_nrregist:= NVL(vr_nrregist,0) - 1;

          vr_contador := vr_contador + 1;

        -- Saida CSV
        ELSE
          -- Carrega os dados           
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => rw_inconsistencia.nmrescop ||';'||
                                                       rw_inconsistencia.dstipinc ||';'||
                                                       TO_CHAR(rw_inconsistencia.dhinconsist,'DD/MM/RRRR hh24:mi') ||';'||
                                                       rw_inconsistencia.dsinconsist ||';'||
                                                       rw_inconsistencia.dsregistro_referencia || chr(10));
        END IF; -- pr_tpdsaida

      END LOOP; -- cr_grupo

      -- Saida XML
      IF pr_tpdsaida = 'XML' THEN
        -- Insere atributo na tag Dados com a quantidade de registros
        GENE0007.pc_gera_atributo(pr_xml   => pr_retxml
                                 ,pr_tag   => 'Dados'
                                 ,pr_atrib => 'qtregist'
                                 ,pr_atval => vr_qtregist
                                 ,pr_numva => 0
                                 ,pr_des_erro => vr_dscritic);

        -- Atributo contendo quantidade de avisos
        GENE0007.pc_gera_atributo(pr_xml   => pr_retxml
                                 ,pr_tag   => 'Dados'
                                 ,pr_atrib => 'qtavisos'
                                 ,pr_atval => vr_qtavisos
                                 ,pr_numva => 0
                                 ,pr_des_erro => vr_dscritic);

        -- Atributo contendo quantidade de erros
        GENE0007.pc_gera_atributo(pr_xml   => pr_retxml
                                 ,pr_tag   => 'Dados'
                                 ,pr_atrib => 'qtderros'
                                 ,pr_atval => vr_qtderros
                                 ,pr_numva => 0
                                 ,pr_des_erro => vr_dscritic);
      -- Saida CSV
      ELSE
        -- Encerrar o Clob
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => ' '
                               ,pr_fecha_xml      => TRUE);

        -- Gera o relatorio
        GENE0002.pc_clob_para_arquivo(pr_clob     => vr_clob,
                                      pr_caminho  => vr_dsdireto,
                                      pr_arquivo  => vr_nmarquiv,
                                      pr_des_erro => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Copia arquivo do diretorio da cooperativa para servidor web
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_dsdireto || '/' || vr_nmarquiv
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);

        -- Caso apresente erro na operacao
        IF NVL(vr_des_reto,'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
            RAISE vr_exc_saida; -- encerra programa
          END IF;
        END IF;

        -- Remover relatorio do diretorio padrao da cooperativa
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_dsdireto||'/'||vr_nmarquiv
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

        -- Se retornou erro
        IF vr_typ_saida = 'ERR' OR vr_dscritic IS NOT null THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_saida; -- encerra programa
        END IF;

        -- Criar XML de retorno para uso na Web
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqcsv>' || vr_nmarquiv || '</nmarqcsv>');
        
        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);
        dbms_lob.freetemporary(vr_clob);

      END IF; -- pr_tpdsaida

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CONINC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_inconsistencia;

  PROCEDURE pc_busca_acesso(pr_cdcooper IN tbgen_inconsist_acesso_grp.cdcooper%TYPE --> Cooperativa
                           ,pr_iddgrupo IN tbgen_inconsist_acesso_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                           ,pr_nrregist IN INTEGER --> Numero Registros
                           ,pr_nriniseq IN INTEGER --> Numero Sequencia Inicial
                           ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_acesso
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os acessos.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os acessos
      CURSOR cr_acesso(pr_cdcooper IN tbgen_inconsist_acesso_grp.cdcooper%TYPE
                      ,pr_iddgrupo IN tbgen_inconsist_acesso_grp.idinconsist_grp%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,dpo.cddepart
              ,dpo.dsdepart
          FROM tbgen_inconsist_acesso_grp ace
              ,tbgen_inconsist_grp        grp
              ,crapcop                    cop
              ,crapdpo                    dpo
         WHERE ace.idinconsist_grp = grp.idinconsist_grp
           AND ace.cddepart        = dpo.cddepart
           AND ace.cdcooper        = dpo.cdcooper
           AND ace.cdcooper        = cop.cdcooper
           AND ace.cdcooper        = DECODE(pr_cdcooper, 0, ace.cdcooper, pr_cdcooper)
           AND ace.idinconsist_grp = pr_iddgrupo;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis Gerais
      vr_contador INTEGER := 0;
      vr_qtregist INTEGER := 0;
      vr_nrregist INTEGER := pr_nrregist;

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de acessos
      FOR rw_acesso IN cr_acesso(pr_cdcooper => pr_cdcooper
                                ,pr_iddgrupo => pr_iddgrupo) LOOP

        -- Incrementar contador
        vr_qtregist:= NVL(vr_qtregist,0) + 1;

        -- Controles da paginacao
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
          -- Proximo
          CONTINUE;
        END IF;

        -- Numero de Registros
        IF vr_nrregist > 0 THEN

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'acesso'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'acesso'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'cdcooper'
                                ,pr_tag_cont => rw_acesso.cdcooper
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'acesso'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nmrescop'
                                ,pr_tag_cont => rw_acesso.nmrescop
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'acesso'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'cddepart'
                                ,pr_tag_cont => rw_acesso.cddepart
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'acesso'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dsdepart'
                                ,pr_tag_cont => rw_acesso.dsdepart
                                ,pr_des_erro => vr_dscritic);

        END IF; -- vr_nrregist > 0

        -- Diminuir registros
        vr_nrregist:= NVL(vr_nrregist,0) - 1;

        vr_contador := vr_contador + 1;
      END LOOP; -- cr_grupo

      -- Insere atributo na tag Dados com a quantidade de registros
      GENE0007.pc_gera_atributo(pr_xml   => pr_retxml
                               ,pr_tag   => 'Dados'
                               ,pr_atrib => 'qtregist'
                               ,pr_atval => vr_qtregist
                               ,pr_numva => 0
                               ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CONINC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_acesso;

  PROCEDURE pc_busca_email(pr_cdcooper IN tbgen_inconsist_email_grp.cdcooper%TYPE --> Cooperativa
                          ,pr_iddgrupo IN tbgen_inconsist_email_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                          ,pr_nrregist IN INTEGER --> Numero Registros
                          ,pr_nriniseq IN INTEGER --> Numero Sequencia Inicial
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_email
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os emails.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os emails
      CURSOR cr_email(pr_cdcooper IN tbgen_inconsist_email_grp.cdcooper%TYPE
                     ,pr_iddgrupo IN tbgen_inconsist_email_grp.idinconsist_grp%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,eml.dsendereco_email dsdemail
          FROM tbgen_inconsist_email_grp eml
              ,tbgen_inconsist_grp       grp
              ,crapcop                   cop
         WHERE eml.idinconsist_grp = grp.idinconsist_grp
           AND eml.cdcooper        = cop.cdcooper
           AND eml.cdcooper        = DECODE(pr_cdcooper, 0, eml.cdcooper, pr_cdcooper)
           AND eml.idinconsist_grp = pr_iddgrupo;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis Gerais
      vr_contador INTEGER := 0;
      vr_qtregist INTEGER := 0;
      vr_nrregist INTEGER := pr_nrregist;

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de acessos
      FOR rw_email IN cr_email(pr_cdcooper => pr_cdcooper
                              ,pr_iddgrupo => pr_iddgrupo) LOOP

        -- Incrementar contador
        vr_qtregist:= NVL(vr_qtregist,0) + 1;

        -- Controles da paginacao
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
          -- Proximo
          CONTINUE;
        END IF;

        -- Numero de Registros
        IF vr_nrregist > 0 THEN

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'email'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'email'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'cdcooper'
                                ,pr_tag_cont => rw_email.cdcooper
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'email'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nmrescop'
                                ,pr_tag_cont => rw_email.nmrescop
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'email'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dsdemail'
                                ,pr_tag_cont => rw_email.dsdemail
                                ,pr_des_erro => vr_dscritic);

        END IF; -- vr_nrregist > 0

        -- Diminuir registros
        vr_nrregist:= NVL(vr_nrregist,0) - 1;

        vr_contador := vr_contador + 1;
      END LOOP; -- cr_grupo

      -- Insere atributo na tag Dados com a quantidade de registros
      GENE0007.pc_gera_atributo(pr_xml   => pr_retxml
                               ,pr_tag   => 'Dados'
                               ,pr_atrib => 'qtregist'
                               ,pr_atval => vr_qtregist
                               ,pr_numva => 0
                               ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CONINC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_email;

  PROCEDURE pc_busca_grupo(pr_iddgrupo IN tbgen_inconsist_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                          ,pr_nrregist IN INTEGER --> Numero Registros
                          ,pr_nriniseq IN INTEGER --> Numero Sequencia Inicial
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_grupo
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os grupos.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os grupos
      CURSOR cr_grupo(pr_iddgrupo IN tbgen_inconsist_grp.idinconsist_grp%TYPE) IS
        SELECT idinconsist_grp
              ,nminconsist_grp
              ,tpconfig_email
              ,dsassunto_email
              ,tpperiodicidade_email
              ,CASE tpconfig_email 
               WHEN 1 THEN 'Somente Erros'
               WHEN 2 THEN 'Erros e Alertas'
               ELSE 'Não enviar e-mail' END dsconteudo
              ,CASE tpperiodicidade_email 
               WHEN 1 THEN 'Online'
               ELSE 'Diário' END dsperiodicidade
          FROM tbgen_inconsist_grp
         WHERE idinconsist_grp = DECODE(pr_iddgrupo, 0, idinconsist_grp, pr_iddgrupo);

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis Gerais
      vr_contador INTEGER := 0;
      vr_qtregist INTEGER := 0;
      vr_nrregist INTEGER := pr_nrregist;

    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de grupos
      FOR rw_grupo IN cr_grupo(pr_iddgrupo => pr_iddgrupo) LOOP

        -- Incrementar contador
        vr_qtregist:= NVL(vr_qtregist,0) + 1;

        -- Controles da paginacao
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
          -- Proximo
          CONTINUE;
        END IF;

        -- Numero de Registros
        IF vr_nrregist > 0 THEN

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'grupo'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'grupo'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'idinconsist_grp'
                                ,pr_tag_cont => rw_grupo.idinconsist_grp
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'grupo'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'nminconsist_grp'
                                ,pr_tag_cont => rw_grupo.nminconsist_grp
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'grupo'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'tpconfig_email'
                                ,pr_tag_cont => rw_grupo.tpconfig_email
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'grupo'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dsconteudo'
                                ,pr_tag_cont => rw_grupo.dsconteudo
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'grupo'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dsassunto_email'
                                ,pr_tag_cont => rw_grupo.dsassunto_email
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'grupo'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'tpperiodicidade_email'
                                ,pr_tag_cont => rw_grupo.tpperiodicidade_email
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'grupo'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dsperiodicidade'
                                ,pr_tag_cont => rw_grupo.dsperiodicidade
                                ,pr_des_erro => vr_dscritic);

        END IF; -- vr_nrregist > 0

        -- Diminuir registros
        vr_nrregist:= NVL(vr_nrregist,0) - 1;

        vr_contador := vr_contador + 1;
      END LOOP; -- cr_grupo

      -- Insere atributo na tag Dados com a quantidade de registros
      GENE0007.pc_gera_atributo(pr_xml   => pr_retxml
                               ,pr_tag   => 'Dados'
                               ,pr_atrib => 'qtregist'
                               ,pr_atval => vr_qtregist
                               ,pr_numva => 0
                               ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CONINC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_grupo;

  PROCEDURE pc_pesquisa_grupo(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                             ,pr_iddgrupo IN tbgen_inconsist_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                             ,pr_nmdgrupo IN tbgen_inconsist_grp.nminconsist_grp%TYPE --> Descricao do Grupo
                             ,pr_cddopcao IN VARCHAR2 --> Opcao selecionada
                             ,pr_nrregist IN PLS_INTEGER --> Numero de registros que deverao ser retornados
                             ,pr_nriniseq IN PLS_INTEGER --> Numero inicial do registro para enviar
                             ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo

    /* .............................................................................

    Programa: pc_pesquisa_grupo
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os grupos.

    Alteracoes: -----
    ..............................................................................*/

      -- Listagem dos grupos
      CURSOR cr_grupo(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_iddgrupo IN tbgen_inconsist_grp.idinconsist_grp%TYPE
                     ,pr_nmdgrupo IN tbgen_inconsist_grp.nminconsist_grp%TYPE
                     ,pr_cddepart IN crapdpo.cddepart%TYPE) IS
        SELECT grp.idinconsist_grp iddgrupo,
               grp.nminconsist_grp nmdgrupo,
               COUNT(1) OVER() retorno
          FROM tbgen_inconsist_grp grp
         WHERE grp.idinconsist_grp = DECODE(NVL(pr_iddgrupo,0), 0, grp.idinconsist_grp, pr_iddgrupo)
           AND (TRIM(pr_nmdgrupo) IS NULL OR
                UPPER(grp.nminconsist_grp) LIKE '%' || UPPER(pr_nmdgrupo) || '%')
           AND (pr_cddepart = 0 OR
                EXISTS (SELECT 1
                          FROM tbgen_inconsist_acesso_grp ace
                         WHERE grp.idinconsist_grp = ace.idinconsist_grp
                           AND ace.cdcooper = DECODE(pr_cdcooper, 0, ace.cdcooper, pr_cdcooper)
                           AND ace.cddepart = DECODE(pr_cddepart, 0, ace.cddepart, pr_cddepart)))
      ORDER BY nmdgrupo;

      -- Busca departamento
      CURSOR cr_crapdpo(pr_cdcooper IN crapdpo.cdcooper%TYPE
                       ,pr_dsdepart IN crapdpo.dsdepart%TYPE) IS
        SELECT cddepart
          FROM crapdpo
         WHERE cdcooper = pr_cdcooper
           AND UPPER(dsdepart) = UPPER(pr_dsdepart);
      rw_crapdpo cr_crapdpo%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad VARCHAR2(100);
      vr_cdcooper NUMBER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      vr_cddepart crapdpo.cddepart%TYPE := 0;

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

        -- Na consulta filtrar por departamento
        IF pr_cddopcao = 'C' THEN
          -- Busca operador
          OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                         ,pr_cdoperad => vr_cdoperad);
          FETCH cr_crapope INTO rw_crapope;
          CLOSE cr_crapope;

          -- Busca departamento
          OPEN cr_crapdpo(pr_cdcooper => vr_cdcooper
                         ,pr_dsdepart => rw_crapope.dsdepart);
          FETCH cr_crapdpo INTO rw_crapdpo;
          CLOSE cr_crapdpo;
          
          -- Seta o codigo
          vr_cddepart := rw_crapdpo.cddepart;
        END IF;

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

        -- Criar cabeçalho do XML
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        -- Listagem de grupos
        FOR rw_grupo IN cr_grupo(pr_cdcooper => pr_cdcooper
                                ,pr_iddgrupo => pr_iddgrupo
                                ,pr_nmdgrupo => pr_nmdgrupo
                                ,pr_cddepart => vr_cddepart) LOOP

          -- Incrementa o contador de registros
          vr_posreg := vr_posreg + 1;

          -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
          IF vr_posreg = 1 THEN
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<histor qtregist="' || rw_grupo.retorno || '">');
          END IF;

          -- Enviar somente se a linha for superior a linha inicial
          IF NVL(pr_nriniseq,0) <= vr_posreg THEN

            -- Carrega os dados
            GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<inf>'||
                                                            '<iddgrupo>' || rw_grupo.iddgrupo ||'</iddgrupo>'||
                                                            '<nmdgrupo>' || rw_grupo.nmdgrupo ||'</nmdgrupo>'||
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
        pr_dscritic := 'Erro geral na busca do Grupo: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_pesquisa_grupo;

  PROCEDURE pc_grava_grupo(pr_iddgrup2 IN tbgen_inconsist_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                          ,pr_nmdgrupo IN tbgen_inconsist_grp.nminconsist_grp%TYPE --> Nome do grupo
                          ,pr_indconte IN tbgen_inconsist_grp.tpconfig_email%TYPE --> (0-Nao enviar e-mail, 1-Somente erros, 2-Erros e alertas)
                          ,pr_dsassunt IN tbgen_inconsist_grp.dsassunto_email%TYPE --> Descricao do assunto do e-mail
                          ,pr_indperio IN tbgen_inconsist_grp.tpperiodicidade_email%TYPE --> Periodicidade (1-OnLine, 2-Diario)
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_grupo
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os dados do grupo.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis Gerais
      vr_idincons tbgen_inconsist_grp.idinconsist_grp%TYPE;

    BEGIN
      -- Se for Alteracao
      IF pr_iddgrup2 > 0 THEN
        BEGIN
          UPDATE tbgen_inconsist_grp
             SET nminconsist_grp       = pr_nmdgrupo
                ,tpconfig_email        = pr_indconte
                ,dsassunto_email       = pr_dsassunt
                ,tpperiodicidade_email = pr_indperio
           WHERE idinconsist_grp       = pr_iddgrup2;
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar grupo: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;
      -- Se for Inclusao
      ELSE
        -- Busca o proximo ID
        vr_idincons := fn_sequence(pr_nmtabela => 'tbgen_inconsist_grp'
                                  ,pr_nmdcampo => 'idinconsist_grp'
                                  ,pr_dsdchave => '0');

        BEGIN
          INSERT INTO tbgen_inconsist_grp
                     (idinconsist_grp
                     ,nminconsist_grp
                     ,tpconfig_email
                     ,dsassunto_email
                     ,tpperiodicidade_email)
               VALUES(vr_idincons
                     ,pr_nmdgrupo
                     ,pr_indconte
                     ,pr_dsassunt
                     ,pr_indperio);
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir grupo: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CONINC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_grupo;

  PROCEDURE pc_exclui_grupo(pr_iddgrupo IN tbgen_inconsist_grp.idinconsist_grp%TYPE --> Codigo do Grupo
                           ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_grupo
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir o grupo.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN

      BEGIN
        DELETE 
          FROM tbgen_inconsist_grp
         WHERE idinconsist_grp = pr_iddgrupo;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao excluir grupo. Grupo vinculado em outro local.';
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
        pr_dscritic := 'Erro geral na rotina da tela CONINC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_grupo;

  PROCEDURE pc_grava_acesso_email(pr_cddopcao IN VARCHAR2 --> Opcao: A-Acesso / E-Email
                                 ,pr_dsoperac IN VARCHAR2 --> Operacao: I-Inclusao / E-Exclusao
                                 ,pr_vlcampos IN VARCHAR2 --> Dados dos campos
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_acesso_email
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os dados do Acesso ou E-mail.

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

      -- Variaveis Gerais
      vr_vlcampos GENE0002.typ_split;

    BEGIN
      -- Separa string contendo (#)
      vr_vlcampos := GENE0002.fn_quebra_string(pr_string  => pr_vlcampos
                                              ,pr_delimit => '#');

      FOR vr_ind IN 1..vr_vlcampos.COUNT() LOOP

        BEGIN
          -- Listagem de cooperativa
          FOR rw_crapcop IN cr_crapcop(pr_cdcooper => GENE0002.fn_busca_entrada(1,vr_vlcampos(vr_ind),'_')) LOOP

            -- Se for Acesso
            IF pr_cddopcao = 'A' THEN
              DELETE
                FROM tbgen_inconsist_acesso_grp
               WHERE cdcooper        = rw_crapcop.cdcooper
                 AND idinconsist_grp = GENE0002.fn_busca_entrada(2,vr_vlcampos(vr_ind),'_')
                 AND cddepart        = GENE0002.fn_busca_entrada(3,vr_vlcampos(vr_ind),'_');

              -- Se for Inclusao
              IF pr_dsoperac = 'I' THEN
                INSERT INTO tbgen_inconsist_acesso_grp
                           (cdcooper
                           ,idinconsist_grp
                           ,cddepart)
                     VALUES(rw_crapcop.cdcooper
                           ,GENE0002.fn_busca_entrada(2,vr_vlcampos(vr_ind),'_')
                           ,GENE0002.fn_busca_entrada(3,vr_vlcampos(vr_ind),'_'));
              END IF;

            -- Se for Email
            ELSIF pr_cddopcao = 'E' THEN
              DELETE
                FROM tbgen_inconsist_email_grp
               WHERE cdcooper         = rw_crapcop.cdcooper
                 AND idinconsist_grp  = GENE0002.fn_busca_entrada(2,vr_vlcampos(vr_ind),'_')
                 AND dsendereco_email = GENE0002.fn_busca_entrada(3,vr_vlcampos(vr_ind),'_');

              -- Se for Inclusao
              IF pr_dsoperac = 'I' THEN
                INSERT INTO tbgen_inconsist_email_grp
                           (cdcooper
                           ,idinconsist_grp
                           ,dsendereco_email)
                     VALUES(rw_crapcop.cdcooper
                           ,GENE0002.fn_busca_entrada(2,vr_vlcampos(vr_ind),'_')
                           ,GENE0002.fn_busca_entrada(3,vr_vlcampos(vr_ind),'_'));
              END IF;
            END IF;

          END LOOP; -- cr_crapcop

        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao gravar dados: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;

      END LOOP; -- vr_vlcampos

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CONINC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_acesso_email;

END TELA_CONINC;
/
