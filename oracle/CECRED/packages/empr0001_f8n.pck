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
            -- Cursor genérico de calendário
            rw_crapdat btch0001.cr_crapdat%ROWTYPE;
        
            --Variaveis Erro
            vr_cdcritic INTEGER;
            vr_dscritic VARCHAR2(4000);
            vr_des_reto VARCHAR2(10);
        
            --Variaveis Excecao
            vr_exc_erro  EXCEPTION;
            vr_exc_saida EXCEPTION;
        
            -- variaveis de retorno
            vr_tab_erro gene0001.typ_tab_erro;
        
            -- Saida com erro opção 2
            vr_exc_erro_2 EXCEPTION;
        
            -- Rowid para inserção de log
            vr_nrdrowid ROWID;
        
            -- Variaveis internas
            vr_cdagenci crapass.cdagenci%TYPE := pr_cdagenci; --> Código da agencia
            vr_nrdcaixa craperr.nrdcaixa%TYPE := pr_nrdcaixa; --> Número do caixa
            vr_cdoperad crapope.cdoperad%TYPE := pr_cdoperad; --> Código do operador
            vr_nmdatela VARCHAR2(100) := pr_nmtela; --> Nome da tela
            vr_nrsequen craperr.nrsequen%TYPE := 1; --> Fixo
            vr_flgtrans craplgm.flgtrans%TYPE := 1; --> True
            vr_idorigem INTEGER := pr_cdorigem; --> Origem
            vr_idseqttl crapttl.idseqttl%TYPE := 1;
            vr_flgerlog VARCHAR2(1) := 'S';
            vr_vlpagpar NUMBER := 0; --> Valor a pagar;
        
            -- Indice para o Array de historicos
            vr_vllanmto craplem.vllanmto%TYPE;
            vr_vlsdeved NUMBER := 0; --> Saldo devedor
            vr_vlprepag NUMBER := 0; --> Qtde parcela paga
            vr_vlpreapg NUMBER := 0; --> Qtde parcela a pagar
            vr_vlpagsld NUMBER := 0; --> Valor pago saldo
            vr_vlsderel NUMBER := 0; --> Saldo para relatórios
            vr_vlsdvctr NUMBER := 0;
        
            -- Indica para a temp-table
            vr_ind_pag NUMBER;
        
            vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
            vr_tab_calculado   empr0001.typ_tab_calculado;
        
            -- Busca dos dados de empréstimo
            CURSOR cr_crapepr IS
                SELECT epr.cdlcremp
                      ,epr.txmensal
                      ,epr.dtdpagto
                      ,epr.qtprecal
                      ,epr.vlemprst
                      ,epr.qtpreemp
                      ,epr.inliquid
                      ,epr.idfiniof
                      ,epr.vliofepr
                      ,epr.vltarifa
                      ,epr.vlsdeved
                  FROM crapepr epr
                 WHERE epr.cdcooper = pr_cdcooper
                   AND epr.nrdconta = pr_nrdconta
                   AND epr.nrctremp = pr_nrctremp;
            rw_crapepr cr_crapepr%ROWTYPE;
            -- Busca dos dados de complemento do empréstimo
            CURSOR cr_crawepr IS
                SELECT epr.dtlibera
                      ,epr.idfiniof
                  FROM crawepr epr
                 WHERE epr.cdcooper = pr_cdcooper
                   AND epr.nrdconta = pr_nrdconta
                   AND epr.nrctremp = pr_nrctremp;
            rw_crawepr cr_crawepr%ROWTYPE;
        
            -- Buscar todas as parcelas de pagamento
            -- do empréstimo e seus valores
            CURSOR cr_crappep IS
                SELECT pep.cdcooper
                      ,pep.nrdconta
                      ,pep.nrctremp
                      ,pep.nrparepr
                      ,pep.vlparepr
                      ,pep.vljinpar
                      ,pep.vlmrapar
                      ,pep.vliofcpl
                      ,pep.vlmtapar
                      ,pep.dtvencto
                      ,pep.dtultpag
                      ,pep.vlpagpar
                      ,pep.vlpagmta
                      ,pep.vlpagmra
                      ,pep.vldespar
                      ,pep.vlsdvpar
                      ,pep.inliquid
                  FROM crappep pep
                 WHERE pep.cdcooper = pr_cdcooper
                   AND pep.nrdconta = pr_nrdconta
                   AND pep.nrctremp = pr_nrctremp
                   AND pep.inliquid = 0 -- Não liquidada
                   AND (pr_nrparepr = 0 OR pep.nrparepr = pr_nrparepr); -- Traz todas quando zero, ou somente a passada
        
            -- Buscar o total pago no mês
            CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                             ,pr_nrdconta IN craplem.nrdconta%TYPE
                             ,pr_nrctremp IN craplem.nrctremp%TYPE
                             ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
            
                SELECT /*+ INDEX (lem CRAPLEM##CRAPLEM7) */
                 SUM(decode(lem.cdhistor
                           ,1044
                           ,lem.vllanmto
                           ,1039
                           ,lem.vllanmto
                           ,1045
                           ,lem.vllanmto
                           ,1057
                           ,lem.vllanmto
                           ,1716
                           ,lem.vllanmto * -1
                           ,1707
                           ,lem.vllanmto * -1
                           ,1714
                           ,lem.vllanmto * -1
                           ,1705
                           ,lem.vllanmto * -1)) AS vllanmto
                  FROM craplem lem
                 WHERE lem.cdcooper = pr_cdcooper
                   AND lem.nrdconta = pr_nrdconta
                   AND lem.nrctremp = pr_nrctremp
                   AND lem.nrdolote IN (600012, 600013, 600031)
                   AND lem.cdhistor IN (1039, 1057, 1044, 1045, 1716, 1707, 1714, 1705)
                   AND to_char(lem.dtmvtolt, 'MMRRRR') = to_char(pr_dtmvtolt, 'MMRRRR');
        
            rw_craplem cr_craplem%ROWTYPE;
        
        BEGIN
            -- Leitura do calendário da cooperativa
            OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
            FETCH btch0001.cr_crapdat
                INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;
        
            --Limpar Tabelas Memoria
            vr_tab_erro.delete;
            vr_tab_pgto_parcel.delete;
            vr_tab_calculado.delete;
        
            -- Criar um bloco para faciliar o tratamento de erro
            BEGIN
                -- Busca detalhes do empréstimo
                OPEN cr_crapepr;
                FETCH cr_crapepr
                    INTO rw_crapepr;
                -- Se não tiver encontrado
                IF cr_crapepr%NOTFOUND THEN
                    -- Fechar o cursor e gerar critica
                    CLOSE cr_crapepr;
                    vr_cdcritic := 356;
                    RAISE vr_exc_erro;
                ELSE
                    -- fechar o cursor e continuar o processo
                    CLOSE cr_crapepr;
                END IF;
                -- Busca dados complementares do empréstimo
                OPEN cr_crawepr;
                FETCH cr_crawepr
                    INTO rw_crawepr;
                -- Se não tiver encontrado
                IF cr_crawepr%NOTFOUND THEN
                    -- Fechar o cursor e gerar critica
                    CLOSE cr_crawepr;
                    vr_cdcritic := 535;
                    RAISE vr_exc_erro;
                ELSE
                    -- fechar o cursor e continuar o processo
                    CLOSE cr_crawepr;
                END IF;
            
                -- Buscar todas as parcelas de pagamento
                -- do empréstimo e seus valores
                FOR rw_crappep IN cr_crappep LOOP
                    -- Criar um novo indice para a temp-table
                    vr_ind_pag := vr_tab_pgto_parcel.count() + 1;
                    -- Copiar as informações da tabela para a temp-table
                    vr_tab_pgto_parcel(vr_ind_pag).cdcooper := rw_crappep.cdcooper;
                    vr_tab_pgto_parcel(vr_ind_pag).nrdconta := rw_crappep.nrdconta;
                    vr_tab_pgto_parcel(vr_ind_pag).nrctremp := rw_crappep.nrctremp;
                    vr_tab_pgto_parcel(vr_ind_pag).nrparepr := rw_crappep.nrparepr;
                    vr_tab_pgto_parcel(vr_ind_pag).vlparepr := rw_crappep.vlparepr;
                    vr_tab_pgto_parcel(vr_ind_pag).vljinpar := rw_crappep.vljinpar;
                    vr_tab_pgto_parcel(vr_ind_pag).vlmrapar := rw_crappep.vlmrapar;
                    vr_tab_pgto_parcel(vr_ind_pag).vlmtapar := rw_crappep.vlmtapar;
                    vr_tab_pgto_parcel(vr_ind_pag).vliofcpl := rw_crappep.vliofcpl;
                    vr_tab_pgto_parcel(vr_ind_pag).dtvencto := rw_crappep.dtvencto;
                    vr_tab_pgto_parcel(vr_ind_pag).dtultpag := rw_crappep.dtultpag;
                    vr_tab_pgto_parcel(vr_ind_pag).vlpagpar := rw_crappep.vlpagpar;
                    vr_tab_pgto_parcel(vr_ind_pag).vlpagmta := rw_crappep.vlpagmta;
                    vr_tab_pgto_parcel(vr_ind_pag).vlpagmra := rw_crappep.vlpagmra;
                    vr_tab_pgto_parcel(vr_ind_pag).vldespar := rw_crappep.vldespar;
                    vr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := rw_crappep.vlsdvpar;
                    vr_tab_pgto_parcel(vr_ind_pag).inliquid := rw_crappep.inliquid;
                
                    -- Se ainda não foi liberado
                    IF pr_dtmvtolt <= rw_crawepr.dtlibera THEN
                        /* Nao liberado */
                        vr_tab_pgto_parcel(vr_ind_pag).vlatupar := rw_crapepr.vlemprst / rw_crapepr.qtpreemp;
                        vr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := vr_tab_pgto_parcel(vr_ind_pag).vlatupar;
                        vr_tab_pgto_parcel(vr_ind_pag).vlatrpag := vr_tab_pgto_parcel(vr_ind_pag).vlatupar;
                        -- Guardar quantidades calculadas
                        vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
                    
                        -- Se a parcela ainda não venceu
                    ELSIF rw_crappep.dtvencto > rw_crapdat.dtmvtoan AND rw_crappep.dtvencto <= pr_dtmvtolt THEN
                        -- Parcela em dia
                        vr_tab_pgto_parcel(vr_ind_pag).vlatupar := rw_crappep.vlsdvpar;
                        -- Guardar quantidades calculadas
                        vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
                    
                        /* A regularizar */
                        vr_vlpreapg := vr_vlpreapg + vr_tab_pgto_parcel(vr_ind_pag).vlatupar;
                        -- Se a parcela está vencida
                    ELSIF rw_crappep.dtvencto < pr_dtmvtolt THEN
                        -- Calculo de valor atualizado de parcelas de empréstimo em atraso
                        empr0001.pc_calc_atraso_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                       ,pr_cdagenci => vr_cdagenci --> Código da agência
                                                       ,pr_nrdcaixa => vr_nrdcaixa --> Número do caixa
                                                       ,pr_cdoperad => vr_cdoperad --> Código do Operador
                                                       ,pr_nmdatela => vr_nmdatela --> Nome da tela
                                                       ,pr_idorigem => vr_idorigem --> Id do módulo de sistema
                                                       ,pr_nrdconta => pr_nrdconta --> Número da conta
                                                       ,pr_idseqttl => vr_idseqttl --> Seq titula
                                                       ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                                       ,pr_flgerlog => vr_flgerlog --> Indicador S/N para geração de log
                                                       ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                                       ,pr_nrparepr => rw_crappep.nrparepr --> Número parcelas empréstimo
                                                       ,pr_vlpagpar => vr_vlpagpar --> Valor a pagar originalmente
                                                       ,pr_vlpagsld => vr_vlpagsld --> Saldo a pagar após multa e juros
                                                       ,pr_vlatupar => vr_tab_pgto_parcel(vr_ind_pag).vlatupar --> Valor atual da parcela
                                                       ,pr_vlmtapar => vr_tab_pgto_parcel(vr_ind_pag).vlmtapar --> Valor de multa
                                                       ,pr_vljinpar => vr_tab_pgto_parcel(vr_ind_pag).vljinpar --> Valor dos juros
                                                       ,pr_vlmrapar => vr_tab_pgto_parcel(vr_ind_pag).vlmrapar --> Valor de mora
                                                       ,pr_vliofcpl => vr_tab_pgto_parcel(vr_ind_pag).vliofcpl --> Valor de mora
                                                       ,pr_vljinp59 => vr_tab_pgto_parcel(vr_ind_pag).vljinp59 --> Juros quando período inferior a 59 dias
                                                       ,pr_vljinp60 => vr_tab_pgto_parcel(vr_ind_pag).vljinp60 --> Juros quando período igual ou superior a 60 dias
                                                       ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                                       ,pr_tab_erro => vr_tab_erro); --> Tabela com possíveis erros
                        -- Testar erro
                        IF vr_des_reto = 'NOK' THEN
                            -- Levantar exceção 2, onde já temos o erro na vr_tab_erro
                            RAISE vr_exc_erro_2;
                        END IF;
                        -- Acumular o valor a regularizar
                        vr_vlpreapg := vr_vlpreapg + vr_tab_pgto_parcel(vr_ind_pag).vlatupar;
                        -- Guardar quantidades calculadas
                        vr_vlsdvctr := vr_vlsdvctr + vr_tab_pgto_parcel(vr_ind_pag).vlatupar;
                    
                        -- Antecipação de parcela
                    ELSIF rw_crappep.dtvencto > pr_dtmvtolt THEN
                        -- Procedure para calcular valor antecipado de parcelas de empréstimo
                        empr0001.pc_calc_antecipa_parcela(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                         ,pr_cdagenci => vr_cdagenci --> Código da agência
                                                         ,pr_nrdcaixa => vr_nrdcaixa --> Número do caixa
                                                         ,pr_dtvencto => rw_crappep.dtvencto --> Data do vencimento
                                                         ,pr_vlsdvpar => rw_crappep.vlsdvpar --> Valor devido parcela
                                                         ,pr_txmensal => rw_crapepr.txmensal --> Taxa aplicada ao empréstimo
                                                         ,pr_dtmvtolt => pr_dtmvtolt --> Data do movimento atual
                                                         ,pr_dtdpagto => rw_crapepr.dtdpagto --> Data de pagamento
                                                         ,pr_vlatupar => vr_tab_pgto_parcel(vr_ind_pag)
                                                                         .vlatupar --> Valor atualizado da parcela
                                                         ,pr_vldespar => vr_tab_pgto_parcel(vr_ind_pag)
                                                                         .vldespar --> Valor desconto da parcela
                                                         ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                                         ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
                        -- Testar erro
                        IF vr_des_reto = 'NOK' THEN
                            -- Levantar exceção 2, onde já temos o erro na vr_tab_erro
                            RAISE vr_exc_erro_2;
                        END IF;
                        -- Iniciar valor da flag
                        vr_tab_pgto_parcel(vr_ind_pag).flgantec := TRUE;
                        -- Guardar quantidades calculadas
                        vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
                    END IF;
                    -- Somente calcular se o empréstimo estiver liberado
                    IF NOT pr_dtmvtolt <= rw_crawepr.dtlibera THEN
                        /* Se liberado */
                        -- Saldo devedor
                        vr_tab_pgto_parcel(vr_ind_pag).vlsdvpar := rw_crappep.vlsdvpar;
                    
                        vr_tab_pgto_parcel(vr_ind_pag).vlatrpag := nvl(vr_tab_pgto_parcel(vr_ind_pag).vlatupar
                                                                      ,0) +
                                                                   nvl(vr_tab_pgto_parcel(vr_ind_pag).vlmtapar
                                                                      ,0) +
                                                                   nvl(vr_tab_pgto_parcel(vr_ind_pag).vlmrapar
                                                                      ,0) +
                                                                   nvl(vr_tab_pgto_parcel(vr_ind_pag).vliofcpl
                                                                      ,0);
                        -- Saldo para relatorios
                        vr_vlsderel := vr_vlsderel + vr_tab_pgto_parcel(vr_ind_pag).vlatupar;
                        -- Saldo devedor total do emprestimo
                        vr_vlsdeved := vr_vlsdeved + vr_tab_pgto_parcel(vr_ind_pag).vlatrpag;
                    END IF;
                END LOOP;
            
                -- Limpar a variável
                vr_vllanmto := 0;
            
                -- Buscar o total pago no mês
                OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctremp
                               ,pr_dtmvtolt => pr_dtmvtolt);
            
                FETCH cr_craplem
                    INTO rw_craplem;
                IF cr_craplem%FOUND THEN
                    vr_vllanmto := nvl(vr_vllanmto, 0) + nvl(rw_craplem.vllanmto, 0);
                END IF;
                -- Fechar o cursor
                CLOSE cr_craplem;
            
                -- Adicionar o valor encontrado no valor pago
                vr_vlprepag := vr_vlprepag + nvl(vr_vllanmto, 0);
                -- Se o empréstimo ainda não estiver liberado e não esteja liquidado
                IF pr_dtmvtolt <= rw_crawepr.dtlibera AND rw_crapepr.inliquid <> 1 THEN
                    /* Nao liberado */
                    -- Continuar com os valores da tabela
                    vr_tab_calculado(1).vlsdeved := rw_crapepr.vlemprst;
                    vr_tab_calculado(1).vlsderel := rw_crapepr.vlemprst;
                    vr_tab_calculado(1).vlsdvctr := rw_crapepr.vlemprst;
                
                    -- Zerar prestações pagas e a pagar
                    vr_tab_calculado(1).vlprepag := 0;
                    vr_tab_calculado(1).vlpreapg := 0;
                ELSE
                    -- Utilizar informações do cálculo
                    vr_tab_calculado(1).vlsdeved := vr_vlsdeved;
                    vr_tab_calculado(1).vlsderel := vr_vlsderel;
                    vr_tab_calculado(1).vlsdvctr := vr_vlsdvctr;
                
                    vr_tab_calculado(1).vlprepag := vr_vlprepag;
                    vr_tab_calculado(1).vlpreapg := vr_vlpreapg;
                END IF;
            
                -- Copiar qtde prestações calculadas
                vr_tab_calculado(1).qtprecal := rw_crapepr.qtprecal;
            
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
                WHEN vr_exc_erro THEN
                    -- Retorno não OK
                    -- Se foi retornado apenas código
                    IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NULL THEN
                        -- Buscar a descrição
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                    END IF;
                
                    --Variavel de erro recebe erro ocorrido
                    pr_cdcritic := nvl(vr_cdcritic, 0);
                    pr_dscritic := vr_dscritic;
                
                    -- Gerar rotina de gravação de erro
                    gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => vr_cdagenci
                                         ,pr_nrdcaixa => vr_nrdcaixa
                                         ,pr_nrsequen => vr_nrsequen
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_tab_erro => vr_tab_erro);
                WHEN vr_exc_erro_2 THEN
                    -- Retorno não OK
                    pr_cdcritic := vr_tab_erro(1).cdcritic;
                    pr_dscritic := vr_tab_erro(1).dscritic;
            END;
            -- Se foi solicitado o envio de LOG
            -- Gerar LOG de envio do e-mail
            gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => ''
                                ,pr_dsorigem => gene0001.vr_vet_des_origens(5) --> Origem enviada
                                ,pr_dstransa => 'Busca pagamentos de parcelas'
                                ,pr_dttransa => pr_dtmvtolt
                                ,pr_flgtrans => vr_flgtrans --> TRUE
                                ,pr_hrtransa => to_number(to_char(SYSDATE, 'SSSSS'))
                                ,pr_idseqttl => vr_idseqttl
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
        EXCEPTION
            WHEN OTHERS THEN
                -- Retorno não OK
                -- Se foi retornado apenas código
                IF nvl(vr_cdcritic, 0) > 0 AND vr_dscritic IS NULL THEN
                    -- Buscar a descrição
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                ELSE
                    -- Montar descrição de erro não tratado
                    vr_dscritic := 'Erro não tratado na empr0001.pc_busca_pgto_parcelas> ' || SQLERRM;
                END IF;
            
                --Variavel de erro recebe erro ocorrido
                pr_cdcritic := nvl(vr_cdcritic, 0);
                pr_dscritic := vr_dscritic;
            
                -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => vr_cdagenci
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_nrsequen => vr_nrsequen --> Fixo
                                     ,pr_cdcritic => vr_cdcritic
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
