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

	PROCEDURE pc_efetiva_lcto_pendente_job (pr_cdcooper IN crapcop.cdcooper%TYPE default 0);

	PROCEDURE pc_efetua_lancamento(pr_nrdconta     IN crapass.nrdconta%TYPE --> Numero da Conta
                                ,pr_vlcampos     IN VARCHAR2              --> Dados enviados
                                ,pr_xmllog       IN VARCHAR2              --> XML com informacoes de LOG
                                ,pr_cdcritic    OUT PLS_INTEGER           --> Codigo da critica
                                ,pr_dscritic    OUT VARCHAR2              --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                ,pr_nmdcampo    OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro    OUT VARCHAR2);            --> Erros do processo

	PROCEDURE pc_valida_lancamento_sld(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
									  ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Numero da conta
									  ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Histórico
									  ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
									  ,pr_dscritic  OUT VARCHAR2);           --> Erros do processo     
										
	PROCEDURE pc_efetiva_lcto_pendente_sld(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
										  ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Numero da conta
										  ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Histórico
										  ,pr_cdcritic  OUT VARCHAR2
										  ,pr_dscritic  OUT VARCHAR2);          --> Descricao da critica                                

	PROCEDURE pc_cria_lanc_futuro(pr_cdcooper IN craplau.cdcooper%TYPE --> Cooperativa
                               ,pr_nrdconta IN craplau.nrdconta%TYPE --> Conta
                               ,pr_nrdctitg IN craplau.nrdctitg%TYPE --> Conta integracao
                               ,pr_cdagenci IN craplau.cdagenci%TYPE --> Numero do PA
                               ,pr_dtmvtolt IN craplau.dtmvtolt%TYPE --> Data do movimento
                               ,pr_cdhistor IN craplau.cdhistor%TYPE --> Historico do lancamento
                               ,pr_vllanaut IN craplau.vllanaut%TYPE --> Valor do lancamento
                               ,pr_nrctremp IN craplau.nrctremp%TYPE --> Contrato
                               ,pr_dsorigem IN varchar2
                               ,pr_dscritic OUT VARCHAR2);         --> Descricao da critica
								

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
  --             21/05/2018 - Alterações referente a SM4 PRJ364, validar e efetivar lançaments 37,38 e 2323 
  --                          para contas situação 7. 
  --                          Paulo Martins - Mout´s  
  --             06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
  --                          após chamada da rotina de geraçao de lançamento em CONTA CORRENTE.
  --                          Alteração específica neste programa acrescentando o tratamento para a origem
  --                          BLQPREJU
  --                          (Renato Cordeiro - AMcom)
  ---------------------------------------------------------------------------

  vr_cdprogra    VARCHAR2(40) := 'TELA_LAUTOM';
  vr_idprglog    tbgen_prglog.idprglog%TYPE := 0;


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
	  vr_vlapagar NUMBER(25,4);    -- SM4

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
        /*registros em crapsld para históricos 37,38 e 2323 (SM 4) Paulo - Mout´s */
        if GENE0002.fn_busca_entrada(6,vr_vet_dados(vr_pos),',') in (37,38,2323) then
           pc_valida_lancamento_sld(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_cdhistor => GENE0002.fn_busca_entrada(6,vr_vet_dados(vr_pos),','),
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);          
           IF vr_dscritic is not null THEN
             RAISE vr_exc_erro;
           END IF;  
           vr_vlapagar := GENE0002.fn_busca_entrada(7,vr_vet_dados(vr_pos),','); -- Valor do lançamento
        else             
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

          -- Se nao for origem TRMULTAJUROS e ADIOFJUROS e BLQPREJU
          IF rw_craplau.dsorigem NOT IN('TRMULTAJUROS','ADIOFJUROS','BLQPREJU') THEN
            vr_cdcritic := 1062; --Débito de lançamento futuro não permitido
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            RAISE vr_exc_erro;
          END IF;
          vr_vlapagar := rw_craplau.vllanaut;
        end if;        

        -- Soma o valor do lancamento
        pr_vlapagar := NVL(pr_vlapagar,0) + vr_vlapagar; 

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

      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'TELA_LAUTOM.pc_valida_lancamento');

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
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
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
        --Não gera log aqui, só na rotina chamadora

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra,
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 3, --Online
                               pr_tpocorrencia  => 1, 
                               pr_cdcriticidade => 1, 
                               pr_cdmensagem    => pr_cdcritic,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

      WHEN OTHERS THEN
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'TELA_LAUTOM.pc_valida_lancamento. '||sqlerrm;

        --Não gera log aqui, só na rotina chamadora
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

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra,
                               pr_cdcooper      => vr_cdcooper, 
                               pr_tpexecucao    => 3, --Online
                               pr_tpocorrencia  => 1, 
                               pr_cdcriticidade => 1, 
                               pr_cdmensagem    => pr_cdcritic,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        --Tratamento de mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'TELA_LAUTOM.pc_valida_lancamento_web '||sqlerrm;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra,
                               pr_cdcooper      => vr_cdcooper, 
                               pr_tpexecucao    => 3, --Online
                               pr_tpocorrencia  => 2, 
                               pr_cdcriticidade => 2, 
                               pr_cdmensagem    => pr_cdcritic,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

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

      -- Incluído pc_set_modulo da procedure - Chamado 788828 - 11/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente');

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
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'craplau:'||
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

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra,
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 3, --Online
                               pr_tpocorrencia  => 1, 
                               pr_cdcriticidade => 1, 
                               pr_cdmensagem    => pr_cdcritic,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

      WHEN OTHERS THEN
        --Tratamento de mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'TELA_LAUTOM.pc_efetiva_lcto_pendente '||sqlerrm;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra,
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 3, --Online
                               pr_tpocorrencia  => 2, 
                               pr_cdcriticidade => 2, 
                               pr_cdmensagem    => pr_cdcritic,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- No caso de erro de programa gravar tabela especifica de log - 11/12/2017 - Ch 788828 
        CECRED.pc_internal_exception;   
    END;

  END pc_efetiva_lcto_pendente;

	PROCEDURE pc_efetiva_lcto_pendente_job (pr_cdcooper IN crapcop.cdcooper%TYPE default 0) IS
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_lcto_pendente_job
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao:22/09/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetivar o lancamento pendente via JOB.

       Alteracoes: 21/10/2016 - Incluir reset da variável de controle de log, pois
                                estava gerando o log de início apenas para a primeira
                                cooperativa executada ( Renato Darosci - Supero )
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )

                   17/04/2018 - Incluido o parametro pr_cdcooper
                                Projeto debitador único - Josiane Stiehler (Amcom) 

    ............................................................................. */
    DECLARE

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         WHERE flgativo = 1
           AND cdcooper = decode(nvl(pr_cdcooper,0),0,cdcooper,pr_cdcooper);

      -- Cursor para retornar lancamentos automaticos
      CURSOR cr_craplau(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT nrdconta
              ,vllanaut
              ,dtmvtolt
              ,nrdolote
              ,nrseqdig
              ,cdhistor
              ,nrctremp
              ,cdbccxlt
              ,cdagenci
              ,ROW_NUMBER() OVER (PARTITION BY nrdconta ORDER BY nrdconta) AS numconta
          FROM craplau
         WHERE cdcooper = pr_cdcooper
           AND insitlau = 1 -- Pendente
           AND cdbccxlt = 100
           AND nrdolote = 600033
           AND dsorigem in ('TRMULTAJUROS','BLQPREJU');

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

      -- Variaveis
      vr_index    PLS_INTEGER;
      vr_blnfound BOOLEAN;
      vr_flgerlog BOOLEAN := FALSE;
      vr_des_reto VARCHAR2(3);
      vr_vlsldisp NUMBER;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_tab_erro  GENE0001.typ_tab_erro;

      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;

      -- 22/09/2017 - Ch 758606
      -- Substituida rotina pc_controla_log_batch pela pc_grava_erro_programa

    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente_job');
      -- Listagem de cooperativas
      FOR rw_crapcop IN cr_crapcop LOOP
        
        -- Deve resetar a variável para cada cooperativa
        vr_flgerlog := FALSE;
      
        -- Log de inicio de execucao - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dstiplog => 'I'
                                       ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                       ,pr_dscritic => NULL
                                       );
        -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
        GENE0001.pc_set_modulo(pr_module => NULL
                              ,pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente_job'); 

        -- Verifica se a data esta cadastrada
        OPEN  BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Alimenta a booleana
        vr_blnfound := BTCH0001.cr_crapdat%FOUND;
        -- Fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          -- Log de erro de execucao - 22/09/2017 - Ch 758606
          empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dstiplog => 'E'
                                         ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                         ,pr_dscritic => 'pc_efetiva_lcto_pendente_job - 1' ||
                                                         ' - cdcooper: ' || rw_crapcop.cdcooper ||
                                                         ' - dscritic: ' || 
                                                         GENE0001.fn_busca_critica(pr_cdcritic => 1));
          -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
          GENE0001.pc_set_modulo(pr_module => NULL
                                ,pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente_job'); 
          CONTINUE;
        END IF;

        -- Final de semana e Feriado nao pode ocorrer o debito
        IF TRUNC(SYSDATE) <> rw_crapdat.dtmvtolt and rw_crapdat.inproces = 1 THEN
          -- Log de final de execucao, antes de passar a proxima cooperativa - 22/09/2017 - Ch 758606
          empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dstiplog => 'F'
                                         ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                         ,pr_dscritic => NULL
                                         );
          -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
          GENE0001.pc_set_modulo(pr_module => NULL
                                ,pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente_job'); 
        
          CONTINUE;
        END IF;

        -- Condicao para verificar se o processo estah rodando
        IF NVL(rw_crapdat.inproces,0) <> 1 THEN
          -- Log de final de execucao, antes de passar a proxima cooperativa - 22/09/2017 - Ch 758606
          empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dstiplog => 'F'
                                         ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                         ,pr_dscritic => NULL
                                         );
          -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
          GENE0001.pc_set_modulo(pr_module => NULL
                                ,pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente_job');                              
          CONTINUE;
        END IF;

        -- Busca todos os lancamentos pendentes
        FOR rw_craplau IN cr_craplau(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          -- Se for a primeira vez de acesso da conta
          IF rw_craplau.numconta = 1 THEN
            
            -- Busca dados do cooperado
            OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_nrdconta => rw_craplau.nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            -- Fecha o cursor
            CLOSE cr_crapass;

            -- Limpa tabela saldos
            vr_tab_saldos.DELETE;
      		
            -- Buscar o saldo disponivel a vista		
            EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapcop.cdcooper
                                       ,pr_rw_crapdat => rw_crapdat
                                       ,pr_cdagenci   => rw_crapass.cdagenci
                                       ,pr_nrdcaixa   => 0
                                       ,pr_cdoperad   => '1'
                                       ,pr_nrdconta   => rw_craplau.nrdconta
                                       ,pr_flgcrass   => FALSE
                                       ,pr_vllimcre   => rw_crapass.vllimcre
                                       ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                       ,pr_des_reto   => vr_des_reto
                                       ,pr_tab_sald   => vr_tab_saldos
                                       ,pr_tipo_busca => 'A'
                                       ,pr_tab_erro   => vr_tab_erro);
            -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente_job'); 
            -- Buscar Indice
            vr_index := vr_tab_saldos.FIRST;
            IF vr_index IS NOT NULL THEN
              -- Saldo Disponivel
              vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index).vlsddisp, 0) +
                                   NVL(vr_tab_saldos(vr_index).vlsdchsl, 0) +
                                   NVL(vr_tab_saldos(vr_index).vllimcre, 0),2);
            END IF;
          END IF;

          -- Verificar se possui saldo disponivel
          IF NVL(vr_vlsldisp, 0) - rw_craplau.vllanaut >= 0 THEN
            -- Efetivar lancamento
            TELA_LAUTOM.pc_efetiva_lcto_pendente(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                ,pr_dtrefere => rw_craplau.dtmvtolt
                                                ,pr_cdagenci => rw_craplau.cdagenci
                                                ,pr_cdbccxlt => rw_craplau.cdbccxlt
                                                ,pr_cdoperad => '1'
                                                ,pr_nrdolote => rw_craplau.nrdolote
                                                ,pr_nrdconta => rw_craplau.nrdconta
                                                ,pr_cdhistor => rw_craplau.cdhistor
                                                ,pr_nrctremp => rw_craplau.nrctremp
                                                ,pr_nrseqdig => rw_craplau.nrseqdig
                                                ,pr_vllanmto => rw_craplau.vllanaut
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
            -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente_job'); 
            -- Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              -- Log de erro de execucao - 22/09/2017 - Ch 758606
              empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_dstiplog => 'E'
                                             ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                             ,pr_dscritic => 'pc_efetiva_lcto_pendente_job - 2' ||
                                                             ' - cdcooper: ' || rw_crapcop.cdcooper ||
                                                             ' - dtmvtolt: ' || rw_craplau.dtmvtolt ||
                                                             ' - cdagenci: ' || rw_craplau.cdagenci ||
                                                             ' - cdbccxlt: ' || rw_craplau.cdbccxlt ||
                                                             ' - nrdolote: ' || rw_craplau.nrdolote ||
                                                             ' - nrdconta: ' || rw_craplau.nrdconta ||
                                                             ' - cdhistor: ' || rw_craplau.cdhistor ||
                                                             ' - nrctremp: ' || rw_craplau.nrctremp ||
                                                             ' - dtmvtolt: ' || rw_craplau.nrseqdig ||
                                                             ' - vllanaut: ' || rw_craplau.vllanaut ||
                                                             ' - cdcritic: ' || vr_cdcritic ||
                                                             ' - dscritic: ' || vr_dscritic);
              -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
              GENE0001.pc_set_modulo(pr_module => NULL
                                    ,pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente_job'); 
              ROLLBACK;
              CONTINUE;
            END IF;

            -- Para cada lancamento diminuir saldo disponivel
            vr_vlsldisp	:= vr_vlsldisp - rw_craplau.vllanaut;

          END IF;

          COMMIT;

        END LOOP; -- cr_craplau

        -- Log de final de execucao - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dstiplog => 'F'
                                       ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                       ,pr_dscritic => NULL);
        -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
        GENE0001.pc_set_modulo(pr_module => NULL
                              ,pr_action => 'TELA_LAUTOM.pc_efetiva_lcto_pendente_job');    

      END LOOP; -- cr_crapcop

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_saida THEN
        NULL;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception;  
        vr_dscritic := 'Erro geral na rotina da tela TELA_LAUTOM.pc_efetiva_pag_atraso_tr: ' || SQLERRM;
        -- Grava informações para resolver erro de programa/ sistema - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => 3
                                       ,pr_dstiplog => 'E'
                                       ,pr_nmrotina => 'TELA_LAUTOM'
                                       ,pr_dscritic => 'pc_efetiva_lcto_pendente_job - OTHERS' ||
                                                       ' - vr_dscritic: ' || vr_dscritic); 
    END;

  END pc_efetiva_lcto_pendente_job;
  
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
        /*registros em crapsld para históricos 37,38 e 2323 (SM 4) Paulo - Mout´s */
        if GENE0002.fn_busca_entrada(6,vr_vet_dados(vr_pos),',') in (37,38,2323) then
           pc_efetiva_lcto_pendente_sld(pr_cdcooper => vr_cdcooper,
                                    pr_nrdconta => pr_nrdconta, 
                                    pr_cdhistor => GENE0002.fn_busca_entrada(6,vr_vet_dados(vr_pos),','),
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);  
           IF vr_dscritic is not null THEN
             RAISE vr_exc_erro;
           END IF;  
           vr_vlapagar := GENE0002.fn_busca_entrada(7,vr_vet_dados(vr_pos),','); -- Valor do lançamento
        else 	  
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
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbcc_lautom_controle:'||
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
		end if;
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

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra,
                               pr_cdcooper      => vr_cdcooper, 
                               pr_tpexecucao    => 3, --Online
                               pr_tpocorrencia  => 1, 
                               pr_cdcriticidade => 1, 
                               pr_cdmensagem    => pr_cdcritic,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        --Tratamento de mensagem
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'TELA_LAUTOM.pc_efetua_lancamento '||sqlerrm;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_cdprogra,
                               pr_cdcooper      => vr_cdcooper, 
                               pr_tpexecucao    => 3, --Online
                               pr_tpocorrencia  => 2, 
                               pr_cdcriticidade => 2, 
                               pr_cdmensagem    => pr_cdcritic,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- No caso de erro de programa gravar tabela especifica de log - 11/12/2017 - Ch 788828 
        CECRED.pc_internal_exception;   

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_efetua_lancamento;

	PROCEDURE pc_cria_lanc_futuro(pr_cdcooper IN craplau.cdcooper%TYPE --> Cooperativa
                               ,pr_nrdconta IN craplau.nrdconta%TYPE --> Conta
                               ,pr_nrdctitg IN craplau.nrdctitg%TYPE --> Conta integracao
                               ,pr_cdagenci IN craplau.cdagenci%TYPE --> Numero do PA
                               ,pr_dtmvtolt IN craplau.dtmvtolt%TYPE --> Data do movimento
                               ,pr_cdhistor IN craplau.cdhistor%TYPE --> Historico do lancamento
                               ,pr_vllanaut IN craplau.vllanaut%TYPE --> Valor do lancamento
                               ,pr_nrctremp IN craplau.nrctremp%TYPE --> Contrato
                               ,pr_dsorigem IN varchar2
                               ,pr_dscritic OUT VARCHAR2) IS         --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_cria_lanc_futuro
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao:22/09/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para criacao de lancamentos futuros.

       Alteracoes: 
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )

    ............................................................................. */
    DECLARE
      -- Variaveis
      vr_nrseqdig INTEGER;

    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'TELA_LAUTOM.pc_cria_lanc_futuro');
      vr_nrseqdig := fn_sequence('CRAPLAU','NRSEQDIG',''||pr_cdcooper||';'||TO_CHAR(pr_dtmvtolt,'DD/MM/RRRR')||'');

      BEGIN
        INSERT INTO craplau
                   (cdcooper
                   ,nrdconta
                   ,nrdctabb
                   ,nrdctitg
                   ,cdagenci
                   ,dtmvtolt
                   ,dtmvtopg
                   ,cdhistor
                   ,vllanaut
                   ,nrseqdig
                   ,nrdocmto
                   ,nrctremp
                   ,cdbccxlt
                   ,nrdolote
                   ,insitlau
                   ,dtdebito
                   ,dsorigem)
             VALUES(pr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrdconta
                   ,pr_nrdctitg
                   ,pr_cdagenci
                   ,pr_dtmvtolt
                   ,pr_dtmvtolt
                   ,pr_cdhistor
                   ,pr_vllanaut
                   ,vr_nrseqdig
                   ,vr_nrseqdig
                   ,pr_nrctremp
                   ,100
                   ,600033
                   ,1
                   ,NULL
                   ,pr_dsorigem);

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);    
          pr_dscritic := 'pc_cria_lanc_futuro - ' || SQLERRM;
      END;
    END;

  END pc_cria_lanc_futuro;

