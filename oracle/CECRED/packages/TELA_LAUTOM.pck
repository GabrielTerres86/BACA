CREATE OR REPLACE PACKAGE CECRED.TELA_LAUTOM IS

  PROCEDURE pc_valida_lancamento_web(pr_nrdconta     IN INTEGER        --> Numero da conta
                                    ,pr_vlcampos     IN VARCHAR2       --> Dados enviados
                                    ,pr_xmllog       IN VARCHAR2       --> XML com informacoes de LOG
                                    ,pr_cdcritic    OUT PLS_INTEGER    --> Codigo da critica
                                    ,pr_dscritic    OUT VARCHAR2       --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo    OUT VARCHAR2       --> Nome do campo com erro
                                    ,pr_des_erro    OUT VARCHAR2);     --> Erros do processo

  PROCEDURE pc_efetiva_lcto_pendente(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_dtrefere  IN craplau.dtmvtolt%TYPE --> Data do debito do lancamento
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Codigo da agencia
                                    ,pr_cdbccxlt  IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                    ,pr_cdoperad  IN crapdev.cdoperad%TYPE --> Codigo do Operador
                                    ,pr_nrdolote  IN craplot.nrdolote%TYPE --> Numero do Lote
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Numero da conta
                                    ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Codigo historico
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                                    ,pr_nrseqdig  IN craplau.nrseqdig%TYPE --> Sequencia de digitacao
                                    ,pr_vllanmto  IN NUMBER                --> Valor do lancamento
                                    ,pr_idlautom  IN NUMBER DEFAULT 0      --> Sequencial da craplau
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

	PROCEDURE pc_efetua_lancamento(pr_nrdconta     IN crapass.nrdconta%TYPE --> Numero da Conta
                                ,pr_vlcampos     IN VARCHAR2              --> Dados enviados
                                ,pr_xmllog       IN VARCHAR2              --> XML com informacoes de LOG
                                ,pr_cdcritic    OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic    OUT VARCHAR2              --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                ,pr_nmdcampo    OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro    OUT VARCHAR2);            --> Erros do processo

END TELA_LAUTOM;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_LAUTOM IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_LAUTOM
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Maio - 2016                 Ultima atualizacao: 11/12/2017
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela LAUTOM
  --
  -- Alteracoes: 01/03/2017 - Adicionar update da tbcc_lautom_controle na procedure
  --                          pc_efetua_lancamento. 
  --                          Adicionar origem ADIOFJUROS para podermos efetuar o 
  --                          debito do registro na procedure pc_valida_lancamento 
  --                          (Lucas Ranghetti M338.1)
  --
  --             24/04/2017 - Nao considerar valores bloqueados na composicao de saldo disponivel
  --                          Heitor (Mouts) - Melhoria 440
  --
  --             05/05/2017 - Ajuste para gravar o idlautom (Lucas Ranghetti M338.1)
  --
  --             11/12/2017 - Padronização pc_set_modulo, tratamento exception insert, mensagens de crítica
  --                          Chamado 788828 - Ana Volles (Envolti)
  ---------------------------------------------------------------------------

  vr_cdprogra    VARCHAR2(40) := 'TELA_LAUTOM';

	PROCEDURE pc_valida_lancamento(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo Operador
                                ,pr_vlcampos  IN VARCHAR2              --> Dados enviados
                                ,pr_vlapagar OUT NUMBER                --> Total a pagar
                                ,pr_inconfir OUT PLS_INTEGER           --> Indicador de confirmacao
                                ,pr_dsmensag OUT VARCHAR2              --> Mensagem de confirmacao
                                ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_valida_lancamento
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao: 11/12/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar os registros selecionados.

    Alteracoes: 01/03/2017 - Adicionar origem ADIOFJUROS para podermos efetuar o 
                             debito do registro (Lucas Ranghetti M338.1)

                11/12/2017 - Padronização pc_set_modulo, tratamento exception insert, mensagens de crítica
                             Chamado 788828 - Ana Volles (Envolti)
    ..............................................................................*/
    DECLARE

      -- Retorna lancamento futuro
      CURSOR cr_craplau(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapass.cdagenci%TYPE
                       ,pr_cdbccxlt IN craperr.nrdcaixa%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE
                       ,pr_nrseqdig IN craplau.nrseqdig%TYPE) IS
        SELECT vllanaut
              ,insitlau
              ,dsorigem
              ,cdhistor
          FROM craplau      
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND nrseqdig = pr_nrseqdig
           AND insitlau = 1; -- Pendente
      rw_craplau cr_craplau%ROWTYPE;

      -- Busca dados do cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT cdagenci
              ,vllimcre
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Busca dados do operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT vlpagchq
          FROM crapope
         WHERE cdcooper = pr_cdcooper
           AND cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Variaveis
      vr_index    PLS_INTEGER;
      vr_blnfound BOOLEAN;
      vr_vlsldisp NUMBER;
      vr_vldifpag NUMBER;

      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;

      -- Array para guardar o split dos dados
      vr_vet_dados GENE0002.typ_split;

    BEGIN
      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'TELA_LAUTOM.pc_valida_lancamento');

      -- Se NAO foi selecionado nada
      IF TRIM(pr_vlcampos) IS NULL THEN
        vr_cdcritic := 1061; --Nenhum lancamento futuro selecionado
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_erro;
      END IF;
      
      -- Inicializa
      pr_inconfir := 0;
      pr_dsmensag := NULL;

      -- Limpa tabela saldos
      vr_tab_saldos.DELETE;

      -- Efetuar o split das informacoes contidas na pr_vlcampos separados por ;
      vr_vet_dados := GENE0002.fn_quebra_string(pr_string  => pr_vlcampos
                                               ,pr_delimit => ';');
      -- Para cada registro encontrado
      FOR vr_pos IN 1..vr_vet_dados.COUNT LOOP

        -- Retorna lancamento futuro
        OPEN cr_craplau(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => TO_DATE(GENE0002.fn_busca_entrada(1,vr_vet_dados(vr_pos),','),'dd/mm/rrrr')
                       ,pr_cdagenci => GENE0002.fn_busca_entrada(2,vr_vet_dados(vr_pos),',')
                       ,pr_cdbccxlt => GENE0002.fn_busca_entrada(3,vr_vet_dados(vr_pos),',')
                       ,pr_nrdolote => GENE0002.fn_busca_entrada(4,vr_vet_dados(vr_pos),',')
                       ,pr_nrseqdig => GENE0002.fn_busca_entrada(5,vr_vet_dados(vr_pos),','));
        FETCH cr_craplau INTO rw_craplau;
        -- Alimenta a booleana
        vr_blnfound := cr_craplau%FOUND;
        -- Fechar o cursor
        CLOSE cr_craplau;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          vr_cdcritic := 501; --Lancamento nao encontrado
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          RAISE vr_exc_erro;
        END IF;

        -- Se nao for origem TRMULTAJUROS e ADIOFJUROS
        IF rw_craplau.dsorigem NOT IN('TRMULTAJUROS','ADIOFJUROS') THEN
          vr_cdcritic := 1062; --Débito de lançamento futuro não permitido
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          RAISE vr_exc_erro;
        END IF;

        -- Soma o valor do lancamento
        pr_vlapagar := NVL(pr_vlapagar,0) + rw_craplau.vllanaut;

      END LOOP;

      -- Busca dados do cooperado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      -- Busca data cadastrada
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      		
      -- Buscar o saldo disponivel a vista		
      EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => rw_crapass.cdagenci
                                 ,pr_nrdcaixa   => 0
                                 ,pr_cdoperad   => '1'
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_flgcrass   => FALSE
                                 ,pr_vllimcre   => rw_crapass.vllimcre
                                 ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_saldos
                                 ,pr_tipo_busca => 'A'
                                 ,pr_tab_erro   => vr_tab_erro);
      -- Buscar Indice
      vr_index := vr_tab_saldos.FIRST;
      IF vr_index IS NOT NULL THEN
        -- Saldo Disponivel
        vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index).vlsddisp, 0) +
                             NVL(vr_tab_saldos(vr_index).vlsdchsl, 0) +
                             NVL(vr_tab_saldos(vr_index).vllimcre, 0),2);
      END IF;

      -- Se valor a pagar for maior que saldo disponivel
      IF NVL(pr_vlapagar, 0) > NVL(vr_vlsldisp, 0) THEN

        -- Busca dados do operador
        OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad);
        FETCH cr_crapope INTO rw_crapope;
        -- Alimenta a booleana
        vr_blnfound := cr_crapope%FOUND;
        -- Fechar o cursor
        CLOSE cr_crapope;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          vr_cdcritic := 67;
          RAISE vr_exc_erro;
        END IF;

        -- Subtrai o valor a pagar do saldo disponivel
        vr_vldifpag := NVL(pr_vlapagar, 0) - NVL(vr_vlsldisp, 0);

        -- Valor Diferenca Maior Limite Pagamento Cheque
        IF vr_vldifpag > NVL(rw_crapope.vlpagchq, 0) THEN
          vr_cdcritic := 1063; --Saldo alçada do operador insuficiente
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          RAISE vr_exc_erro;
        END IF;

        pr_inconfir := 1;

        vr_cdcritic := 717; --Nao ha saldo suficiente para a operacao.
        pr_dsmensag := gene0001.fn_busca_critica(vr_cdcritic)||' Confirma o lançamento?';
      END IF;

      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'pc_valida_lancamento da tela LAUTOM. '||sqlerrm;

        -- No caso de erro de programa gravar tabela especifica de log - 11/12/2017 - Ch 788828 
        CECRED.pc_internal_exception;   
    END;

  END pc_valida_lancamento;

  PROCEDURE pc_valida_lancamento_web(pr_nrdconta     IN INTEGER        --> Numero da conta
                                    ,pr_vlcampos     IN VARCHAR2       --> Dados enviados
                                    ,pr_xmllog       IN VARCHAR2       --> XML com informacoes de LOG
                                    ,pr_cdcritic    OUT PLS_INTEGER    --> Codigo da critica
                                    ,pr_dscritic    OUT VARCHAR2       --> Descricao da critica
                                    ,pr_retxml       IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo    OUT VARCHAR2       --> Nome do campo com erro
                                    ,pr_des_erro    OUT VARCHAR2) IS   --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_valida_lancamento_web
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao: 11/12/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar os registros selecionados.

    Alteracoes: 11/12/2017 - Padronização pc_set_modulo, tratamento exception insert, mensagens de crítica
                             Chamado 788828 - Ana Volles (Envolti)
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis
      vr_vlapagar NUMBER;
      vr_inconfir PLS_INTEGER;
      vr_dsmensag VARCHAR2(4000);

    BEGIN
      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'TELA_LAUTOM.pc_valida_lancamento_web');

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Valida as informacoes de lancamento
      pc_valida_lancamento(pr_cdcooper => vr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_vlcampos => pr_vlcampos
                          ,pr_vlapagar => vr_vlapagar
                          ,pr_inconfir => vr_inconfir
                          ,pr_dsmensag => vr_dsmensag
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'TELA_LAUTOM.pc_valida_lancamento_web');

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inconfir'
                            ,pr_tag_cont => vr_inconfir
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsmensag'
                            ,pr_tag_cont => vr_dsmensag
                            ,pr_des_erro => vr_dscritic);

      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        --Tratamento de mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'pc_valida_lancamento_web da tela LAUTOM. '||sqlerrm;

        -- No caso de erro de programa gravar tabela especifica de log - 11/12/2017 - Ch 788828 
        CECRED.pc_internal_exception;   

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_valida_lancamento_web;

	PROCEDURE pc_efetiva_lcto_pendente(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_dtrefere  IN craplau.dtmvtolt%TYPE --> Data do debito do lancamento
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Codigo da agencia
                                    ,pr_cdbccxlt  IN craperr.nrdcaixa%TYPE --> Numero do caixa
                                    ,pr_cdoperad  IN crapdev.cdoperad%TYPE --> Codigo do Operador
                                    ,pr_nrdolote  IN craplot.nrdolote%TYPE --> Numero do Lote
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Numero da conta
                                    ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Codigo historico
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                                    ,pr_nrseqdig  IN craplau.nrseqdig%TYPE --> Sequencia de digitacao
                                    ,pr_vllanmto  IN NUMBER                --> Valor do lancamento
                                    ,pr_idlautom  IN NUMBER DEFAULT 0      --> Sequencial da craplau
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_efetiva_lcto_pendente
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao: 11/12/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para efetivar o lancamento na conta.

    Alteracoes: 05/05/2017 - Ajuste para gravar o idlautom (Lucas Ranghetti M338.1)

                11/12/2017 - Padronização pc_set_modulo, tratamento exception insert, mensagens de crítica
                             Chamado 788828 - Ana Volles (Envolti)
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

    BEGIN
      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente');

      -- Criar o lancamento da CRAPLAU
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                    ,pr_dtmvtolt => pr_dtmvtolt   --> Movimento atual
                                    ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                    ,pr_cdbccxlt => pr_cdbccxlt   --> Numero do caixa
                                    ,pr_cdoperad => pr_cdoperad   --> Codigo do Operador
                                    ,pr_cdpactra => pr_cdagenci   --> P.A. da transacao
                                    ,pr_nrdolote => pr_nrdolote   --> Numero do Lote
                                    ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                                    ,pr_cdhistor => pr_cdhistor   --> Codigo historico
                                    ,pr_vllanmto => pr_vllanmto   --> Valor do lancamento
                                    ,pr_nrparepr => 0             --> Numero parcelas emprestimo
                                    ,pr_nrctremp => pr_nrctremp   --> Numero do contrato de emprestimo
                                    ,pr_nrseqava => 0             --> Pagamento: Sequencia do avalista
                                    ,pr_idlautom => pr_idlautom   --> Sequencial da craplau
                                    ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro); --> Tabela de erros
      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se possui algum erro na tabela de erros
        IF vr_tab_erro.COUNT() > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 1064;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        RAISE vr_exc_erro;
      END IF;

      -- Atualiza o registro na tabela CRAPLAU
      BEGIN          
        UPDATE craplau
           SET insitlau = 2 -- Efetivado
              ,dtdebito = pr_dtmvtolt
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtrefere
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND nrseqdig = pr_nrseqdig;
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 1035;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craplau.'||
                         ' insitlau:2, dtdebito:'||pr_dtmvtolt||
                         ' com cdcooper:'||pr_cdcooper||', dtmvtolt:'||pr_dtrefere||
                         ', cdagenci:'||pr_cdagenci||', cdbccxlt:'||pr_cdbccxlt||
                         ', nrdolote:'||pr_nrdolote||', nrseqdig:'||pr_nrseqdig||'. '||sqlerrm;

          -- No caso de erro de programa gravar tabela especifica de log - 11/12/2017 - Ch 788828 
          CECRED.pc_internal_exception;   

          RAISE vr_exc_erro;
      END;

      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        --Tratamento de mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'pc_efetiva_lcto_pendente da tela LAUTOM. '||sqlerrm;

        -- No caso de erro de programa gravar tabela especifica de log - 11/12/2017 - Ch 788828 
        CECRED.pc_internal_exception;   
    END;

  END pc_efetiva_lcto_pendente;

	PROCEDURE pc_efetua_lancamento(pr_nrdconta     IN crapass.nrdconta%TYPE --> Numero da Conta
                                ,pr_vlcampos     IN VARCHAR2              --> Dados enviados
                                ,pr_xmllog       IN VARCHAR2              --> XML com informacoes de LOG
                                ,pr_cdcritic    OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic    OUT VARCHAR2              --> Descricao da critica
                                ,pr_retxml       IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                ,pr_nmdcampo    OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro    OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_efetua_lancamento
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao: 11/12/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para efetuar os lancamentos selecionados.

    Alteracoes: 01/03/2017 - Adicionar update da tbcc_lautom_controle (Lucas Ranghetti M338.1)
    
                05/05/2017 - Ajuste para gravar o idlautom (Lucas Ranghetti M338.1)

                11/12/2017 - Padronização pc_set_modulo, tratamento exception insert, mensagens de crítica
                             Chamado 788828 - Ana Volles (Envolti)
    ..............................................................................*/
    DECLARE

      -- Retorna lancamento futuro
      CURSOR cr_craplau(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_cdagenci IN crapass.cdagenci%TYPE
                       ,pr_cdbccxlt IN craperr.nrdcaixa%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE
                       ,pr_nrseqdig IN craplau.nrseqdig%TYPE) IS
        SELECT vllanaut
              ,dtmvtolt
              ,nrdolote
              ,cdhistor
              ,nrseqdig
              ,nrctremp
              ,cdagenci
              ,cdbccxlt
              ,idlancto
          FROM craplau      
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND nrseqdig = pr_nrseqdig
           AND insitlau = 1; -- Pendente
      rw_craplau cr_craplau%ROWTYPE;

      -- Busca dados do cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT cdagenci
              ,vllimcre
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_vlapagar NUMBER;
      vr_inconfir PLS_INTEGER;
      vr_dsmensag VARCHAR2(4000);

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Array para guardar o split dos dados
      vr_vet_dados GENE0002.typ_split;

      vr_idprglog tbgen_prglog.idprglog%type := 0;

    BEGIN
      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'TELA_LAUTOM.pc_efetua_lancamento');

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Valida as informacoes de lancamento
      pc_valida_lancamento(pr_cdcooper => vr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_vlcampos => pr_vlcampos
                          ,pr_vlapagar => vr_vlapagar
                          ,pr_inconfir => vr_inconfir
                          ,pr_dsmensag => vr_dsmensag
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
      -- Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'TELA_LAUTOM.pc_efetua_lancamento');

      -- Busca dados do cooperado
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      -- Busca data cadastrada
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Efetuar o split das informacoes contidas na pr_vlcampos separados por ;
      vr_vet_dados := GENE0002.fn_quebra_string(pr_string  => pr_vlcampos
                                               ,pr_delimit => ';');
      -- Para cada registro encontrado
      FOR vr_pos IN 1..vr_vet_dados.COUNT LOOP
        -- Retorna lancamento futuro
        OPEN cr_craplau(pr_cdcooper => vr_cdcooper
                       ,pr_dtmvtolt => TO_DATE(GENE0002.fn_busca_entrada(1,vr_vet_dados(vr_pos),','),'dd/mm/rrrr')
                       ,pr_cdagenci => GENE0002.fn_busca_entrada(2,vr_vet_dados(vr_pos),',')
                       ,pr_cdbccxlt => GENE0002.fn_busca_entrada(3,vr_vet_dados(vr_pos),',')
                       ,pr_nrdolote => GENE0002.fn_busca_entrada(4,vr_vet_dados(vr_pos),',')
                       ,pr_nrseqdig => GENE0002.fn_busca_entrada(5,vr_vet_dados(vr_pos),','));
        FETCH cr_craplau INTO rw_craplau;

        -- Alimenta a booleana
        vr_blnfound := cr_craplau%FOUND;
        -- Fechar o cursor
        CLOSE cr_craplau;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          vr_cdcritic := 501; --Lancamento nao encontrado
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          RAISE vr_exc_erro;
        END IF;

        -- Efetivar lancamento
        pc_efetiva_lcto_pendente(pr_cdcooper => vr_cdcooper
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_dtrefere => rw_craplau.dtmvtolt
                                ,pr_cdagenci => rw_craplau.cdagenci
                                ,pr_cdbccxlt => rw_craplau.cdbccxlt
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_nrdolote => rw_craplau.nrdolote
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_cdhistor => rw_craplau.cdhistor
                                ,pr_nrctremp => rw_craplau.nrctremp
                                ,pr_nrseqdig => rw_craplau.nrseqdig
                                ,pr_vllanmto => rw_craplau.vllanaut
                                ,pr_idlautom => rw_craplau.idlancto
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

        -- Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'TELA_LAUTOM.pc_efetua_lancamento');

        BEGIN 
          UPDATE tbcc_lautom_controle tbcc
             SET insit_lancto = 2 -- Quitado
           WHERE tbcc.idlautom = rw_craplau.idlancto;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcc_lautom_controle.'||
                           ' insit_lancto:2'||
                           ' com idlautom:'||rw_craplau.idlancto||'. '||sqlerrm;

            -- No caso de erro de programa gravar tabela especifica de log - 11/12/2017 - Ch 788828 
            CECRED.pc_internal_exception;   

            RAISE vr_exc_erro;
        END;

        -- Gerar LOG de debito efetuado
        CECRED.pc_log_programa(pr_dstiplog      => 'E',
                               pr_cdprograma    => vr_cdprogra, 
                               pr_cdcooper      => vr_cdcooper, 
                               pr_tpexecucao    => 3, -- Online  
                               pr_tpocorrencia  => 4, -- Alerta 
                               pr_cdcriticidade => 1, -- Media 
                               pr_dsmensagem    => gene0001.fn_busca_critica(1065)||  --Lancamento de debito na conta
                                                    ' Conta: ' || LTRIM(RTRIM(pr_nrdconta)) ||
                                                    ', Historico: ' || rw_craplau.cdhistor || '.',                             
                               pr_idprglog      => vr_idprglog, 
                               pr_nmarqlog      => NULL,
                               pr_cdmensagem    => 1065);

      END LOOP;

      COMMIT;

      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        --Tratamento de mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'pc_efetua_lancamento tela LAUTOM. '||sqlerrm;

        -- No caso de erro de programa gravar tabela especifica de log - 11/12/2017 - Ch 788828 
        CECRED.pc_internal_exception;   

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_efetua_lancamento;

END TELA_LAUTOM;
/
