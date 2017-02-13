CREATE OR REPLACE PACKAGE CECRED.TELA_FLUXOS IS

  PROCEDURE pc_consulta_fluxo_caixa(pr_cdcooper   IN crapffm.cdcooper%TYPE --> Cooperativa
                                   ,pr_dtrefini   IN VARCHAR2 --> Data inicial
                                   ,pr_dtreffim   IN VARCHAR2 --> Data final
                                   ,pr_tpdmovto   IN VARCHAR2 --> [1,2]-Realizado / [3,4]-Projetado
                                   ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2); --> Erros do processo


  PROCEDURE pc_consulta_movimentacao(pr_dtrefere  IN VARCHAR2 --> Data dereferencia
                                    ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_consulta_liquidacao(pr_cdcooper  IN INTEGER --> Cooperativa
                                  ,pr_dtrefere  IN VARCHAR2 --> Data dereferencia
                                  ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_consulta_fluxo_dia(pr_cdcooper  IN INTEGER --> Cooperativa
                                 ,pr_dtrefere  IN VARCHAR2 --> Data dereferencia
                                 ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_dados(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                          ,pr_dtrefere IN VARCHAR2 --> Data dereferencia
                          ,pr_vldiv085 IN NUMBER --> Diversos 085
                          ,pr_vldiv001 IN NUMBER --> Diversos 001
                          ,pr_vldiv756 IN NUMBER --> Diversos 756
                          ,pr_vldiv748 IN NUMBER --> Diversos 748
                          ,pr_vldivtot IN NUMBER --> Diversos total
                          ,pr_vlresgat IN NUMBER --> Resgate
                          ,pr_vlaplica IN NUMBER --> Aplicacao
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2); --> Erros do processo

END TELA_FLUXOS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_FLUXOS IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_FLUXOS
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Outubro - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela FLUXOS
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  -- Busca as informacoes da cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
      FROM crapcop crapcop
     WHERE crapcop.cdcooper = DECODE(pr_cdcooper, 0, crapcop.cdcooper, pr_cdcooper)
       AND crapcop.cdcooper <> 3
       AND crapcop.flgativo = 1;

  -- Busca operador
  CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                   ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
    SELECT cdoperad
          ,nmoperad
          ,cddepart
      FROM crapope
     WHERE cdcooper = pr_cdcooper
       AND UPPER(cdoperad) = UPPER(pr_cdoperad);
  rw_crapope cr_crapope%ROWTYPE;

  -- Cursor da data
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  PROCEDURE pc_consulta_fluxo_caixa(pr_cdcooper   IN crapffm.cdcooper%TYPE --> Cooperativa
                                   ,pr_dtrefini   IN VARCHAR2 --> Data inicial
                                   ,pr_dtreffim   IN VARCHAR2 --> Data final
                                   ,pr_tpdmovto   IN VARCHAR2 --> [1,2]-Realizado / [3,4]-Projetado
                                   ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                   ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                   ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_consulta_fluxo_caixa
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar informacoes da movimentacao do fluxo financeiro.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar o saldo final C/C
      CURSOR cr_saldo(pr_cdcooper IN crapffm.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapffm.dtmvtolt%TYPE) IS
        SELECT ffc.vlsldcta
          FROM crapffc ffc
         WHERE ffc.cdcooper = pr_cdcooper
           AND ffc.dtmvtolt = pr_dtmvtolt;
      rw_saldo cr_saldo%ROWTYPE;

      -- Selecionar fluxo financeiro
      CURSOR cr_crapffm(pr_cdcooper IN crapffm.cdcooper%TYPE
                       ,pr_dtrefini IN crapffm.dtmvtolt%TYPE
                       ,pr_dtreffim IN crapffm.dtmvtolt%TYPE
                       ,pr_tpdmovto IN VARCHAR2
                       ,pr_cdbccxlt IN crapffm.cdbccxlt%TYPE) IS
        SELECT ffm.tpdmovto

              -- CECRED
              ,ffm.vlcheque -- NR_CHEQUES / SR_CHEQUES
              ,ffm.vltotdoc -- SR_DOC / NR_DOC
              ,ffm.vldevolu -- DEV_CHEQUE_REMETIDO / DEV_CHEQUE_RECEBIDO
              ,ffm.vltrfitc -- TRANSF_INTER
              ,ffm.vldepitc -- DEP_INTER
              ,ffm.vlsatait -- SAQUE_TAA_INTERC
              ,ffm.vlnumera -- RECOLHIMENTO_NUMERARIO / SUPRIMENTO_NUMERARIO

              ,ffm.vlcheque + ffm.vltotdoc + ffm.vltotted + ffm.vltottit 
              +ffm.vldevolu + ffm.vltrfitc + ffm.vldepitc + ffm.vlsatait 
              +ffm.vlcarcre + ffm.vlnumera + ffm.vlconven CEC_SOMA -- [1,3]-ENTRADAS / [2,4]-SAIDAS

              -- BANCO DO BRASIL
              ,ffm.vlmvtitg -- MVTO_CONTA_ITG
              ,ffm.vltottit + ffm.vlmvtitg BB_SOMA -- [1,3]-ENTRADAS / [2,4]-SAIDAS

              -- BANCOOB
              ,ffm.vlcardeb -- CARTAO_DEBITO
              ,ffm.vlcarcre + ffm.vlcardeb + ffm.vlttinss BCO_SOMA -- [1,3]-ENTRADAS / [2,4]-SAIDAS
              
              -- SICREDI
              ,ffm.vlconven + ffm.vlttinss SIC_SOMA -- [1,3]-ENTRADAS / [2,4]-SAIDAS

              -- CECRED/BANCOOB
              ,ffm.vlcarcre -- CARTAO_CREDITO

              -- CECRED / SICREDI
              ,ffm.vltotted -- SR_TED / NR_TED_TEC
              ,ffm.vlconven -- CONVENIOS

              -- CECRED / BANCO DO BRASIL
              ,ffm.vltottit -- SR_TITULOS / NR_TITULOS

              -- BANCOOB / SICREDI
              ,ffm.vlttinss -- INSS / GPS

          FROM crapffm ffm
         WHERE ffm.cdcooper = pr_cdcooper
           AND ffm.dtmvtolt BETWEEN pr_dtrefini AND pr_dtreffim
           AND ffm.tpdmovto IN (SELECT regexp_substr(pr_tpdmovto, '[^,;]+', 1, ROWNUM) N
                                  FROM dual
                      CONNECT BY LEVEL <= length(regexp_replace(pr_tpdmovto, '[^,;]+', '')) + 1)
           AND ffm.cdbccxlt = pr_cdbccxlt;

      -- Tabela temporaria para os valores
      TYPE typ_reg_crapffm IS RECORD(vlcheque NUMBER
                                    ,vltotdoc NUMBER
                                    ,vldevolu NUMBER
                                    ,vltrfitc NUMBER
                                    ,vldepitc NUMBER
                                    ,vlsatait NUMBER
                                    ,vlnumera NUMBER
                                    ,cec_soma NUMBER
                                    ,vlmvtitg NUMBER
                                    ,bb_soma  NUMBER
                                    ,vlcardeb NUMBER
                                    ,bco_soma NUMBER
                                    ,sic_soma NUMBER
                                    ,vlcarcre NUMBER
                                    ,vltotted NUMBER
                                    ,vlconven NUMBER
                                    ,vltottit NUMBER
                                    ,vlttinss NUMBER);
      TYPE typ_tab_crapffm IS TABLE OF typ_reg_crapffm INDEX BY VARCHAR2(4);
      -- Vetor para armazenar os valores
      vr_tab_crapffm typ_tab_crapffm;
      -- Vetor para os bancos
      vr_dsbancos GENE0002.typ_split;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdoperad VARCHAR2(100);
      vr_cdcooper NUMBER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis Gerais
      vr_dtrefini           crapffm.dtmvtolt%TYPE;
      vr_dtreffim           crapffm.dtmvtolt%TYPE;
      vr_contador           INTEGER := 0;
      vr_index              VARCHAR2(4) := '';
      vr_tpdmovto           VARCHAR2(10);
      vr_vlsldcta           NUMBER := 0;
      vr_projetado          NUMBER := 0;
      vr_realizado          NUMBER := 0;
      vr_tot_projetado      NUMBER := 0;
      vr_tot_realizado      NUMBER := 0;
      vr_tot_projetado_in   NUMBER := 0;
      vr_tot_realizado_in   NUMBER := 0;
      vr_tot_projetado_out  NUMBER := 0;
      vr_tot_realizado_out  NUMBER := 0;
      vr_projetado_vlcheque NUMBER := 0;
      vr_projetado_vltotdoc NUMBER := 0;
      vr_projetado_vldevolu NUMBER := 0;
      vr_projetado_vltrfitc NUMBER := 0;
      vr_projetado_vldepitc NUMBER := 0;
      vr_projetado_vlsatait NUMBER := 0;
      vr_projetado_vlnumera NUMBER := 0;
      vr_projetado_cec_soma NUMBER := 0;
      vr_projetado_vlmvtitg NUMBER := 0;
      vr_projetado_bb_soma  NUMBER := 0;
      vr_projetado_vlcardeb NUMBER := 0;
      vr_projetado_bco_soma NUMBER := 0;
      vr_projetado_sic_soma NUMBER := 0;
      vr_projetado_vlcarcre NUMBER := 0;
      vr_projetado_vltotted NUMBER := 0;
      vr_projetado_vlconven NUMBER := 0;
      vr_projetado_vltottit NUMBER := 0;
      vr_projetado_vlttinss NUMBER := 0;
      vr_realizado_vlcheque NUMBER := 0;
      vr_realizado_vltotdoc NUMBER := 0;
      vr_realizado_vldevolu NUMBER := 0;
      vr_realizado_vltrfitc NUMBER := 0;
      vr_realizado_vldepitc NUMBER := 0;
      vr_realizado_vlsatait NUMBER := 0;
      vr_realizado_vlnumera NUMBER := 0;
      vr_realizado_cec_soma NUMBER := 0;
      vr_realizado_vlmvtitg NUMBER := 0;
      vr_realizado_bb_soma  NUMBER := 0;
      vr_realizado_vlcardeb NUMBER := 0;
      vr_realizado_bco_soma NUMBER := 0;
      vr_realizado_sic_soma NUMBER := 0;
      vr_realizado_vlcarcre NUMBER := 0;
      vr_realizado_vltotted NUMBER := 0;
      vr_realizado_vlconven NUMBER := 0;
      vr_realizado_vltottit NUMBER := 0;
      vr_realizado_vlttinss NUMBER := 0;

      vr_realizado_cec_in   NUMBER := 0;
      vr_realizado_cec_out  NUMBER := 0;
      vr_projetado_cec_in   NUMBER := 0;
      vr_projetado_cec_out  NUMBER := 0;
      vr_realizado_bb_in    NUMBER := 0;
      vr_realizado_bb_out   NUMBER := 0;
      vr_projetado_bb_in    NUMBER := 0;
      vr_projetado_bb_out   NUMBER := 0;
      vr_realizado_bco_in   NUMBER := 0;
      vr_realizado_bco_out  NUMBER := 0;
      vr_projetado_bco_in   NUMBER := 0;
      vr_projetado_bco_out  NUMBER := 0;
      vr_realizado_sic_in   NUMBER := 0;
      vr_realizado_sic_out  NUMBER := 0;
      vr_projetado_sic_in   NUMBER := 0;
      vr_projetado_sic_out  NUMBER := 0;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_consulta_fluxo_caixa'
                                ,pr_action => NULL);

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Data de referencia
      vr_dtrefini := TO_DATE(pr_dtrefini,'DD/MM/RRRR');
      vr_dtreffim := TO_DATE(pr_dtreffim,'DD/MM/RRRR');

      -- Se NAO for dia util
      IF vr_dtrefini <> GENE0005.fn_valida_dia_util
                                (pr_cdcooper => vr_cdcooper
                                ,pr_dtmvtolt => vr_dtrefini) THEN
        vr_cdcritic := 13;
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO for dia util
      IF vr_dtreffim <> GENE0005.fn_valida_dia_util
                                (pr_cdcooper => vr_cdcooper
                                ,pr_dtmvtolt => vr_dtreffim) THEN
        vr_cdcritic := 13;
        RAISE vr_exc_saida;
      END IF;

      -- Tipo de movimento
      IF pr_tpdmovto = 'E' THEN -- Entrada
          vr_tpdmovto := '1,3'; -- [1]-Realizado / [3]-Projetado
      ELSIF pr_tpdmovto = 'S' THEN -- Saida
          vr_tpdmovto := '2,4'; -- [2]-Realizado / [4]-Projetado
      ELSIF pr_tpdmovto = 'R' THEN -- Resultado
          vr_tpdmovto := '1,2,3,4'; -- [1,2]-Realizado / [3,4]-Projetado
      END IF;

      -- 85-Cecred / 1-Banco do Brasil / 756-Bancoob / 748-Sicredi
      vr_dsbancos := GENE0002.fn_quebra_string(pr_string  => '85,1,756,748'
                                              ,pr_delimit => ',');
      
      -- Inicializa as variaveis
      FOR vr_idx IN 1..4 LOOP
        -- Listagem de bancos
        FOR vr_iba IN 1..vr_dsbancos.COUNT() LOOP
          vr_index := LPAD(vr_dsbancos(vr_iba),3,'0') || vr_idx;
          vr_tab_crapffm(vr_index).vlcheque := 0;
          vr_tab_crapffm(vr_index).vltotdoc := 0;
          vr_tab_crapffm(vr_index).vldevolu := 0;
          vr_tab_crapffm(vr_index).vltrfitc := 0;
          vr_tab_crapffm(vr_index).vldepitc := 0;
          vr_tab_crapffm(vr_index).vlsatait := 0;
          vr_tab_crapffm(vr_index).vlnumera := 0;
          vr_tab_crapffm(vr_index).cec_soma := 0;
          vr_tab_crapffm(vr_index).vlmvtitg := 0;
          vr_tab_crapffm(vr_index).bb_soma  := 0;
          vr_tab_crapffm(vr_index).vlcardeb := 0;
          vr_tab_crapffm(vr_index).bco_soma := 0;
          vr_tab_crapffm(vr_index).sic_soma := 0;
          vr_tab_crapffm(vr_index).vlcarcre := 0;
          vr_tab_crapffm(vr_index).vltotted := 0;
          vr_tab_crapffm(vr_index).vlconven := 0;
          vr_tab_crapffm(vr_index).vltottit := 0;
          vr_tab_crapffm(vr_index).vlttinss := 0;
        END LOOP;
      END LOOP;

      -- Busca as informacoes da cooperativa
      FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP

        -- Busca a data do sistema
        OPEN  BTCH0001.cr_crapdat(rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        CLOSE BTCH0001.cr_crapdat;
        
        -- Se for RESULTADO
        IF pr_tpdmovto = 'R' THEN
          -- Selecionar o saldo final C/C
          OPEN cr_saldo(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_dtmvtolt => vr_dtrefini);
          FETCH cr_saldo INTO rw_saldo;
          CLOSE cr_saldo;
          vr_vlsldcta := vr_vlsldcta + NVL(rw_saldo.vlsldcta,0);
        END IF;

        -- Se data de referencia for a mesma da cooperativa conectada
        IF vr_dtrefini = rw_crapdat.dtmvtolt THEN
          -- Gravar movimento do fluxo financeiro
          FLXF0001.pc_grava_fluxo_financeiro
                  (pr_cdcooper => rw_crapcop.cdcooper  -- Codigo da Cooperativa
                  ,pr_cdagenci => vr_cdagenci          -- Codigo da agencia
                  ,pr_nrdcaixa => 0                    -- Numero da caixa
                  ,pr_cdoperad => vr_cdoperad          -- Codigo do operador
                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento
                  ,pr_cdprogra => NULL                 -- Nome da tela
                  ,pr_dtmvtoan => rw_crapdat.dtmvtoan  -- Data de movimento anterior
                  ,pr_dtmvtopr => rw_crapdat.dtmvtopr  -- Data do movimento posterior
                  ,pr_tab_erro => vr_tab_erro          -- Tabela contendo os erros
                  ,pr_dscritic => vr_dscritic);
          -- Se retornou erro
          IF vr_dscritic <> 'OK' OR vr_tab_erro.COUNT > 0 THEN
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            RAISE vr_exc_saida;
          END IF;
        END IF;

        -- Listagem de bancos
        FOR vr_iba IN 1..vr_dsbancos.COUNT() LOOP

          -- Selecionar fluxo financeiro
          FOR rw_crapffm IN cr_crapffm(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_dtrefini => vr_dtrefini
                                      ,pr_dtreffim => vr_dtreffim
                                      ,pr_tpdmovto => vr_tpdmovto
                                      ,pr_cdbccxlt => vr_dsbancos(vr_iba)) LOOP
            vr_index := LPAD(vr_dsbancos(vr_iba),3,'0') || rw_crapffm.tpdmovto;
            vr_tab_crapffm(vr_index).vlcheque := vr_tab_crapffm(vr_index).vlcheque + NVL(rw_crapffm.vlcheque,0);
            vr_tab_crapffm(vr_index).vltotdoc := vr_tab_crapffm(vr_index).vltotdoc + NVL(rw_crapffm.vltotdoc,0);
            vr_tab_crapffm(vr_index).vldevolu := vr_tab_crapffm(vr_index).vldevolu + NVL(rw_crapffm.vldevolu,0);
            vr_tab_crapffm(vr_index).vltrfitc := vr_tab_crapffm(vr_index).vltrfitc + NVL(rw_crapffm.vltrfitc,0);
            vr_tab_crapffm(vr_index).vldepitc := vr_tab_crapffm(vr_index).vldepitc + NVL(rw_crapffm.vldepitc,0);
            vr_tab_crapffm(vr_index).vlsatait := vr_tab_crapffm(vr_index).vlsatait + NVL(rw_crapffm.vlsatait,0);
            vr_tab_crapffm(vr_index).vlnumera := vr_tab_crapffm(vr_index).vlnumera + NVL(rw_crapffm.vlnumera,0);
            vr_tab_crapffm(vr_index).cec_soma := vr_tab_crapffm(vr_index).cec_soma + NVL(rw_crapffm.cec_soma,0);
            vr_tab_crapffm(vr_index).vlmvtitg := vr_tab_crapffm(vr_index).vlmvtitg + NVL(rw_crapffm.vlmvtitg,0);
            vr_tab_crapffm(vr_index).bb_soma  := vr_tab_crapffm(vr_index).bb_soma  + NVL(rw_crapffm.bb_soma,0);
            vr_tab_crapffm(vr_index).vlcardeb := vr_tab_crapffm(vr_index).vlcardeb + NVL(rw_crapffm.vlcardeb,0);
            vr_tab_crapffm(vr_index).bco_soma := vr_tab_crapffm(vr_index).bco_soma + NVL(rw_crapffm.bco_soma,0);
            vr_tab_crapffm(vr_index).sic_soma := vr_tab_crapffm(vr_index).sic_soma + NVL(rw_crapffm.sic_soma,0);
            vr_tab_crapffm(vr_index).vlcarcre := vr_tab_crapffm(vr_index).vlcarcre + NVL(rw_crapffm.vlcarcre,0);
            vr_tab_crapffm(vr_index).vltotted := vr_tab_crapffm(vr_index).vltotted + NVL(rw_crapffm.vltotted,0);
            vr_tab_crapffm(vr_index).vlconven := vr_tab_crapffm(vr_index).vlconven + NVL(rw_crapffm.vlconven,0);
            vr_tab_crapffm(vr_index).vltottit := vr_tab_crapffm(vr_index).vltottit + NVL(rw_crapffm.vltottit,0);
            vr_tab_crapffm(vr_index).vlttinss := vr_tab_crapffm(vr_index).vlttinss + NVL(rw_crapffm.vlttinss,0);
          END LOOP; -- cr_crapffm

        END LOOP; -- vr_iba IN 1..vr_dsbancos.COUNT()

      END LOOP; -- cr_crapcop

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
                            ,pr_tag_nova => 'movtos'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Montar XML
      vr_index := vr_tab_crapffm.FIRST;
      WHILE vr_index IS NOT NULL LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'movtos'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'tpdmovto'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'codigo'
                              ,pr_tag_cont => vr_index -- Codigo montado, ex: 0851 --> 85-Cecred, 1-Realizado
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlcheque'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vlcheque,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vltotdoc'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vltotdoc,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vldevolu'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vldevolu,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vltrfitc'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vltrfitc,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vldepitc'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vldepitc,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlsatait'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vlsatait,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlnumera'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vlnumera,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'cec_soma'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).cec_soma,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlmvtitg'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vlmvtitg,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'bb_soma'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).bb_soma,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlcardeb'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vlcardeb,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'bco_soma'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).bco_soma,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'sic_soma'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).sic_soma,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlcarcre'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vlcarcre,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vltotted'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vltotted,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlconven'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vlconven,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vltottit'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vltottit,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'tpdmovto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlttinss'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapffm(vr_index).vlttinss,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        -- Se for ENTRADA busca o indicador de backgound
        IF pr_tpdmovto = 'E' THEN
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_nr_cheques'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 1
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_sr_doc'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 2
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_sr_ted'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 3
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_sr_titulos'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 4
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_dev_cheque_remetido'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 5
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_transf_inter'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 8
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_dep_inter'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 12
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_saque_taa_interc'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 9
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_recolhimento_numerario'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 13
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_mvto_conta_itg'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 6
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_inss'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 7
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

        -- Se for SAIDA busca o indicador de backgound
        ELSIF pr_tpdmovto = 'S' THEN
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_sr_cheques'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 1
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_nr_doc'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 2
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_nr_ted_tec'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 3
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_nr_titulos'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 4
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_dev_cheque_recebido'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 5
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_transf_inter'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 8
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_dep_inter'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 12
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_saque_taa_interc'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 9
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_cartao_credito'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 10
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_suprimento_numerario'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 13
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_convenios'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 11
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_mvto_conta_itg'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 6
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_cartao_debito'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 14
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'bg_gps'
                                ,pr_tag_cont => FLXF0001.fn_tpfluxo_remessa
                                                        (pr_cdremessa  => 7
                                                        ,pr_tpfluxo_es => pr_tpdmovto)
                                ,pr_des_erro => vr_dscritic);

        -- Se for RESULTADO
        ELSIF pr_tpdmovto = 'R' THEN

          CASE SUBSTR(vr_index,-1)

             WHEN '1' THEN
               vr_realizado_cec_in := vr_realizado_cec_in + vr_tab_crapffm(vr_index).cec_soma;
               vr_realizado_bb_in  := vr_realizado_bb_in  + vr_tab_crapffm(vr_index).bb_soma;
               vr_realizado_bco_in := vr_realizado_bco_in + vr_tab_crapffm(vr_index).bco_soma;
               vr_realizado_sic_in := vr_realizado_sic_in + vr_tab_crapffm(vr_index).sic_soma;

             WHEN '2' THEN
               vr_realizado_cec_out := vr_realizado_cec_out + vr_tab_crapffm(vr_index).cec_soma;
               vr_realizado_bb_out  := vr_realizado_bb_out  + vr_tab_crapffm(vr_index).bb_soma;
               vr_realizado_bco_out := vr_realizado_bco_out + vr_tab_crapffm(vr_index).bco_soma;
               vr_realizado_sic_out := vr_realizado_sic_out + vr_tab_crapffm(vr_index).sic_soma;

             WHEN '3' THEN
               vr_projetado_cec_in := vr_projetado_cec_in + vr_tab_crapffm(vr_index).cec_soma;
               vr_projetado_bb_in  := vr_projetado_bb_in  + vr_tab_crapffm(vr_index).bb_soma;
               vr_projetado_bco_in := vr_projetado_bco_in + vr_tab_crapffm(vr_index).bco_soma;
               vr_projetado_sic_in := vr_projetado_sic_in + vr_tab_crapffm(vr_index).sic_soma;

             WHEN '4' THEN
               vr_projetado_cec_out := vr_projetado_cec_out + vr_tab_crapffm(vr_index).cec_soma;
               vr_projetado_bb_out  := vr_projetado_bb_out  + vr_tab_crapffm(vr_index).bb_soma;
               vr_projetado_bco_out := vr_projetado_bco_out + vr_tab_crapffm(vr_index).bco_soma;
               vr_projetado_sic_out := vr_projetado_sic_out + vr_tab_crapffm(vr_index).sic_soma;

          END CASE;

        END IF;

        -- Somariza: [1,2]-Realizado
        IF SUBSTR(vr_index,-1) IN ('1','2') THEN

          vr_realizado_vlcheque := vr_realizado_vlcheque + vr_tab_crapffm(vr_index).vlcheque;
          vr_realizado_vltotdoc := vr_realizado_vltotdoc + vr_tab_crapffm(vr_index).vltotdoc;
          vr_realizado_vldevolu := vr_realizado_vldevolu + vr_tab_crapffm(vr_index).vldevolu;
          vr_realizado_vltrfitc := vr_realizado_vltrfitc + vr_tab_crapffm(vr_index).vltrfitc;
          vr_realizado_vldepitc := vr_realizado_vldepitc + vr_tab_crapffm(vr_index).vldepitc;
          vr_realizado_vlsatait := vr_realizado_vlsatait + vr_tab_crapffm(vr_index).vlsatait;
          vr_realizado_vlnumera := vr_realizado_vlnumera + vr_tab_crapffm(vr_index).vlnumera;
          vr_realizado_cec_soma := vr_realizado_cec_soma + vr_tab_crapffm(vr_index).cec_soma;
          vr_realizado_vlmvtitg := vr_realizado_vlmvtitg + vr_tab_crapffm(vr_index).vlmvtitg;
          vr_realizado_bb_soma  := vr_realizado_bb_soma  + vr_tab_crapffm(vr_index).bb_soma;
          vr_realizado_vlcardeb := vr_realizado_vlcardeb + vr_tab_crapffm(vr_index).vlcardeb;
          vr_realizado_bco_soma := vr_realizado_bco_soma + vr_tab_crapffm(vr_index).bco_soma;
          vr_realizado_sic_soma := vr_realizado_sic_soma + vr_tab_crapffm(vr_index).sic_soma;
          vr_realizado_vlcarcre := vr_realizado_vlcarcre + vr_tab_crapffm(vr_index).vlcarcre;
          vr_realizado_vltotted := vr_realizado_vltotted + vr_tab_crapffm(vr_index).vltotted;
          vr_realizado_vlconven := vr_realizado_vlconven + vr_tab_crapffm(vr_index).vlconven;
          vr_realizado_vltottit := vr_realizado_vltottit + vr_tab_crapffm(vr_index).vltottit;
          vr_realizado_vlttinss := vr_realizado_vlttinss + vr_tab_crapffm(vr_index).vlttinss;

        -- Somariza: [3,4]-Projetado
        ELSE

          vr_projetado_vlcheque := vr_projetado_vlcheque + vr_tab_crapffm(vr_index).vlcheque;
          vr_projetado_vltotdoc := vr_projetado_vltotdoc + vr_tab_crapffm(vr_index).vltotdoc;
          vr_projetado_vldevolu := vr_projetado_vldevolu + vr_tab_crapffm(vr_index).vldevolu;
          vr_projetado_vltrfitc := vr_projetado_vltrfitc + vr_tab_crapffm(vr_index).vltrfitc;
          vr_projetado_vldepitc := vr_projetado_vldepitc + vr_tab_crapffm(vr_index).vldepitc;
          vr_projetado_vlsatait := vr_projetado_vlsatait + vr_tab_crapffm(vr_index).vlsatait;
          vr_projetado_vlnumera := vr_projetado_vlnumera + vr_tab_crapffm(vr_index).vlnumera;
          vr_projetado_cec_soma := vr_projetado_cec_soma + vr_tab_crapffm(vr_index).cec_soma;
          vr_projetado_vlmvtitg := vr_projetado_vlmvtitg + vr_tab_crapffm(vr_index).vlmvtitg;
          vr_projetado_bb_soma  := vr_projetado_bb_soma  + vr_tab_crapffm(vr_index).bb_soma;
          vr_projetado_vlcardeb := vr_projetado_vlcardeb + vr_tab_crapffm(vr_index).vlcardeb;
          vr_projetado_bco_soma := vr_projetado_bco_soma + vr_tab_crapffm(vr_index).bco_soma;
          vr_projetado_sic_soma := vr_projetado_sic_soma + vr_tab_crapffm(vr_index).sic_soma;
          vr_projetado_vlcarcre := vr_projetado_vlcarcre + vr_tab_crapffm(vr_index).vlcarcre;
          vr_projetado_vltotted := vr_projetado_vltotted + vr_tab_crapffm(vr_index).vltotted;
          vr_projetado_vlconven := vr_projetado_vlconven + vr_tab_crapffm(vr_index).vlconven;
          vr_projetado_vltottit := vr_projetado_vltottit + vr_tab_crapffm(vr_index).vltottit;
          vr_projetado_vlttinss := vr_projetado_vlttinss + vr_tab_crapffm(vr_index).vlttinss;

        END IF; -- SUBSTR(vr_index,-1) IN ('1','2')
        
        -- Se for o ultimo registro de cada banco
        IF SUBSTR(vr_index,-1) = '4' THEN

          -- Se for ENTRADA
          IF pr_tpdmovto = 'E' THEN

            -- Somariza o total geral
            vr_tot_projetado := vr_tot_projetado
                              + vr_projetado_vlcheque + vr_projetado_vltotdoc + vr_projetado_vltotted
                              + vr_projetado_vltottit + vr_projetado_vldevolu + vr_projetado_vltrfitc
                              + vr_projetado_vldepitc + vr_projetado_vlsatait + vr_projetado_vlnumera
                              + vr_projetado_vlmvtitg + vr_projetado_vlttinss;

            vr_tot_realizado := vr_tot_realizado
                              + vr_realizado_vlcheque + vr_realizado_vltotdoc + vr_realizado_vltotted
                              + vr_realizado_vltottit + vr_realizado_vldevolu + vr_realizado_vltrfitc
                              + vr_realizado_vldepitc + vr_realizado_vlsatait + vr_realizado_vlnumera
                              + vr_realizado_vlmvtitg + vr_realizado_vlttinss;

          -- Se for SAIDA
          ELSIF pr_tpdmovto = 'S' THEN

            -- Somariza o total geral
            vr_tot_projetado := vr_tot_projetado
                              + vr_projetado_vlcheque + vr_projetado_vltotdoc + vr_projetado_vltotted
                              + vr_projetado_vltottit + vr_projetado_vldevolu + vr_projetado_vltrfitc
                              + vr_projetado_vldepitc + vr_projetado_vlsatait + vr_projetado_vlcarcre
                              + vr_projetado_vlnumera + vr_projetado_vlconven + vr_projetado_vlmvtitg
                              + vr_projetado_vlcardeb + vr_projetado_vlttinss;

            vr_tot_realizado := vr_tot_realizado
                              + vr_realizado_vlcheque + vr_realizado_vltotdoc + vr_realizado_vltotted
                              + vr_realizado_vltottit + vr_realizado_vldevolu + vr_realizado_vltrfitc 
                              + vr_realizado_vldepitc + vr_realizado_vlsatait + vr_realizado_vlcarcre
                              + vr_realizado_vlnumera + vr_realizado_vlconven + vr_realizado_vlmvtitg
                              + vr_realizado_vlcardeb + vr_realizado_vlttinss;

          -- Se for RESULTADO
          ELSE

            -- Somariza o total geral de Entradas e Saidas
            CASE SUBSTR(vr_index,1,3)

               WHEN '085' THEN
                 vr_tot_projetado_in  := vr_tot_projetado_in  + vr_projetado_cec_in;
                 vr_tot_realizado_in  := vr_tot_realizado_in  + vr_realizado_cec_in;
                 vr_tot_projetado_out := vr_tot_projetado_out + vr_projetado_cec_out;
                 vr_tot_realizado_out := vr_tot_realizado_out + vr_realizado_cec_out;

               WHEN '001' THEN
                 vr_tot_projetado_in  := vr_tot_projetado_in  + vr_projetado_bb_in;
                 vr_tot_realizado_in  := vr_tot_realizado_in  + vr_realizado_bb_in;
                 vr_tot_projetado_out := vr_tot_projetado_out + vr_projetado_bb_out;
                 vr_tot_realizado_out := vr_tot_realizado_out + vr_realizado_bb_out;

               WHEN '756' THEN
                 vr_tot_projetado_in  := vr_tot_projetado_in  + vr_projetado_bco_in;
                 vr_tot_realizado_in  := vr_tot_realizado_in  + vr_realizado_bco_in;
                 vr_tot_projetado_out := vr_tot_projetado_out + vr_projetado_bco_out;
                 vr_tot_realizado_out := vr_tot_realizado_out + vr_realizado_bco_out;

               WHEN '748' THEN
                 vr_tot_projetado_in  := vr_tot_projetado_in  + vr_projetado_sic_in;
                 vr_tot_realizado_in  := vr_tot_realizado_in  + vr_realizado_sic_in;
                 vr_tot_projetado_out := vr_tot_projetado_out + vr_projetado_sic_out;
                 vr_tot_realizado_out := vr_tot_realizado_out + vr_realizado_sic_out;

            END CASE;

          END IF;

          -- Carrega no XML as diferencas em [R$] e [%]
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vlcheque'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vlcheque,vr_projetado_vlcheque),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vlcheque'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vlcheque,vr_projetado_vlcheque),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vltotdoc'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vltotdoc,vr_projetado_vltotdoc),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vltotdoc'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vltotdoc,vr_projetado_vltotdoc),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vltotted'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vltotted,vr_projetado_vltotted),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vltotted'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vltotted,vr_projetado_vltotted),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vltottit'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vltottit,vr_projetado_vltottit),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vltottit'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vltottit,vr_projetado_vltottit),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vldevolu'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vldevolu,vr_projetado_vldevolu),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vldevolu'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vldevolu,vr_projetado_vldevolu),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vltrfitc'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vltrfitc,vr_projetado_vltrfitc),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vltrfitc'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vltrfitc,vr_projetado_vltrfitc),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vldepitc'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vldepitc,vr_projetado_vldepitc),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vldepitc'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vldepitc,vr_projetado_vldepitc),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vlsatait'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vlsatait,vr_projetado_vlsatait),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vlsatait'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vlsatait,vr_projetado_vlsatait),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vlnumera'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vlnumera,vr_projetado_vlnumera),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vlnumera'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vlnumera,vr_projetado_vlnumera),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vlmvtitg'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vlmvtitg,vr_projetado_vlmvtitg),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vlmvtitg'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vlmvtitg,vr_projetado_vlmvtitg),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vlttinss'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vlttinss,vr_projetado_vlttinss),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vlttinss'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vlttinss,vr_projetado_vlttinss),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vlcarcre'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vlcarcre,vr_projetado_vlcarcre),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vlcarcre'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vlcarcre,vr_projetado_vlcarcre),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vlconven'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vlconven,vr_projetado_vlconven),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vlconven'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vlconven,vr_projetado_vlconven),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_vlcardeb'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_vlcardeb,vr_projetado_vlcardeb),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_vlcardeb'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_vlcardeb,vr_projetado_vlcardeb),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_cec_in'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_cec_in,vr_projetado_cec_in),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_cec_in'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_cec_in,vr_projetado_cec_in),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_cec_out'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_cec_out,vr_projetado_cec_out),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_cec_out'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_cec_out,vr_projetado_cec_out),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          -- Calcula a diferenca dos valores
          vr_projetado := FLXF0001.fn_calcula_difere_valor(vr_projetado_cec_in,vr_projetado_cec_out);
          vr_realizado := FLXF0001.fn_calcula_difere_valor(vr_realizado_cec_in,vr_realizado_cec_out);
          
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_cec_projetado'
                                ,pr_tag_cont => TO_CHAR(vr_projetado,'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_cec_realizado'
                                ,pr_tag_cont => TO_CHAR(vr_realizado,'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_cec_soma'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_cec_soma'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_bb_in'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_bb_in,vr_projetado_bb_in),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_bb_in'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_bb_in,vr_projetado_bb_in),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_bb_out'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_bb_out,vr_projetado_bb_out),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_bb_out'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_bb_out,vr_projetado_bb_out),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          -- Calcula a diferenca dos valores
          vr_projetado := FLXF0001.fn_calcula_difere_valor(vr_projetado_bb_in,vr_projetado_bb_out);
          vr_realizado := FLXF0001.fn_calcula_difere_valor(vr_realizado_bb_in,vr_realizado_bb_out);
          
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_bb_projetado'
                                ,pr_tag_cont => TO_CHAR(vr_projetado,'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_bb_realizado'
                                ,pr_tag_cont => TO_CHAR(vr_realizado,'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_bb_soma'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_bb_soma'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_bco_in'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_bco_in,vr_projetado_bco_in),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_bco_in'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_bco_in,vr_projetado_bco_in),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_bco_out'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_bco_out,vr_projetado_bco_out),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_bco_out'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_bco_out,vr_projetado_bco_out),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          -- Calcula a diferenca dos valores
          vr_projetado := FLXF0001.fn_calcula_difere_valor(vr_projetado_bco_in,vr_projetado_bco_out);
          vr_realizado := FLXF0001.fn_calcula_difere_valor(vr_realizado_bco_in,vr_realizado_bco_out);
          
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_bco_projetado'
                                ,pr_tag_cont => TO_CHAR(vr_projetado,'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_bco_realizado'
                                ,pr_tag_cont => TO_CHAR(vr_realizado,'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_bco_soma'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_bco_soma'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_sic_in'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_sic_in,vr_projetado_sic_in),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_sic_in'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_sic_in,vr_projetado_sic_in),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_sic_out'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado_sic_out,vr_projetado_sic_out),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_sic_out'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado_sic_out,vr_projetado_sic_out),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          -- Calcula a diferenca dos valores
          vr_projetado := FLXF0001.fn_calcula_difere_valor(vr_projetado_sic_in,vr_projetado_sic_out);
          vr_realizado := FLXF0001.fn_calcula_difere_valor(vr_realizado_sic_in,vr_realizado_sic_out);
          
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_sic_projetado'
                                ,pr_tag_cont => TO_CHAR(vr_projetado,'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_sic_realizado'
                                ,pr_tag_cont => TO_CHAR(vr_realizado,'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_rs_sic_soma'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'tpdmovto'
                                ,pr_posicao  => vr_contador
                                ,pr_tag_nova => 'dif_pc_sic_soma'
                                ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                                ,pr_des_erro => vr_dscritic);

          -- Reinicializa as variaveis
          vr_projetado_vlcheque := 0;   vr_projetado_vltotdoc := 0;   vr_projetado_vldevolu := 0;
          vr_projetado_vltrfitc := 0;   vr_projetado_vldepitc := 0;   vr_projetado_vlsatait := 0;
          vr_projetado_vlnumera := 0;   vr_projetado_cec_soma := 0;   vr_projetado_vlmvtitg := 0;
          vr_projetado_bb_soma  := 0;   vr_projetado_vlcardeb := 0;   vr_projetado_bco_soma := 0;
          vr_projetado_sic_soma := 0;   vr_projetado_vlcarcre := 0;   vr_projetado_vltotted := 0;
          vr_projetado_vlconven := 0;   vr_projetado_vltottit := 0;   vr_projetado_vlttinss := 0;
          vr_projetado_cec_in   := 0;   vr_projetado_cec_out  := 0;   vr_projetado_bb_in    := 0;
          vr_projetado_bb_out   := 0;   vr_projetado_bco_in   := 0;   vr_projetado_bco_out  := 0;
          vr_projetado_sic_in   := 0;   vr_projetado_sic_out  := 0;

          vr_realizado_vlcheque := 0;   vr_realizado_vltotdoc := 0;   vr_realizado_vldevolu := 0;
          vr_realizado_vltrfitc := 0;   vr_realizado_vldepitc := 0;   vr_realizado_vlsatait := 0;
          vr_realizado_vlnumera := 0;   vr_realizado_cec_soma := 0;   vr_realizado_vlmvtitg := 0;
          vr_realizado_bb_soma  := 0;   vr_realizado_vlcardeb := 0;   vr_realizado_bco_soma := 0;
          vr_realizado_sic_soma := 0;   vr_realizado_vlcarcre := 0;   vr_realizado_vltotted := 0;
          vr_realizado_vlconven := 0;   vr_realizado_vltottit := 0;   vr_realizado_vlttinss := 0;
          vr_realizado_cec_in   := 0;   vr_realizado_cec_out  := 0;   vr_realizado_bb_in    := 0;
          vr_realizado_bb_out   := 0;   vr_realizado_bco_in   := 0;   vr_realizado_bco_out  := 0;
          vr_realizado_sic_in   := 0;   vr_realizado_sic_out  := 0;

        END IF; --  SUBSTR(vr_index,-1) = '4'

        vr_contador := vr_contador + 1;
        vr_index    := vr_tab_crapffm.NEXT(vr_index);
    END LOOP;

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'total'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'nmrescop'
                          ,pr_tag_cont => (CASE WHEN pr_cdcooper = 0 THEN 'TODAS' ELSE CYBE0002.fn_nom_cooperativa(pr_cdcooper) END)
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_projetado'
                          ,pr_tag_cont => TO_CHAR(vr_tot_projetado,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_realizado'
                          ,pr_tag_cont => TO_CHAR(vr_tot_realizado,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_rs'
                          ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_tot_realizado,vr_tot_projetado),'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_pc'
                          ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_tot_realizado,vr_tot_projetado),'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_vlsldcta'
                          ,pr_tag_cont => TO_CHAR(vr_vlsldcta,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_projetado_in'
                          ,pr_tag_cont => TO_CHAR(vr_tot_projetado_in,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_realizado_in'
                          ,pr_tag_cont => TO_CHAR(vr_tot_realizado_in,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_projetado_out'
                          ,pr_tag_cont => TO_CHAR(vr_tot_projetado_out,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_realizado_out'
                          ,pr_tag_cont => TO_CHAR(vr_tot_realizado_out,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_rs_in'
                          ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_tot_realizado_in,vr_tot_projetado_in),'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_pc_in'
                          ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_tot_realizado_in,vr_tot_projetado_in),'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_rs_out'
                          ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_tot_realizado_out,vr_tot_projetado_out),'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_pc_out'
                          ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_tot_realizado_out,vr_tot_projetado_out),'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    -- Calcula a diferenca dos valores
    vr_projetado := FLXF0001.fn_calcula_difere_valor(vr_tot_projetado_in,vr_tot_projetado_out);
    vr_realizado := FLXF0001.fn_calcula_difere_valor(vr_tot_realizado_in,vr_tot_realizado_out);
          
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_saldo_projetado'
                          ,pr_tag_cont => TO_CHAR(vr_projetado + vr_vlsldcta,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_saldo_realizado'
                          ,pr_tag_cont => TO_CHAR(vr_realizado + vr_vlsldcta,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);
          
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_projetado'
                          ,pr_tag_cont => TO_CHAR(vr_projetado,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_realizado'
                          ,pr_tag_cont => TO_CHAR(vr_realizado,'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_rs_soma'
                          ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_valor(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'total'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tot_dif_pc_soma'
                          ,pr_tag_cont => TO_CHAR(FLXF0001.fn_calcula_difere_percent(vr_realizado,vr_projetado),'FM999G999G999G990D00')
                          ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela FLUXOS: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_consulta_fluxo_caixa;

  PROCEDURE pc_consulta_movimentacao(pr_dtrefere  IN VARCHAR2 --> Data dereferencia
                                    ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_consulta_movimentacao
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar as movimentacoes.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os movimentos
      CURSOR cr_movimento(pr_dtmvtolt IN crapffc.dtmvtolt%TYPE) IS
        SELECT TO_CHAR(cop.cdcooper,'FM00')|| '-' || cop.nmrescop nmrescop
              ,DECODE(ffc.vlresgat+ffc.vlaplica,0,'-'
                                                 ,(SELECT ope.nmoperad 
                                                     FROM crapope ope 
                                                    WHERE ope.cdcooper = ffc.cdcooper
                                                      AND ope.cdoperad = ffc.cdoperad)) nmoperad
              ,TO_CHAR(DECODE(ffc.vlresgat,0,ffc.vlaplica,ffc.vlresgat*-1),'FM999G999G999G990D00') vlmovime
              ,DECODE(ffc.vlresgat,0,'Aplicação','Resgate') dsmovime
          FROM crapffc ffc 
              ,crapcop cop
         WHERE cop.cdcooper <> 3
           AND cop.cdcooper = ffc.cdcooper
           AND ffc.dtmvtolt = pr_dtmvtolt
      ORDER BY cop.cdcooper;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdoperad VARCHAR2(100);
      vr_cdcooper NUMBER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_contador INTEGER := 0;
      vr_dtrefere DATE;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_consulta_movimentacao'
                                ,pr_action => NULL);

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      vr_dtrefere := TO_DATE(pr_dtrefere,'DD/MM/RRRR');

      -- Se NAO for dia util
      IF vr_dtrefere <> GENE0005.fn_valida_dia_util
                                (pr_cdcooper => vr_cdcooper
                                ,pr_dtmvtolt => vr_dtrefere) THEN
        vr_cdcritic := 13;
        RAISE vr_exc_saida;
      END IF;

      -- Se data de referencia for maior que data atual
      IF vr_dtrefere > rw_crapdat.dtmvtolt THEN
        vr_cdcritic := 13;
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de movimentos
      FOR rw_movimento IN cr_movimento(pr_dtmvtolt => vr_dtrefere) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'mvto'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'mvto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmrescop'
                              ,pr_tag_cont => rw_movimento.nmrescop
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'mvto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmoperad'
                              ,pr_tag_cont => rw_movimento.nmoperad
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'mvto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlmovime'
                              ,pr_tag_cont => rw_movimento.vlmovime
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'mvto'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dsmovime'
                              ,pr_tag_cont => (CASE WHEN rw_movimento.vlmovime = '0,00' THEN '-' ELSE rw_movimento.dsmovime END)
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela FLUXOS: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_consulta_movimentacao;

  PROCEDURE pc_consulta_liquidacao(pr_cdcooper  IN INTEGER --> Cooperativa
                                  ,pr_dtrefere  IN VARCHAR2 --> Data dereferencia
                                  ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_consulta_liquidacao
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar as liquidacoes das previsoes financeiras.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Busca lancamentos
      CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
        SELECT cdbanchq
              ,dsidenti
              ,vllanmto
          FROM craplcm
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdhistor IN (47,191,338,573);

      -- Busca cheques acolhidos para depositos
      CURSOR cr_crapchd(pr_cdcooper IN crapchd.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapchd.dtmvtolt%TYPE) IS
        SELECT cdcmpchq
              ,vlcheque
          FROM crapchd
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND insitchq IN (0,2)
           AND inchqcop = 0;

      -- Busca tranferencia de valores
      CURSOR cr_craptvl(pr_cdcooper IN craptvl.cdcooper%TYPE
                       ,pr_dtmvtolt IN craptvl.dtmvtolt%TYPE) IS
        SELECT cdcooper
              ,cdagenci
              ,cdbcoenv
              ,vldocrcb
          FROM craptvl
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND tpdoctrf <> 3; -- DOC

      -- Busca titulos acolhidos
      CURSOR cr_craptit(pr_cdcooper IN craptit.cdcooper%TYPE
                       ,pr_dtdpagto IN craptit.dtdpagto%TYPE) IS
        SELECT cdcooper
              ,cdagenci
              ,cdbcoenv
              ,vldpagto
          FROM craptit
         WHERE cdcooper = pr_cdcooper
           AND dtdpagto = pr_dtdpagto
           AND tpdocmto = 20
           AND intitcop = 0
           AND insittit IN (2,4);

      -- Busca agencia
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE) IS
        SELECT cdcomchq
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND flgdsede = 1;
      rw_crapage cr_crapage%ROWTYPE;

      -- Busca informacoes da movimentacao
      CURSOR cr_crapffm(pr_cdcooper IN crapffm.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapffm.dtmvtolt%TYPE) IS
        SELECT vltotdoc + vltottit vldoctit
          FROM crapffm 
         WHERE cdcooper = pr_cdcooper
           AND cdbccxlt = 85
           AND dtmvtolt = pr_dtmvtolt
           AND tpdmovto = 1; -- Entrada
      rw_crapffm cr_crapffm%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_dtrefere DATE;
      vr_dtliquid DATE;
      vr_dtliqui2 DATE;
      vr_vlcbdonr NUMBER;
      vr_vlcbdosr NUMBER;
      vr_vlpreliq NUMBER;
      vr_vlcmpnot NUMBER;
      vr_vlcmpdiu NUMBER;
      vr_valorvlb NUMBER;
      vr_valorchq NUMBER;
      vr_vlcobbil NUMBER := 0;
      vr_vlcobmlt NUMBER := 0;
      vr_vldoctit NUMBER := 0;
      vr_vlchqnot NUMBER := 0;
      vr_vlchqdia NUMBER := 0;
      vr_dstextab craptab.dstextab%TYPE;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_consulta_liquidacao'
                                ,pr_action => NULL);

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

      -- Busca operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;

      -- Se NAO fizer parte dos departamentos abaixo
      IF rw_crapope.cddepart <> 20/*TI*/                   AND
         rw_crapope.cddepart <> 18/*SUPORTE*/              AND
         rw_crapope.cddepart <> 08/*COORD.ADM/FINANCEIRO*/ AND
         rw_crapope.cddepart <> 09/*COORD.PRODUTOS*/       AND
         rw_crapope.cddepart <> 04/*COMPE*/                AND
         rw_crapope.cddepart <> 11/*FINANCEIRO*/           THEN
        vr_cdcritic := 36;
        RAISE vr_exc_saida;
      END IF;

      vr_dtrefere := TO_DATE(pr_dtrefere,'DD/MM/RRRR');

      -- Se NAO for dia util
      IF vr_dtrefere <> GENE0005.fn_valida_dia_util
                                (pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtolt => vr_dtrefere) THEN
        vr_cdcritic := 13;
        RAISE vr_exc_saida;
      END IF;

      vr_dtliquid := GENE0005.fn_valida_dia_util
                             (pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => vr_dtrefere - 1
                             ,pr_tipo     => 'A');
      vr_dtliqui2 := GENE0005.fn_valida_dia_util
                             (pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => vr_dtliquid - 1
                             ,pr_tipo     => 'A');

      -- Busca as informacoes da cooperativa
      FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP

        -- Buscaremos os parametros da CRAPTAB valores boleto
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'VALORESVLB'
                                                 ,pr_tpregist => 0);
        -- Se encontrar
        IF vr_dstextab IS NOT NULL THEN
          vr_valorvlb := GENE0002.fn_busca_entrada(1,vr_dstextab,';');
        ELSE
          vr_valorvlb := 5000; 
        END IF;

        -- Buscaremos os parâmetros da CRAPTAB valores cheques
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'MAIORESCHQ'
                                                 ,pr_tpregist => 1);
        -- Se encontrar
        IF vr_dstextab IS NOT NULL THEN
          vr_valorchq := SUBSTR(vr_dstextab,1,15);
        ELSE
          vr_valorchq := 300; 
        END IF;

        -- COMPE NOTURNA - DEVOLU
        FOR rw_craplcm IN cr_craplcm(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtmvtolt => vr_dtliquid) LOOP
          IF rw_craplcm.cdbanchq = 85  AND
             rw_craplcm.dsidenti = '1' THEN -- Noturna
             vr_vlchqnot := vr_vlchqnot + rw_craplcm.vllanmto;
          END IF;
        END LOOP;

        -- COMPE DIURNA - DEVOLU
        FOR rw_craplcm IN cr_craplcm(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtmvtolt => vr_dtrefere) LOOP
          IF rw_craplcm.cdbanchq = 85  AND
             rw_craplcm.dsidenti = '2' THEN -- Diurna
             vr_vlchqdia := vr_vlchqdia + rw_craplcm.vllanmto;
          END IF;
        END LOOP;

        -- Busca agencia
        OPEN cr_crapage(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH cr_crapage INTO rw_crapage;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_crapage%FOUND;
        -- Fecha cursor
        CLOSE cr_crapage;
        -- Se encontrou
        IF vr_blnfound THEN

          -- COMPE 16 (D - 1)
          FOR rw_crapchd IN cr_crapchd(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_dtmvtolt => vr_dtliquid) LOOP
            -- Se for DIFERENTE => NACIONAL (DESCONSIDERA)
            IF rw_crapage.cdcomchq <> rw_crapchd.cdcmpchq THEN
              CONTINUE;
            END IF;
              
            IF rw_crapchd.vlcheque >= vr_valorchq THEN
              vr_vlchqnot := vr_vlchqnot + rw_crapchd.vlcheque;
            ELSE
              vr_vlchqdia := vr_vlchqdia + rw_crapchd.vlcheque;
            END IF;
          END LOOP;

          -- COMPE NACIONAL (D - 2)
          FOR rw_crapchd IN cr_crapchd(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_dtmvtolt => vr_dtliqui2) LOOP
            -- Se for IGUAL => COMPE16 (DESCONSIDERA)
            IF rw_crapage.cdcomchq = rw_crapchd.cdcmpchq THEN
              CONTINUE;
            END IF;
              
            IF rw_crapchd.vlcheque >= vr_valorchq THEN
              vr_vlchqnot := vr_vlchqnot + rw_crapchd.vlcheque;
            ELSE
              vr_vlchqdia := vr_vlchqdia + rw_crapchd.vlcheque;
            END IF;
          END LOOP;

        END IF;

        -- Busca tranferencia de valores
        FOR rw_craptvl IN cr_craptvl(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtmvtolt => vr_dtliquid) LOOP
          IF rw_craptvl.vldocrcb >= vr_valorvlb THEN
            vr_vlcobbil := vr_vlcobbil + rw_craptvl.vldocrcb;
          ELSE
            vr_vlcobmlt := vr_vlcobmlt + rw_craptvl.vldocrcb;
          END IF;
        END LOOP;

        -- Busca titulos acolhidos
        FOR rw_craptit IN cr_craptit(pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtdpagto => vr_dtliquid) LOOP
          IF rw_craptit.vldpagto >= vr_valorvlb THEN
            vr_vlcobbil := vr_vlcobbil + rw_craptit.vldpagto;
          ELSE
            vr_vlcobmlt := vr_vlcobmlt + rw_craptit.vldpagto;
          END IF;
        END LOOP;

        -- Busca informacoes da movimentacao
        OPEN cr_crapffm(pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_dtmvtolt => vr_dtliquid);
        FETCH cr_crapffm INTO rw_crapffm;
        CLOSE cr_crapffm;
        -- Soma dos DOC e Titulos
        vr_vldoctit := vr_vldoctit + NVL(rw_crapffm.vldoctit,0);

      END LOOP; -- cr_crapcop

      vr_vlcbdonr := vr_vlcobbil + vr_vlcobmlt;
      vr_vlcbdosr := vr_vldoctit;
      vr_vlpreliq := vr_vldoctit - vr_vlcbdonr;
      vr_vlcmpnot := vr_vlchqnot;
      vr_vlcmpdiu := vr_vlchqdia;

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
                            ,pr_tag_nova => 'vlcbdonr'
                            ,pr_tag_cont => TO_CHAR(vr_vlcbdonr,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlcbdosr'
                            ,pr_tag_cont => TO_CHAR(vr_vlcbdosr,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlpreliq'
                            ,pr_tag_cont => TO_CHAR(vr_vlpreliq,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlcmpnot'
                            ,pr_tag_cont => TO_CHAR(vr_vlcmpnot,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlcmpdiu'
                            ,pr_tag_cont => TO_CHAR(vr_vlcmpdiu,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela FLUXOS: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_consulta_liquidacao;

  PROCEDURE pc_consulta_fluxo_dia(pr_cdcooper  IN INTEGER --> Cooperativa
                                 ,pr_dtrefere  IN VARCHAR2 --> Data dereferencia
                                 ,pr_xmllog    IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_consulta_fluxo_dia
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar as movimentacoes.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os fluxos consolidados
      CURSOR cr_fluxo(pr_cdcooper IN tbfin_fluxo_caixa_consolid.cdcooper%TYPE
                     ,pr_dtmvtolt IN tbfin_fluxo_caixa_consolid.dtmvtolt%TYPE) IS
        SELECT cdbccxlt
              ,vlentradas
              ,vlsaidas
              ,vloutros
          FROM tbfin_fluxo_caixa_consolid
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt;

      -- Selecionar informacoes do fluxo consolidado
      CURSOR cr_crapffc(pr_cdcooper IN crapffc.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapffc.dtmvtolt%TYPE) IS
        SELECT cdcooper
              ,vlentrad
              ,vlsaidas
              ,vloutros
              ,vlsldcta
              ,vlresgat
              ,vlaplica
              ,cdoperad
              ,TO_CHAR(TO_DATE(hrtransa,'SSSSS'),'HH24:MI:SS') hrtransa
          FROM crapffc
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt;
      rw_crapffc cr_crapffc%ROWTYPE;

      -- Tabela temporaria para os valores
      TYPE typ_reg_fluxo IS RECORD(vlentrad NUMBER
                                  ,vlsaidas NUMBER
                                  ,vloutros NUMBER
                                  ,vlresult NUMBER);
      TYPE typ_tab_fluxo IS TABLE OF typ_reg_fluxo INDEX BY VARCHAR2(4);
      -- Vetor para armazenar os valores
      vr_tab_fluxo typ_tab_fluxo;
      -- Vetor para os bancos
      vr_dsbancos GENE0002.typ_split;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdoperad VARCHAR2(100);
      vr_cdcooper NUMBER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_index    VARCHAR2(4) := '';
      vr_dtrefere DATE;
      vr_contador INTEGER := 0;
      vr_nmoperad VARCHAR2(100) := ' ';
      vr_hrtransa VARCHAR2(10) := ' ';
      vr_vlresult NUMBER := 0;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_consulta_fluxo_dia'
                                ,pr_action => NULL);

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      vr_dtrefere := TO_DATE(pr_dtrefere,'DD/MM/RRRR');

      -- Se NAO for dia util
      IF vr_dtrefere <> GENE0005.fn_valida_dia_util
                                (pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtolt => vr_dtrefere) THEN
        vr_cdcritic := 13;
        RAISE vr_exc_saida;
      END IF;

      -- Se data de referencia for maior que data atual
      IF vr_dtrefere > rw_crapdat.dtmvtolt THEN
        vr_cdcritic := 13;
        RAISE vr_exc_saida;
      END IF;

      -- Se data de referencia for a mesma da cooperativa conectada
      IF vr_dtrefere = rw_crapdat.dtmvtolt THEN
        -- Gravar movimento do fluxo financeiro
        FLXF0001.pc_grava_fluxo_financeiro
                (pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                ,pr_cdagenci => vr_cdagenci          -- Codigo da agencia
                ,pr_nrdcaixa => 0                    -- Numero da caixa
                ,pr_cdoperad => vr_cdoperad          -- Codigo do operador
                ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento
                ,pr_cdprogra => 'FLUXOD'             -- Nome da tela
                ,pr_dtmvtoan => rw_crapdat.dtmvtoan  -- Data de movimento anterior
                ,pr_dtmvtopr => rw_crapdat.dtmvtopr  -- Data do movimento posterior
                ,pr_tab_erro => vr_tab_erro          -- Tabela contendo os erros
                ,pr_dscritic => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic <> 'OK' OR vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- 85-Cecred / 1-Banco do Brasil / 756-Bancoob / 748-Sicredi
      vr_dsbancos := GENE0002.fn_quebra_string(pr_string  => '85,1,756,748'
                                              ,pr_delimit => ',');
      -- Inicializa as variaveis
      FOR vr_iba IN 1..vr_dsbancos.COUNT() LOOP
        vr_index := LPAD(vr_dsbancos(vr_iba),3,'0');
        vr_tab_fluxo(vr_index).vlentrad := 0;
        vr_tab_fluxo(vr_index).vlsaidas := 0;
        vr_tab_fluxo(vr_index).vloutros := 0;
        vr_tab_fluxo(vr_index).vlresult := 0;
      END LOOP;

      -- Selecionar os fluxos consolidados
      FOR rw_fluxo IN cr_fluxo(pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => vr_dtrefere) LOOP
        vr_index := LPAD(rw_fluxo.cdbccxlt,3,'0');
        vr_tab_fluxo(vr_index).vlentrad := rw_fluxo.vlentradas;
        vr_tab_fluxo(vr_index).vlsaidas := rw_fluxo.vlsaidas;
        vr_tab_fluxo(vr_index).vloutros := rw_fluxo.vloutros;
        vr_tab_fluxo(vr_index).vlresult := rw_fluxo.vlentradas - rw_fluxo.vlsaidas + rw_fluxo.vloutros;
      END LOOP;

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
                            ,pr_tag_nova => 'fluxos'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de movimentos
      -- Montar XML
      vr_index := vr_tab_fluxo.FIRST;
      WHILE vr_index IS NOT NULL LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'fluxos'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'fluxo'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'fluxo'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'codigo'
                              ,pr_tag_cont => vr_index -- Codigo, ex: 085 --> 85-Cecred
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'fluxo'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlentrad'
                              ,pr_tag_cont => TO_CHAR(vr_tab_fluxo(vr_index).vlentrad,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'fluxo'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlsaidas'
                              ,pr_tag_cont => TO_CHAR(vr_tab_fluxo(vr_index).vlsaidas,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'fluxo'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vloutros'
                              ,pr_tag_cont => TO_CHAR(vr_tab_fluxo(vr_index).vloutros,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'fluxo'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'vlresult'
                              ,pr_tag_cont => TO_CHAR(vr_tab_fluxo(vr_index).vlresult,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
        vr_index    := vr_tab_fluxo.NEXT(vr_index);
      END LOOP;
      
      -- Selecionar informacoes do fluxo consolidado
      OPEN cr_crapffc(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => vr_dtrefere);
      FETCH cr_crapffc INTO rw_crapffc;
      CLOSE cr_crapffc;
      
      IF NVL(rw_crapffc.vlresgat,0) + NVL(rw_crapffc.vlaplica,0) > 0 THEN
        -- Busca operador
        OPEN cr_crapope(pr_cdcooper => rw_crapffc.cdcooper
                       ,pr_cdoperad => rw_crapffc.cdoperad);
        FETCH cr_crapope INTO rw_crapope;
        CLOSE cr_crapope;
        vr_nmoperad := rw_crapope.cdoperad || '-' || rw_crapope.nmoperad;
        vr_hrtransa := rw_crapffc.hrtransa;
      END IF;

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inform'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tot_vlentrad'
                            ,pr_tag_cont => TO_CHAR(NVL(rw_crapffc.vlentrad,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tot_vlsaidas'
                            ,pr_tag_cont => TO_CHAR(NVL(rw_crapffc.vlsaidas,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tot_vloutros'
                            ,pr_tag_cont => TO_CHAR(NVL(rw_crapffc.vloutros,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      -- Resultado centralizacao
      vr_vlresult := NVL(rw_crapffc.vlentrad,0) - NVL(rw_crapffc.vlsaidas,0) + NVL(rw_crapffc.vloutros,0);
      
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tot_vlresult'
                            ,pr_tag_cont => TO_CHAR(vr_vlresult,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tot_vlsldcta'
                            ,pr_tag_cont => TO_CHAR(NVL(rw_crapffc.vlsldcta,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tot_vlsldfim'
                            ,pr_tag_cont => TO_CHAR(vr_vlresult + NVL(rw_crapffc.vlsldcta,0) + NVL(rw_crapffc.vlresgat,0) - NVL(rw_crapffc.vlaplica,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tot_vlresgat'
                            ,pr_tag_cont => TO_CHAR(NVL(rw_crapffc.vlresgat,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'tot_vlaplica'
                            ,pr_tag_cont => TO_CHAR(NVL(rw_crapffc.vlaplica,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmoperad'
                            ,pr_tag_cont => vr_nmoperad
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'hrtransa'
                            ,pr_tag_cont => vr_hrtransa
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'inform'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'pode_alterar'
                            ,pr_tag_cont => (CASE WHEN vr_dtrefere = rw_crapdat.dtmvtolt THEN 1 ELSE 0 END)
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela FLUXOS: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_consulta_fluxo_dia;

  PROCEDURE pc_grava_dados(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                          ,pr_dtrefere IN VARCHAR2 --> Data dereferencia
                          ,pr_vldiv085 IN NUMBER --> Diversos 085
                          ,pr_vldiv001 IN NUMBER --> Diversos 001
                          ,pr_vldiv756 IN NUMBER --> Diversos 756
                          ,pr_vldiv748 IN NUMBER --> Diversos 748
                          ,pr_vldivtot IN NUMBER --> Diversos total
                          ,pr_vlresgat IN NUMBER --> Resgate
                          ,pr_vlaplica IN NUMBER --> Aplicacao
                          ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os valores.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Vetor para os bancos
      vr_dsbancos GENE0002.typ_split;

      -- Variaveis
      vr_dtrefere DATE;
      vr_cdbccxlt INTEGER;
      vr_tpdcampo INTEGER;
      vr_vldcampo NUMBER;

    BEGIN
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

      -- Se o horario NAO estiver dentro do permitido para alteracao
      IF FLXF0001.fn_valida_horario(pr_cdcooper => pr_cdcooper) = 'N' THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => 676);
        RAISE vr_exc_saida;
      END IF;

      vr_dtrefere := TO_DATE(pr_dtrefere,'DD/MM/RRRR');

      -- 85-Cecred / 1-Banco do Brasil / 756-Bancoob / 748-Sicredi / TDIV-Diversos / TRSG-Resgate / TAPL-Aplicacao
      vr_dsbancos := GENE0002.fn_quebra_string(pr_string  => '85,1,756,748,TDIV,TRSG,TAPL'
                                              ,pr_delimit => ',');

      -- Percorre os bancos
      FOR vr_idx IN 1..vr_dsbancos.COUNT() LOOP
        
        CASE vr_dsbancos(vr_idx)

           WHEN '85' THEN
             vr_cdbccxlt := 85;
             vr_tpdcampo := 6; -- Outros
             vr_vldcampo := pr_vldiv085;

           WHEN '1' THEN
             vr_cdbccxlt := 1;
             vr_tpdcampo := 6; -- Outros
             vr_vldcampo := pr_vldiv001;

           WHEN '756' THEN
             vr_cdbccxlt := 756;
             vr_tpdcampo := 6; -- Outros
             vr_vldcampo := pr_vldiv756;

           WHEN '748' THEN
             vr_cdbccxlt := 748;
             vr_tpdcampo := 6; -- Outros
             vr_vldcampo := pr_vldiv748;

           WHEN 'TDIV' THEN
             vr_cdbccxlt := 0;
             vr_tpdcampo := 6; -- Outros
             vr_vldcampo := pr_vldivtot;

           WHEN 'TRSG' THEN
             vr_cdbccxlt := 0;
             vr_tpdcampo := 4; -- Resgate
             vr_vldcampo := pr_vlresgat;

           WHEN 'TAPL' THEN
             vr_cdbccxlt := 0;
             vr_tpdcampo := 5; -- Aplicacao
             vr_vldcampo := pr_vlaplica;

        END CASE;
        
        -- Grava as informacoes do fluxo financeiro consolidado
        FLXF0001.pc_grava_consolidado_singular
                (pr_cdcooper => pr_cdcooper
                ,pr_cdbccxlt => vr_cdbccxlt
                ,pr_dtmvtolt => vr_dtrefere
                ,pr_tpdcampo => vr_tpdcampo
                ,pr_vldcampo => vr_vldcampo
                ,pr_cdoperad => vr_cdoperad
                ,pr_dscritic => vr_dscritic);

        -- Se retornou erro
        IF vr_dscritic <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;

      END LOOP; -- vr_dsbancos

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela FLUXOS: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_dados;

END TELA_FLUXOS;
/
