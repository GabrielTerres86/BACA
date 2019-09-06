CREATE OR REPLACE PACKAGE CECRED.RATI0002 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RATI0002                     
  --  Sistema  : Rotinas para Rating dos Cooperados
  --  Sigla    : RATI
  --  Autor    : Andrino Carlos de Souza Junior (RKAM)
  --  Data     : Janeiro/2015.                   Ultima atualizacao: 08/06/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Rating dos Cooperados.
  --
  -- Alteracoes:   08/06/2015 - Ajuste na busca do sequencial da PC_EFETUA_ANALISE_CTR (Andrino-RKAM)
  --
  --               08/08/2018 - P450 - Ajuste para o novo Grupo Economico (Guilherme/AMcom)
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina geral de insert, update, select e delete da tela PARRAC na tabela CRAPVAC
  PROCEDURE pc_crapvac(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqvac IN crapvac.nrseqvac%TYPE --> Numero da versao do questionario
                      ,pr_cdcooper IN crapvac.cdcooper%TYPE -- Codigo da cooperativa de destino
                      ,pr_dsversao IN crapvac.dsversao%TYPE --> Descricao da versao
                      ,pr_dtinivig IN VARCHAR2              --> Data de inicio da vigencia
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina geral de insert, update e select da tela PARRAC na tabela CRAPQAC
  PROCEDURE pc_crapqac(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / I - Inclur)
                      ,pr_nrseqqac IN crapqac.nrseqqac%TYPE         --> Sequencia do questionario
                      ,pr_nrseqvac IN crapqac.nrseqvac%TYPE         --> Sequencia da versao
                      ,pr_nrseqiac IN crapqac.nrseqiac%TYPE         --> Sequencia do indicador
                      ,pr_inpessoa IN crapqac.inpessoa%TYPE         --> Indicador de pessoa (1-Fisica, 2-Juridica, 3-Ambos)
                      ,pr_nrordper IN crapqac.nrordper%TYPE         --> Ordem da pergunta dentro do indicador
                      ,pr_vlparam1 IN crapqac.vlparam1%TYPE         --> Parametro 1 informado pelo usuario
                      ,pr_vlparam2 IN crapqac.vlparam2%TYPE         --> Parametro 2 informado pelo usuario
                      ,pr_instatus IN crapqac.instatus%TYPE         --> Status (1-Pre-Aprovado, 2-Analise Manual, 3-Nao conceder)
                      ,pr_inmensag IN crapqac.inmensag%TYPE         --> Local da mensagem (1-Msg Positiva, 2-Msg Atencao)
                      ,pr_dsmensag IN crapqac.dsmensag%TYPE         --> Texto com a mensagem
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina que ira duplicar a versao da cooperativa atual para outra cooperativa
  PROCEDURE pc_cria_versao_cop(pr_nrseqvac IN crapvac.nrseqvac%TYPE  -- Sequencial do questionario que será copiado
                              ,pr_cdcopdst IN crapvac.cdcooper%TYPE  -- Codigo da cooperativa de destino
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para criação de uma versao com base em outra versao de perguntas
  PROCEDURE pc_cria_versao(pr_nrseqvac IN crapvac.nrseqvac%TYPE --> Numero da versao do questionario de origem
                          ,pr_dsversao IN crapvac.dsversao%TYPE --> Nome da nova versao
                          ,pr_dtinivig IN VARCHAR2              --> Data de inicio da nova vigencia
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para retornar as variaveis de parametro do indicador
  PROCEDURE pc_ret_variaveis_crapiac(pr_nrseqiac IN crapiac.nrseqiac%TYPE --> Sequencia do indicador
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Funcao para retornar a variavel de acordo com a posicao solicitada
  FUNCTION fn_retorna_variavel(pr_dstexto VARCHAR2,    -- Texto que sera procurado a variavel
                               pr_inposic PLS_INTEGER) -- Numero da variavel no texto
                            RETURN VARCHAR2;

  -- Valida se as perguntas do questionario estao completas
  PROCEDURE pc_valida_questionario(pr_nrseqvac IN crapvac.nrseqvac%TYPE --> Numero da versao do questionario de origem
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo


  -- Recebe a mensagem cadastrada e transforma em mensagem correta
  FUNCTION fn_ajuste_mensagem(pr_dsmensag crapqac.dsmensag%TYPE --> Mensagem 
                             ,pr_nmparam1 crapiac.nmparam1%TYPE --> Nome do parametro 1
                             ,pr_nmparam2 crapiac.nmparam1%TYPE --> Nome do parametro 2
                             ,pr_nmparam3 crapiac.nmparam1%TYPE --> Nome do parametro 3
                             ,pr_vlparam1 crapdac.vlparam1%TYPE --> Conteudo do parametro 1
                             ,pr_vlparam2 crapdac.vlparam1%TYPE --> Conteudo do parametro 2
                             ,pr_vlparam3 crapdac.vlparam1%TYPE)--> Conteudo do parametro 3
                             RETURN VARCHAR2;

  -- Efetua a analise de credito de um contrato
  PROCEDURE pc_efetua_analise_ctr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Codigo da cooperativa
                                 ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Efetua a analise de credito de um contrato
  PROCEDURE pc_retorna_analise_ctr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                  ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                  ,pr_retxml   OUT CLOB                 --> Arquivo de retorno do XML
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina que indica se deve habilitar / desabilitar o parecer da analise de credito
  PROCEDURE pc_desabilita_parecer(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta)
                                 ,pr_cdcooper crapvac.cdcooper%TYPE    --> Codigo da cooperativa conectada
                                 ,pr_inparece VARCHAR2                 --> Indicador de desabilitacao de parecer (S-Desabilita, N-Habilita)
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
  
  PROCEDURE pc_retorna_descricao_risco(pr_cdcooper IN crawepr.cdcooper%TYPE --> Codigo da cooperativa
                                      ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                      ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                      ,pr_retxml   OUT CLOB                 --> Arquivo de retorno do XML
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
  /******************************************************************************/
  /**      Procedure para trazer o risco na proposta de emprestimo.            **/
  /******************************************************************************/
  PROCEDURE pc_obtem_emprestimo_risco( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                      ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                                      ,pr_cdfinemp IN crapepr.cdfinemp%TYPE  --> Finalidade do emprestimo
                                      ,pr_cdlcremp IN crapepr.cdlcremp%TYPE  --> Linha de credito do emprestimo
                                      ,pr_dsctrliq IN VARCHAR2               --> Lista de descrições de situação dos contratos
                                      ,pr_nrctremp IN crawepr.nrctremp%TYPE DEFAULT NULL  --> Número do contrato de emprestimos
                                      ------ OUT ------
                                      ,pr_nivrisco     OUT VARCHAR2          --> Retorna nivel do risco
                                      ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                                      ,pr_cdcritic     OUT INTEGER);         --> Codigo da critica                                       
                                      
  /******************************************************************************/
  /**      Procedure para atualizar o risco na proposta de emprestimo.         **/
  /******************************************************************************/
  PROCEDURE pc_atualiza_risco_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimento
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Numero de contrato                                      
                                      ------ OUT ------                                      
                                      ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                                      ,pr_cdcritic     OUT INTEGER);         --> Codigo da critica                                      
END RATI0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.rati0002 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : rati0002                     
  --  Sistema  : Rotinas para Rating dos Cooperados
  --  Sigla    : RATI
  --  Autor    : Andrino Carlos de Souza Junior - RKAM
  --  Data     : Janeiro/2015.                   Ultima atualizacao: 12/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para analise complementar do Rating
  --
  -- Alteracoes: 12/11/2015 - Alterado as descricões de risco na procedure pc_retorna_analise_ctr 
  --                          (Tiago/Rodrigo SD356389).
  --
  --             04/01/2016 - Incluida procedure pc_retorna_descricao_risco (Heitor - RKAM)
  --
  --             27/09/2016 - Na rotina pc_efetua_analise_ctr, ao detectar que a linha nao deve gerar
  --                          parecer de credito, ira limpar o parecer gerado anteriormente, se houver.
  --                          Houve casos com alteracao de linha de credito que manteve o parecer indevidamente.
  --                          Heitor (RKAM) - Chamado 513641
  --
  --             01/12/2016 - Fazer tratamento para incorporação. (Oscar)   
  --
  --             26/02/2018 - Retirada a validação do NOT IN dos tipos de contas 6, 7, 17 e 18, substituído pelo 
  --                          NOT IN dos tipos de contas que tem a modalidade 3 – Conta Aplicação.
  --                          PRJ366 (Lombardi).
  --
  --             27/02/2018 - Procedure pc_analise_individual alterada para buscar descricao da situacao 
  --                          da tabela. PRJ366 (Lombardi).
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina que indica se deve habilitar / desabilitar o parecer da analise de credito
  PROCEDURE pc_desabilita_parecer(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta)
                                 ,pr_cdcooper crapvac.cdcooper%TYPE    --> Codigo da cooperativa conectada
                                 ,pr_inparece VARCHAR2                 --> Indicador de desabilitacao de parecer (S-Desabilita, N-Habilita)
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis gerais
      vr_inparece VARCHAR2(01); 
      vr_dssituacao VARCHAR2(12);

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

          WHEN 'C' THEN -- Consulta
            vr_inparece := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                     pr_cdcooper =>  pr_cdcooper,
                                                     pr_cdacesso => 'PRC_ANALISE_CREDITO');

            -- Se nao tiver registro, entao esta desabilitado
            IF vr_inparece IS NULL THEN
              vr_inparece := 'N';
            END IF;

            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
            -- Conteudo da consulta
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0, pr_tag_nova => 'inparece', pr_tag_cont => vr_inparece, pr_des_erro => vr_dscritic);

          WHEN 'A' THEN -- Alteracao
            -- Atualiza a tabela de parametros
            BEGIN
              UPDATE crapprm
                 SET dsvlrprm = pr_inparece
               WHERE crapprm.nmsistem = 'CRED'
                 AND crapprm.cdcooper = pr_cdcooper
                 AND crapprm.cdacesso = 'PRC_ANALISE_CREDITO';
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao alterar CRAPPRM: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            -- Se nao tiver atualizado nada, insere o registro
            IF SQL%ROWCOUNT = 0 THEN
              BEGIN
                INSERT INTO crapprm
                  (nmsistem,
                   cdcooper,
                   cdacesso,
                   dstexprm,
                   dsvlrprm)
                 VALUES
                  ('CRED',
                   pr_cdcooper,
                   'PRC_ANALISE_CREDITO',
                   'Indicador se deve efetuar o parecer da analise de credito (rating)',
                   pr_inparece);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao incluir CRAPPRM: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END IF;

            -- Atribui a situacao do parecer para o log
            IF pr_inparece = 'S' THEN
              vr_dssituacao := ' desabilitou';
            ELSE
              vr_dssituacao := ' habilitou';
            END IF;
            
            -- gera o log de alteracao
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_nmarqlog => 'PARRAC' 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - ' ||
                                         'Operador ' || vr_cdoperad || vr_dssituacao || ' o parecer da cooperativa.' );


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
        pr_dscritic := 'Erro geral em pc_desabilita_parecer: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
     END pc_desabilita_parecer;

  -- Rotina auxiliar para inserir o questionario vazio
  PROCEDURE pc_insere_crapqac(pr_nrseqvac crapqac.nrseqvac%TYPE
                             ,pr_nrseqiac crapqac.nrseqiac%TYPE
                             ,pr_inpessoa crapqac.inpessoa%TYPE
                             ,pr_nrordper crapqac.nrordper%TYPE) IS
    BEGIN
      INSERT INTO crapqac 
        (nrseqqac, 
         nrseqvac, 
         nrseqiac, 
         inpessoa, 
         nrordper,
         instatus) 
       VALUES
        (fn_sequence(pr_nmtabela => 'CRAPQAC', pr_nmdcampo => 'NRSEQQAC',pr_dsdchave => '0'),
         pr_nrseqvac,
         pr_nrseqiac,
         pr_inpessoa,
         pr_nrordper,
         3);
    END;                             

  -- Rotina geral de insert, update, select e delete da tela PARRAC na tabela CRAPVAC
  PROCEDURE pc_crapvac(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                      ,pr_nrseqvac IN crapvac.nrseqvac%TYPE --> Numero da versao do questionario
                      ,pr_cdcooper IN crapvac.cdcooper%TYPE -- Codigo da cooperativa de destino
                      ,pr_dsversao IN crapvac.dsversao%TYPE --> Descricao da versao
                      ,pr_dtinivig IN VARCHAR2              --> Data de inicio da vigencia
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre a versao do questionario de analise de credito
      CURSOR cr_crapvac IS
        SELECT nrseqvac,
               gene0007.fn_caract_acento(dsversao) dsversao,
               dtinivig
          FROM crapvac
         WHERE nrseqvac = decode(nvl(pr_nrseqvac,0),0,nrseqvac,pr_nrseqvac)
           AND cdcooper = nvl(pr_cdcooper,cdcooper)
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
      vr_nrseqvac crapvac.nrseqvac%TYPE;

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
              UPDATE crapvac
                 SET dsversao = pr_dsversao,
                     dtinivig = to_date(pr_dtinivig,'dd/mm/yyyy')
               WHERE nrseqvac = pr_nrseqvac;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar crapvac: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre as versoes do questionario de microcredito
            FOR rw_crapvac IN cr_crapvac LOOP
                
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrseqvac', pr_tag_cont => rw_crapvac.nrseqvac, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsversao', pr_tag_cont => rw_crapvac.dsversao, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtinivig', pr_tag_cont => to_char(rw_crapvac.dtinivig,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
              
              vr_contador := vr_contador + 1;
            END LOOP;

          WHEN 'E' THEN -- Exclusao

            -- Efetua a exclusao das perguntas
            BEGIN
              DELETE crapqac
               WHERE nrseqvac = pr_nrseqvac;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir CRAPQAC: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Efetua a exclusao das versoes do questionario de analise de credito
            BEGIN
              DELETE crapvac
               WHERE nrseqvac = pr_nrseqvac;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir crapvac: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'I' THEN -- Inclusao

            -- Efetua a inclusao no cadastro de versao do questionario de microcredito
            BEGIN
              INSERT INTO crapvac
                 (nrseqvac,
                  cdcooper,
                  dsversao,
                  dtinivig)
                VALUES(
                  fn_sequence(pr_nmtabela => 'CRAPVAC', pr_nmdcampo => 'NRSEQVAC',pr_dsdchave => '0'),
                  pr_cdcooper,
                  pr_dsversao,
                  to_date(pr_dtinivig,'dd/mm/yyyy'))
                 RETURNING nrseqvac INTO vr_nrseqvac;

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN dup_val_on_index THEN
                vr_dscritic := 'Atencao: Ja existe versao para esta data. Favor verificar!';
                RAISE vr_exc_saida;
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao inserir crapvac: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
            
            -- Insere o questionario vazio
            pc_insere_crapqac(vr_nrseqvac,1,1,0); -- Data de Nascimento
            pc_insere_crapqac(vr_nrseqvac,1,1,1);
            pc_insere_crapqac(vr_nrseqvac,1,1,2);
            pc_insere_crapqac(vr_nrseqvac,2,2,0); -- Data de Fundacao
            pc_insere_crapqac(vr_nrseqvac,2,2,1);
            pc_insere_crapqac(vr_nrseqvac,3,1,0); -- Comprometimento de Renda
            pc_insere_crapqac(vr_nrseqvac,3,1,1);
            pc_insere_crapqac(vr_nrseqvac,3,1,2);
            pc_insere_crapqac(vr_nrseqvac,3,2,0);
            pc_insere_crapqac(vr_nrseqvac,3,2,1);
            pc_insere_crapqac(vr_nrseqvac,3,2,2);
            pc_insere_crapqac(vr_nrseqvac,4,3,0); -- Tipo de Residencia
            pc_insere_crapqac(vr_nrseqvac,4,3,1);
            pc_insere_crapqac(vr_nrseqvac,4,3,2);
            pc_insere_crapqac(vr_nrseqvac,4,3,3);
            pc_insere_crapqac(vr_nrseqvac,4,3,4);
            pc_insere_crapqac(vr_nrseqvac,4,3,5);
            pc_insere_crapqac(vr_nrseqvac,4,3,6);
            pc_insere_crapqac(vr_nrseqvac,5,1,0); -- Data de Admissao
            pc_insere_crapqac(vr_nrseqvac,5,1,1);
            pc_insere_crapqac(vr_nrseqvac,6,3,0); -- Data de Abertura da Conta
            pc_insere_crapqac(vr_nrseqvac,6,3,1);
            pc_insere_crapqac(vr_nrseqvac,7,3,0); -- Situacao da Conta
            pc_insere_crapqac(vr_nrseqvac,7,3,1);
            pc_insere_crapqac(vr_nrseqvac,8,3,0); -- Reciprocidade
            pc_insere_crapqac(vr_nrseqvac,8,3,1);
            pc_insere_crapqac(vr_nrseqvac,9,3,0); -- Saldo Medio
            pc_insere_crapqac(vr_nrseqvac,9,3,1);
            pc_insere_crapqac(vr_nrseqvac,10,3,0); -- Cheque sem fundos
            pc_insere_crapqac(vr_nrseqvac,10,3,1);
            pc_insere_crapqac(vr_nrseqvac,10,3,2);
            pc_insere_crapqac(vr_nrseqvac,11,3,0); -- Quantidade de Estouros
            pc_insere_crapqac(vr_nrseqvac,11,3,1);
            pc_insere_crapqac(vr_nrseqvac,12,3,0); -- Atraso acima de 90 dias
            pc_insere_crapqac(vr_nrseqvac,12,3,1);
            pc_insere_crapqac(vr_nrseqvac,13,1,0); -- Quantidade de Instituicoes
            pc_insere_crapqac(vr_nrseqvac,13,1,1);
            pc_insere_crapqac(vr_nrseqvac,13,1,2);
            pc_insere_crapqac(vr_nrseqvac,13,1,3);
            pc_insere_crapqac(vr_nrseqvac,13,2,0);
            pc_insere_crapqac(vr_nrseqvac,13,2,1);
            pc_insere_crapqac(vr_nrseqvac,13,2,2);
            pc_insere_crapqac(vr_nrseqvac,13,2,3);
            pc_insere_crapqac(vr_nrseqvac,14,3,0); -- Operacoes Vencidas
            pc_insere_crapqac(vr_nrseqvac,14,3,1);
            pc_insere_crapqac(vr_nrseqvac,15,3,0); -- Operacoes em Prejuizo
            pc_insere_crapqac(vr_nrseqvac,15,3,1);
            pc_insere_crapqac(vr_nrseqvac,16,3,0); -- Restricoes SPC/Serasa
            pc_insere_crapqac(vr_nrseqvac,16,3,1);
            pc_insere_crapqac(vr_nrseqvac,16,3,2);
            pc_insere_crapqac(vr_nrseqvac,16,3,3);
            pc_insere_crapqac(vr_nrseqvac,17,3,0); -- Corresponsavel
            pc_insere_crapqac(vr_nrseqvac,17,3,1);

            -- Retorna a sequencia criada
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><nrseqvac>' || vr_nrseqvac || '</nrseqvac></Root>');

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
        pr_dscritic := 'Erro geral em crapvac: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_crapvac;

  -- Funcao para verificar se o indicador esta ativo
  FUNCTION fn_verifica_situacao_idc(pr_nrseqvac crapqac.nrseqvac%TYPE,
                                    pr_nrseqiac crapqac.nrseqiac%TYPE) RETURN PLS_INTEGER IS
      -- Cursor que verifica se existe algum questionario preenchido para o indicador
      CURSOR cr_crapqac IS
        SELECT 1
          FROM crapqac
         WHERE nrseqvac = pr_nrseqvac
           AND nrseqiac = pr_nrseqiac
           AND (vlparam1 IS NOT NULL
            OR  vlparam2 IS NOT NULL
            OR  instatus IS NOT NULL
            OR  inmensag IS NOT NULL
            OR  dsmensag IS NOT NULL);
      rw_crapqac cr_crapqac%ROWTYPE;
           
    BEGIN
      --Abre o cursor de questionario
      OPEN cr_crapqac;
      FETCH cr_crapqac INTO rw_crapqac;
      
      -- Se nao encontrar, entao o indicador esta inativo
      IF cr_crapqac%NOTFOUND THEN
        CLOSE cr_crapqac;
        RETURN 2; -- Retorna inativo
      END IF;
      CLOSE cr_crapqac;
      RETURN 1; -- Retorna ativo
    END;                                    

  -- Rotina geral de insert, update e select da tela PARRAC na tabela CRAPQAC
  PROCEDURE pc_crapqac(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / I - Inclur)
                      ,pr_nrseqqac IN crapqac.nrseqqac%TYPE         --> Sequencia do questionario
                      ,pr_nrseqvac IN crapqac.nrseqvac%TYPE         --> Sequencia da versao
                      ,pr_nrseqiac IN crapqac.nrseqiac%TYPE         --> Sequencia do indicador
                      ,pr_inpessoa IN crapqac.inpessoa%TYPE         --> Indicador de pessoa (1-Fisica, 2-Juridica, 3-Ambos)
                      ,pr_nrordper IN crapqac.nrordper%TYPE         --> Ordem da pergunta dentro do indicador
                      ,pr_vlparam1 IN crapqac.vlparam1%TYPE         --> Parametro 1 informado pelo usuario
                      ,pr_vlparam2 IN crapqac.vlparam2%TYPE         --> Parametro 2 informado pelo usuario
                      ,pr_instatus IN crapqac.instatus%TYPE         --> Status (1-Pre-Aprovado, 2-Analise Manual, 3-Nao conceder)
                      ,pr_inmensag IN crapqac.inmensag%TYPE         --> Local da mensagem (1-Msg Positiva, 2-Msg Atencao)
                      ,pr_dsmensag IN crapqac.dsmensag%TYPE         --> Texto com a mensagem
                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre as perguntas do questionario de analise de credito
      CURSOR cr_crapqac IS
        SELECT crapqac.nrseqqac,
               crapqac.nrseqvac,
               crapqac.nrseqiac,
               crapiac.dsindica,
               crapqac.inpessoa,
               crapqac.nrordper,
               crapqac.vlparam1,
               crapqac.vlparam2,
               crapqac.instatus,
               crapqac.inmensag,
               crapqac.dsmensag,
               row_number() over (partition by crapqac.nrseqvac, crapqac.nrseqiac 
                                      order by crapqac.nrseqvac, crapqac.nrseqiac, crapqac.inpessoa, crapqac.nrordper) nrseq
          FROM crapiac,
               crapqac
         WHERE crapiac.nrseqiac = crapqac.nrseqiac
           AND crapqac.nrseqqac = decode(nvl(pr_nrseqqac,0),0,crapqac.nrseqqac,pr_nrseqqac)
           AND crapqac.nrseqvac = decode(nvl(pr_nrseqvac,0),0,crapqac.nrseqvac,pr_nrseqvac)
           AND crapqac.nrseqiac = decode(nvl(pr_nrseqiac,0),0,crapqac.nrseqiac,pr_nrseqiac)
           AND crapqac.inpessoa = decode(nvl(pr_inpessoa,0),0,crapqac.inpessoa,pr_inpessoa)
           AND crapqac.nrordper = decode(nvl(pr_nrordper,0),0,crapqac.nrordper,pr_nrordper)
         ORDER BY crapqac.nrseqvac, crapqac.nrseqiac, crapqac.inpessoa, crapqac.nrordper;

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
      vr_ind PLS_INTEGER := -1;  -- Contador de indicadores
      vr_det PLS_INTEGER := 0;  -- Contador de detalhes
      vr_instatus PLS_INTEGER; -- Situacao do indicador (1-ativo, 2-inativo)

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
              UPDATE crapqac
                 SET vlparam1 = pr_vlparam1,
                     vlparam2 = pr_vlparam2,
                     instatus = pr_instatus,
                     inmensag = pr_inmensag,
                     dsmensag = pr_dsmensag
               WHERE nrseqqac = pr_nrseqqac;

            -- Verifica se houve problema na atualizacao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao atualizar crapqac: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'E' THEN -- Exclusao

            BEGIN
              -- Limpa os campos. Nao pode excluir, porque senao bagunca a tela PARRAC
              UPDATE crapqac
                 SET vlparam1 = NULL,
                     vlparam2 = NULL,
                     instatus = NULL,
                     inmensag = NULL,
                     dsmensag = NULL
               WHERE nrseqvac = pr_nrseqvac
                 AND nrseqiac = pr_nrseqiac;

            -- Verifica se houve problema na exclusao do registro
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao excluir crapqac: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

          WHEN 'C' THEN -- Consulta
            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

            -- Loop sobre as versoes do questionario de microcredito
            FOR rw_crapqac IN cr_crapqac LOOP
              
              -- Se for um novo indicador, cria o nó do indicador
              IF rw_crapqac.nrseq = 1 THEN
                vr_ind := vr_ind + 1;
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'      , pr_posicao => 0, pr_tag_nova => 'indicadores', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'indicadores', pr_posicao => vr_ind, pr_tag_nova => 'nrseqvac', pr_tag_cont => rw_crapqac.nrseqvac, pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'indicadores', pr_posicao => vr_ind, pr_tag_nova => 'nrseqiac', pr_tag_cont => rw_crapqac.nrseqiac, pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'indicadores', pr_posicao => vr_ind, pr_tag_nova => 'dsindica', pr_tag_cont => rw_crapqac.dsindica, pr_des_erro => vr_dscritic);
                
                -- Verifica a situacao do indicador
                vr_instatus := fn_verifica_situacao_idc(rw_crapqac.nrseqvac, rw_crapqac.nrseqiac);
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'indicadores', pr_posicao => vr_ind, pr_tag_nova => 'instatus', pr_tag_cont => vr_instatus, pr_des_erro => vr_dscritic);
                
              END IF;

              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'indicadores'   , pr_posicao => vr_ind, pr_tag_nova => 'detalhe', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => vr_det, pr_tag_nova => 'nrseqqac', pr_tag_cont => rw_crapqac.nrseqqac, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => vr_det, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_crapqac.inpessoa, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => vr_det, pr_tag_nova => 'nrordper', pr_tag_cont => rw_crapqac.nrordper, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => vr_det, pr_tag_nova => 'vlparam1', pr_tag_cont => rw_crapqac.vlparam1, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => vr_det, pr_tag_nova => 'vlparam2', pr_tag_cont => rw_crapqac.vlparam2, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => vr_det, pr_tag_nova => 'instatus', pr_tag_cont => rw_crapqac.instatus, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => vr_det, pr_tag_nova => 'inmensag', pr_tag_cont => rw_crapqac.inmensag, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'detalhe', pr_posicao => vr_det, pr_tag_nova => 'dsmensag', pr_tag_cont => rw_crapqac.dsmensag, pr_des_erro => vr_dscritic);
              
              vr_det := vr_det + 1;
            END LOOP;

          WHEN 'I' THEN -- Inclusao

            -- Efetua a inclusao no cadastro de versao do questionario de microcredito
            BEGIN
              INSERT INTO crapqac
                 (nrseqqac,
                  nrseqvac,
                  nrseqiac,
                  inpessoa,
                  nrordper,
                  vlparam1,
                  vlparam2,
                  instatus,
                  inmensag,
                  dsmensag)
                VALUES(
                  fn_sequence(pr_nmtabela => 'CRAPQAC', pr_nmdcampo => 'NRSEQQAC',pr_dsdchave => '0'),
                  pr_nrseqvac,
                  pr_nrseqiac,
                  pr_inpessoa,
                  pr_nrordper,
                  pr_vlparam1,
                  pr_vlparam2,
                  pr_instatus,
                  pr_inmensag,
                  pr_dsmensag);

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problema ao inserir crapqac: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;

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
        pr_dscritic := 'Erro geral em crapqac: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_crapqac;


  -- Rotina que ira duplicar a versao da cooperativa atual para outra cooperativa
  PROCEDURE pc_cria_versao_cop(pr_nrseqvac IN crapvac.nrseqvac%TYPE  -- Sequencial do questionario que será copiado
                              ,pr_cdcopdst IN crapvac.cdcooper%TYPE  -- Codigo da cooperativa de destino
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre a versao de origem do questionario
      CURSOR cr_crapvac IS
        SELECT cdcooper,
               dsversao,
               dtinivig
          FROM crapvac
         WHERE nrseqvac = pr_nrseqvac;
      rw_crapvac cr_crapvac%ROWTYPE;

      -- cursor sobre a tabela de cooperativas
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         WHERE cdcooper = decode(pr_cdcopdst,0, cdcooper, pr_cdcopdst)
           AND cdcooper <> rw_crapvac.cdcooper;

      -- Variaveis de critica
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis gerais
      vr_nrseqvac  crapvac.nrseqvac%TYPE; -- Numero sequencial da versao da analise de credito

    BEGIN
      -- Busca os dados da versao de origem
      OPEN cr_crapvac;
      FETCH cr_crapvac INTO rw_crapvac;
      
      -- Se nao encontrar, cancela a rotina
      IF cr_crapvac%NOTFOUND THEN  
        CLOSE cr_crapvac;
        vr_dscritic := 'Versao de origem nao existe!';
        RAISE vr_exc_saida;
      END IF;
    
      -- Efetua o loop sobre as cooperativas
      FOR rw_crapcop IN cr_crapcop LOOP
        -- Exclui a versao que ja existe na data do questionario para a cooperativa de destino
        BEGIN
          DELETE crapqac
           WHERE nrseqvac = (SELECT nrseqvac
                               FROM crapvac
                              WHERE cdcooper = rw_crapcop.cdcooper
                                AND dtinivig = rw_crapvac.dtinivig);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir CRAPQAC: '||sqlerrm;
            RAISE vr_Exc_saida;
        END;

        -- Exclui a versao que ja existe na data da versao para a cooperativa de destino
        BEGIN
          DELETE crapvac
           WHERE cdcooper = rw_crapcop.cdcooper
             AND dtinivig = rw_crapvac.dtinivig;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir CRAPVAC: '||sqlerrm;
            RAISE vr_Exc_saida;
        END;
        
        -- Busca o sequencial da versao
        vr_nrseqvac := fn_sequence(pr_nmtabela => 'CRAPVAC', pr_nmdcampo => 'NRSEQVAC',pr_dsdchave => '0');

        -- Insere a versao para a nova cooperativa
        BEGIN
          INSERT INTO crapvac
            (nrseqvac,
             cdcooper, 
             dsversao,
             dtinivig)
           VALUES
            (vr_nrseqvac,
             rw_crapcop.cdcooper, 
             rw_crapvac.dsversao,
             rw_crapvac.dtinivig);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPVAC: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
              
        -- Insere as perguntas para a nova versao
        BEGIN
          INSERT INTO crapqac
            (nrseqqac,
             nrseqvac,
             nrseqiac,
             inpessoa,
             nrordper,
             vlparam1,
             vlparam2,
             instatus,
             inmensag,
             dsmensag)
            (SELECT fn_sequence(pr_nmtabela => 'CRAPQAC', pr_nmdcampo => 'NRSEQQAC',pr_dsdchave => '0'),
                    vr_nrseqvac,
                    nrseqiac,
                    inpessoa,
                    nrordper,
                    vlparam1,
                    vlparam2,
                    instatus,
                    inmensag,
                    dsmensag
               FROM crapqac
              WHERE nrseqvac = pr_nrseqvac);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir CRAPQAC: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

      END LOOP;
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
    END;
    
  -- Rotina para criação de uma versao com base em outra versao de perguntas
  PROCEDURE pc_cria_versao(pr_nrseqvac IN crapvac.nrseqvac%TYPE --> Numero da versao do questionario de origem
                          ,pr_dsversao IN crapvac.dsversao%TYPE --> Nome da nova versao
                          ,pr_dtinivig IN VARCHAR2              --> Data de inicio da nova vigencia
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor sobre a versao de origem do questionario
      CURSOR cr_crapvac IS
        SELECT cdcooper,
               dsversao,
               dtinivig
          FROM crapvac
         WHERE nrseqvac = pr_nrseqvac;
      rw_crapvac cr_crapvac%ROWTYPE;

      -- Variaveis de critica
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis gerais
      vr_nrseqvac  crapvac.nrseqvac%TYPE; -- Numero sequencial da versao da analise de credito

    BEGIN
      -- Busca os dados da versao de origem
      OPEN cr_crapvac;
      FETCH cr_crapvac INTO rw_crapvac;
      
      -- Se nao encontrar, cancela a rotina
      IF cr_crapvac%NOTFOUND THEN  
        CLOSE cr_crapvac;
        vr_dscritic := 'Versao de origem nao existe!';
        RAISE vr_exc_saida;
      END IF;
    
      -- Exclui a versao que ja existe na data do questionario para a cooperativa de destino
      BEGIN
        DELETE crapqac
         WHERE nrseqvac = (SELECT nrseqvac
                             FROM crapvac
                            WHERE cdcooper = rw_crapvac.cdcooper
                              AND dtinivig = to_date(pr_dtinivig,'dd/mm/yyyy'));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir CRAPQAC: '||sqlerrm;
          RAISE vr_Exc_saida;
      END;

      -- Exclui a versao que ja existe na data da versao para a cooperativa de destino
      BEGIN
        DELETE crapvac
         WHERE cdcooper = rw_crapvac.cdcooper
           AND dtinivig = to_date(pr_dtinivig,'DD/MM/YYYY');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir CRAPVAC: '||sqlerrm;
          RAISE vr_Exc_saida;
      END;
        
      -- Busca o sequencial da versao
      vr_nrseqvac := fn_sequence(pr_nmtabela => 'CRAPVAC', pr_nmdcampo => 'NRSEQVAC',pr_dsdchave => '0');

      -- Insere a versao para a nova cooperativa
      BEGIN
        INSERT INTO crapvac
          (nrseqvac,
           cdcooper, 
           dsversao,
           dtinivig)
         VALUES
          (vr_nrseqvac,
           rw_crapvac.cdcooper, 
           pr_dsversao,
           to_date(pr_dtinivig,'dd/mm/yyyy'));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir CRAPVAC: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
              
      -- Insere as perguntas para a nova versao
      BEGIN
        INSERT INTO crapqac
          (nrseqqac,
           nrseqvac,
           nrseqiac,
           inpessoa,
           nrordper,
           vlparam1,
           vlparam2,
           instatus,
           inmensag,
           dsmensag)
          (SELECT fn_sequence(pr_nmtabela => 'CRAPQAC', pr_nmdcampo => 'NRSEQQAC',pr_dsdchave => '0'),
                  vr_nrseqvac,
                  nrseqiac,
                  inpessoa,
                  nrordper,
                  vlparam1,
                  vlparam2,
                  instatus,
                  inmensag,
                  dsmensag
             FROM crapqac
            WHERE nrseqvac = pr_nrseqvac);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir CRAPQAC: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

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
    END;
    
        
  -- Rotina para retornar as variaveis de parametro do indicador
  PROCEDURE pc_ret_variaveis_crapiac(pr_nrseqiac IN crapiac.nrseqiac%TYPE --> Sequencia do indicador
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
      -- Cursor sobre a tabela de indicadores de analise de credito
      CURSOR cr_crapiac IS
        SELECT nmparam1,
               nmparam2,
               nmparam3
          FROM crapiac
         WHERE nrseqiac = pr_nrseqiac;
      rw_crapiac cr_crapiac%ROWTYPE;

      -- Variaveis de critica
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

    BEGIN
      -- Abre o cursor sobre a tabela de indicadores de analise de credito
      OPEN cr_crapiac;
      FETCH cr_crapiac INTO rw_crapiac;
      
      -- Se nao encontrar, da critica e encerra o processo
      IF cr_crapiac%NOTFOUND THEN
        CLOSE cr_crapiac;
        vr_dscritic := 'Sequencia do indicador nao cadastrada';
        RAISE vr_exc_saida;
      END IF;
      
      -- Fecha o cursor
      CLOSE cr_crapiac;

      -- Envia os parametros de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>'||
                                     '<nmparam1>' || rw_crapiac.nmparam1 || '</nmparam1>'||
                                     '<nmparam2>' || rw_crapiac.nmparam2 || '</nmparam2>'||
                                     '<nmparam3>' || rw_crapiac.nmparam3 || '</nmparam3>'||
                                     '</Root>');
      
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
    END;

  -- Funcao para retornar a variavel de acordo com a posicao solicitada
  FUNCTION fn_retorna_variavel(pr_dstexto VARCHAR2,    -- Texto que sera procurado a variavel
                               pr_inposic PLS_INTEGER) -- Numero da variavel no texto
                            RETURN VARCHAR2 IS
      vr_dstexto_tmp VARCHAR2(500); -- Variavel temporaria com o conteudo do parametro
      vr_dstexto_ret VARCHAR2(500); -- Variavel que contera o texto que sera devolvido
    BEGIN
      -- Atualiza a variavel temporaria com o texto do parametro
      vr_dstexto_tmp := pr_dstexto;
      
      -- Busca a variavel conforme o numero informado no parametro
      FOR x IN 1..pr_inposic LOOP
        IF instr(vr_dstexto_tmp,'#') <> 0 THEN
          vr_dstexto_tmp := substr(vr_dstexto_tmp,instr(vr_dstexto_tmp,'#')+1);
        ELSE
          RETURN NULL; -- Se nao encontrar, encerra o programa retornando nulo
        END IF;
      END LOOP;
      
      -- Verifica ate que posicao eh o texto da variavel
      FOR x IN 1..length(vr_dstexto_tmp) LOOP
        IF ascii(substr(vr_dstexto_tmp,x,1)) BETWEEN 97 AND 122 OR -- Letra a ate o z
           ascii(substr(vr_dstexto_tmp,x,1)) BETWEEN 65 AND 90 THEN -- Letra A ate o Z
          vr_dstexto_ret := vr_dstexto_ret || substr(vr_dstexto_tmp,x,1);
        ELSE
          EXIT;
        END IF;
      END LOOP;

      -- Retorna o texto da variavel encontrada
      RETURN vr_dstexto_ret;

    END;

  -- Valida se as perguntas do questionario estao completas
  PROCEDURE pc_valida_questionario(pr_nrseqvac IN crapvac.nrseqvac%TYPE --> Numero da versao do questionario de origem
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

      -- Cursor que verifica se todas as variaveis existentes no texto existem no indicador
      CURSOR cr_crapqac IS
        SELECT c.dsindica,
               a.dsmensag
          FROM crapiac c,
               crapqac a
         WHERE c.nrseqiac = a.nrseqiac
           AND a.nrseqvac = pr_nrseqvac
           AND (rati0002.fn_retorna_variavel(a.dsmensag,1) IS NOT NULL 
            AND NOT EXISTS (SELECT 1
                              FROM crapiac b
                             WHERE b.nrseqiac = a.nrseqiac
                               AND rati0002.fn_retorna_variavel(a.dsmensag,1)
                                    IN (b.nmparam1, b.nmparam2, b.nmparam3)))
            OR (rati0002.fn_retorna_variavel(a.dsmensag,2) IS NOT NULL 
            AND NOT EXISTS (SELECT 1
                              FROM crapiac b
                             WHERE b.nrseqiac = a.nrseqiac
                               AND rati0002.fn_retorna_variavel(a.dsmensag,2)
                                    IN (b.nmparam1, b.nmparam2, b.nmparam3)))
            OR (rati0002.fn_retorna_variavel(a.dsmensag,3) IS NOT NULL 
            AND NOT EXISTS (SELECT 1
                              FROM crapiac b
                             WHERE b.nrseqiac = a.nrseqiac
                               AND rati0002.fn_retorna_variavel(a.dsmensag,3)
                                    IN (b.nmparam1, b.nmparam2, b.nmparam3)));

      -- Cursor que verifica se todas as mensagens existentes no indicador foram cadastradas
      CURSOR cr_crapqac_2 IS
        SELECT crapiac.nrseqiac,
               crapiac.dsindica,
               sum(DECODE(crapqac.nrordper,0,DECODE(crapqac.dsmensag,NULL,0,1))) qtmenpos,
               sum(DECODE(crapqac.nrordper,0,0,DECODE(crapqac.dsmensag,NULL,0,1))) qtmenerr
          FROM crapiac,
               crapqac
         WHERE crapqac.nrseqiac (+) = crapiac.nrseqiac
           AND crapqac.nrseqvac (+) = pr_nrseqvac
         GROUP BY crapiac.nrseqiac,
                  crapiac.dsindica
         ORDER BY crapiac.nrseqiac;
         
 
      -- Tipo de variavel de parametros de indicadores
      TYPE typ_reg_crapiac IS
        RECORD(qtmenpos PLS_INTEGER,
               qtmenerr PLS_INTEGER);
      TYPE typ_tab_crapiac IS
        TABLE OF typ_reg_crapiac
        INDEX BY PLS_INTEGER;
      
      vr_tab_crapiac typ_tab_crapiac;

      -- Variaveis de critica
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;  -- COntador de registros de erro
    BEGIN

      -- Preenche a tabela de indicaores com as quantidades de mensagens necessarias
      --Data de Nascimento
      vr_tab_crapiac(1).qtmenpos := 1;
      vr_tab_crapiac(1).qtmenerr := 2;      
      --Data de Fundacao
      vr_tab_crapiac(2).qtmenpos := 1;
      vr_tab_crapiac(2).qtmenerr := 1;      
      --Comprometimento de Renda
      vr_tab_crapiac(3).qtmenpos := 2;
      vr_tab_crapiac(3).qtmenerr := 4;
      --Tipo de Residencia
      vr_tab_crapiac(4).qtmenpos := 1;
      vr_tab_crapiac(4).qtmenerr := 6;
      --Data de Admissao no Emprego Atual
      vr_tab_crapiac(5).qtmenpos := 1;
      vr_tab_crapiac(5).qtmenerr := 1;
      --Data de Abertura de Conta
      vr_tab_crapiac(6).qtmenpos := 1;
      vr_tab_crapiac(6).qtmenerr := 1;
      --Situacao da Conta
      vr_tab_crapiac(7).qtmenpos := 1;
      vr_tab_crapiac(7).qtmenerr := 1;
      --Reciprocidade de Capital para a Linha Solicitada
      vr_tab_crapiac(8).qtmenpos := 1;
      vr_tab_crapiac(8).qtmenerr := 1;
      --Saldo Medio do Semestre
      vr_tab_crapiac(9).qtmenpos := 1;
      vr_tab_crapiac(9).qtmenerr := 1;
      --Quantidade de Cheques sem Fundos
      vr_tab_crapiac(10).qtmenpos := 1;
      vr_tab_crapiac(10).qtmenerr := 2;
      --Quantidade de Estouros
      vr_tab_crapiac(11).qtmenpos := 1;
      vr_tab_crapiac(11).qtmenerr := 1;
      --Atraso Acima de 90 Dias
      vr_tab_crapiac(12).qtmenpos := 1;
      vr_tab_crapiac(12).qtmenerr := 1;
      --Quantidade de Instituicoes
      vr_tab_crapiac(13).qtmenpos := 2;
      vr_tab_crapiac(13).qtmenerr := 6;
      --Operacoes Vencidas
      vr_tab_crapiac(14).qtmenpos := 1;
      vr_tab_crapiac(14).qtmenerr := 1;
      --Operacoes em Prejuizo
      vr_tab_crapiac(15).qtmenpos := 1;
      vr_tab_crapiac(15).qtmenerr := 1;
      --Restricoes SPC/Serasa
      vr_tab_crapiac(16).qtmenpos := 1;
      vr_tab_crapiac(16).qtmenerr := 3;
      --Corresponsavel
      vr_tab_crapiac(17).qtmenpos := 1;
      vr_tab_crapiac(17).qtmenerr := 1;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Verifica se todas as variaveis existentes no texto existem no indicador
      FOR rw_crapqac IN cr_crapqac LOOP
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => 'Indicador "'||rw_crapqac.dsindica||'" possui variaveis nao parametrizadas na mensagem.', pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
      END LOOP;

      -- Verifica se todas as mensagens existentes no indicador foram cadastradas
      FOR rw_crapqac_2 IN cr_crapqac_2 LOOP
        -- Verifica o total da tabela com o existente no parametro
        IF vr_tab_crapiac(rw_crapqac_2.nrseqiac).qtmenpos <> nvl(rw_crapqac_2.qtmenpos,0) OR
           vr_tab_crapiac(rw_crapqac_2.nrseqiac).qtmenerr <> nvl(rw_crapqac_2.qtmenerr,0) THEN
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dscritic', pr_tag_cont => 'Indicador "'||rw_crapqac_2.dsindica||'" nao possui todas as mensagens cadastradas.', pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;
        END IF;
      END LOOP;

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
    END;

  PROCEDURE pc_busca_saldo_devedor(pr_cdcooper crapass.cdcooper%TYPE,   --> Codigo da cooperativa
                                   pr_nrdconta crapass.nrdconta%TYPE,   --> Codigo da conta
                                   pr_qtmesclc PLS_INTEGER,             --> Quantidade de meses para o calculo
                                   pr_crapdat  btch0001.cr_crapdat%ROWTYPE, --> Registro de data
                                   pr_vltotpag OUT NUMBER,              --> Valor de parcelas em atraso a pagar
                                   pr_cdcritic OUT PLS_INTEGER,         --> Código da crítica
                                   pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

      -- Cursor sobre os emprestimos
      CURSOR cr_crapepr IS
        SELECT a.nrctremp,
               a.tpemprst
          FROM crapepr a
         WHERE a.inliquid = 0 -- Nao estiver liquidado
           AND a.inprejuz = 0 -- Nao estiver em prejuizo
           AND a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta;

      -- Cursor sobre a tabela de prestacoes do emprestimo
      CURSOR cr_crappep(pr_nrctremp crappep.nrctremp%TYPE) IS
        SELECT SUM(decode(greatest(dtvencto, add_months(pr_crapdat.dtmvtolt,pr_qtmesclc*-1)),
                            dtvencto,a.vlparepr - a.vlpagpar,0)) vlsaldo_par,
               SUM(a.vlparepr - a.vlpagpar) vlsaldo_tot
          FROM crappep a
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND inliquid = 0 -- Que nao esteja paga
           AND dtvencto < pr_crapdat.dtmvtolt -- Data menor que o parametro. Foi deixado esta linha para pegar indice
           AND gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => dtvencto) < pr_crapdat.dtmvtolt;
      rw_crappep cr_crappep%ROWTYPE;
           
      --Variaveis para uso na craptab
      vr_dstextab    craptab.dstextab%TYPE;
      vr_inusatab    BOOLEAN;
      vr_digitaliza  craptab.dstextab%TYPE;
      vr_parempctl   craptab.dstextab%TYPE;

      --Tabela de Memoria de dados emprestimo
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;

      --Variaveis Erro
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(4000);
      vr_des_reto  VARCHAR2(3);
      vr_tab_erro  GENE0001.typ_tab_erro;
      vr_exc_saida EXCEPTION;

      --Variaveis para uso nos Indices
      vr_index_epr VARCHAR2(100);

      -- Variaveis gerais
      vr_qtregist    PLS_INTEGER;     -- Quantidade de registros retornados na EMPR0001
      vr_vltotpag    crappep.vlparepr%TYPE := 0; -- Valor total em atraso
      vr_vlparpag    crappep.vlparepr%TYPE := 0; -- Valor parcial em atraso. Este eh o valor que esta maior que o periodo

    BEGIN
      
      --Buscar Indicador Uso Taxa da tabela
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        --Nao usa tabela
        vr_inusatab:= FALSE;
      ELSE
        IF  SUBSTR(vr_dstextab,1,1) = '0' THEN
          --Nao usa tabela
          vr_inusatab:= FALSE;
        ELSE
          --Nao usa tabela
          vr_inusatab:= TRUE;
        END IF;
      END IF;
      -- busca o tipo de documento GED
      vr_digitaliza:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'DIGITALIZA'
                                                ,pr_tpregist => 5);

      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_parempctl:= tabe0001.fn_busca_dstextab(pr_cdcooper => 3 /*Fixo Cecred*/
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPCTL'
                                               ,pr_tpregist => 1);
      
      -- Efetua o loop sobre os emprestimos
      FOR rw_crapepr IN cr_crapepr LOOP

        /* Busca saldo total de emprestimos */
        EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdagenci => 0                   --> Código da agência
                                        ,pr_nrdcaixa => 0                   --> Número do caixa
                                        ,pr_cdoperad => 0                   --> Código do operador
                                        ,pr_nmdatela => 'RATI0002'          --> Nome datela conectada
                                        ,pr_idorigem => 1                   --> Indicador da origem da chamada
                                        ,pr_nrdconta => pr_nrdconta         --> Conta do associado
                                        ,pr_idseqttl => 1                   --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat => pr_crapdat        --> Vetor com dados de parâmetro (CRAPDAT)
                                        ,pr_dtcalcul => NULL                --> Data solicitada do calculo
                                        ,pr_nrctremp => rw_crapepr.nrctremp --> Número contrato empréstimo
                                        ,pr_cdprogra => 'B1WGEN0003'        --> Programa conectado
                                        ,pr_inusatab => vr_inusatab         --> Indicador de utilização da tabela
                                        ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                        ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                        ,pr_nmprimtl => ' '                 --> Nome Primeiro Titular
                                        ,pr_tab_parempctl => vr_parempctl   --> Dados tabela parametro
                                        ,pr_tab_digitaliza => vr_digitaliza --> Dados tabela parametro
                                        ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                        ,pr_nrregist => 0                   --> Qtd registro por pagina
                                        ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                        ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empréstimo
                                        ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros

        --Se ocorreu erro
        IF vr_des_reto = 'NOK' THEN
          --Se tem erro na tabela
          IF vr_tab_erro.COUNT > 0 THEN
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_dscritic:= 'Nao foi possivel concluir a requisicao';
          END IF;
          --Sair com erro
          RAISE vr_exc_saida;
        END IF;

        --Buscar primeiro registro da tabela de emprestimos
        vr_index_epr:= vr_tab_dados_epr.FIRST;
        --Se Retornou Dados
        WHILE vr_index_epr IS NOT NULL LOOP
          -- se for do tipo TR, deve-se calcular com base no saldo total de atraso
          -- dividido pelo periodo em atraso
          IF rw_crapepr.tpemprst = 0 THEN
            -- Vai somar somente se a quantidade de meses em atraso for superior ao parametro
            IF vr_tab_dados_epr(vr_index_epr).qtmesatr > pr_qtmesclc THEN
              -- Acumula o valor de parcelas
              -- Pega o valor total e divide 
              vr_vlparpag := vr_vlparpag + 
                             ((vr_tab_dados_epr(vr_index_epr).vltotpag / vr_tab_dados_epr(vr_index_epr).qtmesatr) * -- Retorna o valor de cada parcela
                                             vr_tab_dados_epr(vr_index_epr).qtmesatr); -- Retorna a quantidade de meses que deve-se analisar
                
            END IF;

            -- Acumula o valor de parcelas
            -- Pega o valor total e divide 
            IF vr_tab_dados_epr(vr_index_epr).qtmesatr > 0 THEN
              vr_vltotpag := vr_vltotpag + 
                           ((vr_tab_dados_epr(vr_index_epr).vltotpag / vr_tab_dados_epr(vr_index_epr).qtmesatr) * -- Retorna o valor de cada parcela
                                           vr_tab_dados_epr(vr_index_epr).qtmesatr); -- Retorna a quantidade de meses que deve-se analisar
            END IF;              
          ELSE -- Se for PP
            -- Abre o cursor de parcelas do contrato
            OPEN cr_crappep(rw_crapepr.nrctremp);
            FETCH cr_crappep INTO rw_crappep;
            CLOSE cr_crappep;

            -- Acumula o valor de parcelas
            vr_vltotpag := vr_vltotpag + vr_tab_dados_epr(vr_index_epr).vltotpag; 
            vr_vlparpag := vr_vlparpag + nvl(rw_crappep.vlsaldo_par,0);

          END IF;
          -- Vai para o proximo registro
          vr_index_epr:= vr_tab_dados_epr.NEXT(vr_index_epr);
        END LOOP;
      END LOOP;
      
      -- Se o valor parcial for maior que zeros, entao teve parcelas com atraso maior
      -- que o periodo de limite. Neste caso deve-se retornar o valor total de atraso,
      -- independente do periodo
      IF vr_vlparpag > 0 THEN
        pr_vltotpag := vr_vltotpag;
      ELSE
        vr_vltotpag := 0;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em analise_individual: ' || SQLERRM;
    END;    

  -- Efetua a analise de credito individualmente
  PROCEDURE pc_analise_individual(pr_nrseqpac IN crapdac.nrseqpac%TYPE --> Sequencial do parecer
                                 ,pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                 ,pr_nrdconta IN crapdac.nrdconta%TYPE --> Numero da conta a ser analisada
                                 ,pr_nrcpfcgc IN crapdac.nrcpfcgc%TYPE --> Numero do CPF / CGC
                                 ,pr_intippes IN crapdac.intippes%TYPE --> Tipo de pessoa do parecer (1-titular, 2-conjuge, 3-socio, 4-grupo economico)
                                 ,pr_inpessoa IN crapdac.inpessoa%TYPE --> Indicador de tipo de pessoa (1-Fisica, 2-Juridica)
                                 ,pr_vlemprst IN crawepr.vlemprst%TYPE --> Valor do emprestimo
                                 ,pr_vlpreemp IN crawepr.vlpreemp%TYPE --> Valor da parcela do emprestimo
                                 ,pr_qtrecpro IN NUMBER                --> Quantidade de reciprocidade da linha
                                 ,pr_crapdat  IN btch0001.cr_crapdat%ROWTYPE --> Data do emprestimo
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

      -- Cursor sobre a versao do questionario
      CURSOR cr_crapvac IS
        SELECT nrseqvac
          FROM crapvac
         WHERE cdcooper = pr_Cdcooper
           AND dtinivig <= pr_crapdat.dtmvtolt
         ORDER BY dtinivig DESC;

      -- Cursor sobre os indicadores
      CURSOR cr_crapiac IS
        SELECT nrseqiac, 
               inpesfis, 
               inpesjur,
               inconjug,
               insocpfi,
               insocpju 
          FROM crapiac
         ORDER BY nrseqiac;

      -- Cursor sobre os parametros do questionario
      CURSOR cr_crapqac(pr_nrseqvac crapqac.nrseqvac%TYPE,
                        pr_nrseqiac crapiac.nrseqiac%TYPE) IS
        SELECT nrseqqac,
               nrordper,
               vlparam1,
               vlparam2,
               instatus,
               inmensag
          FROM crapqac
         WHERE nrseqvac = pr_nrseqvac
           AND nrseqiac = pr_nrseqiac
           AND inpessoa = decode(inpessoa,3,inpessoa,pr_inpessoa)
         ORDER BY decode(nrordper,0,999,nrordper);
      
      -- Busca o periodo de analise
      CURSOR cr_crapqac_per(pr_nrseqvac crapqac.nrseqvac%TYPE,
                            pr_nrseqiac crapiac.nrseqiac%TYPE) IS
        SELECT vlparam1
          FROM crapqac
         WHERE nrseqvac = pr_nrseqvac
           AND nrseqiac = pr_nrseqiac
           AND nrordper = 0 -- Buscar da sequencia 0
           AND inpessoa = 3;


      -- Cursor sobre o associado
      CURSOR cr_crapass IS
        SELECT crapass.dtadmiss,
               crapass.nrcpfcgc,
               crapass.cdsitdct,
               crapass.cdagenci,
               crapass.nmprimtl
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Cursor sobre o titular da conta
      CURSOR cr_crapttl(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT crapttl.dtnasttl,
               crapttl.vlsalari,
               crapttl.vldrendi##1 + crapttl.vldrendi##2 +
               crapttl.vldrendi##3 + crapttl.vldrendi##4 + crapttl.vldrendi##5 +
               crapttl.vldrendi##6 vlrendim,
               crapttl.dtadmemp,
               crapttl.nrinfcad
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
           AND crapttl.nrdconta = pr_nrdconta
           AND crapttl.idseqttl = 1;
      rw_crapttl     cr_crapttl%ROWTYPE;
  
      -- Cursor sobre o titular da conta
      CURSOR cr_crapjur IS
        SELECT crapjur.dtiniatv,
               crapjur.nrinfcad
          FROM crapjur
         WHERE crapjur.cdcooper = pr_cdcooper
           AND crapjur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;

      -- Cursor para buscar os dados da residencia
      CURSOR cr_crapenc IS
        SELECT incasprp,
               decode(incasprp,1,'QUITADO',
                               2,'FINANCIADO',
                               3,'ALUGADO',
                               4,'FAMILIA',
                               5,'CEDIDO',
                                 'OUTROS') dscasprp,
               crapenc.dtinires
          FROM crapenc
         WHERE crapenc.cdcooper = pr_cdcooper
           AND crapenc.nrdconta = pr_nrdconta
           AND crapenc.idseqttl = 1
           AND crapenc.tpendass = decode(pr_inpessoa,2,9,10); -- Se for PJ, considerar Comercial, Senao considerar residencial
      rw_crapenc cr_crapenc%ROWTYPE;

      -- Cursor para buscar o valor total do aluguel
      CURSOR cr_crapenc_2 IS
        SELECT nvl(SUM(crapenc.vlalugue),0) vlalugue
          FROM crapenc
         WHERE crapenc.cdcooper = pr_cdcooper
           AND crapenc.nrdconta = pr_nrdconta
           AND crapenc.idseqttl = 1
           AND crapenc.incasprp = 3 -- Tipo Alugado
           AND crapenc.tpendass = decode(pr_inpessoa,2,9,10); -- Se for PJ, considerar Comercial, Senao considerar residencial
      rw_crapenc_2 cr_crapenc_2%ROWTYPE;

      -- Cursor sobre o saldo da conta
      CURSOR cr_crapsld IS
        SELECT (vlsmstre##1+vlsmstre##2+vlsmstre##3+vlsmstre##4+vlsmstre##5+vlsmstre##6)/6 vlsmstre
          FROM crapsld
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapsld cr_crapsld%ROWTYPE;

      -- Cursor para buscar o total de cheques sem fundos
      CURSOR cr_crapneg(pr_qtmeschq PLS_INTEGER) IS
        SELECT COUNT(*) qtcheque
          FROM crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
           AND crapneg.nrdconta = pr_nrdconta
           AND crapneg.dtiniest >= add_months(pr_crapdat.dtmvtolt,pr_qtmeschq*-1)
           AND crapneg.cdhisest = 1 -- Devolucao de cheques
           AND crapneg.cdobserv IN (11,12); -- Cheques sem fundos

      -- Cursor para buscar o total de estouros
      CURSOR cr_crapneg_2(pr_qtmesest PLS_INTEGER) IS
        SELECT COUNT(*) qtcheque
          FROM crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
           AND crapneg.dtiniest >= add_months(pr_crapdat.dtmvtolt,pr_qtmesest*-1)
           AND crapneg.nrdconta = pr_nrdconta
           AND crapneg.cdhisest = 5; -- Estouro

      -- Busca os dados do SCR
      CURSOR cr_crapopf IS
        SELECT dtrefere,
               crapopf.qtifssfn
          FROM crapopf
         WHERE nrcpfcgc = pr_nrcpfcgc
         ORDER BY crapopf.dtrefere DESC;
       rw_crapopf cr_crapopf%ROWTYPE;
               
      -- Cursor para busca dos dados do conjuge
      CURSOR cr_crapcje IS
        SELECT nrdconta,
               nrcpfcgc,
               vlsalari
          FROM (SELECT crapass.nrdconta, -- Consulta pela conta do conjuge
                       crapass.nrcpfcgc,
                       crapass.dtultalt,
                       crapcje.vlsalari
                  FROM crapass,
                       crapcje
                 WHERE crapcje.cdcooper = pr_cdcooper
                   AND crapcje.nrdconta = pr_nrdconta
                   AND crapcje.idseqttl = 1 -- Titular
                   AND crapcje.nrctacje <> 0
                   AND crapass.cdcooper = crapcje.cdcooper
                   AND crapass.nrdconta = crapcje.nrctacje
                   AND crapass.dtelimin IS NULL -- O mesmo tem que estar ativo
                 UNION ALL -- Consulta pelo CPF
                SELECT crapass.nrdconta,
                       crapass.nrcpfcgc,
                       crapass.dtultalt,
                       crapcje.vlsalari
                  FROM crapass,
                       crapcje
                 WHERE crapcje.cdcooper = pr_cdcooper
                   AND crapcje.nrdconta = pr_nrdconta
                   AND crapcje.idseqttl = 1 -- Titular
                   AND crapcje.nrcpfcjg <> 0
                   AND crapass.cdcooper = crapcje.cdcooper
                   AND crapass.nrcpfcgc = crapcje.nrcpfcjg
                   AND crapass.dtelimin IS NULL -- O mesmo tem que estar ativo
                 UNION ALL -- Conjuge sem conta
                SELECT NULL,
                       crapcje.nrcpfcjg,
                       to_date('01/01/1900','dd/mm/yyyy'),
                       crapcje.vlsalari
                  FROM crapcje
                 WHERE crapcje.cdcooper = pr_cdcooper
                   AND crapcje.nrdconta = pr_nrdconta
                   AND crapcje.idseqttl = 1 -- Titular
                   AND crapcje.nrdconta <> 0)                   
          ORDER BY dtultalt DESC; -- Ordenar pela ultima atualizacao cadastral
      rw_crapcje cr_crapcje%ROWTYPE;
      
          
      -- Busca o total de operacoes em atraso, vencidas e com prejuizo
      CURSOR cr_crapvop(pr_nrcpfcgc crapass.nrcpfcgc%TYPE,
                        pr_dtrefere DATE,
                        pr_cdvencto_ini crapvop.cdvencto%TYPE,
                        pr_cdvencto_fim crapvop.cdvencto%TYPE) IS
        SELECT nvl(SUM(vlvencto),0)
          FROM crapvop
         WHERE cdvencto BETWEEN pr_cdvencto_ini AND pr_cdvencto_fim
         AND dtrefere = pr_dtrefere
         AND nrcpfcgc = pr_nrcpfcgc;

      -- Cursor para verificar se o cooperado eh avalista em outras operacoes
      CURSOR cr_crapavl IS
        SELECT 'S'
          FROM crapepr,
               crapavl,
               crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrcpfcgc = pr_nrcpfcgc
           AND crapavl.cdcooper = crapass.cdcooper
           AND crapavl.nrdconta = crapass.nrdconta
           AND crapavl.tpctrato = 1 -- Emprestimos / Financiamentos
           AND crapepr.cdcooper = crapavl.cdcooper
           AND crapepr.nrdconta = crapavl.nrctaavd
           AND crapepr.nrctremp = crapavl.nrctravd
           AND crapepr.inliquid = 0; -- Nao esta liquidado
           
      -- Buscar o valor de operacoes de 61 a 90 dias
      CURSOR cr_crapvri(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT SUM(vldivida)
          FROM crapvri
         WHERE cdcooper = pr_cdcooper
           AND dtrefere = pr_crapdat.dtmvtolt
           AND nrdconta = pr_nrdconta
           AND cdvencto = 130;

      -- Busca o valor das cotas
      CURSOR cr_crapcot IS
        SELECT vldcotas
          FROM crapcot
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapcot cr_crapcot%ROWTYPE;
           
      /* Conta incorporada */    
      CURSOR cr_craptco(pr_cdcooper IN craptco.cdcooper%TYPE,
                        pr_nrdconta IN craptco.nrdconta%TYPE)  IS
         SELECT 1
           FROM craptco 
          WHERE craptco.cdcooper = pr_cdcooper                 
            AND craptco.nrdconta = pr_nrdconta;
      rw_craptco cr_craptco%ROWTYPE;
           
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
      vr_tab_crapdac crapdac%ROWTYPE;  -- Cria tabela com a mesma estrutura que a tabela CRAPDAC
      vr_nrseqvac    crapvac.nrseqvac%TYPE; -- Sequencial com a versao do questionario
      vr_vlmedfat    NUMBER(17,2);     -- Valor medio do faturamento para PJ
      vr_qtcheque    PLS_INTEGER;      -- Quantidade de cheques sem fundos
      vr_qtestour    PLS_INTEGER;      -- Quantidade de estouros na conta
      vr_vlopevnc    crapvop.vlvencto%TYPE; -- Valor total de operacoes vencidas
      vr_vlopeprj    crapvop.vlvencto%TYPE; -- Valor total de operacoes de prejuizo
      vr_nrinfcad    crapttl.nrinfcad%TYPE; -- Indicador de informacoes cadastrais
      vr_incorres    VARCHAR2(01);          -- Indicador se o cooperado eh cooresponsavel de outras operacoes
      vr_vldivida_tit crapvri.vldivida%TYPE;-- Valor da divida de 61 a 90 dias do titular
      vr_vldivida_cje crapvri.vldivida%TYPE;-- Valor da divida de 61 a 90 dias do conjuge
      vr_vldespes    crapvri.vldivida%TYPE; -- Valor total das despesas
      vr_vlrendim    crapvri.vldivida%TYPE; -- Valor total dos rendimentos
      vr_vltotpag    crapvri.vldivida%TYPE; -- Valor total de atraso na cooperativa (emprestimos)
      vr_prcompro    NUMBER(15,2);          -- Percentual de comprometimento da renda
      vr_qtmeschq    PLS_INTEGER;           -- Quantidade de meses para analise de cheques sem fundos
      vr_qtmesest    PLS_INTEGER;           -- Quantidade de meses para analise do estouro da conta
      vr_qtmesatr    PLS_INTEGER;           -- Quantidade de meses para analise do atraso na cooperativa
      vr_dssitdct    tbcc_situacao_conta.dssituacao%TYPE; -- Descricao da situacao de conta

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_tab_erro      GENE0001.typ_tab_erro;
      vr_des_reto      VARCHAR2(500);

    BEGIN
      -- Busca a versao do questionario
      OPEN cr_crapvac;
      FETCH cr_crapvac INTO vr_nrseqvac;
      IF cr_crapvac%NOTFOUND THEN
        CLOSE cr_crapvac;
        vr_dscritic := 'Versao do questionario de analise de credito nao cadastrada!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapvac;
        
      -- Abre os dados do associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Conta '||gene0002.fn_mask_conta(pr_nrdconta)||' nao cadastrada!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;

      -- Se for PF, abre os dados da pessoa fisica
      IF pr_inpessoa = 1 THEN
        OPEN cr_crapttl(pr_nrdconta);
        FETCH cr_crapttl INTO rw_crapttl;
        IF cr_crapttl%NOTFOUND THEN
          CLOSE cr_crapttl;
          vr_dscritic := 'Conta '||gene0002.fn_mask_conta(pr_nrdconta)||' nao possui titular cadastrado!';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapttl;
        
        -- Atualiza o indicador de informacao cadastral
        vr_nrinfcad := rw_crapttl.nrinfcad;
        
        -- Busca a conta do conjuge
        OPEN cr_crapcje;
        FETCH cr_crapcje INTO rw_crapcje;
        CLOSE cr_crapcje;
               
      ELSE -- Se for PJ
        -- Busca os dados do cadastro da PJ
        OPEN cr_crapjur;
        FETCH cr_crapjur INTO rw_crapjur;
        IF cr_crapjur%NOTFOUND THEN
          CLOSE cr_crapjur;
          vr_dscritic := 'Conta PJ '||gene0002.fn_mask_conta(pr_nrdconta)||' nao possui titular cadastrado!';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapjur;
        
        -- Atualiza o indicador de informacao cadastral
        vr_nrinfcad := rw_crapjur.nrinfcad;

        -- Busca o faturamento medio da PJ
        cada0001.pc_calcula_faturamento(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_vlmedfat => vr_vlmedfat
                                       ,pr_tab_erro => vr_tab_erro 
                                       ,pr_des_reto => vr_des_reto);

        
      END IF;

      -- Busca os dados do endereco do cooperado
      OPEN cr_crapenc;
      FETCH cr_crapenc INTO rw_crapenc;
      IF cr_crapenc%NOTFOUND THEN
        CLOSE cr_crapenc;
        vr_dscritic := 'Conta '||gene0002.fn_mask_conta(pr_nrdconta)||' nao possui endereco cadastrado!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapenc;

      -- Busca o valor do aluguel
      OPEN cr_crapenc_2;
      FETCH cr_crapenc_2 INTO rw_crapenc_2;
      CLOSE cr_crapenc_2;

      -- Busca o saldo da conta
      OPEN cr_crapsld;
      FETCH cr_crapsld INTO rw_crapsld;
      CLOSE cr_crapsld;

      -- Busca o periodo de analise em meses de cheques sem fundos
      OPEN cr_crapqac_per(vr_nrseqvac, 10);
      FETCH cr_crapqac_per INTO vr_qtmeschq;
      IF cr_crapqac_per%NOTFOUND THEN
        vr_qtmeschq := 12; -- Considerar padrao 12 meses;
      END IF;
      CLOSE cr_crapqac_per;

      -- Busca o periodo de analise em meses de cheques sem fundos
      OPEN cr_crapqac_per(vr_nrseqvac, 11);
      FETCH cr_crapqac_per INTO vr_qtmesest;
      IF cr_crapqac_per%NOTFOUND THEN
        vr_qtmesest := 6; -- Considerar padrao 6 meses;
      END IF;
      CLOSE cr_crapqac_per;

      -- Busca o periodo de analise em meses de atraso na cooperativa
      OPEN cr_crapqac_per(vr_nrseqvac, 12);
      FETCH cr_crapqac_per INTO vr_qtmesatr;
      IF cr_crapqac_per%NOTFOUND THEN
        vr_qtmesest := 6; -- Considerar padrao 6 meses;
      END IF;
      CLOSE cr_crapqac_per;

      -- Busca a quantidade de cheques sem fundos
      OPEN cr_crapneg(vr_qtmeschq);
      FETCH cr_crapneg INTO vr_qtcheque;
      CLOSE cr_crapneg;

      -- Busca a quantidade de estouros
      OPEN cr_crapneg_2(vr_qtmesest);
      FETCH cr_crapneg_2 INTO vr_qtestour;
      CLOSE cr_crapneg_2;

      -- Busca os dados do SCR
      OPEN cr_crapopf;
      FETCH cr_crapopf INTO rw_crapopf;
      IF cr_crapopf%NOTFOUND THEN
        rw_crapopf.dtrefere := last_day(pr_crapdat.dtmvtolt);
        rw_crapopf.qtifssfn := 0;
      END IF;
      CLOSE cr_crapopf;
      
      -- Busca o total de operacoes vencidas
      OPEN cr_crapvop(rw_crapass.nrcpfcgc, rw_crapopf.dtrefere, 205, 290);
      FETCH cr_crapvop INTO vr_vlopevnc;
      CLOSE cr_crapvop;

      -- Busca o total de operacoes em prejuizo
      OPEN cr_crapvop(rw_crapass.nrcpfcgc, rw_crapopf.dtrefere, 310, 330);
      FETCH cr_crapvop INTO vr_vlopeprj;
      CLOSE cr_crapvop;

      -- Busca a divida de 61 a 90 dias do titular da conta
      OPEN cr_crapvop(rw_crapass.nrcpfcgc, rw_crapopf.dtrefere, 130, 130);
      FETCH cr_crapvop INTO vr_vldivida_tit;
      CLOSE cr_crapvop;

      -- Se for pessoa fisica
      IF pr_inpessoa = 1 THEN
        -- Se possuir conjuge, busca o valor da divida do mesmo
        IF nvl(rw_crapcje.nrcpfcgc,0) <> 0 THEN
          OPEN cr_crapvop(rw_crapcje.nrcpfcgc, rw_crapopf.dtrefere,130,130);
          FETCH cr_crapvop INTO vr_vldivida_cje;
          CLOSE cr_crapvop;
        END IF;
      END IF;


      -- Busca o valor total de cotas
      OPEN cr_crapcot;
      FETCH cr_crapcot INTO rw_crapcot;
      CLOSE cr_crapcot;

      -- Verifica se o cooperado eh avalista em outras operacoes
      OPEN cr_crapavl;
      FETCH cr_crapavl INTO vr_incorres;
      IF cr_crapavl%NOTFOUND THEN
        vr_incorres := 'N';
      END IF;
      CLOSE cr_crapavl;

      -- Calcula o valor total dos rendimentos
      vr_vlrendim := nvl(rw_crapttl.vlsalari,0) + nvl(rw_crapttl.vlrendim,0) +
                     nvl(rw_crapcje.vlsalari,0) + 
                     nvl(vr_vlmedfat,0); -- Para os casos de PJ

      -- Busca o saldo devedor
      pc_busca_saldo_devedor(pr_cdcooper => pr_cdcooper,  --> Codigo da cooperativa
                             pr_nrdconta => pr_nrdconta,  --> Codigo da conta
                             pr_qtmesclc => vr_qtmesatr,
                             pr_crapdat  => pr_crapdat,   --> Registro de data
                             pr_vltotpag => vr_vltotpag,  --> Valor de parcelas em atraso a pagar
                             pr_cdcritic => vr_cdcritic,  --> Código da crítica
                             pr_dscritic => pr_cdcritic); --> Descrição da crít
      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Efetua o loop sobre os indicadores
      FOR rw_crapiac IN cr_crapiac LOOP
        -- Inicializa as variaveis
        vr_tab_crapdac := NULL;

        -- Verifica se o indicador deve ser processado de acordo com o tipo de pessoa
        IF (pr_intippes = 1 AND pr_inpessoa = 1 AND rw_crapiac.inpesfis = 'N') OR -- Titular e PF
           (pr_intippes = 1 AND pr_inpessoa = 2 AND rw_crapiac.inpesjur = 'N') OR -- Titular e PJ
           (pr_intippes = 2 AND rw_crapiac.inconjug = 'N') OR -- Conjuge
           (pr_intippes IN (3,4) AND pr_inpessoa = 1 AND rw_crapiac.insocpfi = 'N') OR -- Socio/Grupo Economico e PF
           (pr_intippes IN (3,4) AND pr_inpessoa = 2 AND rw_crapiac.insocpfi = 'N') OR -- Socio/Grupo Economico e PJ
           (pr_intippes = 5 AND pr_inpessoa = 1 AND rw_crapiac.inpesfis = 'N') OR -- Avalista e PF
           (pr_intippes = 5 AND pr_inpessoa = 2 AND rw_crapiac.inpesjur = 'N') THEN -- Avalista e PJ
           
          CONTINUE; -- Vai para o proximo indicador
        END IF;

        -- Verifica se o indicador esta inativo
        IF fn_verifica_situacao_idc(vr_nrseqvac, rw_crapiac.nrseqiac) = 2 THEN
          CONTINUE; -- Vai para o proximo indicador
        END IF;
        
        -- Se nao possuir quantidade de reciprocidade informado, nao calcula o
        -- indicador. Solicitado por Suzana em reuniao dia 13/02/2015
        IF rw_crapiac.nrseqiac = 8 AND pr_qtrecpro = 0 THEN
          continue;
        END IF;

        -- Efetua o loop sobre o questionario
        FOR rw_crapqac IN cr_crapqac(vr_nrseqvac, rw_crapiac.nrseqiac) LOOP

          -- Atualiza as variaveis de retorno
          vr_tab_crapdac.nrseqqac := rw_crapqac.nrseqqac;
          vr_tab_crapdac.instatus := rw_crapqac.instatus;
          vr_tab_crapdac.inmensag := rw_crapqac.inmensag;

          -- Se for a ordem 0, entao ja passou por todas as restricoes
          IF rw_crapqac.nrordper = 0 THEN
            -- Sai do indicador
            EXIT;
          END IF;
          
          -- Se for indicador de DATA DE NASCIMENTO
          IF rw_crapiac.nrseqiac = 1 THEN
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := to_char(rw_crapttl.dtnasttl,'DD/MM/YYYY');

            -- Efetua o calculo com base na idade
            IF trunc((to_char(pr_crapdat.dtmvtolt,'YYYYMMDD')-to_char(rw_crapttl.dtnasttl,'YYYYMMDD'))/10000) <= to_number(rw_crapqac.vlparam1) AND
               rw_crapqac.nrordper = 1 THEN -- A ordem 1 tem que ser menor
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            ELSIF trunc((to_char(pr_crapdat.dtmvtolt,'YYYYMMDD')-to_char(rw_crapttl.dtnasttl,'YYYYMMDD'))/10000) >= to_number(rw_crapqac.vlparam1) AND
               rw_crapqac.nrordper = 2 THEN -- A ordem 2 tem que ser maior
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de DATA DE FUNDACAO
          ELSIF rw_crapiac.nrseqiac = 2 THEN
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := to_char(rw_crapjur.dtiniatv,'DD/MM/YYYY');

            IF trunc(MONTHS_BETWEEN(pr_crapdat.dtmvtolt,rw_crapjur.dtiniatv)) <= to_number(rw_crapqac.vlparam1) THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de COMPROMETIMENTO DE RENDA
          ELSIF rw_crapiac.nrseqiac = 3 THEN
            -- Calcula o valor total da despesa
            vr_vldespes := nvl(rw_crapenc_2.vlalugue,0) + pr_vlpreemp + 
                           nvl(vr_vldivida_tit,0) + nvl(vr_vldivida_cje,0);

            -- Calcula o percentual de comprometimento
            IF vr_vlrendim = 0 THEN
              vr_prcompro := 100; -- Se nao tiver renda, sera 100% de comprometimento
            ELSE
              vr_prcompro := round(vr_vldespes / vr_vlrendim * 100,2);
            END IF;
            
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := to_char(vr_prcompro,'FM999G999G990D00');

            -- Se possuir aluguel deve-se incluir mensagem de aluguel
            IF nvl(rw_crapenc_2.vlalugue,0) > 0 THEN
              vr_tab_crapdac.vlparam2 := '(considerando o aluguel) ';
            END IF;

            -- Verifica se o comprometimento eh maior que o parametro
            IF vr_prcompro >= to_number(rw_crapqac.vlparam1) THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de TIPO DE RESIDENCIA
          ELSIF rw_crapiac.nrseqiac = 4 THEN
            -- Atualiza o conteudo dos parametros 1 e 2
            vr_tab_crapdac.vlparam1 := rw_crapenc.dscasprp;
            vr_tab_crapdac.vlparam2 := to_char(rw_crapenc.dtinires,'DD/MM/YYYY');
            
            -- Verifica se o tipo de residencia eh igual ao parametrizado
            IF rw_crapenc.incasprp = rw_crapqac.vlparam1 THEN
              -- Se nao tiver parametro 2 ou se quantidade de meses for inferior ao parametro 2
              IF rw_crapqac.vlparam2 IS NULL OR
                 trunc(months_between(pr_crapdat.dtmvtolt,rw_crapenc.dtinires)) <= to_number(rw_crapqac.vlparam2) THEN
                -- Encontrou uma condicao que satisfaz, entao sai do indicador
                EXIT;
              ELSIF rw_crapqac.vlparam2 IS NULL THEN -- Se for nulo eh o registro do SENAO da data
                -- Encontrou uma condicao que satisfaz, entao sai do indicador
                EXIT;
              END IF;
            END IF;

          -- Se for indicador de DATA DE ADMISSAO NO EMPREGO ATUAL
          ELSIF rw_crapiac.nrseqiac = 5 THEN
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := to_char(rw_crapttl.dtadmemp,'dd/mm/yyyy');

            -- Se tem data de admissao e a quantidade de meses for inferior ao parametrizado
            IF rw_crapttl.dtadmemp IS NOT NULL AND
              trunc(months_between(pr_crapdat.dtmvtolt,rw_crapttl.dtadmemp)) <= to_number(rw_crapqac.vlparam1) THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de DATA DE ABERTURA DA CONTA
          ELSIF rw_crapiac.nrseqiac = 6 THEN
            
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := to_char(rw_crapass.dtadmiss,'dd/mm/yyyy');

            /* Procura se é uma conta incorporada */  
            OPEN cr_craptco(pr_cdcooper, 
                            pr_nrdconta);
            FETCH cr_craptco 
             INTO rw_craptco;

            /* Só considera se não for conta incorporada */
            IF cr_craptco%NOTFOUND THEN
              CLOSE cr_craptco;
            -- Se a quantidade de meses de abertura da conta for inferior ao parametrizado
            IF trunc(months_between(pr_crapdat.dtmvtolt,rw_crapass.dtadmiss)) <= to_number(rw_crapqac.vlparam1) THEN  
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;
            ELSE
              CLOSE cr_craptco;
            END IF;

          -- Se for indicador de SITUACAO DA CONTA
          ELSIF rw_crapiac.nrseqiac = 7 THEN
            -- Atualiza o conteudo do parametro 1
            
            CADA0006.pc_descricao_situacao_conta(pr_cdsituacao => rw_crapass.cdsitdct
                                                ,pr_dssituacao => vr_dssitdct
                                                ,pr_des_erro   => vr_des_reto
                                                ,pr_dscritic   => vr_dscritic);
            
            IF vr_des_reto <> 'NOK' THEN
              RAISE vr_exc_saida;
            END IF;
            
            vr_tab_crapdac.vlparam1 := rw_crapass.cdsitdct||'-'||vr_dssitdct;

            -- Verifica se o tipo esta dentre os escolhidos
            IF instr(';'||rw_crapqac.vlparam1||';',';'||rw_crapass.cdsitdct||';') <> 0 THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de RECIPROCIDADE DE CAPITAL
          ELSIF rw_crapiac.nrseqiac = 8 THEN
            
            -- Atualiza o conteudo dos parametros 1, 2 e 3
            vr_tab_crapdac.vlparam1 := to_char(pr_qtrecpro,'FM999G999G990D00');
            vr_tab_crapdac.vlparam2 := to_char(rw_crapcot.vldcotas,'FM999G999G990D00');
            vr_tab_crapdac.vlparam3 := to_char(pr_qtrecpro*rw_crapcot.vldcotas,'FM999G999G990D00');

            -- Verifica se o valor financiado for maior que a reciprocidade
            IF pr_vlemprst > rw_crapcot.vldcotas * pr_qtrecpro THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de SALDO MEDIO DO SEMESTRE
          ELSIF rw_crapiac.nrseqiac = 9 THEN
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := to_char(rw_crapsld.vlsmstre,'FM999G999G990D00');
            
            -- Verifica se o saldo medio eh menor do que o do parametro
            IF rw_crapsld.vlsmstre <= nvl(to_number(replace(rw_crapqac.vlparam1,'.',',')),0) THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;
            
          -- Se for indicador de CHEQUES SEM FUNDOS
          ELSIF rw_crapiac.nrseqiac = 10 THEN
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := vr_qtcheque;
            
            -- Verifica se a quantidade de cheques é maior do que o parametrizado
            IF vr_qtcheque >= nvl(to_number(rw_crapqac.vlparam1),0) THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de QUANTIDADE DE ESTOUROS
          ELSIF rw_crapiac.nrseqiac = 11 THEN
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := vr_qtestour;
            
            -- Verifica se a quantidade de estouros é maior do que o parametrizado
            IF vr_qtestour >= to_number(rw_crapqac.vlparam1) THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de ATRASO NA COOPERATIVA
          ELSIF rw_crapiac.nrseqiac = 12 THEN
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := to_char(vr_vltotpag,'fm999G999G990D00');
            
            -- Verifica se existe atraso na cooperativa superior ao parametro
            IF vr_vltotpag > to_number(replace(rw_crapqac.vlparam1,'.',',')) THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de QUANTIDADE DE INSTITUICOES
          ELSIF rw_crapiac.nrseqiac = 13 THEN
            -- Atualiza o conteudo dos parametros 1 e 2
            -- Quantidade de instituicoes
            vr_tab_crapdac.vlparam1 := rw_crapopf.qtifssfn;
            -- Valor da renda
            vr_tab_crapdac.vlparam2 := vr_vlrendim;
            
            -- Verifica se a renda eh menor que o parametro
            IF to_number(vr_tab_crapdac.vlparam2) <= to_number(replace(rw_crapqac.vlparam1,'.',',')) AND 
               to_number(vr_tab_crapdac.vlparam1) >  to_number(rw_crapqac.vlparam2) AND -- E a quantidade de instituicoes financeiras maior que o parametro
               rw_crapqac.nrordper IN (1,2) THEN -- Somente a ordem 1 e 2 eh este calculo
              -- Coloca a mascara correta
              vr_tab_crapdac.vlparam2 :=  to_char(vr_tab_crapdac.vlparam2,'fm999G999G990D00');
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            ELSIF to_number(vr_tab_crapdac.vlparam2) > to_number(rw_crapqac.vlparam1) AND 
               to_number(vr_tab_crapdac.vlparam1) >  to_number(rw_crapqac.vlparam2) AND -- E a quantidade de instituicoes financeiras maior que o parametro
               rw_crapqac.nrordper = 3 THEN -- Somente a ordem 3 eh este calculo
              -- Coloca a mascara correta
              vr_tab_crapdac.vlparam2 :=  to_char(vr_tab_crapdac.vlparam2,'fm999G999G990D00');
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

            -- Coloca a mascara correta
            vr_tab_crapdac.vlparam2 :=  to_char(vr_tab_crapdac.vlparam2,'fm999G999G990D00');

          -- Se for indicador de OPERACOES VENCIDAS
          ELSIF rw_crapiac.nrseqiac = 14 THEN
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := vr_vlopevnc;
            
            -- Verifica se o valor de operacoes vencidas eh maior do que o parametro
            IF vr_vlopevnc >= nvl(to_number(replace(rw_crapqac.vlparam1,'.',',')),0) THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de OPERACOES EM PREJUIZO
          ELSIF rw_crapiac.nrseqiac = 15 THEN
            -- Atualiza o conteudo do parametro 1
            vr_tab_crapdac.vlparam1 := vr_vlopeprj;
            
            -- Verifica se o valor de prejuizo eh maior que o parametrizado
            IF vr_vlopeprj >= nvl(to_number(replace(rw_crapqac.vlparam1,'.',',')),0) THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de RESTRICOES SPC/SERASA
          ELSIF rw_crapiac.nrseqiac = 16 THEN
            
            -- Verifica se o indicador eh de restricoe relevantes e sequencia
            -- das perguntas refere-se ao indicador de restricoes relevantes
            IF vr_nrinfcad = 4 AND rw_crapqac.nrordper = 1 OR
              -- Verifica se o indicador eh de restricoes justificadas e aceitas e sequencia
              -- das perguntas refere-se a este indicador
               vr_nrinfcad = 2 AND rw_crapqac.nrordper = 2 OR
              -- Verifica se o indicador eh de restricoes ate R$ 1.000,00 e sequencia
              -- das perguntas refere-se a este indicador
               vr_nrinfcad = 3 AND rw_crapqac.nrordper = 3 THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          -- Se for indicador de CORRESPONSAVEL
          ELSIF rw_crapiac.nrseqiac = 17 THEN
          
            -- Verifica se o Indicador de corresponsavel eh SIM
            IF vr_incorres = 'S' THEN
              -- Encontrou uma condicao que satisfaz, entao sai do indicador
              EXIT;
            END IF;

          END IF;
        END LOOP; -- Fim do loop sobre as perguntas do indicador (CRAPQAC)
        
        -- Se existir analise sobre o indicador, insere o detalhe da analise
        IF vr_tab_crapdac.instatus IS NOT NULL THEN
          BEGIN
            INSERT INTO crapdac
              (nrseqdac
              ,nrseqqac
              ,nrseqpac
              ,nrdconta
              ,nrcpfcgc
              ,intippes
              ,inpessoa
              ,vlparam1
              ,vlparam2
              ,vlparam3
              ,instatus
              ,inmensag)
            VALUES
              (fn_sequence(pr_nmtabela => 'CRAPDAC', pr_nmdcampo => 'NRSEQDAC',pr_dsdchave => '0')
              ,vr_tab_crapdac.nrseqqac
              ,pr_nrseqpac
              ,pr_nrdconta
              ,pr_nrcpfcgc
              ,pr_intippes
              ,pr_inpessoa
              ,vr_tab_crapdac.vlparam1
              ,vr_tab_crapdac.vlparam2
              ,vr_tab_crapdac.vlparam3
              ,vr_tab_crapdac.instatus
              ,vr_tab_crapdac.inmensag);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CRAPDAC: '||SQLERRM;
              RAISE vr_exc_saida;
          END;

        END IF;

      END LOOP; -- Fim do loop sobre os indicadores (CRAPIAC)
    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em analise_individual: ' || SQLERRM;

    END;

  -- Recebe a mensagem cadastrada e transforma em mensagem correta
  FUNCTION fn_ajuste_mensagem(pr_dsmensag crapqac.dsmensag%TYPE --> Mensagem 
                             ,pr_nmparam1 crapiac.nmparam1%TYPE --> Nome do parametro 1
                             ,pr_nmparam2 crapiac.nmparam1%TYPE --> Nome do parametro 2
                             ,pr_nmparam3 crapiac.nmparam1%TYPE --> Nome do parametro 3
                             ,pr_vlparam1 crapdac.vlparam1%TYPE --> Conteudo do parametro 1
                             ,pr_vlparam2 crapdac.vlparam1%TYPE --> Conteudo do parametro 2
                             ,pr_vlparam3 crapdac.vlparam1%TYPE)--> Conteudo do parametro 3
                             RETURN VARCHAR2 IS
      vr_dsmensag_ret VARCHAR2(500);                                                          
    BEGIN
      -- Subsstitui os parametros
      vr_dsmensag_ret := REPLACE(pr_dsmensag,'#'||pr_nmparam1,pr_vlparam1);
      vr_dsmensag_ret := REPLACE(vr_dsmensag_ret,'#'||pr_nmparam2,pr_vlparam2);
      vr_dsmensag_ret := REPLACE(vr_dsmensag_ret,'#'||pr_nmparam3,pr_vlparam3);
      
      -- Retorna a mensagem
      RETURN vr_dsmensag_ret;
      
    END;                             

  -- Efetua a analise de credito de um contrato
  PROCEDURE pc_efetua_analise_ctr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Codigo da cooperativa
                                 ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica
       
      -- Cursor para buscar os dados do emprestimo
      CURSOR cr_crawepr IS
        SELECT crawepr.nrseqpac,
               crawepr.cdlcremp,
               crawepr.cdfinemp,
               crawepr.vlpreemp,
               crawepr.vlemprst,
               craplcr.qtrecpro,
               crawepr.nrctaav1,
               crawepr.nrctaav2
          FROM craplcr,
               crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp
           AND craplcr.cdcooper = crawepr.cdcooper
           AND craplcr.cdlcremp = crawepr.cdlcremp;
      rw_crawepr cr_crawepr%ROWTYPE;
      
      -- Cursor para buscar as demais contas do titular
      CURSOR cr_crapass_2 IS
        SELECT crapass_2.nrdconta,
               crapass_2.nrcpfcgc,
               crapass_2.inpessoa
          FROM crapass crapass_2,
               crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
           AND crapass_2.cdcooper = pr_cdcooper
           AND crapass_2.nrcpfcgc = crapass.nrcpfcgc
           AND crapass_2.nrdconta <> crapass.nrdconta
           AND crapass_2.dtelimin IS NULL -- O mesmo tem que estar ativo
           AND crapass_2.cdtipcta NOT IN (SELECT tpcta.cdtipo_conta -- Desconsiderar contas de aplicacao
                                            FROM tbcc_tipo_conta tpcta
                                           WHERE tpcta.cdmodalidade_tipo = 3
                                             AND tpcta.inpessoa = crapass.inpessoa);
           

      -- Cursor para busca dos dados da conta do titular
      CURSOR cr_crapass(pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT inpessoa,
               nrcpfcgc
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor para busca dos dados do conjuge
      CURSOR cr_crapcje IS
        SELECT nrdconta,
               nrcpfcgc 
          FROM (SELECT crapass.nrdconta,
                       crapass.nrcpfcgc,
                       crapass.dtultalt
                  FROM crapass,
                       crapcje
                 WHERE crapcje.cdcooper = pr_cdcooper
                   AND crapcje.nrdconta = pr_nrdconta
                   AND crapcje.idseqttl = 1 -- Titular
                   AND crapcje.nrctacje <> 0
                   AND crapass.cdcooper = crapcje.cdcooper
                   AND crapass.nrdconta = crapcje.nrctacje
                   AND crapass.dtelimin IS NULL -- O mesmo tem que estar ativo
                 UNION ALL
                SELECT crapass.nrdconta,
                       crapass.nrcpfcgc,
                       crapass.dtultalt
                  FROM crapass,
                       crapcje
                 WHERE crapcje.cdcooper = pr_cdcooper
                   AND crapcje.nrdconta = pr_nrdconta
                   AND crapcje.idseqttl = 1 -- Titular
                   AND crapcje.nrcpfcjg <> 0
                   AND crapass.cdcooper = crapcje.cdcooper
                   AND crapass.nrcpfcgc = crapcje.nrcpfcjg
                   AND crapass.dtelimin IS NULL )-- O mesmo tem que estar ativo
          ORDER BY dtultalt DESC; -- Ordenar pela ultima atualizacao cadastral
      rw_crapcje cr_crapcje%ROWTYPE;
      
      -- Cursor para busca das contas do grupo economico
      CURSOR cr_crapgrp (pr_nrdgrupo INTEGER)IS
        SELECT int.tppessoa inpessoa
              ,int.nrdconta
              ,int.Nrcpfcgc
          FROM tbcc_grupo_economico_integ INT
              ,tbcc_grupo_economico p
         WHERE int.dtexclusao IS NULL
           AND int.cdcooper = pr_cdcooper
           AND int.idgrupo  = p.idgrupo
           AND int.tppessoa = 1  -- Somente PF
           AND int.idgrupo  = pr_nrdgrupo
           AND int.nrdconta <> pr_nrdconta -- Desconsiderar a propria conta, pois ela ja foi analisada   
         UNION
        SELECT ass.inpessoa
              ,pai.nrdconta
              ,ass.nrcpfcgc
          FROM tbcc_grupo_economico       pai
             , crapass                    ass
             , tbcc_grupo_economico_integ int
         WHERE ass.cdcooper = pai.cdcooper
           AND ass.nrdconta = pai.nrdconta
           AND int.idgrupo  = pai.idgrupo
           AND int.dtexclusao is NULL
           AND ass.dtelimin IS NULL -- Somente ativos
           AND ass.inpessoa = 1  -- Somente PF
           AND ass.cdcooper = pr_cdcooper
           AND int.cdcooper = pr_cdcooper
           AND pai.idgrupo  = pr_nrdgrupo
           AND pai.nrdconta <> pr_nrdconta -- Desconsiderar a propria conta, pois ela ja foi analisada   
;
      -- Cursor para busca das contas do grupo economico
      CURSOR cr_crapavt(pr_ingrpeco VARCHAR2)IS
        SELECT crapass.nrdconta,
               crapass.inpessoa,
               crapass.nrcpfcgc
          FROM crapass,
               crapavt
         WHERE crapavt.cdcooper = pr_cdcooper
           AND crapavt.nrdconta = pr_nrdconta
           AND crapavt.tpctrato = 6 -- Socio
           AND crapass.cdcooper = crapavt.cdcooper
           AND crapass.nrcpfcgc = crapavt.nrcpfcgc
           AND crapass.dtelimin IS NULL -- Somente ativos
           AND crapass.inpessoa = 1 -- Somente PF
           AND ((pr_ingrpeco     = 'S'
           AND   crapavt.persocio> 50) -- Se tiver grupo economico buscar somente os socios com mais de 50%
           OR   pr_ingrpeco     = 'N')
         ORDER BY crapavt.persocio DESC, crapass.nrcpfcgc, crapass.dtultalt DESC;

      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Define o tipo de registro para consulta
      TYPE typ_reg_consulta IS
        RECORD (nrdconta crapass.nrdconta%TYPE,
                nrcpfcgc crapass.nrcpfcgc%TYPE,
                inpessoa crapass.inpessoa%TYPE,
                intippes crapdac.intippes%TYPE);
      -- Definicao do tipo de tabela que armazena
      -- registros do tipo acima detalhado
      TYPE typ_tab_consulta IS
        TABLE OF typ_reg_consulta
        INDEX BY PLS_INTEGER;
      -- Vetores para armazenar as informacoes de contas a serem consultadas
      vr_tab_consulta typ_tab_consulta;

      -- Define o tipo de registro para as contas
      TYPE typ_reg_contas IS
        RECORD (nrdconta crapass.nrdconta%TYPE);
      -- Definicao do tipo de tabela que armazena
      -- registros do tipo acima detalhado
      TYPE typ_tab_contas IS
        TABLE OF typ_reg_contas
        INDEX BY VARCHAR2(10);
      -- Vetores para armazenar as informacoes de contas a serem consultadas
      vr_tab_contas typ_tab_contas;


      -- Cursor para verificar o status geral da proposta
      CURSOR cr_crappac(pr_nrseqpac crapdac.nrseqpac%TYPE) IS
        SELECT MAX(decode(crapdac.nrdconta,pr_nrdconta,crapdac.instatus,1)) instatus_tit,
               MAX(decode(crapdac.nrdconta,pr_nrdconta,1,crapdac.instatus)) instatus_out
          FROM crapdac
         WHERE nrseqpac = pr_nrseqpac;
      rw_crappac cr_crappac%ROWTYPE;

      -- Variaveis gerais
      vr_ind           PLS_INTEGER;           --> Indice sobre a tabela de contas a serem consultadas
      vr_nrcpfcgc_ant  crapass.nrcpfcgc%TYPE; --> Numero do CPF anterior do processo
      vr_instatus      crappac.instatus%TYPE; --> Status do parecer de credito
      vr_dslinhas      VARCHAR2(2000);        --> Linhas que nao possuirao analise de credito
      vr_ingrpeco      VARCHAR2(01):='N';     --> Indicador de existencia de grupo economico
      vr_qtsocios      PLS_INTEGER := 0;      --> Quantidade de socios
      -- Variaveis de critica
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      
      -- Obrigatoriedade analise automatica da Esteira
      vr_inobriga VARCHAR2(1) := 'N';
      
      vr_nrdgrupo      tbcc_grupo_economico.idgrupo%TYPE;
      vr_inrisco_grp   tbcc_grupo_economico.inrisco_grupo%TYPE;
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN

      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'ATENDA'
                                ,pr_action => 'RATI0002.pc_efetua_analise_ctr'
                                );

      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Busca os dados do emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        vr_dscritic := 'Emprestimo nao localizado!';
        CLOSE cr_crawepr;
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crawepr;

      -- Busca as linhas de credito que nao devem possuir analise
      vr_dslinhas := ';'||
                     gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper =>  pr_cdcooper,
                                               pr_cdacesso => 'EXC_ANALISE_CREDITO')||
                     ';';

      -- Abre os dados do associado
      OPEN cr_crapass(pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Associado nao cadastrado. Favor verificar!';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crapass;
      
      -- BUscar identificador de obrigação de análise automática
      este0001.pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
                                             ,pr_inpessoa => rw_crapass.inpessoa
                                             ,pr_cdfinemp => rw_crawepr.cdfinemp
                                             ,pr_cdlcremp => rw_crawepr.cdlcremp
                                             ,pr_inobriga => vr_inobriga
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
      -- Tratar erros
      IF vr_dscritic IS NOT NULL OR vr_cdcritic > 0 THEN 
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se a linha de credito atual esta parametrizada para nao possuir analise
      IF instr(vr_dslinhas,';'||rw_crawepr.cdlcremp||';') > 0 OR vr_inobriga = 'S' THEN
	    BEGIN
          UPDATE crawepr
             SET nrseqpac = 0
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := '1-Erro ao atualizar CRAWEPR: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Encerra o processo sem erro, pois eh previsto isso
        RETURN;
      END IF;

      -- Verifica se o questionario esta desabilitado
      IF nvl(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                       pr_cdcooper =>  pr_cdcooper,
                                       pr_cdacesso => 'PRC_ANALISE_CREDITO'),'N') = 'S' THEN
        -- Encerra o processo sem erro, pois eh previsto isso
        RETURN;
      END IF;

      -- Atualiza o indice da tabela
      vr_ind := 1;
      
      -- Insere o titular para ser consultado
      vr_tab_consulta(vr_ind).nrdconta := pr_nrdconta;
      vr_tab_consulta(vr_ind).nrcpfcgc := rw_crapass.nrcpfcgc;
      vr_tab_consulta(vr_ind).inpessoa := rw_crapass.inpessoa;
      vr_tab_consulta(vr_ind).intippes := 1; -- Titular do emprestimo
      vr_tab_contas(pr_nrdconta).nrdconta := pr_nrdconta;
      
      -- Busca as outras contas que o titular possui
      FOR rw_crapass_2 IN cr_crapass_2 LOOP
        -- Insere as demais contas do cooperado titular
        vr_ind := vr_ind + 1;
        vr_tab_consulta(vr_ind).nrdconta := rw_crapass_2.nrdconta;
        vr_tab_consulta(vr_ind).nrcpfcgc := rw_crapass_2.nrcpfcgc;
        vr_tab_consulta(vr_ind).inpessoa := rw_crapass_2.inpessoa; -- PF
        vr_tab_consulta(vr_ind).intippes := 1; -- Titular do emprestimo
        vr_tab_contas(rw_crapass_2.nrdconta).nrdconta := rw_crapass_2.nrdconta;
      END LOOP;      

      -- Se for pessoa fisica, verifica se deve consultar o conjuge
      IF rw_crapass.inpessoa = 1 THEN
        -- Abre o cursor de conjuge
        OPEN cr_crapcje;
        FETCH cr_crapcje INTO rw_crapcje;
        IF cr_crapcje%FOUND THEN
          -- Insere o conjuge para ser consultado
          vr_ind := vr_ind + 1;
          vr_tab_consulta(vr_ind).nrdconta := rw_crapcje.nrdconta;
          vr_tab_consulta(vr_ind).nrcpfcgc := rw_crapcje.nrcpfcgc;
          vr_tab_consulta(vr_ind).inpessoa := 1; -- PF
          vr_tab_consulta(vr_ind).intippes := 2; -- Conjuge
          vr_tab_contas(rw_crapcje.nrdconta).nrdconta := rw_crapcje.nrdconta;
        END IF;
        CLOSE cr_crapcje;
      ELSE
        -- Identificar o grupo da conta
        risc0004.pc_busca_grupo_economico(pr_cdcooper => pr_cdcooper
                                        , pr_nrdconta => pr_nrdconta
                                        , pr_nrcpfcgc => NULL
                                        , pr_numero_grupo => vr_nrdgrupo
                                        , pr_risco_grupo  => vr_inrisco_grp);
      
        vr_nrdgrupo := nvl(vr_nrdgrupo,0);

        IF vr_nrdgrupo > 0 THEN -- Tem Grupo Economico
          -- Busca os cooperados que fazem parte do GRUPO ECONOMICO
          FOR rw_crapgrp IN cr_crapgrp(vr_nrdgrupo) LOOP
            -- Insere o integrante do grupo economico para ser consultado
            vr_ind := vr_ind + 1;
            vr_tab_consulta(vr_ind).nrdconta := rw_crapgrp.nrdconta;
            vr_tab_consulta(vr_ind).nrcpfcgc := rw_crapgrp.nrcpfcgc;
            vr_tab_consulta(vr_ind).inpessoa := rw_crapgrp.inpessoa;
            vr_tab_consulta(vr_ind).intippes := 4; -- Grupo economico
            vr_tab_contas(rw_crapgrp.nrdconta).nrdconta := rw_crapgrp.nrdconta;
            -- Informa que tem grupo economico
            vr_ingrpeco := 'S';
          END LOOP;      
        END IF;
      END IF;

      -- Busca os cooperados que sao os socios da empresa
      FOR rw_crapavt IN cr_crapavt(vr_ingrpeco) LOOP
        -- Verifica se o CPF da conta anterior eh diferente do atual
        -- Isso se faz necessario porque o mesmo CPF pode possuir varias contas
        -- e na ordenacao ele ja busca a conta com a situacao cadastral mais recente
        IF nvl(vr_nrcpfcgc_ant,0) <> rw_crapavt.nrcpfcgc AND
           NOT vr_tab_contas.exists(rw_crapavt.nrdconta) THEN -- E a conta ainda nao tiver sido cadastrada como grupo economico
          -- Insere o integrante do grupo economico para ser consultado
          vr_ind := vr_ind + 1;
          vr_tab_consulta(vr_ind).nrdconta := rw_crapavt.nrdconta;
          vr_tab_consulta(vr_ind).nrcpfcgc := rw_crapavt.nrcpfcgc;
          vr_tab_consulta(vr_ind).inpessoa := 1; -- PF
          vr_tab_consulta(vr_ind).intippes := 3; -- Socio da empresa
          vr_tab_contas(rw_crapavt.nrdconta).nrdconta := rw_crapavt.nrdconta;
          -- Incrementa a quantidade de socios
          vr_qtsocios := vr_qtsocios + 1;
          
          -- Se chegar a dois socios, deve-se encerrar o loop
          IF vr_qtsocios >= 2 THEN
            EXIT;
          END IF;
        END IF;
          
        -- Atualiza o numero do CPF
        vr_nrcpfcgc_ant := rw_crapavt.nrcpfcgc;
          
      END LOOP;      

      -- Se possuir avalista 1, deve-se enviar o mesmo   
      IF nvl(rw_crawepr.nrctaav1,0) <> 0 THEN
        OPEN cr_crapass(rw_crawepr.nrctaav1);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%FOUND THEN
          -- Insere o avalista para ser consultado
          vr_ind := vr_ind + 1;
          vr_tab_consulta(vr_ind).nrdconta := rw_crawepr.nrctaav1;
          vr_tab_consulta(vr_ind).nrcpfcgc := rw_crapass.nrcpfcgc;
          vr_tab_consulta(vr_ind).inpessoa := rw_crapass.inpessoa;
          vr_tab_consulta(vr_ind).intippes := 5; -- Avalista
          vr_tab_contas(rw_crawepr.nrctaav1).nrdconta := rw_crawepr.nrctaav1;
        END IF;
        CLOSE cr_crapass;
      END IF;

      -- Se possuir avalista 2, deve-se enviar o mesmo   
      IF nvl(rw_crawepr.nrctaav2,0) <> 0 THEN
        OPEN cr_crapass(rw_crawepr.nrctaav2);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%FOUND THEN
          -- Insere o avalista para ser consultado
          vr_ind := vr_ind + 1;
          vr_tab_consulta(vr_ind).nrdconta := rw_crawepr.nrctaav2;
          vr_tab_consulta(vr_ind).nrcpfcgc := rw_crapass.nrcpfcgc;
          vr_tab_consulta(vr_ind).inpessoa := rw_crapass.inpessoa;
          vr_tab_consulta(vr_ind).intippes := 5; -- Avalista
          vr_tab_contas(rw_crawepr.nrctaav2).nrdconta := rw_crawepr.nrctaav2;
        END IF;
        CLOSE cr_crapass;
      END IF;

      -- Se o sequencial do parecer eh diferente de zero, deve-se excluir o questionario antigo
      IF rw_crawepr.nrseqpac <> 0 THEN
        -- Exclui a tabela de detalhes, pois o questionario ja existe
        BEGIN
          DELETE crapdac
           WHERE nrseqpac = rw_crawepr.nrseqpac;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir CRAPDAC: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Exclui a capa da tabela do questionario
        BEGIN
          DELETE crappac
           WHERE nrseqpac = rw_crawepr.nrseqpac;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir CRAPPAC: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
      END IF;

      -- Busca o novo numero de sequencial
      rw_crawepr.nrseqpac := fn_sequence(pr_nmtabela => 'CRAPPAC', pr_nmdcampo => 'NRSEQPAC',pr_dsdchave => '0');

      -- Insere a capa do parecer da analise de credito
      BEGIN
        INSERT INTO crappac
          (nrseqpac,
           instatus)
         VALUES
          (rw_crawepr.nrseqpac,
           1);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir NRSEQPAC: '||SQLERRM;
      END;           
             
      -- Posiciona o indice par ao primeiro registro da tabela de contas a serem consultadas
      vr_ind := vr_tab_consulta.first;
      
      -- Percorre todos os registros a serem consultados
      WHILE vr_ind IS NOT NULL LOOP
        -- Efetua a analise da conta
        pc_analise_individual(pr_nrseqpac => rw_crawepr.nrseqpac
                             ,pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => vr_tab_consulta(vr_ind).nrdconta
                             ,pr_nrcpfcgc => vr_tab_consulta(vr_ind).nrcpfcgc
                             ,pr_intippes => vr_tab_consulta(vr_ind).intippes
                             ,pr_inpessoa => vr_tab_consulta(vr_ind).inpessoa
                             ,pr_vlemprst => rw_crawepr.vlemprst
                             ,pr_vlpreemp => rw_crawepr.vlpreemp
                             ,pr_qtrecpro => rw_crawepr.qtrecpro
                             ,pr_crapdat  => rw_crapdat
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        -- Se ocorreu erro, cancela o programa
        IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        -- Vai para o proximo registro
        vr_ind := vr_tab_consulta.next(vr_ind);        
      END LOOP;
      
      -- Atualiza a sequencia da analise de credito na proposta
      BEGIN
        UPDATE crawepr 
           SET nrseqpac = rw_crawepr.nrseqpac
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAWEPR: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Busca os status do titular e dos demais consultados na analise
      OPEN cr_crappac(rw_crawepr.nrseqpac);
      FETCH cr_crappac INTO rw_crappac;
      CLOSE cr_crappac;
      
      -- Se o status do titular for pre-analisado e dos demais for
      -- diferente de pre-analisado, deve-se considerar status manual
      IF rw_crappac.instatus_tit = 1 AND
         rw_crappac.instatus_out <> 1 THEN
        vr_instatus := 2; -- Analise manual
      ELSE -- Considerar a analise do titular
        vr_instatus := rw_crappac.instatus_tit;
      END IF;
      
      -- Atualiza o status no parecer principal
      BEGIN
        UPDATE crappac
           SET instatus = vr_instatus
         WHERE nrseqpac = rw_crawepr.nrseqpac;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar CRAPPAC: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      
    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em craprqs: ' || SQLERRM;

    END;

  -- Funcao para efetuar a quebra do texto em 132 posicoes, para impressao na proposta
  FUNCTION fn_retorna_quebra_texto(pr_texto VARCHAR2) RETURN VARCHAR2 IS
    vr_texto_tmp VARCHAR2(4000); 
    vr_auxiliar VARCHAR2(4000);
    vr_retorno VARCHAR2(4000); 
    vr_tamanho_max PLS_INTEGER := 132;
  BEGIN
    
    -- Atualiza a variavel temporaria com o texto do parametro
    vr_texto_tmp := pr_texto;
    
    -- Se o tamanho for maior que o maximo da linha, efetua a quebra
    WHILE length(vr_texto_tmp) > vr_tamanho_max LOOP
      
      -- Busca somente o espaco maximo que a linha comporta
      vr_auxiliar := substr(vr_texto_tmp,1,vr_tamanho_max);
      
      -- Efetua a varredura para encontrar o espaco antes da quebra
      FOR i IN 1..vr_tamanho_max LOOP
        EXIT WHEN substr(vr_auxiliar,length(vr_auxiliar),1) = ' ';
        vr_auxiliar := substr(vr_auxiliar,1,length(vr_auxiliar)-1);
      END LOOP;
       
      -- Atualiza o retorno com parte da quebra encontrada
      IF vr_retorno IS NULL THEN
        vr_retorno := vr_auxiliar;
      ELSE
        vr_retorno := vr_retorno||';'||vr_auxiliar;
      END IF;    
      
      -- Retira o texto que foi encontrado da string principal
      vr_texto_tmp := trim(substr(vr_texto_tmp,length(vr_auxiliar)));
      
    END LOOP;
    
    -- Atualiza a variavel de retorno com o saldo que ficou (menor que o tamanho maximo da linha)
    IF length(pr_texto) > vr_tamanho_max THEN
      vr_retorno := vr_retorno ||';'|| vr_texto_tmp;
    ELSE
      vr_retorno := vr_texto_tmp;
    END IF;
    
    -- Retorna a variavel de retorno
    RETURN vr_retorno;

  END;

  -- Efetua a analise de credito de um contrato
  PROCEDURE pc_retorna_analise_ctr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Codigo da cooperativa
                                  ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                  ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                  ,pr_retxml   OUT CLOB                 --> Arquivo de retorno do XML
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

      -- Busca a sequencia do parecer da analise de credito
      CURSOR cr_crawepr IS
        SELECT crappac.nrseqpac,
               crappac.instatus,
               decode(crappac.instatus,1,'Baixo risco',
                                       2,'Medio risco',
                                         'Alto risco') dsstatus
          FROM crappac,
               crawepr
         WHERE crawepr.cdcooper = pr_cdcooper
           AND crawepr.nrdconta = pr_nrdconta
           AND crawepr.nrctremp = pr_nrctremp
           AND crappac.nrseqpac = crawepr.nrseqpac;
      rw_crawepr cr_crawepr%ROWTYPE;

      -- Busca a sequencia do parecer da analise de credito
      CURSOR cr_crapdac(pr_nrseqpac crapdac.nrseqpac%TYPE) IS
        SELECT crapdac.intippes,
               crapdac.nrdconta,
               crapass.nmprimtl,
               decode(crapdac.intippes,1,'Titular',
                                       2,'Conjuge',
                                       3,'Socio',
                                       4,'Grupo Economico',
                                       5,'Avalista') dstippes,
               crapdac.inmensag,
               rati0002.fn_ajuste_mensagem(crapqac.dsmensag,crapiac.nmparam1,crapiac.nmparam2,crapiac.nmparam3,
                                                            crapdac.vlparam1,crapdac.vlparam2,crapdac.vlparam3) texto,
               MAX(crapdac.instatus) over (partition by crapdac.intippes, crapdac.nrdconta
                                      order by crapdac.intippes, crapdac.nrdconta) instatus,
               row_number() over (partition by crapdac.intippes, crapdac.nrdconta
                                      order by crapdac.intippes, crapdac.nrdconta) nrseq,
               COUNT(1)     over (partition by crapdac.intippes, crapdac.nrdconta
                                      order by crapdac.intippes, crapdac.nrdconta) qtseq
          FROM crapass,
               crapiac,
               crapqac,
               crapdac
         WHERE crapdac.nrseqpac = pr_nrseqpac
           AND crapqac.nrseqqac = crapdac.nrseqqac
           AND crapiac.nrseqiac = crapqac.nrseqiac
           AND crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = crapdac.nrdconta
           AND crapqac.dsmensag IS NOT NULL -- Nao mostrar quando a mensagem for vazia
         ORDER BY crapdac.intippes, crapdac.nrdconta, crapiac.nrseqiac;
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis gerais
      vr_retxml        XmlType;         --> Conteudo XML de retorno
      vr_ind           PLS_INTEGER :=0; --> Contador de registros do xml
      vr_dsmensag_pos  VARCHAR2(4000);  --> Mensagem positiva
      vr_dsmensag_ate  VARCHAR2(4000);  --> Mensagem positiva
      vr_dsstatus      VARCHAR2(50);    --> Descricao do status individual

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

    BEGIN
      -- Busca a sequencia do parecer da analise de credito
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        RETURN; -- Nao faz nada, pois nao tem analise para este caso
      END IF;
      CLOSE cr_crawepr;

      -- Criar cabeçalho do XML
      vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
            
      -- Insere o parecer geral da proposta
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'instatus', pr_tag_cont => rw_crawepr.instatus, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dsstatus', pr_tag_cont => rw_crawepr.dsstatus, pr_des_erro => vr_dscritic);
            
      -- Efetua loop sobre as analises
      FOR rw_crapdac IN cr_crapdac(rw_crawepr.nrseqpac) LOOP

        -- Se for uma mensagem de positivacao
        IF rw_crapdac.inmensag = 1 THEN
          -- Acumula o texto nas mensagens de positivacao
          vr_dsmensag_pos := nvl(vr_dsmensag_pos,'')||
                               fn_retorna_quebra_texto('- '||rw_crapdac.texto||';');
        ELSE
          vr_dsmensag_ate := nvl(vr_dsmensag_ate,'')||
                               fn_retorna_quebra_texto('- '||rw_crapdac.texto||';');
        END IF;
        
        -- Se for o ultimo registro, insere os dados
        IF rw_crapdac.nrseq = rw_crapdac.qtseq THEN
          -- Busca a descricao do status
          IF rw_crapdac.instatus = 1 THEN
            vr_dsstatus := 'Baixo risco';
          ELSIF rw_crapdac.instatus = 2 THEN
            vr_dsstatus := 'Medio risco';
          ELSE
            vr_dsstatus := 'Alto risco';
          END IF;
          
          -- Popula o XML com o parecer individual
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'analise', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'analise', pr_posicao => vr_ind, pr_tag_nova => 'nrdconta', pr_tag_cont => gene0002.fn_mask_conta(rw_crapdac.nrdconta), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'analise', pr_posicao => vr_ind, pr_tag_nova => 'nmprimtl', pr_tag_cont => gene0002.fn_mask_conta(rw_crapdac.nrdconta)||' - '||rw_crapdac.nmprimtl, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'analise', pr_posicao => vr_ind, pr_tag_nova => 'intippes', pr_tag_cont => rw_crapdac.intippes, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'analise', pr_posicao => vr_ind, pr_tag_nova => 'dstippes', pr_tag_cont => rw_crapdac.dstippes, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'analise', pr_posicao => vr_ind, pr_tag_nova => 'instatus', pr_tag_cont => rw_crapdac.instatus, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'analise', pr_posicao => vr_ind, pr_tag_nova => 'dsstatus', pr_tag_cont => vr_dsstatus, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'analise', pr_posicao => vr_ind, pr_tag_nova => 'dsmensag_pos', pr_tag_cont => vr_dsmensag_pos, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'analise', pr_posicao => vr_ind, pr_tag_nova => 'dsmensag_ate', pr_tag_cont => vr_dsmensag_ate, pr_des_erro => vr_dscritic);

          -- Incrementa o indicador de posicao
          vr_ind := vr_ind + 1;

          -- Limpa as variaveis acumulativas de mensagem
          vr_dsmensag_pos := NULL;
          vr_dsmensag_ate := NULL;

        END IF;
          
      END LOOP;

      -- Converte o XML para CLOB
      pr_retxml := vr_retxml.getclobval();

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        -- Converte o XML para CLOB
        pr_retxml := vr_retxml.getclobval();

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_retorna_analise_ctr: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        -- Converte o XML para CLOB
        pr_retxml := vr_retxml.getclobval();

    END;
    
  PROCEDURE pc_retorna_descricao_risco(pr_cdcooper IN crawepr.cdcooper%TYPE --> Codigo da cooperativa
                                      ,pr_nrdconta IN crawepr.nrdconta%TYPE --> Numero da conta
                                      ,pr_nrctremp IN crawepr.nrctremp%TYPE --> Numero do contrato
                                      ,pr_retxml   OUT CLOB                 --> Arquivo de retorno do XML
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

    vr_retxml        XmlType;         --> Conteudo XML de retorno
    vr_cdcritic      crapcri.cdcritic%TYPE;
    vr_dscritic      VARCHAR2(10000);
  BEGIN
    pc_retorna_analise_ctr(pr_cdcooper
                          ,pr_nrdconta
                          ,pr_nrctremp
                          ,pr_retxml
                          ,pr_cdcritic
                          ,pr_dscritic);

    --Caso não tenha encontrado análise de risco, retorna um XML com a tag instatus vazia
    if pr_retxml is null then
      vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => vr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'instatus', pr_tag_cont => '', pr_des_erro => vr_dscritic);
      pr_retxml := vr_retxml.getclobval();
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em pc_retorna_analise_ctr: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      vr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      -- Converte o XML para CLOB
      pr_retxml := vr_retxml.getclobval();
  END;
  
  
  /******************************************************************************/
  /**      Procedure para trazer o risco na proposta de emprestimo.            **/
  /******************************************************************************/
  PROCEDURE pc_obtem_emprestimo_risco( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                      ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao
                                      ,pr_cdfinemp IN crapepr.cdfinemp%TYPE  --> Finalidade do emprestimo
                                      ,pr_cdlcremp IN crapepr.cdlcremp%TYPE  --> Linha de credito do emprestimo
                                      ,pr_dsctrliq IN VARCHAR2               --> Lista de descrições de situação dos contratos
                                      ,pr_nrctremp IN crawepr.nrctremp%TYPE DEFAULT NULL  --> Número do contrato de emprestimos - P450
                                      ------ OUT ------
                                      ,pr_nivrisco     OUT VARCHAR2          --> Retorna nivel do risco
                                      ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                                      ,pr_cdcritic     OUT INTEGER) IS       --> Codigo da critica
     
  /* ..........................................................................
    --
    --  Programa : pc_obtem_emprestimo_risco        Antiga: b1wgen0043.p/obtem_emprestimo_risco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Abril/2016.                   Ultima atualizacao: 30/01/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para trazer o risco na proposta de emprestimo.
    --
    --  Alteração : 
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------    
    
    --> Buscar risco
    CURSOR cr_crapris (pr_cdcooper  crapris.cdcooper%TYPE,
                       pr_nrdconta  crapris.nrdconta%TYPE,
                       pr_dtrefere  crapris.dtrefere%TYPE,
                       pr_vlarrasto crapris.vldivida%TYPE)IS
    SELECT /*+index_desc (ris CRAPRIS##CRAPRIS1)*/
           ris.innivris,
           ris.dtdrisco
      FROM crapris ris
     WHERE ris.cdcooper = pr_cdcooper
       AND ris.nrdconta = pr_nrdconta
       AND ris.dtrefere = pr_dtrefere
       AND ris.inddocto = 1
       AND ris.cdorigem = 3
       AND (ris.vldivida > pr_vlarrasto OR 
            pr_vlarrasto = 0);
    rw_crapris cr_crapris%ROWTYPE;   
    
    --> Buscar dados da finalidade
    CURSOR cr_crapfin (pr_cdcooper crapfin.cdcooper%TYPE,
                       pr_cdfinemp crapfin.cdfinemp%TYPE) IS
      SELECT fin.tpfinali
        FROM crapfin fin
       WHERE fin.cdcooper = pr_cdcooper
         AND fin.cdfinemp = pr_cdfinemp;
    rw_crapfin cr_crapfin%ROWTYPE;
                
    --Registro do tipo calendario
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --------------> TEMPTABLE <-----------------
    vr_tab_ocorren   CADA0004.typ_tab_ocorren;  
    vr_tab_nrctrliq  gene0002.typ_split; 
    vr_tab_impress_risco     rati0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl  rati0001.typ_tab_impress_risco;
    
            
    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_des_reto VARCHAR2(10);
    vr_exc_erro EXCEPTION;
    vr_tab_erro gene0001.typ_tab_erro;
    
    vr_dstextab_riscobacen craptab.dstextab%TYPE;
    vr_innivris  NUMBER;
    vr_vlarrast  NUMBER;
    vr_flgrefin  BOOLEAN := FALSE;
    
  BEGIN
  
    --> Risco A 
    vr_innivris := 2;
    vr_flgrefin := FALSE;
    
    -- busca o risco bacen
    vr_dstextab_riscobacen := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_tptabela => 'USUARI'
                                                        ,pr_cdempres => 11
                                                        ,pr_cdacesso => 'RISCOBACEN'
                                                        ,pr_tpregist => 000);
    IF TRIM(vr_dstextab_riscobacen) IS NULL THEN
      vr_dscritic := 'Registro nao encontrado craptab;CRED;USUARI;11;RISCOBACEN';
      RAISE vr_exc_erro;
    END IF;
    
    vr_vlarrast := to_number(SUBSTR(vr_dstextab_riscobacen,3,9),'fm99999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    --> Buscar o pior risco da ultima central 
    CADA0004.pc_lista_ocorren
                    (pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                    ,pr_cdagenci => pr_cdagenci --> Codigo de agencia
                    ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa
                    ,pr_cdoperad => pr_cdoperad --> Codigo do operador
                    ,pr_nrdconta => pr_nrdconta --> Numero da conta
                    ,pr_rw_crapdat => rw_crapdat--> Data da cooperativa
                    ,pr_idorigem => pr_idorigem --> Identificado de oriem
                    ,pr_idseqttl => pr_idseqttl --> sequencial do titular
                    ,pr_nmdatela => pr_nmdatela --> Nome da tela
                    ,pr_flgerlog => 'N'         --> identificador se deve gerar log S-Sim e N-Nao
                    ------ OUT ------
                    ,pr_tab_ocorren  => vr_tab_ocorren   --> retorna temptable com os dados dos convenios
                    ,pr_des_reto     => vr_des_reto          --> OK ou NOK
                    ,pr_tab_erro     => vr_tab_erro );
     
    -- Se houve retorno não Ok
    IF vr_des_reto = 'NOK' THEN
      -- Retornar a mensagem de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;                                   
    
    --> Extrair valor
    IF vr_tab_ocorren.exists(vr_tab_ocorren.first) AND vr_tab_ocorren(vr_tab_ocorren.first).innivris <> 0 THEN
      vr_innivris := vr_tab_ocorren(vr_tab_ocorren.first).innivris;
    END IF;
    
    IF TRIM(pr_dsctrliq) IS NOT NULL AND UPPER(TRIM(pr_dsctrliq)) <> 'SEM LIQUIDACOES' THEN
      --> Percorre todos os contratos
      vr_tab_nrctrliq := gene0002.fn_quebra_string(REPLACE(pr_dsctrliq,';',','),',');
      
      IF vr_tab_nrctrliq.count >  0 THEN  
        FOR i IN vr_tab_nrctrliq.first..vr_tab_nrctrliq.last LOOP          
         IF NVL(TRIM(vr_tab_nrctrliq(i)),'0') = '0' THEN
           continue;
         END IF; 
         
         vr_flgrefin := TRUE;
         EXIT;
      
        END LOOP;
      END IF;
    END IF;
    
    --> Verificacao para saber se eh refinancimento
    IF vr_flgrefin THEN
      --> buscar ultimo risco verificando valor arrasto
      OPEN cr_crapris (pr_cdcooper  => pr_cdcooper,
                       pr_nrdconta  => pr_nrdconta,
                       pr_dtrefere  => rw_crapdat.dtmvtoan,
                       pr_vlarrasto => vr_vlarrast);
      FETCH cr_crapris INTO rw_crapris;                 
      IF cr_crapris%FOUND THEN
        CLOSE cr_crapris;
        IF rw_crapris.innivris > vr_innivris THEN
          vr_innivris := rw_crapris.innivris;
        END IF;
      ELSE
        CLOSE cr_crapris;  
        --> buscar ultimo risco
        OPEN cr_crapris (pr_cdcooper  => pr_cdcooper,
                         pr_nrdconta  => pr_nrdconta,
                         pr_dtrefere  => rw_crapdat.dtmvtoan,
                         pr_vlarrasto => 0);
        
        FETCH cr_crapris INTO rw_crapris;
        IF cr_crapris%FOUND THEN  
          CLOSE cr_crapris;     
          --> Caso possuir Prejuizo para as operacoes abaixo do valor de arrasto, o Risco sera "H".
          --  Senao o Risco sera "A" e nao precisamos verificar o pior risco entre as operacoes                   */
         IF rw_crapris.innivris = 10 THEN
           IF rw_crapris.innivris > vr_innivris THEN
             vr_innivris := rw_crapris.innivris;
           END IF;  
         END IF;
                            
        ELSE 
          CLOSE cr_crapris;
        END IF;
      END IF;
    
    END IF;
    
    -- P450 - Rating    
    RISC0004.pc_busca_risco_inclusao(pr_cdcooper   => pr_cdcooper --> Codigo da cooperativa
                                    ,pr_nrdconta   => pr_nrdconta --> Número da conta
                                    ,pr_dsctrliq   => pr_dsctrliq --> Lista de Contratos Liquidados
                                    ,pr_rw_crapdat => rw_crapdat  --> Data da cooperativa
                                    ,pr_nrctremp   => pr_nrctremp --> Número contrato emprestimos
                                    ,pr_innivris   => vr_innivris --> Risco Inclusão
                                    ,pr_cdcritic   => vr_cdcritic 
                                    ,pr_dscritic   => vr_dscritic);
 
    -- Se houve retorno não Ok
    IF nvl(vr_cdcritic,0) > 0 or vr_dscritic is not null  THEN
      RAISE vr_exc_erro;
    END IF;  
    ----------------
    
    --> Somente vamos verificar a cessao de credito, caso possui a finalidade
    IF pr_cdfinemp > 0 THEN
      --> Buscar dados da finalidade
      OPEN cr_crapfin (pr_cdcooper => pr_cdcooper,
                       pr_cdfinemp => pr_cdfinemp);
      FETCH cr_crapfin INTO rw_crapfin; 
      
      IF cr_crapfin%FOUND AND 
         rw_crapfin.tpfinali = 1 THEN
        CLOSE cr_crapfin;
        
        --> Risco D
        IF vr_innivris < 5 THEN
          vr_innivris := 5;
        END IF;  
        
      ELSE
        CLOSE cr_crapfin;
      END IF;
      
    END IF;
    
    --> Chamado: 522658
    IF pr_cdlcremp > 0 THEN
      IF pr_cdcooper = 2 AND 
         pr_cdlcremp IN (800,850,900) THEN
        --> Risco E 
        IF vr_innivris < 6 THEN
          vr_innivris := 6;
        END IF;  
      ELSIF pr_cdcooper <> 2 AND 
            pr_cdlcremp IN (800,900) THEN
        --> Risco E 
        IF vr_innivris < 6 THEN
          vr_innivris := 6;
        END IF;  
      END IF;
              
    END IF; --> END IF pr_cdfinemp > 0 THEN 
  
    IF vr_innivris = 10 THEN
      vr_innivris := 9;
    END IF;
    
    -- Obter as descricoes do risco, provisao , etc ...
    RATI0001.pc_descricoes_risco
                       (pr_cdcooper             => pr_cdcooper             --> Cooperativa conectada
                       ,pr_inpessoa             => 0                       --> Tipo de pessoa
                       ,pr_nrnotrat             => 0                       --> Valor baseado no calculo do rating
                       ,pr_nrnotatl             => 0                       --> Valor baseado no calculo do risco
                       ,pr_nivrisco             => vr_innivris             --> Nivel do Risco
                       ,pr_tab_impress_risco_cl => vr_tab_impress_risco    --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                       ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                       ,pr_des_reto             => vr_des_reto);
    
   
    IF vr_tab_impress_risco.exists(vr_tab_impress_risco.first) THEN
      pr_nivrisco := vr_tab_impress_risco(vr_tab_impress_risco.first).dsdrisco;
    END IF;   
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_obtem_emprestimo_risco ' ||
                     SQLERRM;      
  END pc_obtem_emprestimo_risco;
  
  /******************************************************************************/
  /**      Procedure para atualizar o risco na proposta de emprestimo.         **/
  /******************************************************************************/
  PROCEDURE pc_atualiza_risco_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                      ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimento
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Numero de contrato                                      
                                      ------ OUT ------                                      
                                      ,pr_dscritic     OUT VARCHAR2          --> Descrição da critica
                                      ,pr_cdcritic     OUT INTEGER) IS       --> Codigo da critica
     
  /* ..........................................................................
    --
    --  Programa : pc_atualiza_risco_proposta        Antiga: b1wgen0002.p/atualiza_risco_proposta
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Abril/2016.                   Ultima atualizacao: 30/01/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para atualizar o risco na proposta de emprestimo.
    --
    --  Alteração : 
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------    
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr ( pr_cdcooper  crawepr.cdcooper%TYPE,
                        pr_nrdconta  crawepr.nrdconta%TYPE,
                        pr_nrctremp  crawepr.nrctremp%TYPE) IS
      SELECT epr.cdfinemp,
             epr.cdlcremp,
             epr.nrctremp,
             to_char(epr.nrctrliq##1) || ',' || to_char(epr.nrctrliq##2) || ',' ||
             to_char(epr.nrctrliq##3) || ',' || to_char(epr.nrctrliq##4) || ',' ||
             to_char(epr.nrctrliq##5) || ',' || to_char(epr.nrctrliq##6) || ',' ||
             to_char(epr.nrctrliq##7) || ',' || to_char(epr.nrctrliq##8) || ',' ||
             to_char(epr.nrctrliq##9) || ',' || to_char(epr.nrctrliq##10) dsliquid,
             epr.rowid
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;
                
    --Registro do tipo calendario
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --------------> TEMPTABLE <-----------------
    
            
    --------------> VARIAVEIS <-----------------
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(1000);
    vr_des_reto VARCHAR2(10);
    vr_exc_erro EXCEPTION;
    
    vr_dsnivris VARCHAR2(100);
    
    
  BEGIN
    
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr ( pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => pr_nrdconta,
                      pr_nrctremp  => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 510;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crawepr;      
    END IF;
    
    -- Obtem o pior risco dentre as propostas
    pc_obtem_emprestimo_risco( pr_cdcooper => pr_cdcooper         --> Codigo da cooperativa
                              ,pr_cdagenci => pr_cdagenci         --> Codigo de agencia
                              ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do caixa
                              ,pr_cdoperad => pr_cdoperad         --> Codigo do operador
                              ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                              ,pr_idseqttl => 1                   --> Sequencial do titular
                              ,pr_idorigem => pr_idorigem         --> Identificado de oriem
                              ,pr_nmdatela => pr_nmdatela         --> Nome da tela
                              ,pr_flgerlog => 'N'                 --> identificador se deve gerar log S-Sim e N-Nao
                              ,pr_cdfinemp => rw_crawepr.cdfinemp --> Finalidade do emprestimo
                              ,pr_cdlcremp => rw_crawepr.cdlcremp --> Linha de credito do emprestimo
                              ,pr_dsctrliq => rw_crawepr.dsliquid --> Lista de descrições de situação dos contratos
                              ------ OUT ------
                              ,pr_nivrisco => vr_dsnivris         --> Retorna nivel do risco
                              ,pr_dscritic => vr_dscritic         --> Descrição da critica
                              ,pr_cdcritic => vr_cdcritic);       --> Codigo da critica
      
    IF TRIM(vr_dscritic) IS NOT NULL OR
       nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro; 
    END IF;   
      
    --> Atualizar risco
    BEGIN
      UPDATE crawepr
         SET crawepr.dsnivris = UPPER(vr_dsnivris)
       WHERE crawepr.rowid = rw_crawepr.rowid;   
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel atualizar risco da proposta: '||SQLERRM;
        RAISE vr_exc_erro;
    END; 
    
    
  EXCEPTION 
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_obtem_emprestimo_risco ' ||
                     SQLERRM;      
  END pc_atualiza_risco_proposta;
  
END rati0002;
/
