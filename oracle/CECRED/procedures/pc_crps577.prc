CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps577 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps577 (Fontes/crps577.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Henrique
       Data    : Setembro/2010.                     Ultima atualizacao: 27/10/2014

       Dados referentes ao programa:

       Frequencia: Mensal.
       Objetivo  : Atende a solicitacao 39. Ordem = 11.
                   Gera informacoes para o BNDES - 7019.
                   Relatorio 570.

       Alteracoes:

                20/10/2010 - Alteracao para buscar informacoes da crapvri
                             (Henrique).

                21/03/2011 - Buscar informaçoes somente da base do Risco crapvri
                             (Irlan)

                17/09/2012 - Efetuado quebra de relatório por singular (Tiago).

                19/05/2014 - Conversão Progress >> Oracle (Edison - AMcom)

                23/05/2014 - Ajustado para converter o relatorio(ux2dos) antes de envia-lo por e-mail(Odirlei-AMcom)

                27/10/2014 - Alterado pr_flg_impri de 'N' para 'S' (Lucas R.)
    ............................................................................. */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS577';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca todas as cooperativas, com excecao da cooperativa atual
      -- que possuem riscos calculados no último dia do mes anterior
      -- a data do movimento
      CURSOR cr_crapcop_II( pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtultdma IN DATE) IS
        SELECT crapcop.cdcooper
              ,crapcop.nmrescop
              ,crapcop.nmextcop
              ,crapvri.cdvencto
              ,crapvri.vldivida
              ,count(1) over (partition by crapcop.cdcooper ) totreg
              ,row_number() over (partition by crapcop.cdcooper
                                  order by crapcop.cdcooper) nrseq
        FROM  crapvri
              ,crapcop
        WHERE crapvri.cdcooper = crapcop.cdcooper
        AND   crapcop.cdcooper <> pr_cdcooper
        /*** Risco e gerado com o ultimo dia do mes ***/
        AND   crapvri.dtrefere = pr_dtultdma
        AND   crapvri.cdvencto NOT IN (310,320,330) --Despreza contratos em prejuizo
        ORDER BY crapcop.cdcooper;


      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      --Estrutura de registro
      TYPE typ_reg_conteudo IS
        RECORD( nrconta VARCHAR2(15)
               ,dsconta VARCHAR2(100));
      --Tipo de registro
      TYPE typ_tab_conteudo IS TABLE OF typ_reg_conteudo INDEX BY VARCHAR2(100);
      --tabela temporaria para armazenar as contas do relatorio
      vr_tab_conteudo typ_tab_conteudo;

      ------------------------------- VARIAVEIS -------------------------------
      --vetores
      vr_vet_total      dbms_sql.Number_Table;
      vr_vet_campo      dbms_sql.Number_Table;
      vr_vet_industria  dbms_sql.Number_Table;
      vr_vet_comercio   dbms_sql.Number_Table;
      vr_vet_financeiro dbms_sql.Number_Table;
      vr_vet_outrosserv dbms_sql.Number_Table;
      vr_vet_pes_fisica dbms_sql.Number_Table;
      vr_vet_habitacao  dbms_sql.Number_Table;
      vr_vet_linha_tt   dbms_sql.Number_Table;
      --vetores
      vr_vet_total_sing      dbms_sql.Number_Table;
      vr_vet_campo_sing      dbms_sql.Number_Table;
      vr_vet_industria_sing  dbms_sql.Number_Table;
      vr_vet_comercio_sing   dbms_sql.Number_Table;
      vr_vet_financeiro_sing dbms_sql.Number_Table;
      vr_vet_outrosserv_sing dbms_sql.Number_Table;
      vr_vet_pes_fisica_sing dbms_sql.Number_Table;
      vr_vet_habitacao_sing  dbms_sql.Number_Table;
      vr_vet_linha_tt_sing   dbms_sql.Number_Table;
      --controle de escrita no arquivo
      vr_xml             CLOB;
      vr_texto_completo  VARCHAR2(32600);
      --outras
      vr_prazo           INTEGER;
      vr_nrconta         VARCHAR2(100);
      vr_dsdircop        VARCHAR2(500);
      vr_dsmailcop       VARCHAR2(4000);
      vr_nmarqimp        VARCHAR2(100);

      --------------------------- SUBROTINAS INTERNAS --------------------------
    BEGIN
      --------------- VALIDACOES INICIAIS -----------------

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
      --limpando a tabela temporaria
      vr_tab_conteudo.delete;

      --caregando temporaria que contém as contas que serão exibidas no relatório
      vr_tab_conteudo('00.1.1.00.00.00').dsconta := 'SETOR PUBLICO FEDERAL';
      vr_tab_conteudo('00.1.1.01.00.00').dsconta := 'GOVERNO';
      vr_tab_conteudo('00.1.1.01.01.00').dsconta := 'ADMINISTRACAO DIRETA';
      vr_tab_conteudo('00.1.1.01.02.00').dsconta := 'ADMINISTRACAO INDIRETA';
      vr_tab_conteudo('00.1.1.02.00.00').dsconta := 'ATIVIDADES EMPRESARIAIS';
      vr_tab_conteudo('00.1.1.02.01.00').dsconta := 'INDUSTRIA';
      vr_tab_conteudo('00.1.1.02.02.00').dsconta := 'COMERCIO';
      vr_tab_conteudo('00.1.1.02.03.00').dsconta := 'INTERMEDIARIOS FINANCEIROS';
      vr_tab_conteudo('00.1.2.00.00.00').dsconta := 'SETOR PUBLICO ESTADUTAL';
      vr_tab_conteudo('00.1.2.01.00.00').dsconta := 'GOVERNO';
      vr_tab_conteudo('00.1.2.01.01.00').dsconta := 'ADMINISTRACAO DIRETA';
      vr_tab_conteudo('00.1.2.01.02.00').dsconta := 'ADMINISTRACAO INDIRETA';
      vr_tab_conteudo('00.1.2.02.00.00').dsconta := 'ATIVIDADES EMPRESARIAIS';
      vr_tab_conteudo('00.1.2.02.01.00').dsconta := 'INDUSTRIA';
      vr_tab_conteudo('00.1.2.02.02.00').dsconta := 'COMERCIO';
      vr_tab_conteudo('00.1.2.02.03.00').dsconta := 'INTERMEDIARIOS FINANCEIROS';
      vr_tab_conteudo('00.1.2.02.04.00').dsconta := 'OUTROS SERVICOS';
      vr_tab_conteudo('00.1.3.00.00.00').dsconta := 'SETOR PUBLICO MUNICIPAL';
      vr_tab_conteudo('00.1.3.01.00.00').dsconta := 'GOVERNO';
      vr_tab_conteudo('00.1.3.01.01.00').dsconta := 'ADMINISTRACAO DIRETA';
      vr_tab_conteudo('00.1.3.01.02.00').dsconta := 'ADMINISTRACAO INDIRETA';
      vr_tab_conteudo('00.1.3.02.00.00').dsconta := 'ATIVIDADES EMPRESARIAIS';
      vr_tab_conteudo('00.1.3.02.01.00').dsconta := 'INDUSTRIA';
      vr_tab_conteudo('00.1.3.02.02.00').dsconta := 'COMERCIO';
      vr_tab_conteudo('00.1.3.02.03.00').dsconta := 'INTERMEDIARIOS FINANCEIROS';
      vr_tab_conteudo('00.1.3.02.04.00').dsconta := 'OUTROS SERVICOS';
      vr_tab_conteudo('00.1.4.00.00.00').dsconta := 'SETOR PRIVADO';
      vr_tab_conteudo('00.1.4.01.00.00').dsconta := 'RURAL';
      vr_tab_conteudo('00.1.4.02.00.00').dsconta := 'INDUSTRIA';
      vr_tab_conteudo('00.1.4.03.00.00').dsconta := 'COMERCIO';
      vr_tab_conteudo('00.1.4.04.00.00').nrconta := '00.1.4.00.00.00';
      vr_tab_conteudo('00.1.4.04.00.00').dsconta := 'INTERMEDIOS FINANCEIROS';
      vr_tab_conteudo('00.1.4.05.00.00').dsconta := 'OUTROS SERVICOS';
      vr_tab_conteudo('00.1.4.06.00.00').dsconta := 'PESSOAS FISICAS';
      vr_tab_conteudo('00.1.4.07.00.00').dsconta := 'HABITACAO';
      vr_tab_conteudo('00.1.5.00.00.00').dsconta := 'NAO RESIDENTES';
      vr_tab_conteudo('00.1.9.00.00.00').nrconta := '00.1.0.00.00.00';
      vr_tab_conteudo('00.1.9.00.00.00').dsconta := 'TOTAL';

      --nome do relatorio
      vr_nmarqimp := 'crrl570.lst';

      --inicializando os vetores em 20 posicoes
      FOR vr_cont IN 1 .. 20 LOOP
        vr_vet_total(vr_cont)     := 0;
        vr_vet_campo(vr_cont)     := 0;
        vr_vet_industria(vr_cont) := 0;
        vr_vet_comercio(vr_cont)  := 0;
        vr_vet_financeiro(vr_cont):= 0;
        vr_vet_outrosserv(vr_cont):= 0;
        vr_vet_pes_fisica(vr_cont):= 0;
        vr_vet_habitacao(vr_cont) := 0;
        vr_vet_linha_tt(vr_cont)  := 0;

        vr_vet_total_sing(vr_cont)     := 0;
        vr_vet_campo_sing(vr_cont)     := 0;
        vr_vet_industria_sing(vr_cont) := 0;
        vr_vet_comercio_sing(vr_cont)  := 0;
        vr_vet_financeiro_sing(vr_cont):= 0;
        vr_vet_outrosserv_sing(vr_cont):= 0;
        vr_vet_pes_fisica_sing(vr_cont):= 0;
        vr_vet_habitacao_sing(vr_cont) := 0;
        vr_vet_linha_tt_sing(vr_cont)  := 0;
      END LOOP;

      -- Inicializar CLOB
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

      --Inicializa o xml
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                             '<?xml version="1.0" encoding="utf-8"?>'||
                             '<root dtmvtoan="'||TO_CHAR(rw_crapdat.dtmvtoan,'DD/MM/YYYY')||'">'||chr(13));

      --Todas as cooperativas com excecao da cooperativa conectada
      FOR rw_crapcop_II IN cr_crapcop_II( pr_cdcooper => pr_cdcooper
                                         ,pr_dtultdma => rw_crapdat.dtultdma) -- Ultimo dia do mes anterior
      LOOP
        /** Quando o credito esta vencido, define como prazo "15 dias" **/
        IF rw_crapcop_II.cdvencto IN (205,210,220,230,240,245,250,255,260,270,280,290) THEN
          vr_vet_campo(1)      := vr_vet_campo(1)      + rw_crapcop_II.vldivida;
          vr_vet_campo_sing(1) := vr_vet_campo_sing(1) + rw_crapcop_II.vldivida;
        /** Verifica o prazo e armazena na variavel **/
        ELSIF rw_crapcop_II.cdvencto <= 130 THEN
          vr_vet_total(1)      := vr_vet_total(1)      + rw_crapcop_II.vldivida;
          vr_vet_total_sing(1) := vr_vet_total_sing(1) + rw_crapcop_II.vldivida;
        ELSIF rw_crapcop_II.cdvencto = 140 THEN
          vr_vet_total(2)      := vr_vet_total(2)      + rw_crapcop_II.vldivida;
          vr_vet_total_sing(2) := vr_vet_total_sing(2) + rw_crapcop_II.vldivida;
        ELSIF rw_crapcop_II.cdvencto = 150 THEN
          vr_vet_total(4)      := vr_vet_total(4)      + rw_crapcop_II.vldivida;
          vr_vet_total_sing(4) := vr_vet_total_sing(4) + rw_crapcop_II.vldivida;
        ELSIF rw_crapcop_II.cdvencto = 160 THEN
          vr_vet_total(5)      := vr_vet_total(5)      + rw_crapcop_II.vldivida;
          vr_vet_total_sing(5) := vr_vet_total_sing(5) + rw_crapcop_II.vldivida;
        ELSIF rw_crapcop_II.cdvencto = 165 THEN
          vr_vet_total(6)      := vr_vet_total(6)      + rw_crapcop_II.vldivida;
          vr_vet_total_sing(6) := vr_vet_total_sing(6) + rw_crapcop_II.vldivida;
        ELSIF rw_crapcop_II.cdvencto = 170 THEN
          vr_vet_total(7)      := vr_vet_total(7)      + rw_crapcop_II.vldivida;
          vr_vet_total_sing(7) := vr_vet_total_sing(7) + rw_crapcop_II.vldivida;
        ELSIF rw_crapcop_II.cdvencto = 175 THEN
          vr_vet_total(8)      := vr_vet_total(8)      + rw_crapcop_II.vldivida;
          vr_vet_total_sing(8) := vr_vet_total_sing(8) + rw_crapcop_II.vldivida;
        ELSIF rw_crapcop_II.cdvencto = 180 THEN
          vr_vet_total(9)      := vr_vet_total(9)      + rw_crapcop_II.vldivida;
          vr_vet_total_sing(9) := vr_vet_total_sing(9) + rw_crapcop_II.vldivida;
        ELSIF rw_crapcop_II.cdvencto = 190 THEN
          vr_vet_total(10)     := vr_vet_total(10)      + rw_crapcop_II.vldivida;
          vr_vet_total_sing(10):= vr_vet_total_sing(10) + rw_crapcop_II.vldivida;
        END IF;

        /*Impressao das singulares*/
        --LAST-OF(crapcop.cdcooper)
        IF rw_crapcop_II.nrseq = rw_crapcop_II.totreg THEN

          vr_vet_campo_sing(1) :=  vr_vet_campo_sing(1)  / 1000;
          vr_vet_campo_sing(2) :=  vr_vet_total_sing(1)  / 1000;
          vr_vet_campo_sing(3) := (vr_vet_total_sing(2)  + vr_vet_total_sing(4))  / 1000;
          vr_vet_campo_sing(4) := (vr_vet_total_sing(5)  + vr_vet_total_sing(6)) / 1000;
          vr_vet_campo_sing(5) := (vr_vet_total_sing(7)  + vr_vet_total_sing(8)) / 1000;
          vr_vet_campo_sing(6) :=  vr_vet_total_sing(9)  / 1000;
          vr_vet_campo_sing(7) :=  vr_vet_total_sing(10) / 1000;

          vr_prazo := 1;
          LOOP
            EXIT WHEN vr_prazo > 7;

            /** Dados que irao na linha INDUSTRIA **/
            vr_vet_industria_sing(vr_prazo) := (vr_vet_campo_sing(vr_prazo) * 0.093)  +
                                               (vr_vet_campo_sing(vr_prazo) * 0.0621) +
                                               (vr_vet_campo_sing(vr_prazo) * 0.0621) +
                                               (vr_vet_campo_sing(vr_prazo) * 0.1378) +
                                               (vr_vet_campo_sing(vr_prazo) * 0.01);
            /** Dados que irao na linha COMERCIO **/
            vr_vet_comercio_sing(vr_prazo)   := (vr_vet_campo_sing(vr_prazo) * 0.2803);

            /** Dados que irao na linha INTERMEDIARIOS FINANCEIROS **/
            vr_vet_financeiro_sing(vr_prazo) := (vr_vet_campo_sing(vr_prazo) * 0.0269);

            /** Dados que irao na linha OUTROS SERVICOS **/
            vr_vet_outrosserv_sing(vr_prazo) := (vr_vet_campo_sing(vr_prazo) * 0.0143) +
                                                    (vr_vet_campo_sing(vr_prazo) * 0.0519) +
                                                    (vr_vet_campo_sing(vr_prazo) * 0.1002);

            /** Dados que irao na linha PESSOAS FISICAS **/
            vr_vet_pes_fisica_sing(vr_prazo) := (vr_vet_campo_sing(vr_prazo) * 0.096);

            /** Dados que irao na linha HABITACAO **/
            vr_vet_habitacao_sing(vr_prazo)  := (vr_vet_campo_sing(vr_prazo) * 0.0654);

            /** Dados que irao na linha TOTAL **/
            vr_vet_linha_tt_sing(vr_prazo)   := vr_vet_campo_sing(vr_prazo);


            vr_prazo := vr_prazo + 1;
          END LOOP;

          --Escreve no xml
          gene0002.pc_escreve_xml(vr_xml,
                                  vr_texto_completo,
                                 '<cooper cdcooper="'||rw_crapcop_II.cdcooper||'" '||
                                         'nmrescop="'||rw_crapcop_II.nmrescop||'">'||chr(13));

          --posiciona no primeiro registro da temptable
          vr_nrconta := vr_tab_conteudo.first;
          LOOP
            --sai do loop quando encontrar o ultimo registro
            EXIT WHEN vr_nrconta IS NULL;

            --conta
            CASE vr_nrconta
              WHEN '00.1.4.00.00.00' THEN /* Linha SETOR PRIVADO */
                --Escreve no xml
                gene0002.pc_escreve_xml(vr_xml,
                                        vr_texto_completo,
                                       '<conta nrconta="'||vr_nrconta||'" '||
                                               'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                       '<vencida15>'  ||TO_CHAR(vr_vet_campo_sing(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                       '<vencer3m>'   ||TO_CHAR(vr_vet_campo_sing(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                       '<vencer3x12m>'||TO_CHAR(vr_vet_campo_sing(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                       '<vencer1x3a>' ||TO_CHAR(vr_vet_campo_sing(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                       '<vencer3x5a>' ||TO_CHAR(vr_vet_campo_sing(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                       '<vencer5x15a>'||TO_CHAR(vr_vet_campo_sing(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                       '<vencer15a>'  ||TO_CHAR(vr_vet_campo_sing(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

              WHEN '00.1.4.02.00.00' THEN /* Linha INDUSTRIA */
                --Escreve no xml
                gene0002.pc_escreve_xml(vr_xml,
                                        vr_texto_completo,
                                       '<conta nrconta="'||vr_nrconta||'" '||
                                               'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                       '<vencida15>'  ||TO_CHAR(vr_vet_industria_sing(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                       '<vencer3m>'   ||TO_CHAR(vr_vet_industria_sing(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                       '<vencer3x12m>'||TO_CHAR(vr_vet_industria_sing(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                       '<vencer1x3a>' ||TO_CHAR(vr_vet_industria_sing(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                       '<vencer3x5a>' ||TO_CHAR(vr_vet_industria_sing(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                       '<vencer5x15a>'||TO_CHAR(vr_vet_industria_sing(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                       '<vencer15a>'  ||TO_CHAR(vr_vet_industria_sing(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));
              WHEN '00.1.4.03.00.00' THEN /* Linha COMERCIO */
                --Escreve no xml
                gene0002.pc_escreve_xml(vr_xml,
                                        vr_texto_completo,
                                       '<conta nrconta="'||vr_nrconta||'" '||
                                               'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                       '<vencida15>'  ||TO_CHAR(vr_vet_comercio_sing(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                       '<vencer3m>'   ||TO_CHAR(vr_vet_comercio_sing(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                       '<vencer3x12m>'||TO_CHAR(vr_vet_comercio_sing(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                       '<vencer1x3a>' ||TO_CHAR(vr_vet_comercio_sing(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                       '<vencer3x5a>' ||TO_CHAR(vr_vet_comercio_sing(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                       '<vencer5x15a>'||TO_CHAR(vr_vet_comercio_sing(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                       '<vencer15a>'  ||TO_CHAR(vr_vet_comercio_sing(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

              WHEN '00.1.4.04.00.00' THEN /* Linha INFERMEDIOS FINANCEIROS*/
                --Escreve no xml
                gene0002.pc_escreve_xml(vr_xml,
                                        vr_texto_completo,
                                       '<conta nrconta="'||vr_tab_conteudo(vr_nrconta).nrconta||'" '||
                                               'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                       '<vencida15>'  ||TO_CHAR(vr_vet_financeiro_sing(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                       '<vencer3m>'   ||TO_CHAR(vr_vet_financeiro_sing(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                       '<vencer3x12m>'||TO_CHAR(vr_vet_financeiro_sing(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                       '<vencer1x3a>' ||TO_CHAR(vr_vet_financeiro_sing(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                       '<vencer3x5a>' ||TO_CHAR(vr_vet_financeiro_sing(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                       '<vencer5x15a>'||TO_CHAR(vr_vet_financeiro_sing(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                       '<vencer15a>'  ||TO_CHAR(vr_vet_financeiro_sing(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));
              WHEN '00.1.4.05.00.00' THEN /* Linha OUTROS SERVICOS */
                --Escreve no xml
                gene0002.pc_escreve_xml(vr_xml,
                                        vr_texto_completo,
                                       '<conta nrconta="'||vr_nrconta||'" '||
                                               'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                       '<vencida15>'  ||TO_CHAR(vr_vet_outrosserv_sing(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                       '<vencer3m>'   ||TO_CHAR(vr_vet_outrosserv_sing(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                       '<vencer3x12m>'||TO_CHAR(vr_vet_outrosserv_sing(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                       '<vencer1x3a>' ||TO_CHAR(vr_vet_outrosserv_sing(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                       '<vencer3x5a>' ||TO_CHAR(vr_vet_outrosserv_sing(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                       '<vencer5x15a>'||TO_CHAR(vr_vet_outrosserv_sing(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                       '<vencer15a>'  ||TO_CHAR(vr_vet_outrosserv_sing(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

              WHEN '00.1.4.06.00.00' THEN /* Linha PESSOAS FISICAS */
                --Escreve no xml
                gene0002.pc_escreve_xml(vr_xml,
                                        vr_texto_completo,
                                       '<conta nrconta="'||vr_nrconta||'" '||
                                               'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                       '<vencida15>'  ||TO_CHAR(vr_vet_pes_fisica_sing(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                       '<vencer3m>'   ||TO_CHAR(vr_vet_pes_fisica_sing(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                       '<vencer3x12m>'||TO_CHAR(vr_vet_pes_fisica_sing(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                       '<vencer1x3a>' ||TO_CHAR(vr_vet_pes_fisica_sing(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                       '<vencer3x5a>' ||TO_CHAR(vr_vet_pes_fisica_sing(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                       '<vencer5x15a>'||TO_CHAR(vr_vet_pes_fisica_sing(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                       '<vencer15a>'  ||TO_CHAR(vr_vet_pes_fisica_sing(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

              WHEN '00.1.4.07.00.00' THEN /* Linha HABITACAO */
                --Escreve no xml
                gene0002.pc_escreve_xml(vr_xml,
                                        vr_texto_completo,
                                       '<conta nrconta="'||vr_nrconta||'" '||
                                               'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                       '<vencida15>'||TO_CHAR(vr_vet_habitacao_sing(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                       '<vencer3m>'||TO_CHAR(vr_vet_habitacao_sing(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                       '<vencer3x12m>'||TO_CHAR(vr_vet_habitacao_sing(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                       '<vencer1x3a>'||TO_CHAR(vr_vet_habitacao_sing(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                       '<vencer3x5a>'||TO_CHAR(vr_vet_habitacao_sing(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                       '<vencer5x15a>'||TO_CHAR(vr_vet_habitacao_sing(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                       '<vencer15a>'||TO_CHAR(vr_vet_habitacao_sing(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

              WHEN '00.1.9.00.00.00' THEN  /* Linha TOTAL */
                --Escreve no xml
                gene0002.pc_escreve_xml(vr_xml,
                                        vr_texto_completo,
                                       '<conta nrconta="'||vr_tab_conteudo(vr_nrconta).nrconta||'" '||
                                               'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                       '<vencida15>'  ||TO_CHAR(vr_vet_linha_tt_sing(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                       '<vencer3m>'   ||TO_CHAR(vr_vet_linha_tt_sing(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                       '<vencer3x12m>'||TO_CHAR(vr_vet_linha_tt_sing(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                       '<vencer1x3a>' ||TO_CHAR(vr_vet_linha_tt_sing(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                       '<vencer3x5a>' ||TO_CHAR(vr_vet_linha_tt_sing(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                       '<vencer5x15a>'||TO_CHAR(vr_vet_linha_tt_sing(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                       '<vencer15a>'  ||TO_CHAR(vr_vet_linha_tt_sing(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

              ELSE
                --Escreve no xml
                gene0002.pc_escreve_xml(vr_xml,
                                        vr_texto_completo,
                                       '<conta nrconta="'||vr_nrconta||'" '||
                                               'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                       '<vencida15>'  ||'-'||'</vencida15>'||
                                       '<vencer3m>'   ||'-'||'</vencer3m>'||
                                       '<vencer3x12m>'||'-'||'</vencer3x12m>'||
                                       '<vencer1x3a>' ||'-'||'</vencer1x3a>'||
                                       '<vencer3x5a>' ||'-'||'</vencer3x5a>'||
                                       '<vencer5x15a>'||'-'||'</vencer5x15a>'||
                                       '<vencer15a>'  ||'-'||'</vencer15a></conta>'||chr(13));
            END CASE;

            --vai para o proximo registro da tabela temporaria
            vr_nrconta := vr_tab_conteudo.next(vr_nrconta);
          END LOOP;

          --reinicializando os vetores
          FOR vr_cont IN 1 .. 10 LOOP
            vr_vet_campo_sing(vr_cont)      := 0;
            vr_vet_industria_sing(vr_cont)  := 0;
            vr_vet_comercio_sing(vr_cont)   := 0;
            vr_vet_financeiro_sing(vr_cont) := 0;
            vr_vet_outrosserv_sing(vr_cont) := 0;
            vr_vet_pes_fisica_sing(vr_cont) := 0;
            vr_vet_habitacao_sing(vr_cont)  := 0;
            vr_vet_linha_tt_sing(vr_cont)   := 0;
            vr_vet_total_sing(vr_cont)      := 0;
          END LOOP;
          --Escreve no xml
          gene0002.pc_escreve_xml(vr_xml,
                                  vr_texto_completo,
                                  '</cooper>'||chr(13));
        END IF;
      END LOOP; /*** Fim for each crapcop ***/
      /*** ........... Fim da busca de informacoes para o relatorio ............. ***/

      /*Com o uso da crapvri, o array aux_total tera informacoes somente nas
        seguintes posicoes:
        aux_total[1]  - Ate 3 meses
        aux_total[2]  - 3 a 12 meses
        aux_total[4]  - 3 a 12 meses
        aux_total[5]  - 1 a 3 anos
        aux_total[6]  - 1 a 3 anos
        aux_total[7]  - 3 a 5 anos
        aux_total[8]  - 3 a 5 anos
        aux_total[9] - 5 a 15 anos
        aux_total[10] - acima de 15 anos
      */

      /** Dados que irao na linha SETOR PRIVADO E TOTAL  **/
      vr_vet_campo(1) :=  vr_vet_campo(1)  / 1000;
      vr_vet_campo(2) :=  vr_vet_total(1)  / 1000;
      vr_vet_campo(3) := (vr_vet_total(2)  + vr_vet_total(4)) / 1000;
      vr_vet_campo(4) := (vr_vet_total(5)  + vr_vet_total(6)) / 1000;
      vr_vet_campo(5) := (vr_vet_total(7)  + vr_vet_total(8)) / 1000;
      vr_vet_campo(6) :=  vr_vet_total(9) / 1000;
      vr_vet_campo(7) :=  vr_vet_total(10) / 1000;

      --inicializa a variavel de controle
      vr_prazo := 1;

      LOOP
        --sai do loop quando ultrapassar 7.
        EXIT WHEN vr_prazo > 7;

        /** Dados que irao na linha INDUSTRIA **/
        vr_vet_industria(vr_prazo) := (vr_vet_campo(vr_prazo) * 0.093)  +
                                      (vr_vet_campo(vr_prazo) * 0.0621) +
                                      (vr_vet_campo(vr_prazo) * 0.0621) +
                                      (vr_vet_campo(vr_prazo) * 0.1378) +
                                      (vr_vet_campo(vr_prazo) * 0.01);

        /** Dados que irao na linha COMERCIO **/
        vr_vet_comercio(vr_prazo)  := (vr_vet_campo(vr_prazo) * 0.2803);

        /** Dados que irao na linha INTERMEDIARIOS FINANCEIROS **/
        vr_vet_financeiro(vr_prazo):= (vr_vet_campo(vr_prazo) * 0.0269);

        /** Dados que irao na linha OUTROS SERVICOS **/
        vr_vet_outrosserv(vr_prazo):= (vr_vet_campo(vr_prazo) * 0.0143) +
                                      (vr_vet_campo(vr_prazo) * 0.0519) +
                                      (vr_vet_campo(vr_prazo) * 0.1002);

        /** Dados que irao na linha PESSOAS FISICAS **/
        vr_vet_pes_fisica(vr_prazo):= (vr_vet_campo(vr_prazo) * 0.096);

        /** Dados que irao na linha HABITACAO **/
        vr_vet_habitacao(vr_prazo) := (vr_vet_campo(vr_prazo) * 0.0654);

        /** Dados que irao na linha TOTAL **/
        vr_vet_linha_tt(vr_prazo)  := vr_vet_campo(vr_prazo);

        vr_prazo := vr_prazo + 1;

      END LOOP; /* End repeat */

      --Escreve no xml
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                             '<cooper cdcooper="0" nmrescop="TODAS">'||chr(13));

      --posiciona no primeiro registro da temptable
      vr_nrconta := vr_tab_conteudo.first;
      LOOP
        --sai do loop quando encontrar o ultimo registro
        EXIT WHEN vr_nrconta IS NULL;

        --conta
        CASE vr_nrconta
          WHEN '00.1.4.00.00.00' THEN /* Linha SETOR PRIVADO */
            --Escreve no xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                   '<conta nrconta="'||vr_nrconta||'" '||
                                           'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                   '<vencida15>'  ||TO_CHAR(vr_vet_campo(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                   '<vencer3m>'   ||TO_CHAR(vr_vet_campo(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                   '<vencer3x12m>'||TO_CHAR(vr_vet_campo(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                   '<vencer1x3a>' ||TO_CHAR(vr_vet_campo(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                   '<vencer3x5a>' ||TO_CHAR(vr_vet_campo(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                   '<vencer5x15a>'||TO_CHAR(vr_vet_campo(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                   '<vencer15a>'  ||TO_CHAR(vr_vet_campo(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

          WHEN '00.1.4.02.00.00' THEN /* Linha INDUSTRIA */
            --Escreve no xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                   '<conta nrconta="'||vr_nrconta||'" '||
                                           'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                   '<vencida15>'  ||TO_CHAR(vr_vet_industria(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                   '<vencer3m>'   ||TO_CHAR(vr_vet_industria(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                   '<vencer3x12m>'||TO_CHAR(vr_vet_industria(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                   '<vencer1x3a>' ||TO_CHAR(vr_vet_industria(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                   '<vencer3x5a>' ||TO_CHAR(vr_vet_industria(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                   '<vencer5x15a>'||TO_CHAR(vr_vet_industria(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                   '<vencer15a>'  ||TO_CHAR(vr_vet_industria(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));
          WHEN '00.1.4.03.00.00' THEN /* Linha COMERCIO */
            --Escreve no xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                   '<conta nrconta="'||vr_nrconta||'" '||
                                           'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                   '<vencida15>'  ||TO_CHAR(vr_vet_comercio(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                   '<vencer3m>'   ||TO_CHAR(vr_vet_comercio(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                   '<vencer3x12m>'||TO_CHAR(vr_vet_comercio(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                   '<vencer1x3a>' ||TO_CHAR(vr_vet_comercio(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                   '<vencer3x5a>' ||TO_CHAR(vr_vet_comercio(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                   '<vencer5x15a>'||TO_CHAR(vr_vet_comercio(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                   '<vencer15a>'  ||TO_CHAR(vr_vet_comercio(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

          WHEN '00.1.4.04.00.00' THEN /* Linha INFERMEDIOS FINANCEIROS*/
            --Escreve no xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                   '<conta nrconta="'||vr_tab_conteudo(vr_nrconta).nrconta||'" '||
                                           'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                   '<vencida15>'  ||TO_CHAR(vr_vet_financeiro(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                   '<vencer3m>'   ||TO_CHAR(vr_vet_financeiro(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                   '<vencer3x12m>'||TO_CHAR(vr_vet_financeiro(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                   '<vencer1x3a>' ||TO_CHAR(vr_vet_financeiro(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                   '<vencer3x5a>' ||TO_CHAR(vr_vet_financeiro(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                   '<vencer5x15a>'||TO_CHAR(vr_vet_financeiro(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                   '<vencer15a>'  ||TO_CHAR(vr_vet_financeiro(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));
          WHEN '00.1.4.05.00.00' THEN /* Linha OUTROS SERVICOS */
            --Escreve no xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                   '<conta nrconta="'||vr_nrconta||'" '||
                                           'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                   '<vencida15>'  ||TO_CHAR(vr_vet_outrosserv(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                   '<vencer3m>'   ||TO_CHAR(vr_vet_outrosserv(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                   '<vencer3x12m>'||TO_CHAR(vr_vet_outrosserv(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                   '<vencer1x3a>' ||TO_CHAR(vr_vet_outrosserv(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                   '<vencer3x5a>' ||TO_CHAR(vr_vet_outrosserv(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                   '<vencer5x15a>'||TO_CHAR(vr_vet_outrosserv(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                   '<vencer15a>'  ||TO_CHAR(vr_vet_outrosserv(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

          WHEN '00.1.4.06.00.00' THEN /* Linha PESSOAS FISICAS */
            --Escreve no xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                   '<conta nrconta="'||vr_nrconta||'" '||
                                           'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                   '<vencida15>'  ||TO_CHAR(vr_vet_pes_fisica(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                   '<vencer3m>'   ||TO_CHAR(vr_vet_pes_fisica(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                   '<vencer3x12m>'||TO_CHAR(vr_vet_pes_fisica(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                   '<vencer1x3a>' ||TO_CHAR(vr_vet_pes_fisica(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                   '<vencer3x5a>' ||TO_CHAR(vr_vet_pes_fisica(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                   '<vencer5x15a>'||TO_CHAR(vr_vet_pes_fisica(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                   '<vencer15a>'  ||TO_CHAR(vr_vet_pes_fisica(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

          WHEN '00.1.4.07.00.00' THEN /* Linha HABITACAO */
            --Escreve no xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                   '<conta nrconta="'||vr_nrconta||'" '||
                                           'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                   '<vencida15>'  ||TO_CHAR(vr_vet_habitacao(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                   '<vencer3m>'   ||TO_CHAR(vr_vet_habitacao(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                   '<vencer3x12m>'||TO_CHAR(vr_vet_habitacao(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                   '<vencer1x3a>' ||TO_CHAR(vr_vet_habitacao(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                   '<vencer3x5a>' ||TO_CHAR(vr_vet_habitacao(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                   '<vencer5x15a>'||TO_CHAR(vr_vet_habitacao(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                   '<vencer15a>'  ||TO_CHAR(vr_vet_habitacao(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

          WHEN '00.1.9.00.00.00' THEN  /* Linha TOTAL */
            --Escreve no xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                   '<conta nrconta="'||vr_tab_conteudo(vr_nrconta).nrconta||'" '||
                                           'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                   '<vencida15>'  ||TO_CHAR(vr_vet_linha_tt(1),'fm999G999G999G990D00mi')||'</vencida15>'||
                                   '<vencer3m>'   ||TO_CHAR(vr_vet_linha_tt(2),'fm999G999G999G990D00mi')||'</vencer3m>'||
                                   '<vencer3x12m>'||TO_CHAR(vr_vet_linha_tt(3),'fm999G999G999G990D00mi')||'</vencer3x12m>'||
                                   '<vencer1x3a>' ||TO_CHAR(vr_vet_linha_tt(4),'fm999G999G999G990D00mi')||'</vencer1x3a>'||
                                   '<vencer3x5a>' ||TO_CHAR(vr_vet_linha_tt(5),'fm999G999G999G990D00mi')||'</vencer3x5a>'||
                                   '<vencer5x15a>'||TO_CHAR(vr_vet_linha_tt(6),'fm999G999G999G990D00mi')||'</vencer5x15a>'||
                                   '<vencer15a>'  ||TO_CHAR(vr_vet_linha_tt(7),'fm999G999G999G990D00mi')||'</vencer15a></conta>'||chr(13));

          ELSE
            --Escreve no xml
            gene0002.pc_escreve_xml(vr_xml,
                                    vr_texto_completo,
                                   '<conta nrconta="'||vr_nrconta||'" '||
                                           'dsconta="'||vr_tab_conteudo(vr_nrconta).dsconta||'">'||
                                   '<vencida15>'  ||'-'||'</vencida15>'||
                                   '<vencer3m>'   ||'-'||'</vencer3m>'||
                                   '<vencer3x12m>'||'-'||'</vencer3x12m>'||
                                   '<vencer1x3a>' ||'-'||'</vencer1x3a>'||
                                   '<vencer3x5a>' ||'-'||'</vencer3x5a>'||
                                   '<vencer5x15a>'||'-'||'</vencer5x15a>'||
                                   '<vencer15a>'  ||'-'||'</vencer15a></conta>'||chr(13));
        END CASE;

        --vai para o proximo registro da tabela temporaria
        vr_nrconta := vr_tab_conteudo.next(vr_nrconta);
      END LOOP;

      --Escreve no xml
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                              '</cooper></root>', TRUE);

      --pasta/rl
      vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '');
      --lista de e-mails
      vr_dsmailcop := gene0001.fn_param_sistema( pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_cdacesso => 'CRRL571');

      -- Gerando o relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_xml
                                 ,pr_dsxmlnode => '/root/cooper/conta'
                                 ,pr_dsjasper  => 'crrl570.jasper'
                                 ,pr_dsparams  => ''
                                 ,pr_dsarqsaid => vr_dsdircop||'/rl/'||vr_nmarqimp
                                 ,pr_flg_gerar => 'S'
                                 ,pr_qtcoluna  => 234
                                 ,pr_sqcabrel  => 1
                                 ,pr_flg_impri => 'S'
                                 ,pr_nmformul  => '234dh'
                                 ,pr_nrcopias  => 1
                                 ,pr_fldosmail => 'S'                           --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                 ,pr_dspathcop => vr_dsdircop||'/converte'      --> Lista sep. por ';' de diretórios a copiar o relatório
                                 ,pr_dsmailcop => vr_dsmailcop                  --> Lista sep. por ';' de emails para envio do relatório
                                 ,pr_dsassmail => 'Informaçoes BNDES - Quadro 7019' --> Assunto do e-mail que enviará o relatório
                                 ,pr_des_erro  => vr_dscritic);


      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);

      --limpando a tabela temporaria
      vr_tab_conteudo.delete;

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

  END pc_crps577;
/

