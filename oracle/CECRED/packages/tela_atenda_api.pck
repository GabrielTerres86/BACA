CREATE OR REPLACE PACKAGE cecred.tela_atenda_api IS
    ---------------------------------------------------------------------------
    --
    --  Programa : TELA_ATENDA_API
    --  Sistema  : Ayllos Web
    --  Autor    : Andre Clemer - Supero
    --  Data     : 25/02/2019                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Centralizar rotinas relacionadas a tela ATENDA / PLATAFORMA API
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------

    PROCEDURE pc_consulta_desenvolvedor_coop(pr_nrdconta      IN tbapi_desenvolvedor_cooperado.nrdconta%TYPE --> Numero da Conta
                                            ,pr_idservico_api IN tbapi_desenvolvedor_cooperado.idservico_api%TYPE --> Id Serviço da API
                                            ,pr_xmllog        IN VARCHAR2 --> XML com informações de LOG
                                            ,pr_cdcritic      OUT PLS_INTEGER --> Código da crítica
                                            ,pr_dscritic      OUT VARCHAR2 --> Descrição da crítica
                                            ,pr_retxml        IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                            ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                                            ,pr_des_erro      OUT VARCHAR2 --> Erros do processo
                                             );

    PROCEDURE pc_consulta_finalidade_coop(pr_nrdconta      IN tbapi_desenvolvedor_cooperado.nrdconta%TYPE --> Numero da Conta
                                         ,pr_idservico_api IN tbapi_desenvolvedor_cooperado.idservico_api%TYPE --> Id Serviço da API
                                         ,pr_xmllog        IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic      OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic      OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml        IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro      OUT VARCHAR2 --> Erros do processo
                                          );

    PROCEDURE pc_consulta_servicos_coop(pr_nrdconta IN tbapi_finalidade_cooperado.nrdconta%TYPE --> Numero da Conta
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                                        );

    PROCEDURE pc_grava_servicos_coop(pr_nrdconta           IN tbapi_cooperado_servico.nrdconta%TYPE --> Numero da Conta
                                    ,pr_idservico_api      IN tbapi_cooperado_servico.idservico_api%TYPE --> Id Serviço da API
                                    ,pr_dtadesao           IN VARCHAR2 --> Data de adesão
                                    ,pr_idsituacao_adesao  IN tbapi_cooperado_servico.idsituacao_adesao%TYPE --> Situacao
                                    ,pr_tp_autorizacao     IN NUMBER --> Tipo de autorização (1 = Senha, 2 = Assinatura)
                                    ,pr_ls_finalidades     IN VARCHAR2 --> Lista de finalidades para gravação
                                    ,pr_ls_desenvolvedores IN VARCHAR2 --> Lista de desenvolvedores para gravação
                                    ,pr_cddopcao           IN VARCHAR2 --> Opção selecionada
                                    ,pr_xmllog             IN VARCHAR2 --> XML com informações de LOG
                                    ,pr_cdcritic           OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic           OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml             IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo           OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro           OUT VARCHAR2 --> Erros do processo
                                     );

    PROCEDURE pc_grava_credenciais_acesso(pr_nrdconta IN crapass.nrdconta%TYPE
                                         ,pr_dssenha  IN VARCHAR2
                                         ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                                         );

    PROCEDURE pc_gera_termo(pr_dsrowid  IN VARCHAR2
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                           );

    PROCEDURE pc_exclui_api(pr_dsrowid  IN VARCHAR2 --> rowid do api
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                           );

