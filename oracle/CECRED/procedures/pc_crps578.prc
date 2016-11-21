CREATE OR REPLACE PROCEDURE CECRED.pc_crps578(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                      ,pr_flgresta IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: PC_CRPS578  (Antigo Fontes/crps578.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Guilherme
       Data    : Setembro/2010                   Ultima atualizacao: 19/03/2014

       Dados referentes ao programa:

       Frequencia: Mensal.
       Objetivo  : Atende a solicitacao 39. Ordem = 12.
                   Gera informacoes para o BNDES - 7027.
                   Relatorio 571.

        CAMPO CRAPPRB.CDORIGEM:
         1 = conta investimento
         2 = desconto de titulos
         3 = emprestimos
         4 = desconto de cheques
         5 = rdca60
         6 = rdca30
         7 = rdcpre
         8 = rdcpos
         9 = poupanca programada
        10 = produtos de captação.

       Alteracoes: 02/03/2011 - Desprezar o cddprazo = 0 no prazo de 90 dias
                                pois é usado no relatorio analitico (Guilherme).

                   18/09/2012 - Quebra do relatorio por singular (Tiago).

                   19/03/2014 - Conversão Progress >> Oracle (Petter - Supero)
                   
                   23/05/2014 - Ajustado para converter o relatorio(ux2dos) antes de envia-lo por e-mail(Odirlei-AMcom)   
                   
                   01/10/2014 - Ajuste para ler a nova origem (10) criada para os produtos de captação.
                                (Carlos Rafael Tanholi - Projeto Captacao)              

    ............................................................................ */

    DECLARE
      -- Definição de tipo para collection
      TYPE typ_narray IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

      -- Definição de PL Table de dados temporários
      TYPE typ_reg_craptmp IS
        RECORD(nrdconta crapass.nrdconta%TYPE
              ,cdcooper crapcop.cdcooper%TYPE
              ,nmrescop crapcop.nmrescop%TYPE
              ,vltotobr typ_narray
              ,vloutros NUMBER
              ,vldepprz typ_narray
              ,vldepavs NUMBER
              ,vldeposi typ_narray);
      TYPE typ_tab_craptmp IS TABLE OF typ_reg_craptmp INDEX BY VARCHAR2(100);

      -- Definição de PL Table da tabela CRAPCOP
      TYPE typ_reg_crapcop IS
        RECORD(nrctactl crapcop.nrctactl%TYPE
              ,cdcooper crapcop.cdcooper%TYPE
              ,nmrescop crapcop.nmrescop%TYPE);
      TYPE typ_tab_crapcop IS TABLE OF typ_reg_crapcop INDEX BY VARCHAR2(100);

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS578';

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      PLS_INTEGER;
      vr_dscritic      VARCHAR2(4000);

      -- Variáveis de negócio
      vr_nrindice     PLS_INTEGER;
      vr_vldeposi_1   NUMBER(20,2) := 0;
      vr_vldeposi_2   NUMBER(20,2) := 0;
      vr_vldeposi_3   NUMBER(20,2) := 0;
      vr_vldeposi_4   NUMBER(20,2) := 0;
      vr_vldeposi_5   NUMBER(20,2) := 0;
      vr_vldeposi_6   NUMBER(20,2) := 0;
      vr_vldeposi_7   NUMBER(20,2) := 0;
      vr_vldepavs_1   NUMBER(20,2) := 0;
      vr_vldepprz_2   NUMBER(20,2) := 0;
      vr_vldepprz_3   NUMBER(20,2) := 0;
      Vr_vldepprz_4   NUMBER(20,2) := 0;
      vr_vldepprz_5   NUMBER(20,2) := 0;
      vr_vldepprz_6   NUMBER(20,2) := 0;
      vr_vldepprz_7   NUMBER(20,2) := 0;
      vr_vloutros_1   NUMBER(20,2) := 0;
      vr_vltotobr_1   NUMBER(20,2) := 0;
      vr_vltotobr_2   NUMBER(20,2) := 0;
      vr_vltotobr_3   NUMBER(20,2) := 0;
      vr_vltotobr_4   NUMBER(20,2) := 0;
      vr_vltotobr_5   NUMBER(20,2) := 0;
      vr_vltotobr_6   NUMBER(20,2) := 0;
      vr_vltotobr_7   NUMBER(20,2) := 0;
      vr_tab_craptmp  typ_tab_craptmp;
      vr_tab_crapcop  typ_tab_crapcop;
      vr_index        VARCHAR2(100);
      vr_cindex       VARCHAR2(100);
      vr_cxml         CLOB;
      vr_bxml         VARCHAR2(32767);
      vr_nom_dir      VARCHAR2(256);
      vr_emails       VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------
      -- Buscar dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrctactl
              ,cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper = NVL(pr_cdcooper, cop.cdcooper);
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Buscar dados exigidos pelo BNDES
      CURSOR cr_crapbnd(pr_cdcooper IN crapbnd.cdcooper%TYPE
                       ,pr_dtmvtoan IN crapbnd.dtmvtolt%TYPE) IS
        SELECT cn.vldepavs
              ,cn.nrdconta
        FROM crapbnd cn
        WHERE cn.cdcooper = pr_cdcooper
          AND cn.dtmvtolt = pr_dtmvtoan;

      -- Buscar dados de retorno de produtos para levantamento de informacoes solicitadas pelo BNDES
      CURSOR cr_crapprb(pr_cdcooper IN crapprb.cdcooper%TYPE
                       ,pr_dtmvtoan IN crapprb.dtmvtolt%TYPE) IS
        SELECT cb.cdorigem
              ,cb.vlretorn
              ,cb.nrdconta
              ,cb.cddprazo
        FROM crapprb cb
        WHERE (cb.cdcooper = pr_cdcooper
               AND cb.dtmvtolt = pr_dtmvtoan
               AND cb.cdorigem = 1)
          OR (cb.cdcooper = pr_cdcooper
              AND cb.dtmvtolt = pr_dtmvtoan
              AND cb.cdorigem = 5)
          OR (cb.cdcooper = pr_cdcooper
              AND cb.dtmvtolt = pr_dtmvtoan
              AND cb.cdorigem = 6)
          OR (cb.cdcooper = pr_cdcooper
              AND cb.dtmvtolt = pr_dtmvtoan
              AND cb.cdorigem = 7)
          OR (cb.cdcooper = pr_cdcooper
              AND cb.dtmvtolt = pr_dtmvtoan
              AND cb.cdorigem = 8)
          OR (cb.cdcooper = pr_cdcooper
              AND cb.dtmvtolt = pr_dtmvtoan
              AND cb.cdorigem = 9)
          OR (cb.cdcooper = pr_cdcooper
              AND cb.dtmvtolt = pr_dtmvtoan
              AND cb.cdorigem = 10);

    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => NULL);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
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
      -- Carregar dados das cooperativas
      FOR rw_crapcop IN cr_crapcop(NULL) LOOP
        vr_tab_crapcop(LPAD(rw_crapcop.nrctactl, 15, '0')).nrctactl := rw_crapcop.nrctactl;
        vr_tab_crapcop(LPAD(rw_crapcop.nrctactl, 15, '0')).cdcooper := rw_crapcop.cdcooper;
        vr_tab_crapcop(LPAD(rw_crapcop.nrctactl, 15, '0')).nmrescop := rw_crapcop.nmrescop;
      END LOOP;

      -- Buscar nome da pasta do relatório
      vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl');

      -- Levantar dados para BNDES -- Linha à vista
      FOR rw_crapbnd IN cr_crapbnd(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
        -- Sumarizar valores
        vr_vldepavs_1 := vr_vldepavs_1 + rw_crapbnd.vldepavs;
        vr_vldeposi_1 := vr_vldeposi_1 + rw_crapbnd.vldepavs;
        vr_vltotobr_1 := vr_vltotobr_1 + rw_crapbnd.vldepavs;

        -- Gerar índice para as cooperativas
        vr_cindex := LPAD(rw_crapbnd.nrdconta, 15, '0');

        -- Verificar paridade entre contas das cooperativas
        IF vr_tab_crapcop.exists(vr_cindex) THEN
          -- Criar índice para PL Table
          vr_index := LPAD(vr_tab_crapcop(vr_cindex).nrctactl, 15, '0');

          -- Verificar se registro já foi criado
          IF vr_tab_craptmp.exists(vr_index) THEN
            vr_tab_craptmp(vr_index).vldepavs := vr_tab_craptmp(vr_index).vldepavs + NVL(rw_crapbnd.vldepavs, 0);
            vr_tab_craptmp(vr_index).vldeposi(1) := vr_tab_craptmp(vr_index).vldeposi(1) + NVL(rw_crapbnd.vldepavs, 0);
            vr_tab_craptmp(vr_index).vltotobr(1) := vr_tab_craptmp(vr_index).vltotobr(1) + NVL(rw_crapbnd.vldepavs, 0);
          ELSE
            vr_tab_craptmp(vr_index).nrdconta := vr_tab_crapcop(vr_cindex).nrctactl;
            vr_tab_craptmp(vr_index).cdcooper := vr_tab_crapcop(vr_cindex).cdcooper;
            vr_tab_craptmp(vr_index).nmrescop := vr_tab_crapcop(vr_cindex).nmrescop;
            vr_tab_craptmp(vr_index).vldepavs := NVL(rw_crapbnd.vldepavs, 0);
            vr_tab_craptmp(vr_index).vldeposi(1) := NVL(rw_crapbnd.vldepavs, 0);
            vr_tab_craptmp(vr_index).vldeposi(2) := 0;
            vr_tab_craptmp(vr_index).vldeposi(3) := 0;
            vr_tab_craptmp(vr_index).vldeposi(4) := 0;
            vr_tab_craptmp(vr_index).vldeposi(5) := 0;
            vr_tab_craptmp(vr_index).vldeposi(6) := 0;
            vr_tab_craptmp(vr_index).vldeposi(7) := 0;
            vr_tab_craptmp(vr_index).vltotobr(1) := NVL(rw_crapbnd.vldepavs, 0);
            vr_tab_craptmp(vr_index).vltotobr(2) := 0;
            vr_tab_craptmp(vr_index).vltotobr(3) := 0;
            vr_tab_craptmp(vr_index).vltotobr(4) := 0;
            vr_tab_craptmp(vr_index).vltotobr(5) := 0;
            vr_tab_craptmp(vr_index).vltotobr(6) := 0;
            vr_tab_craptmp(vr_index).vltotobr(7) := 0;
            vr_tab_craptmp(vr_index).vldepprz(1) := 0;
            vr_tab_craptmp(vr_index).vldepprz(2) := 0;
            vr_tab_craptmp(vr_index).vldepprz(3) := 0;
            vr_tab_craptmp(vr_index).vldepprz(4) := 0;
            vr_tab_craptmp(vr_index).vldepprz(5) := 0;
            vr_tab_craptmp(vr_index).vldepprz(6) := 0;
            vr_tab_craptmp(vr_index).vldepprz(7) := 0;
            vr_tab_craptmp(vr_index).vloutros := 0;
          END IF;
        END IF;
      END LOOP;

      -- Buscar informações de produtos para o BNDES
      FOR rw_crapprb IN cr_crapprb(pr_cdcooper, rw_crapdat.dtmvtoan) LOOP
        IF rw_crapprb.cdorigem = 1 THEN
          -- Sumarizar valores
          vr_vloutros_1 := vr_vloutros_1 + NVL(rw_crapprb.vlretorn, 0);
          vr_vldeposi_1 := vr_vldeposi_1 + NVL(rw_crapprb.vlretorn, 0);
          vr_vltotobr_1 := vr_vltotobr_1 + NVL(rw_crapprb.vlretorn, 0);

          -- Gerar índice para as cooperativas
          vr_cindex := LPAD(rw_crapprb.nrdconta, 15, '0');

          -- Verifica paridade nas contas
          IF vr_tab_crapcop.exists(vr_cindex) THEN
            vr_index := LPAD(vr_tab_crapcop(vr_cindex).nrctactl, 15, '0');

            -- Verificar se registro já foi criado
            IF vr_tab_craptmp.exists(vr_index) THEN
              vr_tab_craptmp(vr_index).vloutros := vr_tab_craptmp(vr_index).vloutros + NVL(rw_crapprb.vlretorn, 0);
              vr_tab_craptmp(vr_index).vldeposi(1) := vr_tab_craptmp(vr_index).vldeposi(1) + NVL(rw_crapprb.vlretorn, 0);
              vr_tab_craptmp(vr_index).vltotobr(1) := vr_tab_craptmp(vr_index).vltotobr(1) + NVL(rw_crapprb.vlretorn, 0);
            ELSE
              vr_tab_craptmp(vr_index).nrdconta := vr_tab_crapcop(vr_cindex).nrctactl;
              vr_tab_craptmp(vr_index).cdcooper := vr_tab_crapcop(vr_cindex).cdcooper;
              vr_tab_craptmp(vr_index).nmrescop := vr_tab_crapcop(vr_cindex).nmrescop;
              vr_tab_craptmp(vr_index).vloutros := NVL(rw_crapprb.vlretorn, 0);
              vr_tab_craptmp(vr_index).vldeposi(1) := NVL(rw_crapprb.vlretorn, 0);
              vr_tab_craptmp(vr_index).vldeposi(2) := 0;
              vr_tab_craptmp(vr_index).vldeposi(3) := 0;
              vr_tab_craptmp(vr_index).vldeposi(4) := 0;
              vr_tab_craptmp(vr_index).vldeposi(5) := 0;
              vr_tab_craptmp(vr_index).vldeposi(6) := 0;
              vr_tab_craptmp(vr_index).vldeposi(7) := 0;
              vr_tab_craptmp(vr_index).vltotobr(1) := NVL(rw_crapprb.vlretorn, 0);
              vr_tab_craptmp(vr_index).vltotobr(2) := 0;
              vr_tab_craptmp(vr_index).vltotobr(3) := 0;
              vr_tab_craptmp(vr_index).vltotobr(4) := 0;
              vr_tab_craptmp(vr_index).vltotobr(5) := 0;
              vr_tab_craptmp(vr_index).vltotobr(6) := 0;
              vr_tab_craptmp(vr_index).vltotobr(7) := 0;
              vr_tab_craptmp(vr_index).vldepprz(1) := 0;
              vr_tab_craptmp(vr_index).vldepprz(2) := 0;
              vr_tab_craptmp(vr_index).vldepprz(3) := 0;
              vr_tab_craptmp(vr_index).vldepprz(4) := 0;
              vr_tab_craptmp(vr_index).vldepprz(5) := 0;
              vr_tab_craptmp(vr_index).vldepprz(6) := 0;
              vr_tab_craptmp(vr_index).vldepprz(7) := 0;
              vr_tab_craptmp(vr_index).vldepavs := 0;
            END IF;
          END IF;
        ELSE
          -- Verificar as linhas a prazo
          IF rw_crapprb.cddprazo <= 90 THEN
            -- Verificar se é diferente de ZERO
            IF rw_crapprb.cddprazo <> 0 THEN
              vr_vldepprz_2 := vr_vldepprz_2 + NVL(rw_crapprb.vlretorn, 0);
              vr_vldeposi_2 := vr_vldeposi_2 + NVL(rw_crapprb.vlretorn, 0);
              vr_vltotobr_2 := vr_vltotobr_2 + NVL(rw_crapprb.vlretorn, 0);
              vr_nrindice := 2;
            END IF;
          ELSIF rw_crapprb.cddprazo <= 360 THEN
            vr_vldepprz_3 := vr_vldepprz_3 + NVL(rw_crapprb.vlretorn, 0);
            vr_vldeposi_3 := vr_vldeposi_3 + NVL(rw_crapprb.vlretorn, 0);
            vr_vltotobr_3 := vr_vltotobr_3 + NVL(rw_crapprb.vlretorn, 0);
            vr_nrindice := 3;
          ELSIF rw_crapprb.cddprazo <= 1080 THEN
            vr_vldepprz_4 := vr_vldepprz_4 + NVL(rw_crapprb.vlretorn, 0);
            vr_vldeposi_4 := vr_vldeposi_4 + NVL(rw_crapprb.vlretorn, 0);
            vr_vltotobr_4 := vr_vltotobr_4 + NVL(rw_crapprb.vlretorn, 0);
            vr_nrindice := 4;
          ELSIF rw_crapprb.cddprazo <= 1800 THEN
            vr_vldepprz_5 := vr_vldepprz_5 + NVL(rw_crapprb.vlretorn, 0);
            vr_vldeposi_5 := vr_vldeposi_5 + NVL(rw_crapprb.vlretorn, 0);
            vr_vltotobr_5 := vr_vltotobr_5 + NVL(rw_crapprb.vlretorn, 0);
            vr_nrindice := 5;
          ELSIF rw_crapprb.cddprazo <= 5400 THEN
            vr_vldepprz_6 := vr_vldepprz_6 + NVL(rw_crapprb.vlretorn, 0);
            vr_vldeposi_6 := vr_vldeposi_6 + NVL(rw_crapprb.vlretorn, 0);
            vr_vltotobr_6 := vr_vltotobr_6 + NVL(rw_crapprb.vlretorn, 0);
            vr_nrindice := 6;
          ELSE
            vr_vldepprz_7 := vr_vldepprz_7 + NVL(rw_crapprb.vlretorn, 0);
            vr_vldeposi_7 := vr_vldeposi_7 + NVL(rw_crapprb.vlretorn, 0);
            vr_vltotobr_7 := vr_vltotobr_7 + NVL(rw_crapprb.vlretorn, 0);
            vr_nrindice := 7;
          END IF;

          -- Verifica se o índice gerado é diferente de ZERO
          IF vr_nrindice <> 0 THEN
            -- Gerar índice para as cooperativas
            vr_cindex := LPAD(rw_crapprb.nrdconta, 15, '0');

            -- Verifica paridade nas contas
            IF vr_tab_crapcop.exists(vr_cindex) THEN
              -- Gerar índice
              vr_index := LPAD(vr_tab_crapcop(vr_cindex).nrctactl, 15, '0');

              -- Verificar se registro já foi criado
              IF vr_tab_craptmp.exists(vr_index) THEN
                vr_tab_craptmp(vr_index).vldepprz(vr_nrindice) := vr_tab_craptmp(vr_index).vldepprz(vr_nrindice) + NVL(rw_crapprb.vlretorn, 0);
                vr_tab_craptmp(vr_index).vldeposi(vr_nrindice) := vr_tab_craptmp(vr_index).vldeposi(vr_nrindice) + NVL(rw_crapprb.vlretorn, 0);
                vr_tab_craptmp(vr_index).vltotobr(vr_nrindice) := vr_tab_craptmp(vr_index).vltotobr(vr_nrindice) + NVL(rw_crapprb.vlretorn, 0);
              ELSE
                vr_tab_craptmp(vr_index).nrdconta := vr_tab_crapcop(vr_cindex).nrctactl;
                vr_tab_craptmp(vr_index).cdcooper := vr_tab_crapcop(vr_cindex).cdcooper;
                vr_tab_craptmp(vr_index).nmrescop := vr_tab_crapcop(vr_cindex).nmrescop;
                -- Criar índices de campo
                vr_tab_craptmp(vr_index).vldepprz(1) := 0;
                vr_tab_craptmp(vr_index).vldepprz(2) := 0;
                vr_tab_craptmp(vr_index).vldepprz(3) := 0;
                vr_tab_craptmp(vr_index).vldepprz(4) := 0;
                vr_tab_craptmp(vr_index).vldepprz(5) := 0;
                vr_tab_craptmp(vr_index).vldepprz(6) := 0;
                vr_tab_craptmp(vr_index).vldepprz(7) := 0;
                vr_tab_craptmp(vr_index).vldeposi(1) := 0;
                vr_tab_craptmp(vr_index).vldeposi(2) := 0;
                vr_tab_craptmp(vr_index).vldeposi(3) := 0;
                vr_tab_craptmp(vr_index).vldeposi(4) := 0;
                vr_tab_craptmp(vr_index).vldeposi(5) := 0;
                vr_tab_craptmp(vr_index).vldeposi(6) := 0;
                vr_tab_craptmp(vr_index).vldeposi(7) := 0;
                vr_tab_craptmp(vr_index).vltotobr(1) := 0;
                vr_tab_craptmp(vr_index).vltotobr(2) := 0;
                vr_tab_craptmp(vr_index).vltotobr(3) := 0;
                vr_tab_craptmp(vr_index).vltotobr(4) := 0;
                vr_tab_craptmp(vr_index).vltotobr(5) := 0;
                vr_tab_craptmp(vr_index).vltotobr(6) := 0;
                vr_tab_craptmp(vr_index).vltotobr(7) := 0;
                --
                vr_tab_craptmp(vr_index).vldepprz(vr_nrindice) := NVL(rw_crapprb.vlretorn, 0);
                vr_tab_craptmp(vr_index).vldeposi(vr_nrindice) := NVL(rw_crapprb.vlretorn, 0);
                vr_tab_craptmp(vr_index).vltotobr(vr_nrindice) := NVL(rw_crapprb.vlretorn, 0);
                vr_tab_craptmp(vr_index).vloutros := 0;
                vr_tab_craptmp(vr_index).vldepavs := 0;
              END IF;
            END IF;

            -- Zerar índice
            vr_nrindice := 0;
          END IF;
        END IF;
      END LOOP;

      -- Agregar valores nas variáveis e acertar base 1000
      vr_vldepavs_1 := vr_vldepavs_1 / 1000;
      vr_vloutros_1 := vr_vloutros_1 / 1000;
      vr_vldeposi_1 := vr_vldeposi_1 / 1000;
      vr_vldeposi_2 := vr_vldeposi_2 / 1000;
      vr_vldeposi_3 := vr_vldeposi_3 / 1000;
      vr_vldeposi_4 := vr_vldeposi_4 / 1000;
      vr_vldeposi_5 := vr_vldeposi_5 / 1000;
      vr_vldeposi_6 := vr_vldeposi_6 / 1000;
      vr_vldeposi_7 := vr_vldeposi_7 / 1000;
      vr_vldepprz_2 := vr_vldepprz_2 / 1000;
      vr_vldepprz_3 := vr_vldepprz_3 / 1000;
      vr_vldepprz_4 := vr_vldepprz_4 / 1000;
      vr_vldepprz_5 := vr_vldepprz_5 / 1000;
      vr_vldepprz_6 := vr_vldepprz_6 / 1000;
      vr_vldepprz_7 := vr_vldepprz_7 / 1000;
      vr_vltotobr_1 := vr_vldeposi_1;
      vr_vltotobr_2 := vr_vldeposi_2;
      vr_vltotobr_3 := vr_vldeposi_3;
      vr_vltotobr_4 := vr_vldeposi_4;
      vr_vltotobr_5 := vr_vldeposi_5;
      vr_vltotobr_6 := vr_vldeposi_6;
      vr_vltotobr_7 := vr_vldeposi_7;

      -- Inicializar CLOB
      dbms_lob.createtemporary(vr_cxml, TRUE);
      dbms_lob.open(vr_cxml, dbms_lob.lob_readwrite);

      -- Gerar cabeçalho no XML
      vr_bxml := '<?xml version="1.0" encoding="utf-8"?><root>';

      -- Abrir TAG
      vr_bxml := vr_bxml || '<conteudos>';

      -- Cálcular singulares
      -- Obter primeiro índice
      vr_index := vr_tab_craptmp.first;
      LOOP
        EXIT WHEN vr_index IS NULL;

        vr_tab_craptmp(vr_index).vldepavs := vr_tab_craptmp(vr_index).vldepavs / 1000;
        vr_tab_craptmp(vr_index).vloutros := vr_tab_craptmp(vr_index).vloutros / 1000;
        vr_tab_craptmp(vr_index).vldeposi(1) := vr_tab_craptmp(vr_index).vldeposi(1) / 1000;
        vr_tab_craptmp(vr_index).vldeposi(2) := vr_tab_craptmp(vr_index).vldeposi(2) / 1000;
        vr_tab_craptmp(vr_index).vldeposi(3) := vr_tab_craptmp(vr_index).vldeposi(3) / 1000;
        vr_tab_craptmp(vr_index).vldeposi(4) := vr_tab_craptmp(vr_index).vldeposi(4) / 1000;
        vr_tab_craptmp(vr_index).vldeposi(5) := vr_tab_craptmp(vr_index).vldeposi(5) / 1000;
        vr_tab_craptmp(vr_index).vldeposi(6) := vr_tab_craptmp(vr_index).vldeposi(6) / 1000;
        vr_tab_craptmp(vr_index).vldeposi(7) := vr_tab_craptmp(vr_index).vldeposi(7) / 1000;
        vr_tab_craptmp(vr_index).vldepprz(2) := vr_tab_craptmp(vr_index).vldepprz(2) / 1000;
        vr_tab_craptmp(vr_index).vldepprz(3) := vr_tab_craptmp(vr_index).vldepprz(3) / 1000;
        vr_tab_craptmp(vr_index).vldepprz(4) := vr_tab_craptmp(vr_index).vldepprz(4) / 1000;
        vr_tab_craptmp(vr_index).vldepprz(5) := vr_tab_craptmp(vr_index).vldepprz(5) / 1000;
        vr_tab_craptmp(vr_index).vldepprz(6) := vr_tab_craptmp(vr_index).vldepprz(6) / 1000;
        vr_tab_craptmp(vr_index).vldepprz(7) := vr_tab_craptmp(vr_index).vldepprz(7) / 1000;
        vr_tab_craptmp(vr_index).vltotobr(1) := vr_tab_craptmp(vr_index).vldeposi(1);
        vr_tab_craptmp(vr_index).vltotobr(2) := vr_tab_craptmp(vr_index).vldeposi(2);
        vr_tab_craptmp(vr_index).vltotobr(3) := vr_tab_craptmp(vr_index).vldeposi(3);
        vr_tab_craptmp(vr_index).vltotobr(4) := vr_tab_craptmp(vr_index).vldeposi(4);
        vr_tab_craptmp(vr_index).vltotobr(5) := vr_tab_craptmp(vr_index).vldeposi(5);
        vr_tab_craptmp(vr_index).vltotobr(6) := vr_tab_craptmp(vr_index).vldeposi(6);
        vr_tab_craptmp(vr_index).vltotobr(7) := vr_tab_craptmp(vr_index).vldeposi(7);

        -- Gerar conteúdo no XML para relatório
        vr_bxml := vr_bxml || '<conteudo><dtmvtoan>' || TO_CHAR(rw_crapdat.dtmvtoan, 'DD/MM/RRRR') || '</dtmvtoan>';
        vr_bxml := vr_bxml || '<cdcooper>' || vr_tab_craptmp(vr_index).cdcooper || '</cdcooper>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<nmrescop>' || vr_tab_craptmp(vr_index).nmrescop || '</nmrescop>';
        vr_bxml := vr_bxml || '<vldepavs>' || TO_CHAR(vr_tab_craptmp(vr_index).vldepavs, 'FM999G999G999G990D00') || '</vldepavs>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vloutros>' || TO_CHAR(vr_tab_craptmp(vr_index).vloutros, 'FM999G999G999G990D00') || '</vloutros>';
        vr_bxml := vr_bxml || '<vldeposi1>' || TO_CHAR(vr_tab_craptmp(vr_index).vldeposi(1), 'FM999G999G999G990D00') || '</vldeposi1>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vldeposi2>' || TO_CHAR(vr_tab_craptmp(vr_index).vldeposi(2), 'FM999G999G999G990D00') || '</vldeposi2>';
        vr_bxml := vr_bxml || '<vldeposi3>' || TO_CHAR(vr_tab_craptmp(vr_index).vldeposi(3), 'FM999G999G999G990D00') || '</vldeposi3>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vldeposi4>' || TO_CHAR(vr_tab_craptmp(vr_index).vldeposi(4), 'FM999G999G999G990D00') || '</vldeposi4>';
        vr_bxml := vr_bxml || '<vldeposi5>' || TO_CHAR(vr_tab_craptmp(vr_index).vldeposi(5), 'FM999G999G999G990D00') || '</vldeposi5>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vldeposi6>' || TO_CHAR(vr_tab_craptmp(vr_index).vldeposi(6), 'FM999G999G999G990D00') || '</vldeposi6>';
        vr_bxml := vr_bxml || '<vldeposi7>' || TO_CHAR(vr_tab_craptmp(vr_index).vldeposi(7), 'FM999G999G999G990D00') || '</vldeposi7>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vldepprz2>' || TO_CHAR(vr_tab_craptmp(vr_index).vldepprz(2), 'FM999G999G999G990D00') || '</vldepprz2>';
        vr_bxml := vr_bxml || '<vldepprz3>' || TO_CHAR(vr_tab_craptmp(vr_index).vldepprz(3), 'FM999G999G999G990D00') || '</vldepprz3>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vldepprz4>' || TO_CHAR(vr_tab_craptmp(vr_index).vldepprz(4), 'FM999G999G999G990D00') || '</vldepprz4>';
        vr_bxml := vr_bxml || '<vldepprz5>' || TO_CHAR(vr_tab_craptmp(vr_index).vldepprz(5), 'FM999G999G999G990D00') || '</vldepprz5>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vldepprz6>' || TO_CHAR(vr_tab_craptmp(vr_index).vldepprz(6), 'FM999G999G999G990D00') || '</vldepprz6>';
        vr_bxml := vr_bxml || '<vldepprz7>' || TO_CHAR(vr_tab_craptmp(vr_index).vldepprz(7), 'FM999G999G999G990D00') || '</vldepprz7>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vltotobr1>' || TO_CHAR(vr_tab_craptmp(vr_index).vltotobr(1), 'FM999G999G999G990D00') || '</vltotobr1>';
        vr_bxml := vr_bxml || '<vltotobr2>' || TO_CHAR(vr_tab_craptmp(vr_index).vltotobr(2), 'FM999G999G999G990D00') || '</vltotobr2>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vltotobr3>' || TO_CHAR(vr_tab_craptmp(vr_index).vltotobr(3), 'FM999G999G999G990D00') || '</vltotobr3>';
        vr_bxml := vr_bxml || '<vltotobr4>' || TO_CHAR(vr_tab_craptmp(vr_index).vltotobr(4), 'FM999G999G999G990D00') || '</vltotobr4>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
        vr_bxml := vr_bxml || '<vltotobr5>' || TO_CHAR(vr_tab_craptmp(vr_index).vltotobr(5), 'FM999G999G999G990D00') || '</vltotobr5>';
        vr_bxml := vr_bxml || '<vltotobr6>' || TO_CHAR(vr_tab_craptmp(vr_index).vltotobr(6), 'FM999G999G999G990D00') || '</vltotobr6>';
        vr_bxml := vr_bxml || '<vltotobr7>' || TO_CHAR(vr_tab_craptmp(vr_index).vltotobr(7), 'FM999G999G999G990D00') || '</vltotobr7></conteudo>';
        gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);

        -- Buscar próximo índice
        vr_index := vr_tab_craptmp.next(vr_index);
      END LOOP;

      -- Finalizar conteúdo
      vr_bxml := vr_bxml || '<conteudo><dtmvtoan>' || TO_CHAR(rw_crapdat.dtmvtoan, 'DD/MM/RRRR') || '</dtmvtoan>';
      vr_bxml := vr_bxml || '<cdcooper>0</cdcooper>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<nmrescop>Todas</nmrescop>';
      vr_bxml := vr_bxml || '<vldepavs>' || TO_CHAR(vr_vldepavs_1, 'FM999G999G999G990D00') || '</vldepavs>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vloutros>' || TO_CHAR(vr_vloutros_1, 'FM999G999G999G990D00') || '</vloutros>';
      vr_bxml := vr_bxml || '<vldeposi1>' || TO_CHAR(vr_vldeposi_1, 'FM999G999G999G990D00') || '</vldeposi1>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vldeposi2>' || TO_CHAR(vr_vldeposi_2, 'FM999G999G999G990D00') || '</vldeposi2>';
      vr_bxml := vr_bxml || '<vldeposi3>' || TO_CHAR(vr_vldeposi_3, 'FM999G999G999G990D00') || '</vldeposi3>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vldeposi4>' || TO_CHAR(vr_vldeposi_4, 'FM999G999G999G990D00') || '</vldeposi4>';
      vr_bxml := vr_bxml || '<vldeposi5>' || TO_CHAR(vr_vldeposi_5, 'FM999G999G999G990D00') || '</vldeposi5>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vldeposi6>' || TO_CHAR(vr_vldeposi_6, 'FM999G999G999G990D00') || '</vldeposi6>';
      vr_bxml := vr_bxml || '<vldeposi7>' || TO_CHAR(vr_vldeposi_7, 'FM999G999G999G990D00') || '</vldeposi7>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vldepprz2>' || TO_CHAR(vr_vldepprz_2, 'FM999G999G999G990D00') || '</vldepprz2>';
      vr_bxml := vr_bxml || '<vldepprz3>' || TO_CHAR(vr_vldepprz_3, 'FM999G999G999G990D00') || '</vldepprz3>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vldepprz4>' || TO_CHAR(vr_vldepprz_4, 'FM999G999G999G990D00') || '</vldepprz4>';
      vr_bxml := vr_bxml || '<vldepprz5>' || TO_CHAR(vr_vldepprz_5, 'FM999G999G999G990D00') || '</vldepprz5>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vldepprz6>' || TO_CHAR(vr_vldepprz_6, 'FM999G999G999G990D00') || '</vldepprz6>';
      vr_bxml := vr_bxml || '<vldepprz7>' || TO_CHAR(vr_vldepprz_7, 'FM999G999G999G990D00') || '</vldepprz7>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vltotobr1>' || TO_CHAR(vr_vltotobr_1, 'FM999G999G999G990D00') || '</vltotobr1>';
      vr_bxml := vr_bxml || '<vltotobr2>' || TO_CHAR(vr_vltotobr_2, 'FM999G999G999G990D00') || '</vltotobr2>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vltotobr3>' || TO_CHAR(vr_vltotobr_3, 'FM999G999G999G990D00') || '</vltotobr3>';
      vr_bxml := vr_bxml || '<vltotobr4>' || TO_CHAR(vr_vltotobr_4, 'FM999G999G999G990D00') || '</vltotobr4>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vltotobr5>' || TO_CHAR(vr_vltotobr_5, 'FM999G999G999G990D00') || '</vltotobr5>';
      vr_bxml := vr_bxml || '<vltotobr6>' || TO_CHAR(vr_vltotobr_6, 'FM999G999G999G990D00') || '</vltotobr6>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => FALSE, pr_clob => vr_cxml);
      vr_bxml := vr_bxml || '<vltotobr7>' || TO_CHAR(vr_vltotobr_7, 'FM999G999G999G990D00') || '</vltotobr7></conteudo>';

      -- Fechar TAG XML
      vr_bxml := vr_bxml || '</conteudos></root>';
      gene0002.pc_clob_buffer(pr_dados => vr_bxml, pr_gravfim => TRUE, pr_clob => vr_cxml);

      -- Criar lista de emails para envio do relatório
      vr_emails := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL571');

      -- Verific se a lista retornou valores
      IF vr_emails IS NULL THEN
        vr_dscritic := 'Não foi encontrado destinatário para relatório CRRL571.';

        RAISE vr_exc_fimprg;
      END IF;

      -- Gerar relatório
      gene0002.pc_solicita_relato(pr_cdcooper    => pr_cdcooper
                                   ,pr_cdprogra  => vr_cdprogra
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                   ,pr_dsxml     => vr_cxml
                                   ,pr_dsxmlnode => '/root/conteudos/conteudo'
                                   ,pr_dsjasper  => 'crrl571.jasper'
                                   ,pr_dsparams  => NULL
                                   ,pr_dsarqsaid => vr_nom_dir || '/crrl571.lst'
                                   ,pr_flg_gerar => 'N'
                                   ,pr_qtcoluna  => 234
                                   ,pr_sqcabrel  => 1
                                   ,pr_cdrelato  => NULL
                                   ,pr_flg_impri => 'S'
                                   ,pr_nmformul  => '234dh'
                                   ,pr_nrcopias  => 1
                                   ,pr_fldosmail => 'S'                 
                                   ,pr_dsmailcop => vr_emails
                                   ,pr_dsassmail => 'Informaçoes BNDES - Quadro 7027'
                                   ,pr_dscormail => NULL
                                   ,pr_dspathcop => NULL
                                   ,pr_dsextcop  => NULL
                                   ,pr_flsemqueb => 'N'
                                   ,pr_des_erro  => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Finalizar XML
      dbms_lob.close(vr_cxml);
      dbms_lob.freetemporary(vr_cxml);

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
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || vr_dscritic );

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
        pr_dscritic := SQLERRM;

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps578;
/

