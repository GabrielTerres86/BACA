CREATE OR REPLACE PACKAGE CECRED.empr0007_f8n IS
    ---------------------------------------------------------------------------
    --
    --  Programa : EMPR0007
    --  Sistema  : Rotinas referentes a Portabilidade de Credito
    --  Sigla    : EMPR
    --  Autor    : Dioni/Supero
    --  Data     : Julho - 2019.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Centralizar rotinas relacionadas a Portabilidade de Credito chamadas pelas apis
    --
    -- Alteracoes: 

    ---------------------------------------------------------------------------

    PROCEDURE pc_buscar_boletos_contrato_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                            ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                            ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
                                            ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                            ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                            ,pr_retxml   OUT NOCOPY xmltype); --> Arquivo de retorno do XML

    PROCEDURE pc_obtem_dados_tr_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                   ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
                                   ,pr_dtvenc   IN VARCHAR2 --> Data escolhida para vencimento
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   OUT NOCOPY xmltype); --> Arquivo de retorno do XML

    PROCEDURE pc_busca_aval_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Numero conta
                               ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero conta
                               ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero contrato
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   OUT NOCOPY xmltype);

    PROCEDURE pc_gera_boleto_contrato_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcob.nrdconta%TYPE --> Código da cooperativa
                                         ,pr_nrdconta IN crapcob.nrdconta%TYPE --> Nr. da Conta
                                         ,pr_nrctremp IN crapcob.nrctremp%TYPE --> Número do contrato de empréstimo;
                                         ,pr_dtmvtolt IN VARCHAR2 --> Data do movimento;
                                         ,pr_tpparepr IN NUMBER --> Tipo de parcela 1 = Parcela Normal, 2 = Total do atraso 3 = Parcial do atraso 4 = Quitação do contrato;
                                         ,pr_dsparepr IN VARCHAR2 DEFAULT NULL /* Descrição das parcelas do empréstimo “par1;par2;par...; parN”;
                                                                                                                                                                                                                 Obs: empréstimo TR => NULL;
                                                                                                                                                                                                                 Obs2: Quando for ref a várias parcelas do contrato, parcela = NULL;
                                                                                                                                                                                                                 Obs3: Quando for quitação do contrato, parcela = 0; */
                                         ,pr_dtvencto IN VARCHAR2 --> Vencimento do boleto;
                                         ,pr_vlparepr IN VARCHAR2 --> Valor da parcela;
                                         ,pr_nrcpfava IN NUMBER --> CPF do avalista
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml   OUT NOCOPY xmltype); --> Arquivo de retorno do XML

    PROCEDURE pc_enviar_boleto_email_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE --> Código da Cooperativa
                                        ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE --> Nr. da Conta
                                        ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE --> Nr. Contrato
                                        ,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE --> Nr. Conta Cobrança
                                        ,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE --> Nr. Convenio Cobrança
                                        ,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE --> Nr. Documento
                                        ,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE --> Email
                                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica

    PROCEDURE pc_enviar_boleto_sms_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE --> Nr. da Conta
                                      ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE --> Nr. Contrato
                                      ,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE --> Nr. Conta Cobrança
                                      ,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE --> Nr. Convenio Cobrança
                                      ,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE --> Nr. Documento
                                      ,pr_nrdddsms IN tbrecup_cobranca.nrddd_sms%TYPE --> Nr. DDD Telefone
                                      ,pr_nrtelsms IN tbrecup_cobranca.nrtel_sms%TYPE --> Nr. Telefone
                                      ,pr_nmcontat IN tbrecup_cobranca.nmcontato%TYPE --> Nome de Contato
                                      ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica

    PROCEDURE pc_baixar_boleto_api(pr_nmtela   IN VARCHAR --> Nome da tela
                                  ,pr_nrdcaixa IN INTEGER --> Numero do caixa
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                                  ,pr_cdagenci IN crapope.cdagenci%TYPE --> Código da agência
                                  ,pr_cdorigem IN INTEGER --> Código da origem
                                  ,pr_cdcooper IN crapepr.cdcooper%TYPE --> Código da cooperativa
                                  ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Nr. da conta
                                  ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Nr. contrato de empréstiomo
                                  ,pr_nrctacob IN crapepr.nrdconta%TYPE --> Nr. da conta cobrança
                                  ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE --> Nr. convenio
                                  ,pr_nrdocmto IN crapcob.nrdocmto%TYPE --> Nr. documento
                                  ,pr_dtmvtolt IN VARCHAR2 --> Data de movimento
                                  ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2); --> Descrição da crítica

