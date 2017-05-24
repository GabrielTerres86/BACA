CREATE OR REPLACE PROCEDURE CECRED.pc_crps490(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps490   (Antigo fontes/crps490.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : David
       Data    : Julho/2007                      Ultima atualizacao: 22/03/2017

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Solicitacao: 002.
                   Listar todas as aplicacoes RDCPRE e RDCPOS com vencimento
                   para daqui a 5 dias uteis
                   Ordem da solicitacao: 44
                   Relatorio 458

       Alteracoes: 02/08/2007 - Separar relatorio 458 por PAC (David).

                   05/11/2007 - Classificacao agencia da aplicacao com erro (Magui)

                   11/03/2008 - Melhorar leitura do craplap para taxas (Magui).

                   06/05/2008 - Incluida data que foi feita a aplicacao (Evandro).

                   26/11/2010 - Retirar da sol 2 ordem 44 e colocar na sol 82
                                ordem 81.E na CECRED sol 82 e ordem 84 (Magui).

                   07/12/2010 - Alterado p/ listar as aplicaçoes com base no PAC
                                do cooperado (Vitor).

                   01/06/2011 - Estanciado a b1wgen0004 para o inicio do programa
                                e deletado ao final para ganho de performance
                                (Adriano).

                   16/09/2013 - Tratamento para Imunidade Tributaria (Ze).

                   27/09/2013 - Alterada atribuicao da variavel aux_nrramfon
                                para receber somente o telefone da tabela craptfc
                                e alteradas strings de PAC para PA. (Reinert)

                   12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                                (Reinert)

                   24/03/2014 - Conversão Progress >> Oracle (Petter - Supero)

                   05/09/2014 - #187032 Correção da verificação de feriados e
                                geração do relatório para a última agência (Carlos)

                   22/03/2017 - #455742 Ajuste de passagem dos parâmetros inpessoa e nrcpfcgc para não
                                consultar novamente o associado no pkg apli0001 (Carlos)

    ............................................................................ */

    DECLARE
      -------------------------- PL TABLE´s ------------------------------
      -- PL Table para dados das agencias
      TYPE typ_reg_crapage IS
        RECORD(nmresage crapage.nmresage%TYPE);
      TYPE typ_tab_crapage IS TABLE OF typ_reg_crapage INDEX BY VARCHAR2(15);

      TYPE typ_reg_craptfc IS
        RECORD(nrdconta craptfc.nrdconta%TYPE
              ,tptelefo craptfc.tptelefo%TYPE
              ,nrtelefo craptfc.nrtelefo%TYPE
              ,nrdddtfc craptfc.nrdddtfc%TYPE);
      TYPE typ_tab_craptfc IS TABLE OF typ_reg_craptfc INDEX BY VARCHAR2(25);

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra       CONSTANT crapprg.cdprogra%TYPE := 'CRPS490';

      -- Tratamento de erros
      vr_exc_saida      EXCEPTION;
      vr_exc_fimprg     EXCEPTION;
      vr_cdcritic       PLS_INTEGER;
      vr_dscritic       VARCHAR2(4000);

      -- Variáveis de negócio
      vr_nrramfon       VARCHAR2(400);
      vr_nmarqrel       VARCHAR2(400);
      vr_dsagenci       VARCHAR2(400);
      vr_vlrdirrf       NUMBER(20,2);
      vr_perirrgt       NUMBER(20,2);
      vr_vlrentot       NUMBER(20,2);
      vr_tptelefo       PLS_INTEGER;
      vr_dtvenini       DATE;
      vr_dtvenfim       DATE;
      vr_vlsldrdc       craprda.vlsdrdca%TYPE;
      vr_xmlb           VARCHAR2(32767);
      vr_xmlc           CLOB;
      vr_nom_dir        VARCHAR2(400);
      vr_tab_crapage    typ_tab_crapage;
      vr_tab_erro       gene0001.typ_tab_erro;
      vr_dtinitax       DATE;
      vr_dtfimtax       DATE;
      vr_dstextab       VARCHAR2(400);
      vr_tab_craptfc    typ_tab_craptfc;
      vr_clobtam        PLS_INTEGER;
      vr_contador       PLS_INTEGER := 0;

	  -- Definicao do tipo para a tabela de aplicações
      vr_craprda apli0001.typ_tab_craprda;

      ------------------------------- CURSORES ---------------------------------
      -- Buscar dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Buscar dados de tipos de captação por associado levando em consideração o período de data de vencimento e
      -- o tipo de aplicação RDC
      CURSOR cr_capta(pr_cdcooper IN crapdtc.cdcooper%TYPE
                     ,pr_dtvenini IN craprda.dtvencto%TYPE
                     ,pr_dtvenfim IN craprda.dtvencto%TYPE) IS
        SELECT dtc.tpaplrdc
              ,dtc.tpaplica
              ,dtc.dsaplica
              ,rda.nrdconta
              ,rda.nraplica
              ,rda.dtmvtolt
              ,rda.dtvencto
              ,rda.vlaplica
              ,ass.cdagenci
              ,ass.inpessoa
              ,ass.nmprimtl
              ,ass.nrcpfcgc
              ,row_number() over (partition by ass.cdagenci order by ass.cdagenci) nrseqreg
              ,count(1)     over (partition by ass.cdagenci) nrtotreg
              ,LAG(ass.cdagenci) OVER(ORDER BY ass.cdagenci) prev_cdagenci
              ,LEAD(ass.cdagenci) OVER(ORDER BY ass.cdagenci) post_cdagenci
              ,lap.txaplica
              ,lap.txaplmes
              ,rda.vlsdrdca
              ,rda.qtdiauti
              ,rda.vlsltxmm
              ,rda.dtatslmm
              ,rda.vlsltxmx
              ,rda.dtatslmx
        FROM crapdtc dtc
            ,craprda rda
            ,crapass ass
            ,craplap lap
        WHERE dtc.cdcooper = pr_cdcooper
          AND dtc.tpaplrdc IN (1, 2)
          AND rda.cdcooper = dtc.cdcooper
          AND rda.dtvencto > pr_dtvenini
          AND rda.dtvencto <= pr_dtvenfim
          AND rda.insaqtot = 0
          AND rda.tpaplica = dtc.tpaplica
          AND ass.cdcooper = dtc.cdcooper
          AND ass.nrdconta = rda.nrdconta
          AND lap.cdcooper = rda.cdcooper 
          AND lap.dtmvtolt = rda.dtmvtolt
          AND lap.cdagenci = rda.cdagenci
          AND lap.cdbccxlt = rda.cdbccxlt
          AND lap.nrdolote = rda.nrdolote
          AND lap.nrdconta = rda.nrdconta 
          AND lap.nrdocmto = rda.nraplica
        ORDER BY ass.cdagenci
                ,dtc.tpaplrdc
                ,rda.nrdconta
                ,rda.nraplica;

      TYPE typ_rec_craprda IS TABLE OF cr_capta%ROWTYPE
           INDEX BY PLS_INTEGER;
      vr_tab_craprda typ_rec_craprda;

      -- Busca dados das agencias
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE) IS
        SELECT age.nmresage
              ,age.cdagenci
        FROM crapage age
        WHERE age.cdcooper = pr_cdcooper;

      -- Busca dados do número de telefone de cada titular de conta e o tipo de telefone cadastrado (residencial e/ou comercial)
      CURSOR cr_craptfc(pr_cdcooper IN craptfc.cdcooper%TYPE) IS
        SELECT tfc.nrdconta
              ,tfc.tptelefo
              ,tfc.nrtelefo
              ,tfc.nrdddtfc
              ,NVL(LAG(tfc.nrdconta) OVER(ORDER BY tfc.tptelefo
                                          ,tfc.nrdconta
                                          ,tfc.idseqttl
                                          ,tfc.cdseqtfc), 0) nrdcontaant
              ,NVL(LAG(tfc.tptelefo) OVER(ORDER BY tfc.tptelefo
                                                  ,tfc.nrdconta
                                                  ,tfc.idseqttl
                                                  ,tfc.cdseqtfc), 0) tptelefoant
        FROM craptfc tfc
        WHERE tfc.cdcooper = pr_cdcooper
          AND tfc.tptelefo IN (1,3)
        ORDER BY tfc.tptelefo
                ,tfc.nrdconta
                ,tfc.idseqttl
                ,tfc.cdseqtfc;

      -- procedure para calcular datas de processo
      PROCEDURE fn_calc_data(pr_dtferiad IN OUT DATE
                            ,pr_cdcooper IN crapfer.cdcooper%TYPE) IS
      BEGIN
        DECLARE
          -- Variáveis do processo
          vr_contador    PLS_INTEGER := 0;

          -- Buscar dados do cadastro de feriados
          CURSOR cr_crapfer(pr_dtferiad IN crapfer.dtferiad%TYPE
                           ,pr_cdcooper IN crapfer.cdcooper%TYPE) IS
            SELECT fer.dtferiad
            FROM crapfer fer
            WHERE fer.cdcooper = pr_cdcooper
              AND fer.dtferiad = pr_dtferiad;

        BEGIN

          -- Efetuar incremento da data
          LOOP
            EXIT WHEN vr_contador > 5;

            pr_dtferiad := pr_dtferiad + 1;

            -- Buscar dados de feriados
            OPEN cr_crapfer(pr_dtferiad, pr_cdcooper);

            -- Verificar se a data é feriado ou final de semana
            IF TO_CHAR(pr_dtferiad, 'D') IN (1, 7) OR cr_crapfer%FOUND THEN
              CLOSE cr_crapfer;
              CONTINUE;
            END IF;

            CLOSE cr_crapfer;
            vr_contador := vr_contador + 1;
          END LOOP;
        END;
      END;

    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;

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
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

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
      -- Carregar PL Table das agencias
      FOR rw_crapage IN cr_crapage(pr_cdcooper) LOOP
        vr_tab_crapage(LPAD(rw_crapage.cdagenci, 15, '0')).nmresage := rw_crapage.nmresage;
      END LOOP;

      -- Carregar PL Table de números telefonicos
      FOR rw_craptfc IN cr_craptfc(pr_cdcooper) LOOP
        IF (LPAD(rw_craptfc.nrdconta, 15, '0') || LPAD(rw_craptfc.tptelefo, 3, '0'))  <> (LPAD(rw_craptfc.nrdcontaant, 15, '0') || LPAD(rw_craptfc.tptelefoant, 3, '0')) THEN
          vr_tab_craptfc(LPAD(rw_craptfc.nrdconta, 15, '0') || LPAD(rw_craptfc.tptelefo, 3, '0')).nrtelefo := rw_craptfc.nrtelefo;
          vr_tab_craptfc(LPAD(rw_craptfc.nrdconta, 15, '0') || LPAD(rw_craptfc.tptelefo, 3, '0')).nrdddtfc := rw_craptfc.nrdddtfc;
        END IF;
      END LOOP;

      -- Assimilar datas de ínicio e fim
      vr_dtvenini := rw_crapdat.dtmvtoan;
      vr_dtvenfim := rw_crapdat.dtmvtolt;

      -- Data de fim e inicio da utilização da taxa de poupança.
      -- Utiliza-se essa data quando o rendimento da aplicação for menor que
      -- a poupança, a cooperativa opta por usar ou não.
      -- Buscar a descrição das faixas contido na CRAPTAB.
      -- Adicionado na conversão para fins de compatibilidade.
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'MXRENDIPOS'
                                               ,pr_tpregist => 1);

      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        -- Utilizar datas padrão
        vr_dtinitax := TO_DATE('01/01/9999','DD/MM/RRRR');
        vr_dtfimtax := TO_DATE('01/01/9999','DD/MM/RRRR');
      ELSE
        -- Utilizar datas da tabela
        vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,vr_dstextab,';'),'DD/MM/RRRR');
        vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,vr_dstextab,';'),'DD/MM/RRRR');
      END IF;

      -- Validar feriádos para data inicial
      fn_calc_data(pr_dtferiad => vr_dtvenini, pr_cdcooper => pr_cdcooper);

      -- Validar feriádos para data final
      fn_calc_data(pr_dtferiad => vr_dtvenfim, pr_cdcooper => pr_cdcooper);

      -- Inicializar XML
      dbms_lob.createtemporary(vr_xmlc, TRUE);
      dbms_lob.open(vr_xmlc, dbms_lob.lob_readwrite);
      vr_xmlb := '<?xml version="1.0" encoding="utf-8"?><root>';

      -- Capturar o path do arquivo
      vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl');

      -- Buscar tipos de captação por associado
     -- Carregar PL Table com dados da tabela CRAPRDA
      OPEN cr_capta(pr_cdcooper, vr_dtvenini, vr_dtvenfim);
      LOOP
        FETCH cr_capta BULK COLLECT INTO vr_tab_craprda LIMIT 100000;
              
        EXIT WHEN vr_tab_craprda.COUNT = 0;

        FOR idx IN vr_tab_craprda.first..vr_tab_craprda.last LOOP
                
          --Limpa a tabela
          vr_craprda.delete;
                
          --Alimenta PLTABLE com as informações da aplicação
          vr_craprda(1).dtvencto:= vr_tab_craprda(idx).dtvencto;
          vr_craprda(1).dtmvtolt:= vr_tab_craprda(idx).dtmvtolt;
          vr_craprda(1).vlsdrdca:= vr_tab_craprda(idx).vlsdrdca;
          vr_craprda(1).qtdiauti:= vr_tab_craprda(idx).qtdiauti;
          vr_craprda(1).vlsltxmm:= vr_tab_craprda(idx).vlsltxmm;
          vr_craprda(1).dtatslmm:= vr_tab_craprda(idx).dtatslmm;
          vr_craprda(1).vlsltxmx:= vr_tab_craprda(idx).vlsltxmx;
          vr_craprda(1).dtatslmx:= vr_tab_craprda(idx).dtatslmx;
          vr_craprda(1).tpaplica:= vr_tab_craprda(idx).tpaplica;          
          vr_craprda(1).txaplica:= vr_tab_craprda(idx).txaplica;
          vr_craprda(1).txaplmes:= vr_tab_craprda(idx).txaplmes;

        -- Contador de iterações
        vr_contador := vr_contador + 1;

        -- Verifica se é o primeiro registro de agencia
        IF vr_tab_craprda(idx).cdagenci <> vr_tab_craprda(idx).prev_cdagenci OR vr_contador = 1 THEN
          -- Verifica se existe no cadastro de agencias
          IF vr_tab_crapage.exists(LPAD(vr_tab_craprda(idx).cdagenci, 15, '0')) THEN
              vr_dsagenci := vr_tab_craprda(idx).cdagenci || ' - ' || vr_tab_crapage(LPAD(vr_tab_craprda(idx).cdagenci, 15, '0')).nmresage;
          ELSE
            vr_dsagenci := vr_tab_craprda(idx).cdagenci;
          END IF;

          vr_xmlb := vr_xmlb || '<tipo><agencia>' || vr_dsagenci || '</agencia>';
          vr_xmlb := vr_xmlb || '<texto>--> APLICACOES TIPO ' || vr_tab_craprda(idx).tpaplica || ' - ' || vr_tab_craprda(idx).dsaplica || '</texto></tipo><regs>';
          gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
        END IF;

        -- Apagar PL Table de erros
        vr_tab_erro.delete;

        -- Zerar valor de saldo
        vr_vlsldrdc := 0;

        -- Verificar tipo da conta
        IF vr_tab_craprda(idx).tpaplrdc = 1 THEN
          -- Calcular saldo RDC PRE
          apli0001.pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_tab_craprda(idx).nrdconta
                                   ,pr_nraplica => vr_tab_craprda(idx).nraplica
                                   ,pr_dtmvtolt => vr_tab_craprda(idx).dtvencto
                                   ,pr_dtiniper => NULL
                                   ,pr_dtfimper => NULL
                                   ,pr_txaplica => 0
                                   ,pr_flggrvir => FALSE
                                   ,pr_tab_crapdat => rw_crapdat
                                   ,pr_inpessoa => vr_tab_craprda(idx).inpessoa
                                   ,pr_nrcpfcgc => vr_tab_craprda(idx).nrcpfcgc
                                   ,pr_vlsdrdca => vr_vlsldrdc
                                   ,pr_vlrdirrf => vr_vlrdirrf
                                   ,pr_perirrgt => vr_perirrgt
                                   ,pr_des_reto => vr_dscritic
                                   ,pr_tab_erro => vr_tab_erro);

          -- Verifica se retornou erro
          IF vr_dscritic = 'NOK' THEN
            -- Gerar mensagem com a descrição do erro
            IF vr_tab_erro.count > 0 THEN
              -- Buscar primeiro registro de erro
              vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            ELSE
              vr_dscritic := 'Nao foi possivel calcular o saldo da aplicacao RDCPRE';
            END IF;

            -- Gerar entrada no LOG de erro e continuar no próximo registro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic || ' ' ||
                                                          TO_CHAR(vr_tab_craprda(idx).nrdconta, 'FM9999G999G9') || ' ' || TO_CHAR(vr_tab_craprda(idx).nraplica, 'FM999G999')
                                      ,pr_nmarqlog     => 'PROC_BATCH');
            CONTINUE;
          END IF;
        ELSIF vr_tab_craprda(idx).tpaplrdc = 2 THEN
          -- Calcular saldo RDC POS
          apli0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                   ,pr_nrdconta => vr_tab_craprda(idx).nrdconta
                                   ,pr_craprda  => vr_craprda
                                   ,pr_dtmvtpap => rw_crapdat.dtmvtolt
                                   ,pr_dtcalsld => rw_crapdat.dtmvtolt
                                   ,pr_flantven => FALSE
                                   ,pr_flggrvir => FALSE
                                   ,pr_dtinitax => vr_dtinitax
                                   ,pr_dtfimtax => vr_dtfimtax
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_inpessoa => vr_tab_craprda(idx).inpessoa
                                   ,pr_nrcpfcgc => vr_tab_craprda(idx).nrcpfcgc
                                   ,pr_vlsdrdca => vr_vlsldrdc
                                   ,pr_vlrentot => vr_vlrentot
                                   ,pr_vlrdirrf => vr_vlrdirrf
                                   ,pr_perirrgt => vr_perirrgt
                                   ,pr_des_reto => vr_dscritic
                                   ,pr_tab_erro => vr_tab_erro);

          -- Verifica se retornou erro
          IF vr_dscritic = 'NOK' THEN
            -- Gerar mensagem com a descrição do erro
            IF vr_tab_erro.count > 0 THEN
              -- Buscar primeiro registro de erro
              vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            ELSE
              vr_dscritic := 'Nao foi possivel calcular o saldo da aplicacao RDCPOS';
            END IF;

            -- Gerar entrada no LOG de erro e continuar no próximo registro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic || ' ' ||
                                                          TO_CHAR(vr_tab_craprda(idx).nrdconta, 'FM9999G999G9') || ' ' || TO_CHAR(vr_tab_craprda(idx).nraplica, 'FM999G999')
                                      ,pr_nmarqlog     => 'PROC_BATCH');
            CONTINUE;
          END IF;
        END IF;

        -- Controlar pelo tipo
        IF vr_tab_craprda(idx).inpessoa = 1 THEN
          vr_tptelefo := 1;
        ELSE
          vr_tptelefo := 3;
        END IF;

        -- Limpar conteúdo da variável
        vr_nrramfon := NULL;

        IF vr_tab_craptfc.exists(LPAD(vr_tab_craprda(idx).nrdconta, 15, '0') || LPAD(vr_tptelefo, 3, '0')) THEN
           vr_nrramfon := vr_tab_craptfc(LPAD(vr_tab_craprda(idx).nrdconta, 15, '0') || LPAD(vr_tptelefo, 3, '0')).nrdddtfc ||
                          vr_tab_craptfc(LPAD(vr_tab_craprda(idx).nrdconta, 15, '0') || LPAD(vr_tptelefo, 3, '0')).nrtelefo;
        END IF;

        -- Gerar registros para relatório
        vr_xmlb := vr_xmlb || '<reg><cdagenci>' || vr_tab_craprda(idx).cdagenci || '</cdagenci>';
        vr_xmlb := vr_xmlb || '<nrdconta>' || TO_CHAR(vr_tab_craprda(idx).nrdconta, 'FM9999G999G9') || '</nrdconta>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
        vr_xmlb := vr_xmlb || '<nmprimtl>' || vr_tab_craprda(idx).nmprimtl || '</nmprimtl>';
        vr_xmlb := vr_xmlb || '<nraplica>' || TO_CHAR(vr_tab_craprda(idx).nraplica, 'FM999G999') || '</nraplica>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
        vr_xmlb := vr_xmlb || '<dtmvtolt>' || TO_CHAR(vr_tab_craprda(idx).dtmvtolt, 'DD/MM/RR') || '</dtmvtolt>';
        vr_xmlb := vr_xmlb || '<vlaplica>' || TO_CHAR(vr_tab_craprda(idx).vlaplica, 'FM999G999G999G990D00') || '</vlaplica>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
        vr_xmlb := vr_xmlb || '<dtvencto>' || TO_CHAR(vr_tab_craprda(idx).dtvencto, 'DD/MM/RR') || '</dtvencto>';
        vr_xmlb := vr_xmlb || '<vlsldrdc>' || TO_CHAR(vr_vlsldrdc, 'FM999G999G999G990D00') || '</vlsldrdc>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => FALSE, pr_clob => vr_xmlc);
        vr_xmlb := vr_xmlb || '<nrramfon>' || vr_nrramfon || '</nrramfon></reg>';

        -- Gerar relatório no último registro da agência
        IF vr_tab_craprda(idx).nrseqreg = vr_tab_craprda(idx).nrtotreg THEN
          -- Gerar nome do relatório segmentado por agencia
          vr_nmarqrel := 'crrl458_' || LPAD(vr_tab_craprda(idx).cdagenci, 3, '0') || '.lst';


          -- Finalizar buffer do CLOB
          vr_xmlb := vr_xmlb || '</regs></root>';
          gene0002.pc_clob_buffer(pr_dados => vr_xmlb, pr_gravfim => TRUE, pr_clob => vr_xmlc);

          -- Gerar relatório
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                     ,pr_cdprogra  => vr_cdprogra
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                     ,pr_dsxml     => vr_xmlc
                                     ,pr_dsxmlnode => '/root/regs/reg'
                                     ,pr_dsjasper  => 'crrl458.jasper'
                                     ,pr_dsparams  => NULL
                                     ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarqrel
                                     ,pr_flg_gerar => 'N'
                                     ,pr_qtcoluna  => 132
                                     ,pr_sqcabrel  => 1
                                     ,pr_cdrelato  => NULL
                                     ,pr_flg_impri => 'S'
                                     ,pr_nmformul  => '132col'
                                     ,pr_nrcopias  => 1
                                     ,pr_dsmailcop => NULL
                                     ,pr_dsassmail => NULL
                                     ,pr_dscormail => NULL
                                     ,pr_dspathcop => NULL
                                     ,pr_dsextcop  => NULL
                                     ,pr_flsemqueb => 'N'
                                     ,pr_des_erro  => vr_dscritic);

          -- Verifica se ocorreram erros
          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
          END IF;

          -- Apagar conteúdo do XML
          vr_clobtam := dbms_lob.getlength(vr_xmlc);
          dbms_lob.erase(vr_xmlc, vr_clobtam, 1);
          vr_xmlc := TRIM(vr_xmlc);

          -- Preparar XML para próximo arquivo
          vr_xmlb := '<?xml version="1.0" encoding="utf-8"?><root>';
        END IF;
      END LOOP;

	  END LOOP;

      CLOSE cr_capta;

      vr_tab_craprda.delete; -- limpa dados do bulk ja armazenado em outra pl table   

      -- Finalizar XML
      dbms_lob.freetemporary(vr_xmlc);

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

        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '|| vr_dscritic);

        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);

        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN

        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        
        cecred.pc_internal_exception(pr_cdcooper);
      
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps490;
/
