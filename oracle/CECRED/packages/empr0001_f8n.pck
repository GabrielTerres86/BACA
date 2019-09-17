CREATE OR REPLACE PACKAGE CECRED.empr0001_f8n AS

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : empr0001_f8n
    --  Sistema  : Rotinas genéricas focando nas funcionalidades de empréstimos
    --  Sigla    : EMPR
    --  Autor    : André Clemer - Supero
    --  Data     : Março/2019.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Rotinas para serem consumidas via API
    --
    -- Alterações: 
    --
    ---------------------------------------------------------------------------------------------------------------

    PROCEDURE pc_busca_pgto_parcelas_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                        ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                        ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                        ,pr_retxml   OUT NOCOPY xmltype --> Retorno com xml
                                        ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2); --> Descrição da critica

    PROCEDURE pc_obtem_dados_empresti_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                                         ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número contrato empréstimo
                                         ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da critica
                                         ,pr_retxml   IN OUT NOCOPY xmltype); --> Retorno em XML

END empr0001_f8n;
/
CREATE OR REPLACE PACKAGE BODY CECRED.empr0001_f8n AS

    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : empr0001_f8n
    --  Sistema  : Rotinas genéricas focando nas funcionalidades de empréstimos
    --  Sigla    : EMPR
    --  Autor    : André Clemer - Supero
    --  Data     : Março/2019.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Rotinas para serem consumidas via API
    --
    -- Alterações: 
    --
    ---------------------------------------------------------------------------------------------------------------

    -- Variáveis para armazenar as informações em XML
    vr_des_xml        CLOB;
    vr_texto_completo VARCHAR2(32600);
    vr_index          VARCHAR2(100) := 1;

    -- Rotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                            ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

    -- Função para converter os valores numéricos recebidos do Oracle para o padrão XML consumido pela API
    FUNCTION fn_convert_number_api(pr_dsnumber IN NUMBER) RETURN VARCHAR2 IS
    BEGIN
        RETURN to_char(pr_dsnumber, 'FM9999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,');
    END;

    PROCEDURE pc_busca_pgto_parcelas_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                        ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                        ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                        ,pr_retxml   OUT NOCOPY xmltype --> Retorno com XML
                                        ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2) IS --> Tabela com totais calculados
    BEGIN
        /* .............................................................................
        
           Programa: pc_busca_pgto_parcelas_api
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : André Clemer - Supero
           Data    : Março/2019.                         Ultima atualizacao: 
        
           Dados referentes ao programa:
        
           Frequencia: Sempre que for chamado.
           Objetivo  : Buscar os pagamentos das parcelas de empréstimo consumido pelas APIs.
        
           Alteracoes:  
        ............................................................................. */
        DECLARE
        
            --Variaveis Erro
            vr_cdcritic INTEGER;
            vr_dscritic VARCHAR2(4000);
            vr_des_reto VARCHAR2(10);
        
            --Variaveis Excecao
            vr_exc_erro  EXCEPTION;
            vr_exc_saida EXCEPTION;
        
            -- variaveis de retorno
            vr_tab_erro gene0001.typ_tab_erro;
        
            -- Variaveis internas
            vr_idseqttl crapttl.idseqttl%TYPE := 1;
            vr_flgerlog VARCHAR2(1) := 'S';
        
            vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
            vr_tab_calculado   empr0001.typ_tab_calculado;
        
        BEGIN
            empr0001.pc_busca_pgto_parcelas(pr_cdcooper        => pr_cdcooper
                                           ,pr_cdagenci        => pr_cdagenci
                                           ,pr_nrdcaixa        => pr_nrdcaixa
                                           ,pr_cdoperad        => pr_cdoperad
                                           ,pr_nmdatela        => pr_nmtela
                                           ,pr_idorigem        => pr_cdorigem
                               ,pr_nrdconta => pr_nrdconta
                                           ,pr_idseqttl        => vr_idseqttl
                                           ,pr_dtmvtolt        => pr_dtmvtolt
                                           ,pr_flgerlog        => vr_flgerlog
                               ,pr_nrctremp => pr_nrctremp
                                           ,pr_dtmvtoan        => GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                                                              pr_dtmvtolt  => pr_dtmvtolt - 1,
                                                                                              pr_tipo      => 'A')
                                           ,pr_nrparepr        => pr_nrparepr
                                           ,pr_des_reto        => vr_des_reto
                                           ,pr_tab_erro        => vr_tab_erro
                                           ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                           ,pr_tab_calculado   => vr_tab_calculado);
        
            IF vr_des_reto = 'NOK' THEN
                IF vr_tab_erro.exists(vr_tab_erro.first) THEN
                
                    vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                    vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                ELSE
                    vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
                END IF;
                RAISE vr_exc_erro;
            
            END IF;
            
                -- Inicializar o CLOB
                vr_des_xml := NULL;
                dbms_lob.createtemporary(vr_des_xml, TRUE);
                dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
            
                -- Inicilizar as informações do XML
                vr_texto_completo := NULL;
            
                pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>');
            
                vr_index := 1;
            
                IF vr_tab_calculado.count() > 0 THEN
                
                    IF vr_tab_calculado.exists(vr_index) THEN
                    
                        pc_escreve_xml('<Totalizador>' || '  <ValorSaldoDevedor>' ||
                                       fn_convert_number_api(vr_tab_calculado(vr_index).vlsdvctr) ||
                                       '</ValorSaldoDevedor>' || '  <ValorSaldoDevedorTotal>' ||
                                       fn_convert_number_api(vr_tab_calculado(vr_index).vlsdeved) ||
                                       '</ValorSaldoDevedorTotal>' || '  <ValorSaldoRelatorios>' ||
                                       fn_convert_number_api(vr_tab_calculado(vr_index).vlsderel) ||
                                       '</ValorSaldoRelatorios>' || '  <ValorPago>' ||
                                       fn_convert_number_api(vr_tab_calculado(vr_index).vlprepag) ||
                                       '</ValorPago>' || '  <ValorAPagar>' ||
                                       fn_convert_number_api(vr_tab_calculado(vr_index).vlpreapg) ||
                                       '</ValorAPagar>' || '  <QuantidadePrestacoes>' || vr_tab_calculado(vr_index)
                                       .qtprecal || '</QuantidadePrestacoes>' || '</Totalizador>');
                    
                    END IF;
                END IF;
            
                pc_escreve_xml('<Parcelas>');
            
                IF vr_tab_pgto_parcel.count() > 0 THEN
                
                    IF vr_tab_pgto_parcel.exists(vr_index) THEN
                        LOOP
                            pc_escreve_xml('<Parcela>' || '  <NumeroParcela>' || vr_tab_pgto_parcel(vr_index)
                                           .nrparepr || '</NumeroParcela>' || '  <DataVencimento>' || vr_tab_pgto_parcel(vr_index)
                                           .dtvencto || '</DataVencimento>' || '  <ValorParcela>' ||
                                           fn_convert_number_api(vr_tab_pgto_parcel(vr_index).vlparepr) ||
                                           '</ValorParcela>' || '  <ValorPago>' ||
                                           fn_convert_number_api(vr_tab_pgto_parcel(vr_index).vlpagpar) ||
                                           '</ValorPago>' || '  <ValorMulta>' ||
                                           fn_convert_number_api(vr_tab_pgto_parcel(vr_index).vlmtapar) ||
                                           '</ValorMulta>' || '  <ValorJuros>' ||
                                           fn_convert_number_api(vr_tab_pgto_parcel(vr_index).vljinpar) ||
                                           '</ValorJuros>' || '  <ValorJurosMora>' ||
                                           fn_convert_number_api(vr_tab_pgto_parcel(vr_index).vlmrapar) ||
                                           '</ValorJurosMora>' || '  <ValorDesconto>' ||
                                           fn_convert_number_api(vr_tab_pgto_parcel(vr_index).vldespar) ||
                                           '</ValorDesconto>' || '  <ValorIofAtraso>' ||
                                           fn_convert_number_api(vr_tab_pgto_parcel(vr_index).vliofcpl) ||
                                           '</ValorIofAtraso>' || '  <ValorAtual>' ||
                                           fn_convert_number_api(vr_tab_pgto_parcel(vr_index).vlatupar) ||
                                           '</ValorAtual>' || '  <ValorAPagar>' ||
                                           fn_convert_number_api(vr_tab_pgto_parcel(vr_index).vlatrpag) ||
                                           '</ValorAPagar>' || '  <Vencida>' || CASE WHEN vr_tab_pgto_parcel(vr_index)
                                           .dtvencto < pr_dtmvtolt THEN '1' ELSE '0'
                                           END || '</Vencida>' || '</Parcela>');
                        
                            EXIT WHEN(vr_index = vr_tab_pgto_parcel.last);
                        
                            vr_index := vr_tab_pgto_parcel.next(vr_index);
                        END LOOP;
                    END IF;
                END IF;
            
                pc_escreve_xml('</Parcelas>');
            
                pc_escreve_xml('</Root>', TRUE);
            
                pr_retxml := xmltype.createxml(vr_des_xml);
            
                -- Liberando a memória alocada pro CLOB
                dbms_lob.close(vr_des_xml);
                dbms_lob.freetemporary(vr_des_xml);
            EXCEPTION
            WHEN OTHERS THEN
                -- Retorno não OK
                -- Se foi retornado apenas código
                IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NULL THEN
                    -- Buscar a descrição
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                ELSE
                    -- Montar descrição de erro não tratado
                    vr_dscritic := 'Erro não tratado na empr0001_f8n.pc_busca_pgto_parcelas_api> ' || SQLERRM;
                END IF;
            
                --Variavel de erro recebe erro ocorrido
                pr_cdcritic := nvl(vr_cdcritic, 0);
                pr_dscritic := vr_dscritic;
            
                -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1
                                     ,pr_cdcritic => 0
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => vr_tab_erro);
        END;
    END pc_busca_pgto_parcelas_api;

    /* Procedure para obter dados de emprestimos do associado - Chamada AyllosWeb */
    PROCEDURE pc_obtem_dados_empresti_api(pr_nmtela   IN VARCHAR
											,pr_nrdcaixa IN INTEGER
											,pr_cdoperad IN crapope.cdoperad%TYPE
											,pr_cdagenci IN crapope.cdagenci%TYPE
											,pr_cdorigem IN INTEGER
											,pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                                         ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número contrato empréstimo
                                         ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2 --> Descrição da critica
                                         ,pr_retxml   IN OUT NOCOPY xmltype) IS
    
        /* .............................................................................
        
           Programa: pc_obtem_dados_empresti_api
           Sistema : Conta-Corrente - Cooperativa de Credito
           Sigla   : CRED
           Autor   : André Clemer - Supero
           Data    : Março/2019.                         Ultima atualizacao: 
        
           Dados referentes ao programa:
        
           Frequencia: Sempre que for chamado.
        
           Objetivo  : Procedure para obter dados de emprestimos do associado (Consumido pelas APIs)
        
           Alteracoes: 
        
        ............................................................................. */
    
        -------------------------- VARIAVEIS ----------------------
        -- Cursor genérico de calendário
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
        -- variaveis de retorno
        vr_tab_dados_epr empr0001.typ_tab_dados_epr;
        vr_tab_erro      gene0001.typ_tab_erro;
        vr_qtregist      NUMBER;
    
        --Variaveis Erro
        vr_cdcritic INTEGER;
        vr_dscritic VARCHAR2(4000);
        vr_des_reto VARCHAR2(10);
    
        --Variaveis Excecao
        vr_exc_erro  EXCEPTION;
        vr_exc_saida EXCEPTION;
    
        --Variaveis para busca de parametros
        vr_dstextab            craptab.dstextab%TYPE;
        vr_dstextab_parempctl  craptab.dstextab%TYPE;
        vr_dstextab_digitaliza craptab.dstextab%TYPE;    
    
        --Indicador de utilização da tabela
        vr_inusatab BOOLEAN;
    
        -------------------------------  CURSORES  -------------------------------
        CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE) IS
            SELECT ass.nmprimtl
              FROM crapass ass
             WHERE ass.cdcooper = pr_cdcooper
               AND ass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;
    
    BEGIN
        -- Leitura do calendário da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
    
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE btch0001.cr_crapdat;
            -- Montar mensagem de critica
            vr_cdcritic := 1;
            RAISE vr_exc_erro;
        ELSE
            -- Apenas fechar o cursor
            CLOSE btch0001.cr_crapdat;
        END IF;
    
        -- busca o tipo de documento GED
        vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                            ,pr_nmsistem => 'CRED'
                                                            ,pr_tptabela => 'GENERI'
                                                            ,pr_cdempres => 00
                                                            ,pr_cdacesso => 'DIGITALIZA'
                                                            ,pr_tpregist => 5);
    
        -- Leitura do indicador de uso da tabela de taxa de juros
        vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                           ,pr_nmsistem => 'CRED'
                                                           ,pr_tptabela => 'USUARI'
                                                           ,pr_cdempres => 11
                                                           ,pr_cdacesso => 'PAREMPCTL'
                                                           ,pr_tpregist => 01);
    
        --Buscar Indicador Uso tabela
        vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'TAXATABELA'
                                                 ,pr_tpregist => 0);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
            --Nao usa tabela
            vr_inusatab := FALSE;
        ELSE
            IF substr(vr_dstextab, 1, 1) = '0' THEN
                --Nao usa tabela
                vr_inusatab := FALSE;
            ELSE
                --Nao usa tabela
                vr_inusatab := TRUE;
            END IF;
        END IF;
    
        -- Buscar dados do associado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass
            INTO rw_crapass;
        CLOSE cr_crapass;
    
        /* Procedure para obter dados de emprestimos do associado */
        empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper --> Cooperativa conectada
                                        ,pr_cdagenci       => pr_cdagenci --> Código da agência
                                        ,pr_nrdcaixa       => pr_nrdcaixa --> Número do caixa
                                        ,pr_cdoperad       => pr_cdoperad --> Código do operador
                                        ,pr_nmdatela       => pr_nmtela --> Nome datela conectada
                                        ,pr_idorigem       => pr_cdorigem --> Indicador da origem da chamada
                                        ,pr_nrdconta       => pr_nrdconta --> Conta do associado
                                        ,pr_idseqttl       => 1 --> Sequencia de titularidade da conta
                                        ,pr_rw_crapdat     => rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                        ,pr_dtcalcul       => rw_crapdat.dtmvtolt --> Data solicitada do calculo
                                        ,pr_nrctremp       => nvl(pr_nrctremp, 0) --> Número contrato empréstimo
                                        ,pr_cdprogra       => 1 --> Programa conectado
                                        ,pr_inusatab       => vr_inusatab --> Indicador de utilização da tabela
                                        ,pr_flgerlog       => 'S' --> Gerar log S/N
                                        ,pr_flgcondc       => TRUE
                                        ,pr_nmprimtl       => rw_crapass.nmprimtl --> Nome Primeiro Titular
                                        ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                                        ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                                        ,pr_nriniseq       => 0 --> Numero inicial da paginacao
                                        ,pr_nrregist       => 1 --> Numero de registros por pagina
                                        ,pr_qtregist       => vr_qtregist --> Qtde total de registros
                                        ,pr_tab_dados_epr  => vr_tab_dados_epr --> Saida com os dados do empréstimo
                                        ,pr_des_reto       => vr_des_reto --> Retorno OK / NOK
                                        ,pr_tab_erro       => vr_tab_erro); --> Tabela com possíves erros
    
        IF vr_des_reto = 'NOK' THEN
            IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            
                vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            ELSE
                vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
            END IF;
            RAISE vr_exc_erro;
        
        END IF;

		vr_index := vr_tab_dados_epr.first;

		IF vr_index IS NULL THEN
			vr_cdcritic := 1242;
            RAISE vr_exc_erro;
		END IF;

		WHILE vr_index IS NOT NULL LOOP
        
            -- Inicializar o CLOB
            vr_des_xml := NULL;
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
            -- Inicilizar as informações do XML
            vr_texto_completo := NULL;
            pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>');
        
            pc_escreve_xml('<Root> <nrdconta>' || vr_tab_dados_epr(vr_index).nrdconta || '</nrdconta>' ||
                           '<cdagenci>' || vr_tab_dados_epr(vr_index).cdagenci || '</cdagenci>' ||
                           '<nmprimtl>' || vr_tab_dados_epr(vr_index).nmprimtl || '</nmprimtl>' ||
                           '<nrctremp>' || vr_tab_dados_epr(vr_index).nrctremp || '</nrctremp>' ||
                           '<vlemprst>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlemprst) ||
                           '</vlemprst>' || '<vlsdeved>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlsdeved) || '</vlsdeved>' ||
                           '<vlpreemp>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlpreemp) ||
                           '</vlpreemp>' || '<vlprepag>' ||
                           fn_convert_number_api(nvl(vr_tab_dados_epr(vr_index).vlprepag, 0)) ||
                           '</vlprepag>' || '<txjuremp>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).txjuremp) || '</txjuremp>' ||
                           '<vljurmes>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vljurmes) ||
                           '</vljurmes>' || '<vljuracu>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vljuracu) || '</vljuracu>' ||
                           '<vlprejuz>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlprejuz) ||
                           '</vlprejuz>' || '<vlsdprej>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlsdprej) || '</vlsdprej>' ||
                           '<dtprejuz>' || to_char(vr_tab_dados_epr(vr_index).dtprejuz, 'DD/MM/RRRR') ||
                           '</dtprejuz>' || '<vljrmprj>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vljrmprj) || '</vljrmprj>' ||
                           '<vljraprj>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vljraprj) ||
                           '</vljraprj>' || '<inprejuz>' || vr_tab_dados_epr(vr_index).inprejuz ||
                           '</inprejuz>' || '<vlprovis>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlprovis) || '</vlprovis>' ||
                           '<flgpagto>' ||
                           (CASE vr_tab_dados_epr(vr_index).flgpagto WHEN 1 THEN 'yes' ELSE 'no' END) ||
                           '</flgpagto>' || '<dtdpagto>' ||
                           to_char(vr_tab_dados_epr(vr_index).dtdpagto, 'DD/MM/RRRR') || '</dtdpagto>' ||
                           '<cdpesqui>' || vr_tab_dados_epr(vr_index).cdpesqui || '</cdpesqui>' ||
                           '<dspreapg>' || vr_tab_dados_epr(vr_index).dspreapg || '</dspreapg>' ||
                           '<cdlcremp>' || vr_tab_dados_epr(vr_index).cdlcremp || '</cdlcremp>' ||
                           '<dslcremp>' || vr_tab_dados_epr(vr_index).dslcremp || '</dslcremp>' ||
                           '<cdfinemp>' || vr_tab_dados_epr(vr_index).cdfinemp || '</cdfinemp>' ||
                           '<dsfinemp>' || vr_tab_dados_epr(vr_index).dsfinemp || '</dsfinemp>' ||
                           '<dsdaval1>' || vr_tab_dados_epr(vr_index).dsdaval1 || '</dsdaval1>' ||
                           '<dsdaval2>' || vr_tab_dados_epr(vr_index).dsdaval2 || '</dsdaval2>' ||
                           '<vlpreapg>' || fn_convert_number_api(nvl(vr_tab_dados_epr(vr_index).vlpreapg, 0)) ||
                           '</vlpreapg>' || '<qtmesdec>' || vr_tab_dados_epr(vr_index).qtmesdec ||
                           '</qtmesdec>' || '<qtprecal>' || vr_tab_dados_epr(vr_index).qtprecal ||
                           '</qtprecal>' || '<vlacresc>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlacresc) || '</vlacresc>' ||
                           '<vlrpagos>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlrpagos) ||
                           '</vlrpagos>' || '<slprjori>' || vr_tab_dados_epr(vr_index).slprjori ||
                           '</slprjori>' || '<dtmvtolt>' ||
                           to_char(vr_tab_dados_epr(vr_index).dtmvtolt, 'DD/MM/RRRR') || '</dtmvtolt>' ||
                           '<qtpreemp>' || vr_tab_dados_epr(vr_index).qtpreemp || '</qtpreemp>' ||
                           '<dtultpag>' || to_char(vr_tab_dados_epr(vr_index).dtultpag, 'DD/MM/RRRR') ||
                           '</dtultpag>' || '<vlrabono>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlrabono) || '</vlrabono>' ||
                           '<qtaditiv>' || vr_tab_dados_epr(vr_index).qtaditiv || '</qtaditiv>' ||
                           '<dsdpagto>' || vr_tab_dados_epr(vr_index).dsdpagto || '</dsdpagto>' ||
                           '<dsdavali>' || vr_tab_dados_epr(vr_index).dsdavali || '</dsdavali>' ||
                           '<qtmesatr>' || vr_tab_dados_epr(vr_index).qtmesatr || '</qtmesatr>' ||
                           '<qtpromis>' || vr_tab_dados_epr(vr_index).qtpromis || '</qtpromis>' ||
                           '<flgimppr>' ||
                           (CASE vr_tab_dados_epr(vr_index).flgimppr WHEN 1 THEN 'yes' ELSE 'no' END) ||
                           '</flgimppr>' || '<flgimpnp>' ||
                           (CASE vr_tab_dados_epr(vr_index).flgimpnp WHEN 1 THEN 'yes' ELSE 'no' END) ||
                           '</flgimpnp>' || '<idseleca>' || vr_tab_dados_epr(vr_index).idseleca ||
                           '</idseleca>' || '<nrdrecid>' || vr_tab_dados_epr(vr_index).nrdrecid ||
                           '</nrdrecid>' || '<tplcremp>' || vr_tab_dados_epr(vr_index).tplcremp ||
                           '</tplcremp>' || '<tpemprst>' || vr_tab_dados_epr(vr_index).tpemprst ||
                           '</tpemprst>' || '<cdtpempr>' || vr_tab_dados_epr(vr_index).cdtpempr ||
                           '</cdtpempr>' || '<dstpempr>' || vr_tab_dados_epr(vr_index).dstpempr ||
                           '</dstpempr>' || '<permulta>' || vr_tab_dados_epr(vr_index).permulta ||
                           '</permulta>' || '<perjurmo>' || vr_tab_dados_epr(vr_index).perjurmo ||
                           '</perjurmo>' || '<dtpripgt>' ||
                           to_char(vr_tab_dados_epr(vr_index).dtpripgt, 'DD/MM/RRRR') || '</dtpripgt>' ||
                           '<inliquid>' || vr_tab_dados_epr(vr_index).inliquid || '</inliquid>' ||
                           '<txmensal>' || vr_tab_dados_epr(vr_index).txmensal || '</txmensal>' ||
                           '<flgatras>' ||
                           (CASE vr_tab_dados_epr(vr_index).flgatras WHEN 1 THEN 'yes' ELSE 'no' END) ||
                           '</flgatras>' || '<dsidenti>' || vr_tab_dados_epr(vr_index).dsidenti ||
                           '</dsidenti>' || '<flgdigit>' ||
                           (CASE vr_tab_dados_epr(vr_index).flgdigit WHEN 1 THEN 'yes' ELSE 'no' END) ||
                           '</flgdigit>' || '<tpdocged>' || vr_tab_dados_epr(vr_index).tpdocged ||
                           '</tpdocged>' || '<vlpapgat>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlpapgat) || '</vlpapgat>' ||
                           '<vlsdevat>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlsdevat) ||
                           '</vlsdevat>' || '<qtpcalat>' || vr_tab_dados_epr(vr_index).qtpcalat ||
                           '</qtpcalat>' || '<qtmdecat>' || vr_tab_dados_epr(vr_index).qtmdecat ||
                           '</qtmdecat>' || '<tpdescto>' || vr_tab_dados_epr(vr_index).tpdescto ||
                           '</tpdescto>' || '<qtlemcal>' || vr_tab_dados_epr(vr_index).qtlemcal ||
                           '</qtlemcal>' || '<vlppagat>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlppagat) || '</vlppagat>' ||
                           '<vlmrapar>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlmrapar) ||
                           '</vlmrapar>' || '<vlmtapar>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlmtapar) || '</vlmtapar>' ||
                           '<vltotpag>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vltotpag) ||
                           '</vltotpag>' || '<vlprvenc>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlprvenc) || '</vlprvenc>' ||
                           '<vlpraven>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlpraven) ||
                           '</vlpraven>' || '<flgpreap>' ||
                           (CASE WHEN vr_tab_dados_epr(vr_index).flgpreap THEN 1 ELSE 0 END) || '</flgpreap>' ||
                           '<cdorigem>' || vr_tab_dados_epr(vr_index).cdorigem || '</cdorigem>' ||
                           '<vlttmupr>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlttmupr) ||
                           '</vlttmupr>' || '<vlttjmpr>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlttjmpr) || '</vlttjmpr>' ||
                           '<vlpgmupr>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlpgmupr) ||
                           '</vlpgmupr>' || '<vlpgjmpr>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlpgjmpr) || '</vlpgjmpr>' ||
                           '<liquidia>' || vr_tab_dados_epr(vr_index).liquidia || '</liquidia>' ||
                           '<qtimpctr>' || vr_tab_dados_epr(vr_index).qtimpctr || '</qtimpctr>' ||
                           '<portabil>' || vr_tab_dados_epr(vr_index).portabil || '</portabil>' ||
                           '<idfiniof>' || vr_tab_dados_epr(vr_index).idfiniof || '</idfiniof>' ||
                           '<vliofepr>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vliofepr) ||
                           '</vliofepr>' || '<vlrtarif>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlrtarif) || '</vlrtarif>' ||
                           '<vlrtotal>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vlrtotal) ||
                           '</vlrtotal>' || '<vliofcpl>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vliofcpl) || '</vliofcpl>' ||
                           '<vltiofpr>' || fn_convert_number_api(vr_tab_dados_epr(vr_index).vltiofpr) ||
                           '</vltiofpr>' || '<vlpiofpr>' ||
                           fn_convert_number_api(vr_tab_dados_epr(vr_index).vlpiofpr) || '</vlpiofpr>' ||
                           '<tpatuidx>' || vr_tab_dados_epr(vr_index).tpatuidx || '</tpatuidx>' ||
                           '<idcarenc>' || vr_tab_dados_epr(vr_index).idcarenc || '</idcarenc>' ||
                           '<dtcarenc>' || to_char(vr_tab_dados_epr(vr_index).dtcarenc, 'DD/MM/RRRR') ||
                           '</dtcarenc>' || '<nrdiacar>' || vr_tab_dados_epr(vr_index).nrdiacar ||
                           '</nrdiacar>' || '<qttolatr>' || vr_tab_dados_epr(vr_index).qttolatr ||
                           '</qttolatr>' || '<dsratpro>' || vr_tab_dados_epr(vr_index).dsratpro ||
                           '</dsratpro>' || '<dsratatu>' || vr_tab_dados_epr(vr_index).dsratatu ||
                           '</dsratatu>' || '<flintcdc>' || vr_tab_dados_epr(vr_index).flintcdc ||
                           '</flintcdc>' || '<cdoperad>' || vr_tab_dados_epr(vr_index).cdoperad ||
                           '</cdoperad>' || '<inintegra_cont>' || vr_tab_dados_epr(vr_index).inintegra_cont ||
                           '</inintegra_cont>' || '<tpfinali>' || vr_tab_dados_epr(vr_index).tpfinali ||
                           '</tpfinali>');
            pc_escreve_xml('</Root>', TRUE);
			vr_index := vr_tab_dados_epr.next(vr_index);
        END LOOP;

        pr_retxml := xmltype.createxml(vr_des_xml);
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
    EXCEPTION
        WHEN vr_exc_erro THEN
            -- Se foi retornado apenas código
            IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NULL THEN
                -- Buscar a descrição
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            END IF;
            --Variavel de erro recebe erro ocorrido
            pr_cdcritic := nvl(vr_cdcritic, 0);
            pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
        
            -- Montar descrição de erro não tratado
            pr_dscritic := 'Erro não tratado na empr0001_f8n.pc_obtem_dados_empresti_api ' || SQLERRM;
    END pc_obtem_dados_empresti_api;

END empr0001_f8n;
/
