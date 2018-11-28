CREATE OR REPLACE PACKAGE CECRED.TELA_CONFRP AS

    /*..............................................................................
    
       Programa: tela_confrp                        Antigo: Nao ha
       Sistema : Ayllos
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Fevereiro/2016                      Ultima atualizacao: --/--/----
    
       Dados referentes ao programa:
    
       Frequencia: -------------------
       Objetivo  : Centralizar as rotinas referente a tela CONFRP
    
       Alteracoes: 
      
    ..............................................................................*/

    /* Buscar configuracao de calculo de reprocidade */
    PROCEDURE pc_busca_conf_reciprocidade(pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                         ,pr_inpessoa           IN tbrecip_parame_indica_coop.inpessoa%TYPE
                                         ,pr_cdproduto          IN tbrecip_parame_indica_coop.cdproduto%TYPE
                                         ,pr_cdcooper           IN crapcop.cdcooper%TYPE
                                         ,pr_xmllog             IN VARCHAR2 --XML com informações de LOG
                                         ,pr_cdcritic           OUT PLS_INTEGER --Código da crítica
                                         ,pr_dscritic           OUT VARCHAR2 --Descrição da crítica
                                         ,pr_retxml             IN OUT NOCOPY xmltype --Arquivo de retorno do XML
                                         ,pr_nmdcampo           OUT VARCHAR2 --Nome do Campo
                                         ,pr_des_erro           OUT VARCHAR2); --Saida OK/NOK

    /* Salva configuracao de calculo de reprocidade */
    PROCEDURE pc_confirma_conf_reciprocidade(pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                            ,pr_configrp           IN VARCHAR2
                                            ,pr_vinculacoesrp      IN VARCHAR2
                                            ,pr_vldescontomax_coo  IN tbrecip_parame_calculo.vldesconto_maximo_coo%TYPE
                                            ,pr_vldescontomax_cee  IN tbrecip_parame_calculo.vldesconto_maximo_cee%TYPE
                                            ,pr_cdcooper           IN crapcop.cdcooper%TYPE
                                            ,pr_xmllog             IN VARCHAR2 --XML com informações de LOG
                                            ,pr_cdcritic           OUT PLS_INTEGER --Código da crítica
                                            ,pr_dscritic           OUT VARCHAR2 --Descrição da crítica
                                            ,pr_retxml             IN OUT NOCOPY xmltype --Arquivo de retorno do XML
                                            ,pr_nmdcampo           OUT VARCHAR2 --Nome do Campo
                                            ,pr_des_erro           OUT VARCHAR2); --Saida OK/NOK

