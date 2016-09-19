CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS365(pr_cdcooper  IN  crapcop.cdcooper%TYPE   --> Cooperativa
                                      ,pr_flgresta  IN  PLS_INTEGER             --> Controle de restart
                                      ,pr_stprogra  OUT PLS_INTEGER             --> Sa�da de termino da execu��o
                                      ,pr_infimsol  OUT PLS_INTEGER             --> Sa�da de termino da solicita��o
                                      ,pr_cdcritic  OUT NUMBER                  --> C�digo cr�tica
                                      ,pr_dscritic  OUT VARCHAR2) IS            --> Descri��o cr�tica
BEGIN
  /* .............................................................................

   Programa: crps365   Antigo: Fontes/crps365.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/2003.                      Ultima atualizacao: 21/01/2014

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 87.
               Emite listagens de saldos de cheques descontados para conferen-
               cia fisica (311) e relatorio aberto de cheques descontados para
               auditoria (312).

   Alteracoes: 09/03/2004 - Desprezar devolucoes(Mirtes).

               26/10/2004 - Incluir apropriacao (Ze Eduardo).

               03/12/2004 - Incluido campo valor Liq.(Mirtes)

               05/08/2005 - Ajuste na selecao dos registros do crapljd
                            (Edson).

               12/08/2005 - Alterado para exibir tambem no relatorio 311
                            os campos Limite e Disponivel (Diego).

               01/08/2005 - Alterado p/ mostrar total geral associados que
                            descontaram cheques; qtd borderos emitidos p/
                            desconto cheques; e geral socios c/limite p/
                            desconto de cheque - crrl311 (Diego).

               16/09/2005 - Acrescentados totais e concertado layout (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               11/10/2005 - Efetuado acerto cabecalho,colunas impressao(Mirtes)

               18/10/2005 - Acrescentado no relatorio 311, listagem da qtd de
                            limites que estao e nao esta sendo utilizados
                            por PAC (Diego).

               08/12/2005 - Alterados relatorios (311 e 312) para listar
                            ordenados por PAC (Diego).

               15/02/2005 - Acrescentada listagem por Pac, separando contas
                            Fisicas e Juridicas (311) (Diego).

               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               25/01/2007 - Modificado formato das variaveis do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).

               02/07/2007 - Efetuado acerto mascara valor disponivel(negativo)
                            (Mirtes)

               11/03/2009 - Aumentado formato do campo rel_nrdconta(Gabriel).

               11/07/2013 - Convers�o Progress >> PL/SQL (Oracle). Petter - Supero.

               28/11/2013 - Ajustes nas variaveis tratadas durante a iniprg (Marcos-Supero)

               21/01/2014 - Nao gerar o pdf do crrl312 (Gabriel).
  ............................................................................. */
  DECLARE
    -- PL Table para borderos
    TYPE typ_reg_borderos IS
      RECORD(nrborder crapcdb.nrborder%TYPE);

    -- Defini��o de tipo da PL Table
    TYPE typ_tab_borderbos IS TABLE OF typ_reg_borderos INDEX BY VARCHAR2(50);

    -- Defini��o de tipos para Array em PL Table
    TYPE arrayn IS TABLE OF NUMBER(10,2) INDEX BY PLS_INTEGER;
    TYPE arrayi IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;

    -- PL Table para coleta dados diversos
    TYPE typ_reg_work IS
      RECORD(cdagenci     crapass.cdagenci%TYPE
            ,qtd_naoutili arrayi
            ,vlr_naoutili arrayn
            ,qtd_utiliza  arrayi
            ,vlr_utiliza  arrayn);

    -- Defini��o de tipo da PL Table
    TYPE typ_tab_work IS TABLE OF typ_reg_work INDEX BY VARCHAR2(50);

    -- PL Table para tabela CRAPCDB
    TYPE typ_reg_crapcdb IS
      RECORD(nrdconta crapcdb.nrdconta%TYPE
            ,dtlibera crapcdb.dtlibera%TYPE
            ,cdbanchq crapcdb.cdbanchq%TYPE
            ,cdagechq crapcdb.cdagechq%TYPE
            ,nrctachq crapcdb.nrctachq%TYPE
            ,nrcheque crapcdb.nrcheque%TYPE
            ,nrborder crapcdb.nrborder%TYPE
            ,nrcpfcgc crapcdb.nrcpfcgc%TYPE
            ,dtlibbdc crapcdb.dtlibbdc%TYPE
            ,vlcheque crapcdb.vlcheque%TYPE
            ,vlliquid crapcdb.vlliquid%TYPE
            ,cdagenci crapass.cdagenci%TYPE
            ,cdcmpchq crapcdb.cdcmpchq%TYPE
            ,nmprimtl crapass.nmprimtl%TYPE);

    -- Defini��o de tipo da PL Table
    TYPE typ_tab_crapcdb IS TABLE OF typ_reg_crapcdb INDEX BY VARCHAR2(300);

    -- PL Table da tabela CRAPAGE
    TYPE typ_reg_crapage IS
      RECORD(nmresage crapage.nmresage%TYPE);

    -- Defini��o de tipo da PL Table
    TYPE typ_tab_crapage IS TABLE OF typ_reg_crapage INDEX BY VARCHAR2(5);

    -- PL Table da tabela CRAPLJD
    TYPE typ_reg_crapljd IS
      RECORD(vldjuros crapljd.vldjuros%TYPE
            ,controle VARCHAR2(400));

    -- Defini��o de tipo da PL Table
    TYPE typ_tab_crapljd IS TABLE OF typ_reg_crapljd INDEX BY VARCHAR2(300);

    -- PL Table da tabela CRAPCEC
    TYPE typ_reg_crapcec IS
      RECORD(nmcheque crapcec.nmcheque%TYPE
            ,nrcpfcgc crapcec.nrcpfcgc%TYPE);

    -- Defini��o de tipo da PL Table
    TYPE typ_tab_crapcec IS TABLE OF typ_reg_crapcec INDEX BY VARCHAR2(50);

    -- PL Table da tabela CRAPCEC
    TYPE typ_reg_craplim IS
      RECORD(nrdconta craplim.nrdconta%TYPE
            ,vllimite craplim.vllimite%TYPE);

    -- Defini��o de tipo da PL Table
    TYPE typ_tab_craplim IS TABLE OF typ_reg_craplim INDEX BY VARCHAR2(50);

    -- Pl Table para a tabela CRAPASS
    TYPE typ_reg_crapass IS
      RECORD(cdagenci crapass.cdagenci%TYPE
            ,nmprimtl crapass.nmprimtl%TYPE);

    -- Defini��o de tipo para PL Table
    TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY VARCHAR2(15);

    vr_tab_borderos typ_tab_borderbos;                  --> Armazenar borderos
    vr_tab_work     typ_tab_work;                       --> Armazenar dados do processo
    vr_tab_crapcdb  typ_tab_crapcdb;                    --> Armazenar dados da tabela CRAPCDB
    vr_tab_crapcdbr typ_tab_crapcdb;                    --> Armazenar dados da tabela CRAPCDB
    vr_tab_crapage  typ_tab_crapage;                    --> Armazenar dados da tabela CRAPAGE
    vr_tab_crapljd  typ_tab_crapljd;                    --> Armazenar dados da tabela CRAPLJD
    vr_tab_crapcec  typ_tab_crapcec;                    --> Armazenar dados da tabela CRAPCEC
    vr_tab_craplim  typ_tab_craplim;                    --> Armazenar dados da tabela CRAPLIM
    vr_tab_crapass  typ_tab_crapass;                    --> Armazenar dados da tabela CRAPASS
    vr_cdprogra     VARCHAR2(100);                      --> Nome do programa
    vr_nom_dir      VARCHAR2(400);                      --> Diret�rio do relat�rio
    rw_crapdat      btch0001.cr_crapdat%ROWTYPE;        --> Cursor de informa��es sobre datas de execu��o
    vr_contador     PLS_INTEGER := 0;                   --> Contador de itera��es
    vr_rel_dtrefere DATE;                               --> Data de refer�ncia
    vr_rel_qtcheque PLS_INTEGER := 0;                   --> Quantidade de cheques
    vr_rel_vldescto NUMBER(20,2) := 0;                  --> Valor de desconto
    vr_rel_vldjuros NUMBER(20,2) := 0;                  --> Valor de juros
    vr_rel_vllimite NUMBER(20,2) := 0;                  --> Valor de limite
    vr_rel_disponiv NUMBER(20,2) := 0;                  --> Valor do dispon�vel
    vr_rel_vljurchq NUMBER(20,2) := 0;                  --> Valor de juros do cheque
    vr_rel_nmcheque VARCHAR2(400);                      --> Nome do cheque
    vr_rel_dscpfcgc VARCHAR2(400);                      --> CPF ou CNPJ
    vr_rel_nrdconta PLS_INTEGER := 0;                   --> N�merdo da conta
    vr_rel_nmprimtl VARCHAR2(100);                      --> Nome para impress�o
    vr_rel_deschequ VARCHAR2(19);                       --> Descri��o do cheque
    vr_rel_qtdsocio PLS_INTEGER := 0;                   --> Quantidade de associados
    vr_rel_descgral VARCHAR2(19);                       --> Descri��o de grau
    vr_rel_dsagenci VARCHAR2(20);                       --> Descri��o da ag�ncia
    vr_tot_qtcheque PLS_INTEGER := 0;                   --> Quantidade de cheques
    vr_tot_vldescto NUMBER(20,2) := 0;                  --> Valor do desconto
    vr_tot_vldjuros NUMBER(20,2) := 0;                  --> Valor dos juros
    vr_tot_qtdesche PLS_INTEGER := 0;                   --> Quantidade de cheques
    vr_tot_vllimite PLS_INTEGER := 0;                   --> Valor de limite
    vr_tot_qtdgeral PLS_INTEGER := 0;                   --> Quantidade geral
    vr_tot_vlrlimit NUMBER(20,2) := 0;                  --> Valor do limite
    vr_tot_vlrdispo NUMBER(20,2) := 0;                  --> Valor dispon�vel
    vr_tot_descgral PLS_INTEGER := 0;                   --> Total de grau
    vr_tot_geralchq PLS_INTEGER := 0;                   --> Total geral de cheques
    vr_tot_geralqtd PLS_INTEGER := 0;                   --> Quantidade geral
    vr_tot_valorlim NUMBER(20,2) := 0;                  --> Total do valor limite
    vr_tot_valordes NUMBER(20,2) := 0;                  --> Total dos valores
    vr_tot_valorjur NUMBER(20,2) := 0;                  --> Total do valor dos juros
    vr_tot_limitevl PLS_INTEGER := 0;                   --> Total do limite
    vr_tot_dispovlr NUMBER(20,2) := 0;                  --> Total dispon�vel
    vr_tot_utilizad PLS_INTEGER := 0;                   --> Total utilizado
    vr_tot_naoutili PLS_INTEGER := 0;                   --> Total n�o utilizado
    vr_tot_vlrutili NUMBER(20,2) := 0;                  --> Total do valor utilizado
    vr_tot_vlrnaout NUMBER(20,2) := 0;                  --> Total do valor n�o utilizado
    vr_exc_erro     EXCEPTION;                          --> Controle de erros
    vr_index        VARCHAR2(300);                      --> �ndice para PL Table
    vr_idxljd       VARCHAR2(400);                      --> �ndice para PL Table
    vr_xml_1        CLOB;                               --> Armazenar XML
    vr_xmlbuffer_1  VARCHAR2(32767);                    --> Buffer para criar XML
    vr_xml_2        CLOB;                               --> Armazenar XML
    vr_xmlbuffer_2  VARCHAR2(32767);                    --> Buffer para criar XML
    vr_stsnrcal     BOOLEAN;                            --> Controle da valida��o m�dulo 11
    vr_inpessoa     PLS_INTEGER := 0;                   --> Retorno do tipo de pessoa pelo m�dulo 11
    vr_qtd_utiliza  NUMBER(20,2) := 0;                  --> Sumarizador por ag�ncia de quantidade utilizada
    vr_vlr_utiliza  NUMBER(20,2) := 0;                  --> Sumarizador por ag�ncia de valor utilizado
    vr_qtd_nutiliza NUMBER(20,2) := 0;                  --> Sumarizador por ag�ncia de quantidade n�o utilizada
    vr_vlr_nutiliza NUMBER(20,2) := 0;                  --> Sumarizador por ag�ncia de valor n�o utilizado
    vr_controle     BOOLEAN := TRUE;                    --> Controle para gerar cabe�alho de registros no XML
    vr_tipopess     VARCHAR2(40);                       --> Controle para o tipo de pessoa
    vr_nrcopias     PLS_INTEGER := 1;                   --> N�mero de impress�es em c�pia
    vr_nmformul     VARCHAR2(40) := '';                 --> Nome do formul�rio
    vr_gerindex     VARCHAR2(300);                      --> Vari�vel para gerar �ndices para as PL Tables

    /* Busca dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Buscar dados da tabela de associados */
    CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE) IS --> Cooperativa
      SELECT cp.cdagenci
            ,cp.nmprimtl
            ,cp.nrdconta
      FROM crapass cp
      WHERE cp.cdcooper = pr_cdcooper;

    /* Busca dados dos cheques contidos no bordero de descontos de cheques */
    CURSOR cr_crapcdb(pr_cdcooper IN craptab.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento
                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE) IS --> Data pr�xima data de movimento
      SELECT cb.nrdconta
            ,cb.dtlibera
            ,cb.cdbanchq
            ,cb.cdagechq
            ,cb.nrctachq
            ,cb.nrcheque
            ,cb.nrborder
            ,cb.nrcpfcgc
            ,cb.dtlibbdc
            ,cb.vlcheque
            ,cb.vlliquid
            ,cb.cdcmpchq
      FROM crapcdb cb
      WHERE cb.cdcooper = pr_cdcooper
        AND cb.dtlibera > pr_dtmvtolt
        AND cb.dtlibbdc < pr_dtmvtopr
        AND (cb.dtdevolu IS NULL OR (cb.dtdevolu IS NOT NULL AND cb.dtdevolu > pr_dtmvtolt))
      ORDER BY cb.nrdconta
              ,cb.dtlibera
              ,cb.cdbanchq
              ,cb.cdagechq
              ,cb.nrctachq
              ,cb.nrcheque;

    /* Busca dados das ag�ncias */
    CURSOR cr_crapage(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cp.cdagenci
            ,cp.nmresage
      FROM crapage cp
      WHERE cp.cdcooper = pr_cdcooper;

    /* Busca dados de lan�amento de juros para descontos de cheques */
    CURSOR cr_crapljd(pr_cdcooper IN craptab.cdcooper%TYPE     --> Cooperativa
                     ,pr_dtrefere IN crapljd.dtrefere%TYPE) IS --> Data de refer�ncia
      SELECT cj.nrdconta
            ,cj.nrborder
            ,cj.cdcmpchq
            ,cj.cdbanchq
            ,cj.cdagechq
            ,cj.nrctachq
            ,cj.nrcheque
            ,cj.vldjuros
      FROM crapljd cj
      WHERE cj.cdcooper = pr_cdcooper
        AND cj.dtrefere > pr_dtrefere
      ORDER BY cj.nrdconta
              ,cj.nrborder
              ,cj.cdcmpchq
              ,cj.cdbanchq
              ,cj.cdagechq
              ,cj.nrctachq
              ,cj.nrcheque;

    /* Busca dados do cadastro de imitentes de cheques */
    CURSOR cr_crapcec(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT *
        FROM (SELECT cc.nmcheque,
                     cc.nrcpfcgc,
                     -- exibir posi��o na tabela conforme ordena��o
                     row_number() over(partition by cc.nrcpfcgc
                                       order by cc.nrcpfcgc, cc.progress_recid) reg_cec
                FROM crapcec cc
               WHERE cc.cdcooper = pr_cdcooper) T
       WHERE T.reg_cec = 1; --Simular find-first

    /* Busca dados dos contratos de limite de cr�dito */
    CURSOR cr_craplim(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cm.nrdconta
            ,cm.vllimite
      FROM craplim cm
      WHERE cm.cdcooper = pr_cdcooper
        AND cm.tpctrlim = 2
        AND cm.insitlim = 2;

    /* Busca dados dos contratos de limite de cr�dito de acordo com os registros da CRAPASS */
    CURSOR cr_craplimass(pr_cdcooper IN craptab.cdcooper%TYPE) IS  --> Cooperativa
      SELECT cm.nrdconta
            ,cm.vllimite
            ,ass.cdagenci
            ,ass.inpessoa
      FROM craplim cm, crapass ass
      WHERE cm.cdcooper = pr_cdcooper
        AND cm.tpctrlim = 2
        AND cm.insitlim = 2
        AND cm.vllimite > 0
        AND cm.cdcooper = ass.cdcooper
        AND cm.nrdconta = ass.nrdconta;

  BEGIN
    -- C�digo do programa
    vr_cdprogra := 'CRPS365';

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => pr_cdcooper, pr_nmsubdir => '/rl');

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS365', pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se n�o encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haver� raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      pr_cdcritic := 651;

      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Valida��es iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => pr_cdcritic);

    -- Se a variavel de erro � <> 0
    IF pr_cdcritic <> 0 THEN
      -- Buscar descri��o da cr�tica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_erro;
    END IF;

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    --Posicionar no proximo registro
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    -- Se n�o encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;

      pr_cdcritic := 1;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Definir diferen�a de datas
    vr_rel_dtrefere := last_day(rw_crapdat.dtmvtolt);

    -- Carregar PL Table da CRAPCDB
    vr_contador := 0;
    vr_index := NULL;

    -- Carregar tabela de associados
    FOR rw_crapass IN cr_crapass(pr_cdcooper) LOOP
      vr_gerindex := lpad(rw_crapass.nrdconta, 15, '0');

      vr_tab_crapass(vr_gerindex).cdagenci := rw_crapass.cdagenci;
      vr_tab_crapass(vr_gerindex).nmprimtl := rw_crapass.nmprimtl;
    END LOOP;

    FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper, rw_crapdat.dtmvtolt, rw_crapdat.dtmvtopr) LOOP
      -- Verifica se existe registro na tabela de associados
      IF vr_tab_crapass.exists(lpad(rw_crapcdb.nrdconta, 15, '0')) THEN
        vr_gerindex :=  lpad(vr_tab_crapass(lpad(rw_crapcdb.nrdconta, 15, '0')).cdagenci, 3, '0') ||
                        lpad(rw_crapcdb.nrdconta, 15, '0') ||
                        lpad(to_char(rw_crapcdb.dtlibera, 'DDMMRRRR'), 10, '0') ||
                        lpad(rw_crapcdb.cdbanchq, 10, '0') ||
                        lpad(rw_crapcdb.cdagechq, 5, '0') ||
                        lpad(rw_crapcdb.nrctachq, 10, '0') ||
                        lpad(rw_crapcdb.nrcheque, 20, '0');

        -- Cria �ndice para a PL Table
        IF vr_index IS NULL THEN
          vr_index := vr_gerindex;
        ELSE
          IF vr_index <> vr_gerindex THEN
            vr_contador := 0;
            vr_index := vr_gerindex;
          ELSE
            -- Incrementar �ndice
            vr_contador := vr_contador + 1;
          END IF;
        END IF;

        vr_gerindex := vr_index || lpad(vr_contador, 20, '0');

        vr_tab_crapcdb(vr_gerindex).nrdconta := rw_crapcdb.nrdconta;
        vr_tab_crapcdb(vr_gerindex).dtlibera := rw_crapcdb.dtlibera;
        vr_tab_crapcdb(vr_gerindex).cdbanchq := rw_crapcdb.cdbanchq;
        vr_tab_crapcdb(vr_gerindex).cdagechq := rw_crapcdb.cdagechq;
        vr_tab_crapcdb(vr_gerindex).nrctachq := rw_crapcdb.nrctachq;
        vr_tab_crapcdb(vr_gerindex).nrcheque := rw_crapcdb.nrcheque;
        vr_tab_crapcdb(vr_gerindex).nrborder := rw_crapcdb.nrborder;
        vr_tab_crapcdb(vr_gerindex).nrcpfcgc := rw_crapcdb.nrcpfcgc;
        vr_tab_crapcdb(vr_gerindex).dtlibbdc := rw_crapcdb.dtlibbdc;
        vr_tab_crapcdb(vr_gerindex).vlcheque := rw_crapcdb.vlcheque;
        vr_tab_crapcdb(vr_gerindex).vlliquid := rw_crapcdb.vlliquid;
        vr_tab_crapcdb(vr_gerindex).cdagenci := vr_tab_crapass(lpad(rw_crapcdb.nrdconta, 15, '0')).cdagenci;
        vr_tab_crapcdb(vr_gerindex).cdcmpchq := rw_crapcdb.cdcmpchq;
        vr_tab_crapcdb(vr_gerindex).nmprimtl := vr_tab_crapass(lpad(rw_crapcdb.nrdconta, 15, '0')).nmprimtl;
      END IF;
    END LOOP;

    -- Carregar PL Table da CRAPAGE
    FOR rw_crapage IN cr_crapage(pr_cdcooper) LOOP
      vr_tab_crapage(rw_crapage.cdagenci).nmresage := rw_crapage.nmresage;
    END LOOP;

    -- Carregar PL Table da CRAPLJD
    vr_index := NULL;
    vr_contador := 0;
    FOR rw_crapljd IN cr_crapljd(pr_cdcooper, vr_rel_dtrefere) LOOP
      vr_gerindex :=  lpad(rw_crapljd.nrdconta, 15, '0') ||
                      lpad(rw_crapljd.nrborder, 20, '0') ||
                      lpad(rw_crapljd.cdcmpchq, 10, '0') ||
                      lpad(rw_crapljd.cdbanchq, 5, '0') ||
                      lpad(rw_crapljd.cdagechq, 5, '0') ||
                      lpad(rw_crapljd.nrctachq, 20, '0') ||
                      lpad(rw_crapljd.nrcheque, 30, '0');

      -- Montar �ndice
      IF vr_index IS NULL THEN
        vr_index := vr_gerindex;
      ELSE
        IF vr_index <> vr_gerindex THEN
          vr_contador := 0;
          vr_index := vr_gerindex;
        ELSE
          vr_contador := vr_contador + 1;
        END IF;
      END IF;

      vr_gerindex := vr_index || lpad(vr_contador, 20, '0');

      vr_tab_crapljd(vr_gerindex).vldjuros := rw_crapljd.vldjuros;
      vr_tab_crapljd(vr_gerindex).controle := lpad(rw_crapljd.nrdconta, 15, '0') ||
                                              lpad(rw_crapljd.nrborder, 20, '0') ||
                                              lpad(rw_crapljd.cdcmpchq, 10, '0') ||
                                              lpad(rw_crapljd.cdbanchq, 5, '0') ||
                                              lpad(rw_crapljd.cdagechq, 5, '0') ||
                                              lpad(rw_crapljd.nrctachq, 20, '0') ||
                                              lpad(rw_crapljd.nrcheque, 30, '0');
    END LOOP;

    -- Carregar PL Table da CRAPCEC
    FOR rw_crapcec IN cr_crapcec(pr_cdcooper) LOOP
      vr_tab_crapcec(lpad(rw_crapcec.nrcpfcgc, 20, '0')).nmcheque := rw_crapcec.nmcheque;
      vr_tab_crapcec(lpad(rw_crapcec.nrcpfcgc, 20, '0')).nrcpfcgc := rw_crapcec.nrcpfcgc;
    END LOOP;

    -- Carregar PL Table da CRAPLIM
    FOR rw_craplim IN cr_craplim(pr_cdcooper) LOOP
      vr_tab_craplim(lpad(rw_craplim.nrdconta, 15, '0')).nrdconta := rw_craplim.nrdconta;
      vr_tab_craplim(lpad(rw_craplim.nrdconta, 15, '0')).vllimite := rw_craplim.vllimite;
    END LOOP;

    -- Inicializar vari�veis
    vr_rel_qtdsocio := 0;
    vr_tot_utilizad := 0;
    vr_tot_naoutili := 0;
    vr_tot_vlrutili := 0;
    vr_tot_vlrnaout := 0;

    -- Inicializar os CLOBs
    dbms_lob.createtemporary(vr_xml_1, TRUE);
    dbms_lob.open(vr_xml_1, dbms_lob.lob_readwrite);
    vr_xml_1 := '<?xml version="1.0" encoding="utf-8"?><base>';
    dbms_lob.createtemporary(vr_xml_2, TRUE);
    dbms_lob.open(vr_xml_2, dbms_lob.lob_readwrite);
    vr_xml_2 := '<?xml version="1.0" encoding="utf-8"?><base>';

    -- Gerar cabe�alho de dados no XML
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<cabData>SALDO DE DESCONTO DE CHEQUES EM ' || to_char(vr_rel_dtrefere, 'DD/MM/RRRR') || '</cabData>';
    vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<cabData>SALDO DE DESCONTO DE CHEQUES EM ' || to_char(vr_rel_dtrefere, 'DD/MM/RRRR') || '</cabData>';

    -- Abrir TAG XML
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<registros1>';
    vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<registros2>';

    -- Capturar �ndice da PL Table
    vr_index := vr_tab_crapcdb.first;

    -- Iterar dados da PL Table
    LOOP
      EXIT WHEN vr_index IS NULL;

      -- Verifica se � o primeiro �ndice da quebra
      IF vr_tab_crapcdb.prior(vr_index) IS NULL OR vr_tab_crapcdb(vr_index).cdagenci <> vr_tab_crapcdb(vr_tab_crapcdb.prior(vr_index)).cdagenci THEN
        vr_rel_dsagenci :=  vr_tab_crapcdb(vr_index).cdagenci || ' - ' || vr_tab_crapage(vr_tab_crapcdb(vr_index).cdagenci).nmresage;

        -- Criar mensagem no arquivo XML
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<pac><descricao>=>  PA: ' || vr_rel_dsagenci || '</descricao>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);

        vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<pac><descricao>=>  PA: ' || vr_rel_dsagenci || '</descricao>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      END IF;

      -- Verifica se existe bordero criado
      IF NOT vr_tab_borderos.exists(lpad(vr_tab_crapcdb(vr_index).nrborder, 50, '0')) THEN
        vr_tab_borderos(lpad(vr_tab_crapcdb(vr_index).nrborder, 50, '0')).nrborder := vr_tab_crapcdb(vr_index).nrborder;
        vr_rel_qtdsocio := vr_rel_qtdsocio + 1;
      END IF;

      -- Sumarizar valores
      vr_rel_qtcheque := vr_rel_qtcheque + 1;
      vr_rel_vldescto := vr_rel_vldescto + vr_tab_crapcdb(vr_index).vlcheque;
      vr_rel_vljurchq := 0;

      -- Sumariza os juros sobre cheques
      vr_idxljd := lpad(vr_tab_crapcdb(vr_index).nrdconta, 15, '0') ||
                   lpad(vr_tab_crapcdb(vr_index).nrborder, 20, '0') ||
                   lpad(vr_tab_crapcdb(vr_index).cdcmpchq, 10, '0') ||
                   lpad(vr_tab_crapcdb(vr_index).cdbanchq, 5, '0') ||
                   lpad(vr_tab_crapcdb(vr_index).cdagechq, 5, '0') ||
                   lpad(vr_tab_crapcdb(vr_index).nrctachq, 20, '0') ||
                   lpad(vr_tab_crapcdb(vr_index).nrcheque, 30, '0') || lpad('0', 20, '0');

      IF vr_tab_crapljd.exists(vr_idxljd) THEN
        LOOP
          EXIT WHEN vr_idxljd IS NULL;

          -- Sumarizar valores
          vr_rel_vldjuros := vr_rel_vldjuros + vr_tab_crapljd(vr_idxljd).vldjuros;
          vr_rel_vljurchq := vr_rel_vljurchq + vr_tab_crapljd(vr_idxljd).vldjuros;

          -- Identificar pr�ximo �ndice (ou se � quebra de �ndice)
          IF vr_tab_crapljd.next(vr_idxljd) IS NOT NULL AND vr_tab_crapljd(vr_idxljd).controle = vr_tab_crapljd(vr_tab_crapljd.next(vr_idxljd)).controle THEN
            vr_idxljd := vr_tab_crapljd.next(vr_idxljd);
          ELSE
            vr_idxljd := NULL;
          END IF;
        END LOOP;
      END IF;

      -- Verifica se � o primeiro �ndice da quebra
      IF vr_tab_crapcdb.prior(vr_index) IS NULL OR vr_tab_crapcdb(vr_index).nrdconta <> vr_tab_crapcdb(vr_tab_crapcdb.prior(vr_index)).nrdconta THEN
        vr_rel_nrdconta := vr_tab_crapcdb(vr_index).nrdconta;
        vr_rel_nmprimtl := vr_tab_crapcdb(vr_index).nmprimtl;

        -- Gerar dados para o relat�rio de auditoria
        vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<registro2><nrdconta>' || to_char(vr_rel_nrdconta, 'FM9999G999G999G9') || '</nrdconta>' ||
                                            '<nmprimtl><![CDATA[' || vr_rel_nmprimtl || ']]></nmprimtl>';
       gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      END IF;

      -- Verificar se existe registro na CRAPCEC
      IF NOT vr_tab_crapcec.exists(lpad(vr_tab_crapcdb(vr_index).nrcpfcgc, 20, '0')) THEN
        vr_rel_nmcheque := 'NAO CADASTRADO';
        vr_rel_dscpfcgc := 'NAO CADASTRADO';
      ELSE
        vr_rel_nmcheque := vr_tab_crapcec(lpad(vr_tab_crapcdb(vr_index).nrcpfcgc, 20, '0')).nmcheque;

        -- Valida CNPJ/CPF
        gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_tab_crapcec(lpad(vr_tab_crapcdb(vr_index).nrcpfcgc, 20, '0')).nrcpfcgc
                                   ,pr_stsnrcal => vr_stsnrcal
                                   ,pr_inpessoa => vr_inpessoa);

        IF vr_stsnrcal THEN
          vr_rel_dscpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_crapcec(lpad(vr_tab_crapcdb(vr_index).nrcpfcgc, 20, '0')).nrcpfcgc
                                                      ,pr_inpessoa => vr_inpessoa);
        END IF;
      END IF;

      -- Gerar dados para relat�rio
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<corpo><dtlibera>' || to_char(vr_tab_crapcdb(vr_index).dtlibera, 'DD/MM/RRRR') || '</dtlibera>' ||
                                          '<dtlibbdc>' || to_char(vr_tab_crapcdb(vr_index).dtlibbdc, 'DD/MM/RRRR') || '</dtlibbdc>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<nrborder>' || to_char(vr_tab_crapcdb(vr_index).nrborder, 'FM999G999G999') || '</nrborder>' ||
                                          '<cdbanchq>' || vr_tab_crapcdb(vr_index).cdbanchq || '</cdbanchq>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<cdagechq>' || vr_tab_crapcdb(vr_index).cdagechq || '</cdagechq>' ||
                                          '<nrctachq>' || vr_tab_crapcdb(vr_index).nrctachq || '</nrctachq>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<nrcheque>' || to_char(vr_tab_crapcdb(vr_index).nrcheque, 'FM999G999G999') || '</nrcheque>' ||
                                          '<vlcheque>' || to_char(vr_tab_crapcdb(vr_index).vlcheque, 'FM999G999G999G990D00') || '</vlcheque>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<vlliquid>' || to_char(vr_tab_crapcdb(vr_index).vlliquid, 'FM999G999G999G990D00') || '</vlliquid>' ||
                                          '<rel_nmcheque><![CDATA[' || vr_rel_nmcheque || ']]></rel_nmcheque>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<rel_dscpfcgc>' || vr_rel_dscpfcgc || '</rel_dscpfcgc>' ||
                                          '<rel_vljurchq>' || to_char(vr_rel_vljurchq, 'FM999G999G999G990D00') || '</rel_vljurchq>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<cdagenciordena>' || lpad(vr_tab_crapcdb(vr_index).cdagenci, 10, '0') || '</cdagenciordena>' ||
                                          '<nrdcontaordena>' || lpad(vr_tab_crapcdb(vr_index).nrdconta, 20, '0')  || '</nrdcontaordena>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<dtliberaordena>' || to_char(vr_tab_crapcdb(vr_index).dtlibera, 'RRRRMMDD') || '</dtliberaordena>' ||
                                          '<cdbanchqordena>' || lpad(vr_tab_crapcdb(vr_index).cdbanchq, 20, '0')  || '</cdbanchqordena>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<cdagechqordena>' || lpad(vr_tab_crapcdb(vr_index).cdagechq, 10, '0') || '</cdagechqordena>' ||
                                          '<nrctachqordena>' || lpad(vr_tab_crapcdb(vr_index).nrctachq, 20, '0')  || '</nrctachqordena>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
      vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<nrchequeordena>' || lpad(vr_tab_crapcdb(vr_index).nrcheque, 20, '0') || '</nrchequeordena></corpo>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);


      IF vr_tab_crapcdb.next(vr_index) IS NULL OR vr_tab_crapcdb(vr_index).nrdconta <> vr_tab_crapcdb(vr_tab_crapcdb.next(vr_index)).nrdconta THEN

        -- Sumarizar e deletar borderos
        vr_tot_qtdgeral := vr_tot_qtdgeral + vr_tab_borderos.count;
        vr_tab_borderos.delete;

        -- Incrementar valor
        vr_tot_qtdesche := vr_tot_qtdesche + 1;

        -- Verificar se existe limite de cr�dito para a conta
        IF vr_tab_craplim.exists(lpad(vr_tab_crapcdb(vr_index).nrdconta, 15, '0')) THEN
          vr_rel_vllimite := vr_tab_craplim(lpad(vr_tab_crapcdb(vr_index).nrdconta, 15, '0')).vllimite;
        ELSE
          vr_rel_vllimite := 0;
        END IF;

        -- Contar valor limite
        IF vr_rel_vllimite > 0  THEN
          vr_tot_vllimite := vr_tot_vllimite + 1;
          vr_tot_vlrlimit := vr_tot_vlrlimit + vr_rel_vllimite;
        END IF;

        -- Sumariza valor dispon�vel
        vr_rel_disponiv := vr_rel_vllimite - vr_rel_vldescto;

        -- Verifica valor dispon�vel
        IF vr_rel_disponiv <> 0  THEN
          vr_tot_vlrdispo := vr_tot_vlrdispo + vr_rel_disponiv;
        END IF;

        -- Gera dados para relat�rio
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<registro1><rel_nrdconta>' || to_char(vr_rel_nrdconta, 'FM9999999G999G9') || '</rel_nrdconta>' ||
                                            '<rel_nmprimtl><![CDATA[' || vr_rel_nmprimtl || ']]></rel_nmprimtl>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<rel_qtcheque>' || to_char(vr_rel_qtcheque, 'FM9999G999G999G999') || '</rel_qtcheque>' ||
                                            '<rel_qtdsocio>' || to_char(vr_rel_qtdsocio, 'FM9999G999G999G999') || '</rel_qtdsocio>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<rel_vllimite>' || to_char(vr_rel_vllimite, 'FM999G999G999G990D00') || '</rel_vllimite>' ||
                                            '<rel_vldescto>' || to_char(vr_rel_vldescto, 'FM999G999G999G990D00') || '</rel_vldescto>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<rel_vldjuros>' || to_char(vr_rel_vldjuros, 'FM999G999G999G990D00') || '</rel_vldjuros>' ||
                                            '<rel_disponiv>' || to_char(vr_rel_disponiv, 'FM999G999G999G990D00') || '</rel_disponiv></registro1>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);

        -- Zerar quantidade
        vr_rel_qtdsocio := 0;

        -- Gerar dados para o relat�rio
        vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<total><rel_qtcheque>' || to_char(vr_rel_qtcheque, 'FM9999G999G999G999') || '</rel_qtcheque>' ||
                                            '<rel_vldescto>' || to_char(vr_rel_vldescto, 'FM999G999G999G990D00') || '</rel_vldescto>' ||
                                            '<rel_vldjuros>' || to_char(vr_rel_vldjuros, 'FM999G999G999G990D00') || '</rel_vldjuros></total></registro2>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);

        vr_controle := TRUE;

        -- Sumarizar valores
        vr_tot_qtcheque := vr_tot_qtcheque + vr_rel_qtcheque;
        vr_tot_vldescto := vr_tot_vldescto + vr_rel_vldescto;
        vr_tot_vldjuros := vr_tot_vldjuros + vr_rel_vldjuros;
        vr_rel_qtcheque := 0;
        vr_rel_vldescto := 0;
        vr_rel_vldjuros := 0;
      END IF;

      IF vr_tab_crapcdb.next(vr_index) IS NULL OR
         vr_tab_crapcdb(vr_index).cdagenci <> vr_tab_crapcdb(vr_tab_crapcdb.next(vr_index)).cdagenci THEN
        -- Montar descri��o do cheque
        vr_rel_deschequ := vr_tot_qtdesche || ' SOCIOS';

        -- Gera dados para relat�rio
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<total><rel_deschequ>' || vr_rel_deschequ || '</rel_deschequ>' ||
                                            '<tot_qtcheque>' || to_char(vr_tot_qtcheque, 'FM999G999G999G999') || '</tot_qtcheque>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<tot_qtdgeral>' || to_char(vr_tot_qtdgeral, 'FM999G999G999G999') || '</tot_qtdgeral>' ||
                                            '<tot_vlrlimit>' || to_char(vr_tot_vlrlimit, 'FM999G999G999G990D00') || '</tot_vlrlimit>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<tot_vldescto>' || to_char(vr_tot_vldescto, 'FM999G999G999G990D00') || '</tot_vldescto>' ||
                                            '<tot_vldjuros>' || to_char(vr_tot_vldjuros, 'FM999G999G999G990D00') || '</tot_vldjuros>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<tot_vllimite>' || to_char(vr_tot_vllimite, 'FM999G999G999G999') || '</tot_vllimite>' ||
                                            '<tot_vlrdispo>' || to_char(vr_tot_vlrdispo, 'FM999G999G999G990D00') || '</tot_vlrdispo></total></pac>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);

        -- Gerar dados para relat�rio
        vr_xmlbuffer_2 := vr_xmlbuffer_2 || '</pac>';

        -- Total geral de todos os PAC�s
        vr_tot_descgral := vr_tot_descgral + vr_tot_qtdesche;
        vr_tot_geralchq := vr_tot_geralchq + vr_tot_qtcheque;
        vr_tot_geralqtd := vr_tot_geralqtd + vr_tot_qtdgeral;
        vr_tot_valorlim := vr_tot_valorlim + vr_tot_vlrlimit;
        vr_tot_valordes := vr_tot_valordes + vr_tot_vldescto;
        vr_tot_valorjur := vr_tot_valorjur + vr_tot_vldjuros;
        vr_tot_limitevl := vr_tot_limitevl + vr_tot_vllimite;
        vr_tot_dispovlr := vr_tot_dispovlr + vr_tot_vlrdispo;

        vr_rel_descgral := vr_tot_descgral || ' SOCIOS';
        vr_tot_qtdesche := 0;
        vr_tot_qtcheque := 0;
        vr_tot_qtdgeral := 0;
        vr_tot_vlrlimit := 0;
        vr_tot_vldescto := 0;
        vr_tot_vldjuros := 0;
        vr_tot_vllimite := 0;
        vr_tot_vlrdispo := 0;
      END IF;

      -- Controlar conta de totaliza��o de resultados
      vr_tab_crapcdbr(lpad(vr_tab_crapcdb(vr_index).nrdconta, 20, '0')).nrdconta := vr_tab_crapcdb(vr_index).nrdconta;

      -- Capturar pr�ximo �ndice
      vr_index := vr_tab_crapcdb.next(vr_index);
    END LOOP;

    -- Gera dados para relat�rio
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<totalRegistro1><rel_descgral>' || vr_rel_descgral || '</rel_descgral>' ||
                                        '<tot_geralchq>' || to_char(vr_tot_geralchq, 'FM999G999G999G999') || '</tot_geralchq>';
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<tot_geralqtd>' || to_char(vr_tot_geralqtd, 'FM999G999G999G999') || '</tot_geralqtd>' ||
                                        '<tot_valorlim>' || to_char(vr_tot_valorlim, 'FM999G999G999G990D00') || '</tot_valorlim>';
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<tot_valordes>' || to_char(vr_tot_valordes, 'FM999G999G999G990D00') || '</tot_valordes>' ||
                                        '<tot_valorjur>' || to_char(vr_tot_valorjur, 'FM999G999G999G990D00') || '</tot_valorjur>';
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<tot_limitevl>' || to_char(vr_tot_limitevl, 'FM999G999G999G999') || '</tot_limitevl>' ||
                                        '<tot_dispovlr>' || to_char(vr_tot_dispovlr, 'FM999G999G999G990D00') || '</tot_dispovlr></totalRegistro1>';
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);

    -- Consultar limites de cr�dito por conta contida na CRAPASS
    FOR rw_craplimass IN cr_craplimass(pr_cdcooper) LOOP
      -- Criar �ndice
      vr_index := lpad(rw_craplimass.cdagenci, 10, '0');

      -- Verifica se existe registro na PL Table de sumariza��o
      IF NOT vr_tab_work.exists(lpad(rw_craplimass.cdagenci, 10, '0')) THEN
        vr_tab_work(vr_index).cdagenci := rw_craplimass.cdagenci;
        vr_tab_work(vr_index).qtd_naoutili(1) := 0;
        vr_tab_work(vr_index).vlr_naoutili(1) := 0;
        vr_tab_work(vr_index).qtd_naoutili(2) := 0;
        vr_tab_work(vr_index).vlr_naoutili(2) := 0;
        vr_tab_work(vr_index).qtd_utiliza(1) := 0;
        vr_tab_work(vr_index).vlr_utiliza(1) := 0;
        vr_tab_work(vr_index).qtd_utiliza(2) := 0;
        vr_tab_work(vr_index).vlr_utiliza(2) := 0;
      END IF;

      -- Verifica se existe registro na PL Table da CRAPCDB
      IF NOT vr_tab_crapcdbr.exists(lpad(rw_craplimass.nrdconta, 20, '0')) THEN
        -- Valida se � pessoa f�sica ou jur�dica
        IF rw_craplimass.inpessoa = 1 THEN
          vr_tab_work(vr_index).qtd_naoutili(1) := vr_tab_work(vr_index).qtd_naoutili(1) + 1;
          vr_tab_work(vr_index).vlr_naoutili(1) := vr_tab_work(vr_index).vlr_naoutili(1) + rw_craplimass.vllimite;
        ELSIF rw_craplimass.inpessoa = 2 THEN
          vr_tab_work(vr_index).qtd_naoutili(2) := vr_tab_work(vr_index).qtd_naoutili(2) + 1;
          vr_tab_work(vr_index).vlr_naoutili(2) := vr_tab_work(vr_index).vlr_naoutili(2) + rw_craplimass.vllimite;
        END IF;
      ELSE
        -- Valida se � pessoa f�sica ou jur�dica
        IF rw_craplimass.inpessoa = 1 THEN
          vr_tab_work(vr_index).qtd_utiliza(1) := vr_tab_work(vr_index).qtd_utiliza(1) + 1;
          vr_tab_work(vr_index).vlr_utiliza(1) := vr_tab_work(vr_index).vlr_utiliza(1) + rw_craplimass.vllimite;
        ELSIF rw_craplimass.inpessoa = 2 THEN
          vr_tab_work(vr_index).qtd_utiliza(2) := vr_tab_work(vr_index).qtd_utiliza(2) + 1;
          vr_tab_work(vr_index).vlr_utiliza(2) := vr_tab_work(vr_index).vlr_utiliza(2) + rw_craplimass.vllimite;
        END IF;
      END IF;
    END LOOP;

    -- Buscar o primeiro registro da PL Table
    vr_index := vr_tab_work.first;

    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<totSumario>';

    LOOP
      EXIT WHEN vr_index IS NULL;

      -- Verifica se � quebra do �ndice
      IF vr_tab_work.next(vr_index) IS NULL OR vr_tab_work(vr_index).cdagenci <> vr_tab_work(vr_tab_work.next(vr_index)).cdagenci THEN
        vr_tot_utilizad := nvl(vr_tot_utilizad, 0) + vr_tab_work(vr_index).qtd_utiliza(1) + vr_tab_work(vr_index).qtd_utiliza(2);
        vr_tot_naoutili := nvl(vr_tot_naoutili, 0) + vr_tab_work(vr_index).qtd_naoutili(1) + vr_tab_work(vr_index).qtd_naoutili(2);
        vr_tot_vlrutili := nvl(vr_tot_vlrutili, 0) + vr_tab_work(vr_index).vlr_utiliza(1) + vr_tab_work(vr_index).vlr_utiliza(2);
        vr_tot_vlrnaout := nvl(vr_tot_vlrnaout, 0) + vr_tab_work(vr_index).vlr_naoutili(1) + vr_tab_work(vr_index).vlr_naoutili(2);

        -- Gera dados para relat�rio
        vr_qtd_utiliza  := vr_tab_work(vr_index).qtd_utiliza(1) + vr_tab_work(vr_index).qtd_utiliza(2);
        vr_vlr_utiliza  := vr_tab_work(vr_index).vlr_utiliza(1) + vr_tab_work(vr_index).vlr_utiliza(2);
        vr_qtd_nutiliza := vr_tab_work(vr_index).qtd_naoutili(1) + vr_tab_work(vr_index).qtd_naoutili(2);
        vr_vlr_nutiliza := vr_tab_work(vr_index).vlr_naoutili(1) + vr_tab_work(vr_index).vlr_naoutili(2);

        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<totalPrimeiro><cdagenci>' || vr_tab_work(vr_index).cdagenci || '</cdagenci>' ||
                                            '<qtd_utiliza>' || to_char(vr_qtd_utiliza, 'FM999G999G999G999') || '</qtd_utiliza>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob => vr_xml_1);
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<vlr_utiliza>' || to_char(vr_vlr_utiliza, 'FM999G999G999G990D00') || '</vlr_utiliza>' ||
                                            '<qtd_naoutili>' || to_char(vr_qtd_nutiliza, 'FM999G999G999G999') || '</qtd_naoutili>' ||
                                            '<vlr_naoutili>' || to_char(vr_vlr_nutiliza, 'FM999G999G999G990D00') || '</vlr_naoutili></totalPrimeiro>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob => vr_xml_1);
      END IF;

      -- Pr�ximo registro
      vr_index := vr_tab_work.next(vr_index);
    END LOOP;

    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '</totSumario>';

    -- Gera dados para relat�rio
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<totalGeralLimite><tot_utilizad>' || to_char(vr_tot_utilizad, 'FM999G999G999') || '</tot_utilizad>' ||
                                        '<tot_naoutili>' || to_char(vr_tot_naoutili, 'FM999G999G999') || '</tot_naoutili>';
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<tot_vlrutili>' || to_char(vr_tot_vlrutili, 'FM999G999G999G990D00') || '</tot_vlrutili>' ||
                                        '<tot_vlrnaout>' || to_char(vr_tot_vlrnaout, 'FM999G999G999G990D00') || '</tot_vlrnaout></totalGeralLimite>';
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);

    -- Gerar TAG pai
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<TipoPessoa>';

    -- Gerar totaliza��o por tipo de pessoa
    FOR vr_contador IN 1..2 LOOP
      -- Zerar valores de vari�veis
      vr_tot_utilizad := 0;
      vr_tot_naoutili := 0;
      vr_tot_vlrutili := 0;
      vr_tot_vlrnaout := 0;

      -- Validar o tipo de pessoa da itera��o
      IF vr_contador = 1 THEN
        vr_tipopess := 'Fisica';
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<regPessoa' || vr_tipopess || '><pessoa><descricao>==>  PESSOA FISICA</descricao>';
      ELSE
        vr_tipopess := 'Juridica';
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<regPessoa' || vr_tipopess || '><pessoa><descricao>==>  PESSOA JURIDICA</descricao>';
      END IF;

      -- Buscar o primeiro registro da PL Table
      vr_index := vr_tab_work.first;

      LOOP
        EXIT WHEN vr_index IS NULL;

        vr_tot_utilizad := nvl(vr_tot_utilizad, 0) + vr_tab_work(vr_index).qtd_utiliza(vr_contador);
        vr_tot_naoutili := nvl(vr_tot_naoutili, 0) + vr_tab_work(vr_index).qtd_naoutili(vr_contador);
        vr_tot_vlrutili := nvl(vr_tot_vlrutili, 0) + vr_tab_work(vr_index).vlr_utiliza(vr_contador);
        vr_tot_vlrnaout := nvl(vr_tot_vlrnaout, 0) + vr_tab_work(vr_index).vlr_naoutili(vr_contador);

        -- Gera dados para relat�rio
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<totalPessoa' || vr_tipopess || '><cdagenci>' || vr_tab_work(vr_index).cdagenci || '</cdagenci>' ||
                                            '<qtd_utiliza>' || to_char(vr_tab_work(vr_index).qtd_utiliza(vr_contador), 'FM999G999G999G999') || '</qtd_utiliza>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<vlr_utiliza>' || to_char(vr_tab_work(vr_index).vlr_utiliza(vr_contador), 'FM999G999G999G990D00') || '</vlr_utiliza>' ||
                                            '<qtd_naoutili>' || to_char(vr_tab_work(vr_index).qtd_naoutili(vr_contador), 'FM999G999G999G999') || '</qtd_naoutili>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
        vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<vlr_naoutili>' || to_char(vr_tab_work(vr_index).vlr_naoutili(vr_contador), 'FM999G999G999G990D00') || '</vlr_naoutili>' ||
                                            '</totalPessoa' || vr_tipopess || '>';
        gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);

        -- Pr�ximo registro
        vr_index := vr_tab_work.next(vr_index);
      END LOOP;

      vr_xmlbuffer_1 := vr_xmlbuffer_1 || '</pessoa>';

      -- Gera dados para relat�rio
      vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<totalGeralPessoa><tot_utilizad>' || to_char(vr_tot_utilizad, 'FM999G999G999G999') || '</tot_utilizad>' ||
                                          '<tot_naoutili>' || to_char(vr_tot_naoutili, 'FM999G999G999G999') || '</tot_naoutili>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);
      vr_xmlbuffer_1 := vr_xmlbuffer_1 || '<tot_vlrutili>' || to_char(vr_tot_vlrutili, 'FM999G999G999G990D00') || '</tot_vlrutili>' ||
                                          '<tot_vlrnaout>' || to_char(vr_tot_vlrnaout, 'FM999G999G999G990D00') || '</tot_vlrnaout></totalGeralPessoa>';
      gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => FALSE, pr_clob    => vr_xml_1);

      vr_xmlbuffer_1 := vr_xmlbuffer_1 || '</regPessoa' || vr_tipopess || '>';
    END LOOP;

    -- Fechar TAG pai
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '</TipoPessoa>';

    vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<totalFinal><tot_geralchq>' || to_char(vr_tot_geralchq, 'FM999G999G999G999') || '</tot_geralchq>' ||
                                        '<tot_valordes>' || to_char(vr_tot_valordes, 'FM999G999G999G990D00') || '</tot_valordes>';
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);
    vr_xmlbuffer_2 := vr_xmlbuffer_2 || '<tot_valorjur>' || to_char(vr_tot_valorjur, 'FM999G999G999G990D00') || '</tot_valorjur></totalFinal>';
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => FALSE, pr_clob    => vr_xml_2);

    -- Fechar TAG XML
    vr_xmlbuffer_1 := vr_xmlbuffer_1 || '</registros1></base>';
    vr_xmlbuffer_2 := vr_xmlbuffer_2 || '</registros2></base>';

    -- Finalizar buffer
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_1, pr_gravfim => TRUE, pr_clob    => vr_xml_1);
    gene0002.pc_clob_buffer(pr_dados   => vr_xmlbuffer_2, pr_gravfim => TRUE, pr_clob    => vr_xml_2);

    -- Gerar relat�rio 1
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_xml_1
                               ,pr_dsxmlnode => '/base/registros1'
                               ,pr_dsjasper  => 'crrl311.jasper'
                               ,pr_dsparams  => 'PR_QUEBRA##S'
                               ,pr_dsarqsaid => vr_nom_dir || '/crrl311.lst'
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'S'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => vr_nrcopias
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'N'
                               ,pr_des_erro  => pr_dscritic);

    -- Verifica se executou com erros
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := 'Erro ao gerar CRRL311.XML: ' || pr_dscritic;
      RAISE vr_exc_erro;
    END IF;

    -- Gerar relat�rio 2
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_xml_2
                               ,pr_dsxmlnode => '/base/registros2/pac'
                               ,pr_dsjasper  => 'crrl312.jasper'
                               ,pr_dsparams  => 'PR_QUEBRA##S'
                               ,pr_dsarqsaid => vr_nom_dir || '/crrl312.lst'
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 2
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'N'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => vr_nrcopias
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'N'
                               ,pr_des_erro  => pr_dscritic);

    -- Verifica se executou com erros
    IF pr_dscritic IS NOT NULL THEN
      pr_dscritic := 'Erro ao gerar CRRL312.XML: ' || pr_dscritic;
      RAISE vr_exc_erro;
    END IF;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informa��es atualizada
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas c�digo
      IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
        -- Buscar a descri��o
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;

      -- Devolvemos c�digo e critica encontradas
      pr_cdcritic := NVL(pr_cdcritic, 0);

      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Gerar cr�tica
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;

      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS365;
/

