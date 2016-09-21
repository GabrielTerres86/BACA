CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps483 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* .............................................................................

   Programa: pc_crps483 (Fontes/crps483.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Sidnei (Precise IT)
   Data    : Junho/2007                      Ultima atualizacao: 27/02/2014

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Emitir Relatorio Mensal Consolidado Arrecadacao,
               conforme convenios lancados
               (Solicitacao 39 - Primeiro dia util do mes)
               (Emite relatorio 450)

   Alteracoes: 21/08/2007 - Alimenta tarifa diferenciada para pac 90(Guilherme)
                          - Ajustes no padrao de formatacao (Evandro).

               21/10/2008 - Incluir resumo dos convenios (Gabriel).

               13/11/2008 - Melhoria de Performance (Evandro).

               16/07/2009 - Considerar PMB(Mirtes)

               27/10/2009 - Alterado para utilizar a BO b1wgen0045.p que sera
                            agrupadora das funcoes compartilhadas com o CRPS524

               18/02/2010 - Alterar nome do handle (Magui).

               18/03/2010 - Incluido nova coluna no relatorio crrl450.lst, com
                            as informacoes do numero de cooperados que tiveram
                            debito automatico (Elton).

               13/05/2010 - Incluido campo com total de cooperados que tiveram
                            algum debito automatico no mes (Elton).

               21/03/2012 - Ajustes para a contabilizacao correta da coluna
                            "COOP.DEB.AUT" (Adriano).

               09/09/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               27/02/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS483';

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

      -- Busca os dados do convenio ordenados por nome
      CURSOR cr_gnconve IS
        SELECT nmempres,
               cdconven
          FROM gnconve
         ORDER BY nmempres;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Variavel para armazenar a tabela de memoria de convenios
      vr_tab_convenio      conv0001.typ_tab_convenio; -- Vetor contendo os convenios ordenados por convenio e agencia
      vr_tab_convenio_age  conv0001.typ_tab_convenio; -- Vetor contendo os convenios ordenados por agencia e convenio

      -- Variavel para PlTable de associados que pagaram qualquer convenio
      vr_tab_crawass conv0001.typ_tab_crawass;


      -- Definicao do tipo de tabela para os totais dos convenios
      TYPE typ_reg_tot_convenio IS
        RECORD(dsconven  gnconve.nmempres%TYPE,       --> Nome do convenio
               qtfatura  PLS_INTEGER,                 --> Quantidade de faturas
               vlfatura  NUMBER(17,2),                --> Valor das faturas
               vltarifa  NUMBER(17,2),                --> Valor das tarifas
               vlapagar  NUMBER(17,2),                --> Valor a pagar
               qtdebaut  PLS_INTEGER,                 --> Quantidade associados com debitos automaticos
               qtdebito  PLS_INTEGER,                 --> Quantidade de debitos automaticos
               vldebito  NUMBER(17,2),                --> Valor debitado
               vltardeb  NUMBER(17,2),                --> Valor das tarifas dos debitos
               vlapadeb  NUMBER(17,2));               --> Valor a pagar
      TYPE typ_tab_tot_convenio IS
        TABLE OF typ_reg_tot_convenio
        INDEX BY PLS_INTEGER;
      -- Vetor para armazenar os os totais dos convenios
      vr_tab_tot_convenio typ_tab_tot_convenio;
      vr_indice_tot PLS_INTEGER := 0;



      ------------------------------- VARIAVEIS -------------------------------
      vr_dtproces   DATE;                         --> Data de processo. Sera o primeiro dia do mes do processo anterior
      vr_mes        VARCHAR2(07);                 --> Mes / ano do processo anterior
      vr_indice     VARCHAR2(10);                 --> Indice da tabela de memoria vr_tab_convenio
      vr_indice_age VARCHAR2(10);                 --> Indice da tabela de memoria vr_tab_convenio_age
      vr_indice_crawass VARCHAR2(13);             --> Indice da tabela de memoria vr_tab_crawass
      vr_texto_completo VARCHAR2(32600);          --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml    CLOB;                         --> XML do relatorio
      vr_nom_direto VARCHAR2(100);                --> Nome do diretorio para a geracao do arquivo de saida


      -- Variaveis totalizadoras
      vr_t_qtfatura  PLS_INTEGER;                 --> Quantidade de faturas
      vr_t_vlfatura  NUMBER(17,2);                --> Valor das faturas
      vr_t_vltarifa  NUMBER(17,2);                --> Valor das tarifas
      vr_t_vlapagar  NUMBER(17,2);                --> Valor a pagar
      vr_t_qtdebaut  PLS_INTEGER;                 --> Quantidade associados com debitos automaticos
      vr_t_qtdebito  PLS_INTEGER;                 --> Quantidade de debitos automaticos
      vr_t_vldebito  NUMBER(17,2);                --> Valor debitado
      vr_t_vltardeb  NUMBER(17,2);                --> Valor das tarifas dos debitos
      vr_t_vlapadeb  NUMBER(17,2);                --> Valor a pagar
      vr_t_qttotal   PLS_INTEGER;                 --> Soma da quantidade das faturas com a quantidade dos debitos
      vr_t_vltartot  NUMBER(17,2);                --> Soma do valor das faturas com o valor dos debitos

      -- Variaveis totalizadoras gerais
      vr_tg_qtfatura PLS_INTEGER;                 --> Quantidade de faturas
      vr_tg_vlfatura NUMBER(17,2);                --> Valor das faturas
      vr_tg_vltarifa NUMBER(17,2);                --> Valor das tarifas
      vr_tg_vlapagar NUMBER(17,2);                --> Valor a pagar
      vr_tg_qtdebaut PLS_INTEGER;                 --> Quantidade associados com debitos automaticos
      vr_tg_qtdebito PLS_INTEGER;                 --> Quantidade de debitos automaticos
      vr_tg_vldebito NUMBER(17,2);                --> Valor debitado
      vr_tg_vltardeb NUMBER(17,2);                --> Valor das tarifas dos debitos
      vr_tg_vlapadeb NUMBER(17,2);                --> Valor a pagar
      vr_tg_qttotal   PLS_INTEGER;                --> Soma da quantidade das faturas com a quantidade dos debitos
      vr_tg_vltartot  NUMBER(17,2);               --> Soma do valor das faturas com o valor dos debitos



      --------------------------- SUBROTINAS INTERNAS --------------------------

      -- Le a temp-table de convenios e gerar a parte de detalhes do relatorio
      PROCEDURE pc_gerar_relatorio IS
      BEGIN

        -- Abre o no de detalhe
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<detalhe>');

        -- inicializa as variaveis totalizadoras
        vr_t_qtfatura := 0;
        vr_t_vlfatura := 0;
        vr_t_vltarifa := 0;
        vr_t_vlapagar := 0;
        vr_t_qtdebaut := 0;
        vr_t_qtdebito := 0;
        vr_t_vldebito := 0;
        vr_t_vltardeb := 0;
        vr_t_vlapadeb := 0;

        -- inicializa as variaveis de totais gerais
        vr_tg_qtfatura := 0;
        vr_tg_vlfatura := 0;
        vr_tg_vltarifa := 0;
        vr_tg_vlapagar := 0;
        vr_tg_qtdebaut := 0;
        vr_tg_qtdebito := 0;
        vr_tg_vldebito := 0;
        vr_tg_vltardeb := 0;
        vr_tg_vlapadeb := 0;

        -- Efetua um loop para buscar os convenios ordenados por nome
        FOR rw_gnconve IN cr_gnconve LOOP

          -- Busca o primeiro registro do convenio
          vr_indice := lpad(rw_gnconve.cdconven,7,'0')||'000';
          vr_indice := vr_tab_convenio.next(vr_indice);

          -- Percorre a tabela de convenios enquanto o convenio da temp-table for igual ao do FOR cr_gnconve
          WHILE vr_indice IS NOT NULL AND
                vr_tab_convenio(vr_indice).cdconven = rw_gnconve.cdconven LOOP

            -- Verifica se eh o primeiro convenio
            IF vr_indice = vr_tab_convenio.first OR   -- Se for o primeiro registro
               vr_tab_convenio(vr_indice).cdconven <> vr_tab_convenio(vr_tab_convenio.prior(vr_indice)).cdconven THEN -- Convenio anterior for diferente do atual
              -- Abre o no de convenio
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                 '<convenio>' ||
                   '<nmempres>'||rw_gnconve.nmempres||'</nmempres>');
            END IF;

            -- Escreve a linha de detalhe
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
              '<pa>'||
                '<cdagenci>'||vr_tab_convenio(vr_indice).cdagenci                            ||'</cdagenci>'||
                '<qtfatura>'||to_char(nvl(vr_tab_convenio(vr_indice).qtfatura,0),'FM999G999G990')   ||'</qtfatura>'||
                '<vlfatura>'||to_char(nvl(vr_tab_convenio(vr_indice).vlfatura,0),'FM999G999G990D00')||'</vlfatura>'||
                '<vltarifa>'||to_char(nvl(vr_tab_convenio(vr_indice).vltarifa,0),'FM999G999G990D00')||'</vltarifa>'||
                '<vlapagar>'||to_char(nvl(vr_tab_convenio(vr_indice).vlapagar,0),'FM999G999G990D00')||'</vlapagar>'||
                '<qtdebaut>'||to_char(nvl(vr_tab_convenio(vr_indice).qtdebaut,0),'FM999G999G990')   ||'</qtdebaut>'||
                '<qtdebito>'||to_char(nvl(vr_tab_convenio(vr_indice).qtdebito,0),'FM999G999G990')   ||'</qtdebito>'||
                '<vldebito>'||to_char(nvl(vr_tab_convenio(vr_indice).vldebito,0),'FM999G999G990D00')||'</vldebito>'||
                '<vltardeb>'||to_char(nvl(vr_tab_convenio(vr_indice).vltardeb,0),'FM999G999G990D00')||'</vltardeb>'||
                '<vlapadeb>'||to_char(nvl(vr_tab_convenio(vr_indice).vlapadeb,0),'FM999G999G990D00')||'</vlapadeb>'||
              '</pa>');

            /****** Totalizadores ***********/
            vr_t_qtfatura := vr_t_qtfatura + nvl(vr_tab_convenio(vr_indice).qtfatura,0);
            vr_t_vlfatura := vr_t_vlfatura + nvl(vr_tab_convenio(vr_indice).vlfatura,0);
            vr_t_vltarifa := vr_t_vltarifa + nvl(vr_tab_convenio(vr_indice).vltarifa,0);
            vr_t_vlapagar := vr_t_vlapagar + nvl(vr_tab_convenio(vr_indice).vlapagar,0);
            vr_t_qtdebaut := vr_t_qtdebaut + nvl(vr_tab_convenio(vr_indice).qtdebaut,0);
            vr_t_qtdebito := vr_t_qtdebito + nvl(vr_tab_convenio(vr_indice).qtdebito,0);
            vr_t_vldebito := vr_t_vldebito + nvl(vr_tab_convenio(vr_indice).vldebito,0);
            vr_t_vltardeb := vr_t_vltardeb + nvl(vr_tab_convenio(vr_indice).vltardeb,0);
            vr_t_vlapadeb := vr_t_vlapadeb + nvl(vr_tab_convenio(vr_indice).vlapadeb,0);

            -- Verifica se eh o ultimo convenio
            IF vr_indice = vr_tab_convenio.last OR -- Se for o ultimo registro
               vr_tab_convenio(vr_indice).cdconven <> vr_tab_convenio(vr_tab_convenio.next(vr_indice)).cdconven THEN -- Convenio posterior for diferente do atual

              -- Escreve a linha de total do convenio
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                   '<t_qtfatura>'||to_char(vr_t_qtfatura,'FM999G999G990')   ||'</t_qtfatura>'||
                   '<t_vlfatura>'||to_char(vr_t_vlfatura,'FM999G999G990D00')||'</t_vlfatura>'||
                   '<t_vltarifa>'||to_char(vr_t_vltarifa,'FM999G999G990D00')||'</t_vltarifa>'||
                   '<t_vlapagar>'||to_char(vr_t_vlapagar,'FM999G999G990D00')||'</t_vlapagar>'||
                   '<t_qtdebaut>'||to_char(vr_t_qtdebaut,'FM999G999G990')   ||'</t_qtdebaut>'||
                   '<t_qtdebito>'||to_char(vr_t_qtdebito,'FM999G999G990')   ||'</t_qtdebito>'||
                   '<t_vldebito>'||to_char(vr_t_vldebito,'FM999G999G990D00')||'</t_vldebito>'||
                   '<t_vltardeb>'||to_char(vr_t_vltardeb,'FM999G999G990D00')||'</t_vltardeb>'||
                   '<t_vlapadeb>'||to_char(vr_t_vlapadeb,'FM999G999G990D00')||'</t_vlapadeb>'||
                 '</convenio>');

              -- Insere o total do convenio da temp-table de totais de convenio
              vr_indice_tot := vr_indice_tot + 1;
              vr_tab_tot_convenio(vr_indice_tot).dsconven := rw_gnconve.nmempres;
              vr_tab_tot_convenio(vr_indice_tot).qtfatura := vr_t_qtfatura;
              vr_tab_tot_convenio(vr_indice_tot).vlfatura := vr_t_vlfatura;
              vr_tab_tot_convenio(vr_indice_tot).vltarifa := vr_t_vltarifa;
              vr_tab_tot_convenio(vr_indice_tot).vlapagar := vr_t_vlapagar;
              vr_tab_tot_convenio(vr_indice_tot).qtdebaut := vr_t_qtdebaut;
              vr_tab_tot_convenio(vr_indice_tot).qtdebito := vr_t_qtdebito;
              vr_tab_tot_convenio(vr_indice_tot).vldebito := vr_t_vldebito;
              vr_tab_tot_convenio(vr_indice_tot).vltardeb := vr_t_vltardeb;
              vr_tab_tot_convenio(vr_indice_tot).vlapadeb := vr_t_vlapadeb;

              -- Acumula o total do convenio no total geral
              vr_tg_qtfatura := vr_tg_qtfatura + vr_t_qtfatura;
              vr_tg_vlfatura := vr_tg_vlfatura + vr_t_vlfatura;
              vr_tg_vltarifa := vr_tg_vltarifa + vr_t_vltarifa;
              vr_tg_vlapagar := vr_tg_vlapagar + vr_t_vlapagar;
              vr_tg_qtdebaut := vr_tg_qtdebaut + vr_t_qtdebaut;
              vr_tg_qtdebito := vr_tg_qtdebito + vr_t_qtdebito;
              vr_tg_vldebito := vr_tg_vldebito + vr_t_vldebito;
              vr_tg_vltardeb := vr_tg_vltardeb + vr_t_vltardeb;
              vr_tg_vlapadeb := vr_tg_vlapadeb + vr_t_vlapadeb;

               -- Zera as variaveis de totais do convenio
              vr_t_qtfatura := 0;
              vr_t_vlfatura := 0;
              vr_t_vltarifa := 0;
              vr_t_vlapagar := 0;
              vr_t_qtdebaut := 0;
              vr_t_qtdebito := 0;
              vr_t_vldebito := 0;
              vr_t_vltardeb := 0;
              vr_t_vlapadeb := 0;
            END IF;

            vr_indice := vr_tab_convenio.next(vr_indice);
          END LOOP; -- Loop sobre a vr_tab_convenio
        END LOOP; -- Loop sobre a cr_gnconve

        /********* exibir totalizador geral **********/
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
              '<tg_qtfatura>'||to_char(vr_tg_qtfatura,'FM999G999G990')   ||'</tg_qtfatura>'||
              '<tg_vlfatura>'||to_char(vr_tg_vlfatura,'FM999G999G990D00')||'</tg_vlfatura>'||
              '<tg_vltarifa>'||to_char(vr_tg_vltarifa,'FM999G999G990D00')||'</tg_vltarifa>'||
              '<tg_vlapagar>'||to_char(vr_tg_vlapagar,'FM999G999G990D00')||'</tg_vlapagar>'||
              '<tg_qtdebaut>'||to_char(vr_tg_qtdebaut,'FM999G999G990')   ||'</tg_qtdebaut>'||
              '<tg_qtdebito>'||to_char(vr_tg_qtdebito,'FM999G999G990')   ||'</tg_qtdebito>'||
              '<tg_vldebito>'||to_char(vr_tg_vldebito,'FM999G999G990D00')||'</tg_vldebito>'||
              '<tg_vltardeb>'||to_char(vr_tg_vltardeb,'FM999G999G990D00')||'</tg_vltardeb>'||
              '<tg_vlapadeb>'||to_char(vr_tg_vlapadeb,'FM999G999G990D00')||'</tg_vlapadeb>'||
            '</detalhe>');
      END pc_gerar_relatorio;

      -- gerar resumo das tarifas por PA
      PROCEDURE pc_gerar_resumo_tarifas IS
      BEGIN
        -- Abre o no de totais por PA
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<resumopa>');

        -- inicializa as variaveis totalizadoras
        vr_t_qtfatura := 0;
        vr_t_vltarifa := 0;
        vr_t_qtdebito := 0;
        vr_t_vltardeb := 0;
        vr_t_qttotal  := 0;
        vr_t_vltartot := 0;
        vr_t_qtdebaut := 0;

        -- inicializa as variaveis de totais gerais
        vr_tg_qtfatura := 0;
        vr_tg_vltarifa := 0;
        vr_tg_qtdebito := 0;
        vr_tg_vltardeb := 0;
        vr_tg_qttotal  := 0;
        vr_tg_vltartot := 0;
        vr_tg_qtdebaut := 0;

        -- busca o indice do primeiro registro da temp table vr_tab_convenio_age
        vr_indice_age := vr_tab_convenio_age.first;

        -- Varre toda a temp-table vr_tab_convenio_age
        WHILE vr_indice_age IS NOT NULL LOOP

          /****** Totalizadores ***********/
          vr_t_qtfatura := vr_t_qtfatura + nvl(vr_tab_convenio_age(vr_indice_age).qtfatura,0);
          vr_t_vltarifa := vr_t_vltarifa + nvl(vr_tab_convenio_age(vr_indice_age).vltarifa,0);
          vr_t_qtdebito := vr_t_qtdebito + nvl(vr_tab_convenio_age(vr_indice_age).qtdebito,0);
          vr_t_vltardeb := vr_t_vltardeb + nvl(vr_tab_convenio_age(vr_indice_age).vltardeb,0);
          vr_t_qttotal  := vr_t_qttotal  + nvl(vr_tab_convenio_age(vr_indice_age).qtfatura,0) + nvl(vr_tab_convenio_age(vr_indice_age).qtdebito,0);
          vr_t_vltartot := vr_t_vltartot + nvl(vr_tab_convenio_age(vr_indice_age).vltarifa,0) + nvl(vr_tab_convenio_age(vr_indice_age).vltardeb,0);

          -- Verifica se eh o ultimo PA
          IF vr_indice_age = vr_tab_convenio_age.last OR -- Se for o ultimo registro
             vr_tab_convenio_age(vr_indice_age).cdagenci <> vr_tab_convenio_age(vr_tab_convenio_age.next(vr_indice_age)).cdagenci THEN -- PA posterior for diferente do atual

            -- Varre a temp-table crawass e soma a quantidade de debitos automaticos
            vr_indice_crawass := vr_tab_crawass.first;
            WHILE vr_indice_crawass IS NOT NULL LOOP
              -- Se a agencia do associado for igual a agencia da pesquisa
              IF vr_tab_crawass(vr_indice_crawass).cdagenci = vr_tab_convenio_age(vr_indice_age).cdagenci THEN
                -- Soma a quantidade de debitos automaticos
                vr_t_qtdebaut := vr_t_qtdebaut + 1;
              END IF;

              -- Vai para o proximo registro
              vr_indice_crawass := vr_tab_crawass.next(vr_indice_crawass);
            END LOOP;

            -- Escreve o totalizador do PA
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                '<pa>'||
                  '<cdagenci>'||vr_tab_convenio_age(vr_indice_age).cdagenci||'</cdagenci>'||
                  '<qtfatura>'||to_char(vr_t_qtfatura,'FM999G999G990')     ||'</qtfatura>'||
                  '<vltarfat>'||to_char(vr_t_vltarifa,'FM999G999G990D00')  ||'</vltarfat>'||
                  '<qtdebaut>'||to_char(vr_t_qtdebaut,'FM999G999G990')     ||'</qtdebaut>'||
                  '<qtdebito>'||to_char(vr_t_qtdebito,'FM999G999G990')     ||'</qtdebito>'||
                  '<vltardeb>'||to_char(vr_t_vltardeb,'FM999G999G990D00')  ||'</vltardeb>'||
                  '<qttotal>' ||to_char(vr_t_qttotal ,'FM999G999G990')     ||'</qttotal>' ||
                  '<vltartot>'||to_char(vr_t_vltartot,'FM999G999G990D00')  ||'</vltartot>'||
                '</pa>');

            -- Acumula os valores para o total geral
            vr_tg_qtfatura := vr_tg_qtfatura + vr_t_qtfatura;
            vr_tg_vltarifa := vr_tg_vltarifa + vr_t_vltarifa;
            vr_tg_qtdebito := vr_tg_qtdebito + vr_t_qtdebito;
            vr_tg_vltardeb := vr_tg_vltardeb + vr_t_vltardeb;
            vr_tg_qttotal  := vr_tg_qttotal  + vr_t_qttotal ;
            vr_tg_vltartot := vr_tg_vltartot + vr_t_vltartot;
            vr_tg_qtdebaut := vr_tg_qtdebaut + vr_t_qtdebaut;

            -- inicializa as variaveis totalizadoras
            vr_t_qtfatura := 0;
            vr_t_vltarifa := 0;
            vr_t_qtdebito := 0;
            vr_t_vltardeb := 0;
            vr_t_qttotal  := 0;
            vr_t_vltartot := 0;
            vr_t_qtdebaut := 0;
          END IF;

          -- Vai para o proximo registro
          vr_indice_age := vr_tab_convenio_age.next(vr_indice_age);

        END LOOP;

        -- Escreve o totalizador geral
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
              '<tg_qtfatura>'||to_char(vr_tg_qtfatura,'FM999G999G990')   ||'</tg_qtfatura>'||
              '<tg_vltarfat>'||to_char(vr_tg_vltarifa,'FM999G999G990D00')||'</tg_vltarfat>'||
              '<tg_qtdebaut>'||to_char(vr_tg_qtdebaut,'FM999G999G990')   ||'</tg_qtdebaut>'||
              '<tg_qtdebito>'||to_char(vr_tg_qtdebito,'FM999G999G990')   ||'</tg_qtdebito>'||
              '<tg_vltardeb>'||to_char(vr_tg_vltardeb,'FM999G999G990D00')||'</tg_vltardeb>'||
              '<tg_qttotal>' ||to_char(vr_tg_qttotal ,'FM999G999G990')   ||'</tg_qttotal>' ||
              '<tg_vltartot>'||to_char(vr_tg_vltartot,'FM999G999G990D00')||'</tg_vltartot>'||
            '</resumopa>');

      END pc_gerar_resumo_tarifas;

      -- Lista o total de cada convenio
      PROCEDURE pc_resumo_convenio IS
      BEGIN

         -- Zera as variaveis de total geral
        vr_t_qtfatura := 0;
        vr_t_vlfatura := 0;
        vr_t_vltarifa := 0;
        vr_t_vlapagar := 0;
        vr_t_qtdebaut := 0;
        vr_t_qtdebito := 0;
        vr_t_vldebito := 0;
        vr_t_vltardeb := 0;
        vr_t_vlapadeb := 0;

        -- Vai para o primeiro registro de totais
        vr_indice_tot := vr_tab_tot_convenio.first;

        -- Escreve o no inicial de resumo de convenio
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,'<resumoconvenio>');

        -- Percorre a tabela de totais
        WHILE vr_indice_tot IS NOT NULL LOOP

          -- Escreve o totalizador de convenios
          gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
            '<convenio>'  ||
              '<dsconven>'||substr(vr_tab_tot_convenio(vr_indice_tot).dsconven,1,19)               ||'</dsconven>'||
              '<qtfatura>'||to_char(vr_tab_tot_convenio(vr_indice_tot).qtfatura,'FM999G999G990')   ||'</qtfatura>'||
              '<vlfatura>'||to_char(vr_tab_tot_convenio(vr_indice_tot).vlfatura,'FM999G999G990D00')||'</vlfatura>'||
              '<vltarifa>'||to_char(vr_tab_tot_convenio(vr_indice_tot).vltarifa,'FM999G999G990D00')||'</vltarifa>'||
              '<vlapagar>'||to_char(vr_tab_tot_convenio(vr_indice_tot).vlapagar,'FM999G999G990D00')||'</vlapagar>'||
              '<qtdebaut>'||to_char(vr_tab_tot_convenio(vr_indice_tot).qtdebaut,'FM999G999G990')   ||'</qtdebaut>'||
              '<qtdebito>'||to_char(vr_tab_tot_convenio(vr_indice_tot).qtdebito,'FM999G999G990')   ||'</qtdebito>'||
              '<vldebito>'||to_char(vr_tab_tot_convenio(vr_indice_tot).vldebito,'FM999G999G990D00')||'</vldebito>'||
              '<vltardeb>'||to_char(vr_tab_tot_convenio(vr_indice_tot).vltardeb,'FM999G999G990D00')||'</vltardeb>'||
              '<vlapadeb>'||to_char(vr_tab_tot_convenio(vr_indice_tot).vlapadeb,'FM999G999G990D00')||'</vlapadeb>'||
            '</convenio>');

          -- Acumula os valores para o total geral
          vr_t_qtfatura := vr_t_qtfatura + vr_tab_tot_convenio(vr_indice_tot).qtfatura;
          vr_t_vlfatura := vr_t_vlfatura + vr_tab_tot_convenio(vr_indice_tot).vlfatura;
          vr_t_vltarifa := vr_t_vltarifa + vr_tab_tot_convenio(vr_indice_tot).vltarifa;
          vr_t_vlapagar := vr_t_vlapagar + vr_tab_tot_convenio(vr_indice_tot).vlapagar;
          vr_t_qtdebaut := vr_t_qtdebaut + vr_tab_tot_convenio(vr_indice_tot).qtdebaut;
          vr_t_qtdebito := vr_t_qtdebito + vr_tab_tot_convenio(vr_indice_tot).qtdebito;
          vr_t_vldebito := vr_t_vldebito + vr_tab_tot_convenio(vr_indice_tot).vldebito;
          vr_t_vltardeb := vr_t_vltardeb + vr_tab_tot_convenio(vr_indice_tot).vltardeb;
          vr_t_vlapadeb := vr_t_vlapadeb + vr_tab_tot_convenio(vr_indice_tot).vlapadeb;

          -- Vai para o proximo registro
          vr_indice_tot := vr_tab_tot_convenio.next(vr_indice_tot);
        END LOOP;

        -- Escreve o totalizador de convenios
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
            '<tg_qtfatura>'||to_char(vr_t_qtfatura,'FM999G999G990')   ||'</tg_qtfatura>'||
            '<tg_vlfatura>'||to_char(vr_t_vlfatura,'FM999G999G990D00')||'</tg_vlfatura>'||
            '<tg_vltarifa>'||to_char(vr_t_vltarifa,'FM999G999G990D00')||'</tg_vltarifa>'||
            '<tg_vlapagar>'||to_char(vr_t_vlapagar,'FM999G999G990D00')||'</tg_vlapagar>'||
            '<tg_qtdebaut>'||to_char(vr_t_qtdebaut,'FM999G999G990')   ||'</tg_qtdebaut>'||
            '<tg_qtdebito>'||to_char(vr_t_qtdebito,'FM999G999G990')   ||'</tg_qtdebito>'||
            '<tg_vldebito>'||to_char(vr_t_vldebito,'FM999G999G990D00')||'</tg_vldebito>'||
            '<tg_vltardeb>'||to_char(vr_t_vltardeb,'FM999G999G990D00')||'</tg_vltardeb>'||
            '<tg_vlapadeb>'||to_char(vr_t_vlapadeb,'FM999G999G990D00')||'</tg_vlapadeb>'||
          '</resumoconvenio>');

      END pc_resumo_convenio;

    BEGIN -- Rotina Principal

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

      -- Atualiza as datas que serao utilizadas no programa
      vr_dtproces := trunc(rw_crapdat.dtmvtoan,'MM'); -- Busca o primeiro dia do mes do movimento anterior
      vr_mes      := to_char(rw_crapdat.dtmvtoan,'MM/YYYY'); -- Mes e ano do movimento anterior

      /*** Ler convenios e popular temp-table ******/
      conv0001.pc_valor_convenios(pr_cdcooper => pr_cdcooper,
                                  pr_dataini  => vr_dtproces,
                                  pr_datafim  => rw_crapdat.dtmvtoan,
                                  pr_tab_convenio => vr_tab_convenio_age,
                                  pr_tab_crawass  => vr_tab_crawass,
                                  pr_cdcritic => vr_cdcritic,
                                  pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- ordena a pl_table por convenio e depois agencia. Atualmente esta agencia e depois convenio
      vr_indice_age := vr_tab_convenio_age.first;
      WHILE vr_indice_age IS NOT NULL LOOP
        vr_indice := lpad(vr_tab_convenio_age(vr_indice_age).cdconven,7,'0')||
                     lpad(vr_tab_convenio_age(vr_indice_age).cdagenci,3,'0');
        vr_tab_convenio(vr_indice) := vr_tab_convenio_age(vr_indice_age);
        vr_indice_age := vr_tab_convenio_age.next(vr_indice_age);
      END LOOP;

      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Inicializa o XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                            '<?xml version="1.0" encoding="utf-8"?><crrl450>'||
                              '<nrmesref>'||vr_mes||'</nrmesref>');


      /******* ler temp-table e gerar relatorio ******/
      pc_gerar_relatorio;

      /******* gerar resumo das tarifas por PA *****/
      pc_gerar_resumo_tarifas;

      /******* todos os totais dos convenios  *******/
      pc_resumo_convenio;

      -- Encerra o arquivo XML
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                            '</crrl450>',TRUE);

      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl');

      -- Chamada do iReport para gerar o arquivo de saida
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,                    --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,                    --> Programa chamador
                                  pr_dtmvtolt  => rw_crapdat.dtmvtolt,            --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,                     --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/crrl450',                     --> No base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl450.jasper',               --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                           --> Nao enviar parametro
                                  pr_dsarqsaid => vr_nom_direto||'/crrl450.lst',  --> Arquivo final
                                  pr_flg_gerar => 'N',                            --> Nao gerar o arquivo na hora
                                  pr_qtcoluna  => 132,                            --> Quantidade de colunas
                                  pr_nmformul  => '132col',                       --> Nome do formulario
                                  pr_sqcabrel  => 1,                              --> Sequencia do cabecalho
                                  pr_flg_impri => 'S',                            --> Chamar a impress?o (Imprim.p)
                                  pr_nrcopias  => 1,                              --> Numero de copias
                                  pr_des_erro  => vr_dscritic);                   --> Saida com erro
      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

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

  END pc_crps483;
/