END TELA_CONFRP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONFRP AS

    /*..............................................................................
    
       Programa: tela_confrp                        Antigo: Nao ha
       Sistema : Ayllos
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Fevereiro/2016                      Ultima atualizacao: --/--/----
    
       Dados referentes ao programa:
    
       Frequencia: -------------------
       Objetivo  : Centralizar as rotinas referente a tela CONFRP
    
       Alteracoes: 
      
    ..............................................................................*/

    /* Buscar configuracao de calculo de reprocidade */
    PROCEDURE pc_busca_conf_reciprocidade(pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                         ,pr_inpessoa           IN tbrecip_parame_indica_coop.inpessoa%TYPE
                                         ,pr_cdproduto          IN tbrecip_parame_indica_coop.cdproduto%TYPE
                                         ,pr_cdcooper           IN crapcop.cdcooper%TYPE
                                         ,pr_xmllog             IN VARCHAR2 --XML com informações de LOG
                                         ,pr_cdcritic           OUT PLS_INTEGER --Código da crítica
                                         ,pr_dscritic           OUT VARCHAR2 --Descrição da crítica
                                         ,pr_retxml             IN OUT NOCOPY xmltype --Arquivo de retorno do XML
                                         ,pr_nmdcampo           OUT VARCHAR2 --Nome do Campo
                                         ,pr_des_erro           OUT VARCHAR2) IS
        --Saida OK/NOK
        ---------------------------------------------------------------------------------------------------------------
        --
        --  Programa : pc_busca_conf_reciprocidade                  Antigo: Não há
        --  Sistema  : Ayllos
        --  Sigla    : CRED
        --  Autor    : Lucas Lombardi
        --  Data     : Março/2016.                   Ultima atualizacao: --/--/----
        --
        -- Dados referentes ao programa:
        --
        -- Frequencia: Sempre que for chamado
        -- Objetivo  : Buscar configuracao de calculo de reprocidade.
        ---------------------------------------------------------------------------------------------------------------
    
        -- Busca dos valores previstos
        CURSOR cr_desconto_maximo(pr_idparame_reciproci tbrecip_parame_calculo.idparame_reciproci%TYPE) IS
            SELECT prc.perdesconto_maximo
                  ,prc.vldesconto_maximo_cee
                  ,prc.vldesconto_maximo_coo
              FROM tbrecip_parame_calculo prc
             WHERE prc.idparame_reciproci = pr_idparame_reciproci;
        rw_desconto_maximo cr_desconto_maximo%ROWTYPE;
    
        -- Busca das faixas parametrizadas
        CURSOR cr_parametrizacao(pr_idparame_reciproci tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                ,pr_inpessoa           tbrecip_parame_indica_coop.inpessoa%TYPE
                                ,pr_cdproduto          tbrecip_parame_indica_coop.cdproduto%TYPE
                                ,pr_cdcooper           crapcop.cdcooper%TYPE) IS
            SELECT 1 flgativo -- Se veio da tabela está sempre ativo
                  ,irc.idindicador
                  ,irc.nmindicador
                  ,decode(irc.tpindicador, 'A', 'Adesão', 'Q', 'Quantidade', 'Moeda') tpindicador
                  ,ipr.vlminimo
                  ,ipr.vlmaximo
                  ,ipr.perscore
                  ,ipr.pertolera
                  ,ipr.vlpercentual_peso
                  ,ipr.vlpercentual_desconto
              FROM tbrecip_parame_indica_calculo ipr
                  ,tbrecip_indicador             irc
             WHERE ipr.idparame_reciproci = pr_idparame_reciproci
               AND ipr.idindicador = irc.idindicador
            UNION
            SELECT 0 flgativo -- Não selecionado
                  ,irc.idindicador
                  ,irc.nmindicador
                  ,decode(irc.tpindicador, 'A', 'Adesão', 'Q', 'Quantidade', 'Moeda') tpindicador
                  ,ico.vlminimo
                  ,ico.vlmaximo
                  ,ico.perscore
                  ,ico.pertolera
                  ,ico.vlpercentual_peso
                  ,ico.vlpercentual_desconto
              FROM tbrecip_indicador          irc
                  ,tbrecip_parame_indica_coop ico
             WHERE ico.idindicador = irc.idindicador
               AND ico.cdcooper = pr_cdcooper
               AND irc.flgativo = 1 --> Ativo globalmente
               AND ico.inpessoa = pr_inpessoa --> Tipo da pessoa atual
               AND ico.cdproduto = pr_cdproduto --> Código do produto atual
                  -- E o mesmo não está selecionado no cálculo atual
               AND NOT EXISTS (SELECT 1
                      FROM tbrecip_parame_indica_calculo prc
                     WHERE prc.idparame_reciproci = pr_idparame_reciproci
                       AND prc.idindicador = irc.idindicador)
            
             ORDER BY flgativo DESC
                     ,idindicador;
    
        -- Busca das faixas parametrizadas
        CURSOR cr_parametrizacao_2(pr_inpessoa  tbrecip_parame_indica_coop.inpessoa%TYPE
                                  ,pr_cdproduto tbrecip_parame_indica_coop.cdproduto%TYPE
                                  ,pr_cdcooper  crapcop.cdcooper%TYPE) IS
            SELECT 0 flgativo -- Não selecionado
                  ,irc.idindicador
                  ,irc.nmindicador
                  ,decode(irc.tpindicador, 'A', 'Adesão', 'Q', 'Quantidade', 'Moeda') tpindicador
                  ,ico.vlminimo
                  ,ico.vlmaximo
                  ,ico.perscore
                  ,ico.pertolera
              FROM tbrecip_indicador          irc
                  ,tbrecip_parame_indica_coop ico
             WHERE ico.idindicador = irc.idindicador
               AND ico.cdcooper = pr_cdcooper
               AND irc.flgativo = 1 --> Ativo globalmente
               AND ico.inpessoa = pr_inpessoa --> Tipo da pessoa atual
               AND ico.cdproduto = pr_cdproduto --> Código do produto atual
            
             ORDER BY irc.idindicador;
    
        -- Busca as parametrizações
        CURSOR cr_vinculacao(pr_idparame_reciproci tbrecip_vinculacao_parame.idparame_reciproci%TYPE) IS
            SELECT tvc.idvinculacao_reciproci
                  ,tvc.vlpercentual_desconto
                  ,tvc.vlpercentual_peso
                  ,0                          flgativo
                  ,tv.nmvinculacao
              FROM tbrecip_vinculacao_parame_coop tvc
                  ,tbrecip_vinculacao             tv
             WHERE tvc.idvinculacao_reciproci = tv.idvinculacao
               AND tvc.inpessoa = 1
               AND tvc.cdproduto = 6
               AND NOT EXISTS (SELECT 1
                      FROM tbrecip_vinculacao_parame tvp
                     WHERE tvp.idparame_reciproci = pr_idparame_reciproci
                       AND tvp.idvinculacao_reciproci = tvc.idvinculacao_reciproci)           
            UNION
            SELECT tvp.idvinculacao_reciproci
                  ,tvp.vlpercentual_desconto
                  ,tvp.vlpercentual_peso
                  ,1 flgativo
                  ,tv.nmvinculacao
              FROM tbrecip_vinculacao_parame tvp
                  ,tbrecip_vinculacao        tv
             WHERE tvp.idparame_reciproci = pr_idparame_reciproci
               AND tvp.idvinculacao_reciproci = tv.idvinculacao;
        rw_vinculacao cr_vinculacao%ROWTYPE;
    
        -- Variáveis genéricas
        vr_vldescontomax_cee    NUMBER;
        vr_vldescontomax_coo    NUMBER;
        vr_contador             INTEGER;
        vr_contador_vinculacoes INTEGER;
        vr_vlminimo             VARCHAR2(100);
        vr_vlmaximo             VARCHAR2(100);
        vr_pertolera            VARCHAR2(100);
        vr_peso                 VARCHAR2(100);
        vr_desconto             VARCHAR2(100);
    
        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        --Variaveis de Criticas
        vr_dscritic VARCHAR2(4000);
    
        --Variaveis de Excecoes
        vr_exc_erro EXCEPTION;
    
    BEGIN
        --------------- VALIDACOES INICIAIS -----------------
        -- Incluir nome do módulo logado
        gene0001.pc_informa_acesso(pr_module => 'RCIP0001', pr_action => NULL);
    
        --Inicializar Variaveis
        vr_dscritic := NULL;
    
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
    
        -- Buscar o valor o percentual máximo de desconto ao cálculo.
        OPEN cr_desconto_maximo(pr_idparame_reciproci);
        FETCH cr_desconto_maximo
            INTO rw_desconto_maximo;
    
        IF cr_desconto_maximo%FOUND THEN
            vr_vldescontomax_cee := rw_desconto_maximo.vldesconto_maximo_cee;
            vr_vldescontomax_coo := rw_desconto_maximo.vldesconto_maximo_coo;
        ELSE
            vr_vldescontomax_cee := 0;
            vr_vldescontomax_coo := 0;
        END IF;
    
        -- Criar cabeçalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Config'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
    
        vr_contador := 0;
        -- Buscar a parametrização já cadastrada.
        FOR rw_parametrizacao IN cr_parametrizacao(pr_idparame_reciproci
                                                  ,pr_inpessoa
                                                  ,pr_cdproduto
                                                  ,pr_cdcooper) LOOP
            IF rw_parametrizacao.tpindicador = 'Adesão' THEN
                vr_vlminimo  := '-';
                vr_vlmaximo  := '-';
                vr_pertolera := '-';
                vr_peso      := '-';
                vr_desconto  := '-';
            ELSE
                vr_vlminimo  := rcip0001.fn_format_valor_indicador(rw_parametrizacao.idindicador
                                                                  ,rw_parametrizacao.vlminimo);
                vr_vlmaximo  := rcip0001.fn_format_valor_indicador(rw_parametrizacao.idindicador
                                                                  ,rw_parametrizacao.vlmaximo);
                vr_pertolera := to_char(nvl(rw_parametrizacao.pertolera, 0), 'fm990d00');
                vr_peso      := to_char(nvl(rw_parametrizacao.vlpercentual_peso, 0), 'fm990d00');
                vr_desconto  := to_char(nvl(rw_parametrizacao.vlpercentual_desconto, 0), 'fm990d00');
            END IF;
        
            -- Insere as tags dos campos da PLTABLE de aplicações
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Config'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Reg'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'flgativo'
                                  ,pr_tag_cont => rw_parametrizacao.flgativo
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'idindicador'
                                  ,pr_tag_cont => rw_parametrizacao.idindicador
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'nmindicador'
                                  ,pr_tag_cont => rw_parametrizacao.nmindicador
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'tpindicador'
                                  ,pr_tag_cont => rw_parametrizacao.tpindicador
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'vlminimo'
                                  ,pr_tag_cont => vr_vlminimo
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'vlmaximo'
                                  ,pr_tag_cont => vr_vlmaximo
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'perscore'
                                  ,pr_tag_cont => to_char(nvl(rw_parametrizacao.perscore, 0), 'fm990d00')
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'pertolera'
                                  ,pr_tag_cont => vr_pertolera
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'peso'
                                  ,pr_tag_cont => vr_peso
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Reg'
                                  ,pr_posicao  => vr_contador
                                  ,pr_tag_nova => 'desconto'
                                  ,pr_tag_cont => vr_desconto
                                  ,pr_des_erro => vr_dscritic);
            vr_contador := vr_contador + 1;
        END LOOP;
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'QtdRegist'
                              ,pr_tag_cont => vr_contador
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Vinculacoes'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
        vr_contador_vinculacoes := 0;
        -- Buscar a vinculação
        FOR rw_vinculacao IN cr_vinculacao(pr_idparame_reciproci) LOOP
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Vinculacoes'
                                  ,pr_posicao  => 0
                                  ,pr_tag_nova => 'Vinculacao'
                                  ,pr_tag_cont => NULL
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Vinculacao'
                                  ,pr_posicao  => vr_contador_vinculacoes
                                  ,pr_tag_nova => 'flgativa'
                                  ,pr_tag_cont => rw_vinculacao.flgativo
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Vinculacao'
                                  ,pr_posicao  => vr_contador_vinculacoes
                                  ,pr_tag_nova => 'idvinculacao'
                                  ,pr_tag_cont => rw_vinculacao.idvinculacao_reciproci
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Vinculacao'
                                  ,pr_posicao  => vr_contador_vinculacoes
                                  ,pr_tag_nova => 'nmvinculacao'
                                  ,pr_tag_cont => rw_vinculacao.nmvinculacao
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Vinculacao'
                                  ,pr_posicao  => vr_contador_vinculacoes
                                  ,pr_tag_nova => 'vlpercentual_desconto'
                                  ,pr_tag_cont => to_char(nvl(rw_vinculacao.vlpercentual_desconto, 0)
                                                         ,'fm990d00')
                                  ,pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml      => pr_retxml
                                  ,pr_tag_pai  => 'Vinculacao'
                                  ,pr_posicao  => vr_contador_vinculacoes
                                  ,pr_tag_nova => 'vlpercentual_peso      '
                                  ,pr_tag_cont => to_char(nvl(rw_vinculacao.vlpercentual_peso, 0), 'fm990d00')
                                  ,pr_des_erro => vr_dscritic);
            vr_contador_vinculacoes := vr_contador_vinculacoes + 1;
        END LOOP;
    
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'VlcustoCee'
                              ,pr_tag_cont => to_char(nvl(vr_vldescontomax_cee, 0), 'fm990d00')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'VlcustoCoo'
                              ,pr_tag_cont => to_char(nvl(vr_vldescontomax_coo, 0), 'fm990d00')
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'QtdVinculacoes'
                              ,pr_tag_cont => vr_contador_vinculacoes
                              ,pr_des_erro => vr_dscritic);
    
        --Retorno
        pr_des_erro := 'OK';
    
    EXCEPTION
        WHEN vr_exc_erro THEN
            -- Erro tratado
            pr_dscritic := 'TELA_CONFRP..pc_busca_conf_reciprocidade --> ' || vr_dscritic;
            pr_des_erro := 'NOK';
            pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                             pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        WHEN OTHERS THEN
            -- Erro não tratado
            pr_dscritic := 'TELA_CONFRP..pc_busca_conf_reciprocidade --> Erro não tratado: ' || SQLERRM;
            pr_des_erro := 'NOK';
            pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                             pr_dscritic || '</Erro></Root>');
            ROLLBACK;
    END pc_busca_conf_reciprocidade;

    /* Salva configuracao de calculo de reprocidade */
    PROCEDURE pc_confirma_conf_reciprocidade(pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                            ,pr_configrp           IN VARCHAR2
                                            ,pr_vinculacoesrp      IN VARCHAR2
                                            ,pr_vldescontomax_coo  IN tbrecip_parame_calculo.vldesconto_maximo_coo%TYPE
                                            ,pr_vldescontomax_cee  IN tbrecip_parame_calculo.vldesconto_maximo_cee%TYPE
                                            ,pr_cdcooper           IN crapcop.cdcooper%TYPE
                                            ,pr_xmllog             IN VARCHAR2 --XML com informações de LOG
                                            ,pr_cdcritic           OUT PLS_INTEGER --Código da crítica
                                            ,pr_dscritic           OUT VARCHAR2 --Descrição da crítica
                                            ,pr_retxml             IN OUT NOCOPY xmltype --Arquivo de retorno do XML
                                            ,pr_nmdcampo           OUT VARCHAR2 --Nome do Campo
                                            ,pr_des_erro           OUT VARCHAR2) IS
        --Saida OK/NOK
        ---------------------------------------------------------------------------------------------------------------
        --
        --  Programa : pc_confirma_conf_reciprocidade                Antigo: Não há
        --  Sistema  : Ayllos
        --  Sigla    : CRED
        --  Autor    : Lucas Lombardi
        --  Data     : Março/2016.                   Ultima atualizacao: --/--/----
        --
        -- Dados referentes ao programa:
        --
        -- Frequencia: Sempre que for chamado
        -- Objetivo  : Gravar configuração para um cálculo de reciprocidade 
        --             futuro ou alterar um cálculo pré-existente.
        ---------------------------------------------------------------------------------------------------------------
        CURSOR cr_procura_parame(pr_idparame_reciproci IN tbrecip_parame_indica_calculo.idparame_reciproci%TYPE
                                ,pr_idindicador        IN tbrecip_parame_indica_calculo.idindicador%TYPE) IS
            SELECT tpv.vlminimo
                  ,tpv.vlmaximo
                  ,tpv.vlpercentual_peso
                  ,tpv.vlpercentual_desconto
              FROM tbrecip_parame_indica_calculo tpv
             WHERE idparame_reciproci = pr_idparame_reciproci
               AND idindicador = pr_idindicador;
        rw_procura_parame cr_procura_parame%ROWTYPE;
    
        CURSOR cr_convenios_semelhantes(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
            SELECT conv.nrconven
                  ,conv.idprmrec
                  ,conv.cdcooper
              FROM crapcco conv
             WHERE conv.cdcooper = pr_cdcooper
               AND conv.flgativo = 1
               AND conv.flrecipr = 1
               AND conv.dsorgarq NOT IN ('PROTESTO');
        rw_convenios_semelhantes cr_convenios_semelhantes%ROWTYPE;
    
        CURSOR cr_procura_vinculacao(pr_idparame_reciproci     IN tbrecip_vinculacao_parame.idparame_reciproci%TYPE
                                    ,pr_idvinculacao_reciproci IN tbrecip_vinculacao_parame.idvinculacao_reciproci%TYPE) IS
            SELECT tvp.vlpercentual_desconto
                  ,tvp.vlpercentual_peso
              FROM tbrecip_vinculacao_parame tvp
             WHERE tvp.idparame_reciproci = pr_idparame_reciproci
               AND tvp.idvinculacao_reciproci = pr_idvinculacao_reciproci;
        rw_procura_vinculacao cr_procura_vinculacao%ROWTYPE;
    
        CURSOR cr_tbrecip_parame_calculo(pr_idparame_reciproci IN tbrecip_parame_calculo.idparame_reciproci%TYPE) IS
            SELECT tc.perdesconto_maximo
                  ,tc.vldesconto_maximo_cee
                  ,tc.vldesconto_maximo_coo
              FROM tbrecip_parame_calculo tc
             WHERE idparame_reciproci = pr_idparame_reciproci;
        rw_tbrecip_parame_calculo cr_tbrecip_parame_calculo%ROWTYPE;
    
        -- Variáveis genéricas
        vr_achoureg     BOOLEAN;
        vr_confrp_geral gene0002.typ_split;
        vr_confrp_dados gene0002.typ_split;
    
        vr_achouvinculacao     BOOLEAN;
        vr_vinculacoesrp_geral gene0002.typ_split;
        vr_vinculacoesrp_dados gene0002.typ_split;
    
        vr_idparame_reciproci tbrecip_parame_indica_calculo.idparame_reciproci%TYPE;
    
        vr_old_vldescontomax_coo tbrecip_parame_calculo.vldesconto_maximo_coo%TYPE;
        vr_old_vldescontomax_cee tbrecip_parame_calculo.vldesconto_maximo_cee%TYPE;
    
        vr_old_vlminimo NUMBER;
        vr_old_vlmaximo NUMBER;
        vr_old_peso     NUMBER;
        vr_old_desconto NUMBER;
        vr_old_vlpeso   NUMBER;
        vr_old_vldesc   NUMBER;
    
        vr_textolog VARCHAR2(32767);
    
        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
    
        --Variaveis de Criticas
        vr_dscritic VARCHAR2(4000);
    
        --Variaveis de Excecoes
        vr_exc_erro EXCEPTION;
    
    BEGIN
        --------------- VALIDACOES INICIAIS -----------------
        -- Incluir nome do módulo logado
        gene0001.pc_informa_acesso(pr_module => 'RCIP0001', pr_action => NULL);
    
        --Inicializar Variaveis
        vr_dscritic := NULL;
    
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
    
        -- Devemos replicar as parametrizações para todos os convênios que possuam reciprocidade
        FOR rw_convenios_semelhantes IN cr_convenios_semelhantes(pr_cdcooper) LOOP
            --    
            vr_idparame_reciproci := rw_convenios_semelhantes.idprmrec;
            --
            IF vr_idparame_reciproci <> 0 THEN
                --              
                OPEN cr_tbrecip_parame_calculo(vr_idparame_reciproci);
                FETCH cr_tbrecip_parame_calculo
                    INTO rw_tbrecip_parame_calculo;
                --
                vr_old_vldescontomax_coo := rw_tbrecip_parame_calculo.vldesconto_maximo_coo;
                vr_old_vldescontomax_cee := rw_tbrecip_parame_calculo.vldesconto_maximo_cee;
            
                CLOSE cr_tbrecip_parame_calculo;
            
                -- Atualizar tarifas e pesos
                BEGIN
                    UPDATE tbrecip_parame_calculo
                       SET vldesconto_maximo_coo = pr_vldescontomax_coo
                          ,vldesconto_maximo_cee = pr_vldescontomax_cee
                     WHERE idparame_reciproci = vr_idparame_reciproci;
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Nao foi possível atualizar as tarifas (CEE e COO) e os pesos (Boleto e Adicionais).' ||
                                       SQLERRM;
                        RAISE vr_exc_erro;
                END;
            
                IF vr_old_vldescontomax_coo <> pr_vldescontomax_coo THEN
                    -- Gera log
                    vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                   ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                   'Alterou o valor de custo COO ' || 'de ' || vr_old_vldescontomax_coo ||
                                   ' para ' || pr_vldescontomax_coo || '.' || '[br]';
                END IF;
            
                IF vr_old_vldescontomax_cee <> pr_vldescontomax_cee THEN
                    -- Gera log
                    vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                   ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                   'Alterou o valor de custo CEE ' || 'de ' || vr_old_vldescontomax_cee ||
                                   ' para ' || pr_vldescontomax_cee || '.' || '[br]';
                END IF;
            
                vr_confrp_geral := gene0002.fn_quebra_string(pr_configrp, ';');
                FOR ind_registro IN vr_confrp_geral.first .. vr_confrp_geral.last LOOP
                
                    vr_confrp_dados := gene0002.fn_quebra_string(vr_confrp_geral(ind_registro), ',');
                
                    -- Substituir os "-" recebidos da tela para indicadores de Adesão para "0"
                    IF upper(vr_confrp_dados(3)) = 'A' THEN
                        vr_confrp_dados(4) := 0;
                        vr_confrp_dados(5) := 0;
                    END IF;
                
                    -- Ativo
                    IF upper(vr_confrp_dados(1)) = 'TRUE' THEN
                    
                        -- Verifica se já existe registro
                        OPEN cr_procura_parame(pr_idparame_reciproci => vr_idparame_reciproci
                                              ,pr_idindicador        => to_number(vr_confrp_dados(2)));
                        FETCH cr_procura_parame
                            INTO rw_procura_parame;
                        vr_achoureg := cr_procura_parame%FOUND;
                        IF vr_achoureg THEN
                            vr_old_vlminimo := rw_procura_parame.vlminimo;
                            vr_old_vlmaximo := rw_procura_parame.vlmaximo;
                            vr_old_peso     := rw_procura_parame.vlpercentual_peso;
                            vr_old_desconto := rw_procura_parame.vlpercentual_desconto;
                        END IF;
                        CLOSE cr_procura_parame;
                    
                        -- Se achou registro
                        IF vr_achoureg THEN
                            --Se há alteração
                            IF nvl(vr_old_vlminimo, 0) <>
                               nvl(to_number(REPLACE(vr_confrp_dados(4), '.', ',')), 0) OR
                               nvl(vr_old_vlmaximo, 0) <>
                               nvl(to_number(REPLACE(vr_confrp_dados(5), '.', ',')), 0) OR
                               nvl(vr_old_peso, 0) <> nvl(to_number(REPLACE(vr_confrp_dados(6), '.', ',')), 0) OR
                               nvl(vr_old_desconto, 0) <> nvl(to_number(REPLACE(vr_confrp_dados(7), '.', ',')), 0) THEN
                                BEGIN
                                    UPDATE tbrecip_parame_indica_calculo
                                       SET vlminimo          = to_number(REPLACE(vr_confrp_dados(4), '.', ',')) -- Valor Minimo
                                          ,vlmaximo          = to_number(REPLACE(vr_confrp_dados(5), '.', ',')) -- Valor Maximo
                                          ,vlpercentual_peso = to_number(REPLACE(vr_confrp_dados(6), '.', ',')) -- Peso
                                          ,vlpercentual_desconto = to_number(REPLACE(vr_confrp_dados(7), '.', ',')) -- Desconto
                                     WHERE idparame_reciproci = vr_idparame_reciproci
                                       AND idindicador = to_number(vr_confrp_dados(2));
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        vr_dscritic := 'Erro ao alterar Indicador de parametrizacao' ||
                                                       'de calculo de Reciprocidade. ' || SQLERRM;
                                        RAISE vr_exc_erro;
                                END;
                            
                                -- Gera log
                                vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                               ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                               'Alterou o Indicador ' ||
                                               to_number(REPLACE(vr_confrp_dados(2), '.', ',')) || '.' ||
                                               '[br]';
                            
                                -- Gera log
                                IF nvl(vr_old_vlminimo, 0) <>
                                   nvl(to_number(REPLACE(vr_confrp_dados(4), '.', ',')), 0) THEN
                                    vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                   ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                                   'Alterou o Valor Minimo ' || 'de ' || vr_old_vlminimo ||
                                                   ' para ' ||
                                                   to_number(REPLACE(vr_confrp_dados(4), '.', ',')) || '.' ||
                                                   '[br]';
                                END IF;
                            
                                -- Gera log
                                IF nvl(vr_old_vlmaximo, 0) <>
                                   nvl(to_number(REPLACE(vr_confrp_dados(5), '.', ',')), 0) THEN
                                    vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                   ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                                   'Alterou o Valor Maximo ' || 'de ' || vr_old_vlmaximo ||
                                                   ' para ' ||
                                                   to_number(REPLACE(vr_confrp_dados(5), '.', ',')) || '.' ||
                                                   '[br]';
                                END IF;
                            
                                -- Gera log
                                IF nvl(vr_old_peso, 0) <>
                                   nvl(to_number(REPLACE(vr_confrp_dados(6), '.', ',')), 0) THEN
                                    vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                   ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                                   'Alterou o Peso ' || 'de ' || vr_old_peso || ' para ' ||
                                                   to_number(REPLACE(vr_confrp_dados(6), '.', ',')) || '.' ||
                                                   '[br]';
                                END IF;
                            
                                -- Gera log
                                IF nvl(vr_old_desconto, 0) <>
                                   nvl(to_number(REPLACE(vr_confrp_dados(6), '.', ',')), 0) THEN
                                    vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                   ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                                   'Alterou o Desconto ' || 'de ' || vr_old_desconto ||
                                                   ' para ' ||
                                                   to_number(REPLACE(vr_confrp_dados(7), '.', ',')) || '.' ||
                                                   '[br]';
                                END IF;
                            
                            END IF;
                        ELSE
                            -- Se não encontrar, cria novo registro
                            BEGIN
                                INSERT INTO tbrecip_parame_indica_calculo
                                    (idparame_reciproci, idindicador, vlminimo, vlmaximo, vlpercentual_peso, vlpercentual_desconto)
                                VALUES
                                    (vr_idparame_reciproci
                                    ,to_number(REPLACE(vr_confrp_dados(2), '.', ',')) -- Indicador
                                    ,to_number(REPLACE(vr_confrp_dados(4), '.', ',')) -- Valor Minimo
                                    ,to_number(REPLACE(vr_confrp_dados(5), '.', ',')) -- Valor Maximo
                                    ,to_number(REPLACE(vr_confrp_dados(6), '.', ',')) -- Peso
                                    ,to_number(REPLACE(vr_confrp_dados(7), '.', ','))); -- Desconto
                            EXCEPTION
                                WHEN OTHERS THEN
                                    vr_dscritic := 'Erro ao alterar Indicador de parametrizacao' ||
                                                   'de calculo de Reciprocidade. ' || SQLERRM;
                                    RAISE vr_exc_erro;
                            END;
                        
                            -- Gera log
                            vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                           ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                           'Incluiu o indicador : ' ||
                                           to_number(REPLACE(vr_confrp_dados(2), '.', ',')) || '.' || '[br]';
                        
                            -- Gera log
                            IF upper(vr_confrp_dados(3)) != 'A' THEN
                                vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                               ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                               'Incluiu o Valor Minimo: ' ||
                                               to_number(REPLACE(vr_confrp_dados(4), '.', ',')) || '.' ||
                                               '[br]';
                                -- Gera log
                                vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                               ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                               'Incluiu o Valor Maximo: ' ||
                                               to_number(REPLACE(vr_confrp_dados(5), '.', ',')) || '.' ||
                                               '[br]';
                            
                                -- Gera log
                                vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                               ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                               'Incluiu o Peso: ' ||
                                               to_number(REPLACE(vr_confrp_dados(6), '.', ',')) || '.' ||
                                               '[br]';
                            
                                -- Gera log
                                vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                               ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                               'Incluiu o Desconto: ' ||
                                               to_number(REPLACE(vr_confrp_dados(7), '.', ',')) || '.' ||
                                               '[br]';
                            END IF;
                        
                        END IF;
                    
                    ELSE
                        -- Não ativo
                    
                        -- Verifica se já existe registro
                        OPEN cr_procura_parame(pr_idparame_reciproci => pr_idparame_reciproci
                                              ,pr_idindicador        => to_number(vr_confrp_dados(2)));
                        FETCH cr_procura_parame
                            INTO rw_procura_parame;
                        vr_achoureg := cr_procura_parame%FOUND;
                        CLOSE cr_procura_parame;
                    
                        IF vr_achoureg THEN
                            -- Se achou registro deleta
                            BEGIN
                                DELETE FROM tbrecip_parame_indica_calculo
                                 WHERE idparame_reciproci = pr_idparame_reciproci
                                   AND idindicador = to_number(vr_confrp_dados(2));
                            EXCEPTION
                                WHEN OTHERS THEN
                                    vr_dscritic := 'Erro ao excluir Indicador de parametrizacao' ||
                                                   'de calculo de Reciprocidade. ' || SQLERRM;
                                    RAISE vr_exc_erro;
                            END;
                        
                            -- Gera log
                            vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                           ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                           'Excluiu o Indicador de parametrizacao de calculo de Reciprocidade: ' ||
                                           to_number(vr_confrp_dados(2)) || '.' || '[br]';
                        
                        END IF;
                    
                    END IF;
                
                END LOOP;
            
                -- Se houve alteração
                IF TRIM(vr_textolog) IS NOT NULL THEN
                    -- Incluir o início do log
                    vr_textolog := to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') || ' [fl]  Operador ' ||
                                   vr_cdoperad || ' - ' || 'Alterou parametrizacao Reciprocidade: ' || '[br]' ||
                                   vr_textolog;
                
                END IF;
            
                -- Vinculações
                IF pr_vinculacoesrp IS NOT NULL THEN
                    vr_vinculacoesrp_geral := gene0002.fn_quebra_string(pr_vinculacoesrp, ';');
                    FOR ind_registro IN vr_vinculacoesrp_geral.first .. vr_vinculacoesrp_geral.last LOOP
                    
                        vr_vinculacoesrp_dados := gene0002.fn_quebra_string(vr_vinculacoesrp_geral(ind_registro)
                                                                           ,',');
                    
                        -- Ativo
                        IF upper(vr_vinculacoesrp_dados(1)) = 'TRUE' THEN
                        
                            -- Verifica se já existe registro
                            OPEN cr_procura_vinculacao(pr_idparame_reciproci     => vr_idparame_reciproci
                                                      ,pr_idvinculacao_reciproci => to_number(vr_vinculacoesrp_dados(2)));
                            FETCH cr_procura_vinculacao
                                INTO rw_procura_vinculacao;
                            vr_achouvinculacao := cr_procura_vinculacao%FOUND;
                            IF vr_achouvinculacao THEN
                                vr_old_vlpeso := rw_procura_vinculacao.vlpercentual_peso;
                                vr_old_vldesc := rw_procura_vinculacao.vlpercentual_desconto;
                            END IF;
                            CLOSE cr_procura_vinculacao;
                        
                            -- Se achou registro
                            IF vr_achouvinculacao THEN
                                --Se há alteração
                                IF nvl(vr_old_vldesc, 0) <>
                                   nvl(to_number(REPLACE(vr_vinculacoesrp_dados(3), '.', ',')), 0) THEN
                                    BEGIN
                                        UPDATE tbrecip_vinculacao_parame
                                           SET vlpercentual_desconto = to_number(REPLACE(vr_vinculacoesrp_dados(3)
                                                                                        ,'.'
                                                                                        ,','))
                                         WHERE idparame_reciproci = vr_idparame_reciproci
                                           AND idvinculacao_reciproci = to_number(vr_vinculacoesrp_dados(2));
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            vr_dscritic := 'Erro ao alterar desconto da Vinculação de parametrizacao' ||
                                                           'de calculo de Reciprocidade. ' || SQLERRM;
                                            RAISE vr_exc_erro;
                                    END;
                                
                                    -- Gera log
                                    IF nvl(vr_old_vldesc, 0) <>
                                       nvl(to_number(REPLACE(vr_vinculacoesrp_dados(3), '.', ',')), 0) THEN
                                        vr_textolog := vr_textolog ||
                                                       to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                                       'Alterou o percentual de desconto ' || 'de ' ||
                                                       vr_old_vldesc || ' para ' ||
                                                       to_number(REPLACE(vr_vinculacoesrp_dados(3), '.', ',')) || '.' ||
                                                       '[br]';
                                    END IF;
                                
                                END IF;
                                IF nvl(vr_old_vlpeso, 0) <>
                                   nvl(to_number(REPLACE(vr_vinculacoesrp_dados(4), '.', ',')), 0) THEN
                                    BEGIN
                                        UPDATE tbrecip_vinculacao_parame
                                           SET vlpercentual_peso = to_number(REPLACE(vr_vinculacoesrp_dados(4)
                                                                                    ,'.'
                                                                                    ,','))
                                         WHERE idparame_reciproci = vr_idparame_reciproci
                                           AND idvinculacao_reciproci = to_number(vr_vinculacoesrp_dados(2));
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            vr_dscritic := 'Erro ao alterar Vinculação de parametrizacao' ||
                                                           'de calculo de Reciprocidade. ' || SQLERRM;
                                            RAISE vr_exc_erro;
                                    END;
                                
                                    -- Gera log
                                    IF nvl(vr_old_vlpeso, 0) <>
                                       nvl(to_number(REPLACE(vr_vinculacoesrp_dados(4), '.', ',')), 0) THEN
                                        vr_textolog := vr_textolog ||
                                                       to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                                       'Alterou o peso ' || 'de ' || vr_old_vlpeso || ' para ' ||
                                                       to_number(REPLACE(vr_vinculacoesrp_dados(4), '.', ',')) || '.' ||
                                                       '[br]';
                                    END IF;
                                
                                END IF;
                            ELSE
                                -- Se não encontrar, cria novo registro
                                BEGIN
                                    INSERT INTO tbrecip_vinculacao_parame p
                                        (idparame_reciproci
                                        ,idvinculacao_reciproci
                                        ,vlpercentual_desconto
                                        ,vlpercentual_peso)
                                    VALUES
                                        (vr_idparame_reciproci
                                        ,to_number(REPLACE(vr_vinculacoesrp_dados(2), '.', ',')) -- Vinculação
                                        ,to_number(REPLACE(vr_vinculacoesrp_dados(3), '.', ',')) -- Peso
                                        ,to_number(REPLACE(vr_vinculacoesrp_dados(4), '.', ','))); -- Percentual Desconto
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        vr_dscritic := 'Erro ao incluir Vinculação de parametrizacao ' ||
                                                       'de calculo de Reciprocidade. ' || SQLERRM;
                                        RAISE vr_exc_erro;
                                END;
                            
                                -- Gera log
                                vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                               ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                               'Incluiu a vinculação: ' ||
                                               to_number(REPLACE(vr_vinculacoesrp_dados(2), '.', ',')) || '.' ||
                                               '[br]';
                            
                            END IF;
                        
                        ELSE
                            -- Não ativo
														
														OPEN cr_procura_vinculacao(pr_idparame_reciproci     => vr_idparame_reciproci
                                                      ,pr_idvinculacao_reciproci => to_number(vr_vinculacoesrp_dados(2)));
														-- Verifica se já existe registro
														FETCH cr_procura_vinculacao
                                INTO rw_procura_vinculacao;
                            vr_achouvinculacao := cr_procura_vinculacao%FOUND;
                            CLOSE cr_procura_vinculacao;
														
														                        
                            IF vr_achouvinculacao THEN
                                -- Se achou registro deleta
                                BEGIN
                                    DELETE FROM tbrecip_vinculacao_parame
                                     WHERE idparame_reciproci = pr_idparame_reciproci
                                       AND idvinculacao_reciproci = to_number(vr_vinculacoesrp_dados(2));
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        vr_dscritic := 'Erro ao excluir Indicador de parametrizacao' ||
                                                       'de calculo de Reciprocidade. ' || SQLERRM;
                                        RAISE vr_exc_erro;
                                END;
                            
                                -- Gera log
                                vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                               ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                               'Excluiu o Indicador de parametrizacao de calculo de Reciprocidade: ' ||
                                               to_number(vr_vinculacoesrp_dados(2)) || '.' || '[br]';
                            
                            END IF;
                        
                        END IF;
                    
                    END LOOP;
                END IF;
            
                -- Se houve alteração
                IF TRIM(vr_textolog) IS NOT NULL THEN
                    -- Incluir o início do log
                    vr_textolog := to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') || ' [fl]  Operador ' ||
                                   vr_cdoperad || ' - ' || 'Alterou parametrizacao Reciprocidade: ' || '[br]' ||
                                   vr_textolog;
                
                END IF;
            
            ELSE
                -- Não é informado pr_idparame_reciproci
            
                -- Criar novas tarifas e pesos
                BEGIN
                    INSERT INTO tbrecip_parame_calculo
                        (vldesconto_maximo_coo, vldesconto_maximo_cee)
                    VALUES
                        (pr_vldescontomax_coo, pr_vldescontomax_cee)
                    RETURNING idparame_reciproci INTO vr_idparame_reciproci;
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Nao foi possível atualizar as tarifas (CEE e COO) e os pesos (Boleto e Adicionais). ' ||
                                       SQLERRM;
                        RAISE vr_exc_erro;
                END;
            
                -- Iniciar LOG
                vr_textolog := to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') || ' [fl]  Operador ' || vr_cdoperad ||
                               ' - ' || 'Incluiu nova parametrizacao Reciprocidade:' || '[br]';
            
                -- Gera log
                vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') || ' [fl]  Operador ' ||
                               vr_cdoperad || ' - ' || 'Incluiu a tarifa COO ao Calculo: ' ||
                               pr_vldescontomax_coo || '.' || '[br]';
            
                -- Gera log
                vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') || ' [fl]  Operador ' ||
                               vr_cdoperad || ' - ' || 'Incluiu a tarifa CEE ao Calculo: ' ||
                               pr_vldescontomax_cee || '.' || '[br]';
            
                -- Indicadores
                vr_confrp_geral := gene0002.fn_quebra_string(pr_configrp, ';');
                FOR ind_registro IN vr_confrp_geral.first .. vr_confrp_geral.last LOOP
                
                    vr_confrp_dados := gene0002.fn_quebra_string(vr_confrp_geral(ind_registro), ',');
                
                    -- Substituir os "-" recebidos da tela para indicadores de Adesão para "0"
                    IF upper(vr_confrp_dados(3)) = 'A' THEN
                        vr_confrp_dados(4) := 0;
                        vr_confrp_dados(5) := 0;
                    END IF;
                
                    IF upper(vr_confrp_dados(1)) = 'TRUE' THEN
                        -- Ativo
                        BEGIN
                            -- Criar indicadores de parametrizacao de calculo de Reciprocidade.
                            INSERT INTO tbrecip_parame_indica_calculo
                                (idparame_reciproci, idindicador, vlminimo, vlmaximo, vlpercentual_peso, vlpercentual_desconto)
                            VALUES
                                (vr_idparame_reciproci
                                ,to_number(REPLACE(vr_confrp_dados(2), '.', ',')) -- Indicador
                                ,to_number(REPLACE(vr_confrp_dados(4), '.', ',')) -- Valor Minimo
                                ,to_number(REPLACE(vr_confrp_dados(5), '.', ',')) -- Valor Maximo
                                ,to_number(REPLACE(vr_confrp_dados(6), '.', ',')) -- Peso
                                ,to_number(REPLACE(vr_confrp_dados(7), '.', ','))); -- Desconto
                        EXCEPTION
                            WHEN OTHERS THEN
                                vr_dscritic := 'Erro ao incluir Indicador de parametrizacao' ||
                                               'de calculo de Reciprocidade. ' || SQLERRM;
                                RAISE vr_exc_erro;
                        END;
                    
                        -- Gera log
                        vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                       ' [fl]  Operador ' || vr_cdoperad || ' - ' || 'Incluiu o indicador : ' ||
                                       to_number(REPLACE(vr_confrp_dados(2), '.', ',')) || '.' || '[br]';
                    
                        IF upper(vr_confrp_dados(3)) <> 'A' THEN
                            -- Gera log
                            vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                           ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                           'Incluiu o Valor Minimo: ' ||
                                           to_number(REPLACE(vr_confrp_dados(4), '.', ',')) || '.' || '[br]';
                        
                            -- Gera log
                            vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                           ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                           'Incluiu o Valor Maximo: ' ||
                                           to_number(REPLACE(vr_confrp_dados(5), '.', ',')) || '.' || '[br]';
                        
                            -- Gera log
                            vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                           ' [fl]  Operador ' || vr_cdoperad || ' - ' || 'Incluiu o Peso: ' ||
                                           to_number(REPLACE(vr_confrp_dados(6), '.', ',')) || '.' || '[br]';
                        
                            -- Gera log
                            vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                           ' [fl]  Operador ' || vr_cdoperad || ' - ' ||
                                           'Incluiu o Desconto: ' ||
                                           to_number(REPLACE(vr_confrp_dados(7), '.', ',')) || '.' || '[br]';
                        END IF;
                    
                    END IF;
                
                END LOOP;
            
                -- Vinculações
                vr_vinculacoesrp_geral := gene0002.fn_quebra_string(pr_configrp, ';');
                FOR ind_registro IN vr_vinculacoesrp_geral.first .. vr_vinculacoesrp_geral.last LOOP
                
                    vr_vinculacoesrp_dados := gene0002.fn_quebra_string(vr_vinculacoesrp_geral(ind_registro)
                                                                       ,',');
                    IF upper(vr_vinculacoesrp_dados(1)) = 'TRUE' THEN
                        -- Ativo
                        BEGIN
                            -- Criar indicadores de parametrizacao de calculo de Reciprocidade.
                            INSERT INTO tbrecip_vinculacao_parame
                                (idparame_reciproci
                                ,idvinculacao_reciproci
                                ,vlpercentual_peso
                                ,vlpercentual_desconto)
                            VALUES
                                (vr_idparame_reciproci
                                ,to_number(REPLACE(vr_vinculacoesrp_dados(2), '.', ',')) -- Vinculação
                                ,to_number(REPLACE(vr_vinculacoesrp_dados(4), '.', ',')) -- Peso
                                ,to_number(REPLACE(vr_vinculacoesrp_dados(3), '.', ','))); -- Percentual de desconto
                        EXCEPTION
                            WHEN OTHERS THEN
                                vr_dscritic := 'Erro ao incluir Vinculação de parametrizacao ' ||
                                               'de calculo de Reciprocidade. ' || SQLERRM;
                                RAISE vr_exc_erro;
                        END;
                    
                        -- Gera log
                        vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                       ' [fl]  Operador ' || vr_cdoperad || ' - ' || 'Incluiu a vinculação : ' ||
                                       to_number(REPLACE(vr_vinculacoesrp_dados(2), '.', ',')) || '.' ||
                                       '[br]';
                    
                        -- Gera log
                        vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                       ' [fl]  Operador ' || vr_cdoperad || ' - ' || 'Incluiu o Peso: ' ||
                                       to_number(REPLACE(vr_vinculacoesrp_dados(4), '.', ',')) || '.' ||
                                       '[br]';
                    
                        -- Gera log
                        vr_textolog := vr_textolog || to_char(SYSDATE, 'DD/MM/RRRR hh24:mi:ss') ||
                                       ' [fl]  Operador ' || vr_cdoperad || ' - ' || 'Incluiu o Desconto: ' ||
                                       to_number(REPLACE(vr_vinculacoesrp_dados(3), '.', ',')) || '.' ||
                                       '[br]';
                    
                    END IF;
                END LOOP;
            
                -- Após realizar todas as operações devemos atualizar o campo idprmrec da cadcco
                BEGIN
                    UPDATE crapcco
                       SET idprmrec = vr_idparame_reciproci
                     WHERE cdcooper = rw_convenios_semelhantes.cdcooper
                       AND nrconven = rw_convenios_semelhantes.nrconven;
                EXCEPTION
                    WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao atualizar o ID unico da parametrizacao de calculo de Reciprocidade.' ||
                                       SQLERRM;
                        RAISE vr_exc_erro;
                END;
            
            END IF;
        
        END LOOP;
    
        --Retorno
        pr_des_erro := 'OK';
    
        -- Salva no banco as alterações
        COMMIT;
    
        -- Criar cabeçalho do XML
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    
        -- Devemos enviar o pr_idparame_reciproci e não o vr_idparame_reciproci, senão o PHP irá alterar na cadcco o idprmrec de forma incorreta
        -- O motivo desse "problema" é que antes não havia replicação dos parametros e sim a alteração para um único convenio
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idparame_reciproci'
                              ,pr_tag_cont => pr_idparame_reciproci
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsretorno'
                              ,pr_tag_cont => pr_des_erro
                              ,pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dslogconfrp'
                              ,pr_tag_cont => vr_textolog
                              ,pr_des_erro => vr_dscritic);
    
    EXCEPTION
        WHEN vr_exc_erro THEN
            -- Erro tratado
            pr_dscritic := 'TELA_CONFRP.pc_confirma_conf_reciprocidade --> ' || vr_dscritic;
            pr_des_erro := 'NOK';
            pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                             pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        WHEN OTHERS THEN
            -- Erro não tratado
            pr_dscritic := 'TELA_CONFRP.pc_confirma_conf_reciprocidade --> Erro não tratado: ' || SQLERRM;
            pr_des_erro := 'NOK';
            pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' || '<Root><Erro>' ||
                                             pr_dscritic || '</Erro></Root>');
            ROLLBACK;
    END pc_confirma_conf_reciprocidade;

END TELA_CONFRP;
/
