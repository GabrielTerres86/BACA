CREATE OR REPLACE PROCEDURE CECRED.pc_crps373(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps373 (Fontes/crps373.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Mirtes
       Data    : Dezembro/2003.                  Ultima atualizacao: 28/06/2016
       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Atende a solicitacao 102.(Cadeia 3/ Execucao em Paralelo)
                  (Para CENTRAL - solicitacao 70 - Cadeia 1/Execucao em Paralelo)
                   Efetuar os debitos do IPMF nas contas.
                   Relatorio 323

            No gnarrec.inpessoa = 3 vamos guardar os lancamentos do codigo de
            DARF igual a 5706, que contem o imposto de renda pago sobre os
            rendimentos do cotas capital tanto de pessoa fisica como
            juridica.

       Alteracao: 27/01/2004 - Prever novo histor de IR (Margarete).

                  16/12/2004 - Incluidos hist. 875/877/876(Ajuste IR)(Mirtes)

                  08/12/2005 - Controle para rodar de 10 em 10 dias e fazer o
                      recolhimento no 3o. dia util apos o fim do
                      periodo (Evandro).

                  17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                  09/06/2006 - Para o controle de 10 em 10 dias, se estiver no
                      ultimo decendio, atribuir ultimo dia do mes
                      (glb_dtultdia) para o final do periodo. (Julio)

                  09/11/2007 - Incluir 533(rdcpos) e 476(rdcpre) (Magui).

                  17/06/2008 - Incluir historicos 475 e 532 vindos do craplap
                      (Gabriel).

                  25/09/2009 - Precise - Paulo - Alterado programa para gravar
                      em tabela generica total dos impostos quando for
                      cooperativa diferente de 3 (diferenciando total
                      pessoa fisica de juridica). Quando for a Cecred (3)
                      lista relatorio adicional totalizando os impostos
                      de cada cooperativa.

                  03/11/2009 - Precise - Guilherme - Correcao da funcao Impostos
                      para processar a tabela crapcop. Correcao de
                      atribuicao de valores para vr_vlapagar e
                      vr_vlarecol e no vr_vlapagar recebendo o buffer

                  22/12/2009 - Inclusao da string "DO PERIODO" nas colunas
                      "IR A RECOLHER" de PF e  PJ (Guilherme/Precise)

                  25/02/2010 - Totalizar IOF a Pagar e IOF do Periodo (David).

                  23/02/2011 - Incluir os historicos 922 e 926 da craplct, e o
                      novo codigo de DARF 5706 (Vitor).

                    - Criar gnarrec.inpessoa = 3 quando valor for
                      <> 0 (Vitor).

                  22/10/2011 - Alterado a mascara do histor no FOR EACH (Ze).

                  05/12/2011 - Acerto no CAN-DO do historico 476 (Ze).

                  21/06/2012 - Substituido gncoper por crapcop (Tiago).

                  30/07/2012 - Ajuste do format no campo nmrescop (David Kruger).

                  23/08/2013 - Incluido o total de isenção tributária.

                  23/01/2014 - Conversão Progress -> Oracle (Petter - Supero).

                  07/03/2014 - Ajuste na lógica de busca da data (Marcos-Supero)

                  13/05/2014 - Ajuste na busca dos valores a pagar dos decidios anteriores(Odirlei/AMcom)

                  29/08/2014 - Adicionado tratamento para lançamentos de produtos
                               de captação. (Reinert)

                 27/06/2016 - M325 - Tributacao Juros ao Capital
                              Nao gerar pc_imposto para inpessoa 3 (Guilherme/SUPERO)
    ............................................................................ */

    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra       CONSTANT crapprg.cdprogra%TYPE := 'CRPS373';
      vr_rel_dsperiod   VARCHAR2(100);
      vr_dtrecolh       DATE;
      vr_contador       PLS_INTEGER;
      vr_vlr588_f       NUMBER(20,2) := 0;
      vr_qtd588_f       NUMBER(20,2) := 0;
      vr_vlr864_f       NUMBER(20,2) := 0;
      vr_qtd864_f       PLS_INTEGER := 0;
      vr_vlr868_f       NUMBER(20,2) := 0;
      vr_qtd868_f       PLS_INTEGER := 0;
      vr_vlr870_f       NUMBER(20,2) := 0;
      vr_qtd870_f       PLS_INTEGER := 0;
      vr_vlr871_f       NUMBER(20,2) := 0;
      vr_qtd871_f       PLS_INTEGER := 0;
      vr_vlr588_j       NUMBER(20,2) := 0;
      vr_qtd588_j       PLS_INTEGER := 0;
      vr_vlr864_j       NUMBER(20,2) := 0;
      vr_qtd864_j       PLS_INTEGER := 0;
      vr_vlr868_j       NUMBER(20,2) := 0;
      vr_qtd868_j       PLS_INTEGER := 0;
      vr_vlr870_j       NUMBER(20,2) := 0;
      vr_qtd870_j       PLS_INTEGER := 0;
      vr_vlr871_j       NUMBER(20,2) := 0;
      vr_qtd871_j       PLS_INTEGER := 0;
      vr_vlr861_f       NUMBER(20,2) := 0;
      vr_qtd861_f       PLS_INTEGER := 0;
      vr_vlr862_f       NUMBER(20,2) := 0;
      vr_qtd862_f       PLS_INTEGER := 0;
      vr_vlr116_f       NUMBER(20,2) := 0;
      vr_qtd116_f       PLS_INTEGER := 0;
      vr_vlr179_f       NUMBER(20,2) := 0;
      vr_qtd179_f       PLS_INTEGER := 0;
      vr_vlr861_j       NUMBER(20,2) := 0;
      vr_qtd861_j       PLS_INTEGER := 0;
      vr_vlr862_j       NUMBER(20,2) := 0;
      vr_qtd862_j       PLS_INTEGER := 0;
      vr_vlr116_j       NUMBER(20,2) := 0;
      vr_qtd116_j       PLS_INTEGER := 0;
      vr_vlr179_j       NUMBER(20,2) := 0;
      vr_qtd179_j       PLS_INTEGER := 0;
      vr_vlr475_j       NUMBER(20,2) := 0;
      vr_qtd475_j       PLS_INTEGER := 0;
      vr_vlr532_j       NUMBER(20,2) := 0;
      vr_qtd532_j       PLS_INTEGER := 0;
      vr_vlr533_j       NUMBER(20,2) := 0;
      vr_qtd533_j       PLS_INTEGER := 0;
      vr_vlr476_j       NUMBER(20,2) := 0;
      vr_qtd476_j       PLS_INTEGER := 0;
      vr_vlr475_f       NUMBER(20,2) := 0;
      vr_qtd475_f       PLS_INTEGER := 0;
      vr_vlr532_f       NUMBER(20,2) := 0;
      vr_qtd532_f       PLS_INTEGER := 0;
      vr_vlr533_f       NUMBER(20,2) := 0;
      vr_qtd533_f       PLS_INTEGER := 0;
      vr_vlr476_f       NUMBER(20,2) := 0;
      vr_qtd476_f       PLS_INTEGER := 0;
      vr_vlr151_f       NUMBER(20,2) := 0;
      vr_qtd151_f       PLS_INTEGER := 0;
      vr_vlr863_f       NUMBER(20,2) := 0;
      vr_qtd863_f       PLS_INTEGER := 0;
      vr_vlr151_j       NUMBER(20,2) := 0;
      vr_qtd151_j       PLS_INTEGER := 0;
      vr_vlr863_j       NUMBER(20,2) := 0;
      vr_qtd863_j       PLS_INTEGER := 0;
      vr_vlr875_j       NUMBER(20,2) := 0;
      vr_qtd875_j       PLS_INTEGER := 0;
      vr_vlr876_j       NUMBER(20,2) := 0;
      vr_qtd876_j       PLS_INTEGER := 0;
      vr_vlr877_j       NUMBER(20,2) := 0;
      vr_qtd877_j       PLS_INTEGER := 0;
      vr_vlr875_f       NUMBER(20,2) := 0;
      vr_qtd875_f       PLS_INTEGER := 0;
      vr_vlr876_f       NUMBER(20,2) := 0;
      vr_qtd876_f       PLS_INTEGER := 0;
      vr_vlr877_f       NUMBER(20,2) := 0;
      vr_qtd877_f       PLS_INTEGER := 0;
      vr_vlr922_fj      NUMBER(20,2) := 0;
      vr_qtd922_fj      PLS_INTEGER := 0;
      vr_vlr926_fj      NUMBER(20,2) := 0;
      vr_data_inicio    DATE;
      vr_data_fim       DATE;
      vr_baslan_f       NUMBER(20,2) := 0;
      vr_deblan_f       NUMBER(20,2) := 0;
      vr_qtdlan_f       PLS_INTEGER := 0;
      vr_baslan_j       NUMBER(20,2) := 0;
      vr_deblan_j       NUMBER(20,2) := 0;
      vr_qtdlan_j       PLS_INTEGER := 0;
      vr_vlirap_j       NUMBER(20,2) := 0;
      vr_vlirct_j       NUMBER(20,2) := 0;
      vr_baslan_fj      NUMBER(20,2) := 0;
      vr_deblan_fj      NUMBER(20,2) := 0;
      vr_qtdlan_fj      PLS_INTEGER := 0;
      vr_rel_nmrescop   VARCHAR2(100) := 0;
      vr_rel_nrdocnpj   VARCHAR2(100) := 0;
      vr_vlapagar       NUMBER(20,2) := 0;
      vr_vlarecol       NUMBER(20,2) := 0;
      vr_tot_vlapagar   NUMBER(20,2) := 0;
      vr_tot_vlarecol   NUMBER(20,2) := 0;
      vr_xprimpf        PLS_INTEGER := 0;
      vr_xprimpj        PLS_INTEGER := 0;
      vr_xprimpfj       PLS_INTEGER := 0;
      vr_achou          PLS_INTEGER := 0;
      vr_inpessoa       PLS_INTEGER := 0;
      vr_flgprint       BOOLEAN;
      vr_dtinipmf       DATE;
      vr_dtfimpmf       DATE;
      vr_txcpmfcc       NUMBER := 0;
      vr_txrdcpmf       NUMBER := 0;
      vr_indabono       PLS_INTEGER := 0;
      vr_dtiniabo       DATE;
      vr_bfclob         VARCHAR2(32767);
      vr_xmlclob        CLOB;
      vr_deblan_a       NUMBER(20,2) := 0;
      vr_nom_dir        VARCHAR2(4000);

      -- Variáveis dos lançamentos de aplicações de captação
      vr_qtdrend_lac_f PLS_INTEGER := 0;
      vr_vlrrend_lac_f NUMBER(20,2) := 0;
      vr_qtdrend_lac_j PLS_INTEGER := 0;
      vr_vlrrend_lac_j NUMBER(20,2) := 0;
      vr_qtdirrf_lac_f PLS_INTEGER := 0;
      vr_vlrirrf_lac_f NUMBER(20,2) := 0;
      vr_qtdirrf_lac_j PLS_INTEGER := 0;
      vr_vlrirrf_lac_j NUMBER(20,2) := 0;

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- PLTable para armazenar históricos da crapcpc
      TYPE typ_cdhistor      IS RECORD (cdhsrdap crapcpc.cdhsrdap%TYPE
                                       ,cdhsirap crapcpc.cdhsirap%TYPE);
      TYPE typ_cdhistor_tab  IS TABLE OF typ_cdhistor INDEX BY PLS_INTEGER;
      vr_tab_hist      typ_cdhistor_tab;

      ------------------------------- CURSORES ---------------------------------
      /* Busca dos dados da cooperativa */
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      /* Buscar valor da moeda fix do sistema */
      CURSOR cr_crapfmx(pr_cdcooper IN crapmfx.cdcooper%TYPE     --> Código da cooperativa
                       ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE) IS --> Data de movimento
        SELECT cx.vlmoefix
        FROM crapmfx cx
        WHERE cx.cdcooper = pr_cdcooper
          AND cx.dtmvtolt = pr_dtmvtolt
          AND cx.tpmoefix = 2;
      rw_crapfmx cr_crapfmx%ROWTYPE;

      /* Buscar informações da tabela de feríados */
      CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_dtrecolh IN crapfer.dtferiad%TYPE) IS  --> Data de recolhimento
        SELECT cf.dsferiad
        FROM crapfer cf
        WHERE cf.cdcooper = pr_cdcooper
          AND cf.dtferiad = pr_dtrecolh;
      rw_crapfer cr_crapfer%ROWTYPE;

      /* Buscar dados de insentos de IOF e IRRF */
      CURSOR cr_crapvin(pr_cdcooper    IN crapvin.cdcooper%TYPE     --> Código da cooperativa
                       ,pr_data_inicio IN crapvin.dtmvtolt%TYPE     --> Data inicial
                       ,pr_data_fim    IN crapvin.dtmvtolt%TYPE) IS --> Data final
        SELECT cv.cdinsenc
              ,cv.vlinsenc
        FROM crapvin cv
        WHERE cv.cdcooper = pr_cdcooper
          AND cv.dtmvtolt BETWEEN pr_data_inicio AND pr_data_fim
          AND cv.cdinsenc >= 5;

      /* Buscar dados de investimentos por associado */
      CURSOR cr_craplcmass(pr_cdcooper    IN craplcm.cdcooper%TYPE     --> Código da cooperativa
                          ,pr_data_inicio IN crapvin.dtmvtolt%TYPE     --> Data inicial
                          ,pr_data_fim    IN crapvin.dtmvtolt%TYPE) IS --> Data final
        SELECT cs.inpessoa
              ,cm.cdhistor
              ,cm.vllanmto
        FROM craplcm cm, crapass cs
        WHERE cm.cdcooper = pr_cdcooper
          AND cm.dtmvtolt BETWEEN pr_data_inicio AND pr_data_fim
          AND cm.cdhistor IN (588, 864)
          AND cs.cdcooper = cm.cdcooper
          AND cs.nrdconta = cm.nrdconta;

      /* Buscar lançamentos RDCA por associado */
      CURSOR cr_craplapass(pr_cdcooper    IN craplap.cdcooper%TYPE     --> Código da cooperativa
                          ,pr_data_inicio IN craplap.dtmvtolt%TYPE     --> Data inicial
                          ,pr_data_fim    IN craplap.dtmvtolt%TYPE) IS --> Data final
        SELECT cs.inpessoa
              ,cl.cdhistor
              ,cl.vllanmto
              ,cs.nrdconta
        FROM craplap cl, crapass cs
        WHERE cl.cdcooper = pr_cdcooper
          AND cl.dtmvtolt BETWEEN pr_data_inicio AND pr_data_fim
          AND cl.cdhistor IN (533, 476, 861, 862, 868, 871, 116, 179, 875, 876, 877, 475, 532)
          AND cs.cdcooper = cl.cdcooper
          AND cs.nrdconta = cl.nrdconta;

      -- Buscar lançamentos de aplicações de captação
      CURSOR cr_craplacass(pr_cdcooper       IN craplac.cdcooper%TYPE
                          ,pr_data_inicio    IN craplac.dtmvtolt%TYPE
                          ,pr_data_fim       IN craplac.dtmvtolt%TYPE
                          ,pr_cdhistor       IN craplac.cdhistor%TYPE) IS
      SELECT crapass.inpessoa,
             craplac.cdhistor,
             craplac.vllanmto
        FROM craplac,
             crapass
       WHERE craplac.cdcooper  = pr_cdcooper                         AND
             craplac.dtmvtolt BETWEEN pr_data_inicio AND pr_data_fim AND
             craplac.cdhistor  = pr_cdhistor                         AND
             crapass.cdcooper  = craplac.cdcooper                    AND
             crapass.nrdconta  = craplac.nrdconta;


      /* Buscar dados das aplicações programadas em poupança */
      CURSOR cr_craplppass(pr_cdcooper    IN craplpp.cdcooper%TYPE     --> Código da cooperativa
                          ,pr_data_inicio IN craplpp.dtmvtolt%TYPE     --> Data inicial
                          ,pr_data_fim    IN craplpp.dtmvtolt%TYPE) IS --> Data final
        SELECT cs.inpessoa
              ,cp.cdhistor
              ,cp.vllanmto
        FROM craplpp cp, crapass cs
        WHERE cp.cdcooper = pr_cdcooper
          AND cp.dtmvtolt BETWEEN pr_data_inicio AND pr_data_fim
          AND cp.cdhistor IN (863, 151, 870)
          AND cs.cdcooper = cp.cdcooper
          AND cs.nrdconta = cp.nrdconta;

      /* Busca dados de lançamentos de cotas/capital */
      CURSOR cr_craplct(pr_cdcooper    IN craplct.cdcooper%TYPE     --> Código da cooperativa
                       ,pr_data_inicio IN craplct.dtmvtolt%TYPE     --> Data inicial
                       ,pr_data_fim    IN craplct.dtmvtolt%TYPE) IS --> Data final
        SELECT ct.cdhistor
              ,ct.vllanmto
        FROM craplct ct
        WHERE ct.cdcooper = pr_cdcooper
          AND ct.dtmvtolt BETWEEN pr_data_inicio AND pr_data_fim
          AND ct.cdhistor IN (922, 926);


      /* Cálcular o imposto para cada tipo de pessoa */
      PROCEDURE pc_imposto(pr_inpessoa IN PLS_INTEGER  --> Indicação do tipo de pessoa
                          ,pr_dscritic OUT VARCHAR) IS --> Descrição do erro
      BEGIN
        DECLARE
          vr_erro         EXCEPTION;
          vr_bufimpo      VARCHAR2(32767);
          vr_codtransac   VARCHAR2(10);
          vr_nometit      VARCHAR2(400);

          /* Busca dados sobre as cooperativas */
          CURSOR cr_crapcop IS
            SELECT co.nmrescop
                  ,co.nrdocnpj
                  ,co.cdcooper
            FROM crapcop co
            WHERE co.cdcooper <> 3
            ORDER BY co.cdcooper;

          /* Busca dados de lançamentos de IR */
          CURSOR cr_gnarrec(pr_cdcooper    IN gnarrec.cdcooper%TYPE      --> Código da cooperativa
                           ,pr_data_inicio IN gnarrec.dtiniapu%TYPE      --> Data de apuração
                           ,pr_inpessoa    IN gnarrec.inpessoa%TYPE      --> Tipo de pessoa de cálculo
                           ,pr_inapagar    IN gnarrec.inapagar%TYPE) IS  --> Indicador de pagamento do imposto
            SELECT gc.vlrecolh
                  ,gc.rowid
            FROM gnarrec gc
            WHERE gc.cdcooper = pr_cdcooper
              AND gc.dtiniapu = pr_data_inicio
              AND gc.inpessoa = pr_inpessoa
              AND gc.tpimpost = 2
              AND gc.inapagar = NVL(pr_inapagar, gc.inapagar);
          rw_gnarrec cr_gnarrec%ROWTYPE;

          /* Buscar valores de decendios anteriores nao recolhidos*/
          CURSOR cr_gnarrec_ant(pr_cdcooper    IN gnarrec.cdcooper%TYPE      --> Código da cooperativa
                               ,pr_data_inicio IN gnarrec.dtiniapu%TYPE      --> Data de apuração
                               ,pr_inpessoa    IN gnarrec.inpessoa%TYPE      --> Tipo de pessoa de cálculo
                               ,pr_inapagar    IN gnarrec.inapagar%TYPE) IS  --> Indicador de pagamento do imposto
            SELECT gc.vlrecolh
                  ,gc.rowid
            FROM gnarrec gc
            WHERE gc.cdcooper = pr_cdcooper
              AND gc.dtiniapu < pr_data_inicio
              AND gc.inpessoa = pr_inpessoa
              AND gc.tpimpost = 2
              AND gc.inapagar = NVL(pr_inapagar, gc.inapagar);

        BEGIN
          -- Zerar valores das variáveis
          vr_tot_vlapagar := 0;
          vr_tot_vlarecol := 0;
          vr_flgprint := FALSE;

          -- Atribuir valor para o tipo transacionado
          IF pr_inpessoa = 1 THEN
            vr_codtransac := '8053';
            vr_nometit := '** I.R.R.F. DOS ASSOCIADOS (PESSOA FISICA) ** COD. DARF ' || vr_codtransac;
          ELSIF pr_inpessoa = 2 THEN
            vr_codtransac := '3426';
            vr_nometit := '** I.R.R.F. DOS ASSOCIADOS (PESSOA JURIDICA) ** COD. DARF ' || vr_codtransac;
          ELSIF pr_inpessoa = 3 THEN
            vr_codtransac := '5706';
            vr_nometit := '** I.R.R.F. DOS ASSOCIADOS (PESSOA FISICA/JURIDICA) ** COD. DARF ' || vr_codtransac;
          END IF;

          -- Iterar sobre as cooperativas
          FOR rw_crapcop IN cr_crapcop LOOP
            vr_rel_nmrescop := rw_crapcop.nmrescop;
            vr_rel_nrdocnpj := regexp_replace(LPAD(rw_crapcop.nrdocnpj, 15, '0'),'([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})','\1.\2.\3/\4-\5');

            -- Buscar dados dos lançamentos de cálculo de IR
            OPEN cr_gnarrec(rw_crapcop.cdcooper, vr_data_inicio, pr_inpessoa, NULL);
            FETCH cr_gnarrec INTO rw_gnarrec;

            -- Verifica se a tupla retornou registros
            IF cr_gnarrec%NOTFOUND THEN
              CLOSE cr_gnarrec;
              CONTINUE;
            ELSE
              CLOSE cr_gnarrec;
              vr_flgprint := TRUE;
            END IF;

            -- Armazenar valores
            vr_vlapagar := rw_gnarrec.vlrecolh;
            vr_vlarecol := rw_gnarrec.vlrecolh;
            vr_achou := 0;

            -- Pegar valores de decendios anteriores nao recolhidos
            FOR regs IN cr_gnarrec_ant(rw_crapcop.cdcooper, vr_data_inicio, pr_inpessoa, 1) LOOP
              vr_vlapagar := vr_vlapagar + regs.vlrecolh;
              vr_achou := 1;
            END LOOP;

            -- Limite minimo fixado de R$ 10 para recolhimento do periodo */
            IF vr_vlapagar >= 10 THEN
              BEGIN
                UPDATE gnarrec rec
                SET rec.vlapagar = vr_vlapagar
                   ,rec.inapagar = 0
                WHERE rec.rowid = rw_gnarrec.rowid;

                -- Marca decendios anterios como recolhido
                IF vr_achou = 1 THEN
                  UPDATE gnarrec rec
                  SET rec.inapagar = 0
                  WHERE rec.cdcooper = rw_crapcop.cdcooper
                    AND rec.dtiniapu < vr_data_inicio
                    AND rec.inpessoa = pr_inpessoa
                    AND rec.tpimpost = 2
                    AND rec.inapagar = 1;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro em PC_IMPOSTO. ' || SQLERRM;
                  RAISE vr_erro;
              END;
            ELSE
              vr_vlapagar := 0;
            END IF;

            -- Gerar valores
            vr_tot_vlapagar := vr_tot_vlapagar + vr_vlapagar;
            vr_tot_vlarecol := vr_tot_vlarecol + vr_vlarecol;

            -- Controlar informações geradas no relatório por tipo de pessoa
            IF vr_xprimpf = 0 AND vr_inpessoa = 1 THEN
              vr_xprimpf := 1;

              vr_bufimpo := vr_bufimpo || '<cons_pf><rel_dsperiod>' || vr_rel_dsperiod || '</rel_dsperiod>' ||
                                        '<vr_dtrecolh>' || vr_dtrecolh || '</vr_dtrecolh></cons_pf>';
              --gene0002.pc_clob_buffer(pr_dados => vr_bfclob, pr_gravfim => FALSE, pr_clob => vr_xmlclob);
            ELSIF vr_xprimpj = 0 AND vr_inpessoa = 2 THEN
              vr_xprimpj := 1;

              vr_bufimpo := vr_bufimpo || '<cons_pj><rel_dsperiod>' || vr_rel_dsperiod || '</rel_dsperiod>' ||
                                        '<vr_dtrecolh>' || vr_dtrecolh || '</vr_dtrecolh></cons_pj>';
              --gene0002.pc_clob_buffer(pr_dados => vr_bfclob, pr_gravfim => FALSE, pr_clob => vr_xmlclob);
            ELSIF vr_xprimpfj = 0 AND vr_inpessoa = 3 THEN
              vr_xprimpfj := 1;

              vr_bufimpo := vr_bufimpo || '<cons_pfj><rel_dsperiod>' || vr_rel_dsperiod || '</rel_dsperiod>' ||
                                        '<vr_dtrecolh>' || vr_dtrecolh || '</vr_dtrecolh></cons_pfj>';
              --gene0002.pc_clob_buffer(pr_dados => vr_bfclob, pr_gravfim => FALSE, pr_clob => vr_xmlclob);
            END IF;

            -- Gerar informações para relatório
            vr_bufimpo := vr_bufimpo || '<imposto><rel_nmrescop>' || vr_rel_nmrescop || '</rel_nmrescop>' ||
                                      '<rel_nrdocnpj>' || vr_rel_nrdocnpj || '</rel_nrdocnpj>' ||
                                      '<vlarecol>' || TO_CHAR(vr_vlarecol, 'FM999G999G999G990D00') || '</vlarecol>' ||
                                      '<vlapagar>' || TO_CHAR(vr_vlapagar, 'FM999G999G999G990D00') || '</vlapagar></imposto>';
            --gene0002.pc_clob_buffer(pr_dados => vr_bfclob, pr_gravfim => FALSE, pr_clob => vr_xmlclob);
          END LOOP;

          -- Gerar informações para relatório no caso de existir totalização
          IF vr_flgprint = TRUE THEN
            vr_bfclob := vr_bfclob || '<impostos ctrl="' || pr_cdcooper || '" tipo="' || vr_codtransac ||
                                      '" vlarecol="' || TO_CHAR(vr_tot_vlarecol, 'FM999G999G999G990D00') ||
                                      '" vlapagar="' || TO_CHAR(vr_tot_vlapagar, 'FM999G999G999G990D00') ||
                                      '" desc="' || vr_nometit || '">';
          ELSE
            vr_bfclob := vr_bfclob || '<impostos ctrl="' || pr_cdcooper || '" tipo="' || vr_codtransac || '" vlarecol="0" vlapagar="0" ' ||
                                      'desc="' || vr_nometit || '">';
          END IF;

          -- Gerar saída do fragmento XML para o CLOB
          vr_bfclob := vr_bfclob || vr_bufimpo || '</impostos>';
          gene0002.pc_clob_buffer(pr_dados => vr_bfclob, pr_gravfim => FALSE, pr_clob => vr_xmlclob);

        EXCEPTION
          WHEN vr_erro THEN

            pr_dscritic := pr_dscritic;
          WHEN OTHERS THEN
            pr_dscritic := 'Erro em  PC_IMPOSTO: ' || SQLERRM;
        END;
      END pc_imposto;

    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => null);

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

      -- Capturar o path do arquivo
      vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl');

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
      gene0005.pc_busca_cpmf(pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_dtinipmf => vr_dtinipmf
                            ,pr_dtfimpmf => vr_dtfimpmf
                            ,pr_txcpmfcc => vr_txcpmfcc
                            ,pr_txrdcpmf => vr_txrdcpmf
                            ,pr_indabono => vr_indabono
                            ,pr_dtiniabo => vr_dtiniabo
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreram erros no processo
      IF NVL(vr_cdcritic, 0) > 0 THEN
        RAISE vr_exc_fimprg;
      END IF;

      -- Buscar dados de moeda fixa no sistema
      OPEN cr_crapfmx(pr_cdcooper, rw_crapdat.dtmvtolt);
      FETCH cr_crapfmx INTO rw_crapfmx;

      -- Verifica se a tupla retornou registros
      IF cr_crapfmx%NOTFOUND THEN
        vr_cdcritic := 140;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                         ,pr_ind_tipo_log => 2 -- Erro tratato
                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || vr_dscritic || ' - UFIR');
      ELSE
        CLOSE cr_crapfmx;
      END IF;

      -- Validar intervalo de datas
      -- Primeiro/segundo/terceiro decendio
      IF TO_CHAR(rw_crapdat.dtmvtolt, 'DD') <= 10 AND TO_CHAR(rw_crapdat.dtmvtopr, 'DD') > 10 THEN
        vr_data_inicio := TO_DATE('01' || TO_CHAR(rw_crapdat.dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
        vr_data_fim := TO_DATE('10' || TO_CHAR(rw_crapdat.dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
      ELSIF TO_CHAR(rw_crapdat.dtmvtolt, 'DD') <= 20 AND TO_CHAR(rw_crapdat.dtmvtopr, 'DD') > 20 THEN
        vr_data_inicio := TO_DATE('11' || TO_CHAR(rw_crapdat.dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
        vr_data_fim := TO_DATE('20' || TO_CHAR(rw_crapdat.dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
      ELSIF TO_CHAR(rw_crapdat.dtmvtolt, 'MM') <> TO_CHAR(rw_crapdat.dtmvtopr, 'MM') THEN
        vr_data_inicio := TO_DATE('21' || TO_CHAR(rw_crapdat.dtmvtolt, '/MM/RRRR'), 'DD/MM/RRRR');
        vr_data_fim := rw_crapdat.dtultdia;
      ELSE
        --Se não definiu as datas, indica que não deve ser rodado neste data
        vr_dscritic := 'Data invalida, programa deve rodar apenas no dia 10, 20 ou virada do mes!';
        raise vr_exc_fimprg;
      END IF;

      -- Data de recolhimento - 3o. dia util depois do decendio
      vr_dtrecolh := vr_data_fim + 1;
      vr_contador := 0;

      -- Fazer varredura até encontrar data util
      LOOP
        -- Busca se a data é feriado
        -- Buscar data de processamento
        OPEN cr_crapfer(pr_cdcooper, vr_dtrecolh);
        FETCH cr_crapfer INTO rw_crapfer;
        -- Se a data não for sabado ou domingo ou feriado
        IF NOT(TO_CHAR(vr_dtrecolh, 'd') IN (1,7) OR cr_crapfer%FOUND) THEN
          vr_contador := vr_contador + 1;
        END IF;
        --
        close cr_crapfer;
        -- Sair quando encontrar o 3º dia apos
        exit when vr_contador >= 3;
        -- Incrementar data
        vr_dtrecolh := vr_dtrecolh + 1;
      END LOOP;

      -- Busca próximo dia útil considerando feriados e finais de semana
      vr_dtrecolh := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => vr_dtrecolh
                                                ,pr_tipo => 'P');

      -- Validar IRRF isento
      FOR rw_crapvin IN cr_crapvin(pr_cdcooper, vr_data_inicio, vr_data_fim) LOOP
        IF rw_crapvin.cdinsenc = 6 THEN
          vr_vlirct_j := vr_vlirct_j + NVL(rw_crapvin.vlinsenc, 0);
        ELSE
          vr_vlirap_j := vr_vlirap_j + NVL(rw_crapvin.vlinsenc, 0);
        END IF;
      END LOOP;

      -- Processar lançamentos
      FOR rw_craplcmass in  cr_craplcmass(pr_cdcooper, vr_data_inicio, vr_data_fim) LOOP
        IF rw_craplcmass.inpessoa = 1 THEN
          IF rw_craplcmass.cdhistor = 588 THEN
            vr_vlr588_f := vr_vlr588_f + NVL(rw_craplcmass.vllanmto, 0);
            vr_qtd588_f := vr_qtd588_f + 1;
          ELSE
            vr_vlr864_f := vr_vlr864_f + NVL(rw_craplcmass.vllanmto, 0);
            vr_qtd864_f := vr_qtd864_f + 1;
          END IF;
        ELSE
          IF rw_craplcmass.cdhistor = 588 THEN
            vr_vlr588_j := vr_vlr588_j + NVL(rw_craplcmass.vllanmto, 0);
            vr_qtd588_j := vr_qtd588_j + 1;
          ELSE
            vr_vlr864_j := vr_vlr864_j + NVL(rw_craplcmass.vllanmto, 0);
            vr_qtd864_j := vr_qtd864_j + 1;
          END IF;
        END IF;
      END LOOP;

      -- Processar lançamentos RDCA
      FOR rw_craplapass IN cr_craplapass(pr_cdcooper, vr_data_inicio, vr_data_fim) LOOP
        IF rw_craplapass.inpessoa = 1 THEN
          IF rw_craplapass.cdhistor = 533 THEN
            vr_vlr533_f := vr_vlr533_f + rw_craplapass.vllanmto;
            vr_qtd533_f := vr_qtd533_f + 1;
          ELSIF rw_craplapass.cdhistor = 476 THEN
            vr_vlr476_f := vr_vlr476_f + rw_craplapass.vllanmto;
            vr_qtd476_f := vr_qtd476_f + 1;
          ELSIF rw_craplapass.cdhistor = 861 THEN
            vr_vlr861_f := vr_vlr861_f + rw_craplapass.vllanmto;
            vr_qtd861_f := vr_qtd861_f + 1;
          ELSIF  rw_craplapass.cdhistor = 862 THEN
            vr_vlr862_f := vr_vlr862_f + rw_craplapass.vllanmto;
            vr_qtd862_f := vr_qtd862_f + 1;
          ELSIF rw_craplapass.cdhistor = 875 THEN
            vr_vlr875_f := vr_vlr875_f + rw_craplapass.vllanmto;
            vr_qtd875_f := vr_qtd875_f + 1;
          ELSIF rw_craplapass.cdhistor = 876 THEN
            vr_vlr876_f := vr_vlr876_f + rw_craplapass.vllanmto;
            vr_qtd876_f := vr_qtd876_f + 1;
          ELSIF rw_craplapass.cdhistor = 877 THEN
            vr_vlr877_f := vr_vlr877_f + rw_craplapass.vllanmto;
            vr_qtd877_f := vr_qtd877_f + 1;
          ELSIF rw_craplapass.cdhistor = 116 THEN
            vr_vlr116_f := vr_vlr116_f + rw_craplapass.vllanmto;
            vr_qtd116_f := vr_qtd116_f + 1;
          ELSIF rw_craplapass.cdhistor = 868 THEN
            vr_vlr868_f := vr_vlr868_f + rw_craplapass.vllanmto;
            vr_qtd868_f := vr_qtd868_f + 1;
          ELSIF rw_craplapass.cdhistor = 871 THEN
            vr_vlr871_f := vr_vlr871_f + rw_craplapass.vllanmto;
            vr_qtd871_f := vr_qtd871_f + 1;
          ELSIF rw_craplapass.cdhistor = 475 THEN
            vr_vlr475_f := vr_vlr475_f + rw_craplapass.vllanmto;
            vr_qtd475_f := vr_qtd475_f + 1;
          ELSIF rw_craplapass.cdhistor = 532 THEN
            vr_vlr532_f := vr_vlr532_f + rw_craplapass.vllanmto;
            vr_qtd532_f := vr_qtd532_f + 1;
          ELSE
            vr_vlr179_f := vr_vlr179_f + rw_craplapass.vllanmto;
            vr_qtd179_f := vr_qtd179_f + 1;
          END IF;
        ELSE
          IF rw_craplapass.cdhistor = 533 THEN
            vr_vlr533_j := vr_vlr533_j + rw_craplapass.vllanmto;
            vr_qtd533_j := vr_qtd533_j + 1;
          ELSIF rw_craplapass.cdhistor = 476 THEN
            vr_vlr476_j := vr_vlr476_j + rw_craplapass.vllanmto;
            vr_qtd476_j := vr_qtd476_j + 1;
          ELSIF rw_craplapass.cdhistor = 861 THEN
            vr_vlr861_j := vr_vlr861_j + rw_craplapass.vllanmto;
            vr_qtd861_j := vr_qtd861_j + 1;
          ELSIF rw_craplapass.cdhistor = 862 THEN
            vr_vlr862_j := vr_vlr862_j + rw_craplapass.vllanmto;
            vr_qtd862_j := vr_qtd862_j + 1;
          ELSIF rw_craplapass.cdhistor = 875 THEN
            vr_vlr875_j := vr_vlr875_j + rw_craplapass.vllanmto;
            vr_qtd875_j := vr_qtd875_j + 1;
          ELSIF rw_craplapass.cdhistor = 876 THEN
            vr_vlr876_j := vr_vlr876_j + rw_craplapass.vllanmto;
            vr_qtd876_j := vr_qtd876_j + 1;
          ELSIF rw_craplapass.cdhistor = 877 THEN
            vr_vlr877_j := vr_vlr877_j + rw_craplapass.vllanmto;
            vr_qtd877_j := vr_qtd877_j + 1;
          ELSIF rw_craplapass.cdhistor = 868 THEN
            vr_vlr868_j := vr_vlr868_j + rw_craplapass.vllanmto;
            vr_qtd868_j := vr_qtd868_j + 1;
          ELSIF rw_craplapass.cdhistor = 871 THEN
            vr_vlr871_j := vr_vlr871_j + rw_craplapass.vllanmto;
            vr_qtd871_j := vr_qtd871_j + 1;
          ELSIF rw_craplapass.cdhistor = 116 THEN
            vr_vlr116_j := vr_vlr116_j + rw_craplapass.vllanmto;
            vr_qtd116_j := vr_qtd116_j + 1;
          ELSIF rw_craplapass.cdhistor = 475 THEN
            vr_vlr475_j := vr_vlr475_j + rw_craplapass.vllanmto;
            vr_qtd475_j := vr_qtd475_j + 1;
          ELSIF rw_craplapass.cdhistor = 532 THEN
            vr_vlr532_j := vr_vlr532_j + rw_craplapass.vllanmto;
            vr_qtd532_j := vr_qtd532_j + 1;
          ELSE
            vr_vlr179_j := vr_vlr179_j + rw_craplapass.vllanmto;
            vr_qtd179_j := vr_qtd179_j + 1;
          END IF;
        END IF;
      END LOOP;

      vr_contador := 0;

      -- Para cada produto de captação
      FOR rw_crapcpc IN (SELECT cpc.cdhsrdap,
                                cpc.cdhsirap
                           FROM crapcpc cpc) LOOP
        -- Incrementa indice da wt
        vr_contador := vr_contador + 1;
        -- Armazena os históricos na wt
        vr_tab_hist(vr_contador).cdhsrdap := rw_crapcpc.cdhsrdap;
        vr_tab_hist(vr_contador).cdhsirap := rw_crapcpc.cdhsirap;
      END LOOP;

      -- Para cada histórico dos produtos de captação
      FOR vr_cont IN 1..vr_tab_hist.COUNT LOOP

        -- Soma quantidade e valor dos lançamentos de rendimento
        FOR rw_craplacass IN cr_craplacass(pr_cdcooper    => pr_cdcooper
                                          ,pr_data_inicio => vr_data_inicio
                                          ,pr_data_fim    => vr_data_fim
                                          ,pr_cdhistor    => vr_tab_hist(vr_cont).cdhsrdap) LOOP

          IF rw_craplacass.inpessoa = 1 THEN /* Pessoa Física */
            vr_qtdrend_lac_f := vr_qtdrend_lac_f + 1;
            vr_vlrrend_lac_f := vr_vlrrend_lac_f + rw_craplacass.vllanmto;
          ELSE /* Pessoa Jurídica */
            vr_qtdrend_lac_j := vr_qtdrend_lac_j + 1;
            vr_vlrrend_lac_j := vr_vlrrend_lac_j + rw_craplacass.vllanmto;
          END IF;

        END LOOP;

        -- Soma quantidade e valor dos lançamentos de IRRF
        FOR rw_craplacass IN cr_craplacass(pr_cdcooper    => pr_cdcooper
                                          ,pr_data_inicio => vr_data_inicio
                                          ,pr_data_fim    => vr_data_fim
                                          ,pr_cdhistor    => vr_tab_hist(vr_cont).cdhsirap) LOOP
          IF rw_craplacass.inpessoa = 1 THEN /* Pessoa Física */
            vr_qtdirrf_lac_f := vr_qtdirrf_lac_f + 1;
            vr_vlrirrf_lac_f := vr_vlrirrf_lac_f + rw_craplacass.vllanmto;
          ELSE /* Pessoa Jurídica */
            vr_qtdirrf_lac_j := vr_qtdirrf_lac_j + 1;
            vr_vlrirrf_lac_j := vr_vlrirrf_lac_j + rw_craplacass.vllanmto;
          END IF;

        END LOOP;

      END LOOP;


      -- Processar aplicações programadas de poupança
      FOR rw_craplppass IN cr_craplppass(pr_cdcooper, vr_data_inicio, vr_data_fim) LOOP
        IF rw_craplppass.inpessoa = 1 THEN
          IF rw_craplppass.cdhistor = 863 THEN
            vr_vlr863_f := vr_vlr863_f + rw_craplppass.vllanmto;
            vr_qtd863_f := vr_qtd863_f + 1;
          ELSIF rw_craplppass.cdhistor = 870 THEN
            vr_vlr870_f := vr_vlr870_f + rw_craplppass.vllanmto;
            vr_qtd870_f := vr_qtd870_f + 1;
          ELSE
            vr_vlr151_f := vr_vlr151_f + rw_craplppass.vllanmto;
            vr_qtd151_f := vr_qtd151_f + 1;
          END IF;
        ELSE
          IF rw_craplppass.cdhistor = 863 THEN
            vr_vlr863_j := vr_vlr863_j + rw_craplppass.vllanmto;
            vr_qtd863_j := vr_qtd863_j + 1;
          ELSIF rw_craplppass.cdhistor = 870 THEN
            vr_vlr870_j := vr_vlr870_j + rw_craplppass.vllanmto;
            vr_qtd870_j := vr_qtd870_j + 1;
          ELSE
            vr_vlr151_j := vr_vlr151_j + rw_craplppass.vllanmto;
            vr_qtd151_j := vr_qtd151_j + 1;
          END IF;
        END IF;
      END LOOP;

      -- Validar dados de cotas/capital
      FOR rw_craplct IN cr_craplct(pr_cdcooper, vr_data_inicio, vr_data_fim) LOOP
        IF rw_craplct.cdhistor = 922 THEN
          vr_vlr922_fj := vr_vlr922_fj + rw_craplct.vllanmto;
          vr_qtd922_fj := vr_qtd922_fj + 1;
        ELSE
          IF rw_craplct.cdhistor = 926 THEN
            vr_vlr926_fj := vr_vlr926_fj + rw_craplct.vllanmto;
          END IF;
        END IF;
      END LOOP;

      -- Assimilar valores nas variáveis
      vr_qtdlan_fj := vr_qtd922_fj;
      vr_baslan_fj := vr_vlr926_fj;
      vr_deblan_fj := vr_vlr922_fj;
      vr_qtdlan_f := vr_qtd533_f + vr_qtd476_f + vr_qtd588_f + vr_qtd864_f + vr_qtd870_f + vr_qtd868_f + vr_qtd871_f + vr_qtd861_f + vr_qtd862_f +
                     vr_qtd116_f + vr_qtd179_f + vr_qtd863_f + vr_qtd151_f + vr_qtd875_f + vr_qtd876_f + vr_qtd877_f + vr_qtd475_f + vr_qtd532_f +
                     vr_qtdrend_lac_f + vr_qtdirrf_lac_f;
      vr_qtdlan_j := vr_qtd533_j + vr_qtd476_j + vr_qtd588_J + vr_qtd864_j + vr_qtd870_j + vr_qtd868_j + vr_qtd871_j + vr_qtd861_j + vr_qtd862_j +
                     vr_qtd116_j + vr_qtd179_j + vr_qtd863_j + vr_qtd151_j + vr_qtd875_j + vr_qtd876_j + vr_qtd877_j + vr_qtd475_j + vr_qtd532_j +
                     vr_qtdrend_lac_j + vr_qtdirrf_lac_j;
      vr_baslan_f := vr_vlr588_f + vr_vlr116_f + vr_vlr179_f + vr_vlr151_f + vr_vlr475_f + vr_vlr532_f + vr_vlrrend_lac_f;
      vr_baslan_j := vr_vlr588_j + vr_vlr116_j + vr_vlr179_j + vr_vlr151_j + vr_vlr475_j + vr_vlr532_j + vr_vlrrend_lac_j;
      vr_deblan_f := vr_vlr533_f + vr_vlr476_f + vr_vlr864_f + vr_vlr870_f + vr_vlr868_f + vr_vlr871_f + vr_vlr861_f + vr_vlr862_f + vr_vlr863_f +
                     vr_vlr875_f + vr_vlr876_f + vr_vlr877_f + vr_vlrirrf_lac_f;
      vr_deblan_j := vr_vlr533_j + vr_vlr476_j + vr_vlr864_j + vr_vlr870_j + vr_vlr868_j + vr_vlr871_j + vr_vlr861_j + vr_vlr862_j + vr_vlr863_j +
                     vr_vlr875_j + vr_vlr876_j + vr_vlr877_j + vr_vlrirrf_lac_j;
      vr_rel_dsperiod := TO_CHAR(vr_data_inicio, 'DD/MM/RRRR') || ' A ' || TO_CHAR(vr_data_fim, 'DD/MM/RRRR');

      -- Inicializar XML
      dbms_lob.createtemporary(vr_xmlclob, TRUE);
      dbms_lob.open(vr_xmlclob, dbms_lob.lob_readwrite);
      vr_bfclob := '<?xml version="1.0" encoding="utf-8"?><root>';

      -- Criar dados de resumo
      vr_bfclob := vr_bfclob || '<resumo><rel_dsperiod>' || vr_rel_dsperiod || '</rel_dsperiod>' ||
                                '<dtrecolh>' || TO_CHAR(vr_dtrecolh, 'DD/MM/RRRR') || '</dtrecolh>' ||
                                '<qtdlan_f>' || TO_CHAR(vr_qtdlan_f, 'FM999G999G999G990') || '</qtdlan_f>' ||
                                '<baslan_f>' || TO_CHAR(vr_baslan_f, 'FM999G999G999G990D00') || '</baslan_f>' ||
                                '<deblan_f>' || TO_CHAR(vr_deblan_f, 'FM999G999G999G990D00') || '</deblan_f>' ||
                                '<qtdlan_j>' || TO_CHAR(vr_qtdlan_j, 'FM999G999G999G990') || '</qtdlan_j>' ||
                                '<baslan_j>' || TO_CHAR(vr_baslan_j, 'FM999G999G999G990D00') || '</baslan_j>' ||
                                '<deblan_j>' || TO_CHAR(vr_deblan_j, 'FM999G999G999G990D00') || '</deblan_j>' ||
                                '<vlirap_j>' || TO_CHAR(vr_vlirap_j, 'FM999G999G999G990D00') || '</vlirap_j></resumo>';
      gene0002.pc_clob_buffer(pr_dados => vr_bfclob, pr_gravfim => FALSE, pr_clob => vr_xmlclob);

      -- Criar segundo lote de resumo
      IF vr_deblan_fj <> 0 OR vr_vlirct_j <> 0 THEN
        vr_bfclob := vr_bfclob || '<resumo2><qtdlan_fj>' || TO_CHAR(vr_qtdlan_fj, 'FM999G999G999G990') || '</qtdlan_fj>' ||
                                  '<baslan_fj>' || TO_CHAR(vr_baslan_fj, 'FM999G999G999G990D00') || '</baslan_fj>' ||
                                  '<deblan_fj>' || TO_CHAR(vr_deblan_fj, 'FM999G999G999G990D00') || '</deblan_fj>' ||
                                  '<vlirct_j>' || TO_CHAR(vr_vlirct_j, 'FM999G999G999G990D00') || '</vlirct_j>
                                  </resumo2>';

        gene0002.pc_clob_buffer(pr_dados => vr_bfclob, pr_gravfim => FALSE, pr_clob => vr_xmlclob);
      END IF;

      -- Popular tabela genérica de arrecadação para cooperativos diferentes de CECRED
      IF pr_cdcooper <> 3 THEN
        -- Controla valores menores que 10 para pessoa física
        IF vr_deblan_f < 10 THEN
          vr_deblan_a := 0;
        ELSE
          vr_deblan_a := vr_deblan_f;
        END IF;

        -- Gravar registro de IR da pessoa fisica
        BEGIN
          INSERT INTO gnarrec(cdcooper, dtiniapu, inpessoa, tpimpost, dtfimapu, dtrecolh, vlrecolh, vlapagar, inapagar)
            VALUES(pr_cdcooper, vr_data_inicio, 1, 2, vr_data_fim, vr_dtrecolh, vr_deblan_f, vr_deblan_a, 1);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              UPDATE gnarrec
              SET dtfimapu = vr_data_fim
                 ,dtrecolh = vr_dtrecolh
                 ,vlrecolh = vr_deblan_f
                 ,vlapagar = vr_deblan_a
                 ,inapagar = 1
               WHERE cdcooper = pr_cdcooper
                 AND dtiniapu = vr_data_inicio
                 AND inpessoa = 1
                 AND tpimpost = 2;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar IR pessoa física: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro gravando GNARREC: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Controla valores menores que 10 para pessoa jurídica
        IF vr_deblan_j < 10 THEN
          vr_deblan_a := 0;
        ELSE
          vr_deblan_a := vr_deblan_j;
        END IF;

        -- Grava registro de IR da pessoa juridica
        BEGIN
          INSERT INTO gnarrec(cdcooper, dtiniapu, inpessoa, tpimpost, dtfimapu, dtrecolh, vlrecolh, vlapagar, inapagar)
            VALUES(pr_cdcooper, vr_data_inicio, 2, 2, vr_data_fim, vr_dtrecolh, vr_deblan_j, vr_deblan_a, 1);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            BEGIN
              UPDATE gnarrec
              SET dtfimapu = vr_data_fim
                 ,dtrecolh = vr_dtrecolh
                 ,vlrecolh = vr_deblan_j
                 ,vlapagar = vr_deblan_a
                 ,inapagar = 1
               WHERE cdcooper = pr_cdcooper
                 AND dtiniapu = vr_data_inicio
                 AND inpessoa = 2
                 AND tpimpost = 2;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar IR pessoa jurídica: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          WHEN OTHERS THEN
            vr_dscritic := 'Erro gravando GNARREC: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

         -- Controla valores menores que 10 para pessoa física/jurídica
        IF vr_deblan_fj < 10 THEN
          vr_deblan_a := 0;
        ELSE
          vr_deblan_a := vr_deblan_fj;
        END IF;

        -- Grava registro de IR da pessoa física/jurídica
        IF vr_deblan_fj <> 0 THEN
          BEGIN
            INSERT INTO gnarrec(cdcooper, dtiniapu, inpessoa, tpimpost, dtfimapu, dtrecolh, vlrecolh, vlapagar, inapagar)
              VALUES(pr_cdcooper, vr_data_inicio, 3, 2, vr_data_fim, vr_dtrecolh, vr_deblan_fj, vr_deblan_a, 1);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
              BEGIN
                UPDATE gnarrec
                SET dtfimapu = vr_data_fim
                   ,dtrecolh = vr_dtrecolh
                   ,vlrecolh = vr_deblan_fj
                   ,vlapagar = vr_deblan_a
                   ,inapagar = 1
                 WHERE cdcooper = pr_cdcooper
                   AND dtiniapu = vr_data_inicio
                   AND inpessoa = 3
                   AND tpimpost = 2;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar IR: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro gravando GNARREC: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;

        -- Gerar finalização com compatibillidade do modelo do arquivo XML
        vr_bfclob := vr_bfclob || '<tributos><impostos ctrl="' || pr_cdcooper || '" vlarecol="0" vlapagar="0" ><imposto><rel_nmrescop></rel_nmrescop>' ||
                                  '<rel_nrdocnpj></rel_nrdocnpj><vlarecol>0</vlarecol><vlapagar>0</vlapagar></imposto></impostos></tributos>';
      ELSE
        -- Quando CECRED, exibir resumo no relatório
        vr_xprimpj  := 0;
        vr_xprimpf  := 0;
        vr_xprimpfj := 0;

        -- Gerar imposto
        vr_bfclob := vr_bfclob || '<tributos>';
        FOR idx IN 1..2 LOOP
          pc_imposto(pr_inpessoa => idx, pr_dscritic => vr_dscritic);

          -- Verifica se ocorreram erros
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END LOOP;
        vr_bfclob := vr_bfclob || '</tributos>';
      END IF;

      -- Criar tag de fechamento
      vr_bfclob := vr_bfclob || '</root>';

      -- Fechar execução do CLOB
      gene0002.pc_clob_buffer(pr_dados => vr_bfclob, pr_gravfim => TRUE, pr_clob => vr_xmlclob);

      -- Gerar relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_xmlclob
                                 ,pr_dsxmlnode => '/root/tributos/impostos'
                                 ,pr_dsjasper  => 'crrl323.jasper'
                                 ,pr_dsparams  => NULL
                                 ,pr_dsarqsaid => vr_nom_dir || '/crrl323.lst'
                                 ,pr_flg_gerar => 'N'
                                 ,pr_qtcoluna  => 80
                                 ,pr_sqcabrel  => 1
                                 ,pr_cdrelato  => NULL
                                 ,pr_flg_impri => 'S'
                                 ,pr_nmformul  => NULL
                                 ,pr_nrcopias  => NULL
                                 ,pr_dspathcop => NULL
                                 ,pr_dsmailcop => NULL
                                 ,pr_dsassmail => NULL
                                 ,pr_dscormail => NULL
                                 ,pr_flsemqueb => 'N'
                                 ,pr_des_erro  => vr_dscritic);

      -- Verifica se encontrou erros
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
                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || vr_dscritic );

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
  END pc_crps373;
/