END tela_atenda_api;
/
CREATE OR REPLACE PACKAGE BODY cecred.tela_atenda_api IS

    ---------------------------------------------------------------------------
    --
    --  Programa : TELA_ATENDA_API
    --  Sistema  : Ayllos Web
    --  Autor    : Andre Clemer - Supero
    --  Data     : 25/02/2019                Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Centralizar rotinas relacionadas a tela ATENDA / Plataforma API
    --
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------

    TYPE typ_cds IS TABLE OF tbapi_finalidade_produto_api.cdfinalidade%TYPE;

    PROCEDURE pc_consulta_desenvolvedor_coop(pr_nrdconta      IN tbapi_desenvolvedor_cooperado.nrdconta%TYPE --> Numero da Conta
                                            ,pr_idservico_api IN tbapi_desenvolvedor_cooperado.idservico_api%TYPE --> Id Serviço da API
                                            ,pr_xmllog        IN VARCHAR2 --> XML com informações de LOG
                                            ,pr_cdcritic      OUT PLS_INTEGER --> Código da crítica
                                            ,pr_dscritic      OUT VARCHAR2 --> Descrição da crítica
                                            ,pr_retxml        IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                            ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                                            ,pr_des_erro      OUT VARCHAR2 --> Erros do processo
                                             ) IS
        /* .............................................................................
        
        Programa: pc_consulta_desenvolvedor_coop
        Sistema : Ayllos Web
        Autor   : Andre Clemer - Supero
        Data    : 19/02/2019                Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para consulta dos desenvolvedores do cooperado da API.
        
        Alteracoes:
        
        ..............................................................................*/
    
        CURSOR cr_desenvolvedores(pr_cdcooper      IN tbapi_desenvolvedor_cooperado.cdcooper%TYPE
                                 ,pr_nrdconta      IN tbapi_desenvolvedor_cooperado.nrdconta%TYPE
                                 ,pr_idservico_api IN tbapi_desenvolvedor_cooperado.idservico_api%TYPE) IS
            SELECT dco.cddesenvolvedor
                  ,des.dsnome
                  ,des.inpessoa
                  ,des.nrdocumento
                  ,des.nrddd_comercial
                  ,des.nrtelefone_comercial
                  ,des.nrddd_celular
                  ,des.nrtelefone_celular
                  ,des.dscontato_comercial
                  ,des.dscontato_celular
                  ,des.dsemail
              FROM tbapi_desenvolvedor_cooperado dco
                  ,tbapi_desenvolvedor           des
             WHERE dco.cddesenvolvedor = des.cddesenvolvedor
               AND dco.cdcooper = pr_cdcooper
               AND dco.nrdconta = pr_nrdconta
               AND dco.idservico_api = pr_idservico_api;
    
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
        FOR rw_desenvolvedor IN cr_desenvolvedores(vr_cdcooper, pr_nrdconta, pr_idservico_api) LOOP
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Desenvolvedor'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Desenvolvedor'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cddesenvolvedor'
                                  ,pr_tag_cont => rw_desenvolvedor.cddesenvolvedor
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Desenvolvedor'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dsnome'
                                  ,pr_tag_cont => rw_desenvolvedor.dsnome
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Desenvolvedor'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'nrdocumento'
                                  ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_desenvolvedor.nrdocumento
                                                                           ,rw_desenvolvedor.inpessoa)
                                  ,pr_des_erro => vr_dscritic);
        
            IF TRIM(rw_desenvolvedor.nrtelefone_comercial) IS NOT NULL THEN
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Desenvolvedor'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'nrtelefone'
                                      ,pr_tag_cont => CASE
                                                          WHEN TRIM(rw_desenvolvedor.nrddd_comercial) IS NOT NULL THEN
                                                           '(' || rw_desenvolvedor.nrddd_comercial || ') ' ||
                                                           rw_desenvolvedor.nrtelefone_comercial
                                                          ELSE
                                                           ''
                                                      END
                                      ,pr_des_erro => vr_dscritic);
            ELSE
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Desenvolvedor'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'nrtelefone'
                                      ,pr_tag_cont => CASE
                                                          WHEN TRIM(rw_desenvolvedor.nrddd_celular) IS NOT NULL THEN
                                                           '(' || rw_desenvolvedor.nrddd_celular || ') ' ||
                                                           rw_desenvolvedor.nrtelefone_celular
                                                          ELSE
                                                           ''
                                                      END
                                      ,pr_des_erro => vr_dscritic);
            END IF;
        
            IF TRIM(rw_desenvolvedor.dscontato_comercial) IS NOT NULL THEN
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Desenvolvedor'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'dscontato'
                                      ,pr_tag_cont => rw_desenvolvedor.dscontato_comercial
                                      ,pr_des_erro => vr_dscritic);
            ELSE
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Desenvolvedor'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'dscontato'
                                      ,pr_tag_cont => rw_desenvolvedor.dscontato_celular
                                      ,pr_des_erro => vr_dscritic);
            END IF;
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Desenvolvedor'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dsemail'
                                  ,pr_tag_cont => rw_desenvolvedor.dsemail
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
            pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_API.pc_consulta_desenvolvedor_coop: ' ||
                           SQLERRM;
        
            pr_des_erro := 'NOK';
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_consulta_desenvolvedor_coop;

    PROCEDURE pc_consulta_finalidade_coop(pr_nrdconta      IN tbapi_desenvolvedor_cooperado.nrdconta%TYPE --> Numero da Conta
                                         ,pr_idservico_api IN tbapi_desenvolvedor_cooperado.idservico_api%TYPE --> Id Serviço da API
                                         ,pr_xmllog        IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic      OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic      OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml        IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro      OUT VARCHAR2 --> Erros do processo
                                          ) IS
        /* .............................................................................
        
        Programa: pc_consulta_finalidade_coop
        Sistema : Ayllos Web
        Autor   : Andre Clemer - Supero
        Data    : 19/02/2019                Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para consulta das finalidades do cooperado da API.
        
        Alteracoes:
        
        ..............................................................................*/
    
        CURSOR cr_finalidades(pr_cdcooper      IN tbapi_finalidade_cooperado.cdcooper%TYPE
                             ,pr_nrdconta      IN tbapi_finalidade_cooperado.nrdconta%TYPE
                             ,pr_idservico_api IN tbapi_finalidade_cooperado.idservico_api%TYPE) IS
            SELECT fco.cdfinalidade
              FROM tbapi_finalidade_cooperado fco
             WHERE fco.cdcooper = pr_cdcooper
               AND fco.nrdconta = pr_nrdconta
               AND fco.idservico_api = pr_idservico_api;
    
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
        FOR rw_finalidade IN cr_finalidades(vr_cdcooper, pr_nrdconta, pr_idservico_api) LOOP
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Finalidade'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Finalidade'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cdfinalidade'
                                  ,pr_tag_cont => rw_finalidade.cdfinalidade
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
            pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_API.pc_consulta_finalidade_coop: ' ||
                           SQLERRM;
        
            pr_des_erro := 'NOK';
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_consulta_finalidade_coop;

    PROCEDURE pc_consulta_servicos_coop(pr_nrdconta IN tbapi_finalidade_cooperado.nrdconta%TYPE --> Numero da Conta
                                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                                        ) IS
        /* .............................................................................
        
        Programa: pc_consulta_servicos_coop
        Sistema : Ayllos Web
        Autor   : Andre Clemer - Supero
        Data    : 20/02/2019                Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para busca dos serviços do Cooperado.
        
        Alteracoes:
        
        ..............................................................................*/
    
        CURSOR cr_servicos_coop(pr_cdcooper IN tbapi_finalidade_cooperado.cdcooper%TYPE
                               ,pr_nrdconta IN tbapi_finalidade_cooperado.nrdconta%TYPE) IS
            SELECT ser.cdproduto
                  ,pro.dsproduto
                  ,cse.dtadesao
                  ,cse.idsituacao_adesao
                  ,ser.dsservico_api
                  ,ser.idservico_api
                  ,cse.rowid
              FROM tbapi_cooperado_servico cse
                  ,tbcc_produto            pro
                  ,tbapi_produto_servico   ser
             WHERE cse.cdcooper = pr_cdcooper
               AND cse.nrdconta = pr_nrdconta
               AND cse.idservico_api = ser.idservico_api
               AND ser.cdproduto = pro.cdproduto;
    
        -- Buscar a senha de acesso a API
        CURSOR cr_crapsnh(pr_cdcooper crapass.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE) IS
            SELECT 1
              FROM crapsnh snh
             WHERE snh.cdcooper = pr_cdcooper
               AND snh.nrdconta = pr_nrdconta
               AND snh.idseqttl = 1 -- Sempre primeiro titular
               AND snh.tpdsenha = 4 -- ACESSO API
               AND snh.cdsitsnh = 1; -- Situacao Ativa
        rw_crapsnh cr_crapsnh%ROWTYPE;
    
        CURSOR cr_convenio_6(pr_cdcooper IN crapceb.cdcooper%TYPE
                            ,pr_nrdconta IN crapceb.nrdconta%TYPE) IS
            SELECT 1
              FROM crapcco cco
                  ,crapceb ceb
             WHERE cco.nrconven = ceb.nrconven
               AND cco.cdcooper = ceb.cdcooper
               AND cco.dsorgarq = 'IMPRESSO PELO SOFTWARE'
               AND ceb.insitceb = 1 -- ATIVO
               AND ceb.nrdconta = pr_nrdconta
               AND ceb.cdcooper = pr_cdcooper;
        rw_convenio_6 cr_convenio_6%ROWTYPE;
    
        CURSOR cr_check_produto_disp(pr_cdcooper IN crapceb.cdcooper%TYPE
                                    ,pr_nrdconta IN crapceb.nrdconta%TYPE) IS
            SELECT substr(sys_connect_by_path(cdproduto, ','), 2) cdproduto
                  ,substr(sys_connect_by_path(idservico_api, ','), 2) idservico_api
              FROM (SELECT ps.cdproduto
                          ,ps.idservico_api
                          ,row_number() over(ORDER BY cdproduto) rn
                          ,COUNT(*) over() cnt
                      FROM tbapi_produto_servico ps
                     WHERE ps.idapi_cooperado = 1
                       AND NOT EXISTS (SELECT 1
                              FROM tbapi_cooperado_servico cs
                             WHERE cs.cdcooper = pr_cdcooper
                               AND cs.nrdconta = pr_nrdconta
                               AND cs.idservico_api = ps.idservico_api))
             WHERE rn = cnt
             START WITH rn = 1
            CONNECT BY rn = PRIOR rn + 1;
        rw_check_produto_disp cr_check_produto_disp%ROWTYPE;
    
        -- Variaveis internas
        vr_contador           PLS_INTEGER := 0;
        vr_cdsitsnh           PLS_INTEGER := 0;
        vr_convenio_ativo     PLS_INTEGER := 0;
        vr_produto_disponivel VARCHAR2(100);
        vr_servico_disponivel VARCHAR2(100);
    
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
    
        -- Buscar a senha para acesso
        OPEN cr_crapsnh(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
        FETCH cr_crapsnh
            INTO rw_crapsnh;
    
        IF cr_crapsnh%FOUND THEN
            vr_cdsitsnh := 1;
        END IF;
        CLOSE cr_crapsnh;
    
        OPEN cr_convenio_6(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
    
        FETCH cr_convenio_6
            INTO rw_convenio_6;
    
        IF cr_convenio_6%FOUND THEN
            vr_convenio_ativo := 1;
        END IF;
        CLOSE cr_convenio_6;
    
        OPEN cr_check_produto_disp(pr_cdcooper => vr_cdcooper, pr_nrdconta => pr_nrdconta);
    
        FETCH cr_check_produto_disp
            INTO rw_check_produto_disp;
    
        IF cr_check_produto_disp%FOUND THEN
            vr_produto_disponivel := rw_check_produto_disp.cdproduto;
            vr_servico_disponivel := rw_check_produto_disp.idservico_api;
        END IF;
        CLOSE cr_check_produto_disp;
    
        -- Insere atributo na tag Dados com a quantidade de registros
        gene0007.pc_gera_atributo(pr_xml      => pr_retxml --> XML que irá receber o novo atributo
                                 ,pr_tag      => 'Dados' --> Nome da TAG XML
                                 ,pr_atrib    => 'cdsitsnh' --> Nome do atributo
                                 ,pr_atval    => vr_cdsitsnh --> Valor do atributo
                                 ,pr_numva    => 0 --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic); --> Descrição de erros
    
        -- Insere atributo na tag Dados com a situação do convênio
        gene0007.pc_gera_atributo(pr_xml      => pr_retxml --> XML que irá receber o novo atributo
                                 ,pr_tag      => 'Dados' --> Nome da TAG XML
                                 ,pr_atrib    => 'cdsitconv' --> Nome do atributo
                                 ,pr_atval    => vr_convenio_ativo --> Valor do atributo
                                 ,pr_numva    => 0 --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic); --> Descrição de erros
    
        -- Insere atributo na tag Dados com os produtos ainda disponíveis
        gene0007.pc_gera_atributo(pr_xml      => pr_retxml --> XML que irá receber o novo atributo
                                 ,pr_tag      => 'Dados' --> Nome da TAG XML
                                 ,pr_atrib    => 'cdproddisp' --> Nome do atributo
                                 ,pr_atval    => vr_produto_disponivel --> Valor do atributo
                                 ,pr_numva    => 0 --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic); --> Descrição de erros
    
        -- Insere atributo na tag Dados com os serviços ainda disponíveis
        gene0007.pc_gera_atributo(pr_xml      => pr_retxml --> XML que irá receber o novo atributo
                                 ,pr_tag      => 'Dados' --> Nome da TAG XML
                                 ,pr_atrib    => 'cdservdisp' --> Nome do atributo
                                 ,pr_atval    => vr_servico_disponivel --> Valor do atributo
                                 ,pr_numva    => 0 --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic); --> Descrição de erros
    
        -- Cadastro das categorias
        FOR rw_servicos_coop IN cr_servicos_coop(vr_cdcooper, pr_nrdconta) LOOP
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Servico'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Servico'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cdproduto'
                                  ,pr_tag_cont => rw_servicos_coop.cdproduto
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Servico'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dsproduto'
                                  ,pr_tag_cont => rw_servicos_coop.dsproduto
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Servico'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dtadesao'
                                  ,pr_tag_cont => to_char(rw_servicos_coop.dtadesao, 'DD/MM/YYYY')
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Servico'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'idsituacao_adesao'
                                  ,pr_tag_cont => rw_servicos_coop.idsituacao_adesao
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Servico'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dsservico_api'
                                  ,pr_tag_cont => rw_servicos_coop.dsservico_api
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Servico'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'idservico_api'
                                  ,pr_tag_cont => rw_servicos_coop.idservico_api
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Servico'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'rowid'
                                  ,pr_tag_cont => rw_servicos_coop.rowid
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
            pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_API.pc_consulta_servicos_coop: ' ||
                           SQLERRM;
        
            pr_des_erro := 'NOK';
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_consulta_servicos_coop;

    PROCEDURE pc_grava_servicos_coop(pr_nrdconta           IN tbapi_cooperado_servico.nrdconta%TYPE --> Numero da Conta
                                    ,pr_idservico_api      IN tbapi_cooperado_servico.idservico_api%TYPE --> Id Serviço da API
                                    ,pr_dtadesao           IN VARCHAR2 --> Data de adesão
                                    ,pr_idsituacao_adesao  IN tbapi_cooperado_servico.idsituacao_adesao%TYPE --> Situacao
                                    ,pr_tp_autorizacao     IN NUMBER --> Tipo de autorização (1 = Senha, 2 = Assinatura)
                                    ,pr_ls_finalidades     IN VARCHAR2 --> Lista de finalidades para gravação
                                    ,pr_ls_desenvolvedores IN VARCHAR2 --> Lista de desenvolvedores para gravação
                                    ,pr_cddopcao           IN VARCHAR2 --> Opção selecionada
                                    ,pr_xmllog             IN VARCHAR2 --> XML com informações de LOG
                                    ,pr_cdcritic           OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic           OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml             IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo           OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro           OUT VARCHAR2 --> Erros do processo
                                     ) IS
        /* .............................................................................
        
        Programa: pc_grava_servicos_coop
        Sistema : Ayllos Web
        Autor   : Andre Clemer - Supero
        Data    : 22/02/2019                Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina para gravar os servicos do cooperado e suas devidas ligações da API.
        
        Alteracoes:
        
        ..............................................................................*/
    
        -- Cursores internos
        CURSOR cr_finalidade(pr_cdcooper      IN tbapi_finalidade_cooperado.cdcooper%TYPE
                            ,pr_nrdconta      IN tbapi_finalidade_cooperado.nrdconta%TYPE
                            ,pr_idservico_api IN tbapi_finalidade_produto_api.idservico_api%TYPE
                            ,pr_cdfinalidade  IN tbapi_finalidade_produto_api.cdfinalidade%TYPE) IS
            SELECT fin.cdfinalidade
              FROM tbapi_finalidade_cooperado fin
             WHERE fin.cdcooper = pr_cdcooper
               AND fin.nrdconta = pr_nrdconta
               AND fin.idservico_api = pr_idservico_api
               AND fin.cdfinalidade = pr_cdfinalidade;
        rw_finalidade cr_finalidade%ROWTYPE;
    
        CURSOR cr_finalidades(pr_cdcooper      IN tbapi_finalidade_cooperado.cdcooper%TYPE
                             ,pr_nrdconta      IN tbapi_finalidade_cooperado.nrdconta%TYPE
                             ,pr_idservico_api IN tbapi_finalidade_produto_api.idservico_api%TYPE) IS
            SELECT fin.cdfinalidade
                  ,pro.dsfinalidade
              FROM tbapi_finalidade_cooperado   fin
                  ,tbapi_finalidade_produto_api pro
             WHERE fin.idservico_api = pro.idservico_api
               AND fin.cdfinalidade = pro.cdfinalidade
               AND fin.cdcooper = pr_cdcooper
               AND fin.nrdconta = pr_nrdconta
               AND fin.idservico_api = pr_idservico_api;
        rw_finalidades cr_finalidades%ROWTYPE;
    
        CURSOR cr_desenvolvedor(pr_cdcooper        IN tbapi_desenvolvedor_cooperado.cdcooper%TYPE
                               ,pr_nrdconta        IN tbapi_desenvolvedor_cooperado.nrdconta%TYPE
                               ,pr_idservico_api   IN tbapi_desenvolvedor_cooperado.idservico_api%TYPE
                               ,pr_cddesenvolvedor IN tbapi_desenvolvedor_cooperado.cddesenvolvedor%TYPE) IS
            SELECT des.cddesenvolvedor
              FROM tbapi_desenvolvedor_cooperado des
             WHERE des.cdcooper = pr_cdcooper
               AND des.nrdconta = pr_nrdconta
               AND des.idservico_api = pr_idservico_api
               AND des.cddesenvolvedor = pr_cddesenvolvedor;
        rw_desenvolvedor cr_desenvolvedor%ROWTYPE;
    
        CURSOR cr_desenvolvedores(pr_cdcooper      IN tbapi_desenvolvedor_cooperado.cdcooper%TYPE
                                 ,pr_nrdconta      IN tbapi_desenvolvedor_cooperado.nrdconta%TYPE
                                 ,pr_idservico_api IN tbapi_desenvolvedor_cooperado.idservico_api%TYPE) IS
            SELECT des.cddesenvolvedor
                  ,desenv.dsnome
              FROM tbapi_desenvolvedor_cooperado des
                  ,tbapi_desenvolvedor           desenv
             WHERE des.cddesenvolvedor = desenv.cddesenvolvedor
               AND des.cdcooper = pr_cdcooper
               AND des.nrdconta = pr_nrdconta
               AND des.idservico_api = pr_idservico_api;
        rw_desenvolvedores cr_desenvolvedores%ROWTYPE;
    
        CURSOR cr_existe_prod_serv(pr_cdcooper      IN tbapi_cooperado_servico.cdcooper%TYPE
                                  ,pr_nrdconta      IN tbapi_cooperado_servico.nrdconta%TYPE
                                  ,pr_idservico_api IN tbapi_cooperado_servico.idservico_api%TYPE) IS
            SELECT *
              FROM tbapi_cooperado_servico
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND idservico_api = pr_idservico_api;
        rw_existe_prod_serv cr_existe_prod_serv%ROWTYPE;
    
        CURSOR cr_existe_serv(pr_idservico_api IN tbapi_cooperado_servico.idservico_api%TYPE) IS
            SELECT dsservico_api
                  ,idservico_api
              FROM tbapi_produto_servico
             WHERE idservico_api = pr_idservico_api
               AND idapi_cooperado = 1;
        rw_existe_serv cr_existe_serv%ROWTYPE;
    
        -- Variaveis internas
        vr_blnfound        BOOLEAN;
        vr_split_fin       gene0002.typ_split;
        vr_split_des       gene0002.typ_split;
        vr_split_rec       gene0002.typ_split;
        vr_cds             typ_cds;
        vr_cdfinalidade    tbapi_finalidade_cooperado.cdfinalidade%TYPE;
        vr_cddesenvolvedor tbapi_desenvolvedor_cooperado.cddesenvolvedor%TYPE;
    
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
        vr_nrdrowid ROWID;
    
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
    
        OPEN cr_existe_serv(pr_idservico_api => pr_idservico_api);
        FETCH cr_existe_serv
            INTO rw_existe_serv;
    
        IF cr_existe_serv%NOTFOUND THEN
            CLOSE cr_existe_serv;
            vr_dscritic := 'Serviço não encontrado.';
            RAISE vr_exc_erro;
        END IF;
        CLOSE cr_existe_serv;
    
        IF pr_cddopcao = 'I' THEN
            OPEN cr_existe_prod_serv(pr_cdcooper      => vr_cdcooper
                                    ,pr_nrdconta      => pr_nrdconta
                                    ,pr_idservico_api => pr_idservico_api);
            FETCH cr_existe_prod_serv
                INTO rw_existe_prod_serv;
        
            IF cr_existe_prod_serv%FOUND THEN
                CLOSE cr_existe_prod_serv;
                vr_dscritic := 'Serviço já cadastrado para este cooperado.';
                RAISE vr_exc_erro;
            END IF;
            CLOSE cr_existe_prod_serv;
        END IF;
    
        -- Inserção da parte 'cabeçalho'
        BEGIN
            -- Tenta realizar o insert
            INSERT INTO tbapi_cooperado_servico
                (cdcooper, nrdconta, idservico_api, dtadesao, idsituacao_adesao, dhultima_alteracao)
            VALUES
                (vr_cdcooper
                ,pr_nrdconta
                ,pr_idservico_api
                ,to_date(pr_dtadesao, 'DD/MM/RRRR')
                ,pr_idsituacao_adesao
                ,SYSDATE);
        
            gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ' '
                                ,pr_dsorigem => ''
                                ,pr_dstransa => 'Inclusao de Servico de API'
                                ,pr_dttransa => trunc(SYSDATE)
                                ,pr_flgtrans => 1
                                ,pr_hrtransa => to_char(SYSDATE, 'SSSSS')
                                ,pr_idseqttl => 1
                                ,pr_nmdatela => ' '
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
        
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Código do Serviço'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => pr_idservico_api);
        
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Descrição do Serviço'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => rw_existe_serv.dsservico_api);
        
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Situação'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => CASE pr_idsituacao_adesao
                                                         WHEN 1 THEN
                                                          'Ativo'
                                                         ELSE
                                                          'Inativo'
                                                     END);
        
            gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                     ,pr_nmdcampo => 'Data de Adesão'
                                     ,pr_dsdadant => ' '
                                     ,pr_dsdadatu => pr_dtadesao);
        
        EXCEPTION
            -- Em caso de violação de chave (valor duplicado) tenta atualizar
            WHEN dup_val_on_index THEN
            
                OPEN cr_existe_prod_serv(pr_cdcooper      => vr_cdcooper
                                        ,pr_nrdconta      => pr_nrdconta
                                        ,pr_idservico_api => pr_idservico_api);
                FETCH cr_existe_prod_serv
                    INTO rw_existe_prod_serv;
                CLOSE cr_existe_prod_serv;
            
                BEGIN
                    UPDATE tbapi_cooperado_servico
                       SET idsituacao_adesao = pr_idsituacao_adesao, dhultima_alteracao = SYSDATE
                     WHERE cdcooper = vr_cdcooper
                       AND nrdconta = pr_nrdconta
                       AND idservico_api = pr_idservico_api;
                
                    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                                        ,pr_cdoperad => vr_cdoperad
                                        ,pr_dscritic => ' '
                                        ,pr_dsorigem => ''
                                        ,pr_dstransa => 'Alteracao de Servico de API'
                                        ,pr_dttransa => trunc(SYSDATE)
                                        ,pr_flgtrans => 1
                                        ,pr_hrtransa => to_char(SYSDATE, 'SSSSS')
                                        ,pr_idseqttl => 1
                                        ,pr_nmdatela => ' '
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Código do Serviço'
                                             ,pr_dsdadant => rw_existe_prod_serv.idservico_api
                                             ,pr_dsdadatu => pr_idservico_api);
                
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Descrição do Serviço'
                                             ,pr_dsdadant => rw_existe_serv.dsservico_api
                                             ,pr_dsdadatu => rw_existe_serv.idservico_api);
                
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Situação'
                                             ,pr_dsdadant => CASE rw_existe_prod_serv.idsituacao_adesao
                                                                 WHEN 1 THEN
                                                                  'Ativo'
                                                                 ELSE
                                                                  'Inativo'
                                                             END
                                             ,pr_dsdadatu => CASE pr_idsituacao_adesao
                                                                 WHEN 1 THEN
                                                                  'Ativo'
                                                                 ELSE
                                                                  'Inativo'
                                                             END);
                
                    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                             ,pr_nmdcampo => 'Data de Adesão'
                                             ,pr_dsdadant => to_char(rw_existe_prod_serv.dtadesao
                                                                    ,'DD/MM/YYYY')
                                             ,pr_dsdadatu => pr_dtadesao);
                
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Ocorreu um erro ao atualizar os registros.';
                        RAISE vr_exc_erro;
                END;
            WHEN OTHERS THEN
                vr_dscritic := 'Ocorreu um erro ao gravar os registros.';
                RAISE vr_exc_erro;
        END;
    
        /*
        *** Apenas gravar as alteração de finalidade e desenvolvedor quando a situação for igual a 1 (Ativo)
        */
    
        IF pr_idsituacao_adesao = 1 THEN
        
            BEGIN
            
                /*
                 Se o tipo de autorização for SENHA (1) :
                  -> Deve gravar os dados, registrando o campo DTASSINATURA_DIGITAL com o sysdate (data + hora), para todos os serviços do cooperado.
                 Se o tipo de autorização do ASSINATURA (2) :
                  -> Deve gravar os dados, registrando o campo DTASSINATURA_DIGITAL com NULL, para todos os serviços do cooperado.
                */
            
                UPDATE tbapi_cooperado_servico
                   SET dtassinatura_digital = decode(pr_tp_autorizacao, 1, SYSDATE, NULL)
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = pr_nrdconta;
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Ocorreu um erro ao atualizar os serviços do cooperado.';
                    RAISE vr_exc_erro;
            END;
        
            -- Separa e varre as finalidades para inseri-las
            vr_split_fin := gene0002.fn_quebra_string(pr_ls_finalidades, ';');
        
            FOR i IN nvl(vr_split_fin.first, 0) .. nvl(vr_split_fin.last, -1) LOOP
            
                -- Atribui valores
                vr_cdfinalidade := vr_split_fin(i);
            
                vr_cds.extend;
                vr_cds(i) := vr_cdfinalidade;
            
                -- Consulta a finalidade atual
                OPEN cr_finalidade(vr_cdcooper, pr_nrdconta, pr_idservico_api, vr_cdfinalidade);
                FETCH cr_finalidade
                    INTO rw_finalidade;
            
                vr_blnfound := cr_finalidade%FOUND;
            
                CLOSE cr_finalidade;
            
                IF NOT vr_blnfound THEN
                    BEGIN
                        INSERT INTO tbapi_finalidade_cooperado
                            (cdcooper, nrdconta, idservico_api, cdfinalidade)
                        VALUES
                            (vr_cdcooper, pr_nrdconta, pr_idservico_api, vr_cdfinalidade);
                    
                        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                                 ,pr_nmdcampo => 'Finalidade Marcada'
                                                 ,pr_dsdadant => ' '
                                                 ,pr_dsdadatu => vr_cdfinalidade);
                    EXCEPTION
                        WHEN OTHERS THEN
                            vr_dscritic := 'Ocorreu um erro ao incluir a finalidade.';
                            RAISE vr_exc_erro;
                    END;
                END IF;
            
            END LOOP;
        
            FOR rw_finalidades IN cr_finalidades(vr_cdcooper, pr_nrdconta, pr_idservico_api) LOOP
                IF rw_finalidades.cdfinalidade NOT MEMBER OF vr_cds THEN
                    BEGIN
                        DELETE FROM tbapi_finalidade_cooperado
                         WHERE cdcooper = vr_cdcooper
                           AND nrdconta = pr_nrdconta
                           AND idservico_api = pr_idservico_api
                           AND cdfinalidade = rw_finalidades.cdfinalidade;
                    
                        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                                 ,pr_nmdcampo => 'Finalidade Desmarcada'
                                                 ,pr_dsdadant => rw_finalidades.cdfinalidade
                                                 ,pr_dsdadatu => ' ');
                    
                    EXCEPTION
                        WHEN OTHERS THEN
                            vr_dscritic := 'Finalidade ' || rw_finalidades.dsfinalidade || ' está em uso.' ||
                                           ' Exclusão não permitida.';
                            RAISE vr_exc_erro;
                    END;
                END IF;
            END LOOP;
        
            -- Limpa valores
            vr_cds := typ_cds();
        
            -- Separa e varre os desenvolvedores para inseri-los
            vr_split_des := gene0002.fn_quebra_string(pr_ls_desenvolvedores, ';');
        
            FOR i IN nvl(vr_split_des.first, 0) .. nvl(vr_split_des.last, -1) LOOP
            
                -- Atribui valores
                vr_cddesenvolvedor := vr_split_des(i);
            
                vr_cds.extend;
                vr_cds(i) := vr_cddesenvolvedor;
            
                -- Consulta a finalidade atual
                OPEN cr_desenvolvedor(vr_cdcooper, pr_nrdconta, pr_idservico_api, vr_cddesenvolvedor);
                FETCH cr_desenvolvedor
                    INTO rw_desenvolvedor;
            
                vr_blnfound := cr_desenvolvedor%FOUND;
            
                CLOSE cr_desenvolvedor;
            
                IF NOT vr_blnfound THEN
                    BEGIN
                        INSERT INTO tbapi_desenvolvedor_cooperado
                            (cdcooper, nrdconta, idservico_api, cddesenvolvedor)
                        VALUES
                            (vr_cdcooper, pr_nrdconta, pr_idservico_api, vr_cddesenvolvedor);
                    
                        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                                 ,pr_nmdcampo => 'Novo Desenvolvedor'
                                                 ,pr_dsdadant => ' '
                                                 ,pr_dsdadatu => vr_cddesenvolvedor);
                    EXCEPTION
                        WHEN OTHERS THEN
                            vr_dscritic := 'Ocorreu um erro ao incluir o desenvolvedor.';
                            RAISE vr_exc_erro;
                    END;
                END IF;
            
            END LOOP;
        
            FOR rw_desenvolvedores IN cr_desenvolvedores(vr_cdcooper, pr_nrdconta, pr_idservico_api) LOOP
                IF rw_desenvolvedores.cddesenvolvedor NOT MEMBER OF vr_cds THEN
                    BEGIN
                        DELETE FROM tbapi_desenvolvedor_cooperado
                         WHERE cdcooper = vr_cdcooper
                           AND nrdconta = pr_nrdconta
                           AND idservico_api = pr_idservico_api
                           AND cddesenvolvedor = rw_desenvolvedores.cddesenvolvedor;
                    
                        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                                 ,pr_nmdcampo => 'Exclusão de Desenvolvedor'
                                                 ,pr_dsdadant => rw_desenvolvedores.cddesenvolvedor
                                                 ,pr_dsdadatu => ' ');
                    
                    EXCEPTION
                        WHEN OTHERS THEN
                            vr_dscritic := 'Desenvolvedor ' || rw_desenvolvedores.dsnome || ' está em uso.' ||
                                           ' Exclusão não permitida.';
                            RAISE vr_exc_erro;
                    END;
                END IF;
            END LOOP;
        
        END IF;
    
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
        
            ROLLBACK;
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_API.pc_grava_servicos_coop: ' || SQLERRM;
        
            pr_des_erro := 'NOK';
        
            ROLLBACK;
        
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_grava_servicos_coop;

    PROCEDURE pc_grava_credenciais_acesso(pr_nrdconta IN crapass.nrdconta%TYPE
                                         ,pr_dssenha  IN VARCHAR2
                                         ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                                         )IS
        /* .............................................................................
          Programa: pc_grava_credenciais_acesso
          Sistema : Aimaro
          Sigla   : TELA_ATENDA_API
          Autor   : Andrey Formigari (Supero)
          Data    : Março/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Grava credenciais de acesso digitadas na tela Plataforma API
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
    
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        vr_idsenhok NUMBER;
        vr_dserrshn VARCHAR2(100);
    
        CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT 1 FROM crapcop WHERE cdcooper = pr_cdcooper;
    
    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela, pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    
        OPEN cr_crapcop(vr_cdcooper);
        IF cr_crapcop%NOTFOUND THEN
            CLOSE cr_crapcop;
            vr_dscritic := 'Cooperativa não encontrada.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcop;
    
        BEGIN
            apis0001.pc_grava_credencial_acesso(pr_cdcooper => vr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_dsdsenha => pr_dssenha
                                               ,pr_cdoperad => vr_cdoperad
                                               ,pr_idsenhok => vr_idsenhok
                                               ,pr_dserrshn => vr_dserrshn);
        EXCEPTION
            WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro geral na APIS0001.pc_grava_credencial_acesso. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        IF vr_idsenhok = 0 THEN
            vr_cdcritic := 0;
            vr_dscritic := vr_dserrshn;
            RAISE vr_exc_saida;
        END IF;
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idsenhok'
                              ,pr_tag_cont => vr_idsenhok
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dserrshn'
                              ,pr_tag_cont => vr_dserrshn
                              ,pr_des_erro => vr_dscritic);
    
        COMMIT;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
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
            pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_API.pc_grava_credenciais_acesso. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_grava_credenciais_acesso;

    PROCEDURE pc_gera_termo(pr_dsrowid  IN VARCHAR2 --> rowid do api
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
        /* .............................................................................
          Programa: pc_gera_termo
          Sistema : Aimaro
          Sigla   : TELA_ATENDA_API
          Autor   : Andrey Formigari (Supero)
          Data    : Março/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Gera termo de Liberação e Condições de Uso
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
    
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        vr_nom_direto VARCHAR2(200); --> Diretório para gravação do arquivo
        vr_dsjasper   VARCHAR2(100); --> nome do jasper a ser usado
        vr_nmarqim    VARCHAR2(50); --> nome do arquivo PDF
    
        vr_xml_temp VARCHAR2(32726) := '';
        vr_clob     CLOB;
    
        vr_tab_erro gene0001.typ_tab_erro;
        vr_des_reto VARCHAR2(10);
    
        -- Cria o registro de data
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
        CURSOR cr_crapprm IS
            SELECT dsvlrprm
              FROM crapprm
             WHERE nmsistem = 'CRED'
               AND cdcooper = 0
               AND cdacesso = 'NMARQ_IMPRES_ATENDA_API';
        rw_crapprm cr_crapprm%ROWTYPE;
    
        CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT 1 FROM crapcop WHERE cdcooper = pr_cdcooper;
    
        CURSOR cr_representante_legal(pr_cdcooper crapcop.cdcooper%TYPE
                                     ,pr_nrdconta crapcop.nrdconta%TYPE) IS
            SELECT ass.nmprimtl
                  ,ass.inpessoa
                  ,nac.dsnacion
                  ,ecv.rsestcvl
                  ,ttl.nrcpfcgc
                  ,enc.dsendere
                  ,enc.nrendere
                  ,enc.nmbairro
                  ,enc.nmcidade
                  ,enc.cdufende
                  ,enc.nrcepend
              FROM crapenc enc -- Endereço
                  ,gnetcvl ecv -- Estado Civil
                  ,crapnac nac -- Nacionalidades
                  ,crapttl ttl
                  ,crapass ass
                  ,crapavt avt
             WHERE enc.tpendass = 10 -- Residencial
               AND enc.cdcooper = ttl.cdcooper
               AND enc.nrdconta = ttl.nrdconta
               AND enc.idseqttl = ttl.idseqttl
               AND ecv.cdestcvl = ttl.cdestcvl
               AND nac.cdnacion = ass.cdnacion
               AND ttl.cdcooper = ass.cdcooper
               AND ttl.nrdconta = ass.nrdconta
               AND ttl.idseqttl = 1 -- Primeiro titular
               AND ass.cdcooper = avt.cdcooper
               AND ass.nrdconta = avt.nrdctato
                  /*AND avt.dtvalida >= DATA_DE_ASSINATURA_DIGITAL*/
               AND avt.cdcooper = pr_cdcooper
               AND avt.nrdconta = pr_nrdconta;
        rw_representante_legal cr_representante_legal%ROWTYPE;
    
        CURSOR cr_cooperado(pr_dsrowid VARCHAR2) IS
            SELECT cop.nmextcop
                  ,cop.dsendweb
                  ,cop.nrouvbcb
                  ,cop.nrdocnpj
                  ,cop.dsendcop
                  ,cop.nrcepend AS nrcepend_coop
                  ,cop.nmcidade AS nmcidade_coop
                  ,cop.cdufdcop
                  ,ass.nmprimtl
                  ,ttl.xxx_dsnacion AS dsnacion
                  ,cvl.dsestcvl
                  ,ass.nrcpfcgc
                  ,ass.inpessoa
                  ,enc.dsendere
                  ,enc.nrendere
                  ,enc.nmbairro
                  ,enc.nmcidade AS nmcidade_ass
                  ,ass.nrdconta
                  ,ass.cdagenci
                  ,enc.nrcepend AS nrcepend_ass
                  ,enc.cdufende AS cdufende_ass
                  ,decode(tcs.dtassinatura_digital, NULL, 2, 1) AS tp_autorizacao
                  ,to_char(decode(tcs.dtassinatura_digital, NULL, SYSDATE, tcs.dtassinatura_digital)
                          ,'DD/MM/RRRR') AS dtassinatura_digital
                  ,to_char(decode(tcs.dtassinatura_digital, NULL, SYSDATE, tcs.dtassinatura_digital)
                          ,'hh24:mi') AS hrassinatura_digital
              FROM tbapi_cooperado_servico tcs
             INNER JOIN crapcop cop
                ON cop.cdcooper = tcs.cdcooper
             INNER JOIN crapass ass
                ON ass.cdcooper = tcs.cdcooper
               AND ass.nrdconta = tcs.nrdconta
              LEFT JOIN crapenc enc
                ON enc.cdcooper = tcs.cdcooper
               AND enc.nrdconta = tcs.nrdconta
               AND enc.idseqttl = 1
              LEFT JOIN crapttl ttl
                ON ttl.cdcooper = tcs.cdcooper
               AND ttl.nrdconta = tcs.nrdconta
               AND ttl.idseqttl = 1
              LEFT JOIN gnetcvl cvl
                ON cvl.cdestcvl = ttl.cdestcvl
             WHERE tcs.rowid = pr_dsrowid;
        rw_cooperado cr_cooperado%ROWTYPE;
    
    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela, pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    
        -- Abre o cursor de data
        OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
    
        OPEN cr_crapcop(vr_cdcooper);
        IF cr_crapcop%NOTFOUND THEN
            CLOSE cr_crapcop;
            vr_dscritic := 'Cooperativa não encontrada.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcop;
    
        OPEN cr_cooperado(pr_dsrowid => pr_dsrowid);
        FETCH cr_cooperado
            INTO rw_cooperado;
        IF cr_cooperado%NOTFOUND THEN
            CLOSE cr_cooperado;
            vr_dscritic := 'Cooperado não encontrado.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_cooperado;
    
        OPEN cr_crapprm;
        FETCH cr_crapprm
            INTO rw_crapprm;
    
        IF cr_crapprm%NOTFOUND THEN
            vr_dscritic := 'Parâmetro do Manual de API não cadastrado.';
            CLOSE cr_crapprm;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapprm;
    
        vr_dsjasper := 'termo_liberacao_plataforma_api.jasper';
        vr_nmarqim  := to_char(SYSDATE, 'DDMMYYYYHH24MISS') || '_' || rw_crapprm.dsvlrprm;
    
        --busca diretorio padrao da cooperativa
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                              ,pr_cdcooper => vr_cdcooper
                                              ,pr_nmsubdir => 'rl');
    
        -- Monta documento XML de Dados
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><dados>');
    
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<nmextcop>' || rw_cooperado.nmextcop ||
                                                     '</nmextcop>
                                                      <cdufdcop>' ||
                                                     rw_cooperado.cdufdcop ||
                                                     '</cdufdcop>
                                                      <dsendweb>' ||
                                                     rw_cooperado.dsendweb ||
                                                     '</dsendweb>
                                                      <nrouvbcb>' ||
                                                     rw_cooperado.nrouvbcb ||
                                                     '</nrouvbcb>
                                                      <nrdocnpj>' ||
                                                     gene0002.fn_mask_cpf_cnpj(rw_cooperado.nrdocnpj, 2) ||
                                                     '</nrdocnpj>
                                                      <dsendcop>' ||
                                                     rw_cooperado.dsendcop ||
                                                     '</dsendcop>
                                                      <nrcepend_coop>' ||
                                                     gene0002.fn_mask(rw_cooperado.nrcepend_coop, 'zzzzzz-zzz') ||
                                                     '</nrcepend_coop>
                                                      <nrcepend_ass>' ||
                                                     gene0002.fn_mask(rw_cooperado.nrcepend_ass, 'zzzzzz-zzz') ||
                                                     '</nrcepend_ass>
                                                      <nmcidade_coop>' ||
                                                     rw_cooperado.nmcidade_coop ||
                                                     '</nmcidade_coop>
                                                      <nmcidade_ass>' ||
                                                     rw_cooperado.nmcidade_ass ||
                                                     '</nmcidade_ass>
                                                      <nmprimtl>' ||
                                                     rw_cooperado.nmprimtl ||
                                                     '</nmprimtl>
                                                      <dsnacion>' ||
                                                     rw_cooperado.dsnacion ||
                                                     '</dsnacion>
                                                      <dsestcvl>' ||
                                                     rw_cooperado.dsestcvl ||
                                                     '</dsestcvl>
                                                      <nrcpfcgc>' ||
                                                     gene0002.fn_mask_cpf_cnpj(rw_cooperado.nrcpfcgc
                                                                              ,rw_cooperado.inpessoa) ||
                                                     '</nrcpfcgc>
                                                      <dsendere>' ||
                                                     rw_cooperado.dsendere ||
                                                     '</dsendere>
                                                      <nrendere>' ||
                                                     to_char(rw_cooperado.nrendere) ||
                                                     '</nrendere>
                                                      <nmbairro>' ||
                                                     rw_cooperado.nmbairro ||
                                                     '</nmbairro>
                                                      <nrdconta>' ||
                                                     gene0002.fn_mask(rw_cooperado.nrdconta, 'zzz.zzz.zz9') ||
                                                     '</nrdconta>
                                                      <cdufende_ass>' ||
                                                     rw_cooperado.cdufende_ass ||
                                                     '</cdufende_ass>
                                                      <cdagenci>' ||
                                                     to_char(rw_cooperado.cdagenci) ||
                                                     '</cdagenci>
                                                      <inpessoa>' ||
                                                     rw_cooperado.inpessoa ||
                                                     '</inpessoa>
                                                      <dtextenso>' ||
                                                     'Blumenau, ' || gene0005.fn_data_extenso(SYSDATE) ||
                                                     '</dtextenso>
                                                     <tp_autorizacao>' ||
                                                     rw_cooperado.tp_autorizacao ||
                                                     '</tp_autorizacao>
                                                     <dtassinatura_digital>' ||
                                                     rw_cooperado.dtassinatura_digital ||
                                                     '</dtassinatura_digital>
                                                     <hrassinatura_digital>' ||
                                                     rw_cooperado.hrassinatura_digital ||
                                                     '</hrassinatura_digital>
                                                     <nmarquivo_termo>' ||
                                                     rw_crapprm.dsvlrprm || '</nmarquivo_termo>');
    
        gene0002.pc_escreve_xml(pr_xml => vr_clob, pr_texto_completo => vr_xml_temp, pr_texto_novo => '<RL>');
    
        FOR rw_representante_legal IN cr_representante_legal(pr_cdcooper => vr_cdcooper
                                                            ,pr_nrdconta => rw_cooperado.nrdconta) LOOP
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<RepresentanteLegal>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<nmprimtl>' || rw_representante_legal.nmprimtl ||
                                                         '</nmprimtl>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<dsnacion>' || rw_representante_legal.dsnacion ||
                                                         '</dsnacion>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<rsestcvl>' || rw_representante_legal.rsestcvl ||
                                                         '</rsestcvl>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<nrcpfcgc>' ||
                                                         gene0002.fn_mask_cpf_cnpj(rw_representante_legal.nrcpfcgc
                                                                                  ,rw_representante_legal.inpessoa) ||
                                                         '</nrcpfcgc>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<dsendere>' || rw_representante_legal.dsendere ||
                                                         '</dsendere>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<nrendere>' || rw_representante_legal.nrendere ||
                                                         '</nrendere>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<nmbairro>' || rw_representante_legal.nmbairro ||
                                                         '</nmbairro>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<nmcidade>' || rw_representante_legal.nmcidade ||
                                                         '</nmcidade>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<cdufende>' || rw_representante_legal.cdufende ||
                                                         '</cdufende>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<nrcepend>' ||
                                                         gene0002.fn_mask(rw_representante_legal.nrcepend
                                                                         ,'zzzzzz-zzz') || '</nrcepend>');
        
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '</RepresentanteLegal>');
        
        END LOOP;
    
        gene0002.pc_escreve_xml(pr_xml => vr_clob, pr_texto_completo => vr_xml_temp, pr_texto_novo => '</RL>');
    
        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</dados>'
                               ,pr_fecha_xml      => TRUE);
    
        -- Solicita geracao do PDF
        gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper
                                   ,pr_cdprogra  => 'ATENDA'
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_clob
                                   ,pr_dsxmlnode => '/dados'
                                   ,pr_dsjasper  => vr_dsjasper
                                   ,pr_dsparams  => NULL
                                   ,pr_dsarqsaid => vr_nom_direto || '/' || vr_nmarqim
                                   ,pr_cdrelato  => 733
                                   ,pr_flg_gerar => 'S'
                                   ,pr_qtcoluna  => 80
                                   ,pr_sqcabrel  => 1
                                   ,pr_flg_impri => 'N'
                                   ,pr_nmformul  => ' '
                                   ,pr_nrcopias  => 1
                                   ,pr_parser    => 'R'
                                   ,pr_nrvergrl  => 1
                                   ,pr_des_erro  => vr_dscritic);
        -- Se houve retorno de erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
        END IF;
    
        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);
    
        gene0002.pc_efetua_copia_pdf(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_nom_direto || '/' || vr_nmarqim
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
    
        -- Se houve retorno de erro
        IF nvl(vr_des_reto, 'OK') <> 'OK' THEN
            IF vr_tab_erro.count > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                RAISE vr_exc_saida;
            END IF;
        END IF;
        -- Criar XML de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' || vr_nmarqim ||
                                       '</nmarqpdf>');
    
        COMMIT;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
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
            pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_API.pc_gera_termo. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_gera_termo;

    PROCEDURE pc_exclui_api(pr_dsrowid  IN VARCHAR2 --> rowid do api
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2 --> Erros do processo
                           ) IS
        /* .............................................................................
          Programa: pc_exclui_api
          Sistema : Aimaro
          Sigla   : TELA_ATENDA_API
          Autor   : Andrey Formigari (Supero)
          Data    : Maio/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Exclui uma API selecionada em tela.
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
    
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        vr_nrdconta      tbapi_cooperado_servico.nrdconta%TYPE;
        vr_cdproduto     tbapi_produto_servico.cdproduto%TYPE;
        vr_idservico_api tbapi_produto_servico.idservico_api%TYPE;
    
        vr_isdelete BOOLEAN := FALSE;
    
        vr_xml_temp VARCHAR2(32726) := '';
        vr_clob     CLOB;
    
        vr_tab_erro gene0001.typ_tab_erro;
        vr_des_reto VARCHAR2(10);
    
        -- Cria o registro de data
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
        CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT 1 FROM crapcop WHERE cdcooper = pr_cdcooper;
    
        CURSOR cr_tickboleto(pr_cdcooper crapcob.cdcooper%TYPE
                            ,pr_nrdconta crapcob.nrdconta%TYPE) IS
            SELECT 1
              FROM tbcobran_ticket_lote_boleto
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
    
        CURSOR cr_servcoop(pr_dsrowid VARCHAR2) IS
            SELECT tcs.nrdconta
                  ,tps.cdproduto
                  ,tps.idservico_api
              FROM tbapi_cooperado_servico tcs
                  ,tbapi_produto_servico   tps
             WHERE tcs.rowid = pr_dsrowid
               AND tcs.idservico_api = tps.idservico_api;
    
    BEGIN
        pr_des_erro := 'OK';
        -- Extrai dados do xml
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
    
        gene0001.pc_informa_acesso(pr_module => vr_nmdatela, pr_action => vr_nmeacao);
    
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    
        -- Abre o cursor de data
        OPEN btch0001.cr_crapdat(vr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
    
        OPEN cr_crapcop(vr_cdcooper);
        IF cr_crapcop%NOTFOUND THEN
            CLOSE cr_crapcop;
            vr_dscritic := 'Cooperativa não encontrada.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcop;
    
        OPEN cr_servcoop(pr_dsrowid => pr_dsrowid);
    
        IF cr_servcoop%NOTFOUND THEN
            vr_dscritic := 'API não foi localizada.';
            CLOSE cr_servcoop;
            RAISE vr_exc_saida;
        END IF;
        FETCH cr_servcoop
            INTO vr_nrdconta
                ,vr_cdproduto
                ,vr_idservico_api;
        CLOSE cr_servcoop;
    
        IF vr_cdproduto = 6 THEN
        
            OPEN cr_tickboleto(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
        
            IF cr_tickboleto%FOUND THEN
                vr_dscritic := 'API não pode ser excluída devido a registros existentes no Cadastro de Cobrança Bancária.';
                CLOSE cr_tickboleto;
                RAISE vr_exc_saida;
            END IF;
            CLOSE cr_tickboleto;
        
            vr_isdelete := TRUE;
        
        END IF;
    
        IF vr_isdelete = TRUE THEN
        
            BEGIN
            
                /*
                *** Excluir todas as tabelas que possuem FK com a tabela de serviços do cooperado (tbapi_cooperado_servico)
                */
            
                DELETE FROM tbapi_desenvolvedor_cooperado
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = vr_nrdconta
                   AND idservico_api = vr_idservico_api; --> Desenvolvedores;
            
                DELETE FROM tbapi_finalidade_cooperado
                 WHERE cdcooper = vr_cdcooper
                   AND nrdconta = vr_nrdconta
                   AND idservico_api = vr_idservico_api; --> Finalidades;
            
                DELETE FROM tbapi_cooperado_servico WHERE ROWID = pr_dsrowid; --> E por último, o próprio serviço.
            
                COMMIT;
            
            EXCEPTION
                WHEN OTHERS THEN
                    vr_dscritic := 'Ocorreu um erro ao tentar realizar a exclusão do registro.';
                    ROLLBACK;
                    RAISE vr_exc_saida;
            END;
        
        ELSE
            vr_dscritic := 'Produto não permite a exclusão de serviços de API do cooperado.';
            RAISE vr_exc_saida;
        END IF;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
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
        
            ROLLBACK;
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_API.pc_exclui_api. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
            ROLLBACK;
    END pc_exclui_api;

END tela_atenda_api;
/
