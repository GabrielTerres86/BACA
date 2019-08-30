CREATE OR REPLACE PACKAGE CECRED.tela_contar IS

    PROCEDURE pc_consulta_tarifas_web(pr_cddgrupo IN crapgru.cddgrupo%TYPE --> Codigo do grupo
                                     ,pr_cdtarifa IN craptar.cdtarifa%TYPE --> Codigo da tarifa
                                     ,pr_nrconven IN VARCHAR2 --> Numeros dos convenios separados por ","
                                     ,pr_flgativo IN VARCHAR2 --> Situacao do convenio (NULL=Todos, 0=Inativos, 1=Ativos)
                                     ,pr_cdlcremp IN VARCHAR2 --> Codigos das linhas de credito separados por ","
                                     ,pr_nrregist IN PLS_INTEGER --> Numero de Registros da Paginacao
                                     ,pr_nriniseq IN PLS_INTEGER --> Numero de inicio de sequencia da paginacao
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                      ------------ OUT ------------
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

    PROCEDURE pc_consulta_convenios_web(pr_nrconven    IN crapcco.nrconven%TYPE --> Numero do convenio
                                       ,pr_flgativo    IN crapcco.flgativo%TYPE --> Status (1=Ativo,0=Inativo,Null=Ambos)
                                       ,pr_ls_nrconven IN VARCHAR2 --> Numero de convenios ja selecionados
                                       ,pr_xmllog      IN VARCHAR2 --> XML com informacoes de LOG
                                        ------------ OUT ------------
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);

    PROCEDURE pc_consulta_creditos_web(pr_cdlcremp    IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                      ,pr_ls_cdlcremp IN VARCHAR2 --> Codigos de linhas de credito ja selecionados
                                      ,pr_xmllog      IN VARCHAR2 --> XML com informacoes de LOG
                                       ------------ OUT ------------
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);

END tela_contar;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_contar IS

    PROCEDURE pc_consulta_tarifas_web(pr_cddgrupo IN crapgru.cddgrupo%TYPE --> Codigo do grupo
                                     ,pr_cdtarifa IN craptar.cdtarifa%TYPE --> Codigo da tarifa
                                     ,pr_nrconven IN VARCHAR2 --> Numeros dos convenios separados por ","
                                     ,pr_flgativo IN VARCHAR2 --> Situacao do convenio (NULL=Todos, 0=Inativos, 1=Ativos)
                                     ,pr_cdlcremp IN VARCHAR2 --> Codigos das linhas de credito separados por ","
                                     ,pr_nrregist IN PLS_INTEGER --> Numero de Registros da Paginacao
                                     ,pr_nriniseq IN PLS_INTEGER --> Numero de inicio de sequencia da paginacao
                                     ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                      ------------ OUT ------------
                                     ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS
    
        /* .............................................................................
        
        Programa: pc_consultar_tarifas_web
        Sistema : Ayllos Web
        Autor   : Andre Clemer (Supero)
        Data    : Outubro/2018                        Ultima atualizacao: 13/08/2019
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado via mensageria
        
        Objetivo  : Consulta tarifas
        
        Alteracoes: 13/08/2019 - Inserir colunas Valor Inicial e Final da Faixa,
		                         conforme RITM0011962 (Jose Gracik/Mouts).
        ..............................................................................*/
    
        CURSOR cr_tarifas(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_cddgrupo IN crapgru.cddgrupo%TYPE
                         ,pr_cdtarifa IN craptar.cdtarifa%TYPE
                         ,pr_nrconven IN VARCHAR2
                         ,pr_flgativo IN VARCHAR2
                         ,pr_cdlcremp IN VARCHAR2) IS
            SELECT gru.cddgrupo
                  ,gru.dsdgrupo
                  ,sub.cdsubgru
                  ,sub.dssubgru
                  ,cat.cdcatego
                  ,cat.cdtipcat
                  ,cat.dscatego
                  ,cco.nrconven
                  ,tar.cdtarifa
                  ,substr(tar.dstarifa, 0, 80) AS dstarifa
                  ,to_char(fco.vltarifa, 'fm999G999G990D00') AS vltarifa
                  ,to_char(fco.vlmintar, 'fm999G999G990D00') AS vlmintar
                  ,to_char(fco.vlmaxtar, 'fm999G999G990D00') AS vlmaxtar
                  ,to_char(fco.vlpertar, 'fm999G999G990D00') AS vlpertar
                  ,his.cdhistor
                  ,substr(his.cdhistor || ' - ' || his.dshistor, 0, 20) AS dshistor
                  ,his.dsexthst
                  ,to_char(fco.dtvigenc, 'DD/MM/RRRR') AS dtvigenc
				  ,to_char(fvl.vlinifvl, 'fm999G999G990D00') AS vlinifvl
                  ,to_char(fvl.vlfinfvl, 'fm999G999G990D00') AS vlfinfvl
                  ,fco.cdoperad
                  ,ope.nmoperad
                  ,cco.flgativo
                  ,row_number() over(ORDER BY fco.dtvigenc DESC) rnum
                  ,COUNT(1) over() qtregist
              FROM craptar tar
                  ,crapsgr sub
                  ,crapgru gru
                  ,crapcat cat
                  ,crapfco fco
                  ,crapfvl fvl
                  ,craphis his
                  ,crapcco cco
                  ,crapope ope
                  ,craplcr lcr
             WHERE tar.cdsubgru = sub.cdsubgru
               AND sub.cddgrupo = gru.cddgrupo
               AND cat.cdcatego = tar.cdcatego
               AND fvl.cdtarifa = tar.cdtarifa
               AND fco.cdfaixav = fvl.cdfaixav
               AND fco.cdcooper = pr_cdcooper
                  -- Para tipo cobranca
               AND cco.cdcooper(+) = fco.cdcooper
               AND cco.nrconven(+) = fco.nrconven
               AND cco.cdcooper(+) = pr_cdcooper
               AND (TRIM(pr_nrconven) IS NULL OR
                   cco.nrconven IN
                   (SELECT regexp_substr(TRIM(pr_nrconven), '[^,]+', 1, LEVEL) item
                       FROM dual
                     CONNECT BY LEVEL <= regexp_count(TRIM(pr_nrconven), '[^,]+')))
                  -- Ligacao com linha de credito
               AND lcr.cdcooper(+) = fco.cdcooper
               AND lcr.cdlcremp(+) = fco.cdlcremp
               AND lcr.cdcooper(+) = pr_cdcooper
               AND lcr.flgstlcr(+) = 1
               AND (TRIM(pr_cdlcremp) IS NULL OR
                   lcr.cdlcremp IN
                   (SELECT regexp_substr(TRIM(pr_cdlcremp), '[^,]+', 1, LEVEL) item
                       FROM dual
                     CONNECT BY LEVEL <= regexp_count(TRIM(pr_cdlcremp), '[^,]+')))
                  
                  -- Ligacao com historico
               AND his.cdcooper(+) = pr_cdcooper
               AND his.cdhistor(+) = fvl.cdhistor
                  
                  -- Ligacao com operador
               AND ope.cdoperad(+) = fco.cdoperad
               AND ope.cdcooper(+) = pr_cdcooper
                  
               AND (tar.cdtarifa = pr_cdtarifa OR pr_cdtarifa IS NULL)
                  
               AND ((pr_cddgrupo IN (1, 2, 4, 6, 7) AND gru.cddgrupo IN (1, 2, 4, 6, 7)) -- CHEQUE/CONTA CORRENTE/DEMAIS SERVICOS/SERVICOS COOPERATIVOS/SMS
                   OR (pr_cddgrupo = 3 AND gru.cddgrupo = 3) -- COBRANCA
                   OR (pr_cddgrupo = 5 AND gru.cddgrupo = 5) -- CREDITO
                   )
            
             ORDER BY fco.dtvigenc DESC, fvl.vlinifvl;
    
        -- Controle de erro
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
        vr_exc_erro EXCEPTION;
    
        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad crapope.cdoperad%TYPE;
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis locais
        vr_contador INTEGER := 0;
    BEGIN
    
        gene0001.pc_informa_acesso(pr_module => 'TELA_CONTAR.pc_consultar_tarifas_web');
    
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
    
        pr_des_erro := 'OK';
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        FOR rw_tarifas IN cr_tarifas(vr_cdcooper
                                    ,pr_cddgrupo
                                    ,pr_cdtarifa
                                    ,pr_nrconven
                                    ,pr_flgativo
                                    ,pr_cdlcremp) LOOP
        
            -- Cria atributo
            IF vr_contador = 0 THEN
                gene0007.pc_gera_atributo(pr_xml      => pr_retxml
                                         ,pr_tag      => 'Dados'
                                         ,pr_atrib    => 'qtregist'
                                         ,pr_atval    => rw_tarifas.qtregist
                                         ,pr_numva    => 0
                                         ,pr_des_erro => vr_dscritic);
            END IF;
        
            -- Enviar somente se a linha for superior a linha inicial
            IF nvl(pr_nriniseq, 1) <= rw_tarifas.rnum AND vr_contador < nvl(pr_nrregist, 99999) THEN
                -- E enviados for menor que o solicitado
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'Dados'
                                      ,pr_posicao  => 0
                                      ,pr_tag_nova => 'inf'
                                      ,pr_tag_cont => NULL
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'cddgrupo'
                                      ,pr_tag_cont => rw_tarifas.cddgrupo
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'dsdgrupo'
                                      ,pr_tag_cont => rw_tarifas.dsdgrupo
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'cdtarifa'
                                      ,pr_tag_cont => rw_tarifas.cdtarifa
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'dstarifa'
                                      ,pr_tag_cont => rw_tarifas.dstarifa
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'cdhistor'
                                      ,pr_tag_cont => rw_tarifas.cdhistor
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'dshistor'
                                      ,pr_tag_cont => rw_tarifas.dshistor
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'dtvigenc'
                                      ,pr_tag_cont => rw_tarifas.dtvigenc
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'vltarifa'
                                      ,pr_tag_cont => rw_tarifas.vltarifa
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'cdoperad'
                                      ,pr_tag_cont => rw_tarifas.cdoperad
                                      ,pr_des_erro => vr_dscritic);
            
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'nmoperad'
                                      ,pr_tag_cont => rw_tarifas.nmoperad
                                      ,pr_des_erro => vr_dscritic);
            
				gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'vlinifvl'
                                      ,pr_tag_cont => rw_tarifas.vlinifvl
                                      ,pr_des_erro => vr_dscritic);
										
				gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'vlfinfvl'
                                      ,pr_tag_cont => rw_tarifas.vlfinfvl
                                      ,pr_des_erro => vr_dscritic);

				gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'vlpertar'
                                      ,pr_tag_cont => rw_tarifas.vlpertar
                                      ,pr_des_erro => vr_dscritic);
                
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'vlpertar'
                                      ,pr_tag_cont => rw_tarifas.vlpertar
                                      ,pr_des_erro => vr_dscritic);
                
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'vlmintar'
                                      ,pr_tag_cont => rw_tarifas.vlmintar
                                      ,pr_des_erro => vr_dscritic);
                
                gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                      ,pr_tag_pai  => 'inf'
                                      ,pr_posicao  => vr_contador
                                      ,pr_tag_nova => 'vlmaxtar'
                                      ,pr_tag_cont => rw_tarifas.vlmaxtar
                                      ,pr_des_erro => vr_dscritic);
                                      
                 -- Grupo Cobranca
                IF pr_cddgrupo = 3 THEN
                    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                          ,pr_tag_pai  => 'inf'
                                          ,pr_posicao  => vr_contador
                                          ,pr_tag_nova => 'nrconven'
                                          ,pr_tag_cont => rw_tarifas.nrconven
                                          ,pr_des_erro => vr_dscritic);
                
                    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                          ,pr_tag_pai  => 'inf'
                                          ,pr_posicao  => vr_contador
                                          ,pr_tag_nova => 'flgativo'
                                          ,pr_tag_cont => rw_tarifas.flgativo
                                          ,pr_des_erro => vr_dscritic);                                     
                END IF;
            
                vr_contador := vr_contador + 1;
            END IF;
        END LOOP;
    
        IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
        END IF;
    
        pr_nmdcampo := NULL;
    
    EXCEPTION
        WHEN vr_exc_erro THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
            END IF;
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela CONTAR: ' || SQLERRM;
        
            -- Carregar XML padrão para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
    END;

    PROCEDURE pc_consulta_convenios_web(pr_nrconven    IN crapcco.nrconven%TYPE --> Numero do convenio
                                       ,pr_flgativo    IN crapcco.flgativo%TYPE --> Status (1=Ativo,0=Inativo,Null=Ambos)
                                       ,pr_ls_nrconven IN VARCHAR2 --> Numero de convenios ja selecionados
                                       ,pr_xmllog      IN VARCHAR2 --> XML com informacoes de LOG
                                        ------------ OUT ------------
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                       ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS
    
        /* .............................................................................
        
        Programa: pc_consulta_convenios_web
        Sistema : Ayllos Web
        Autor   : Andre Clemer (Supero)
        Data    : Outubro/2018                        Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado via mensageria
        
        Objetivo  : Listar convenios
        
        Alteracoes: -----
        ..............................................................................*/
    
        CURSOR cr_convenios(pr_cdcooper    IN crapcop.cdcooper%TYPE
                           ,pr_flgativo    IN crapcco.flgativo%TYPE
                           ,pr_nrconven    IN crapcco.nrconven%TYPE
                           ,pr_ls_nrconven IN VARCHAR2) IS
            SELECT crapcco.cdcooper
                  ,crapcco.nrconven
                  ,crapcco.dsorgarq
                  ,crapcco.flgativo
              FROM crapcco
             WHERE crapcco.cdcooper = pr_cdcooper
               AND (crapcco.nrconven = pr_nrconven OR pr_nrconven IS NULL)
               AND (crapcco.nrconven NOT IN
                   (SELECT regexp_substr(TRIM(pr_ls_nrconven), '[^,]+', 1, LEVEL) item
                       FROM dual
                     CONNECT BY LEVEL <= regexp_count(TRIM(pr_ls_nrconven), '[^,]+')) OR
                   pr_ls_nrconven IS NULL)
               AND (crapcco.flgativo = pr_flgativo OR pr_flgativo IS NULL)
             ORDER BY crapcco.nrconven
                     ,crapcco.dsorgarq;
    
        -- Controle de erro
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
        vr_exc_erro EXCEPTION;
    
        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad crapope.cdoperad%TYPE;
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis locais
        vr_contador INTEGER := 0;
    BEGIN
    
        gene0001.pc_informa_acesso(pr_module => 'TELA_CONTAR.pc_consulta_convenios_web');
    
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
    
        pr_des_erro := 'OK';
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        FOR rw_convenios IN cr_convenios(vr_cdcooper, pr_flgativo, pr_nrconven, pr_ls_nrconven) LOOP
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'inf'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'nrconven'
                                  ,pr_tag_cont => rw_convenios.nrconven
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dsorgarq'
                                  ,pr_tag_cont => rw_convenios.dsorgarq
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'flgativo'
                                  ,pr_tag_cont => rw_convenios.flgativo
                                  ,pr_des_erro => vr_dscritic);
        
            vr_contador := vr_contador + 1;
        END LOOP;
    
        IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
        END IF;
    
        pr_nmdcampo := NULL;
    
    EXCEPTION
        WHEN vr_exc_erro THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
            END IF;
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela CONTAR: ' || SQLERRM;
        
            -- Carregar XML padrão para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
    END;

    PROCEDURE pc_consulta_creditos_web(pr_cdlcremp    IN craplcr.cdlcremp%TYPE --> Codigo da linha de credito
                                      ,pr_ls_cdlcremp IN VARCHAR2 --> Codigos de linhas de credito ja selecionados
                                      ,pr_xmllog      IN VARCHAR2 --> XML com informacoes de LOG
                                       ------------ OUT ------------
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS
    
        /* .............................................................................
        
        Programa: pc_consulta_creditos_web
        Sistema : Ayllos Web
        Autor   : Andre Clemer (Supero)
        Data    : Outubro/2018                        Ultima atualizacao:
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado via mensageria
        
        Objetivo  : Listar linhas de credito
        
        Alteracoes: -----
        ..............................................................................*/
    
        CURSOR cr_creditos(pr_cdcooper    IN crapcop.cdcooper%TYPE
                          ,pr_cdlcremp    IN craplcr.cdlcremp%TYPE
                          ,pr_ls_cdlcremp IN VARCHAR2) IS
            SELECT craplcr.cdlcremp
                  ,craplcr.flgstlcr
                  ,craplcr.dslcremp
              FROM craplcr
             WHERE craplcr.cdcooper = pr_cdcooper
               AND craplcr.flgstlcr = 1
               AND (craplcr.cdlcremp = pr_cdlcremp OR pr_cdlcremp IS NULL)
               AND (craplcr.cdlcremp NOT IN
                   (SELECT regexp_substr(TRIM(pr_ls_cdlcremp), '[^,]+', 1, LEVEL) item
                       FROM dual
                     CONNECT BY LEVEL <= regexp_count(TRIM(pr_ls_cdlcremp), '[^,]+')) OR
                   pr_ls_cdlcremp IS NULL)
             ORDER BY craplcr.cdlcremp;
    
        -- Controle de erro
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
        vr_exc_erro EXCEPTION;
    
        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad crapope.cdoperad%TYPE;
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        -- Variaveis locais
        vr_contador INTEGER := 0;
    BEGIN
    
        gene0001.pc_informa_acesso(pr_module => 'TELA_CONTAR.pc_consulta_creditos_web');
    
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
    
        pr_des_erro := 'OK';
    
        -- Criar cabecalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        FOR rw_creditos IN cr_creditos(vr_cdcooper, pr_cdlcremp, pr_ls_cdlcremp) LOOP
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Dados'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'inf'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'cdlcremp'
                                  ,pr_tag_cont => rw_creditos.cdlcremp
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'dslcremp'
                                  ,pr_tag_cont => rw_creditos.dslcremp
                                  ,pr_des_erro => vr_dscritic);
        
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'inf'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'flgstlcr'
                                  ,pr_tag_cont => rw_creditos.flgstlcr
                                  ,pr_des_erro => vr_dscritic);
        
            vr_contador := vr_contador + 1;
        END LOOP;
    
        IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
        END IF;
    
        pr_nmdcampo := NULL;
    
    EXCEPTION
        WHEN vr_exc_erro THEN
            IF vr_cdcritic <> 0 THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := vr_dscritic;
            
            END IF;
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral na rotina da tela CONTAR: ' || SQLERRM;
        
            -- Carregar XML padrão para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                           pr_dscritic || '</Erro></Root>');
        
    END;
END tela_contar;
/
