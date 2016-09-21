CREATE OR REPLACE PROCEDURE CECRED.pc_crps576 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps576 (Fontes/crps576.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Guilherme
       Data    : Setembro/2010                   Ultima atualizacao: 23/06/2016

       Dados referentes ao programa:

       Frequencia: Mensal / CECRED(Roda no primeiro dia util do mes.
       Objetivo  : Atende a solicitacao 39. Ordem = 10.
                   Gera informacoes para o BNDES - 7018.
                   Relatorio 568.

       Alteracoes: 04/01/2010 - Ler o crapris com glb_dtultdma (Magui).

                   26/01/2011 - Gerar informaçoes a partir da crapprb (Guilherme)

                   30/10/2012 - Retirado os valores da Concredi e Credimilsul do
                                relatorio (Elton).

                   28/11/2012 - Retirado os valores da Alto Vale do relatorio
                                (David Kruger).

                   02/08/2013 - Retirado restriçoes  das informaçoes para
                                a Concredi e a Alto Vale (Daniele).

                   29/04/2014 - Conversão Progress >> Oracle (Edison - AMcom)

                   23/05/2014 - Ajustado para converter o relatorio(ux2dos) antes
                                de envia-lo por e-mail(Odirlei-AMcom)

                   30/07/2014 - Correção da falta de envio do arquivo a Intranet
                                (Marcos-Supero)

                   02/10/2014 - Retirado validação para credimilsul (Lucas R. #200980)

                   23/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.
                                (Carlos Rafael Tanholi).
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS576';

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

      -- Busca todas as cooperativas, com excecao da cooperativa 15-Credimisul
      CURSOR cr_crapcop_II IS
        SELECT cdcooper
              ,nmrescop
              ,nmextcop
          FROM crapcop;

      --Contem informacoes necessarias para levantar os dados exigidos pelo BNDES
      CURSOR cr_crapbnd( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtoan IN DATE) IS
        SELECT crapbnd.vlaplprv
        FROM   crapbnd
        WHERE  crapbnd.cdcooper = pr_cdcooper
        AND    crapbnd.dtmvtolt = pr_dtmvtoan;

      -- Buscar dados da tabela de parametros
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT craptab.tpregist
              ,craptab.dstextab
        FROM craptab
        WHERE craptab.cdcooper = pr_cdcooper
          AND UPPER(craptab.nmsistem) = 'CRED'
          AND UPPER(craptab.tptabela) = 'GENERI'
          AND craptab.cdempres = 0
          AND UPPER(craptab.cdacesso) = 'PROVISAOCL';
      rw_craptab cr_craptab%ROWTYPE;

      --Arquivo para controle das informacoes da central de risco
      CURSOR cr_crapris( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtrefere IN DATE) IS
        SELECT crapris.nrcpfcgc
              ,crapris.nrdconta
              ,crapris.dtrefere
              ,crapris.innivris
              ,crapris.cdmodali
              ,crapris.nrctremp
              ,crapris.nrseqctr
        FROM  crapris
        WHERE crapris.cdcooper = pr_cdcooper
        AND   crapris.dtrefere = pr_dtrefere
        AND   crapris.inddocto = 1;

      --Vencimento do risco
      CURSOR cr_crapvri( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapvri.nrdconta%TYPE
                        ,pr_dtrefere IN crapvri.dtrefere%TYPE
                        ,pr_innivris IN crapvri.innivris%TYPE
                        ,pr_cdmodali IN crapvri.cdmodali%TYPE
                        ,pr_nrctremp IN crapvri.nrctremp%TYPE
                        ,pr_nrseqctr IN crapvri.nrseqctr%TYPE) IS
        SELECT crapvri.vldivida
        FROM   crapvri
        WHERE  crapvri.cdcooper = pr_cdcooper
        AND    crapvri.nrdconta = pr_nrdconta
        AND    crapvri.dtrefere = pr_dtrefere
        AND    crapvri.innivris = pr_innivris
        AND    crapvri.cdmodali = pr_cdmodali
        AND    crapvri.nrctremp = pr_nrctremp
        AND    crapvri.nrseqctr = pr_nrseqctr
        AND    crapvri.cdvencto NOT IN (310,320,330); --Despreza contratos em prejuizo

      --Contem os prazos de retorno dos nossos produtos para
      --levantamento de informacoes solicitadas pelo BNDES
      CURSOR cr_crapprb( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN DATE) IS
        SELECT crapass.nrcpfcgc
              ,crapprb.vlretorn
        FROM   crapprb
              ,crapass
        WHERE  crapprb.cdcooper = pr_cdcooper
        AND    crapprb.dtmvtolt = pr_dtmvtolt
        AND    crapass.cdcooper = crapprb.cdcooper
        AND    crapass.nrdconta = crapprb.nrdconta;

      --Contem informacoes necessarias para levantar os dados exigidos pelo BNDES
      CURSOR cr_crapbnd_II( pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt IN DATE) IS
        SELECT crapass.nrcpfcgc
              ,crapbnd.vldepavs
        FROM   crapbnd
              ,crapass
        WHERE  crapbnd.cdcooper = pr_cdcooper
        AND    crapbnd.dtmvtolt = pr_dtmvtolt
        AND    crapass.cdcooper = crapbnd.cdcooper
        AND    crapass.nrdconta = crapbnd.nrdconta;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      --tipo de registro
      TYPE typ_tab_bnd IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
      --INDEX tt-bnd1 vlaplprv DESC.
      --tabela temporaria
      vr_tab_bnd typ_tab_bnd;

      --Estrutura de registro
      TYPE typ_reg_opr IS
        RECORD( nrcpfcgc crapris.vldivida%TYPE
               ,vldivida NUMBER
               ,vlprovis NUMBER);
      --Tipo de registro
      TYPE typ_tab_opr IS TABLE OF typ_reg_opr INDEX BY VARCHAR2(100);
      --INDEX tt-opr2 vldivida DESC.
      --tabela temporária
      vr_tab_opr typ_tab_opr;

      --Estrutura de registro
      TYPE typ_reg_dep IS
        RECORD( nrcpfcgc NUMBER
               ,vldeposi NUMBER);

      --Tipo de registro
      TYPE typ_tab_dep IS TABLE OF typ_reg_dep INDEX BY VARCHAR2(100);
      --INDEX tt-dep2 vldeposi DESC.
      --tabela temporaria
      vr_tab_dep typ_tab_dep;

      -- PL Table de dados de parâmetros
      TYPE typ_reg_craptab IS
        RECORD(dstextab craptab.dstextab%TYPE);
      TYPE typ_tab_craptab IS TABLE OF typ_reg_craptab INDEX BY VARCHAR2(10);
      vr_tab_craptab    typ_tab_craptab;

      ------------------------------- VARIAVEIS -------------------------------
      --vr_rel_nmempres    VARCHAR2(15);
      vr_nmarqimp        VARCHAR(500);
      vr_contador        INTEGER;
      vr_rel_percentu    dbms_sql.Number_Table; --"zz9.99"   EXTENT 20 NO-UNDO.

      /* Coluna 1 */
      vr_vlaplprv_10     NUMBER;
      vr_vlaplprv_50     NUMBER;
      vr_vlaplprv_100    NUMBER;
      vr_vlaplprv_demais NUMBER;
      vr_vlaplprv_tot    NUMBER;

      /* Coluna 2 */
      vr_pcaplprv_10     NUMBER;
      vr_pcaplprv_50     NUMBER;
      vr_pcaplprv_100    NUMBER;
      vr_pcaplprv_demais NUMBER;
      vr_pcaplprv_tot    NUMBER;

      /* Coluna 3 */
      vr_vloprcrd_10     NUMBER;
      vr_vloprcrd_50     NUMBER;
      vr_vloprcrd_100    NUMBER;
      vr_vloprcrd_demais NUMBER;
      vr_vloprcrd_tot    NUMBER;

      /* Coluna 4 */
      vr_pcoprcrd_10     NUMBER;
      vr_pcoprcrd_50     NUMBER;
      vr_pcoprcrd_100    NUMBER;
      vr_pcoprcrd_demais NUMBER;
      vr_pcoprcrd_tot    NUMBER;

      /* Coluna 5 */
      vr_vltotprv_10     NUMBER;
      vr_vltotprv_50     NUMBER;
      vr_vltotprv_100    NUMBER;
      vr_vltotprv_demais NUMBER;
      vr_vltotprv_tot    NUMBER;

      /* Coluna 6 */
      vr_vltotdep_10     NUMBER;
      vr_vltotdep_50     NUMBER;
      vr_vltotdep_100    NUMBER;
      vr_vltotdep_demais NUMBER;
      vr_vltotdep_tot    NUMBER;

      /* Coluna 7 */
      vr_pctotdep_10     NUMBER;
      vr_pctotdep_50     NUMBER;
      vr_pctotdep_100    NUMBER;
      vr_pctotdep_demais NUMBER;
      vr_pctotdep_tot    NUMBER;
      vr_dsdircop        VARCHAR2(500);

      vr_xml             CLOB;
      vr_texto_completo  VARCHAR2(32600);
      vr_ind_craptab     VARCHAR2(100);
      vr_ind_bnd         VARCHAR2(100);
      vr_ind_opr         VARCHAR2(100);
      vr_ind_dep         VARCHAR2(100);
      vr_dsmailcop       VARCHAR2(4000);

      --------------------------- SUBROTINAS INTERNAS --------------------------
      --rotina interna para reordenar a tabela temporaria tab_opr pelo
      --valor da divida decrescente
      PROCEDURE pc_reordena_tab_opr(pr_tab_opr IN OUT typ_tab_opr) IS
        vr_indice_atual VARCHAR2(100);
        vr_indice_novo  VARCHAR2(100);
        vr_tab_opr_new  typ_tab_opr;
      BEGIN
        --posiciona no primeiro registro
        vr_indice_atual := pr_tab_opr.first;
        LOOP
          --sai do loop quando chegar no último registro
          EXIT WHEN vr_indice_atual IS NULL;

          --trabalha apenas com valores maiores que zero
          IF pr_tab_opr(vr_indice_atual).vldivida <> 0 THEN
            --montando o novo indice
            vr_indice_novo := 999999999999999 - round(pr_tab_opr(vr_indice_atual).vldivida,2)*100||
                              LPAD(vr_tab_opr_new.count,10,'0');

            --recarga da tabela com nova ordenacao
            vr_tab_opr_new(vr_indice_novo).nrcpfcgc := pr_tab_opr(vr_indice_atual).nrcpfcgc;
            vr_tab_opr_new(vr_indice_novo).vldivida := pr_tab_opr(vr_indice_atual).vldivida;
            vr_tab_opr_new(vr_indice_novo).vlprovis := pr_tab_opr(vr_indice_atual).vlprovis;
          END IF;
          -- vai para o proximo registro da tabela
          vr_indice_atual := pr_tab_opr.next(vr_indice_atual);
        END LOOP;

        --retorna a tabela reordenada
        pr_tab_opr := vr_tab_opr_new;
      END;

      --rotina interna para reordenar a tabela temporaria tab_dep pelo
      --valor do deposito decrescente
      PROCEDURE pc_reordena_tab_dep(pr_tab_dep IN OUT typ_tab_dep) IS
        vr_indice_atual VARCHAR2(100);
        vr_indice_novo  VARCHAR2(100);
        vr_tab_dep_new  typ_tab_dep;
      BEGIN
        --posiciona no primeiro registro
        vr_indice_atual := pr_tab_dep.first;
        LOOP
          --sai do loop quando chegar no último registro
          EXIT WHEN vr_indice_atual IS NULL;

          IF pr_tab_dep(vr_indice_atual).vldeposi < 0 THEN
            vr_indice_novo := '999999999999999'||LPAD(vr_tab_dep_new.count,10,'0');
          ELSE
            --montando o novo indice
            vr_indice_novo := 999999999999999 - round(pr_tab_dep(vr_indice_atual).vldeposi,2)*100||
                              LPAD(vr_tab_dep_new.count,10,'0');
          END IF;
          --recarga da tabela com nova ordenacao
          vr_tab_dep_new(vr_indice_novo).nrcpfcgc := pr_tab_dep(vr_indice_atual).nrcpfcgc;
          vr_tab_dep_new(vr_indice_novo).vldeposi := pr_tab_dep(vr_indice_atual).vldeposi;

          -- vai para o proximo registro da tabela
          vr_indice_atual := pr_tab_dep.next(vr_indice_atual);
        END LOOP;

        --retorna a tabela reordenada
        pr_tab_dep := vr_tab_dep_new;
      END;

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

      -- Carregar PL Table de parâmetros
      FOR rw_craptab IN cr_craptab(pr_cdcooper) LOOP
        vr_tab_craptab(LPAD(rw_craptab.tpregist, 5, '0')).dstextab := rw_craptab.dstextab;
      END LOOP;

      --percorre todas as cooperativas
      FOR rw_crapcop_II IN cr_crapcop_II
      LOOP
        --inicializando as variaveis
        vr_contador     := 0;

        vr_rel_percentu(vr_contador) := 0;

        /* Coluna 1 e 2 */
        IF  rw_crapcop_II.cdcooper = 3  THEN
          --Contem informacoes necessarias para levantar os dados exigidos pelo BNDES
          FOR rw_crapbnd IN cr_crapbnd( pr_cdcooper => rw_crapcop_II.cdcooper
                                       ,pr_dtmvtoan => rw_crapdat.dtmvtoan)
          LOOP
            --indexador decrescente por valor
            vr_ind_bnd := 999999999999999 - (round(rw_crapbnd.vlaplprv,2)*100);
            --armazenando o valor
            vr_tab_bnd(vr_ind_bnd) := rw_crapbnd.vlaplprv;
          END LOOP;
        ELSE
          --posicionando no primeiro registro
          vr_ind_craptab := vr_tab_craptab.FIRST;
          LOOP
            EXIT WHEN vr_ind_craptab IS NULL;

            --atualiza o contador
            vr_contador := TO_NUMBER(SUBSTR(vr_tab_craptab(vr_ind_craptab).dstextab,12,2));
            --armazena
            vr_rel_percentu(vr_contador) := TO_NUMBER(SUBSTR(vr_tab_craptab(vr_ind_craptab).dstextab,1,6)) / 100;

            --posiciona no proximo registro
            vr_ind_craptab := vr_tab_craptab.NEXT(vr_ind_craptab);

          END LOOP;

          -- percorre as informacoes de risco
          /*** Coluna 3,4 e 5 ***/
          FOR rw_crapris IN cr_crapris( pr_cdcooper => rw_crapcop_II.cdcooper
                                       ,pr_dtrefere => rw_crapdat.dtultdma)
          LOOP

            --verifica se o registro já existe na tabela temporaria
            IF NOT vr_tab_opr.EXISTS(rw_crapris.nrcpfcgc) THEN
              --armazenando as informacoes na tabela temporaria
              vr_tab_opr(rw_crapris.nrcpfcgc).nrcpfcgc := rw_crapris.nrcpfcgc;
              vr_tab_opr(rw_crapris.nrcpfcgc).vldivida := 0;
              vr_tab_opr(rw_crapris.nrcpfcgc).vlprovis := 0;
            END IF;
            --verifica os vencimentos do risco
            FOR rw_crapvri IN cr_crapvri( pr_cdcooper => rw_crapcop_II.cdcooper
                                         ,pr_nrdconta => rw_crapris.nrdconta
                                         ,pr_dtrefere => rw_crapris.dtrefere
                                         ,pr_innivris => rw_crapris.innivris
                                         ,pr_cdmodali => rw_crapris.cdmodali
                                         ,pr_nrctremp => rw_crapris.nrctremp
                                         ,pr_nrseqctr => rw_crapris.nrseqctr)
            LOOP
              --acumula o valor da divida
              vr_tab_opr(rw_crapris.nrcpfcgc).vldivida := nvl(vr_tab_opr(rw_crapris.nrcpfcgc).vldivida,0) +
                                                          rw_crapvri.vldivida;
              --acumula o valor da provisao
              vr_tab_opr(rw_crapris.nrcpfcgc).vlprovis := nvl(vr_tab_opr(rw_crapris.nrcpfcgc).vlprovis,0) +
                                                          round((rw_crapvri.vldivida * vr_rel_percentu(rw_crapris.innivris)),2);
            END LOOP;
          END LOOP;

          /* Coluna 6 e 7 */
          --Contem os prazos de retorno dos nossos produtos para
          --levantamento de informacoes solicitadas pelo BNDES
          FOR rw_crapprb IN cr_crapprb( pr_cdcooper => rw_crapcop_II.cdcooper
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtoan)
          LOOP
            --se não existir na tabela temporaria, será inserido
            IF NOT vr_tab_dep.EXISTS(rw_crapprb.nrcpfcgc) THEN
              vr_tab_dep(rw_crapprb.nrcpfcgc).nrcpfcgc := rw_crapprb.nrcpfcgc;
              vr_tab_dep(rw_crapprb.nrcpfcgc).vldeposi := 0;
            END IF;
            --acumula o valor depositado
            vr_tab_dep(rw_crapprb.nrcpfcgc).vldeposi := nvl(vr_tab_dep(rw_crapprb.nrcpfcgc).vldeposi,0) +
                                                        rw_crapprb.vlretorn;
          END LOOP; /* Fim FOR EACH */

          FOR rw_crapbnd_II IN cr_crapbnd_II( pr_cdcooper => rw_crapcop_II.cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtoan)
          LOOP
            --se não existir na tabela temporaria, será inserido
            IF NOT vr_tab_dep.EXISTS(rw_crapbnd_II.nrcpfcgc) THEN
              vr_tab_dep(rw_crapbnd_II.nrcpfcgc).nrcpfcgc := rw_crapbnd_II.nrcpfcgc;
            END IF;
            --acumula o valor depositado
            vr_tab_dep(rw_crapbnd_II.nrcpfcgc).vldeposi := nvl(vr_tab_dep(rw_crapbnd_II.nrcpfcgc).vldeposi,0) +
                                                           rw_crapbnd_II.vldepavs;
          END LOOP; /* Fim FOR EACH */

        END IF;

      END LOOP;

      --reordenando as tabelas temporarias pelo valor decrescente
      pc_reordena_tab_opr(pr_tab_opr => vr_tab_opr);
      pc_reordena_tab_dep(pr_tab_dep => vr_tab_dep);

      /* Inicio Coluna 1 e 2 */
      vr_contador := 0;

      --posiciona no primeiro registro
      vr_ind_bnd := vr_tab_bnd.FIRST;
      LOOP
        EXIT WHEN vr_ind_bnd IS NULL;

        --incrementa o contador
        vr_contador := vr_contador + 1;

        IF vr_contador <= 10 THEN
          vr_vlaplprv_10 := NVL(vr_vlaplprv_10,0) + nvl(vr_tab_bnd(vr_ind_bnd),0);
        ELSIF vr_contador <= 60  THEN
          vr_vlaplprv_50 := NVL(vr_vlaplprv_50,0) + nvl(vr_tab_bnd(vr_ind_bnd),0);
        ELSIF vr_contador <= 160  THEN
          vr_vlaplprv_100 := NVL(vr_vlaplprv_100,0) + nvl(vr_tab_bnd(vr_ind_bnd),0);
        ELSE
          vr_vlaplprv_demais := NVL(vr_vlaplprv_demais,0) + nvl(vr_tab_bnd(vr_ind_bnd),0);
        END IF;

        --vai para o proximo registro
        vr_ind_bnd := vr_tab_bnd.NEXT(vr_ind_bnd);
      END LOOP;

      -- calculando
      vr_vlaplprv_10     := nvl(vr_vlaplprv_10,0)     / 1000;
      vr_vlaplprv_50     := nvl(vr_vlaplprv_50,0)     / 1000;
      vr_vlaplprv_100    := nvl(vr_vlaplprv_100,0)    / 1000;
      vr_vlaplprv_demais := nvl(vr_vlaplprv_demais,0) / 1000;
      vr_vlaplprv_tot    := nvl(vr_vlaplprv_10,0)  +
                            nvl(vr_vlaplprv_50,0)  +
                            nvl(vr_vlaplprv_100,0) +
                            nvl(vr_vlaplprv_demais,0);

      IF nvl(vr_vlaplprv_tot,0) <> 0 THEN
        vr_pcaplprv_10  := (nvl(vr_vlaplprv_10,0) * 100) / vr_vlaplprv_tot;
        vr_pcaplprv_50  := (nvl(vr_vlaplprv_50,0) * 100) / vr_vlaplprv_tot;
        vr_pcaplprv_100 := (nvl(vr_vlaplprv_100,0)* 100) / vr_vlaplprv_tot;
        vr_pcaplprv_demais := (nvl(vr_vlaplprv_demais,0) * 100) / vr_vlaplprv_tot;
      END IF;

      vr_pcaplprv_tot := nvl(vr_pcaplprv_10,0)  +
                         nvl(vr_pcaplprv_50,0)  +
                         nvl(vr_pcaplprv_100,0) +
                         nvl(vr_pcaplprv_demais,0);
      /* Fim Coluna 1 e 2 */

      /* Inicio Coluna 3, 4 e 5 */
      vr_contador := 0;
      --posiciona no primeiro registro
      vr_ind_opr := vr_tab_opr.FIRST;
      LOOP
        EXIT WHEN vr_ind_opr IS NULL;

        --incrementa o contador
        vr_contador := vr_contador + 1;
        IF vr_contador <= 10 THEN
          vr_vloprcrd_10 := nvl(vr_vloprcrd_10,0) + nvl(vr_tab_opr(vr_ind_opr).vldivida,0);
          vr_vltotprv_10 := nvl(vr_vltotprv_10,0) + nvl(vr_tab_opr(vr_ind_opr).vlprovis,0);
        ELSIF vr_contador <= 60 THEN
          vr_vloprcrd_50 := nvl(vr_vloprcrd_50,0) + nvl(vr_tab_opr(vr_ind_opr).vldivida,0);
          vr_vltotprv_50 := nvl(vr_vltotprv_50,0) + nvl(vr_tab_opr(vr_ind_opr).vlprovis,0);
        ELSIF vr_contador <= 160 THEN
          vr_vloprcrd_100 := nvl(vr_vloprcrd_100,0) + nvl(vr_tab_opr(vr_ind_opr).vldivida,0);
          vr_vltotprv_100 := nvl(vr_vltotprv_100,0) + nvl(vr_tab_opr(vr_ind_opr).vlprovis,0);
        ELSE
          vr_vloprcrd_demais := nvl(vr_vloprcrd_demais,0) + nvl(vr_tab_opr(vr_ind_opr).vldivida,0);
          vr_vltotprv_demais := nvl(vr_vltotprv_demais,0) + nvl(vr_tab_opr(vr_ind_opr).vlprovis,0);
        END IF;

        -- posiciona no proximo registro
        vr_ind_opr := vr_tab_opr.NEXT(vr_ind_opr);
      END LOOP;

      vr_vloprcrd_10     := nvl(vr_vloprcrd_10,0)     / 1000;
      vr_vltotprv_10     := nvl(vr_vltotprv_10,0)     / 1000;
      vr_vloprcrd_50     := nvl(vr_vloprcrd_50,0)     / 1000;
      vr_vltotprv_50     := nvl(vr_vltotprv_50,0)     / 1000;
      vr_vloprcrd_100    := nvl(vr_vloprcrd_100,0)    / 1000;
      vr_vltotprv_100    := nvl(vr_vltotprv_100,0)    / 1000;
      vr_vloprcrd_demais := nvl(vr_vloprcrd_demais,0) / 1000;
      vr_vltotprv_demais := nvl(vr_vltotprv_demais,0) / 1000;

      vr_vloprcrd_tot    := nvl(vr_vloprcrd_10,0)  +
                            nvl(vr_vloprcrd_50,0)  +
                            nvl(vr_vloprcrd_100,0) +
                            nvl(vr_vloprcrd_demais,0);

      vr_vltotprv_tot    := nvl(vr_vltotprv_10,0)  +
                            nvl(vr_vltotprv_50,0)  +
                            nvl(vr_vltotprv_100,0) +
                            nvl(vr_vltotprv_demais,0);

      IF nvl(vr_vloprcrd_tot,0) <> 0 THEN
        vr_pcoprcrd_10  := (nvl(vr_vloprcrd_10,0)     * 100) / vr_vloprcrd_tot;
        vr_pcoprcrd_50  := (nvl(vr_vloprcrd_50,0)     * 100) / vr_vloprcrd_tot;
        vr_pcoprcrd_100 := (nvl(vr_vloprcrd_100,0)    * 100) / vr_vloprcrd_tot;
        vr_pcoprcrd_demais := (nvl(vr_vloprcrd_demais,0) * 100) / vr_vloprcrd_tot;
      END IF;

      vr_pcoprcrd_tot   := nvl(vr_pcoprcrd_10,0)  +
                           nvl(vr_pcoprcrd_50,0)  +
                           nvl(vr_pcoprcrd_100,0) +
                           nvl(vr_pcoprcrd_demais,0);

      /* Fim Coluna 3, 4 e 5 */

      /* Inicio Coluna 6 e 7 */
      vr_contador := 0;

      --posiciona no primeiro registro
      vr_ind_dep := vr_tab_dep.FIRST;

      LOOP
        EXIT WHEN vr_ind_dep IS NULL;

        --incrementa o contado
        vr_contador := vr_contador + 1;

        IF vr_contador <= 10  THEN
          vr_vltotdep_10 := nvl(vr_vltotdep_10,0) + nvl(vr_tab_dep(vr_ind_dep).vldeposi,0);
        ELSIF  vr_contador <= 60  THEN
          vr_vltotdep_50 := nvl(vr_vltotdep_50,0) + nvl(vr_tab_dep(vr_ind_dep).vldeposi,0);
        ELSIF  vr_contador <= 160  THEN
          vr_vltotdep_100 := nvl(vr_vltotdep_100,0) + nvl(vr_tab_dep(vr_ind_dep).vldeposi,0);
        ELSE
          vr_vltotdep_demais := nvl(vr_vltotdep_demais,0) + nvl(vr_tab_dep(vr_ind_dep).vldeposi,0);
        END IF;

        --posiciona no proximo registro
        vr_ind_dep := vr_tab_dep.NEXT(vr_ind_dep);
      END LOOP;

      vr_vltotdep_10     := nvl(vr_vltotdep_10,0)     / 1000;
      vr_vltotdep_50     := nvl(vr_vltotdep_50,0)     / 1000;
      vr_vltotdep_100    := nvl(vr_vltotdep_100,0)    / 1000;
      vr_vltotdep_demais := nvl(vr_vltotdep_demais,0) / 1000;
      vr_vltotdep_tot    := nvl(vr_vltotdep_10,0)  +
                            nvl(vr_vltotdep_50,0)  +
                            nvl(vr_vltotdep_100,0) +
                            nvl(vr_vltotdep_demais,0);

      IF nvl(vr_vltotdep_tot,0) <> 0 THEN
        vr_pctotdep_10     := (nvl(vr_vltotdep_10,0)     * 100) / vr_vltotdep_tot;
        vr_pctotdep_50     := (nvl(vr_vltotdep_50,0)     * 100) / vr_vltotdep_tot;
        vr_pctotdep_100    := (nvl(vr_vltotdep_100,0)    * 100) / vr_vltotdep_tot;
        vr_pctotdep_demais := (nvl(vr_vltotdep_demais,0) * 100) / vr_vltotdep_tot;
      END IF;

      vr_pctotdep_tot := nvl(vr_pctotdep_10,0)  +
                         nvl(vr_pctotdep_50,0)  +
                         nvl(vr_pctotdep_100,0) +
                         nvl(vr_pctotdep_demais,0);

      /* Fim Coluna 6 e 7 */

      --nome do arquivo
      vr_nmarqimp := 'crrl568.lst';

      -- Inicializar CLOB
      dbms_lob.createtemporary(vr_xml, TRUE);
      dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

      --Inicializa o xml
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                             '<?xml version="1.0" encoding="utf-8"?><root>'||
                             '<dtmvtoan>'||TO_CHAR(rw_crapdat.dtmvtoan,'DD/MM/YYYY')||'</dtmvtoan>'||chr(13));

      --escreve a linha ref aos 10 MAIORES EMITENTES/CLIENTES
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                             '<conta ctaid="00.0.0.01.01.00" ctanome="10 MAIORES EMITENTES/CLIENTES">'||
                             '<vlaplprv>'||round(nvl(vr_vlaplprv_10,0),2)||'</vlaplprv>'||
                             '<pcaplprv>'||TO_CHAR(nvl(vr_pcaplprv_10,0),'990D00')||'</pcaplprv>'||
                             '<vloprcrd>'||round(nvl(vr_vloprcrd_10,0),2)||'</vloprcrd>'||
                             '<pcoprcrd>'||TO_CHAR(nvl(vr_pcoprcrd_10,0),'990D00')||'</pcoprcrd>'||
                             '<vltotprv>'||round(nvl(vr_vltotprv_10,0),2)||'</vltotprv>'||
                             '<vltotdep>'||round(nvl(vr_vltotdep_10,0),2)||'</vltotdep>'||
                             '<pctotdep>'||TO_CHAR(nvl(vr_pctotdep_10,0),'990D00')||'</pctotdep></conta>'||chr(13));
      --escreve a linha ref aos 50 MAIORES SEGUINTES
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                             '<conta ctaid="00.0.0.01.02.00" ctanome="50 MAIORES SEGUINTES">'||
                             '<vlaplprv>'||round(nvl(vr_vlaplprv_50,0),2)||'</vlaplprv>'||
                             '<pcaplprv>'||TO_CHAR(nvl(vr_pcaplprv_50,0),'990D00')||'</pcaplprv>'||
                             '<vloprcrd>'||round(nvl(vr_vloprcrd_50,0),2)||'</vloprcrd>'||
                             '<pcoprcrd>'||TO_CHAR(nvl(vr_pcoprcrd_50,0),'990D00')||'</pcoprcrd>'||
                             '<vltotprv>'||round(nvl(vr_vltotprv_50,0),2)||'</vltotprv>'||
                             '<vltotdep>'||round(nvl(vr_vltotdep_50,0),2)||'</vltotdep>'||
                             '<pctotdep>'||TO_CHAR(nvl(vr_pctotdep_50,0),'990D00')||'</pctotdep></conta>'||chr(13));
      --escreve a linha ref aos 100 MAIORES SEGUINTES
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                             '<conta ctaid="00.0.0.01.03.00" ctanome="100 MAIORES SEGUINTES">'||
                             '<vlaplprv>'||round(nvl(vr_vlaplprv_100,0),2)||'</vlaplprv>'||
                             '<pcaplprv>'||TO_CHAR(nvl(vr_pcaplprv_100,0),'990D00')||'</pcaplprv>'||
                             '<vloprcrd>'||round(nvl(vr_vloprcrd_100,0),2)||'</vloprcrd>'||
                             '<pcoprcrd>'||TO_CHAR(nvl(vr_pcoprcrd_100,0),'990D00')||'</pcoprcrd>'||
                             '<vltotprv>'||round(nvl(vr_vltotprv_100,0),2)||'</vltotprv>'||
                             '<vltotdep>'||round(nvl(vr_vltotdep_100,0),2)||'</vltotdep>'||
                             '<pctotdep>'||TO_CHAR(nvl(vr_pctotdep_100,0),'990D00')||'</pctotdep></conta>'||chr(13));
      --escreve a linha ref aos DEMAIS EMITENTES/CLIENTES
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                             '<conta ctaid="00.0.0.01.04.00" ctanome="DEMAIS EMITENTES/CLIENTES">'||
                             '<vlaplprv>'||round(nvl(vr_vlaplprv_demais,0),2)||'</vlaplprv>'||
                             '<pcaplprv>'||TO_CHAR(nvl(vr_pcaplprv_demais,0),'990D00')||'</pcaplprv>'||
                             '<vloprcrd>'||round(nvl(vr_vloprcrd_demais,0),2)||'</vloprcrd>'||
                             '<pcoprcrd>'||TO_CHAR(nvl(vr_pcoprcrd_demais,0),'990D00')||'</pcoprcrd>'||
                             '<vltotprv>'||round(nvl(vr_vltotprv_demais,0),2)||'</vltotprv>'||
                             '<vltotdep>'||round(nvl(vr_vltotdep_demais,0),2)||'</vltotdep>'||
                             '<pctotdep>'||TO_CHAR(nvl(vr_pctotdep_demais,0),'990D00')||'</pctotdep></conta>'||chr(13));
      --escreve a linha ref ao totalizador
      gene0002.pc_escreve_xml(vr_xml,
                              vr_texto_completo,
                             '<conta ctaid="00.0.0.01.00.00" ctanome="TOTAL">'||
                             '<vlaplprv>'||round(nvl(vr_vlaplprv_tot,0),2)||'</vlaplprv>'||
                             '<pcaplprv>'||TO_CHAR(nvl(vr_pcaplprv_tot,0),'990D00')||'</pcaplprv>'||
                             '<vloprcrd>'||round(nvl(vr_vloprcrd_tot,0),2)||'</vloprcrd>'||
                             '<pcoprcrd>'||TO_CHAR(nvl(vr_pcoprcrd_tot,0),'990D00')||'</pcoprcrd>'||
                             '<vltotprv>'||round(nvl(vr_vltotprv_tot,0),2)||'</vltotprv>'||
                             '<vltotdep>'||round(nvl(vr_vltotdep_tot,0),2)||'</vltotdep>'||
                             '<pctotdep>'||TO_CHAR(nvl(vr_pctotdep_tot,0),'990D00')||'</pctotdep></conta></root>', TRUE);
      --pasta/rl
      vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '');

      vr_dsmailcop := gene0001.fn_param_sistema( pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_cdacesso => 'CRRL571');

      -- Gerando o relatório
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                 ,pr_cdprogra  => vr_cdprogra
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                 ,pr_dsxml     => vr_xml
                                 ,pr_dsxmlnode => '/root/conta'
                                 ,pr_dsjasper  => 'crrl568.jasper'
                                 ,pr_dsparams  => ''
                                 ,pr_dsarqsaid => vr_dsdircop||'/rl/'||vr_nmarqimp
                                 ,pr_flg_gerar => 'N'
                                 ,pr_qtcoluna  => 234
                                 ,pr_sqcabrel  => 1
                                 ,pr_flg_impri => 'S'
                                 ,pr_nmformul  => '234dh'
                                 ,pr_nrcopias  => 1
                                 ,pr_dspathcop => vr_dsdircop||'/converte'      --> Lista sep. por ';' de diretórios a copiar o relatório
                                 ,pr_fldosmail => 'S'                           --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                 ,pr_dsmailcop => vr_dsmailcop                  --> Lista sep. por ';' de emails para envio do relatório
                                 ,pr_dsassmail => 'Informaçoes BNDES - Quadro 7018' --> Assunto do e-mail que enviará o relatório
                                 ,pr_des_erro  => vr_dscritic);


      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml);
      dbms_lob.freetemporary(vr_xml);

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

  END pc_crps576;
/
