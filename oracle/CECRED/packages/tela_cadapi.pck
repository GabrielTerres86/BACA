CREATE OR REPLACE PACKAGE CECRED.tela_cadapi IS
    ---------------------------------------------------------------------------
    --
    --  Programa : TELA_CADAPI
    --  Sistema  : Ayllos Web
    --  Autor    : Andre Clemer - Supero
    --  Data     : 08/02/2019                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Centralizar rotinas relacionadas a tela CADAPI
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------

    PROCEDURE pc_consulta_produtos(pr_dsproduto IN tbcc_produto.dsproduto%TYPE --> Descrição do produto
                                  ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2 --> Erros do processo
                                   );

    PROCEDURE pc_consulta_finalidades(pr_idservico_api IN tbapi_finalidade_produto_api.idservico_api%TYPE --> Código do produto
                                     ,pr_xmllog        IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic      OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic      OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml        IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro      OUT VARCHAR2 --> Erros do processo
                                      );

    PROCEDURE pc_grava_finalidades(pr_idservico_api  IN tbapi_finalidade_produto_api.idservico_api%TYPE --> Código do produto
                                  ,pr_ls_finalidades IN VARCHAR2 --> Lista de finalidades para gravação
                                  ,pr_xmllog         IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic       OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic       OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml         IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro       OUT VARCHAR2 --> Erros do processo
                                   );

