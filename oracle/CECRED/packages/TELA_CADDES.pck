CREATE OR REPLACE PACKAGE cecred.tela_caddes IS
    /* ---------------------------------------------------------------------------------------------------------------
    
        Programa : TELA_CADDES
        Sistema  : Rotinas referentes a tela CADDES (CADASTRO DE DESENVOLVEDORES)
        Sigla    : CADDES
        Autor    : Andrey Formigari - Supero
        Data     : Fevereiro/2019.
    
        Dados referentes ao programa:
    
        Frequencia: -----
        Objetivo  : Rotinas utilizadas pela tela CADDES para cadastro de desenvolvedores
    ---------------------------------------------------------------------------------------------------------------*/

    PROCEDURE pc_cadastra_desenvolvedor(pr_nrdocumento          IN tbapi_desenvolvedor.nrdocumento%TYPE
                                       ,pr_dsnome               IN tbapi_desenvolvedor.dsnome%TYPE
                                       ,pr_nrcep_endereco       IN tbapi_desenvolvedor.nrcep_endereco%TYPE
                                       ,pr_dsendereco           IN tbapi_desenvolvedor.dsendereco%TYPE
                                       ,pr_nrendereco           IN tbapi_desenvolvedor.nrendereco%TYPE
                                       ,pr_dsbairro             IN tbapi_desenvolvedor.dsbairro%TYPE
                                       ,pr_dscidade             IN tbapi_desenvolvedor.dscidade%TYPE
                                       ,pr_dsunidade_federacao  IN tbapi_desenvolvedor.dsunidade_federacao%TYPE
                                       ,pr_dsemail              IN tbapi_desenvolvedor.dsemail%TYPE
                                       ,pr_nrddd_celular        IN tbapi_desenvolvedor.nrddd_celular%TYPE
                                       ,pr_nrtelefone_celular   IN tbapi_desenvolvedor.nrtelefone_celular%TYPE
                                       ,pr_dscontato_celular    IN tbapi_desenvolvedor.dscontato_celular%TYPE
                                       ,pr_nrddd_comercial      IN tbapi_desenvolvedor.nrddd_comercial%TYPE
                                       ,pr_nrtelefone_comercial IN tbapi_desenvolvedor.nrtelefone_comercial%TYPE
                                       ,pr_dscontato_comercial  IN tbapi_desenvolvedor.dscontato_comercial%TYPE
                                       ,pr_inpessoa             IN tbapi_desenvolvedor.inpessoa%TYPE
                                       ,pr_dscomplemento        IN tbapi_desenvolvedor.dscomplemento%TYPE
                                       ,pr_xmllog               IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic             OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic             OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro             OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_consulta_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE --> codigo do desenvolvedor
                                       ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro        OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_altera_desenvolvedor(pr_cddesenvolvedor      IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                     ,pr_nrdocumento          IN tbapi_desenvolvedor.nrdocumento%TYPE
                                     ,pr_dsnome               IN tbapi_desenvolvedor.dsnome%TYPE
                                     ,pr_nrcep_endereco       IN tbapi_desenvolvedor.nrcep_endereco%TYPE
                                     ,pr_dsendereco           IN tbapi_desenvolvedor.dsendereco%TYPE
                                     ,pr_nrendereco           IN tbapi_desenvolvedor.nrendereco%TYPE
                                     ,pr_dsbairro             IN tbapi_desenvolvedor.dsbairro%TYPE
                                     ,pr_dscidade             IN tbapi_desenvolvedor.dscidade%TYPE
                                     ,pr_dsunidade_federacao  IN tbapi_desenvolvedor.dsunidade_federacao%TYPE
                                     ,pr_dsemail              IN tbapi_desenvolvedor.dsemail%TYPE
                                     ,pr_nrddd_celular        IN tbapi_desenvolvedor.nrddd_celular%TYPE
                                     ,pr_nrtelefone_celular   IN tbapi_desenvolvedor.nrtelefone_celular%TYPE
                                     ,pr_dscontato_celular    IN tbapi_desenvolvedor.dscontato_celular%TYPE
                                     ,pr_nrddd_comercial      IN tbapi_desenvolvedor.nrddd_comercial%TYPE
                                     ,pr_nrtelefone_comercial IN tbapi_desenvolvedor.nrtelefone_comercial%TYPE
                                     ,pr_dscontato_comercial  IN tbapi_desenvolvedor.dscontato_comercial%TYPE
                                     ,pr_inpessoa             IN tbapi_desenvolvedor.inpessoa%TYPE
                                     ,pr_dscomplemento        IN tbapi_desenvolvedor.dscomplemento%TYPE
                                     ,pr_dsusuario_portal     IN tbapi_desenvolvedor.dsusuario_portal%TYPE
                                     ,pr_xmllog               IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic             OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic             OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro             OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_exclui_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                     ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro        OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_pesquisa_desenvolvedor(pr_nrdocumento IN tbapi_desenvolvedor.nrdocumento%TYPE
                                       ,pr_dsempresa   IN tbapi_desenvolvedor.dsnome%TYPE
                                       ,pr_nriniseq    IN NUMBER --> Registro inicial para paginacao
                                       ,pr_nrregist    IN NUMBER --> Qtd Registro inicial para paginacao
                                       ,pr_xmllog      IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic    OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_altera_frase_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                           ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                           ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                           ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                           ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                           ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                           ,pr_des_erro        OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_envia_frase_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                          ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                          ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                          ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                          ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                          ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                          ,pr_des_erro        OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_envia_uuid_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                         ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro        OUT VARCHAR2); --> Erros do processo

    PROCEDURE pc_gera_uuid_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE --> Código do Desenvolvedor
                                        ,pr_cdcooper        IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                        ,pr_operador        IN crapope.cdoperad%TYPE --> Código do operador que está chamando
                                        ,pr_dsuuid          OUT VARCHAR2 --> UUID Gerada
                                        ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                         );

END tela_caddes;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_caddes IS
    /* ---------------------------------------------------------------------------------------------------------------
    
        Programa : TELA_CADDES
        Sistema  : Rotinas referentes a tela CADDES (CADASTRO DE DESENVOLVEDORES)
        Sigla    : CADDES
        Autor    : Andrey Formigari - Supero
        Data     : Fevereiro/2019.
    
        Dados referentes ao programa:
    
        Frequencia: -----
        Objetivo  : Rotinas utilizadas pela tela CADDES para cadastro de desenvolvedores
    ---------------------------------------------------------------------------------------------------------------*/
    PROCEDURE pc_cadastra_desenvolvedor(pr_nrdocumento          IN tbapi_desenvolvedor.nrdocumento%TYPE
                                       ,pr_dsnome               IN tbapi_desenvolvedor.dsnome%TYPE
                                       ,pr_nrcep_endereco       IN tbapi_desenvolvedor.nrcep_endereco%TYPE
                                       ,pr_dsendereco           IN tbapi_desenvolvedor.dsendereco%TYPE
                                       ,pr_nrendereco           IN tbapi_desenvolvedor.nrendereco%TYPE
                                       ,pr_dsbairro             IN tbapi_desenvolvedor.dsbairro%TYPE
                                       ,pr_dscidade             IN tbapi_desenvolvedor.dscidade%TYPE
                                       ,pr_dsunidade_federacao  IN tbapi_desenvolvedor.dsunidade_federacao%TYPE
                                       ,pr_dsemail              IN tbapi_desenvolvedor.dsemail%TYPE
                                       ,pr_nrddd_celular        IN tbapi_desenvolvedor.nrddd_celular%TYPE
                                       ,pr_nrtelefone_celular   IN tbapi_desenvolvedor.nrtelefone_celular%TYPE
                                       ,pr_dscontato_celular    IN tbapi_desenvolvedor.dscontato_celular%TYPE
                                       ,pr_nrddd_comercial      IN tbapi_desenvolvedor.nrddd_comercial%TYPE
                                       ,pr_nrtelefone_comercial IN tbapi_desenvolvedor.nrtelefone_comercial%TYPE
                                       ,pr_dscontato_comercial  IN tbapi_desenvolvedor.dscontato_comercial%TYPE
                                       ,pr_inpessoa             IN tbapi_desenvolvedor.inpessoa%TYPE
                                       ,pr_dscomplemento        IN tbapi_desenvolvedor.dscomplemento%TYPE
                                       ,pr_xmllog               IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic             OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic             OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro             OUT VARCHAR2 --> Erros do processo
                                       ) IS
        /* .............................................................................
          Programa: pc_cadastra_desenvolvedor
          Sistema : Aimaro
          Sigla   : CADDES
          Autor   : Andrey Formigari (Supero)
          Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Cadastrar um novo desenvolvedor e retornar seu código para a tela
        
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
    
        -- Variaveis internas
        vr_dsfrase           tbapi_desenvolvedor.dsfrase_desenvolvedor%TYPE;
        vr_dsuuid            VARCHAR2(36);
    
        CURSOR cr_seq_cddesenvoldedor IS
            SELECT nvl(MAX(cddesenvolvedor), 0) + 1 AS next_cddesenvolvedor FROM tbapi_desenvolvedor;
        rw_seq_cddesenvoldedor cr_seq_cddesenvoldedor%ROWTYPE;
    
        CURSOR cr_checkdoc(pr_nrdocumento tbapi_desenvolvedor.nrdocumento%TYPE
                          ,pr_inpessoa    tbapi_desenvolvedor.inpessoa%TYPE) IS
            SELECT cddesenvolvedor
                  ,inpessoa
                  ,dsnome
              FROM tbapi_desenvolvedor
             WHERE nrdocumento = pr_nrdocumento
               AND inpessoa = pr_inpessoa;
        rw_checkdoc cr_checkdoc%ROWTYPE;
    
        CURSOR cr_checkfrase_desen(pr_dsfrase_desenvolvedor tbapi_desenvolvedor.dsfrase_desenvolvedor%TYPE) IS
            SELECT cddesenvolvedor
              FROM tbapi_desenvolvedor
             WHERE dsfrase_desenvolvedor = pr_dsfrase_desenvolvedor;
        rw_checkfrase_desen cr_checkfrase_desen%ROWTYPE;
    
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
    
        OPEN cr_checkdoc(pr_nrdocumento => pr_nrdocumento, pr_inpessoa => pr_inpessoa);
        FETCH cr_checkdoc
            INTO rw_checkdoc;
    
        IF cr_checkdoc%FOUND THEN
            CLOSE cr_checkdoc;
            IF rw_checkdoc.inpessoa = 1 THEN
                vr_dscritic := 'Este CPF já está em uso por outro desenvolvedor: ' ||
                               rw_checkdoc.cddesenvolvedor || ' - ' || rw_checkdoc.dsnome;
            ELSE
                vr_dscritic := 'Este CNPJ já está em uso por outro desenvolvedor: ' ||
                               rw_checkdoc.cddesenvolvedor || ' - ' || rw_checkdoc.dsnome;
            END IF;
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_checkdoc;
    
        OPEN cr_seq_cddesenvoldedor;
        FETCH cr_seq_cddesenvoldedor
            INTO rw_seq_cddesenvoldedor;
        CLOSE cr_seq_cddesenvoldedor;
    
        WHILE TRUE LOOP
            apis0001.pc_gerar_frase(pr_dsfrase => vr_dsfrase);
        
            OPEN cr_checkfrase_desen(pr_dsfrase_desenvolvedor => vr_dsfrase);
            FETCH cr_checkfrase_desen
                INTO rw_checkfrase_desen;
        
            IF cr_checkfrase_desen%NOTFOUND THEN
                EXIT;
            END IF;
            CLOSE cr_checkfrase_desen;
        
        END LOOP;
        CLOSE cr_checkfrase_desen;
    
        BEGIN
            INSERT INTO tbapi_desenvolvedor
                (cddesenvolvedor
                ,inpessoa
                ,nrdocumento
                ,dsnome
                ,nrcep_endereco
                ,dsendereco
                ,nrendereco
                ,dsbairro
                ,dscidade
                ,dsunidade_federacao
                ,dsemail
                ,nrddd_celular
                ,nrtelefone_celular
                ,dscontato_celular
                ,nrddd_comercial
                ,nrtelefone_comercial
                ,dscontato_comercial
                ,cdoperador
                ,dtalteracao
                ,dsfrase_desenvolvedor
                ,dtfrase_desenvolvedor
                ,dscomplemento)
            VALUES
                (rw_seq_cddesenvoldedor.next_cddesenvolvedor
                ,pr_inpessoa
                ,pr_nrdocumento
                ,pr_dsnome
                ,pr_nrcep_endereco
                ,pr_dsendereco
                ,pr_nrendereco
                ,pr_dsbairro
                ,pr_dscidade
                ,pr_dsunidade_federacao
                ,pr_dsemail
                ,pr_nrddd_celular
                ,pr_nrtelefone_celular
                ,pr_dscontato_celular
                ,pr_nrddd_comercial
                ,pr_nrtelefone_comercial
                ,pr_dscontato_comercial
                ,vr_cdoperad
                ,SYSDATE
                ,vr_dsfrase
                ,SYSDATE
                ,pr_dscomplemento);
        EXCEPTION
            WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao cadastrar o desenvolvedor: ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
        pc_gera_uuid_desenvolvedor(pr_cddesenvolvedor => rw_seq_cddesenvoldedor.next_cddesenvolvedor
                                  ,pr_cdcooper        => vr_cdcooper
                                  ,pr_operador        => vr_cdoperad
                                  ,pr_dsuuid          => vr_dsuuid
                                  ,pr_cdcritic        => vr_cdcritic
                                  ,pr_dscritic        => vr_dscritic);
    
        IF TRIM(vr_dscritic) IS NOT NULL THEN
            vr_dscritic := 'Não foi possível gerar o UUID, tente novamente.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
    
        -- Se chegou até aqui commit, pois pode ocorrer algum erro no envio de e-mail e abortar todo processo.
        COMMIT;
    
        -- Se e-mail é valido, envia.
        IF gene0003.fn_valida_email(pr_dsemail) = 1 THEN
        
            tela_caddes.pc_envia_frase_desenvolvedor(pr_cddesenvolvedor => rw_seq_cddesenvoldedor.next_cddesenvolvedor
                                                    ,pr_xmllog          => ''
                                                    ,pr_cdcritic        => vr_cdcritic
                                                    ,pr_dscritic        => vr_dscritic
                                                    ,pr_retxml          => pr_retxml
                                                    ,pr_nmdcampo        => pr_nmdcampo
                                                    ,pr_des_erro        => pr_des_erro);
        
            IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'O desenvolvedor foi cadastrado com sucesso, mas não foi possível enviar a frase por e-mail. Cadastre um e-mail válido e tente enviar manualmente.';
                vr_cdcritic := 0;
                RAISE vr_exc_saida;
            END IF;
        
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
                              ,pr_tag_nova => 'cddesenvolvedor'
                              ,pr_tag_cont => rw_seq_cddesenvoldedor.next_cddesenvolvedor
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsfrase'
                              ,pr_tag_cont => vr_dsfrase
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsuuid'
                              ,pr_tag_cont => vr_dsuuid
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
        
            ROLLBACK;
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_CADDES.pc_cadastra_desenvolvedor. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
            ROLLBACK;
    END pc_cadastra_desenvolvedor;

    PROCEDURE pc_consulta_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE --> codigo do desenvolvedor
                                       ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro        OUT VARCHAR2 --> Erros do processo
                                       ) IS
        /* .............................................................................
          Programa: pc_consulta_desenvolvedor
          Sistema : Aimaro
          Sigla   : CADDES
          Autor   : Andrey Formigari (Supero)
          Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Retornar os dados do desenvolvedor.
        
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
    
        -- Variaveis internas
        vr_dsuuidds VARCHAR2(36);
    
        CURSOR cr_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE) IS
            SELECT * FROM tbapi_desenvolvedor td WHERE td.cddesenvolvedor = pr_cddesenvolvedor;
        rw_desenvolvedor cr_desenvolvedor%ROWTYPE;
    
    
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
                              ,pr_tag_nova => 'Desenvolvedor'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        OPEN cr_desenvolvedor(pr_cddesenvolvedor => pr_cddesenvolvedor);
        FETCH cr_desenvolvedor
            INTO rw_desenvolvedor;
    
        IF cr_desenvolvedor%NOTFOUND THEN
            CLOSE cr_desenvolvedor;
            vr_dscritic := 'Nenhum desenvolvedor encontrado com o código informado.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_desenvolvedor;
    
        apis0001.pc_busca_identif_desenv(pr_cddesenv => pr_cddesenvolvedor
                                        ,pr_inpessoa => ''
                                        ,pr_nrdocdsv => ''
                                        ,pr_idformat => 1
                                        ,pr_dsuuidds => vr_dsuuidds);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cddesenvolvedor'
                              ,pr_tag_cont => rw_desenvolvedor.cddesenvolvedor
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'inpessoa'
                              ,pr_tag_cont => rw_desenvolvedor.inpessoa
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrdocumento'
                              ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_desenvolvedor.nrdocumento
                                                                       ,rw_desenvolvedor.inpessoa)
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsnome'
                              ,pr_tag_cont => rw_desenvolvedor.dsnome
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrcep_endereco'
                              ,pr_tag_cont => rw_desenvolvedor.nrcep_endereco
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsendereco'
                              ,pr_tag_cont => rw_desenvolvedor.dsendereco
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrendereco'
                              ,pr_tag_cont => rw_desenvolvedor.nrendereco
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrendereco'
                              ,pr_tag_cont => rw_desenvolvedor.nrendereco
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscomplemento'
                              ,pr_tag_cont => rw_desenvolvedor.dscomplemento
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsbairro'
                              ,pr_tag_cont => rw_desenvolvedor.dsbairro
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscidade'
                              ,pr_tag_cont => rw_desenvolvedor.dscidade
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsunidade_federacao'
                              ,pr_tag_cont => rw_desenvolvedor.dsunidade_federacao
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsemail'
                              ,pr_tag_cont => rw_desenvolvedor.dsemail
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrddd_celular'
                              ,pr_tag_cont => rw_desenvolvedor.nrddd_celular
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrtelefone_celular'
                              ,pr_tag_cont => rw_desenvolvedor.nrtelefone_celular
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscontato_celular'
                              ,pr_tag_cont => rw_desenvolvedor.dscontato_celular
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrddd_comercial'
                              ,pr_tag_cont => rw_desenvolvedor.nrddd_comercial
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrtelefone_comercial'
                              ,pr_tag_cont => rw_desenvolvedor.nrtelefone_comercial
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscontato_comercial'
                              ,pr_tag_cont => rw_desenvolvedor.dscontato_comercial
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsfrase_desenvolvedor'
                              ,pr_tag_cont => rw_desenvolvedor.dsfrase_desenvolvedor
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsusuario_portal'
                              ,pr_tag_cont => rw_desenvolvedor.dsusuario_portal
                              ,pr_des_erro => vr_dscritic);
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Desenvolvedor'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dschave'
                              ,pr_tag_cont => vr_dsuuidds
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
        
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_CADDES.pc_detalhe_solicitacao_retorno. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_consulta_desenvolvedor;

    PROCEDURE pc_altera_desenvolvedor(pr_cddesenvolvedor      IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                     ,pr_nrdocumento          IN tbapi_desenvolvedor.nrdocumento%TYPE
                                     ,pr_dsnome               IN tbapi_desenvolvedor.dsnome%TYPE
                                     ,pr_nrcep_endereco       IN tbapi_desenvolvedor.nrcep_endereco%TYPE
                                     ,pr_dsendereco           IN tbapi_desenvolvedor.dsendereco%TYPE
                                     ,pr_nrendereco           IN tbapi_desenvolvedor.nrendereco%TYPE
                                     ,pr_dsbairro             IN tbapi_desenvolvedor.dsbairro%TYPE
                                     ,pr_dscidade             IN tbapi_desenvolvedor.dscidade%TYPE
                                     ,pr_dsunidade_federacao  IN tbapi_desenvolvedor.dsunidade_federacao%TYPE
                                     ,pr_dsemail              IN tbapi_desenvolvedor.dsemail%TYPE
                                     ,pr_nrddd_celular        IN tbapi_desenvolvedor.nrddd_celular%TYPE
                                     ,pr_nrtelefone_celular   IN tbapi_desenvolvedor.nrtelefone_celular%TYPE
                                     ,pr_dscontato_celular    IN tbapi_desenvolvedor.dscontato_celular%TYPE
                                     ,pr_nrddd_comercial      IN tbapi_desenvolvedor.nrddd_comercial%TYPE
                                     ,pr_nrtelefone_comercial IN tbapi_desenvolvedor.nrtelefone_comercial%TYPE
                                     ,pr_dscontato_comercial  IN tbapi_desenvolvedor.dscontato_comercial%TYPE
                                     ,pr_inpessoa             IN tbapi_desenvolvedor.inpessoa%TYPE
                                     ,pr_dscomplemento        IN tbapi_desenvolvedor.dscomplemento%TYPE
                                     ,pr_dsusuario_portal     IN tbapi_desenvolvedor.dsusuario_portal%TYPE
                                     ,pr_xmllog               IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic             OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic             OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml               IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro             OUT VARCHAR2 --> Erros do processo
                                     ) IS
        /* .............................................................................
          Programa: pc_consulta_desenvolvedor
          Sistema : Aimaro
          Sigla   : CADDES
          Autor   : Andrey Formigari (Supero)
          Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Alterar informações de um desenvolvedor
        
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
    
        -- Variaveis internas
    
        CURSOR cr_checkdoc(pr_nrdocumento     tbapi_desenvolvedor.nrdocumento%TYPE
                          ,pr_cddesenvolvedor tbapi_desenvolvedor.cddesenvolvedor%TYPE
                          ,pr_inpessoa        tbapi_desenvolvedor.inpessoa%TYPE) IS
            SELECT cddesenvolvedor
                  ,inpessoa
                  ,dsnome
              FROM tbapi_desenvolvedor
             WHERE nrdocumento = pr_nrdocumento
               AND pr_cddesenvolvedor <> cddesenvolvedor
               AND inpessoa = pr_inpessoa;
        rw_checkdoc cr_checkdoc%ROWTYPE;
    
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
    
        OPEN cr_checkdoc(pr_nrdocumento     => pr_nrdocumento
                        ,pr_cddesenvolvedor => pr_cddesenvolvedor
                        ,pr_inpessoa        => pr_inpessoa);
        FETCH cr_checkdoc
            INTO rw_checkdoc;
    
        IF cr_checkdoc%FOUND THEN
            CLOSE cr_checkdoc;
            IF rw_checkdoc.inpessoa = 1 THEN
                vr_dscritic := 'Este CPF já está em uso por outro desenvolvedor: ' ||
                               rw_checkdoc.cddesenvolvedor || ' - ' || rw_checkdoc.dsnome;
            ELSE
                vr_dscritic := 'Este CNPJ já está em uso por outro desenvolvedor: ' ||
                               rw_checkdoc.cddesenvolvedor || ' - ' || rw_checkdoc.dsnome;
            END IF;
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_checkdoc;
    
        BEGIN
            UPDATE tbapi_desenvolvedor
               SET inpessoa             = pr_inpessoa
                  ,nrdocumento          = pr_nrdocumento
                  ,dsnome               = pr_dsnome
                  ,nrcep_endereco       = pr_nrcep_endereco
                  ,dsendereco           = pr_dsendereco
                  ,nrendereco           = pr_nrendereco
                  ,dsbairro             = pr_dsbairro
                  ,dscidade             = pr_dscidade
                  ,dsunidade_federacao  = pr_dsunidade_federacao
                  ,dsemail              = pr_dsemail
                  ,nrddd_celular        = pr_nrddd_celular
                  ,nrtelefone_celular   = pr_nrtelefone_celular
                  ,dscontato_celular    = pr_dscontato_celular
                  ,nrddd_comercial      = pr_nrddd_comercial
                  ,nrtelefone_comercial = pr_nrtelefone_comercial
                  ,dscontato_comercial  = pr_dscontato_comercial
                  ,cdoperador           = vr_cdoperad
                  ,dtalteracao          = SYSDATE
                  ,dscomplemento        = pr_dscomplemento
                  ,dsusuario_portal     = pr_dsusuario_portal
             WHERE cddesenvolvedor = pr_cddesenvolvedor;
        EXCEPTION
            WHEN OTHERS THEN
                vr_dscritic := 'Erro ao alterar o desenvolvedor na tbapi_desenvolvedor: ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
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
            pr_dscritic := 'Erro geral na rotina na procedure TELA_CADDES.pc_cadastra_desenvolvedor. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_altera_desenvolvedor;

    PROCEDURE pc_exclui_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                     ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro        OUT VARCHAR2 --> Erros do processo
                                     ) IS
        /* .............................................................................
          Programa: pc_exclui_desenvolvedor
          Sistema : Aimaro
          Sigla   : CADDES
          Autor   : Andrey Formigari (Supero)
          Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Exclusão de desenvolvedor
        
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
    
        CURSOR cr_checkdesen(pr_cddesenvolvedor tbapi_desenvolvedor.cddesenvolvedor%TYPE) IS
            SELECT cddesenvolvedor FROM tbapi_desenvolvedor WHERE cddesenvolvedor = pr_cddesenvolvedor;
        rw_checkdesen cr_checkdesen%ROWTYPE;
    
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
    
        OPEN cr_checkdesen(pr_cddesenvolvedor => pr_cddesenvolvedor);
        FETCH cr_checkdesen
            INTO rw_checkdesen;
    
        IF cr_checkdesen%NOTFOUND THEN
            CLOSE cr_checkdesen;
            vr_dscritic := 'Nenhum desenvolvedor encontrado com o código informado.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_checkdesen;
    
        BEGIN
            DELETE tbapi_acesso_desenvolvedor WHERE cddesenvolvedor = pr_cddesenvolvedor;
            DELETE tbapi_desenvolvedor WHERE cddesenvolvedor = pr_cddesenvolvedor;
        EXCEPTION
            WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Este desenvolvedor encontra-se vinculado a um cooperado, por este motivo, não pode ser excluído.';
                RAISE vr_exc_saida;
        END;
    
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
            pr_dscritic := 'Erro geral na rotina na procedure TELA_CADDES.pc_exclui_desenvolvedor. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_exclui_desenvolvedor;

    PROCEDURE pc_pesquisa_desenvolvedor(pr_nrdocumento IN tbapi_desenvolvedor.nrdocumento%TYPE
                                       ,pr_dsempresa   IN tbapi_desenvolvedor.dsnome%TYPE
                                       ,pr_nriniseq    IN NUMBER --> Registro inicial para paginacao
                                       ,pr_nrregist    IN NUMBER --> Qtd Registro inicial para paginacao
                                       ,pr_xmllog      IN VARCHAR2 --> XML com informações de LOG
                                       ,pr_cdcritic    OUT PLS_INTEGER --> Código da crítica
                                       ,pr_dscritic    OUT VARCHAR2 --> Descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro    OUT VARCHAR2--> Erros do processo
                                       ) IS
        /* .............................................................................
        
          Programa: pc_pesquisa_desenvolvedor
          Sistema : Aimaro
          Sigla   : CADDES
          Autor   : Andrey Formigari (Supero)
          Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Rotina retorna lista de desenvolvedores
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        ----------------------------- VARIAVEIS ---------------------------------
        vr_cdcritic NUMBER := 0;
    
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        vr_cont_tag INTEGER := 0;
        vr_qtregist INTEGER := 0;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper INTEGER;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        ---------------------------- CURSORES -----------------------------------
        CURSOR cr_desenvolvedor(pr_nrdocumento tbapi_desenvolvedor.nrdocumento%TYPE
                               ,pr_dsempresa   tbapi_desenvolvedor.dsnome%TYPE
                               ,pr_nriniseq    NUMBER
                               ,pr_nrregist    NUMBER) IS
            SELECT *
              FROM (SELECT td.cddesenvolvedor
                          ,td.dsnome
                          ,td.nrdocumento
                          ,td.nrddd_celular
                          ,td.nrtelefone_celular
                          ,td.nrddd_comercial
                          ,td.nrtelefone_comercial
                          ,td.dscontato_celular
                          ,td.dscontato_comercial
                          ,td.dsemail
                          ,td.inpessoa
                          ,COUNT(*) over() qtregtot
                          ,row_number() over(ORDER BY td.cddesenvolvedor) rnum
                      FROM tbapi_desenvolvedor td
                     WHERE td.nrdocumento LIKE '%' || nvl(pr_nrdocumento, td.nrdocumento) || '%'
                       AND upper(td.dsnome) LIKE '%' || upper(pr_dsempresa) || '%'
                     ORDER BY td.cddesenvolvedor)
             WHERE (rnum >= pr_nriniseq AND rnum <= (pr_nriniseq + pr_nrregist - 1))
                OR pr_nrregist = 0;
        rw_desenvolvedor cr_desenvolvedor%ROWTYPE;
    
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
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        -- Abre cursor para atribuir os registros encontrados na PL/Table
        FOR rw_desenvolvedor IN cr_desenvolvedor(pr_nrdocumento => pr_nrdocumento
                                                ,pr_dsempresa   => pr_dsempresa
                                                ,pr_nriniseq    => pr_nriniseq
                                                ,pr_nrregist    => pr_nrregist) LOOP
        
            vr_qtregist := rw_desenvolvedor.qtregtot;
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'inf'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_cont_tag
                                  ,pr_tag_nova => 'cddesenvolvedor'
                                  ,pr_tag_cont => rw_desenvolvedor.cddesenvolvedor
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_cont_tag
                                  ,pr_tag_nova => 'dsnome'
                                  ,pr_tag_cont => rw_desenvolvedor.dsnome
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_cont_tag
                                  ,pr_tag_nova => 'nrdocumento'
                                  ,pr_tag_cont => gene0002.fn_mask_cpf_cnpj(rw_desenvolvedor.nrdocumento
                                                                           ,rw_desenvolvedor.inpessoa)
                                  ,pr_des_erro => vr_dscritic);
        
            IF TRIM(rw_desenvolvedor.nrtelefone_comercial) IS NOT NULL THEN
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_cont_tag
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
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_cont_tag
                                      ,pr_tag_nova => 'nrtelefone'
                                      ,pr_tag_cont => CASE
                                                          WHEN TRIM(rw_desenvolvedor.nrddd_celular) IS NOT NULL THEN
                                                           '(' || rw_desenvolvedor.nrddd_celular || ')' ||
                                                           rw_desenvolvedor.nrtelefone_celular
                                                          ELSE
                                                           ''
                                                      END
                                      ,pr_des_erro => vr_dscritic);
            END IF;
        
            IF TRIM(rw_desenvolvedor.dscontato_comercial) IS NOT NULL THEN
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_cont_tag
                                      ,pr_tag_nova => 'dscontato'
                                      ,pr_tag_cont => rw_desenvolvedor.dscontato_comercial
                                      ,pr_des_erro => vr_dscritic);
            ELSE
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_cont_tag
                                      ,pr_tag_nova => 'dscontato'
                                      ,pr_tag_cont => rw_desenvolvedor.dscontato_celular
                                      ,pr_des_erro => vr_dscritic);
            END IF;
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_cont_tag
                                  ,pr_tag_nova => 'dsemail'
                                  ,pr_tag_cont => rw_desenvolvedor.dsemail
                                  ,pr_des_erro => vr_dscritic);
        
            -- Incrementa o contador de tags
            vr_cont_tag := vr_cont_tag + 1;
        
        END LOOP;
    
        -- Insere atributo na tag Dados com a quantidade de registros
        gene0007.pc_gera_atributo(pr_xml      => pr_retxml --> XML que irá receber o novo atributo
                                 ,pr_tag      => 'Dados' --> Nome da TAG XML
                                 ,pr_atrib    => 'qtregist' --> Nome do atributo
                                 ,pr_atval    => vr_qtregist --> Valor do atributo
                                 ,pr_numva    => 0 --> Número da localização da TAG na árvore XML
                                 ,pr_des_erro => vr_dscritic); --> Descrição de erros
    
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
            pr_dscritic := 'Erro geral na rotina na procedure TELA_CADDES.pc_pesquisa_desenvolvedor. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
    END pc_pesquisa_desenvolvedor;

    PROCEDURE pc_altera_frase_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                           ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                           ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                           ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                           ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                           ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                           ,pr_des_erro        OUT VARCHAR2--> Erros do processo
                                           ) IS
        /* .............................................................................
          Programa: pc_altera_frase_desenvolvedor
          Sistema : Aimaro
          Sigla   : CADDES
          Autor   : Andrey Formigari (Supero)
          Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Gerar uma nova frase para o desenvolvedor
        
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
        vr_dsfrase  tbapi_desenvolvedor.dsfrase_desenvolvedor%TYPE;
    
        CURSOR cr_checkdesen(pr_cddesenvolvedor tbapi_desenvolvedor.cddesenvolvedor%TYPE) IS
            SELECT dsfrase_desenvolvedor FROM tbapi_desenvolvedor WHERE cddesenvolvedor = pr_cddesenvolvedor;
        rw_checkdesen cr_checkdesen%ROWTYPE;
    
        CURSOR cr_checkfrase_desen(pr_dsfrase_desenvolvedor tbapi_desenvolvedor.dsfrase_desenvolvedor%TYPE) IS
            SELECT cddesenvolvedor
              FROM tbapi_desenvolvedor
             WHERE dsfrase_desenvolvedor = pr_dsfrase_desenvolvedor;
        rw_checkfrase_desen cr_checkfrase_desen%ROWTYPE;
    
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
    
        OPEN cr_checkdesen(pr_cddesenvolvedor => pr_cddesenvolvedor);
        FETCH cr_checkdesen
            INTO rw_checkdesen;
    
        IF cr_checkdesen%NOTFOUND THEN
            CLOSE cr_checkdesen;
            vr_dscritic := 'Nenhum desenvolvedor encontrado com o código informado.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_checkdesen;
    
        WHILE TRUE LOOP
            apis0001.pc_gerar_frase(pr_dsfrase => vr_dsfrase);
        
            OPEN cr_checkfrase_desen(pr_dsfrase_desenvolvedor => vr_dsfrase);
            FETCH cr_checkfrase_desen
                INTO rw_checkfrase_desen;
        
            IF cr_checkfrase_desen%NOTFOUND THEN
                EXIT;
            END IF;
            CLOSE cr_checkfrase_desen;
        
        END LOOP;
        CLOSE cr_checkfrase_desen;
    
        BEGIN
            UPDATE tbapi_desenvolvedor
               SET dsfrase_desenvolvedor = vr_dsfrase, dtfrase_desenvolvedor = SYSDATE
             WHERE cddesenvolvedor = pr_cddesenvolvedor;
        EXCEPTION
            WHEN OTHERS THEN
                vr_dscritic := 'Erro ao alterar a frase do desenvolvedor na tbapi_desenvolvedor: ' || SQLERRM;
                RAISE vr_exc_saida;
        END;
    
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
                              ,pr_tag_nova => 'dsfrase'
                              ,pr_tag_cont => vr_dsfrase
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
            pr_dscritic := 'Erro geral na rotina na procedure TELA_CADDES.pc_cadastra_desenvolvedor. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_altera_frase_desenvolvedor;

    PROCEDURE pc_envia_frase_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                          ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                          ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                          ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                          ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                          ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                          ,pr_des_erro        OUT VARCHAR2--> Erros do processo
                                          ) IS
        /* .............................................................................
          Programa: pc_envia_frase_desenvolvedor
          Sistema : Aimaro
          Sigla   : CADDES
          Autor   : Andrey Formigari (Supero)
          Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Enviar frase do desenvolvedor por e-mail
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
    
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper    INTEGER;
        vr_cdoperad    VARCHAR2(100);
        vr_nmdatela    VARCHAR2(100);
        vr_nmeacao     VARCHAR2(100);
        vr_cdagenci    VARCHAR2(100);
        vr_nrdcaixa    VARCHAR2(100);
        vr_idorigem    VARCHAR2(100);
        vr_texto_email VARCHAR2(4000);
        vr_nmrescop    crapcop.nmrescop%TYPE; -- Razao Social da cooperativa
        vr_nmextcop    crapcop.nmextcop%TYPE; -- Nome da cooperativa
        vr_nrdocnpj    crapcop.nrdocnpj%TYPE; -- CNPJ da cooperativa
        vr_dsmanual    VARCHAR2(4000);
        vr_dsdirmnl    VARCHAR2(100);
    
        CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT nmrescop
                  ,nmextcop
                  ,nrdocnpj
              FROM crapcop
             WHERE cdcooper = pr_cdcooper;
    
        CURSOR cr_checkdesen(pr_cddesenvolvedor tbapi_desenvolvedor.cddesenvolvedor%TYPE) IS
            SELECT dsfrase_desenvolvedor
                  ,dsemail
                  ,dsnome
                  ,nrdocumento
                  ,inpessoa
              FROM tbapi_desenvolvedor
             WHERE cddesenvolvedor = pr_cddesenvolvedor;
        rw_checkdesen cr_checkdesen%ROWTYPE;
    
        -- Buscar os manuais a serem enviados 
        CURSOR cr_craptab IS 
          SELECT tab.dstextab
            FROM craptab tab
           WHERE tab.nmsistem = 'CRED'
             AND tab.tptabela = 'GENERI'
             AND tab.cdempres = 0
             AND tab.cdacesso = 'MANUAL_UTILIZA_API';
             
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
        FETCH cr_crapcop
            INTO vr_nmrescop
                ,vr_nmextcop
                ,vr_nrdocnpj;
        IF cr_crapcop%NOTFOUND THEN
            CLOSE cr_crapcop;
            vr_dscritic := 'Cooperativa não encontrada.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcop;
    
        OPEN cr_checkdesen(pr_cddesenvolvedor => pr_cddesenvolvedor);
        FETCH cr_checkdesen
            INTO rw_checkdesen;
    
        IF cr_checkdesen%NOTFOUND THEN
            CLOSE cr_checkdesen;
            vr_dscritic := 'Nenhum desenvolvedor encontrado com o código informado.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_checkdesen;
    
        IF gene0003.fn_valida_email(rw_checkdesen.dsemail) <> 1 THEN
            vr_dscritic := 'O e-mail do desenvolvedor está inválido para enviar a frase.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
    
        -- Busca o diretório onde estão diponibilizados os manuais
        vr_dsdirmnl := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                            ,pr_cdcooper => 3); -- Os manuais ficam no micros da central
                                            
        -- Adicionar o subdiretório
        vr_dsdirmnl := vr_dsdirmnl || '/API/manualAPI/';
        
        -- Limpar
        vr_dsmanual := NULL;
        
        -- Percorrer os manuais cadastrados 
        FOR rg_craptab IN cr_craptab LOOP
          -- Adicionar os manuais separados por ";"
          IF vr_dsmanual IS NULL THEN
            vr_dsmanual := vr_dsdirmnl||rg_craptab.dstextab;
          ELSE
            vr_dsmanual := vr_dsmanual||';'||vr_dsdirmnl||rg_craptab.dstextab;
          END IF;
        END LOOP;
    
        vr_texto_email := '<html style="font-size: 10pt; font-family: Tahoma,Verdana,Arial;">' ||
                          'Caro desenvolvedor,' || '<br />' || '<br />' ||
                          'Um de seus clientes solicitou a integra&ccedil;&atilde;o do seu sistema com a API do Sistema Ailos.<br />' ||
                          'Estamos disponibilizando em anexo os Manuais T&eacute;cnicos para que voc&ecirc; possa realizar as configura&ccedil;&otilde;es necess&aacute;rias para utiliza&ccedil;&atilde;o das APIs.<br />' ||
                          '<br />' || 
                          'Em breve voc&ecirc; estar&aacute; recebendo um e-mail da <u>Equipe de Homologa&ccedil;&atilde;o</u> com os acessos necess&aacute;rios para implementa&ccedil;&atilde;o da API no ambiente <strong>Sandbox</strong> junto a seu protocolo de atendimento.' ||
                          '<br /><br />' ||
                          'Ap&oacute;s a implementa&ccedil;&atilde;o da API em seu sistema, entre em contato com a <u>Equipe de Homologa&ccedil;&atilde;o</u> da Ailos e informe o c&oacute;digo abaixo junto ao protocolo de atendimento, para realizarmos a valida&ccedil;&atilde;o cadastral e disponibilizarmos os acessos de Produ&ccedil;&atilde;o.' ||
                          '<br /><br />' ||
                          'C&oacute;digo do Desenvolvedor: <strong style="font-size: 16pt; font-family: Sans-serif,Arial,Tahoma,Arial;">' ||
                          rw_checkdesen.dsfrase_desenvolvedor || '</strong>' || '<br />' || '<br />' ||
                          'Atenciosamente,' || '<br />____________________________<br />' ||
                          '<strong style="font-size: 10pt; font-family: Verdana,Tahoma,Arial; color: darkblue;">Cobran&ccedil;a Banc&aacute;ria</strong>' ||
                          '<br />' ||
                          '<span style="font-size: 8pt; font-family: Tahoma,Verdana,Arial;color: rgb(68,114,196);">Tel.: (47) 3231-4196' ||
                          '<br />Sistema de Cooperativas de Cr&eacute;dito - <strong>AILOS</strong></span>' ||
                          '<br />' || '<br />' ||
                          '<img src="https://www.viacredi.coop.br/static/images/logo-cecred.png" width="202px" style="margin-top: -10px; margin-left: -30px;">' ||
                          '</html>';
    
        -- Comando para enviar e-mail para o Jurídico
        gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper --> Cooperativa conectada
                                  ,pr_cdprogra        => 'CADDES' --> Programa conectado
                                  ,pr_des_destino     => rw_checkdesen.dsemail --> Um ou mais detinatários separados por ';' ou ','
                                  ,pr_des_assunto     => 'Frase do Desenvolvedor' --> Assunto do e-mail
                                  ,pr_des_corpo       => vr_texto_email --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => vr_dsmanual --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_log_batch   => 'N' --> Incluir no log a informação do anexo?
                                  ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
    
        IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
    
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
            pr_dscritic := 'Erro geral na rotina na procedure TELA_CADDES.pc_envia_frase_desenvolvedor. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_envia_frase_desenvolvedor;

    PROCEDURE pc_envia_uuid_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE
                                         ,pr_xmllog          IN VARCHAR2 --> XML com informações de LOG
                                         ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml          IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo        OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro        OUT VARCHAR2 --> Erros do processo
                                         ) IS
        /* .............................................................................
          Programa: pc_envia_uuid_desenvolvedor
          Sistema : Aimaro
          Sigla   : CADDES
          Autor   : Andrey Formigari (Supero)
          Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Enviar Chave de Acesso UUID do desenvolvedor por e-mail
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
    
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
        vr_cdcooper    INTEGER;
        vr_cdoperad    VARCHAR2(100);
        vr_nmdatela    VARCHAR2(100);
        vr_nmeacao     VARCHAR2(100);
        vr_cdagenci    VARCHAR2(100);
        vr_nrdcaixa    VARCHAR2(100);
        vr_idorigem    VARCHAR2(100);
        vr_texto_email VARCHAR2(4000);
        vr_nmrescop    crapcop.nmrescop%TYPE; -- Razao Social da cooperativa
        vr_dsuuidds    VARCHAR2(36);
    
        CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT nmrescop FROM crapcop WHERE cdcooper = pr_cdcooper;
    
        CURSOR cr_checkdesen(pr_cddesenvolvedor tbapi_desenvolvedor.cddesenvolvedor%TYPE) IS
            SELECT dsfrase_desenvolvedor
                  ,dsemail
                  ,dsnome
                  ,nrdocumento
                  ,inpessoa
              FROM tbapi_desenvolvedor
             WHERE cddesenvolvedor = pr_cddesenvolvedor;
        rw_checkdesen cr_checkdesen%ROWTYPE;
    
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
        FETCH cr_crapcop
            INTO vr_nmrescop;
        IF cr_crapcop%NOTFOUND THEN
            CLOSE cr_crapcop;
            vr_dscritic := 'Cooperativa não encontrada.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcop;
    
        OPEN cr_checkdesen(pr_cddesenvolvedor => pr_cddesenvolvedor);
        FETCH cr_checkdesen
            INTO rw_checkdesen;
    
        IF cr_checkdesen%NOTFOUND THEN
            CLOSE cr_checkdesen;
            vr_dscritic := 'Nenhum desenvolvedor encontrado com o código informado.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_checkdesen;
    
        IF gene0003.fn_valida_email(rw_checkdesen.dsemail) <> 1 THEN
            vr_dscritic := 'O e-mail do desenvolvedor está inválido para enviar a UUID.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
    
        apis0001.pc_busca_identif_desenv(pr_cddesenv => pr_cddesenvolvedor
                                        ,pr_inpessoa => ''
                                        ,pr_nrdocdsv => ''
                                        ,pr_idformat => 1
                                        ,pr_dsuuidds => vr_dsuuidds);
    
        IF TRIM(vr_dsuuidds) IS NULL THEN
            vr_dscritic := 'Chave da UUID não foi gerada ainda.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
    
        vr_texto_email := '<html style="font-size: 10pt; font-family: Tahoma,Verdana,Arial;">' ||
                          'Caro Desenvolvedor!' || '<br />' ||
                          '<br />Conforme contato realizado com o n&uacute;cleo de Cobran&ccedil;a Banc&aacute;ria de nossa central, estamos lhe enviando a chave de acesso UUID.' ||
                          '<br />Essa chave &eacute; necess&aacute;ria para realizar a integra&ccedil;&atilde;o de seu sistema com a API do Sistema Ailos.' ||
                          '<br />' ||
                          '<br />Chave UUID: <strong style="font-size: 14pt; font-family: Courier New,Tahoma,Arial;">' ||
                          vr_dsuuidds || '</strong>' || '<br />' ||
                          '<br />Lembramos que essa chave &eacute; de uso exclusivo e restrito do desenvolvedor.' ||
                          '<br />' || '<br />Atenciosamente,' || '<br />____________________________' ||
                          '<br />' ||
                          '<strong style="font-size: 10pt; font-family: Verdana,Tahoma,Arial; color: darkblue;">Cobran&ccedil;a Banc&aacute;ria</strong>' ||
                          '<br /><span style="font-size: 8pt; font-family: Tahoma,Verdana,Arial;color: rgb(68,114,196);">Tel.: (47) 3231-4196<br />Sistema de Cooperativas de Cr&eacute;dito - <strong>AILOS</strong></span>' ||
                          '<br />' || '<br />' ||
                          '<img src="https://www.viacredi.coop.br/static/images/logo-cecred.png" width="202px" style="margin-top: -10px; margin-left: -30px;">' ||
                          '</html>';
    
        -- Comando para enviar e-mail para o Jurídico
        gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper --> Cooperativa conectada
                                  ,pr_cdprogra        => 'CADDES' --> Programa conectado
                                  ,pr_des_destino     => rw_checkdesen.dsemail --> Um ou mais detinatários separados por ';' ou ','
                                  ,pr_des_assunto     => 'UUID do Desenvolvedor' --> Assunto do e-mail
                                  ,pr_des_corpo       => vr_texto_email --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => NULL --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                  ,pr_flg_log_batch   => 'N' --> Incluir no log a informação do anexo?
                                  ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
    
        IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
    
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
            pr_dscritic := 'Erro geral na rotina na procedure TELA_CADDES.pc_envia_uuid_desenvolvedor. Erro: ' ||
                           SQLERRM;
            pr_des_erro := 'NOK';
            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
    END pc_envia_uuid_desenvolvedor;

    PROCEDURE pc_gera_uuid_desenvolvedor(pr_cddesenvolvedor IN tbapi_desenvolvedor.cddesenvolvedor%TYPE --> Código do Desenvolvedor
                                        ,pr_cdcooper        IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                        ,pr_operador        IN crapope.cdoperad%TYPE --> Código do operador que está chamando
                                        ,pr_dsuuid          OUT VARCHAR2 --> UUID Gerada
                                        ,pr_cdcritic        OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic        OUT VARCHAR2 --> Descrição da crítica
                                         ) IS
        /* .............................................................................
          Programa: pc_gera_uuid_desenvolvedor
          Sistema : Aimaro
          Sigla   : CADDES
          Autor   : Andrey Formigari (Supero)
          Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Gerar Chave de Acesso UUID do desenvolvedor
        
          Observacao: -----
        
          Alteracoes:
        ..............................................................................*/
    
        -- Tratamento de erros
        vr_cdcritic NUMBER := 0;
    
        vr_dscritic VARCHAR2(4000);
        vr_exc_saida EXCEPTION;
    
        -- Variaveis retornadas da gene0004.pc_extrai_dados
    
        CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT 1 FROM crapcop WHERE cdcooper = pr_cdcooper;
    
        CURSOR cr_checkdesen(pr_cddesenvolvedor tbapi_desenvolvedor.cddesenvolvedor%TYPE) IS
            SELECT nrdocumento
                  ,inpessoa
              FROM tbapi_desenvolvedor
             WHERE cddesenvolvedor = pr_cddesenvolvedor;
        rw_checkdesen cr_checkdesen%ROWTYPE;
    
    BEGIN
    
        OPEN cr_crapcop(pr_cdcooper);
        IF cr_crapcop%NOTFOUND THEN
            CLOSE cr_crapcop;
            vr_dscritic := 'Cooperativa não encontrada.';
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapcop;
    
        OPEN cr_checkdesen(pr_cddesenvolvedor => pr_cddesenvolvedor);
        FETCH cr_checkdesen
            INTO rw_checkdesen;
    
        IF cr_checkdesen%NOTFOUND THEN
            CLOSE cr_checkdesen;
            vr_dscritic := 'Nenhum desenvolvedor encontrado com o código informado.';
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END IF;
        CLOSE cr_checkdesen;
    
        BEGIN
            apis0001.pc_gera_identif_desenv(pr_cddesenv => pr_cddesenvolvedor
                                           ,pr_inpessoa => rw_checkdesen.inpessoa
                                           ,pr_nrdocdsv => rw_checkdesen.nrdocumento
                                           ,pr_cdoperad => pr_operador
                                           ,pr_idformat => 1
                                           ,pr_dsuuidds => pr_dsuuid);
        
        EXCEPTION
            WHEN OTHERS THEN
                vr_dscritic := 'Ocorreu um erro ao gerar a UUID: ' || SQLERRM;
                vr_cdcritic := 0;
                RAISE vr_exc_saida;
        END;
    
    EXCEPTION
        WHEN vr_exc_saida THEN
        
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            END IF;
        WHEN OTHERS THEN
        
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina na procedure TELA_CADDES.pc_gera_uuid_desenvolvedor. Erro: ' ||
                           SQLERRM;
    END pc_gera_uuid_desenvolvedor;

END tela_caddes;
/