PROCEDURE pc_valida_lancamento_sld(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Numero da conta
                                  ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Histórico
                                  ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica                                    
                                  ,pr_dscritic  OUT VARCHAR2) IS         --> Erros do processo
                                    
  /* .............................................................................

  Programa: pc_valida_lancamento_sld
  Sistema : Ayllos Web
  Autor   : Paulo Roberto - Mout´s
  Data    : Maio/2018                

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  : Rotina para validar os lancamentos informados, somente para contas situação 7 e históricos 37,38 e 2323

  ..............................................................................*/    
  
  cursor c_crapsld is
  select nvl(vljurmes,0)+nvl(vlsmnmes,0) vljurmes, -- 37 (Colunas EXTR002-vlsmnmes e PC_CRPS008-vljurmes)
         nvl(vljuresp,0)+nvl(vlsmnesp,0) vljuresp, -- 38
         nvl(vliofmes,0) vliofmes  -- 2323
    from crapsld s
   where s.cdcooper = pr_cdcooper
     and s.nrdconta = pr_nrdconta;
     r_crapsld c_crapsld%rowtype;
                                  
  BEGIN
   
    open c_crapsld;
     fetch c_crapsld into r_crapsld;
      if c_crapsld%notfound then
         pr_cdcritic := 90; --Lancamento nao encontrado
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      else
        if (pr_cdhistor = 37 and r_crapsld.vljurmes = 0) or
           (pr_cdhistor = 38 and r_crapsld.vljuresp = 0) or
           (pr_cdhistor = 2323 and r_crapsld.vliofmes = 0) then
               pr_cdcritic := 90; --Lancamento nao encontrado
               pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        end if;
      end if;  
    close c_crapsld;
      
  END pc_valida_lancamento_sld;