END tela_cadapi;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_cadapi IS

    TYPE typ_cds IS TABLE OF tbapi_finalidade_produto_api.cdfinalidade%TYPE;

    ---------------------------------------------------------------------------
    --
    --  Programa : TELA_CADAPI
    --  Sistema  : Ayllos Web
    --  Autor    : Andre Clemer - Supero
    --  Data     : 08/02/2019                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Centralizar rotinas relacionadas a tela CADAPI
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------

    PROCEDURE pc_consulta_produtos(pr_dsproduto IN tbcc_produto.dsproduto%TYPE --> Descrição do produto
                                  ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2 --> Erros do processo
                                   ) IS
        /* .............................................................................
        
        Programa: pc_consulta_produtos
        Sistema : Ayllos Web
        Autor   : Andre Clemer - Supero
        Data    : 08/02/2019                Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para consulta dos produtos de API.
        
        Alteracoes: 
        
        ..............................................................................*/
    
        CURSOR cr_produtos IS
            SELECT cdproduto
                  ,dsproduto
              FROM tbcc_produto
             WHERE flgproduto_api = 1
               AND (dsproduto LIKE '%' || upper(pr_dsproduto) || '%' OR TRIM(pr_dsproduto) IS NULL)
             ORDER BY dsproduto ASC;
    
        CURSOR cr_produto_servico(pr_cdproduto IN tbapi_produto_servico.cdproduto%TYPE) IS
            SELECT idservico_api
                  ,dsservico_api
              FROM tbapi_produto_servico
             WHERE idapi_cooperado = 1
               AND cdproduto = pr_cdproduto
             ORDER BY dsservico_api ASC;
        rw_produto_servico cr_produto_servico%ROWTYPE;
    
        -- Variaveis internas
        vr_contador  PLS_INTEGER := 0;
        vr_contador2 PLS_INTEGER := 0;
    
        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
        -- Tratamento de erros
        vr_exc_erro EXCEPTION;
    
    BEGIN
        pr_nmdcampo := NULL;
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
    
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela, pr_action => vr_nmeacao);
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
                              
    
        -- Cadastro das categorias
        FOR rw_produtos IN cr_produtos LOOP
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Produto'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Produto'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cdproduto'
                                  ,pr_tag_cont => rw_produtos.cdproduto
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Produto'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dsproduto'
                                  ,pr_tag_cont => rw_produtos.dsproduto
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Produto'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'produto_6'
                                  ,pr_tag_cont => rw_produtos.dsproduto
                                  ,pr_des_erro => vr_dscritic);
        
            FOR rw_produto_servico IN cr_produto_servico(pr_cdproduto => rw_produtos.cdproduto) LOOP
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Produto'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'Servico'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Servico'
                                      ,pr_posicao  => vr_contador2
                                      ,pr_tag_nova => 'idservico_api'
                                      ,pr_tag_cont => rw_produto_servico.idservico_api
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Servico'
                                      ,pr_posicao  => vr_contador2
                                      ,pr_tag_nova => 'dsservico_api'
                                      ,pr_tag_cont => rw_produto_servico.dsservico_api
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Servico'
                                      ,pr_posicao  => vr_contador2
                                      ,pr_tag_nova => 'cdproduto'
                                      ,pr_tag_cont => rw_produtos.cdproduto
                                      ,pr_des_erro => vr_dscritic);
            
                vr_contador2 := vr_contador2 + 1;
            
            END LOOP;
        
            vr_contador := vr_contador + 1;
        END LOOP;
    
        dbms_output.put_line(pr_retxml.getstringval());
    
    EXCEPTION
        WHEN vr_exc_erro THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela CADAPI: ' || SQLERRM;
        
            pr_des_erro := 'NOK';
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_consulta_produtos;

    PROCEDURE pc_consulta_finalidades(pr_idservico_api IN tbapi_finalidade_produto_api.idservico_api%TYPE --> Código do produto
                                     ,pr_xmllog        IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic      OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic      OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml        IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro      OUT VARCHAR2 --> Erros do processo
                                      ) IS
        /* .............................................................................
        
        Programa: pc_consulta_finalidades
        Sistema : Ayllos Web
        Autor   : Andre Clemer - Supero
        Data    : 11/02/2019                Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para busca dos finalidade de API.
        
        Alteracoes: 
        
        ..............................................................................*/
    
        CURSOR cr_finalidades(pr_idservico_api IN tbapi_finalidade_produto_api.idservico_api%TYPE) IS
            SELECT fin.idservico_api
                  ,fin.cdfinalidade
                  ,fin.dsfinalidade
                  ,fin.idsituacao
                  ,fin.dtativacao
                  ,fin.cdoperador_ativa
                  ,fin.dtinativacao
                  ,fin.cdoperador_inativa
              FROM tbapi_finalidade_produto_api fin
             WHERE fin.idservico_api = pr_idservico_api;
    
        -- Variaveis internas
        vr_contador PLS_INTEGER := 0;
    
        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
        -- Tratamento de erros
        vr_exc_erro EXCEPTION;
    
    BEGIN
        pr_nmdcampo := NULL;
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
    
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela, pr_action => vr_nmeacao);
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        -- Cadastro das categorias
        FOR rw_finalidade IN cr_finalidades(pr_idservico_api) LOOP
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Finalidade'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Finalidade'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cdproduto'
                                  ,pr_tag_cont => rw_finalidade.idservico_api
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Finalidade'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cdfinalidade'
                                  ,pr_tag_cont => rw_finalidade.cdfinalidade
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Finalidade'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dsfinalidade'
                                  ,pr_tag_cont => rw_finalidade.dsfinalidade
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Finalidade'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'idsituacao'
                                  ,pr_tag_cont => rw_finalidade.idsituacao
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Finalidade'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dtativacao'
                                  ,pr_tag_cont => rw_finalidade.dtativacao
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Finalidade'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cdoperador_ativa'
                                  ,pr_tag_cont => rw_finalidade.cdoperador_ativa
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Finalidade'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dtinativacao'
                                  ,pr_tag_cont => rw_finalidade.dtinativacao
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Finalidade'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cdoperador_inativa'
                                  ,pr_tag_cont => rw_finalidade.cdoperador_inativa
                                  ,pr_des_erro => vr_dscritic);
        
            vr_contador := vr_contador + 1;
        END LOOP;
    EXCEPTION
        WHEN vr_exc_erro THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela CADAPI: ' || SQLERRM;
        
            pr_des_erro := 'NOK';
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_consulta_finalidades;

    PROCEDURE pc_grava_finalidades(pr_idservico_api  IN tbapi_finalidade_produto_api.idservico_api%TYPE --> Código do produto
                                  ,pr_ls_finalidades IN VARCHAR2 --> Lista de finalidades para gravação
                                  ,pr_xmllog         IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic       OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic       OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml         IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro       OUT VARCHAR2 --> Erros do processo
                                   ) IS
        /* .............................................................................
        
        Programa: pc_grava_finalidades
        Sistema : Ayllos Web
        Autor   : Andre Clemer - Supero
        Data    : 11/02/2019                Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para gravar finalidades da API.
        
        Alteracoes: 
        
        ..............................................................................*/
    
        -- Cursores internos
        CURSOR cr_finalidade(pr_idservico_api IN tbapi_finalidade_produto_api.idservico_api%TYPE
                            ,pr_cdfinalidade  IN tbapi_finalidade_produto_api.cdfinalidade%TYPE) IS
            SELECT fin.dsfinalidade
                  ,fin.idsituacao
              FROM tbapi_finalidade_produto_api fin
             WHERE fin.idservico_api = idservico_api
               AND fin.cdfinalidade = pr_cdfinalidade;
        rw_finalidade cr_finalidade%ROWTYPE;
    
        CURSOR cr_finalidades(pr_cdproduto IN tbapi_finalidade_produto_api.idservico_api%TYPE) IS
            SELECT fin.cdfinalidade
                  ,fin.dsfinalidade
              FROM tbapi_finalidade_produto_api fin
             WHERE fin.idservico_api = idservico_api;
        rw_finalidades cr_finalidades%ROWTYPE;
    
        -- Variaveis internas
        vr_blnfound       BOOLEAN;
        vr_split_fin      gene0002.typ_split;
        vr_split_rec      gene0002.typ_split;
        vr_cds            typ_cds;
        vr_cdfinalidade   tbapi_finalidade_produto_api.cdfinalidade%TYPE;
        vr_dsfinalidade   tbapi_finalidade_produto_api.dsfinalidade%TYPE;
        vr_idsituacao     tbapi_finalidade_produto_api.idsituacao%TYPE;
        vr_old_idsituacao tbapi_finalidade_produto_api.idsituacao%TYPE;
    
        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
        -- Tratamento de erros
        vr_exc_erro EXCEPTION;
    
    BEGIN
        -- Inicializa variaveis
        pr_nmdcampo := NULL;
        pr_des_erro := 'OK';
        vr_cds      := typ_cds();
    
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
    
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela, pr_action => vr_nmeacao);
    
        vr_split_fin := gene0002.fn_quebra_string(pr_ls_finalidades, '|');
    
        FOR i IN nvl(vr_split_fin.first, 0) .. nvl(vr_split_fin.last, -1) LOOP
        
            vr_split_rec := gene0002.fn_quebra_string(vr_split_fin(i), '#');
        
            vr_cds.extend;
            vr_cds(i) := vr_split_rec(1);
        
            -- Atribui valores
            vr_cdfinalidade := vr_split_rec(1);
            vr_dsfinalidade := vr_split_rec(2);
            vr_idsituacao   := vr_split_rec(3);
        
            -- Consulta a finalidade atual
            OPEN cr_finalidade(pr_idservico_api, vr_cdfinalidade);
            FETCH cr_finalidade
                INTO rw_finalidade;
        
            vr_blnfound       := cr_finalidade%FOUND;
            vr_old_idsituacao := rw_finalidade.idsituacao;
        
            CLOSE cr_finalidade;
        
            -- Se encontrou registro, atualiza
            IF vr_blnfound THEN
                BEGIN
                    UPDATE tbapi_finalidade_produto_api
                       SET dsfinalidade       = vr_dsfinalidade
                          ,idsituacao         = decode(vr_idsituacao, 2, idsituacao, vr_idsituacao)
                          ,dtinativacao = CASE
                                              WHEN idsituacao = 1 AND vr_idsituacao = 0 THEN
                                               SYSDATE
                                              ELSE
                                               dtinativacao
                                          END
                          ,cdoperador_inativa = CASE
                                                    WHEN idsituacao = 1 AND vr_idsituacao = 0 THEN
                                                     vr_cdoperad
                                                    ELSE
                                                     cdoperador_inativa
                                                END
                          ,dtativacao = CASE
                                            WHEN idsituacao = 0 AND vr_idsituacao = 1 THEN
                                             SYSDATE
                                            ELSE
                                             dtinativacao
                                        END
                          ,cdoperador_ativa = CASE
                                                  WHEN idsituacao = 0 AND vr_idsituacao = 1 THEN
                                                   vr_cdoperad
                                                  ELSE
                                                   cdoperador_inativa
                                              END
                     WHERE idservico_api = pr_idservico_api
                       AND cdfinalidade = vr_cdfinalidade;
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Erro na atualização da finalidade.';
                        RAISE vr_exc_erro;
                END;
            ELSE
                BEGIN
                    INSERT INTO tbapi_finalidade_produto_api
                        (idservico_api, cdfinalidade, dsfinalidade, idsituacao, dtativacao, cdoperador_ativa)
                    VALUES
                        (pr_idservico_api
                        ,(SELECT nvl(MAX(cdfinalidade), 0) + 1 FROM tbapi_finalidade_produto_api WHERE idservico_api = pr_idservico_api)
                        ,vr_dsfinalidade
                        ,vr_idsituacao
                        ,SYSDATE
                        ,vr_cdoperad);
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Erro na inclusão da finalidade.';
                        RAISE vr_exc_erro;
                END;
            END IF;
        
        END LOOP;
    
        FOR rw_finalidades IN cr_finalidades(pr_idservico_api) LOOP
            IF rw_finalidades.cdfinalidade NOT MEMBER OF vr_cds THEN
                BEGIN
                    DELETE FROM tbapi_finalidade_produto_api
                     WHERE idservico_api = pr_idservico_api
                       AND cdfinalidade = rw_finalidades.cdfinalidade;
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Finalidade ' || rw_finalidades.dsfinalidade || ' está em uso.' ||
                                       ' Exclusão não permitida.';
                        RAISE vr_exc_erro;
                END;
            END IF;
        END LOOP;
    
        COMMIT;
    
    EXCEPTION
        WHEN vr_exc_erro THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        
            pr_des_erro := 'NOK';
        
            IF cr_finalidade%ISOPEN THEN
                CLOSE cr_finalidade;
            END IF;
        
            ROLLBACK;
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela CADAPI: ' || SQLERRM;
        
            pr_des_erro := 'NOK';
        
            IF cr_finalidade%ISOPEN THEN
                CLOSE cr_finalidade;
            END IF;
        
            ROLLBACK;
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_grava_finalidades;

END tela_cadapi;
/
