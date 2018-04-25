CREATE OR REPLACE PROCEDURE CECRED.pc_crps138 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps138 (Fontes/crps138.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Novembro/95                     Ultima atualizacao: 04/04/2018

       Dados referentes ao programa:

       Frequencia: Mensal (Batch).
       Objetivo  : Atende a solicitacao 039.
                   Gerar o relatorio de informacoes gerenciais.
                   Emite relatorio 115.
                   Roda no primeiro dia util.

       Alteracoes: 23/02/96 - Tratar os campos cdempres nas leituras do crapger e do
                          crapacc (Odair).

                   01/04/1996 - Listar tambem vlctrrpp, qtaplrpp, vlaplrpp (Odair)

                   14/08/1996 - Alterado para listar o campo qtassapl (Odair).

                   27/04/1998 - Tratamento para milenio e troca para V8 (Margarete).

                   15/01/1999 - Tratar historico 320 = 58 (Odair)

                   17/03/1999 - Listar resumo de todas as agencias do mes corrente
                                no inicio (Odair).

                   07/01/2000 - Alterado o diretorio /micros (Deborah).

                   30/05/2001 - Alterado para ser impresso na impressora laser
                                com formulario de 234 columas por 62 linhas
                                (Edson).

                   30/10/2003 - Substituido comando RETURN pelo QUIT(Mirtes)

                   20/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                                tabela crapacc (Diego).

                   16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   04/04/2006 - Acerto em estouro de campo LANCTOS (Ze).

                   03/05/2006 - Alterado format "SALDO DEVEDOR" (Diego).

                   25/07/2006 - Alterado numero de copias do relatorio 115 para
                                Viacredi(Elton).

                   07/04/2009 - Aumentado formato do valor capital e
                                saldo medio (Gabriel).

                   22/08/2011 - Alterado format do campo aux_vldjuros (Adriano).

                   08/03/2013 - Alteracao no format aux_vldjuros (Daniele).

                   11/11/2013 - Alterado totalizador de PAs de 99 para 999.
                               (Reinert)

                   19/03/2014 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM)

                   05/05/2014 - Ajuste na passada de pr_nmformul  => '234dh', pois o PDF
                                estava sendo gerado erroneamente (Marcos-Supero)

                   17/06/2014 - Alteração para apresentar dados gerais consolidados
                                das singulares no crrl115 da CECRED - Alteração de 12/02/2014
                                que está na produção (Douglas - Chamado 111830).
                                
                   04/04/2018 - INC0012086 Criado novo rowtype da crapdat pois o rowtype principal
                                quando o programa roda na CECRED estava retendo a data da última 
                                cooperativa buscada (Concredi); Na rotina pc_gera_dados_gerais_coop,
                                retiradas as vars não utilizadas: dtmvtolt e dtmvtopr (Carlos)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS138';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      vr_dtfimmes   DATE; --data fim mes
      vr_dtrefere   DATE; --data referencia

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Cursores genéricos de calendário
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
      rw_crapdat2 btch0001.cr_crapdat%ROWTYPE;
      
      --busca cadastro de informacoes gerais para PA maior que zero
      CURSOR cr_crapger1 (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT  dtrefere,
                cdagenci,
                qtassoci,
                qtassepr,
                qtctacor,
                qtaplrdc,
                qtaplrda,
                qtaplrpp,
                qtassapl,
                qtplanos,
                vlctrrpp,
                vlcaptal,
                vlsmpmes,
                vlaplrdc,
                vlaplrda,
                vlaplrpp
        FROM    crapger
        WHERE   crapger.cdcooper = pr_cdcooper
        AND     crapger.dtrefere = vr_dtfimmes
        AND     crapger.cdempres = 0
        AND     crapger.cdagenci > 0;
      --busca cadastro de informacoes gerais para todos os PAs
      CURSOR cr_crapger2 (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT  dtrefere,
                cdagenci,
                qtassoci,
                qtassepr,
                qtctacor,
                qtaplrdc,
                qtaplrda,
                qtaplrpp,
                qtassapl,
                qtplanos,
                vlctrrpp,
                vlcaptal,
                vlsmpmes,
                vlaplrdc,
                vlaplrda,
                vlaplrpp
        FROM    crapger
        WHERE   crapger.cdcooper = pr_cdcooper
        AND     crapger.dtrefere > vr_dtrefere
        AND     crapger.cdempres = 0
        ORDER BY crapger.cdagenci,
                 crapger.dtrefere;
      -- busca informacoes gerenciais acumuladas para lancamentos 0
      CURSOR cr_crapacc1(pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_dtrefere IN crapger.dtrefere%TYPE,
                         pr_cdagenci IN crapger.cdagenci%TYPE)  IS
        SELECT  tpregist,
                qtlanmto,
                vllanmto
        FROM    crapacc
        WHERE   crapacc.cdcooper = pr_cdcooper
        AND     crapacc.dtrefere = pr_dtrefere
        AND     crapacc.cdagenci = pr_cdagenci
        AND     crapacc.cdempres = 0
        AND     crapacc.cdlanmto = 0;

      -- busca informacoes gerenciais acumuladas para lancamentos (37,38,57,58,62,75,93,95,98,320)
      CURSOR cr_crapacc2 (pr_cdcooper IN crapcop.cdcooper%TYPE,
                          pr_dtrefere IN crapger.dtrefere%TYPE,
                          pr_cdagenci IN crapger.cdagenci%TYPE) IS
        SELECT  tpregist,
                qtlanmto,
                vllanmto,
                cdlanmto
        FROM    crapacc
        WHERE   crapacc.cdcooper = pr_cdcooper
        AND     crapacc.dtrefere = pr_dtrefere
        AND     crapacc.cdagenci = pr_cdagenci
        AND     crapacc.cdempres = 0
        AND     crapacc.tpregist = 1
        AND     crapacc.cdlanmto IN (37,38,57,58,62,75,93,95,98,320);

      -- busca informacoes gerenciais acumuladas para lancamentos (7,8)
      CURSOR cr_crapacc3(pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_dtrefere IN crapger.dtrefere%TYPE,
                         pr_cdagenci IN crapger.cdagenci%TYPE) IS
        SELECT  sum(vllanmto)
        FROM    crapacc
        WHERE   crapacc.cdcooper = pr_cdcooper
        AND     crapacc.dtrefere = pr_dtrefere
        AND     crapacc.cdagenci = pr_cdagenci
        AND     crapacc.cdempres = 0
        AND     crapacc.tpregist = 1
        AND     crapacc.cdlanmto IN (7,8);

      -- busca nome da agencia
      CURSOR cr_crapage(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdagenci IN crapger.cdagenci%TYPE)  IS
        SELECT  nmresage
        FROM    crapage
        WHERE   crapage.cdcooper = pr_cdcooper
        AND     crapage.cdagenci = pr_cdagenci;

      -- Busca dos dados das cooperativas, menos da CECRED
      CURSOR cr_crapcop2 IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper <> 3;
      rw_crapcop2 cr_crapcop2%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      --guarda informacoes do relatorios de resumo
      TYPE typ_reg_resumo IS
        RECORD ( cdagenci VARCHAR2(3)
                ,nmresage VARCHAR2(100)
                ,qtassoci crapger.qtassoci%TYPE
                ,qtassepr crapger.qtassepr%TYPE
                ,qtctacor crapger.qtctacor%TYPE
                ,qtlansis NUMBER
                ,qtempres NUMBER
                ,qtepreac NUMBER
                ,qtaplrdc crapger.qtaplrdc%TYPE
                ,qtaplrpp crapger.qtaplrpp%TYPE
                ,qtassapl crapger.qtassapl%TYPE
                ,qtplanos crapger.qtplanos%TYPE
                ,vldespla NUMBER
                ,vldesepr NUMBER
                ,vlctrrpp crapger.vlctrrpp%TYPE
                ,vlcaptal crapger.vlcaptal%TYPE
                ,vlsmpmes crapger.vlsmpmes%TYPE
                ,vlempmes NUMBER
                ,vlepreac NUMBER
                ,vlaplrdc crapger.vlaplrdc%TYPE
                ,vlaplrpp crapger.vlaplrpp%TYPE
                ,vlcrefol NUMBER
                ,vldjuros NUMBER
                );
      TYPE typ_tab_resumo IS
        TABLE OF typ_reg_resumo
          INDEX BY VARCHAR2(3); --> 03 PA
      vr_tab_resumo typ_tab_resumo;

      --guarda informacoes do relatorio por data
      TYPE typ_reg_data IS
        RECORD ( dtrefere VARCHAR2(6)
                ,cdagenci crapass.cdagenci%TYPE
                ,nmresage VARCHAR2(100)
                ,qtassoci crapger.qtassoci%TYPE
                ,qtassepr crapger.qtassepr%TYPE
                ,qtctacor crapger.qtctacor%TYPE
                ,qtlansis NUMBER
                ,qtempres NUMBER
                ,qtepreac NUMBER
                ,qtaplrdc crapger.qtaplrdc%TYPE
                ,qtaplrpp crapger.qtaplrpp%TYPE
                ,qtassapl crapger.qtassapl%TYPE
                ,qtplanos crapger.qtplanos%TYPE
                ,vldespla NUMBER
                ,vldesepr NUMBER
                ,vlctrrpp crapger.vlctrrpp%TYPE
                ,vlcaptal crapger.vlcaptal%TYPE
                ,vlsmpmes crapger.vlsmpmes%TYPE
                ,vlempmes NUMBER
                ,vlepreac NUMBER
                ,vlaplrdc crapger.vlaplrdc%TYPE
                ,vlaplrpp crapger.vlaplrpp%TYPE
                ,vlcrefol NUMBER
                ,vldjuros NUMBER
                );
      TYPE typ_tab_data IS
        TABLE OF typ_reg_data
          INDEX BY VARCHAR2(11); --> 06 data referencia + 05 PA
      vr_tab_data typ_tab_data;
      vr_des_chave  VARCHAR2(11);


      ------------------------------- VARIAVEIS -------------------------------

      vr_nmresage VARCHAR2(100);
      vr_qtlansis NUMBER;
      vr_qtempres NUMBER;
      vr_vlempmes NUMBER;
      vr_qtepreac NUMBER;
      vr_vlepreac NUMBER;
      vr_vlaplica NUMBER;
      vr_vldjuros NUMBER;
      vr_vldesepr NUMBER;
      vr_vldespla NUMBER;
      vr_vlcrefol NUMBER;
      vr_nrcopias NUMBER;
      vr_nmarqim  VARCHAR2(30);
      vr_rel_dtrefere VARCHAR2(6);
      -- Variaveis para os XMLs e relatórios
      vr_clobxml     CLOB;   -- Clob para conter o XML de dados
      vr_nom_direto  VARCHAR2(200);         -- Diretório para gravação do arquivo

      --------------------------- SUBROTINAS INTERNAS --------------------------

      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

      PROCEDURE pc_carrega_resumo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_nmresage IN VARCHAR2) IS
      BEGIN
        FOR rw_crapger IN cr_crapger1(pr_cdcooper) --busca informacoes gerenciais
        LOOP
          EXIT WHEN cr_crapger1%NOTFOUND;
          vr_qtlansis := 0;
          vr_qtempres := 0;
          vr_vlempmes := 0;
          vr_qtepreac := 0;
          vr_vlepreac := 0;
          vr_vlaplica := 0;
          vr_vldjuros := 0;
          vr_vldesepr := 0;
          vr_vldespla := 0;
          -- busca informacoes acumuladas
          FOR rw_crapacc IN cr_crapacc1(pr_cdcooper,rw_crapger.dtrefere,rw_crapger.cdagenci)
          LOOP
            EXIT WHEN cr_crapacc1%NOTFOUND;
            --verifica tipo registro é historico
            IF   rw_crapacc.tpregist = 1 THEN
              vr_qtlansis := rw_crapacc.qtlanmto;
            --verifica tipo registro é emp/linha
            ELSIF rw_crapacc.tpregist = 2 THEN
              vr_qtempres := rw_crapacc.qtlanmto;
              vr_vlempmes := rw_crapacc.vllanmto;
            --verifica tipo registro é sdo dev/linha
            ELSIF rw_crapacc.tpregist = 3 THEN
              vr_qtepreac := rw_crapacc.qtlanmto;
              vr_vlepreac := rw_crapacc.vllanmto;
            END IF;
          END LOOP;
          --busca acumulado dos historicos especificos
          FOR rw_crapacc IN cr_crapacc2(pr_cdcooper,rw_crapger.dtrefere,rw_crapger.cdagenci)
          LOOP
            EXIT WHEN cr_crapacc2%NOTFOUND;
            --verifica codico do historico
            IF  rw_crapacc.cdlanmto = 58 OR
                rw_crapacc.cdlanmto = 320 THEN
              vr_vldjuros := vr_vldjuros - rw_crapacc.vllanmto;
            ELSIF rw_crapacc.cdlanmto = 98 OR
                  rw_crapacc.cdlanmto = 38 OR
                  rw_crapacc.cdlanmto = 57 OR
                  rw_crapacc.cdlanmto = 37 THEN
              vr_vldjuros := vr_vldjuros + rw_crapacc.vllanmto;
            ELSIF rw_crapacc.cdlanmto = 62 OR
                  rw_crapacc.cdlanmto = 75 THEN
              vr_vldespla := vr_vldespla + rw_crapacc.vllanmto;
            ELSIF rw_crapacc.cdlanmto = 93 OR
                  rw_crapacc.cdlanmto = 95 THEN
              vr_vldesepr := vr_vldesepr + rw_crapacc.vllanmto;
            END IF;
          END LOOP;
          --busca informacoes dos historicos 7,8
          OPEN cr_crapacc3(pr_cdcooper,rw_crapger.dtrefere,rw_crapger.cdagenci);
          FETCH cr_crapacc3 INTO vr_vlcrefol;
          CLOSE cr_crapacc3;
          vr_vlcrefol := nvl(vr_vlcrefol,0);
          vr_rel_dtrefere := lpad(rw_crapger.cdagenci,3,'0');
          --popula temp table resumo
          vr_des_chave := lpad(rw_crapger.cdagenci,3,'0');
          vr_tab_resumo(vr_des_chave).nmresage  := pr_nmresage;
          vr_tab_resumo(vr_des_chave).cdagenci  := rw_crapger.cdagenci;
          vr_tab_resumo(vr_des_chave).qtassoci  := rw_crapger.qtassoci;
          vr_tab_resumo(vr_des_chave).qtassepr  := rw_crapger.qtassepr;
          vr_tab_resumo(vr_des_chave).qtctacor  := rw_crapger.qtctacor;
          vr_tab_resumo(vr_des_chave).qtlansis  := vr_qtlansis;
          vr_tab_resumo(vr_des_chave).qtempres  := vr_qtempres;
          vr_tab_resumo(vr_des_chave).qtepreac  := vr_qtepreac;
          vr_tab_resumo(vr_des_chave).qtaplrdc  := rw_crapger.qtaplrdc + rw_crapger.qtaplrda;
          vr_tab_resumo(vr_des_chave).qtaplrpp  := rw_crapger.qtaplrpp;
          vr_tab_resumo(vr_des_chave).qtassapl  := rw_crapger.qtassapl;
          vr_tab_resumo(vr_des_chave).qtplanos  := rw_crapger.qtplanos;
          vr_tab_resumo(vr_des_chave).vldespla  := vr_vldespla;
          vr_tab_resumo(vr_des_chave).vldesepr  := vr_vldesepr;
          vr_tab_resumo(vr_des_chave).vlctrrpp  := rw_crapger.vlctrrpp;
          vr_tab_resumo(vr_des_chave).vlcaptal  := rw_crapger.vlcaptal;
          vr_tab_resumo(vr_des_chave).vlsmpmes  := rw_crapger.vlsmpmes;
          vr_tab_resumo(vr_des_chave).vlempmes  := vr_vlempmes;
          vr_tab_resumo(vr_des_chave).vlepreac  := vr_vlepreac;
          vr_tab_resumo(vr_des_chave).vlaplrdc  := rw_crapger.vlaplrdc + rw_crapger.vlaplrda;
          vr_tab_resumo(vr_des_chave).vlaplrpp  := rw_crapger.vlaplrpp;
          vr_tab_resumo(vr_des_chave).vlcrefol  := vr_vlcrefol;
          vr_tab_resumo(vr_des_chave).vldjuros  := vr_vldjuros;
        END LOOP;
      END;

      PROCEDURE pc_carrega_datas(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_nmresage IN VARCHAR2
                                ,pr_coop_cecred IN BOOLEAN) IS
      BEGIN
        vr_des_chave := null;
        FOR rw_crapger IN cr_crapger2(pr_cdcooper) -- busca informacoes gerenciais
        LOOP
          EXIT WHEN cr_crapger2%NOTFOUND;
          vr_qtlansis := 0;
          vr_qtempres := 0;
          vr_vlempmes := 0;
          vr_qtepreac := 0;
          vr_vlepreac := 0;
          vr_vlaplica := 0;
          vr_vldjuros := 0;
          vr_vldesepr := 0;
          vr_vldespla := 0;

          -- Verificamos se a cooperativa é a CECRED e validamos o código da agência
          IF  pr_coop_cecred AND rw_crapger.cdagenci > 0 THEN
            CONTINUE;
          END IF;

          --verifica PA <> 0
          IF  rw_crapger.cdagenci = 0 THEN
            IF  pr_coop_cecred THEN
              vr_nmresage := upper(pr_nmresage);
            ELSE
              vr_nmresage := 'GERAL';
            END IF;
          ELSE --busca descricao do PA
            OPEN cr_crapage(pr_cdcooper,rw_crapger.cdagenci);
            FETCH cr_crapage INTO vr_nmresage;
            IF  cr_crapage%NOTFOUND THEN
              vr_nmresage := 'NAO CADASTRADA';
            ELSE -- monta descricao PA
              vr_nmresage := lpad(rw_crapger.cdagenci,3,'0')||
                                  ' - '||vr_nmresage;
            END IF;
            CLOSE cr_crapage;
          END IF;
          -- busca informacoes acumuladas
          FOR rw_crapacc IN cr_crapacc1(pr_cdcooper,rw_crapger.dtrefere,rw_crapger.cdagenci)
          LOOP
            EXIT WHEN cr_crapacc1%NOTFOUND;
            --verifica tipo registro é historico
            IF rw_crapacc.tpregist = 1 THEN
              vr_qtlansis := rw_crapacc.qtlanmto;
            --verifica tipo registro é emp/linha
            ELSIF rw_crapacc.tpregist = 2 THEN
              vr_qtempres := rw_crapacc.qtlanmto;
              vr_vlempmes := rw_crapacc.vllanmto;
            --verifica tipo registro é sdo dev/linha
            ELSIF rw_crapacc.tpregist = 3 THEN
              vr_qtepreac := rw_crapacc.qtlanmto;
              vr_vlepreac := rw_crapacc.vllanmto;
            END IF;
          END LOOP;
          --busca acumulado dos historicos especificos
          FOR rw_crapacc IN cr_crapacc2(pr_cdcooper,rw_crapger.dtrefere,rw_crapger.cdagenci)
          LOOP
            EXIT WHEN cr_crapacc2%NOTFOUND;
            -- verifica codigo do historico
            IF  rw_crapacc.cdlanmto = 58  OR
                rw_crapacc.cdlanmto = 320 THEN
              vr_vldjuros := vr_vldjuros - rw_crapacc.vllanmto;
            ELSIF rw_crapacc.cdlanmto = 98 OR
                  rw_crapacc.cdlanmto = 38 OR
                  rw_crapacc.cdlanmto = 57 OR
                  rw_crapacc.cdlanmto = 37 THEN
              vr_vldjuros := vr_vldjuros + rw_crapacc.vllanmto;
            ELSIF rw_crapacc.cdlanmto = 62 OR
                  rw_crapacc.cdlanmto = 75 THEN
              vr_vldespla := vr_vldespla + rw_crapacc.vllanmto;
            ELSIF rw_crapacc.cdlanmto = 93 OR
                  rw_crapacc.cdlanmto = 95 THEN
              vr_vldesepr := vr_vldesepr + rw_crapacc.vllanmto;
            END IF;
          END LOOP;
          --busca informacoes dos historicos 7,8
          OPEN cr_crapacc3(pr_cdcooper,rw_crapger.dtrefere,rw_crapger.cdagenci);
          FETCH cr_crapacc3 INTO vr_vlcrefol;
          CLOSE cr_crapacc3;
          vr_vlcrefol := nvl(vr_vlcrefol,0);
          vr_rel_dtrefere := to_char(rw_crapger.dtrefere,'ddmmyy');
          --popula temp table PA
          vr_des_chave := lpad(rw_crapger.cdagenci,3,'0')||to_char(rw_crapger.dtrefere, 'yyyymmdd');
          vr_tab_data(vr_des_chave).dtrefere  := vr_rel_dtrefere;
          vr_tab_data(vr_des_chave).nmresage  := vr_nmresage;
          vr_tab_data(vr_des_chave).qtassoci  := rw_crapger.qtassoci;
          vr_tab_data(vr_des_chave).qtassepr  := rw_crapger.qtassepr;
          vr_tab_data(vr_des_chave).qtctacor  := rw_crapger.qtctacor;
          vr_tab_data(vr_des_chave).qtlansis  := vr_qtlansis;
          vr_tab_data(vr_des_chave).qtempres  := vr_qtempres;
          vr_tab_data(vr_des_chave).qtepreac  := vr_qtepreac;
          vr_tab_data(vr_des_chave).qtaplrdc  := rw_crapger.qtaplrdc + rw_crapger.qtaplrda;
          vr_tab_data(vr_des_chave).qtaplrpp  := rw_crapger.qtaplrpp;
          vr_tab_data(vr_des_chave).qtassapl  := rw_crapger.qtassapl;
          vr_tab_data(vr_des_chave).qtplanos  := rw_crapger.qtplanos;
          vr_tab_data(vr_des_chave).vldespla  := vr_vldespla;
          vr_tab_data(vr_des_chave).vldesepr  := vr_vldesepr;
          vr_tab_data(vr_des_chave).vlctrrpp  := rw_crapger.vlctrrpp;
          vr_tab_data(vr_des_chave).vlcaptal  := rw_crapger.vlcaptal;
          vr_tab_data(vr_des_chave).vlsmpmes  := rw_crapger.vlsmpmes;
          vr_tab_data(vr_des_chave).vlempmes  := vr_vlempmes;
          vr_tab_data(vr_des_chave).vlepreac  := vr_vlepreac;
          vr_tab_data(vr_des_chave).vlaplrdc  := rw_crapger.vlaplrdc + rw_crapger.vlaplrda;
          vr_tab_data(vr_des_chave).vlaplrpp  := rw_crapger.vlaplrpp;
          vr_tab_data(vr_des_chave).vlcrefol  := vr_vlcrefol;
          vr_tab_data(vr_des_chave).vldjuros  := vr_vldjuros;
        END LOOP;
      END;

      PROCEDURE pc_escreve_resumo IS
      BEGIN
        --primeiro registro
        vr_des_chave := vr_tab_resumo.first;
        IF vr_des_chave IS NULL THEN -- gera somente cabecalho do resumo quando nao tiver informacao
          pc_escreve_clob(vr_clobxml,'<pas>'
                                   ||'  <nmresage>'||vr_nmresage||'</nmresage>'
                                   ||'</pas>');
        END IF;
        WHILE vr_des_chave IS NOT NULL LOOP -- varre a tabela temporaria para montar xml
          --monta xml do resumo
          pc_escreve_clob(vr_clobxml,'<pas>'
                                   ||'  <nmresage>'||vr_tab_resumo(vr_des_chave).nmresage||'</nmresage>'
                                   ||'  <pa>'||lpad(vr_tab_resumo(vr_des_chave).cdagenci,3,'0')||'</pa>'
                                   ||'  <qtassoci>'||vr_tab_resumo(vr_des_chave).qtassoci||'</qtassoci>'
                                   ||'  <qtassepr>'||vr_tab_resumo(vr_des_chave).qtassepr||'</qtassepr>'
                                   ||'  <qtctacor>'||vr_tab_resumo(vr_des_chave).qtctacor||'</qtctacor>'
                                   ||'  <qtlansis>'||vr_tab_resumo(vr_des_chave).qtlansis||'</qtlansis>'
                                   ||'  <qtempres>'||vr_tab_resumo(vr_des_chave).qtempres||'</qtempres>'
                                   ||'  <qtepreac>'||vr_tab_resumo(vr_des_chave).qtepreac||'</qtepreac>'
                                   ||'  <qtaplrdc>'||vr_tab_resumo(vr_des_chave).qtaplrdc||'</qtaplrdc>'
                                   ||'  <qtaplrpp>'||vr_tab_resumo(vr_des_chave).qtaplrpp||'</qtaplrpp>'
                                   ||'  <qtassapl>'||vr_tab_resumo(vr_des_chave).qtassapl||'</qtassapl>'
                                   ||'  <qtplanos>'||vr_tab_resumo(vr_des_chave).qtplanos||'</qtplanos>'
                                   ||'  <vldespla>'||vr_tab_resumo(vr_des_chave).vldespla||'</vldespla>'
                                   ||'  <vldesepr>'||vr_tab_resumo(vr_des_chave).vldesepr||'</vldesepr>'
                                   ||'  <vlctrrpp>'||vr_tab_resumo(vr_des_chave).vlctrrpp||'</vlctrrpp>'
                                   ||'  <vlcaptal>'||vr_tab_resumo(vr_des_chave).vlcaptal||'</vlcaptal>'
                                   ||'  <vlsmpmes>'||vr_tab_resumo(vr_des_chave).vlsmpmes||'</vlsmpmes>'
                                   ||'  <vlempmes>'||vr_tab_resumo(vr_des_chave).vlempmes||'</vlempmes>'
                                   ||'  <vlepreac>'||vr_tab_resumo(vr_des_chave).vlepreac||'</vlepreac>'
                                   ||'  <vlaplrdc>'||vr_tab_resumo(vr_des_chave).vlaplrdc||'</vlaplrdc>'
                                   ||'  <vlaplrpp>'||vr_tab_resumo(vr_des_chave).vlaplrpp||'</vlaplrpp>'
                                   ||'  <vlcrefol>'||vr_tab_resumo(vr_des_chave).vlcrefol||'</vlcrefol>'
                                   ||'  <vldjuros>'||vr_tab_resumo(vr_des_chave).vldjuros||'</vldjuros>'
                                   ||'</pas>') ;
          -- Buscar o proximo
          vr_des_chave := vr_tab_resumo.NEXT(vr_des_chave);
        END LOOP;
      END;

      PROCEDURE pc_escreve_datas IS
      BEGIN
        vr_des_chave := vr_tab_data.first;
        WHILE vr_des_chave IS NOT NULL LOOP -- varre a tabela temporaria para montar xml
          --monta xml por pa
          pc_escreve_clob(vr_clobxml,'<datas>'
                                   ||'  <nmresage>'||vr_tab_data(vr_des_chave).nmresage||'</nmresage>'
                                   ||'  <data>'||vr_tab_data(vr_des_chave).dtrefere||'</data>'
                                   ||'  <qtassoci>'||vr_tab_data(vr_des_chave).qtassoci||'</qtassoci>'
                                   ||'  <qtassepr>'||vr_tab_data(vr_des_chave).qtassepr||'</qtassepr>'
                                   ||'  <qtctacor>'||vr_tab_data(vr_des_chave).qtctacor||'</qtctacor>'
                                   ||'  <qtlansis>'||vr_tab_data(vr_des_chave).qtlansis||'</qtlansis>'
                                   ||'  <qtempres>'||vr_tab_data(vr_des_chave).qtempres||'</qtempres>'
                                   ||'  <qtepreac>'||vr_tab_data(vr_des_chave).qtepreac||'</qtepreac>'
                                   ||'  <qtaplrdc>'||vr_tab_data(vr_des_chave).qtaplrdc||'</qtaplrdc>'
                                   ||'  <qtaplrpp>'||vr_tab_data(vr_des_chave).qtaplrpp||'</qtaplrpp>'
                                   ||'  <qtassapl>'||vr_tab_data(vr_des_chave).qtassapl||'</qtassapl>'
                                   ||'  <qtplanos>'||vr_tab_data(vr_des_chave).qtplanos||'</qtplanos>'
                                   ||'  <vldespla>'||vr_tab_data(vr_des_chave).vldespla||'</vldespla>'
                                   ||'  <vldesepr>'||vr_tab_data(vr_des_chave).vldesepr||'</vldesepr>'
                                   ||'  <vlctrrpp>'||vr_tab_data(vr_des_chave).vlctrrpp||'</vlctrrpp>'
                                   ||'  <vlcaptal>'||vr_tab_data(vr_des_chave).vlcaptal||'</vlcaptal>'
                                   ||'  <vlsmpmes>'||vr_tab_data(vr_des_chave).vlsmpmes||'</vlsmpmes>'
                                   ||'  <vlempmes>'||vr_tab_data(vr_des_chave).vlempmes||'</vlempmes>'
                                   ||'  <vlepreac>'||vr_tab_data(vr_des_chave).vlepreac||'</vlepreac>'
                                   ||'  <vlaplrdc>'||vr_tab_data(vr_des_chave).vlaplrdc||'</vlaplrdc>'
                                   ||'  <vlaplrpp>'||vr_tab_data(vr_des_chave).vlaplrpp||'</vlaplrpp>'
                                   ||'  <vlcrefol>'||vr_tab_data(vr_des_chave).vlcrefol||'</vlcrefol>'
                                   ||'  <vldjuros>'||vr_tab_data(vr_des_chave).vldjuros||'</vldjuros>'
                                   ||'</datas>') ;
          -- Buscar o proximo
          vr_des_chave := vr_tab_data.NEXT(vr_des_chave);
        END LOOP;
      END;


      PROCEDURE pc_carrega_info_cooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE
                                           ,pr_nmresage IN VARCHAR2
                                           ,pr_coop_cecred IN BOOLEAN) IS
      BEGIN
        -- Carregamos as informações do resumo para a cooperativa
        pc_carrega_resumo(pr_cdcooper,pr_nmresage);
        -- E as informações das datas
        pc_carrega_datas(pr_cdcooper,pr_nmresage,pr_coop_cecred);
      END;

      PROCEDURE pc_escreve_info_cooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE
                                           ,pr_coop_cecred IN BOOLEAN)IS
      BEGIN
        -- Geramos uma tag para a cooperativa, para agrupar as informações de cada uma
        pc_escreve_clob(vr_clobxml,'<cooperativa>');
        pc_escreve_clob(vr_clobxml,'<cdcooper>'|| pr_cdcooper||'</cdcooper>');
        IF NOT pr_coop_cecred THEN
          -- Somente vamos escrever as informações do resumo quando não for a CECRED
          -- para a CECRED é gerado uma listagem de totais para a data de cada cooperativa
          pc_escreve_resumo;
        END IF;
        -- Escrevemos as informações das datas para a cooperativa
        pc_escreve_datas;
        pc_escreve_clob(vr_clobxml,'</cooperativa>');
      END;

      PROCEDURE pc_gera_dados_gerais_coop  IS
      BEGIN
        BEGIN
          -- Geramos as informações da CECRED
          pc_carrega_info_cooperativa(pr_cdcooper,vr_nmresage,TRUE);
          pc_escreve_info_cooperativa(pr_cdcooper,TRUE);

          -- Busca todas as cooperativas, menos a CECRED
          -- Para gerar as demais informações
          FOR rw_crapcop2 IN cr_crapcop2
          LOOP
            vr_tab_resumo.DELETE;
            vr_tab_data.DELETE;

            OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop2.cdcooper);
            FETCH btch0001.cr_crapdat INTO rw_crapdat2;
            CLOSE btch0001.cr_crapdat;
            vr_dtrefere := to_date(to_char(rw_crapdat2.dtmvtolt,'mm')||
                                   to_char(rw_crapdat2.dtmvtolt,'dd')||
                                   to_number(to_char(rw_crapdat2.dtmvtolt,'yyyy')-1),'mmddyyyy');
            --calcula data referencia menos o dia calculado
            vr_dtrefere := vr_dtrefere - to_number(to_char(vr_dtrefere,'dd'));
            vr_dtrefere := vr_dtrefere - to_number(to_char(vr_dtrefere,'dd'));
            /* pega data do fim do mes */
            vr_dtfimmes := rw_crapdat2.dtmvtopr - to_number(to_char(rw_crapdat2.dtmvtopr,'dd'));

            vr_nmresage := 'GERAL       ' || upper(rw_crapcop2.nmrescop);
            -- Carregamos as informações para a cooperativa
            pc_carrega_info_cooperativa(rw_crapcop2.cdcooper,vr_nmresage,TRUE);
            -- e escrevemos esses dados no XML
            pc_escreve_info_cooperativa(rw_crapcop2.cdcooper,TRUE);
          END LOOP;
        END;
      END;

      --------------- VALIDACOES INICIAIS -----------------

    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

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
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;


      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      vr_nmarqim := '/crrl115.lst';
      --calcula data referencia com um ano a menos
      vr_dtrefere := to_date(to_char(rw_crapdat.dtmvtolt,'mm')||
                             to_char(rw_crapdat.dtmvtolt,'dd')||
                             to_number(to_char(rw_crapdat.dtmvtolt,'yyyy')-1),'mmddyyyy');
      --calucula data referencia menos o dia calculado
      vr_dtrefere := vr_dtrefere - to_number(to_char(vr_dtrefere,'dd'));
      vr_dtrefere := vr_dtrefere - to_number(to_char(vr_dtrefere,'dd'));
      /* pega data do fim do mes */
      vr_dtfimmes := rw_crapdat.dtmvtopr - to_number(to_char(rw_crapdat.dtmvtopr,'dd'));

      IF  pr_cdcooper = 3 THEN
        vr_nmresage := 'GERAL       ' || upper(rw_crapcop.nmrescop) ||'       DATA DE REFERENCIA: '||
                        to_char(vr_dtfimmes,'dd/mm/yyyy');
      ELSE
        vr_nmresage := 'GERAL       '||'       DATA DE REFERENCIA: '||
                       to_char(vr_dtfimmes,'dd/mm/yyyy');
      END IF;

      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- não for CECRED, traz informações Gerais da Coop
      IF  pr_cdcooper <> 3 THEN
          -- carregamos as informações da cooperativa
          pc_carrega_info_cooperativa(pr_cdcooper,vr_nmresage,FALSE);
          pc_escreve_info_cooperativa(pr_cdcooper,FALSE);
      ELSE
          -- carregamos as informações da CECRED e os totais das outras cooperativas
          pc_gera_dados_gerais_coop;
      END IF;
      pc_escreve_clob(vr_clobxml,'</raiz>');

      -- verificar qtd. copias
      IF  pr_cdcooper = 1 THEN
        vr_nrcopias := 5;
      ELSE
        vr_nrcopias := 4;
      END IF;
      --busca diretorio padrao da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');

      --gera relatorio crrl115.lst
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                              --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'                              --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl115.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||vr_nmarqim            --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 132 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234dh'                                   --> Nome do formulário para impressão
                                 ,pr_nrcopias  => vr_nrcopias                          --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_fldoscop  => 'S'
                                 ,pr_dscmaxcop => ' | tr -d "\032" '
                                 ,pr_dspathcop => gene0001.fn_diretorio(pr_tpdireto => 'M',pr_cdcooper => pr_cdcooper, pr_nmsubdir => 'contab')
                                 ,pr_des_erro  => vr_dscritic);                       --> Saída com erro

      IF vr_dscritic IS NOT NULL THEN
       -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps138;
/