PROCEDURE pc_efetiva_lcto_pendente_sld(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa conectada
                                        ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Numero da conta
                                        ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Histórico
                                        ,pr_cdcritic  OUT VARCHAR2
                                        ,pr_dscritic  OUT VARCHAR2) IS         --> Descricao da critica
                                        

    /* .............................................................................

    Programa: pc_efetiva_lcto_pendente_sld
    Sistema : Ayllos Web
    Autor   : Paulo Martins - Mout´s
    Data    : Maio/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para efetivar o lancamento na contas em situação 7, somente históricos 37,38 e 2323

    Alterações: 03/085/2018 - Modificado o forma de compor o numero do documento no momento de efetivar 
                              o lançamento pois estava impactando no batch que faz o mesmo numero de 
                              documento no lancamento. (Tiago SCTASK0023646).
    ..............................................................................*/
                                        
     --Selecionar informacoes dos saldos dos associados
       CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE
                         ,pr_nrdconta IN crapsld.nrdconta%TYPE) IS
         SELECT crapsld.nrdconta
               ,crapsld.vliofmes
               ,crapsld.vlbasiof
               ,crapsld.qtlanmes
               ,crapsld.vlsdblfp
               ,crapsld.vlsdbloq
               ,crapsld.vlsdblpr
               ,crapsld.vlblqjud
               ,crapsld.vlsdchsl
               ,crapsld.vlsddisp
               ,crapsld.vltsallq
               ,crapsld.qtddsdev
               ,crapsld.dtdsdclq
               ,crapsld.qtdriclq
               ,crapsld.dtrisclq
               ,crapsld.qtddtdev
               ,crapsld.vlsmnesp
               ,crapsld.vlsmnblq
               ,crapsld.vlsmnmes
               ,crapsld.qtddusol
               ,crapsld.vlsmpmes
               ,crapsld.vlipmfap
               ,crapsld.vlipmfpg
               ,crapsld.vlbasipm
               ,crapsld.dtsdexes
               ,crapsld.dtsdanes
               ,crapsld.vlsdexes
               ,crapsld.vlsdanes
               ,crapsld.vlsdindi
               ,crapsld.dtrefere
               ,crapsld.vljuresp
               ,crapsld.vljurmes
               ,crapsld.rowid
         FROM  crapsld crapsld
         WHERE crapsld.cdcooper = pr_cdcooper
         AND   crapsld.nrdconta = pr_nrdconta;       
         rw_crapsld cr_crapsld%rowtype; 
         

       --Selecionar informacoes dos lotes
       CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                         ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                         ,pr_cdagenci IN craplot.cdagenci%TYPE
                         ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                         ,pr_nrdolote IN craplot.nrdolote%TYPE)  IS
         SELECT  craplot.dtmvtolt
                ,craplot.cdagenci
                ,craplot.cdbccxlt
                ,craplot.nrdolote
                ,craplot.nrseqdig
                ,craplot.cdcooper
                ,craplot.tplotmov
                ,craplot.vlinfodb
                ,craplot.vlcompdb
                ,craplot.qtinfoln
                ,craplot.qtcompln
                ,craplot.rowid
         FROM craplot craplot
         WHERE  craplot.cdcooper = pr_cdcooper
         AND    craplot.dtmvtolt = pr_dtmvtolt
         AND    craplot.cdagenci = pr_cdagenci
         AND    craplot.cdbccxlt = pr_cdbccxlt
         AND    craplot.nrdolote = pr_nrdolote;
       rw_craplot cr_craplot%ROWTYPE;  
       
       --Selecionar informacoes dos lancamentos na conta
       CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                         ,pr_nrdconta IN craplcm.nrdconta%TYPE
                         ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
         SELECT /*+ INDEX (craplcm craplcm##craplcm2) */
                craplcm.cdhistor
               ,craplcm.vllanmto
               ,craplcm.nrdconta
               ,craplcm.nrdocmto
               ,craplcm.dtmvtolt
               ,craplcm.nrdctabb
               ,craplcm.cdbanchq
               ,craplcm.cdagechq
               ,craplcm.nrctachq
               ,craplcm.nrdctitg
               ,craplcm.cdpesqbb
               ,craplcm.cdoperad
               ,craplcm.vldoipmf
               ,craplcm.cdcooper
               ,craplcm.ROWID
         FROM craplcm craplcm
         WHERE craplcm.cdcooper = pr_cdcooper
         AND   craplcm.nrdconta = pr_nrdconta
         AND   craplcm.dtmvtolt = pr_dtmvtolt
         AND   craplcm.cdhistor <> 289;
       rw_craplcm cr_craplcm%ROWTYPE;   
       
      -- Busca dados do cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT cdagenci
              ,vllimcre
              ,cdsitdct 
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;                   

      --Selecionar contratos de limites de creditos
      CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE
                        ,pr_nrdconta IN craplim.nrdconta%TYPE
                        ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                        ,pr_insitlim IN craplim.insitlim%TYPE) IS
         SELECT *
           FROM (SELECT craplim.nrdconta
                       ,craplim.cddlinha
                       ,craplim.dtinivig
                       ,craplim.vllimite
                       ,rownum nrlinha
                 FROM craplim craplim
                 WHERE  craplim.cdcooper = pr_cdcooper
                 AND    craplim.nrdconta = pr_nrdconta
                 AND    craplim.tpctrlim = pr_tpctrlim
                 AND    craplim.insitlim = pr_insitlim
                 ORDER BY craplim.cdcooper 
                        , craplim.nrdconta
                        , craplim.dtinivig
                        , craplim.tpctrlim
                        , craplim.nrctrlim)
          ORDER BY nrlinha DESC;  -- Order by realizado para simular o FIND LAST do progress
      rw_craplim cr_craplim%ROWTYPE;
      
      --Selecionar Cadastro de linhas de credito rotativos
      CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE
                        ,pr_cddlinha IN craplrt.cddlinha%TYPE) IS
        SELECT craplrt.ROWID
               ,craplrt.cddlinha
               ,craplrt.qtdiavig
               ,craplrt.txmensal
        FROM craplrt craplrt
        WHERE  craplrt.cdcooper = pr_cdcooper
        AND    craplrt.cddlinha = pr_cddlinha;
      rw_craplrt cr_craplrt%ROWTYPE;       
               
       vr_dscritic  VARCHAR2(2000);         
       vr_cdcritic  NUMBER:= 0;    
       vr_vlsddisp  NUMBER:= 0;       
       vr_dtmvtolt  DATE; 
       vr_nrseqdig  NUMBER:= 0;
       -- Cursor genérico de calendário
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;                                      
       
       vr_des_erro  VARCHAR2(100);      
       
       --Tipo da tabela de saldos
       vr_tab_saldo EXTR0001.typ_tab_saldos;
       vr_tab_erro  GENE0001.typ_tab_erro;
       
       vr_exc_saida  EXCEPTION; 

       -- Variáveis 
       vr_vlsmnmes crapsld.vlsmnmes%type;
       vr_vljuresp crapsld.vljuresp%type;
       vr_txjurneg NUMBER(35,10);
       vr_juros_negat craptab.dstextab%TYPE;
       
       procedure pc_saldo_dia is 
       begin
        -- Busca data cadastrada
        OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        CLOSE BTCH0001.cr_crapdat;
        
        -- Busca dados do cooperado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
         FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;
        if rw_crapass.cdsitdct != 7 then
           vr_dscritic:= 'Situação da conta não permite débito!';
         RAISE vr_exc_saida;
        end if;
        -- Verificar Saldo do cooperado
        extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper, 
                                    pr_rw_crapdat => rw_crapdat, 
                                    pr_cdagenci => 1, 
                                    pr_nrdcaixa => 0, 
                                    pr_cdoperad => '1', 
                                    pr_nrdconta => rw_crapsld.nrdconta, 
                                    pr_vllimcre => rw_crapass.vllimcre, 
                                    pr_dtrefere => rw_crapdat.dtmvtolt, 
                                    pr_flgcrass => FALSE, 
                                    pr_tipo_busca => 'A', -- Tipo Busca(A-dtmvtoan)
                                    pr_des_reto => vr_des_erro, 
                                    pr_tab_sald => vr_tab_saldo, 
                                    pr_tab_erro => vr_tab_erro);
                                                                  
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          -- Tenta buscar o erro no vetor de erro
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_crapsld.nrdconta;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_crapsld.nrdconta;
          END IF;
                                    
          IF vr_cdcritic <> 0 THEN
            vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ' Conta: '||rw_crapsld.nrdconta;
          END IF;                              

          --Levantar Excecao
          RAISE vr_exc_saida;
        ELSE
          vr_dscritic:= NULL;
        END IF;
        --Verificar o saldo retornado
        IF vr_tab_saldo.Count = 0 THEN
          --Montar mensagem erro
          vr_cdcritic:= 1072;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);--'Nao foi possivel consultar o saldo para a operacao.';                                              
          --Levantar Excecao
          RAISE vr_exc_saida;
        ELSE
          vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                         nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
        END IF; 
       end;
       
       procedure pc_lote is
       begin
         
       --Atribuir a data do movimento
       vr_dtmvtolt:= rw_crapdat.dtmvtolt;
       
              --Verificar se o lote existe
       OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => vr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8450);
       --Posicionar no proximo registro
       FETCH cr_craplot INTO rw_craplot;

       --Se encontrou registro
       IF cr_craplot%NOTFOUND THEN
         --Criar lote
         BEGIN
           --Inserir a capa do lote retornando informacoes para uso posterior
           INSERT INTO craplot (cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov)
                       VALUES  (pr_cdcooper
                               ,vr_dtmvtolt
                               ,1
                               ,100
                               ,8450
                               ,1)
                       RETURNING cdcooper
                                ,dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,ROWID
                       INTO  rw_craplot.cdcooper
                            ,rw_craplot.dtmvtolt
                            ,rw_craplot.cdagenci
                            ,rw_craplot.cdbccxlt
                            ,rw_craplot.nrdolote
                            ,rw_craplot.tplotmov
                            ,rw_craplot.rowid;
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao inserir na tabela craplot. '||SQLERRM;
             --Sair do programa
             RAISE vr_exc_saida;
         END;
       END IF;
       --Fechar Cursor
       CLOSE cr_craplot;  
       end;
       
       procedure pc_atualiza_lote(pr_vllanmto in craplcm.vllanmto%type,
                                  pr_rowid in rowid) is
       --atualizar capa do lote
       begin
         update craplot set craplot.vlinfodb = nvl(craplot.vlinfodb,0) + pr_vllanmto
                           ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + pr_vllanmto
                           ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                           ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                           ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
         where craplot.rowid = pr_rowid;
       exception
         when others then
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao atualizar tabela craplot. '||sqlerrm;
           --sair do programa
           raise vr_exc_saida;
       end;
       
  BEGIN
  
  if cr_crapsld%isopen then
   close cr_crapsld;
  end if;
  --
  open cr_crapsld(pr_cdcooper,pr_nrdconta);
   fetch cr_crapsld into rw_crapsld;

    --Valida Saldo da Conta
    pc_saldo_dia;

    --Busca ou cria lote
    pc_lote;   
     
    if pr_cdhistor = 37 then
    --pc_crps008
    /*Carrega taxa de juros do cheque especial, da multa c/c, multa s/saque bloq. */
    vr_juros_negat:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'JUROSNEGAT'
                                               ,pr_tpregist => 1);
    --Se nao encontrou                                              
    IF vr_juros_negat IS NULL THEN
      vr_cdcritic := 0;
      vr_dscritic:= 'Taxa de Juros não encontrada!';
      --Sair
      RAISE vr_exc_saida;
    ELSE
      --taxa Juros negativo
      vr_txjurneg:= gene0002.fn_char_para_number(SUBSTR(vr_juros_negat,1,10)) / 100;  
    END IF;     
   
    vr_vlsmnmes := (rw_crapsld.vlsmnmes * vr_txjurneg) * -1;
    
    --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
    BEGIN
      INSERT INTO craplcm (cdcooper
                          ,dtmvtolt
                          ,cdagenci
                          ,cdbccxlt
                          ,nrdolote
                          ,nrdconta
                          ,nrdctabb
                          ,nrdctitg
                          ,nrdocmto
                          ,cdhistor
                          ,nrseqdig
                          ,vllanmto
                          ,vldoipmf
                          ,cdcoptfn)
                  VALUES  (pr_cdcooper  
                          ,rw_craplot.dtmvtolt
                          ,rw_craplot.cdagenci
                          ,rw_craplot.cdbccxlt
                          ,rw_craplot.nrdolote
                          ,rw_crapsld.nrdconta
                          ,rw_crapsld.nrdconta
                          ,GENE0002.FN_MASK(rw_crapsld.nrdconta, '99999999')
                          ,TO_NUMBER(Nvl(rw_craplot.nrseqdig,0) + 1||99999937)
                          ,37
                          ,Nvl(rw_craplot.nrseqdig,0) + 1
                          ,vr_vlsmnmes
                          ,0
                          ,0)returning vllanmto into rw_craplcm.vllanmto;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir na tabela craplcm. '||SQLERRM;
        --Sair do programa
        RAISE vr_exc_saida;
    END;
    --
    begin
    update crapsld s
           --Incrementar a quantidade de lancamentos no mes
       set s.qtlanmes = Nvl(rw_crapsld.qtlanmes,0) + 1,
           --Zerar valor 
           s.vlsmnmes = 0
     where s.rowid = rw_crapsld.rowid;
    exception
     when others then
       vr_cdcritic := 0;
       vr_dscritic := 'Erro ao atualizar crapsld: '||sqlerrm;
       RAISE vr_exc_saida;
    end;       

    --pc_crps008 FIM
    elsif pr_cdhistor = 38 then
      
        --Selecionar informacoes dos limites de credito do associado
          OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => rw_crapsld.nrdconta
                          ,pr_tpctrlim => 1
                          ,pr_insitlim => 2);
          --Posicionar no proximo registro
          FETCH cr_craplim INTO rw_craplim;
          --Se nao encontrar
          IF cr_craplim%NOTFOUND THEN
            --Fechar cursor
            CLOSE cr_craplim;
            --Selecionar informacoes dos limites de credito do associado
            OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapsld.nrdconta
                            ,pr_tpctrlim => 1
                            ,pr_insitlim => 3);
            --Posicionar no proximo registro
            FETCH cr_craplim INTO rw_craplim;
            --Se nao encontrou
            IF cr_craplim%NOTFOUND THEN
              --Fechar cursor
              CLOSE cr_craplim;
              --Selecionar informacoes dos limites de credito do associado
              OPEN cr_craplim (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapsld.nrdconta
                            ,pr_tpctrlim => 1
                            ,pr_insitlim => 1);
              --Posicionar no proximo registro
              FETCH cr_craplim INTO rw_craplim;
              --Se nao encontrou
              IF cr_craplim%NOTFOUND THEN
                --Fechar cursor
                CLOSE cr_craplim;
              --Montar mensagem de erro com base na critica
              vr_cdcritic:= 105;
              --Sair do programa
              RAISE vr_exc_saida;
            END IF;
            END IF;
          END IF; 
          --Fechar Cursor
          IF cr_craplim%ISOPEN THEN
            CLOSE cr_craplim;
          END IF;  
          --Selecionar informacoes das linhas de credito do associado 
          OPEN cr_craplrt (pr_cdcooper => pr_cdcooper
                          ,pr_cddlinha => rw_craplim.cddlinha);
          FETCH cr_craplrt INTO rw_craplrt;
          --Se nao encontrou
          IF cr_craplrt%NOTFOUND THEN               
            --Fechar Cursor
            CLOSE cr_craplrt;
            --Buscar mensagem de erro da critica
            vr_cdcritic := 363;
            --Sair do programa
            RAISE vr_exc_saida;
          END IF;  
          --Fechar Cursor
          CLOSE cr_craplrt;     
       --pc_crps001
       IF TO_CHAR(rw_crapdat.dtmvtolt,'mm') <> TO_CHAR(rw_crapdat.dtmvtoan,'mm') THEN -- Primeiro Útil
         vr_vljuresp := rw_crapsld.vljuresp;
       ELSE
         vr_vljuresp := (rw_crapsld.vlsmnesp * (rw_craplrt.txmensal / 100)) * -1;
       END IF;         
       --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
       BEGIN
         INSERT INTO craplcm (cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,nrdconta
                             ,nrdctabb
                             ,nrdctitg
                             ,nrdocmto
                             ,cdhistor
                             ,nrseqdig
                             ,vllanmto
                             ,vldoipmf
                             ,cdcoptfn)
                     VALUES  (pr_cdcooper
                             ,rw_craplot.dtmvtolt
                             ,rw_craplot.cdagenci
                             ,rw_craplot.cdbccxlt
                             ,rw_craplot.nrdolote
                             ,rw_crapsld.nrdconta
                             ,rw_crapsld.nrdconta
                             ,GENE0002.FN_MASK(rw_crapsld.nrdconta, '99999999')
                             ,99999938
                             ,38
                             ,Nvl(rw_craplot.nrseqdig,0) + 1
                             ,vr_vljuresp
                             ,0
                             ,0)returning vllanmto into rw_craplcm.vllanmto;
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao inserir na tabela craplcm. '||SQLERRM;
           --Sair do programa
           RAISE vr_exc_saida;
       END;
       --
       begin
       update crapsld s
              --Incrementar a quantidade de lancamentos no mes
          set s.qtlanmes = Nvl(rw_crapsld.qtlanmes,0) + 1,
              --Zerar valor juros mes
              s.vljuresp = 0,
              s.vlsmnesp = 0
        where s.rowid = rw_crapsld.rowid;
       exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar crapsld: '||sqlerrm;
          RAISE vr_exc_saida;
       end;      
    elsif pr_cdhistor = 2323 then
     --pc_crps001
     --Inserir lancamento retornando o valor do rowid e do lançamento para uso posterior
     BEGIN
       INSERT INTO craplcm (cdcooper
                           ,dtmvtolt
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,nrdconta
                           ,nrdctabb
                           ,nrdctitg
                           ,nrdocmto
                           ,cdhistor
                           ,nrseqdig
                           ,vllanmto
                           ,cdpesqbb
                           ,vldoipmf)
                   VALUES  (pr_cdcooper
                           ,rw_craplot.dtmvtolt
                           ,rw_craplot.cdagenci
                           ,rw_craplot.cdbccxlt
                           ,rw_craplot.nrdolote
                           ,rw_crapsld.nrdconta
                           ,rw_crapsld.nrdconta
                           ,to_char(rw_crapsld.nrdconta,'fm00000000')
                           ,99999323
                           ,2323
                           ,Nvl(rw_craplot.nrseqdig,0) + 1
                           ,round(rw_crapsld.vliofmes,2)
                           ,to_char(rw_crapsld.vlbasiof,'fm000g000g000d00')
                           ,0)returning vllanmto into rw_craplcm.vllanmto;
     EXCEPTION
       WHEN OTHERS THEN
         vr_cdcritic := 0;
         vr_dscritic := 'Erro ao inserir na tabela craplcm. '|| SQLERRM;
         --Sair do programa
         RAISE vr_exc_saida;
     END;
     --------------------------------------------------------------------------------------------------
     -- Atualizar os dados do IOF
     --------------------------------------------------------------------------------------------------
     TIOF0001.pc_altera_iof(pr_cdcooper     => pr_cdcooper
                           ,pr_nrdconta     => rw_crapsld.nrdconta
                           ,pr_dtmvtolt     => rw_craplot.dtmvtolt
                           ,pr_tpproduto    => 5
                           ,pr_nrcontrato   => 0
                           ,pr_cdagenci_lcm => rw_craplot.cdagenci
                           ,pr_cdbccxlt_lcm => rw_craplot.cdbccxlt
                           ,pr_nrdolote_lcm => rw_craplot.nrdolote
                           ,pr_nrseqdig_lcm => vr_nrseqdig
                           ,pr_cdcritic     => vr_cdcritic
                           ,pr_dscritic     => vr_dscritic);
                                  
     -- Condicao para verificar se houve critica                             
     IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
     END IF;
     
     begin
     --Atualizações crapsld
     update crapsld s
            --Incrementar a quantidade de lancamentos no mes
        set s.qtlanmes = Nvl(rw_crapsld.qtlanmes,0) + 1,
            --Zerar valor iof no mes
            s.vliofmes = 0,
            --Zerar valor base iof
            s.vlbasiof = 0
      where s.rowid = rw_crapsld.rowid;
     exception
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crapsld: '||sqlerrm;
        RAISE vr_exc_saida;
     end;

    end if; -- Fim 2323
    close cr_crapsld;
    pc_atualiza_lote(rw_craplcm.vllanmto,rw_craplot.rowid);
    --
    commit;
    EXCEPTION
      WHEN vr_exc_saida THEN
        rollback;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;        
      WHEN OTHERS THEN
        rollback;
        pr_cdcritic := 0;
        pr_dscritic := 'pc_efetiva_lcto_pendente_sld: ' || SQLERRM;

  END pc_efetiva_lcto_pendente_sld;    

END TELA_LAUTOM;
/