END empr0007_f8n;
/
CREATE OR REPLACE PACKAGE BODY CECRED.empr0007_f8n IS
    ---------------------------------------------------------------------------
    --
    --  Programa : EMPR0007
    --  Sistema  : Rotinas referentes a Portabilidade de Credito
    --  Sigla    : EMPR
    --  Autor    : Dioni/Supero
    --  Data     : Abril - 2019.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Centralizar rotinas relacionadas a Portabilidade de Credito chamadas pelas apis
    --
    -- Alteracoes: 

    ---------------------------------------------------------------------------

    PROCEDURE pc_buscar_boletos_contrato_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                            ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                            ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
                                            ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                            ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                            ,pr_retxml   OUT NOCOPY xmltype) IS --> Xml de retorno
    BEGIN
        /* .............................................................................
        
          Programa: pc_buscar_boletos_contratos_api
          Sistema : CECRED
          Sigla   : API - Crédito
          Autor   : Dioni/Supero
          Data    : Março/19.                    
        
          Dados referentes ao programa:
        
          Frequencia: Sempre que for chamado
        
          Objetivo  : Rotina referente a busca dos boletos de contratos para Api de crédito
        
          Observacao: Chamada a partir do c# na api de crédito
        
        ..............................................................................*/
        DECLARE
            ----------------------------- VARIAVEIS ---------------------------------
            -- Variável de críticas
            vr_cdcritic crapcri.cdcritic%TYPE; -- Cód. crítica
            vr_dscritic VARCHAR2(10000); -- Desc. crítica
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- PL/Table
            vr_tab_cde  empr0007.typ_tab_cde; -- PL/Table com os dados retornados da procedure
            vr_ind_cde  INTEGER := 0; -- Indice para a PL/Table retornada da procedure
            vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML      
        
        BEGIN
        
            empr0007.pc_buscar_boletos_contratos(pr_cdcooper => pr_cdcooper --> Cooperativa
                                                ,pr_cdagenci => pr_cdagenci --> PA
                                                ,pr_nrctremp => pr_nrctremp --> Nr. do Contrato
                                                ,pr_nrdconta => pr_nrdconta --> Nr. da Conta
                                                ,pr_dtbaixai => NULL --> Data de baixa inicial
                                                ,pr_dtbaixaf => NULL --> Data de baixa final
                                                ,pr_dtemissi => NULL --> Data de emissão inicial
                                                ,pr_dtemissf => NULL --> Data de emissão final
                                                ,pr_dtvencti => NULL --> Data de vencimento inicial
                                                ,pr_dtvenctf => NULL --> Data de vencimento final
                                                ,pr_dtpagtoi => NULL --> Data de pagamento inicial
                                                ,pr_dtpagtof => NULL --> Data de pagamento final
                                                ,pr_cdoperad => pr_cdoperad --> Cód. Operador
                                                ,pr_cdcritic => vr_cdcritic --> Cód. da crítica
                                                ,pr_dscritic => vr_dscritic --> Descrição da crítica
                                                ,pr_tab_cde  => vr_tab_cde); --> Pl/Table com os dados de cobrança de emprestimos
        
            -- Se retornou alguma crítica
            IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
                -- Levantar exceção
                RAISE vr_exc_saida;
            END IF;
        
            -- Se PL/Table possuir algum registro
            IF vr_tab_cde.count() > 0 THEN
                -- Atribui registro inicial como indice
                vr_ind_cde := 1;
                -- Se existe registro com o indice inicial
                IF vr_tab_cde.exists(vr_ind_cde) THEN
                    -- Criar cabeçalho do XML
                    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
                
                    FOR vr_ind_cde IN vr_tab_cde.first .. vr_tab_cde.last LOOP
                        IF vr_tab_cde(vr_ind_cde)
                         .dssituac = 'BAIXADO' OR vr_tab_cde(vr_ind_cde).dssituac = 'PAGO' THEN
                            continue;
                        END IF;
                    
                        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                              ,pr_tag_pai  => 'Root'
                                              ,pr_posicao  => 0
                                              ,pr_tag_nova => 'Dados'
                                              ,pr_tag_cont => NULL
                                              ,pr_des_erro => vr_dscritic);
                        -- Insere as tags
                        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                              ,pr_tag_pai  => 'Dados'
                                              ,pr_posicao  => vr_auxconta
                                              ,pr_tag_nova => 'nrcnvcob'
                                              ,pr_tag_cont => vr_tab_cde(vr_ind_cde).nrcnvcob
                                              ,pr_des_erro => vr_dscritic);
                        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                              ,pr_tag_pai  => 'Dados'
                                              ,pr_posicao  => vr_auxconta
                                              ,pr_tag_nova => 'nrdocmto'
                                              ,pr_tag_cont => vr_tab_cde(vr_ind_cde).nrdocmto
                                              ,pr_des_erro => vr_dscritic);
                        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                              ,pr_tag_pai  => 'Dados'
                                              ,pr_posicao  => vr_auxconta
                                              ,pr_tag_nova => 'dtvencto'
                                              ,pr_tag_cont => to_char(vr_tab_cde(vr_ind_cde).dtvencto
                                                                     ,'dd/mm/RRRR')
                                              ,pr_des_erro => vr_dscritic);
                        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                              ,pr_tag_pai  => 'Dados'
                                              ,pr_posicao  => vr_auxconta
                                              ,pr_tag_nova => 'vlboleto'
                                              ,pr_tag_cont => vr_tab_cde(vr_ind_cde).vlboleto
                                              ,pr_des_erro => vr_dscritic);
                        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                              ,pr_tag_pai  => 'Dados'
                                              ,pr_posicao  => vr_auxconta
                                              ,pr_tag_nova => 'dssituac'
                                              ,pr_tag_cont => vr_tab_cde(vr_ind_cde).dssituac
                                              ,pr_des_erro => vr_dscritic);
                        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                              ,pr_tag_pai  => 'Dados'
                                              ,pr_posicao  => vr_auxconta
                                              ,pr_tag_nova => 'lindigit'
                                              ,pr_tag_cont => vr_tab_cde(vr_ind_cde).lindigit
                                              ,pr_des_erro => vr_dscritic);
                    
                        vr_auxconta := vr_auxconta + 1;
                    END LOOP;
                END IF;
            END IF;
        
            IF vr_auxconta = 0 THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Dados nao encontrados!';
                -- Levanta exceção
                RAISE vr_exc_saida;
            END IF;
        EXCEPTION
            WHEN vr_exc_saida THEN
                -- Se possui código de crítica e não foi informado a descrição
                IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                    -- Busca descrição da crítica
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                END IF;
            
                -- Atribui exceção para os parametros de crítica
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
            WHEN OTHERS THEN
            
                -- Atribui exceção para os parametros de crítica
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro nao tratado na EMPR0007_F8N.pc_buscar_boletos_contratos_api: ' || SQLERRM;
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
        END;
    END pc_buscar_boletos_contrato_api;

    PROCEDURE pc_obtem_dados_tr_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0 --> Nr. da Conta
                                   ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
                                   ,pr_dtvenc   IN VARCHAR2 --> Data escolhida para vencimento
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   OUT NOCOPY xmltype) IS --> Arquivo de retorno do XML
    BEGIN
        /* .............................................................................
        
            Programa: pc_obtem_dados_tr_api
            Sistema : CECRED
            Sigla   : API - Crédito
            Autor   : Dioni/Supero
            Data    : Março/19.                    Ultima atualizacao: --/--/----
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Rotina referente a busca dos dados do contrato TR para geração do boleto de quitação para Api de crédito
        
            Observacao: Chamada a partir do c# na api de crédito
        
            Alteracoes:
        ..............................................................................*/
        DECLARE
        
            -- Variável de críticas
            vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
            vr_dscritic VARCHAR2(1000); --> Desc. Erro
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis locais
            vr_vlsdeved crapepr.vlsdeved%TYPE;
            vr_vlatraso crapepr.vlsdeved%TYPE;
        
        BEGIN
        
            empr0007.pc_obtem_dados_tr(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp
                                      ,pr_dtmvtolt => to_date(pr_dtvenc, 'DD/MM/RRRR')
                                      ,pr_nmdatela => pr_nmtela
                                      ,pr_idorigem => pr_cdorigem
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_vlsdeved => vr_vlsdeved
                                      ,pr_vlatraso => vr_vlatraso
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
        
            -- Se retornou alguma crítica
            IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                -- Levanta exceção
                RAISE vr_exc_saida;
            END IF;
        
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><vlsdeved>' || to_char(vr_vlsdeved) || '</vlsdeved>' ||
                                           '<vlatraso>' || to_char(vr_vlatraso) || '</vlatraso></Root>');
        
        EXCEPTION
            WHEN vr_exc_saida THEN
            
                IF vr_cdcritic <> 0 THEN
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                ELSE
                    pr_cdcritic := vr_cdcritic;
                    pr_dscritic := vr_dscritic;
                END IF;
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
            WHEN OTHERS THEN
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina pc_obtem_dados_tr_api : ' || SQLERRM;
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
        END;
    END pc_obtem_dados_tr_api;

    PROCEDURE pc_busca_aval_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                               ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero conta
                               ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero contrato
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   OUT NOCOPY xmltype) IS --> Erros do processo
    BEGIN
    
        /* .............................................................................
        
        Programa: pc_busca_aval_api
        Sistema : Cobrança - Cooperativa de Credito
        Sigla   : API - Crédito
        Autor   : André Clemer - Supero
        Data    : Marco/2019.                    Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado via API
        
        Objetivo  : Rotina para listar os avalistas.
        
        Observacao: Procedure baseada na TELA_COBEMP.pc_busca_aval
        
        Alteracoes: -----
        ..............................................................................*/
        DECLARE
        
            -- Variável de críticas
            vr_cdcritic crapcri.cdcritic%TYPE;
            vr_dscritic VARCHAR2(10000);
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
            -- Variaveis
            vr_index    PLS_INTEGER;
            vr_tab_aval dsct0002.typ_tab_dados_avais;
            
            vr_cpfcnpj  VARCHAR2(20);
        
        BEGIN
        
            -- Criar cabeçalho do XML
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        
            -- Listar avalistas de contratos
            dsct0002.pc_lista_avalistas(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                       ,pr_cdagenci => pr_cdagenci --> Código da agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa do operador
                                       ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                       ,pr_nmdatela => pr_nmtela --> Nome da tela
                                       ,pr_idorigem => pr_cdorigem --> Identificador de Origem
                                       ,pr_nrdconta => pr_nrdconta --> Numero da conta do cooperado
                                       ,pr_idseqttl => 1 --> Sequencial do titular
                                       ,pr_tpctrato => 1 --> Emprestimo  
                                       ,pr_nrctrato => pr_nrctremp --> Numero do contrato
                                       ,pr_nrctaav1 => 0 --> Numero da conta do primeiro avalista
                                       ,pr_nrctaav2 => 0 --> Numero da conta do segundo avalista
                                        --------> OUT <--------                                   
                                       ,pr_tab_dados_avais => vr_tab_aval --> retorna dados do avalista
                                       ,pr_cdcritic        => vr_cdcritic --> Código da crítica
                                       ,pr_dscritic        => vr_dscritic); --> Descrição da crítica
        
            IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
            END IF;
        
            -- Buscar Primeiro registro
            vr_index := vr_tab_aval.first;
        
            -- Percorrer todos os registros
            WHILE vr_index IS NOT NULL LOOP
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Root'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'Avalista'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Avalista'
                                      ,pr_posicao  => vr_index - 1
                                      ,pr_tag_nova => 'NumeroConta'
                                      ,pr_tag_cont => vr_tab_aval(vr_index).nrctaava
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Avalista'
                                      ,pr_posicao  => vr_index - 1
                                      ,pr_tag_nova => 'Nome'
                                      ,pr_tag_cont => vr_tab_aval(vr_index).nmdavali
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Avalista'
                                      ,pr_posicao  => vr_index - 1
                                      ,pr_tag_nova => 'NumeroTelefone'
                                      ,pr_tag_cont => vr_tab_aval(vr_index).nrfonres
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Avalista'
                                      ,pr_posicao  => vr_index - 1
                                      ,pr_tag_nova => 'Email'
                                      ,pr_tag_cont => vr_tab_aval(vr_index).dsdemail
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Avalista'
                                      ,pr_posicao  => vr_index - 1
                                      ,pr_tag_nova => 'Identificador'
                                      ,pr_tag_cont => vr_tab_aval(vr_index).idavalis
                                      ,pr_des_erro => vr_dscritic);
                                      
                vr_cpfcnpj := gene0002.fn_mask_cpf_cnpj(vr_tab_aval(vr_index).nrcpfcgc,vr_tab_aval(vr_index).inpessoa);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Avalista'
                                      ,pr_posicao  => vr_index - 1
                                      ,pr_tag_nova => 'NumeroDocumento'
                                      ,pr_tag_cont => regexp_replace(vr_cpfcnpj,'[^0-9]','')
                                      ,pr_des_erro => vr_dscritic);
            
                -- Proximo Registro
                vr_index := vr_tab_aval.next(vr_index);
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
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        END;
    
    END pc_busca_aval_api;

    PROCEDURE pc_gera_boleto_contrato_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcob.nrdconta%TYPE --> Código da cooperativa
                                         ,pr_nrdconta IN crapcob.nrdconta%TYPE --> Nr. da Conta
                                         ,pr_nrctremp IN crapcob.nrctremp%TYPE --> Número do contrato de empréstimo;
                                         ,pr_dtmvtolt IN VARCHAR2 --> Data do movimento;
                                         ,pr_tpparepr IN NUMBER --> Tipo de parcela 1 = Parcela Normal, 2 = Total do atraso 3 = Parcial do atraso 4 = Quitação do contrato;
                                         ,pr_dsparepr IN VARCHAR2 DEFAULT NULL --> Descrição das parcelas do empréstimo “par1;par2;par...; parN”;
                                          -->    Obs: empréstimo TR => NULL;
                                          -->   Obs2: Quando for ref a várias parcelas do contrato, parcela = NULL;
                                          -->   Obs3: Quando for quitação do contrato, parcela = 0; 
                                         ,pr_dtvencto IN VARCHAR2 --> Vencimento do boleto;
                                         ,pr_vlparepr IN VARCHAR2 --> Valor da parcela;
                                         ,pr_nrcpfava IN NUMBER --> CPF do avalista
                                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                         ,pr_retxml   OUT NOCOPY xmltype) IS --> Arquivo de retorno do XML
    
        /* .............................................................................
        
        Programa: pc_gera_boleto_contrato_api
        Sistema : Cobrança - Cooperativa de Credito
        Sigla   : API - Crédito
        Autor   : Dioni/Supero
        Data    : Marco/19.                    Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        
        Objetivo  : Rotina de geração de boleto pra api de crédito.
        
        Observacao: -----
        
        Alteracoes: -----
        ..............................................................................*/
    
    BEGIN
        DECLARE
        
            -- Variável de críticas
            vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
            vr_dscritic VARCHAR2(1000); --> Desc. Erro
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        
        BEGIN
        
            empr0007.pc_gera_boleto_contrato(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrctremp => pr_nrctremp
                                            ,pr_dtmvtolt => to_date(pr_dtmvtolt, 'DD/MM,YYYY')
                                            ,pr_tpparepr => gene0002.fn_char_para_number(pr_tpparepr)
                                            ,pr_dsparepr => pr_dsparepr
                                            ,pr_dtvencto => to_date(pr_dtvencto, 'DD/MM,YYYY')
                                            ,pr_vlparepr => gene0002.fn_char_para_number(pr_vlparepr)
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nmdatela => pr_nmtela
                                            ,pr_idorigem => pr_cdorigem
                                            ,pr_nrcpfava => pr_nrcpfava
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
        
            -- Se retornou alguma crítica
            IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                -- Levanta exceção
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
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
            WHEN OTHERS THEN
            
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina de geração de boleto para api de crédito: ' || SQLERRM;
            
                -- Carregar XML padrão para variável de retorno não utilizada.
                -- Existe para satisfazer exigência da interface.
                pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                               '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                ROLLBACK;
        END;
    END pc_gera_boleto_contrato_api;

    PROCEDURE pc_enviar_boleto_email_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE --> Código da Cooperativa
                                        ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE --> Nr. da Conta
                                        ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE --> Nr. Contrato
                                        ,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE --> Nr. Conta Cobrança
                                        ,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE --> Nr. Convenio Cobrança
                                        ,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE --> Nr. Documento
                                        ,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE --> Email
                                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
        /* .............................................................................
        
            Programa: pc_enviar_boleto_email_api
            Sistema : CECRED
            Sigla   : EMPR
            Autor   : André Clemer - Supero
            Data    : Março/2019.                    Ultima atualizacao: --/--/----
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Rotina para enviar os boletos por E-mail via API
        
            Alteracoes:
        ..............................................................................*/
    BEGIN
        DECLARE
        
            -- Variável de críticas
            vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
            vr_dscritic VARCHAR2(1000); --> Desc. Erro        
            
            vr_nmcontat tbrecup_cobranca.nmcontato%TYPE := NULL;
            vr_tpdenvio tbrecup_cobranca.tpenvio%TYPE := 1; --> Tipo de Envio (1 = EMAIL, 2 = SMS, 3 = IMPRESSAO)                        
            vr_indretor tbrecup_cobranca.indretorno%TYPE := 0;
            vr_nrdddsms tbrecup_cobranca.nrddd_sms%TYPE := 0;
            vr_nrtelsms tbrecup_cobranca.nrtel_sms%TYPE := 0;
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        BEGIN
        
            empr0007.pc_enviar_boleto(pr_cdcooper => gene0002.fn_char_para_number(pr_cdcooper)
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_nrctacob => pr_nrctacob
                                     ,pr_nrcnvcob => pr_nrcnvcob
                                     ,pr_nrdocmto => pr_nrdocmto
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nmcontat => vr_nmcontat
                                     ,pr_tpdenvio => vr_tpdenvio
                                     ,pr_nmdatela => pr_nmtela
                                     ,pr_idorigem => pr_cdorigem
                                     ,pr_dsdemail => pr_dsdemail
                                     ,pr_indretor => vr_indretor
                                     ,pr_nrdddsms => vr_nrdddsms
                                     ,pr_nrtelsms => vr_nrtelsms
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
        
            -- Se retornou alguma crítica
            IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                -- Levanta exceção
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
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;
        END;
    END pc_enviar_boleto_email_api;

    PROCEDURE pc_enviar_boleto_sms_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE --> Nr. da Conta
                                      ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE --> Nr. Contrato
                                      ,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE --> Nr. Conta Cobrança
                                      ,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE --> Nr. Convenio Cobrança
                                      ,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE --> Nr. Documento
                                      ,pr_nrdddsms IN tbrecup_cobranca.nrddd_sms%TYPE --> Nr. DDD Telefone
                                      ,pr_nrtelsms IN tbrecup_cobranca.nrtel_sms%TYPE --> Nr. Telefone
                                      ,pr_nmcontat IN tbrecup_cobranca.nmcontato%TYPE --> Nome de Contato
                                      ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
        /* .............................................................................
        
            Programa: pc_enviar_boleto_sms_api
            Sistema : CECRED
            Sigla   : EMPR
            Autor   : André Clemer - Supero
            Data    : Março/2019.                    Ultima atualizacao: --/--/----
        
            Dados referentes ao programa:
        
            Frequencia: Sempre que for chamado
        
            Objetivo  : Rotina para enviar os boletos por SMS via API
        
            Alteracoes:
        ..............................................................................*/
    BEGIN
        DECLARE
        
            -- Variável de críticas
            vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
            vr_dscritic VARCHAR2(1000); --> Desc. Erro        
            
        
            vr_tpdenvio tbrecup_cobranca.tpenvio%TYPE := 2; --> Tipo de Envio (1 = EMAIL, 2 = SMS, 3 = IMPRESSAO)
            vr_indretor tbrecup_cobranca.indretorno%TYPE := 0;
            vr_dsdemail tbrecup_cobranca.dsemail%TYPE := NULL;
        
            -- Tratamento de erros
            vr_exc_saida EXCEPTION;
        BEGIN
        
            empr0007.pc_enviar_boleto(pr_cdcooper => gene0002.fn_char_para_number(pr_cdcooper)
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_nrctacob => pr_nrctacob
                                     ,pr_nrcnvcob => pr_nrcnvcob
                                     ,pr_nrdocmto => pr_nrdocmto
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nmcontat => pr_nmcontat
                                     ,pr_tpdenvio => vr_tpdenvio
                                     ,pr_nmdatela => pr_nmtela
                                     ,pr_idorigem => pr_cdorigem
                                     ,pr_dsdemail => vr_dsdemail
                                     ,pr_indretor => vr_indretor
                                     ,pr_nrdddsms => pr_nrdddsms
                                     ,pr_nrtelsms => pr_nrtelsms
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
        
            -- Se retornou alguma crítica
            IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                -- Levanta exceção
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
            WHEN OTHERS THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;
        END;
    END pc_enviar_boleto_sms_api;

  PROCEDURE pc_baixar_boleto_api(pr_nmtela   IN VARCHAR --> Nome da tela
                                ,pr_nrdcaixa IN INTEGER --> Numero do caixa
                                ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do operador
                                ,pr_cdagenci IN crapope.cdagenci%TYPE --> Código da agência
                                ,pr_cdorigem IN INTEGER --> Código da origem
                                ,pr_cdcooper IN crapepr.cdcooper%TYPE --> Código da cooperativa
                                ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Nr. da conta
                                ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Nr. contrato de empréstiomo
                                ,pr_nrctacob IN crapepr.nrdconta%TYPE --> Nr. da conta cobrança
                                ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE --> Nr. convenio
                                ,pr_nrdocmto IN crapcob.nrdocmto%TYPE --> Nr. documento
                                ,pr_dtmvtolt IN VARCHAR2 --> Data de movimento
                                ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2) IS --> Descrição da crítica
      /* .............................................................................
      
          Programa: pc_baixar_boleto_api
          Sistema : CECRED
          Sigla   : EMPR
          Autor   : André Clemer
          Data    : Junho/2019.                    Ultima atualizacao: --/--/----
      
          Dados referentes ao programa:
      
          Frequencia: Sempre que for chamado
      
          Objetivo  : Rotina para realizar a instrução de baixa de boleto utilizados 
                      para empréstimo através da API
      
          Observacao: -----
      
          Alteracoes: 
      ..............................................................................*/
  BEGIN
      DECLARE
          -- Variáveis locais
          vr_dstransa VARCHAR2(1000) := 'Boleto cancelado atraves do sistema Cyber';

          -- Variável de críticas
          vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
          vr_dscritic VARCHAR2(1000); --> Desc. Erro
      
          -- Tratamento de erros
          vr_exc_saida EXCEPTION;
      BEGIN
          EMPR0007.pc_inst_baixa_boleto_epr(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_nrctacob => pr_nrctacob
                                           ,pr_nrcnvcob => pr_nrcnvcob
                                           ,pr_nrdocmto => pr_nrdocmto
                                           ,pr_dtmvtolt => to_date(pr_dtmvtolt, 'DD/MM/RRRR')
                                           ,pr_idorigem => gene0002.fn_char_para_number(pr_cdorigem)
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nmdatela => pr_nmtela
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
      
          -- Se retornou alguma crítica
          IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              -- Levanta exceção
              RAISE vr_exc_saida;
          END IF;
      
          -- Atualiza a Justificativa
          BEGIN
              UPDATE tbrecup_cobranca
                 SET dsjustifica_baixa = vr_dstransa
               WHERE cdcooper = pr_cdcooper
                 AND nrdconta = pr_nrdconta
                 AND nrctremp = pr_nrctremp
                 AND nrdconta_cob = pr_nrctacob
                 AND nrcnvcob = pr_nrcnvcob
                 AND nrboleto = pr_nrdocmto;
          EXCEPTION
              WHEN OTHERS THEN
                  vr_dscritic := 'Problema ao alterar dados na tabela tbrecup_cobranca: ' || SQLERRM;
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
          
              ROLLBACK;
          WHEN OTHERS THEN
          
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmtela || ': ' || SQLERRM;

              ROLLBACK;
      END;
  END pc_baixar_boleto_api;

END empr0007_f8n;
/
