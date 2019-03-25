CREATE OR REPLACE PACKAGE CECRED.empr0005 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0005
  --  Sistema  : Rotinas referentes a tela PARMCR
  --  Sigla    : EMPR
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : Dezembro - 2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela PARMCR

  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de insert, update, select e delete da tela PARMCR na tabela CRAPVQS
  PROCEDURE pc_crapvqs(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrversao IN crapvqs.nrversao%TYPE --> Numero da versao do questionario
                      ,pr_dsversao IN crapvqs.dsversao%TYPE --> Descricao da versao
                      ,pr_dtinivig IN VARCHAR2              --> Data de inicio da vigencia
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  -- Rotina geral de insert, update, select e delete da tela PARMCR na tabela CRAPTQS
  PROCEDURE pc_craptqs(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqtit IN craptqs.nrseqtit%TYPE --> Numero sequencial do titulo
                      ,pr_nrversao IN craptqs.nrversao%TYPE --> Numero da versao do questionario
                      ,pr_nrordtit IN craptqs.nrordtit%TYPE --> Ordem que o titulo aparecera no questionario
                      ,pr_dstitulo IN craptqs.dstitulo%TYPE --> Descricao da titulo
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina geral de insert, update, select e delete da tela PARMCR na tabela CRAPPQS
  PROCEDURE pc_crappqs(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqper IN crappqs.nrseqper%TYPE --> Numero sequencial da pergunta
                      ,pr_nrseqtit IN crappqs.nrseqtit%TYPE --> Numero sequencial do titulo
                      ,pr_nrordper IN crappqs.nrordper%TYPE --> Ordem que a pergunta aparecera no questionario
                      ,pr_dspergun IN crappqs.dspergun%TYPE --> Descricao da pergunta
                      ,pr_inobriga IN crappqs.inobriga%TYPE --> Indicador de a pergunta eh obrigatoria
                      ,pr_intipres IN crappqs.intipres%TYPE --> Tipo de resposta, onde 1-Unica escolha, 2-texto numerico, 3-Texto caracter
                      ,pr_nrregcal IN crappqs.nrregcal%TYPE --> Regra de calculo da pergunta
                      ,pr_dsregexi IN crappqs.dsregexi%TYPE --> Regra para exigencia do campo
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina geral de insert, update, select e delete da tela PARMCR na tabela craprqs
  PROCEDURE pc_craprqs(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqres IN craprqs.nrseqres%TYPE --> Numero sequencial da resposta
                      ,pr_nrseqper IN craprqs.nrseqper%TYPE --> Numero sequencial da pergunta
                      ,pr_nrordres IN craprqs.nrordres%TYPE --> Ordem que a resposta aparecera no questionario
                      ,pr_dsrespos IN craprqs.dsrespos%TYPE --> Descricao da resposta
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para criação de uma versao com base em outra versao de perguntas
  PROCEDURE pc_cria_versao(pr_nrversao IN crapvqs.nrversao%TYPE --> Numero da versao do questionario de origem
                          ,pr_dsversao IN crapvqs.dsversao%TYPE --> Nome da versao
                          ,pr_dtinivig IN VARCHAR2              --> Data de inicio da vigencia
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para criação de uma versao com base em outra versao de perguntas
  PROCEDURE pc_retorna_perguntas(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                ,pr_nrseqrrq IN craprrq.nrseqrrq%TYPE --> Numero sequencial do retorno das respostas do questionario
                                ,pr_inregcal IN PLS_INTEGER           --> Indicador se deve ou nao exibir registros que sao calculados
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para retorno das perguntas do questionario que eh chamada via Relatorio de contratos (EMPR0003)
  PROCEDURE pc_retorna_perguntas(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                ,pr_nrseqrrq IN craprrq.nrseqrrq%TYPE --> Numero sequencial do retorno das respostas do questionario
                                ,pr_inregcal IN PLS_INTEGER           --> Indicador se deve ou nao exibir registros que sao calculados
                                ,pr_retxml   IN OUT CLOB              --> Arquivo de retorno do XML
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina para gravacao das respostas que foram efetuadas na tela ATENDA
  PROCEDURE pc_grava_respostas_mcr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                  ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                  ,pr_resposta IN VARCHAR2              --> Retorno das respostas
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para verificar se a linha de credito deve possuir solicitacao de perguntas do questionario
  PROCEDURE pc_verifica_microcredito(pr_cdcooper IN craplcr.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                    ,pr_inlcrmcr OUT VARCHAR2             --> Indicador de linha de credito como microcredito
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina para verificar se a linha de credito deve possuir solicitacao de perguntas do questionario
  PROCEDURE pc_verifica_microcredito_xml(pr_cdcooper IN craplcr.cdcooper%TYPE --> Código da cooperativa
                                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para retorno das perguntas do questionario na tela PARMCR
  PROCEDURE pc_ret_perguntas_parmcr(pr_nrversao crapvqs.nrversao%TYPE  --> Versao do questionario de dados
                                   ,pr_inpessoa crapass.inpessoa%TYPE  --> Tipo de pessoa
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  END empr0005;
/

CREATE OR REPLACE PACKAGE BODY CECRED.empr0005 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0005
  --  Sistema  : Rotinas referentes a tela PARMCR
  --  Sigla    : EMPR
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : Dezembro - 2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela PARMCR

  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de insert, update, select e delete da tela PARMCR na tabela CRAPVQS
  PROCEDURE pc_crapvqs(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrversao IN crapvqs.nrversao%TYPE --> Numero da versao do questionario
                      ,pr_dsversao IN crapvqs.dsversao%TYPE --> Descricao da versao
                      ,pr_dtinivig IN VARCHAR2              --> Data de inicio da vigencia
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre a versao do questionario de microcredito
      CURSOR cr_crapvqs IS
        SELECT nrversao,
               gene0007.fn_caract_acento(dsversao) dsversao,
               dtinivig
          FROM crapvqs
         WHERE nrversao = decode(nvl(pr_nrversao,0),0,nrversao,pr_nrversao)
         ORDER BY dtinivig DESC;

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

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao

            BEGIN
              -- Atualizacao de registro de versao do questionario
              UPDATE crapvqs
                 SET dsversao = pr_dsversao,
                     dtinivig = to_date(pr_dtinivig,'dd/mm/yyyy')
               WHERE nrversao = pr_nrversao;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar CRAPVQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' alterou a versao '||
                                         pr_dsversao);

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre as versoes do questionario de microcredito
            FOR rw_crapvqs IN cr_crapvqs LOOP

              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrversao', pr_tag_cont => rw_crapvqs.nrversao, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsversao', pr_tag_cont => rw_crapvqs.dsversao, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtinivig', pr_tag_cont => to_char(rw_crapvqs.dtinivig,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);

              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            -- Efetua a exclusao das respostas
            BEGIN
              DELETE craprqs
               WHERE nrseqper IN (SELECT nrseqper
                                    FROM crappqs
                                   WHERE nrseqtit IN (SELECT nrseqtit
                                                        FROM craptqs
                                                       WHERE nrversao = pr_nrversao));
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPRQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Efetua a exclusao das perguntas
            BEGIN
              DELETE crappqs
               WHERE nrseqtit IN (SELECT nrseqtit
                                    FROM craptqs
                                   WHERE nrversao = pr_nrversao);
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPPQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Efetua a exclusao dos titulos
            BEGIN
              DELETE craptqs
               WHERE nrversao = pr_nrversao;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPTQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Efetua a exclusao das versoes do questionario de microcredito
            BEGIN
              DELETE crapvqs
               WHERE nrversao = pr_nrversao;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPVQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' excluiu a versao '||
                                         pr_dsversao);

          WHEN 'I' THEN -- Inclusao

            -- Efetua a inclusao no cadastro de versao do questionario de microcredito
            BEGIN
              INSERT INTO crapvqs
                 (nrversao,
                  dsversao,
                  dtinivig)
                VALUES(
                  fn_sequence(pr_nmtabela => 'CRAPVQS', pr_nmdcampo => 'NRVERSAO',pr_dsdchave => '0'),
                  pr_dsversao,
                  to_date(pr_dtinivig,'dd/mm/yyyy'));

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao inserir CRAPVQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' incluiu a versao '||
                                         pr_dsversao);

        END CASE;

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
        pr_dscritic := 'Erro geral em CRAPVQS: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_crapvqs;

  -- Rotina geral de insert, update, select e delete da tela PARMCR na tabela CRAPTQS
  PROCEDURE pc_craptqs(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqtit IN craptqs.nrseqtit%TYPE --> Numero sequencial do titulo
                      ,pr_nrversao IN craptqs.nrversao%TYPE --> Numero da versao do questionario
                      ,pr_nrordtit IN craptqs.nrordtit%TYPE --> Ordem que o titulo aparecera no questionario
                      ,pr_dstitulo IN craptqs.dstitulo%TYPE --> Descricao da titulo
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre os titulos do questionario de microcredito
      CURSOR cr_craptqs IS
        SELECT nrseqtit,
               nrversao,
               nrordtit,
               gene0007.fn_caract_acento(dstitulo) dstitulo
          FROM craptqs
         WHERE nrversao = pr_nrversao
           AND nrseqtit = decode(nvl(pr_nrseqtit,0),0,nrseqtit,pr_nrseqtit)
         ORDER BY nrordtit;

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

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao

            BEGIN
              -- Atualizacao de registro de titulos do questionario
              UPDATE craptqs
                 SET nrordtit = pr_nrordtit,
                     dstitulo = pr_dstitulo
               WHERE nrseqtit = pr_nrseqtit;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar CRAPTQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' alterou o titulo '||
                                         pr_dstitulo);

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre os titulos do questionario de microcredito
            FOR rw_craptqs IN cr_craptqs LOOP

              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqtit', pr_tag_cont => rw_craptqs.nrseqtit, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrversao', pr_tag_cont => rw_craptqs.nrversao, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrordtit', pr_tag_cont => rw_craptqs.nrordtit, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstitulo', pr_tag_cont => rw_craptqs.dstitulo, pr_des_erro => vr_dscritic);

              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            -- Efetua a exclusao das respostas
            BEGIN
              DELETE craprqs
               WHERE nrseqper IN (SELECT nrseqper
                                    FROM crappqs
                                   WHERE nrseqtit = pr_nrseqtit);
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPRQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Efetua a exclusao das perguntas
            BEGIN
              DELETE crappqs
               WHERE nrseqtit = pr_nrseqtit;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPPQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Efetua a exclusao dos titulos
            BEGIN
              DELETE craptqs
               WHERE nrseqtit = pr_nrseqtit;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPTQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' excluiu o titulo '||
                                         pr_dstitulo);

          WHEN 'I' THEN -- Inclusao

            -- Efetua a inclusao no cadastro de titulos do questionario de microcredito
            BEGIN
              INSERT INTO craptqs
                 (nrseqtit,
                  nrversao,
                  nrordtit,
                  dstitulo)
                VALUES(
                  fn_sequence(pr_nmtabela => 'CRAPTQS', pr_nmdcampo => 'NRSEQTIT',pr_dsdchave => '0'),
                  pr_nrversao,
                  pr_nrordtit,
                  pr_dstitulo);

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao inserir CRAPTQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' incluiu o titulo '||
                                         pr_dstitulo);
        END CASE;

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
        pr_dscritic := 'Erro geral em CRAPTQS: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_craptqs;

  -- Rotina geral de insert, update, select e delete da tela PARMCR na tabela CRAPPQS
  PROCEDURE pc_crappqs(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqper IN crappqs.nrseqper%TYPE --> Numero sequencial da pergunta
                      ,pr_nrseqtit IN crappqs.nrseqtit%TYPE --> Numero sequencial do titulo
                      ,pr_nrordper IN crappqs.nrordper%TYPE --> Ordem que a pergunta aparecera no questionario
                      ,pr_dspergun IN crappqs.dspergun%TYPE --> Descricao da pergunta
                      ,pr_inobriga IN crappqs.inobriga%TYPE --> Indicador de a pergunta eh obrigatoria
                      ,pr_intipres IN crappqs.intipres%TYPE --> Tipo de resposta, onde 1-Unica escolha, 2-texto numerico, 3-Texto caracter
                      ,pr_nrregcal IN crappqs.nrregcal%TYPE --> Regra de calculo da pergunta
                      ,pr_dsregexi IN crappqs.dsregexi%TYPE --> Regra para exigencia do campo
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre as perguntas do questionario de microcredito
      CURSOR cr_crappqs IS
        SELECT nrseqper,
               nrseqtit,
               nrordper,
               gene0007.fn_caract_acento(dspergun) dspergun,
               inobriga,
               intipres,
               nrregcal,
               dsregexi
          FROM crappqs
         WHERE nrseqtit = pr_nrseqtit
           AND nrseqper = decode(nvl(pr_nrseqper,0),0,nrseqper,pr_nrseqper)
       ORDER BY nrordper;

      -- Cursor sobre as perguntas para verificar se a pergunta eh regra de alguma outra pergunta
      CURSOR cr_crappqs_2 IS
        SELECT 1
          FROM crappqs
         WHERE dsregexi LIKE '%pergunta'||pr_nrseqper||'=%';
      rw_crappqs_2 cr_crappqs_2%ROWTYPE;


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

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao

            BEGIN
              -- Atualizacao de registro de perguntas do questionario
              UPDATE crappqs
                 SET nrordper = pr_nrordper,
                     dspergun = pr_dspergun,
                     inobriga = pr_inobriga,
                     intipres = pr_intipres,
                     nrregcal = pr_nrregcal,
                     dsregexi = pr_dsregexi
               WHERE nrseqper = pr_nrseqper;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar CRAPPQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Se o tipo de resposta for texto numerico ou texto livre, limpa as respostas
            IF pr_intipres IN (2,3) THEN
              BEGIN
                DELETE craprqs
                 WHERE nrseqper = pr_nrseqper;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Descricao do erro na alteracao de registros
                  vr_dscritic := 'Problema ao excluir CRAPRQS: ' || sqlerrm;
                  RAISE vr_exc_saida;
              END;
            END IF;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' alterou a pergunta '||
                                         pr_dspergun);

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre as perguntas do questionario de microcredito
            FOR rw_crappqs IN cr_crappqs LOOP

              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqper', pr_tag_cont => rw_crappqs.nrseqper, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqtit', pr_tag_cont => rw_crappqs.nrseqtit, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrordper', pr_tag_cont => rw_crappqs.nrordper, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dspergun', pr_tag_cont => rw_crappqs.dspergun, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'inobriga', pr_tag_cont => rw_crappqs.inobriga, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'intipres', pr_tag_cont => rw_crappqs.intipres, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrregcal', pr_tag_cont => rw_crappqs.nrregcal, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsregexi', pr_tag_cont => rw_crappqs.dsregexi, pr_des_erro => vr_dscritic);

              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            -- Antes de excluir, deve-se verificar se esta pergunta nao esta na regra de alguma
            -- outra pergunta. Se estiver, nao pode excluir
            OPEN cr_crappqs_2;
            FETCH cr_crappqs_2 INTO rw_crappqs_2;
            IF cr_crappqs_2%FOUND THEN
              CLOSE cr_crappqs_2;
              vr_dscritic := 'Pergunta pertence a regra de uma outra pergunta. Não pode ser excluida';
              RAISE vr_exc_saida;
            END IF;
            CLOSE cr_crappqs_2;

            -- Efetua a exclusao das respostas
            BEGIN
              DELETE craprqs
               WHERE nrseqper = pr_nrseqper;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPRQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Efetua a exclusao das perguntas
            BEGIN
              DELETE crappqs
               WHERE nrseqper = pr_nrseqper;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPPQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' excluiu a pergunta '||
                                         pr_dspergun);

          WHEN 'I' THEN -- Inclusao

            -- Efetua a inclusao no cadastro de titulos do questionario de microcredito
            BEGIN
              INSERT INTO crappqs
                 (nrseqper,
                  nrseqtit,
                  nrordper,
                  dspergun,
                  inobriga,
                  intipres,
                  nrregcal,
                  dsregexi)
                VALUES(
                  fn_sequence(pr_nmtabela => 'CRAPPQS', pr_nmdcampo => 'NRSEQPER',pr_dsdchave => '0'),
                  pr_nrseqtit,
                  pr_nrordper,
                  pr_dspergun,
                  pr_inobriga,
                  pr_intipres,
                  pr_nrregcal,
                  pr_dsregexi);

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao inserir CRAPPQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' inseriu a pergunta '||
                                         pr_dspergun);
        END CASE;

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
        pr_dscritic := 'Erro geral em CRAPPQS: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_crappqs;

  -- Rotina geral de insert, update, select e delete da tela PARMCR na tabela craprqs
  PROCEDURE pc_craprqs(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqres IN craprqs.nrseqres%TYPE --> Numero sequencial da resposta
                      ,pr_nrseqper IN craprqs.nrseqper%TYPE --> Numero sequencial da pergunta
                      ,pr_nrordres IN craprqs.nrordres%TYPE --> Ordem que a resposta aparecera no questionario
                      ,pr_dsrespos IN craprqs.dsrespos%TYPE --> Descricao da resposta
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre as respostas do questionario de microcredito
      CURSOR cr_craprqs IS
        SELECT nrseqres,
               nrseqper,
               nrordres,
               gene0007.fn_caract_acento(dsrespos) dsrespos
          FROM craprqs
         WHERE nrseqper = pr_nrseqper
           AND nrseqres = decode(nvl(pr_nrseqres,0),0,nrseqres,pr_nrseqres)
         ORDER BY nrordres;

      -- Cursor sobre as perguntas para verificar se a resposta eh regra de alguma pergunta
      CURSOR cr_crappqs IS
        SELECT 1
          FROM crappqs
         WHERE dsregexi LIKE '%resposta'||pr_nrseqres;
      rw_crappqs cr_crappqs%ROWTYPE;


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

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Verifica o tipo de acao que sera executada
        CASE pr_cddopcao

          WHEN 'A' THEN -- Alteracao

            BEGIN
              -- Atualizacao de registro de resposta do questionario
              UPDATE craprqs
                 SET nrordres = pr_nrordres,
                     dsrespos = pr_dsrespos
               WHERE nrseqres = pr_nrseqres;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar craprqs: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' alterou a resposta '||
                                         pr_dsrespos);

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre as respostas do questionario de microcredito
            FOR rw_craprqs IN cr_craprqs LOOP

              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqres', pr_tag_cont => rw_craprqs.nrseqres, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqper', pr_tag_cont => rw_craprqs.nrseqper, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrordres', pr_tag_cont => rw_craprqs.nrordres, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsrespos', pr_tag_cont => rw_craprqs.dsrespos, pr_des_erro => vr_dscritic);

              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            -- Antes de excluir, deve-se verificar se esta resposta nao esta na regra de alguma
            -- outra pergunta. Se estiver, nao pode excluir
            OPEN cr_crappqs;
            FETCH cr_crappqs INTO rw_crappqs;
            IF cr_crappqs%FOUND THEN
              CLOSE cr_crappqs;
              vr_dscritic := 'Reposta pertence a regra de uma pergunta. Não pode ser excluida';
              RAISE vr_exc_saida;
            END IF;
            CLOSE cr_crappqs;

            -- Efetua a exclusao das respostas
            BEGIN
              DELETE craprqs
               WHERE nrseqres = pr_nrseqres;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPRQS: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' excluiu a resposta '||
                                         pr_dsrespos);

          WHEN 'I' THEN -- Inclusao

            -- Efetua a inclusao no cadastro de respostas do questionario de microcredito
            BEGIN
              INSERT INTO craprqs
                 (nrseqres,
                  nrseqper,
                  nrordres,
                  dsrespos)
                VALUES(
                  fn_sequence(pr_nmtabela => 'CRAPRQS', pr_nmdcampo => 'NRSEQRES',pr_dsdchave => '0'),
                  pr_nrseqper,
                  pr_nrordres,
                  pr_dsrespos);

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao inserir craprqs: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARMCR'
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || ' incluiu a resposta '||
                                         pr_dsrespos);
        END CASE;

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
        pr_dscritic := 'Erro geral em craprqs: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_craprqs;

  -- Rotina para criação de uma versao com base em outra versao de perguntas
  PROCEDURE pc_cria_versao(pr_nrversao IN crapvqs.nrversao%TYPE --> Numero da versao do questionario de origem
                          ,pr_dsversao IN crapvqs.dsversao%TYPE --> Nome da versao
                          ,pr_dtinivig IN VARCHAR2              --> Data de inicio da vigencia
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre os tiulos do questionario de microcredito
      CURSOR cr_craptqs IS
        SELECT nrseqtit,
               nrversao,
               nrordtit,
               dstitulo
          FROM craptqs
         WHERE nrversao = pr_nrversao
         ORDER BY nrordtit;

      -- Cursor sobre os tiulos do questionario de microcredito
      CURSOR cr_crappqs(pr_nrseqtit crappqs.nrseqtit%TYPE) IS
        SELECT nrseqper,
               nrseqtit,
               nrordper,
               dspergun,
               inobriga,
               intipres,
               nrregcal,
               dsregexi
          FROM crappqs
         WHERE nrseqtit = pr_nrseqtit
         ORDER BY nrordper;

      -- Cursor para buscar a pergunta da regra de exigencia com base em uma regra antiga
      CURSOR cr_crappqs_2(pr_nrversao          craptqs.nrversao%TYPE,
                          pr_nrseqper_anterior crappqs.nrseqper%TYPE) IS
        SELECT p3.nrseqper
          FROM crappqs p1, -- Pergunta antiga
               craptqs p2, -- Titual da pergunta atual
               crappqs p3  -- pergunta da regra
         WHERE p1.nrseqper = pr_nrseqper_anterior
           AND p2.nrversao = pr_nrversao
           AND p3.nrseqtit = p2.nrseqtit
           AND p3.dspergun = p1.dspergun;

      -- Cursor para buscar a resposta da regra de exigencia com base em uma regra antiga
      CURSOR cr_craprqs_2(pr_nrseqper crappqs.nrseqper%TYPE,
                          pr_nrseqres craprqs.nrseqres%TYPE) IS
        SELECT p2.nrseqres
          FROM craprqs p1, -- Resposta antiga
               craprqs p2  -- Resposta nova
         WHERE p1.nrseqres = pr_nrseqres
           AND p2.nrseqper = pr_nrseqper
           AND p2.dsrespos = p1.dsrespos;

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

      -- Variaveis gerais
      vr_nrversao crapvqs.nrversao%TYPE;
      vr_nrseqtit craptqs.nrseqtit%TYPE;
      vr_nrseqper crappqs.nrseqper%TYPE;
      vr_nrseqper_tmp crappqs.nrseqper%TYPE;
      vr_nrseqres_tmp craprqs.nrseqres%TYPE;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

      -- Busca o numero da nova versao
      vr_nrversao := fn_sequence(pr_nmtabela => 'CRAPVQS', pr_nmdcampo => 'NRVERSAO',pr_dsdchave => '0');

      -- Comeca efetuando o insert da nova versao
      BEGIN
        INSERT INTO crapvqs
          (nrversao,
           dsversao,
           dtinivig)
         VALUES
          (vr_nrversao,
           pr_dsversao,
           to_date(pr_dtinivig,'dd/mm/yyyy'));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na CRAPVQS: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Loop sobre a tabela de titulos do questionario
      FOR rw_craptqs IN cr_craptqs LOOP
        BEGIN
          INSERT INTO craptqs
            (nrseqtit,
             nrversao,
             nrordtit,
             dstitulo)
           VALUES
            (fn_sequence(pr_nmtabela => 'CRAPTQS', pr_nmdcampo => 'NRSEQTIT',pr_dsdchave => '0'),
             vr_nrversao,
             rw_craptqs.nrordtit,
             rw_craptqs.dstitulo)
          RETURNING nrseqtit INTO vr_nrseqtit;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na CRAPTQS: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Loop sobre as perguntas do questionario
        FOR rw_crappqs IN cr_crappqs(rw_craptqs.nrseqtit) LOOP
          -- Insere o registro de perguntas
          BEGIN
            INSERT INTO crappqs
              (nrseqper,
               nrseqtit,
               nrordper,
               dspergun,
               inobriga,
               intipres,
               nrregcal,
               dsregexi)
             VALUES
              (fn_sequence(pr_nmtabela => 'CRAPPQS', pr_nmdcampo => 'NRSEQPER',pr_dsdchave => '0'),
               vr_nrseqtit,
               rw_crappqs.nrordper,
               rw_crappqs.dspergun,
               rw_crappqs.inobriga,
               rw_crappqs.intipres,
               rw_crappqs.nrregcal,
               rw_crappqs.dsregexi)
             RETURNING nrseqper INTO vr_nrseqper;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na CRAPPQS: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Insere as respostas
          BEGIN
            INSERT INTO craprqs
              (nrseqres,
               nrseqper,
               nrordres,
               dsrespos)
              (SELECT fn_sequence(pr_nmtabela => 'CRAPRQS', pr_nmdcampo => 'NRSEQRES',pr_dsdchave => '0'),
                      vr_nrseqper,
                      nrordres,
                      dsrespos
                 FROM craprqs
                WHERE nrseqper = rw_crappqs.nrseqper);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na CRARPQS: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Se a regra de exigencia nao for nula, atualiza com os sequenciais da nova versao
          IF rw_crappqs.dsregexi IS NOT NULL AND
             instr(rw_crappqs.dsregexi,'pergunta') <> 0 THEN

            -- Busca a sequencia da pergunta e a sequencia da resposta antiga
            vr_nrseqper_tmp := SUBSTR(rw_crappqs.dsregexi,INSTR(rw_crappqs.dsregexi,'pergunta')+8,INSTR(rw_crappqs.dsregexi,'=')-9);
            vr_nrseqres_tmp := SUBSTR(rw_crappqs.dsregexi,INSTR(rw_crappqs.dsregexi,'resposta')+8);

            -- Busca a sequencia da pergunta que corresponde a sequencia da pergunta anterior
            OPEN cr_crappqs_2(vr_nrversao, vr_nrseqper_tmp);
            FETCH cr_crappqs_2 INTO vr_nrseqper_tmp;

            -- Se nao encontrar, cancela a rotina
            IF cr_crappqs_2%NOTFOUND THEN
              CLOSE cr_crappqs_2;
              vr_dscritic := 'Erro ao buscar pergunta na regra de exigencia. A mesma nao foi encontrada!';
              RAISE vr_exc_saida;
            END IF;
            CLOSE cr_crappqs_2;

            -- Busca a sequencia da resposta que corresponde a resposta da regra
            OPEN cr_craprqs_2(vr_nrseqper_tmp, vr_nrseqres_tmp);
            FETCH cr_craprqs_2 INTO vr_nrseqres_tmp;
            IF cr_craprqs_2%NOTFOUND THEN
              CLOSE cr_craprqs_2;
              vr_dscritic := 'Erro ao buscar resposta na regra de exigencia. A mesma nao foi encontrada!';
              RAISE vr_exc_saida;
            END IF;
            CLOSE cr_craprqs_2;

            -- Efetua a atualizacao da pergunta com a regra de exigencia atualizada
            BEGIN
              UPDATE crappqs
                 SET dsregexi = 'pergunta'||vr_nrseqper_tmp||'=resposta'||vr_nrseqres_tmp
               WHERE nrseqper = vr_nrseqper;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar CRAPPQS: '||SQLERRM;
                RAISE vr_exc_saida;
            END;

          END IF;

        END LOOP;

      END LOOP;

      COMMIT;

      -- gera o log de alteracao
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Processo normal
                                ,pr_nmarqlog => 'PARMCR'
                                ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                   'Operador ' || vr_cdoperad || ' duplicou a versao '||
                                   pr_dsversao);

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
        pr_dscritic := 'Erro geral em pc_cria_versao: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_cria_versao;


  PROCEDURE pc_monta_perguntas(pr_nrversao crapvqs.nrversao%TYPE  --> Versao do questionario de dados
                              ,pr_inpessoa crapass.inpessoa%TYPE  --> Tipo de pessoa
                              ,pr_nrseqrrq IN craprrq.nrseqrrq%TYPE --> Numero sequencial do retorno das respostas do questionario
                              ,pr_inregcal IN PLS_INTEGER           --> Indicador se deve ou nao exibir registros que sao calculados
                              ,pr_retxml   IN OUT CLOB            --> Arquivo de retorno do XML
                              ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2) IS       --> Descrição da crítica

    -- Busca os titulos do questionario
    CURSOR cr_craptqs IS
      SELECT nrseqtit,
             dstitulo
        FROM craptqs
       WHERE nrversao = pr_nrversao
       ORDER BY nrordtit;

    -- Busca as perguntas do questionario
    CURSOR cr_crappqs(pr_nrseqtit crappqs.nrseqtit%TYPE) IS
      SELECT nrseqper,
             gene0007.fn_caract_acento(dspergun) dspergun,
             inobriga,
             intipres,
             REPLACE(REPLACE(dsregexi,'#PESSOA=1',''),'#PESSOA=2','') dsregexi
        FROM crappqs
       WHERE crappqs.nrseqtit = pr_nrseqtit
         AND decode(nvl(instr(crappqs.dsregexi,'#PESSOA'),0),0,9,              -- Efetua o filtro por tipo de pessoa
                    SUBSTR(crappqs.dsregexi,INSTR(crappqs.dsregexi,'#PESSOA=')+8,1)) IN (9,pr_inpessoa)
         AND (pr_inregcal = 1 -- Exibir registro calculados
          OR  nvl(crappqs.nrregcal,0) = 0)
     ORDER BY nrordper;

    -- Busca as respostas do questionario
    CURSOR cr_craprqs(pr_nrseqper craprqs.nrseqper%TYPE) IS
      SELECT nrseqres,
             gene0007.fn_caract_acento(dsrespos) dsrespos
        FROM craprqs
       WHERE nrseqper = pr_nrseqper
      ORDER BY nrordres;

    -- Busca as respostas do questionario
    CURSOR cr_craprrq(pr_nrseqper craprrq.nrseqper%TYPE) IS
      SELECT craprrq.nrseqres,
             gene0007.fn_caract_acento(nvl(craprqs.dsrespos, craprrq.dsrespos)) dsrespos
        FROM craprqs,
             craprrq
       WHERE craprrq.nrseqrrq = pr_nrseqrrq
         AND craprrq.nrseqper = pr_nrseqper
         AND craprqs.nrseqres (+) = craprrq.nrseqres;
    rw_craprrq cr_craprrq%ROWTYPE;

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
    vr_retxml       XMLType;                -- Retorno do xml
    vr_des_xml      CLOB;                   -- CLOB com o conteudo do XML
    vr_texto_completo  varchar2(32600);     --> Variável para armazenar os dados do XML antes de incluir no CLOB

  BEGIN

    -- Inicializar o CLOB
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    -- Se ja veio um xml no parametro, entao nao deve-se criar novamente, apenas concatenar
    IF pr_retxml IS NOT NULL THEN
      -- Copia o CLOB que veio do parametro para o CLOB que sera utilizado
      vr_des_xml := pr_retxml;

      -- Abre o no de dados
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<Dados>');
    ELSE
      -- Inicilizar as informações do XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');
    END IF;

    -- Loop sobre os titulos do questionario
    FOR rw_craptqs IN cr_craptqs LOOP

      -- Abre a tag de titulos
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<titulos>');

      -- Popula com o texto do titulo
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '<titulo>'||rw_craptqs.dstitulo||'</titulo>');

      -- Loop sobre as perguntas
      FOR rw_crappqs IN cr_crappqs(rw_craptqs.nrseqtit) LOOP
        -- Abre a tag de perguntas
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                '<perguntas>');

        -- Popula os dados com as perguntas
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                '<pergunta>'||rw_crappqs.dspergun||'</pergunta>'||
                                '<nrseqper>'||rw_crappqs.nrseqper||'</nrseqper>'||
                                '<inobriga>'||rw_crappqs.inobriga||'</inobriga>'||
                                '<dsregexi>'||rw_crappqs.dsregexi||'</dsregexi>'||
                                '<intipres>'||rw_crappqs.intipres||'</intipres>');

        -- Se for uma resposta de escolha, gera as opcoes
        IF rw_crappqs.intipres = 1 THEN

          -- Abre a tag de principal com as respostas
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                  '<opcoes>');

          -- Loop sobre as opcoes de respostas
          FOR rw_craprqs IN cr_craprqs(rw_crappqs.nrseqper) LOOP
            -- Abre a tag de respostas
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                    '<opcao>');
            -- Popula os dados com as respostas
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                    '<nrseqres>'||rw_craprqs.nrseqres||'</nrseqres>'||
                                    '<dsrespos>'||rw_craprqs.dsrespos||'</dsrespos>');

            -- Fecha a tag de respostas
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                    '</opcao>');

          END LOOP;

          -- Fecha a tag de principal com as respostas
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                  '</opcoes>');

        END IF;

        -- Se possuir respostas, entao deve-se gerar a tag de respostas
        IF nvl(pr_nrseqrrq,0) <> 0 THEN

          -- Abre o cursor com as respostas existentes na proposta
          OPEN cr_craprrq(rw_crappqs.nrseqper);
          FETCH cr_craprrq INTO rw_craprrq;

          -- Se a pergunta possuir resposta, gera as tags com as repostas
          IF cr_craprrq%FOUND THEN
            -- Gera as tags de respostas
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                    '<resposta_nrseqres>'||rw_craprrq.nrseqres||'</resposta_nrseqres>'||
                                    '<resposta_dsrespos>'||rw_craprrq.dsrespos||'</resposta_dsrespos>');
          END IF;
          CLOSE cr_craprrq;
        END IF;

        -- Fecha a tag de perguntas
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                '</perguntas>');

      END LOOP;

      -- Fecha a tag de titulos
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              '</titulos>');

    END LOOP;

    -- Fecha a tag principal
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                            '</Dados>',TRUE);

    -- Atualiza a variavel CLOB de retorno
    pr_retxml := vr_des_xml;

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_retorna_perguntas: ' || SQLERRM;

  END pc_monta_perguntas;

  -- Rotina para retorno das perguntas do questionario na tela PARMCR
  PROCEDURE pc_ret_perguntas_parmcr(pr_nrversao crapvqs.nrversao%TYPE  --> Versao do questionario de dados
                                   ,pr_inpessoa crapass.inpessoa%TYPE  --> Tipo de pessoa
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    vr_retxml CLOB;
  BEGIN
    -- Chama a rotina para montar as perguntas
    pc_monta_perguntas(pr_nrversao => pr_nrversao,
                       pr_inpessoa => pr_inpessoa,
                       pr_nrseqrrq => 0,
                       pr_inregcal => 0,
                       pr_retxml   => vr_retxml,
                       pr_cdcritic => pr_cdcritic,
                       pr_dscritic => pr_dscritic);

    -- Converte o CLOB para o formato XML
    BEGIN
      pr_retxml := xmltype(vr_retxml);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao converter para XML: ' ||SQLERRM;
    END;

    -- Verifica se o processo ocorreu erro
    IF nvl(pr_cdcritic,0) <> 0 OR pr_dscritic IS NOT NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END IF;
  END;

  -- Rotina para retorno das perguntas do questionario
  PROCEDURE pc_retorna_perguntas(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                ,pr_nrseqrrq IN craprrq.nrseqrrq%TYPE --> Numero sequencial do retorno das respostas do questionario
                                ,pr_inregcal IN PLS_INTEGER           --> Indicador se deve ou nao exibir registros que sao calculados
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    vr_retxml CLOB;
  BEGIN

    pc_retorna_perguntas(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrseqrrq => pr_nrseqrrq,
                         pr_inregcal => pr_inregcal,
                         pr_retxml   => vr_retxml,
                         pr_cdcritic => pr_cdcritic,
                         pr_dscritic => pr_dscritic);

    -- Se nao tiver questionario, vai ser nulo.
    IF vr_retxml IS NOT NULL THEN
      BEGIN
        pr_retxml := xmltype(vr_retxml);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao converter para XML: ' ||SQLERRM;
      END;
    END IF;

    IF pr_dscritic IS NOT NULL THEN
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END IF;

  END;

  -- Rotina para retorno das perguntas do questionario que eh chamada via Relatorio de contratos (EMPR0003)
  PROCEDURE pc_retorna_perguntas(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                ,pr_nrseqrrq IN craprrq.nrseqrrq%TYPE --> Numero sequencial do retorno das respostas do questionario
                                ,pr_inregcal IN PLS_INTEGER           --> Indicador se deve ou nao exibir registros que sao calculados
                                ,pr_retxml   IN OUT CLOB              --> Arquivo de retorno do XML
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

    -- Busca a sequencia das respostas
    CURSOR cr_craprrd IS
      SELECT nrversao
        FROM craptqs,
             crappqs,
             craprrq
       WHERE craprrq.nrseqrrq = pr_nrseqrrq
         AND crappqs.nrseqper = craprrq.nrseqper
         AND craptqs.nrseqtit = crappqs.nrseqtit;

    -- Buscar a versao do questionario
    CURSOR cr_crapvqs(pr_dtmvtolt crapvqs.dtinivig%TYPE) IS
      SELECT nrversao
        FROM crapvqs
       WHERE dtinivig <= pr_dtmvtolt
       ORDER BY dtinivig DESC;

    -- Identifica se a pessoa eh fisica ou juridica
    CURSOR cr_crapass IS
      SELECT inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;


    /* Cursor genérico de calendário */
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

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
    vr_retxml       XMLType;                -- Retorno do xml
    vr_nrversao     crapvqs.nrversao%TYPE;  -- Versao que eh utilizada do questionario
    vr_inpessoa     crapass.inpessoa%TYPE;  -- Indicador de pessoa fisica ou juridica
    vr_des_xml      CLOB;                   -- CLOB com o conteudo do XML
    vr_texto_completo  varchar2(32600);     --> Variável para armazenar os dados do XML antes de incluir no CLOB

  BEGIN

    -- Busca os dados do calendario
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Busca os dados do calendario
    OPEN cr_crapass;
    FETCH cr_crapass INTO vr_inpessoa;
    IF cr_crapass%NOTFOUND THEN
      vr_dscritic := 'Conta nao encontrada.';
      CLOSE cr_crapass;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapass;

    -- Verifica se possui sequencia de respostas. Se possuir deve-se utilizar a versao que foi feita as respostas
    IF nvl(pr_nrseqrrq,0) <> 0 THEN
      OPEN cr_craprrd;
      FETCH cr_craprrd INTO vr_nrversao;
      IF cr_craprrd%NOTFOUND THEN
        vr_dscritic := 'Sequencia de respostas nao encontrada.';
        CLOSE cr_craprrd;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_craprrd;
    ELSE -- Busca a versao de acordo com a data
      OPEN cr_crapvqs(rw_crapdat.dtmvtolt);
      FETCH cr_crapvqs INTO vr_nrversao;
      IF cr_crapvqs%NOTFOUND THEN
        CLOSE cr_crapvqs;
        -- Nao deve dar erro... apenas encerrar o programa
        RETURN;
      END IF;
      CLOSE cr_crapvqs;
    END IF;

    pc_monta_perguntas(pr_nrversao => vr_nrversao,
                       pr_inpessoa => vr_inpessoa,
                       pr_nrseqrrq => pr_nrseqrrq,
                       pr_inregcal => pr_inregcal,
                       pr_retxml   => pr_retxml,
                       pr_cdcritic => pr_cdcritic,
                       pr_dscritic => pr_dscritic);

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_retorna_perguntas: ' || SQLERRM;

  END pc_retorna_perguntas;

-- Rotina para buscar o conteudo do campo com base no xml enviado
PROCEDURE pc_busca_conteudo_campo(pr_retxml    IN OUT NOCOPY XMLType,    --> XML de retorno da operadora
                                  pr_nrcampo   IN VARCHAR2,              --> Campo a ser buscado no XML
                                  pr_indcampo  IN VARCHAR2,              --> Tipo de dado: S=String, D=Data, N=Numerico
                                  pr_retorno  OUT VARCHAR2,              --> Retorno do campo do xml
                                  pr_dscritic IN OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_tab_xml   gene0007.typ_tab_tagxml; --> PL Table para armazenar conteúdo XML
  BEGIN
    -- Busca a informacao no XML
    gene0007.pc_itera_nodos(pr_xpath      => pr_nrcampo
                           ,pr_xml        => pr_retxml
                           ,pr_list_nodos => vr_tab_xml
                           ,pr_des_erro   => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Se encontrou mais de um registro, deve dar mensagem de erro
    IF  vr_tab_xml.count > 1 THEN
      vr_dscritic := 'Mais de um registro XML encontrado.';
      RAISE vr_exc_saida;
    ELSIF vr_tab_xml.count = 1 THEN -- Se encontrou, retornar o texto
      IF pr_indcampo = 'D' THEN -- Se o tipo de dado for Data, transformar para data
        -- Se for tudo zeros, desconsiderar
        IF vr_tab_xml(0).tag IN ('00000000','0')  THEN
          pr_retorno := NULL;
        ELSE
          pr_retorno := to_date(vr_tab_xml(0).tag,'yyyymmdd');
        END IF;
      ELSE
        pr_retorno := replace(vr_tab_xml(0).tag,'.',',');
      END IF;
    END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao buscar campo '||pr_nrcampo||'. '||SQLERRM;
  END;

  -- Rotina para gravacao das respostas que foram efetuadas na tela ATENDA
  PROCEDURE pc_grava_respostas_mcr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                  ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                  ,pr_resposta IN VARCHAR2              --> Retorno das respostas
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

    -- Cursor sobre os emprestimos
    CURSOR cr_crawepr IS
      SELECT crawepr.nrseqrrq,
             crawepr.vlemprst,
             crawepr.qtpreemp,
             crapass.inpessoa,
             crapass.cdsexotl
        FROM crapass,
             crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctremp
         AND crapass.cdcooper = crawepr.cdcooper
         AND crapass.nrdconta = crawepr.nrdconta;
    rw_crawepr cr_crawepr%ROWTYPE;

    -- Cursor com as perguntas que tem respostas automaticas
    CURSOR cr_crappqs(pr_nrversao IN craptqs.nrversao%TYPE) IS
      SELECT crappqs.nrseqper,
             crappqs.nrregcal
        FROM craptqs,                 -- Busca todos os titulos da versao
             crappqs                  -- Perguntas que possuem respostas automaticas
       WHERE craptqs.nrversao        = pr_nrversao
         AND crappqs.nrseqtit        = craptqs.nrseqtit
         AND crappqs.nrregcal IS NOT NULL;

    -- Busca os socios da empresa
    CURSOR cr_crapavt IS
      SELECT nvl(crapass.cdsexotl, crapavt.cdsexcto) cdsexotl
        FROM crapass,
             crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.tpctrato = 6 --Juridico
         AND crapavt.dsproftl = 'SOCIO/PROPRIETARIO'
         AND crapass.cdcooper (+) = crapavt.cdcooper
         AND crapass.nrdconta (+) = crapavt.nrdconta;
     rw_crapavt cr_crapavt%ROWTYPE;

    -- Busca a resposta automatica com base na pergunta
    CURSOR cr_craprrq(pr_nrseqper craprqs.nrseqper%TYPE,
                      pr_nrrespos PLS_INTEGER) IS
      SELECT nrseqres
        FROM (
              SELECT craprqs.nrseqres,
                     ROW_NUMBER() OVER (ORDER BY nrordres) resposta
                FROM craprqs
               WHERE craprqs.nrseqper = pr_nrseqper
               ORDER BY nrordres)
       WHERE resposta = pr_nrrespos;
    rw_craprrq cr_craprrq%ROWTYPE;

    -- Cursor para buscar a versao do questionario
    CURSOR cr_craptqs(pr_nrseqrrq craprrq.nrseqrrq%TYPE) IS
      SELECT craptqs.nrversao
        FROM craptqs,
             crappqs,
             craprrq
       WHERE craprrq.nrseqrrq = pr_nrseqrrq
         AND crappqs.nrseqper = craprrq.nrseqper
         AND craptqs.nrseqtit = crappqs.nrseqtit;

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
    vr_craprrq      craprrq%ROWTYPE;        --> Tabela sobre a tabela de retorno das respostas do questionario
    vr_nrseqrrq     craprrq.nrseqrrq%TYPE;  --> numero sequencial das respostas
    vr_contador     PLS_INTEGER := 1;       --> Contador sobre o loop de respostas
    vr_nmtagres     VARCHAR2(50);           --> Tag com o caminho das respostas
    vr_nrresposta   PLS_INTEGER;            --> Numero da resposta no questionario automatizado
    vr_respostas    XmlType;                --> XML com as respostas
    vr_des_xml CLOB;
    vr_texto_completo  VARCHAR2(32600);     --> Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_nrversao     craptqs.nrversao%TYPE;  --> Versao do questionario

  BEGIN
    -- Abre o cursor de emprestimos
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO rw_crawepr;
    IF cr_crawepr%NOTFOUND THEN
      vr_dscritic := 'Emprestimo informado inexistente!';
      CLOSE cr_crawepr;
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crawepr;

    -- Atualiza o numero de retorno das respostas do questionario
    vr_nrseqrrq := rw_crawepr.nrseqrrq;

    -- Se nao vier resposta, nao precisa convertes para XML
    IF pr_resposta IS NOT NULL THEN
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                              pr_resposta,TRUE);
      -- Converte o parametro de varchar2 em XML
      -- O SUBSTR eh necessario porque vem <![CDATA[texto]]>
      vr_respostas := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       substr(pr_resposta,10,LENGTH(pr_resposta)-12));

    END IF;

    -- Se ja existir sequencia de resposta, exclui as respostas que ja existiram
    IF nvl(vr_nrseqrrq,0) <> 0 AND
       pr_resposta IS NOT NULL THEN -- Se vier nulo eh para atualizar somente as automaticas
      BEGIN
        DELETE craprrq
         WHERE nrseqrrq = vr_nrseqrrq;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir craprrd: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSIF nvl(vr_nrseqrrq,0) <> 0 AND
       pr_resposta IS NULL THEN -- Neste caso deve-se excluir somente as respostas automaticas
      -- Excluir as respostas automaticas
      BEGIN
        DELETE craprrq
         WHERE nrseqrrq = vr_nrseqrrq
           AND EXISTS (SELECT 1
                         FROM crappqs
                        WHERE crappqs.nrseqper = craprrq.nrseqper
                          AND nvl(crappqs.nrregcal,0) <> 0);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro exclusao craprrd: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      --busca o numero sequencial das respostas
      vr_nrseqrrq := fn_sequence(pr_nmtabela => 'CRAPRRQ', pr_nmdcampo => 'NRSEQRRQ',pr_dsdchave => '0');

      -- Associa o novo numero na tabela de emprestimos
      BEGIN
        UPDATE crawepr
           SET nrseqrrq = vr_nrseqrrq
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crawepr: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    END IF;

    -- Se possuir respostas, entao efetua o loop para preencher as mesmas
    IF pr_resposta IS NOT NULL THEN
      -- Efetua loop sobre as respostas
      LOOP
        -- Monta a tag com o caminho das respostas
        vr_nmtagres := '//dados/respostas['||vr_contador||']/';

        -- Se nao tiver informacao, sai do loop
        EXIT WHEN  vr_respostas.existsnode(vr_nmtagres||'nrseqper') = 0;

        vr_craprrq := NULL;

        -- Busca os dados das respostas
        pc_busca_conteudo_campo(vr_respostas, vr_nmtagres||'nrseqper','N', vr_craprrq.nrseqper, vr_dscritic);
        pc_busca_conteudo_campo(vr_respostas, vr_nmtagres||'nrseqres','N', vr_craprrq.nrseqres, vr_dscritic);
        pc_busca_conteudo_campo(vr_respostas, vr_nmtagres||'dsrespos','S', vr_craprrq.dsrespos, vr_dscritic);

        -- Verifica se ocorreu algum erro nas buscas
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Se possuir resposta, insere no retorno da resposta do questionario
        IF vr_craprrq.nrseqres IS NOT NULL OR
           vr_craprrq.dsrespos IS NOT NULL THEN
          BEGIN
            INSERT INTO craprrq
              (nrseqrrq,
               nrseqper,
               nrseqres,
               dsrespos)
             VALUES
              (vr_nrseqrrq,
               vr_craprrq.nrseqper,
               vr_craprrq.nrseqres,
               vr_craprrq.dsrespos);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CRAPRRQ: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;

        -- Vai para o proximo registro do xml
        vr_contador := vr_contador + 1;
      END LOOP;
    END IF;

    -- Busca a versao do questionario
    OPEN cr_craptqs(vr_nrseqrrq);
    FETCH cr_craptqs INTO vr_nrversao;
    CLOSE cr_craptqs;

    -- Efetua a busca por respostas automaticas
    FOR rw_crappqs IN cr_crappqs(vr_nrversao) LOOP

      -- Limpa a variavel de resposta
      vr_nrresposta := NULL;

      IF rw_crappqs.nrregcal = 1 THEN --Perfil de credito
        -- O perfil de credito tera as seguintes opcoes:
        --  Resposta 1: Se o valor do emprestimo for ate 1000
        --  Resposta 2: Se o valor do emprestimo for de 1001 a 3000
        --  resposta 3: Se o valor do emprestimo for de 3001 a 5000
        --  Resposta 4: Se o valor do emprestimo for superior a 5000
        IF rw_crawepr.vlemprst <= 1000 THEN
          vr_nrresposta := 1;
        ELSIF rw_crawepr.vlemprst <= 3000 THEN
          vr_nrresposta := 2;
        ELSIF rw_crawepr.vlemprst <= 5000 THEN
          vr_nrresposta := 3;
        ELSE
          vr_nrresposta := 4;
        END IF;
      ELSIF rw_crappqs.nrregcal = 2 THEN -- Prazo
        -- O prazo tera as seguintes opcoes
        --  Resposta 1: Ate 12 vezes
        --  Resposta 2: Ate 24 vezes
        --  Resposta 3: Ate 36 vezes
        --  Resposta 4: Ate 48 vezes
        IF rw_crawepr.qtpreemp <= 12 THEN
          vr_nrresposta := 1;
        ELSIF rw_crawepr.qtpreemp <= 24 THEN
          vr_nrresposta := 2;
        ELSIF rw_crawepr.qtpreemp <= 36 THEN
          vr_nrresposta := 3;
        ELSE
          vr_nrresposta := 4;
        END IF;
      ELSIF rw_crappqs.nrregcal = 3 THEN -- Genero
        IF rw_crawepr.inpessoa = 1 THEN -- Pessoa fisica
          IF rw_crawepr.cdsexotl IN (0,1) THEN -- Se for masculino
            vr_nrresposta := 1; -- Masculino
          ELSE
            vr_nrresposta := 2; -- Feminino
          END IF;
        ELSE -- Se for pessoa juridica
          -- Busca os dados do socio/administrador da empresa
          OPEN cr_crapavt;
          FETCH cr_crapavt INTO rw_crapavt;
          IF cr_crapavt%NOTFOUND THEN -- Se nao encontrar, considera como masculino
            rw_crapavt.cdsexotl := 1;
          END IF;
          CLOSE cr_crapavt;
          IF rw_crawepr.cdsexotl IN (0,1) THEN -- Se for masculino
            vr_nrresposta := 1; -- Masculino
          ELSE
            vr_nrresposta := 2; -- Feminino
          END IF;
        END IF;
      END IF;

      -- Se possuir resposta, entao efetua a gravacao da mesma
      IF vr_nrresposta IS NOT NULL THEN
        -- Busca a sequencia da resposta
        OPEN cr_craprrq(rw_crappqs.nrseqper, vr_nrresposta);
        FETCH cr_craprrq INTO rw_craprrq;
        -- Se nao encontrar resposta automatica, cancela o programa
        IF cr_craprrq%NOTFOUND THEN
          vr_dscritic := 'Resposta automatica nao encontrada!';
          CLOSE cr_craprrq;
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_craprrq;

        -- Insere a resposta automatica
        BEGIN
          INSERT INTO craprrq
            (nrseqrrq,
             nrseqper,
             nrseqres)
          VALUES
            (vr_nrseqrrq,
             rw_crappqs.nrseqper,
             rw_craprrq.nrseqres);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPRRQ automaticamente: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF;
    END LOOP;

  EXCEPTION
    WHEN vr_exc_saida THEN

      ROLLBACK;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      ROLLBACK;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_grava_respostas_mcr: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END;

  -- Rotina para verificar se a linha de credito deve possuir solicitacao de perguntas do questionario
  PROCEDURE pc_verifica_microcredito(pr_cdcooper IN craplcr.cdcooper%TYPE --> Código da cooperativa
                                    ,pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                    ,pr_inlcrmcr OUT VARCHAR2             --> Indicador de linha de credito como microcredito
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
    -- Busca a origem da linha de credito
    CURSOR cr_craplcr IS
      SELECT dsorgrec
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

    -- Variaveis gerais
    vr_dsorigens VARCHAR2(2000); --> Contem as origens que sao de microcredito
  BEGIN

    -- Busca a origem da linha de credito retornada do parametro
    OPEN cr_craplcr;
    FETCH cr_craplcr INTO rw_craplcr;
    CLOSE cr_craplcr;

    -- Busca as origens que sao de microcredito
    vr_dsorigens := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper =>  pr_cdcooper,
                                             pr_cdacesso => 'PERGUNTAS_MICROCREDITO');

    -- Inclui ponto-e-virgula no final para faciliar a busca
    vr_dsorigens := vr_dsorigens || ';';

    -- Verifica se a origem da linha passada como parametro esta parametrizada
    IF instr(vr_dsorigens, rw_craplcr.dsorgrec||';') > 0 THEN
      pr_inlcrmcr := 'S'; -- Retorna como encontrou a linha de credito parametrizada
    ELSE
      pr_inlcrmcr := 'N'; -- Retorna como nao encontrada a linha de credito parametrizada
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em pc_verifica_microcredito: ' || SQLERRM;
  END;

  -- Rotina para verificar se a linha de credito deve possuir solicitacao de perguntas do questionario
  PROCEDURE pc_verifica_microcredito_xml(pr_cdcooper IN craplcr.cdcooper%TYPE --> Código da cooperativa
                                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

    vr_inlcrmcr VARCHAR2(01);
  BEGIN
    -- Executa a rotina de verificacao de microcredito
    pc_verifica_microcredito(pr_cdcooper => pr_cdcooper,
                             pr_cdlcremp => pr_cdlcremp,
                             pr_inlcrmcr => vr_inlcrmcr,
                             pr_cdcritic => pr_cdcritic,
                             pr_dscritic => pr_dscritic);
   -- Se ocorreu erro, retorna o erro
   IF pr_dscritic IS NOT NULL THEN
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   ELSE -- Senao retorna o indicador de microcredito
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><inlcrmcr>' || vr_inlcrmcr || '</inlcrmcr></Root>');
   END IF;
  END;
END empr0005;
/

