CREATE OR REPLACE PROCEDURE CECRED.pc_crps341(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Cooperativa solicitada
                                       pr_flgresta IN PLS_INTEGER, --> Flag padrao para utilização de restart
                                       pr_stprogra OUT PLS_INTEGER, --> Saída de termino da execução
                                       pr_infimsol OUT PLS_INTEGER, --> Saída de termino da solicitacao
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE, --> Critica encontrada
                                       pr_dscritic OUT VARCHAR2) IS
BEGIN
  /* .............................................................................

    Programa: pc_crps341 (Fonte antigo > Fontes/crps341.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Edson
    Data    : Abril/2003                      Ultima atualizacao: 06/08/2018

    Dados referentes ao programa:

    Frequencia: Diario (Batch).
    Objetivo  : Atende a solicitacao 5.
                Efetuar os lancamentos automaticos no sistema de cheques
                descontados.
                Emite relatorio 287.

                Valores para insitlau: 1  ==> a processar
                                       2  ==> processada
                                       3  ==> com erro

    Alteracoes: 08/10/2003 - Atualiza craplcm.dtrefere (Margarete).

                06/12/2003 - Alterado para tratar cheque em custodia que foi
                             descontado (Edson).

                22/12/2003 - Alterado para tratar borderos NAO liberados
                             (Edson).

                30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                             craplcm e craprej (Diego).

                21/09/2005 - Modificado FIND FIRST para FIND na tabela
                              crapcop.cdcooper = glb_cdcooper (Diego).

                16/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).

                02/11/2005 - Uso da procedure digbbx.p para conversao de campo
                             inteiro para caracter (SQLWorks - Andre).

                18/11/2005 - Acertar leitura do crapfdc (Magui).

                10/12/2005 - Atualizar craprej.nrdctitg (Magui).

                17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                13/02/2007 - Alterar consultas com indice crapfdc1 (David).

                07/03/2007 - Ajustes para o Bancoob (Magui).

                04/06/2008 - Campo dsorigem nas leituras da craplau (David)

                14/07/2009 - incluido no for each a condição -
                             craplau.dsorigem <> "PG555" - Precise - paulo

                05/08/2009 - Criar craprej com dados fixos do lote pois na
                             primeira leitura ele nao tem o lote lido(Guilherme).

                02/06/2011 - incluido no for each a condição -
                             craplau.dsorigem <> "TAA" (Evandro).

                03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                             craplau. (Fabricio)

                02/01/2013 - Tratamento para os cheques das contas migradas
                             (Viacredi -> Alto Vale), realizado na procedure
                             proc_trata_desconto. (Fabricio)

                03/06/2013 - Incluido no FOR EACH craplau a condicao -
                             craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)

                14/11/2013 - CONVERSAO PROGRESS >>> PLSQL (Adriano).

                26/11/2013 - Adicionado tt-cheques-contas-altoVale.nrdocmto =
                             craplau.nrdocmto. (Fabricio)

                17/01/2014 - Corrigida as leituras da craptco na procedure
                             proc_trata_desconto. (Fabricio)

                24/01/2014 - Incluido 'RELEASE craptco' para garantir que o
                             programa nao pegue um registro lido anteriormente.
                             (Fabricio)

                28/01/2014 - Conversão das últimas atualizações para PL/SQL (Daniel - Supero)

                01/04/2014 - incluido nas consultas da craplau
                             craplau.dsorigem <> "DAUT BANCOOB" (Lucas).												          								

                06/05/2014 - Alterado busca na tabela crapfdc para considerar a cooperativa migrada (Odirlei-AMcom)
                
                30/07/2014 - Alterado para que a variável vr_nrdocmto fosse alimentada corretamente para inserção na lcm
                             (Vanessa - SD 156648)

                28/09/2015 - incluido nas consultas da craplau
                             craplau.dsorigem <> "CAIXA" (Lombardi).

                20/05/2016 - Incluido nas consultas da craplau
                             craplau.dsorigem <> "TRMULTAJUROS". (Jaison/James)


                20/06/2016 - Ajuste para não parar o processo em caso de contas em prejuizo (Daniel - Cecred) 
                
                07/07/2017 - #703725 Uso da variável vr_dscritic no lugar de pr_dscritic para logar as críticas
                             corretamente; e tratamento para ir para o próximo registro do cr_craplau ao invés de 
                             sair do looping (Carlos)
                             
                06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
                             após chamada da rotina de geraçao de lançamento em CONTA CORRENTE.
                             Alteração específica neste programa acrescentando o tratamento para a origem
                             BLQPREJU. Tratamento crítica 695 para também verificar conta em prejuízo
                             (Renato Cordeiro - AMcom)

  ............................................................................. */
  DECLARE
    --Busca os dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop,
             cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    --Cursor para bucar os lancamentos automaticos
    CURSOR cr_craplau IS
      SELECT lau.nrdconta,
             lau.dtmvtolt,
             lau.cdagenci,
             lau.cdbccxlt,
             lau.nrdolote,
             lau.cdseqtel,
             lau.insitlau,
             lau.cdhistor,
             lau.vllanaut,
             lau.dtdebito,
             lau.nrdctabb,
             lau.nrdctitg,
             lau.nrdocmto,
             lau.nrseqdig,
             ROWID
        FROM craplau lau
       WHERE lau.cdcooper = pr_cdcooper
         AND lau.cdbccxlt = 700 --Desconto de cheques
         AND lau.dtmvtopg > rw_crapdat.dtmvtolt
         AND lau.dtmvtopg <= rw_crapdat.dtmvtopr
         AND lau.insitlau = 1 --Pendente
         AND NOT lau.dsorigem IN ('CAIXA',
                                  'INTERNET',
                                  'TAA',
                                  'PG555',
                                  'CARTAOBB',
                                  'BLOQJUD',
                                  'DAUT BANCOOB',
                                  'TRMULTAJUROS',
                                  'BLQPREJU')
       order by cdcooper, nrdconta, dtmvtopg, cdhistor, nrdocmto; -- índice craplau2
    rw_craplau cr_craplau%ROWTYPE;
    --Cursor para buscar o associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta,
             ass.dtelimin,
             ass.cdsitdtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    --Cursor para buscar Transferencia e Duplicacao de Matricula
    CURSOR cr_craptrf(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT trf.nrsconta
        FROM craptrf trf
       WHERE trf.cdcooper = pr_cdcooper
         AND trf.nrdconta = pr_nrdconta
         AND trf.tptransa = 1; --Transferencia
    --Cursor para buscar os rejeitados
    CURSOR cr_craprej(pr_cdcooper craprej.cdcooper%TYPE,
                      pr_dtmvtolt craprej.dtmvtolt%TYPE,
                      pr_cdagenci craprej.cdagenci%TYPE,
                      pr_cdbccxlt craprej.cdbccxlt%TYPE,
                      pr_nrdolote craprej.nrdolote%TYPE) IS
      SELECT rej.cdcritic,
             rej.nraplica,
             rej.vllanmto,
             rej.cdpesqbb
        FROM craprej rej
       WHERE rej.cdcooper = pr_cdcooper
         AND rej.dtmvtolt = pr_dtmvtolt
         AND rej.cdagenci = pr_Cdagenci
         AND rej.cdbccxlt = pr_cdbccxlt
         AND rej.nrdolote = pr_nrdolote
         AND rej.tpintegr = 341
       ORDER BY rej.dtmvtolt,
                rej.cdagenci,
                rej.cdbccxlt,
                rej.nrdolote,
                rej.tpintegr,
                rej.nrseqdig;
    rw_craprej cr_craprej%ROWTYPE;
    --------------------------VARIAVEIS----------------------------------------
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS341';
    -- Nome do relatorio
    vr_nmrelato CONSTANT varchar2(12) := 'crrl287';
    --Tabela de erro
    vr_tab_erro GENE0001.typ_tab_erro;
    -- Codigo da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- Descrição da critica
    vr_dscritic VARCHAR2(4000);
    -- Tratamento de log
    vr_exc_log EXCEPTION;
    -- Tratamento de erro
    vr_exc_erro EXCEPTION;
    -- Tratamento de finalizacao do programa
    vr_exc_fimprg EXCEPTION;
    -- Tratamento de saida do programa
    vr_exc_saida EXCEPTION;
    --Variavel para armazenar conteudo do relatorio
    vr_dsxmldad CLOB;
    --Armazena o diretorio do relatorio
    vr_dsdireto VARCHAR2(400);
    --Armazena o numero da conta nova do associado
    vr_nrdconta craptrf.nrsconta%TYPE := 0;
    --Armazena a quantidade de lancamentos
    vr_qtdifeln INTEGER := 0;
    --Armazena o valor total dos debitos
    vr_vldifedb NUMBER(10, 2) := 0;
    --Armazena o valor total dos creditos
    vr_vldifecr NUMBER(10, 2) := 0;
    --Armazena a dascricao de historico
    vr_dshistor VARCHAR2(400) := '';
    --Armazena valor de retorno OK/NOK
    vr_des_reto VARCHAR(3) := '';
    -- Contador de registros rejeitados
    vr_cont_rej number(5);
    -- Tabela para armazenar os cheques de contas migradas (Viacredi > Viacredi Alto Vale)
    TYPE typ_reg_cheques_altovale IS RECORD(
      cdcooper craplcm.cdcooper%TYPE,
      nrdconta craplcm.nrdconta%TYPE,
      nrdctabb craplcm.nrdctabb%TYPE,
      nrdctitg craplcm.nrdctitg%TYPE,
      nrdocmto craplcm.nrdocmto%TYPE,
      cdhistor craplcm.cdhistor%TYPE,
      vllanmto craplcm.vllanmto%TYPE,
      cdbanchq crapfdc.cdbanchq%TYPE,
      cdagechq crapfdc.cdagechq%TYPE,
      nrctachq crapfdc.nrctachq%TYPE);
    TYPE typ_tab_cheques_altovale IS TABLE OF typ_reg_cheques_altovale INDEX BY VARCHAR2(100); --> Nossa chave será a nrdconta + nrdocmto
    -- PL/Table com a estrutura do registro acima
    vr_tab_cheques_altovale typ_tab_cheques_altovale;

    --Procedure para escrever na variavel CLOB
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_dsxmldad,LENGTH(pr_des_dados),pr_des_dados);
    END;

    --
    PROCEDURE pc_proc_rejeitados(pr_cdcooper IN INTEGER, --Codigo Cooperativa
                                 pr_cdagenci IN INTEGER, --Codigo Agencia
                                 pr_nrdcaixa IN INTEGER, --Numero do Caixa
                                 pr_nrdconta IN INTEGER, --Numero da Conta
                                 pr_dtmvtopr IN DATE, --Data de movimento do programa
                                 pr_nrcustod IN INTEGER, --Numero da conta
                                 pr_cdseqtel IN VARCHAR2, --Codigo sequencial do arquivo
                                 pr_vllanaut IN INTEGER, --Valor do lancamento automatico
                                 pr_cdhistor IN INTEGER, --Historico
                                 pr_nrdctabb IN INTEGER, --Numero da conta base no Banco do Brasil.
                                 pr_nrdocmto IN INTEGER, --Numero do documento
                                 pr_nrseqdig IN INTEGER, --Sequencia de digitacao
                                 pr_cdcritic IN INTEGER, --Codigo da critica da integracao
                                 pr_des_reto OUT VARCHAR, --Retorno OK / NOK
                                 pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com erros
      -- Procedimento para inserir as informações de regitros rejeitados
      --Variavel para armazenar o codigo do erro
      vr_cdcritic INTEGER := 0;
      --Variavel para armazenar a descricao do erro
      vr_dscritic VARCHAR2(4000) := '';
      --Variavel para armazenar a descricao da conta itg
      vr_dsdctitg VARCHAR2(1000) := '';
      --Variavel utilizada para formatacao da conta itg
      vr_stsnrcal INTEGER := 0;
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
    BEGIN
      -- Limpar a tabela de erro
      pr_tab_erro.DELETE;
      --Formata conta integracao
      GENE0005.pc_conta_itg_digito_x(pr_nrcalcul => pr_nrdctabb,
                                     pr_dscalcul => vr_dsdctitg,
                                     pr_stsnrcal => vr_stsnrcal,
                                     pr_cdcritic => vr_cdcritic,
                                     pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR
         vr_dscritic IS NOT NULL THEN
        --Gera exececao
        RAISE vr_exc_erro;
      END IF;
      --Cria registro de rejeitado
      BEGIN
        INSERT INTO craprej
          (craprej.dtmvtolt,
           craprej.cdagenci,
           craprej.cdbccxlt,
           craprej.nrdolote,
           craprej.tplotmov,
           craprej.cdhistor,
           craprej.nraplica,
           craprej.nrdconta,
           craprej.nrdctabb,
           craprej.nrdctitg,
           craprej.nrseqdig,
           craprej.nrdocmto,
           craprej.vllanmto,
           craprej.cdpesqbb,
           craprej.cdcritic,
           craprej.tpintegr,
           craprej.cdcooper)
        VALUES
          (pr_dtmvtopr,
           1,
           100,
           4501,
           1,
           pr_cdhistor,
           pr_nrcustod,
           pr_nrdconta,
           pr_nrdctabb,
           vr_dsdctitg,
           pr_nrseqdig,
           pr_nrdocmto,
           pr_vllanaut,
           pr_cdseqtel,
           pr_cdcritic,
           341,
           pr_cdcooper);
      EXCEPTION
        WHEN OTHERS THEN
          --Monta mensagem de erro
          vr_dscritic := 'Erro ao inserir dados na tabela craprej na rotina pc_proc_rejeitados. ' || SQLERRM;
          --Gera excecao
          RAISE vr_exc_erro;
      END;
      --Retorna OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        -- Gerar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1, --> Fixo
                              pr_cdcritic => nvl(vr_cdcritic, 0),
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      WHEN OTHERS THEN
        vr_dscritic := 'pc_proc_rejeitados --> Erro não tratado ao processar rejeitados:' || 'Conta:' || pr_nrdconta || '.Detalhes:' || sqlerrm;
        -- Gerar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1, --> Fixo
                              pr_cdcritic => NVL(vr_cdcritic, 0),
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
    END;

    PROCEDURE pc_processamento_tco(pr_cdcooper IN INTEGER,  --Codigo Cooperativa
                                   pr_dtmvtopr in date,     --Data do movimento do programa
                                   pr_tab_cheques_altovale IN typ_tab_cheques_altovale, --Tabela de cheques
                                   pr_cdprogra in varchar2,
                                   pr_des_reto OUT VARCHAR, --> Retorno OK / NOK
                                   pr_tab_erro OUT gene0001.typ_tab_erro) IS
      -- Procedimento para fazer o tratamento de cheques de contas migradas
      --> Tabela com erros
      --Cursor para buscar o lote
      CURSOR cr_craplot(pr_cdcooper craplot.cdcooper%TYPE,
                        pr_dtmvtolt craplot.dtmvtolt%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_cdbccxlt craplot.cdbccxlt%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT ROWID,
               lot.cdcooper,
               lot.cdagenci,
               lot.cdbccxlt,
               lot.nrdolote,
               lot.dtmvtolt,
               lot.nrseqdig
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;
      --Cursor para buscar lancamentos
      CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                        pr_cdagenci IN craplcm.cdagenci%TYPE,
                        pr_cdbccxlt IN craplcm.cdbccxlt%TYPE,
                        pr_nrdolote IN craplcm.nrdolote%TYPE,
                        pr_nrdctabb IN craplcm.nrdctabb%TYPE,
                        pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
        SELECT lcm.cdcooper,
               lcm.nrseqdig
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdagenci = pr_cdagenci
           AND lcm.cdbccxlt = pr_cdbccxlt
           AND lcm.nrdolote = pr_nrdolote
           AND lcm.nrdctabb = pr_nrdctabb
           AND lcm.nrdocmto = pr_nrdocmto;
      rw_craplcm cr_craplcm%ROWTYPE;
      --Variavel para armazenar o codigo da critica
      vr_cdcritic INTEGER := 0;
      --Variavel para armazenar a descricao da critica
      vr_dscritic VARCHAR2(4000) := '';
      --Variavel usada para controle da criacao do lote
      vr_gerarlot BOOLEAN := FALSE;
      --Variavel para armazenar o numero do lote
      vr_nrlotetc INTEGER := 4501;
      --Variavel para armazenar o numero do documento
      vr_nrdocmto INTEGER := 0;
      --Variavel para armazenar indice para leitura da tabela de cheques
      vr_indice VARCHAR2(100) := '';
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      -- Tratamento de log
      vr_exc_log EXCEPTION;
    BEGIN
      -- Limpar a tabela de erro
      pr_tab_erro.DELETE;
      -- posiciona no primeiro registro
      vr_indice := pr_tab_cheques_altovale.FIRST;
      -- navega em todos os registros da tabela temporaria
      WHILE vr_indice IS NOT NULL LOOP
        IF vr_gerarlot IS NULL THEN
          --Busca o lote
          OPEN cr_craplot(pr_cdcooper => pr_tab_cheques_altovale(vr_indice).cdcooper,
                          pr_dtmvtolt => pr_dtmvtopr,
                          pr_cdagenci => 1,
                          pr_cdbccxlt => 100,
                          pr_nrdolote => vr_nrlotetc);
          FETCH cr_craplot
            INTO rw_craplot;
          IF cr_craplot%NOTFOUND THEN
            --Fecha o cursor
            CLOSE cr_craplot;
            --Cria o lote
            BEGIN
              INSERT INTO craplot
                (craplot.cdcooper,
                 craplot.dtmvtolt,
                 craplot.cdagenci,
                 craplot.cdbccxlt,
                 craplot.nrdolote,
                 craplot.tplotmov)
              VALUES
                (pr_tab_cheques_altovale(vr_indice).cdcooper,
                 pr_dtmvtopr,
                 1,
                 100,
                 vr_nrlotetc,
                 1);
            EXCEPTION
              WHEN OTHERS THEN
                --Monta mensagem de erro
                vr_dscritic := 'Erro ao inserir dados na tabela craplot na rotina pc_processamento_tco. ' || SQLERRM;
                --Gera excecao
                RAISE vr_exc_erro;
            END;
          ELSE
            -- Fecha o cursor
            CLOSE cr_craplot;
            --Incrementa o numero do lote
            vr_nrlotetc := vr_nrlotetc + 1;
          END IF;
        ELSE
          --Busca o lote
          OPEN cr_craplot(pr_cdcooper => pr_tab_cheques_altovale(vr_indice).cdcooper,
                          pr_dtmvtolt => pr_dtmvtopr,
                          pr_cdagenci => 1,
                          pr_cdbccxlt => 100,
                          pr_nrdolote => vr_nrlotetc);
          FETCH cr_craplot
            INTO rw_craplot;
          IF cr_craplot%NOTFOUND THEN
            --Fecha o cursor
            CLOSE cr_craplot;
            --Monta codigo da mensagem
            vr_cdcritic := 60;
            --Gera raise para efetuar log do erro
            RAISE vr_exc_log;
          ELSE
            --Fecha o cursor
            CLOSE cr_craplot;
          END IF;
        END IF;
        vr_gerarlot := TRUE;
        vr_nrdocmto := pr_tab_cheques_altovale(vr_indice).nrdocmto;
        --Busca registro na craplcm referente ao cheque em questao
        OPEN cr_craplcm(pr_cdcooper => rw_craplot.cdcooper,
                        pr_dtmvtolt => rw_craplot.dtmvtolt,
                        pr_cdagenci => rw_craplot.cdagenci,
                        pr_cdbccxlt => rw_craplot.cdbccxlt,
                        pr_nrdolote => rw_craplot.nrdolote,
                        pr_nrdctabb => pr_tab_cheques_altovale(vr_indice).nrdctabb,
                        pr_nrdocmto => vr_nrlotetc);
        FETCH cr_craplcm
          INTO rw_craplcm;
        IF cr_craplcm%FOUND THEN
          --Fecha cursor
          CLOSE cr_craplcm;
          vr_nrdocmto := vr_nrdocmto + 1000000;
        ELSE
          --Fecha cursor
          CLOSE cr_craplcm;
        END IF;
        --Cria registro na craplcm referente ao cheque em questao
        BEGIN
          INSERT INTO craplcm
            (craplcm.dtmvtolt,
             craplcm.dtrefere,
             craplcm.cdagenci,
             craplcm.cdbccxlt,
             craplcm.nrdolote,
             craplcm.nrdconta,
             craplcm.nrdctabb,
             craplcm.nrdctitg,
             craplcm.nrdocmto,
             craplcm.cdhistor,
             craplcm.vllanmto,
             craplcm.nrseqdig,
             craplcm.cdcooper,
             craplcm.cdbanchq,
             craplcm.cdagechq,
             craplcm.nrctachq,
             craplcm.cdpesqbb)
          VALUES
            (rw_craplot.dtmvtolt,
             rw_craplot.dtmvtolt,
             rw_craplot.cdagenci,
             rw_craplot.cdbccxlt,
             rw_craplot.nrdolote,
             pr_tab_cheques_altovale(vr_indice).nrdconta,
             pr_tab_cheques_altovale(vr_indice).nrdctabb,
             pr_tab_cheques_altovale(vr_indice).nrdctitg,
             vr_nrdocmto,
             pr_tab_cheques_altovale(vr_indice).cdhistor,
             pr_tab_cheques_altovale(vr_indice).vllanmto,
             rw_craplot.nrseqdig + 1,
             pr_tab_cheques_altovale(vr_indice).cdcooper,
             pr_tab_cheques_altovale(vr_indice).cdbanchq,
             pr_tab_cheques_altovale(vr_indice).cdagechq,
             pr_tab_cheques_altovale(vr_indice).nrctachq,
             'LANCAMENTO DE CONTA MIGRADA');
        EXCEPTION
          WHEN OTHERS THEN
            --Monta mensagem de erro
            vr_dscritic := 'Erro ao inserir dados na tabela craplcm na rotina pc_processamento_tco. ' || SQLERRM;
            --Gera RAISE
            RAISE vr_exc_erro;
        END;
        --Atualiza os dados do lote
        BEGIN
          UPDATE craplot
             SET craplot.qtinfoln = craplot.qtinfoln + 1,
                 craplot.qtcompln = craplot.qtcompln + 1,
                 craplot.vlinfodb = craplot.vlinfodb + pr_tab_cheques_altovale(vr_indice).vllanmto,
                 craplot.vlcompdb = craplot.vlcompdb + pr_tab_cheques_altovale(vr_indice).vllanmto,
                 craplot.nrseqdig = craplot.nrseqdig + 1
           WHERE ROWID = rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            --Monta mensagem de erro
            vr_dscritic := 'Erro ao atualizar dados na tabela craplot na rotina pc_processamento_tco. ' || SQLERRM;
            --Gera excecao
            RAISE vr_exc_erro;
        END;
        -- indo para o proximo registro da tabela
        vr_indice := pr_tab_cheques_altovale.NEXT(vr_indice);
      END LOOP;
      --Retorna OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        -- Gerar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => nvl(rw_craplot.cdagenci, 0),
                              pr_nrdcaixa => nvl(rw_craplot.cdbccxlt, 0),
                              pr_nrsequen => 1, --> Fixo
                              pr_cdcritic => NVL(vr_cdcritic, 0),
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      WHEN vr_exc_log THEN

        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        -- Gera log do erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratado
                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') || ' - ' || pr_cdprogra || ' --> ' || vr_dscritic || ' Lote: ' || vr_nrlotetc);
      WHEN OTHERS THEN
        vr_dscritic := 'pc_proc_rejeitados --> Erro não tratado ao processar pc_processamento_tco: ' || sqlerrm;
        -- Gerar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => nvl(rw_craplot.cdagenci, 0),
                              pr_nrdcaixa => nvl(rw_craplot.cdbccxlt, 0),
                              pr_nrsequen => 1, --> Fixo
                              pr_cdcritic => NVL(vr_cdcritic, 0),
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
    END;

    -- Procedimento para tratamento de descontos.
    PROCEDURE pc_proc_trata_desconto(pr_cdcooper      IN number,   -- Codigo Cooperativa
                                     pr_cdagenci      IN number,   -- Codigo Agencia
                                     pr_nrdcaixa      IN number,   -- Numero do Caixa
                                     pr_nrdconta      IN number,   -- Numero da Conta
                                     pr_dtmvtolt      IN DATE,     -- Data do Movimento
                                     pr_dtmvtopr      IN DATE,     -- Data de movimento do programa
                                     pr_cdseqtel      IN VARCHAR2, -- Codigo sequencial do arquivo
                                     pr_vllanaut      IN number,   -- Valor do lancamento automatico
                                     pr_cdbccxlt      IN number,   -- Banco caixa
                                     pr_nrdolote      IN number,   -- Numero do Lote
                                     pr_cdhistor      IN number,   -- Historico
                                     pr_nrdctabb      IN number,   -- Numero da conta base no Banco do Brasil
                                     pr_nrdocmto      IN number,   -- Numero do documento
                                     pr_nrseqdig      IN number,   -- Seuqencia de digitacao
                                     pr_nrdctitg      IN varchar2, -- Conta integracao
                                     pr_craplau_rowid in rowid,
                                     pr_tab_cheques_altovale in out typ_tab_cheques_altovale,
                                     pr_des_reto      OUT VARCHAR, --> Retorno OK / NOK
                                     pr_tab_erro      OUT gene0001.typ_tab_erro) IS --> Tabela com erros)
                                     
      --Cursor para buscar Cheques contidos do Bordero de desconto de cheques
      CURSOR cr_crapcdb(pr_dtmvtolt crapcdb.dtmvtolt%TYPE,
                        pr_cdagenci crapcdb.cdagenci%TYPE,
                        pr_cdbccxlt crapcdb.cdbccxlt%TYPE,
                        pr_nrdolote crapcdb.nrdolote%TYPE,
                        pr_cdcmpchq crapcdb.cdcmpchq%TYPE,
                        pr_cdbanchq crapcdb.cdbanchq%TYPE,
                        pr_cdagechq crapcdb.cdagechq%TYPE,
                        pr_nrctachq crapcdb.nrctachq%TYPE,
                        pr_nrcheque crapcdb.nrcheque%TYPE) IS
        SELECT ROWID,
               cdb.dtlibbdc,
               cdb.nrdconta,
               cdb.cdbanchq,
               cdb.cdagechq,
               cdb.nrctachq,
               cdb.nrcheque
          FROM crapcdb cdb
         WHERE cdb.cdcooper = pr_cdcooper
           AND cdb.dtmvtolt = pr_dtmvtolt
           AND cdb.cdagenci = pr_cdagenci
           AND cdb.cdbccxlt = pr_cdbccxlt
           AND cdb.nrdolote = pr_nrdolote
           AND cdb.cdcmpchq = pr_cdcmpchq
           AND cdb.cdbanchq = pr_cdbanchq
           AND cdb.cdagechq = pr_cdagechq
           AND cdb.nrctachq = pr_nrctachq
           AND cdb.nrcheque = pr_nrcheque;
      rw_crapcdb cr_crapcdb%ROWTYPE;
      --Cursor para buscar o lote
      CURSOR cr_craplot(pr_cdcooper craplot.cdcooper%TYPE,
                        pr_dtmvtolt craplot.dtmvtolt%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_cdbccxlt craplot.cdbccxlt%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT ROWID,
               lot.cdcooper,
               lot.cdagenci,
               lot.cdbccxlt,
               lot.nrdolote,
               lot.dtmvtolt,
               lot.nrseqdig
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;
      --Cursor para encontrar as folhas de cheques
      CURSOR cr_crapfdc(pr_cdcooper crapfdc.cdcooper%TYPE,
                        pr_cdbanchq crapfdc.cdbanchq%TYPE,
                        pr_cdagechq crapfdc.cdagechq%TYPE,
                        pr_nrctachq crapfdc.nrctachq%TYPE,
                        pr_nrcheque crapfdc.nrcheque%TYPE) IS
        SELECT ROWID,
               fdc.nrdconta,
               fdc.incheque,
               fdc.tpcheque,
               fdc.vlcheque,
               fdc.dtemschq,
               fdc.dtretchq,
               fdc.cdbanchq,
               fdc.cdagechq,
               fdc.nrctachq,
               fdc.dtliqchq
          FROM crapfdc fdc
         WHERE fdc.cdcooper = pr_cdcooper
           AND fdc.cdbanchq = pr_cdbanchq
           AND fdc.cdagechq = pr_cdagechq
           AND fdc.nrctachq = pr_nrctachq
           AND fdc.nrcheque = pr_nrcheque;
      rw_crapfdc cr_crapfdc%ROWTYPE;
      --Cursor para buscar conta migrada
      CURSOR cr_craptco_ant(pr_cdcopant in craptco.cdcopant%type,
                            pr_nrctaant in craptco.nrctaant%TYPE) IS
        SELECT tco.cdcooper,
               tco.nrdconta,
               tco.nrctaant,
               tco.cdcopant
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcopant
           AND tco.nrctaant = pr_nrctaant
           AND tco.tpctatrf = 1 -- 1 = Conta/Corrente
           AND tco.flgativo = 1; -- Ativo
      rw_craptco_ant  cr_craptco_ant%ROWTYPE;
      --Cursor para buscar lancamentos
      CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE,
                        pr_dtmvtolt IN craplcm.dtmvtolt%TYPE,
                        pr_cdagenci IN craplcm.cdagenci%TYPE,
                        pr_cdbccxlt IN craplcm.cdbccxlt%TYPE,
                        pr_nrdolote IN craplcm.nrdolote%TYPE,
                        pr_nrdctabb IN craplcm.nrdctabb%TYPE,
                        pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
        SELECT lcm.cdcooper,
               lcm.nrseqdig
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdagenci = pr_cdagenci
           AND lcm.cdbccxlt = pr_cdbccxlt
           AND lcm.nrdolote = pr_nrdolote
           AND lcm.nrdctabb = pr_nrdctabb
           AND lcm.nrdocmto = pr_nrdocmto;
      rw_craplcm cr_craplcm%ROWTYPE;
      --
      vr_dtmvtolt             DATE;
      vr_cdagenci             INTEGER := 0;
      vr_cdbccxlt             INTEGER := 0;
      vr_nrdolote             INTEGER := 0;
      vr_cdcmpchq             INTEGER := 0;
      vr_cdbanchq             INTEGER := 0;
      vr_cdagechq             INTEGER := 0;
      vr_nrctachq             INTEGER := 0;
      vr_nrcheque             INTEGER := 0;
      vr_nrcustod             crapcdb.nrdconta%TYPE := 0;
      vr_flgentra             BOOLEAN := FALSE;
      --Variavel para guardar o codigo do erro
      vr_cdcritic INTEGER := 0;
      --Variavel para guardar a descricao do erro
      vr_dscritic VARCHAR2(4000) := '';
      --Variavel de indica para utilizar na leitura da tabela de cheques
      vr_idcheque VARCHAR2(100) := '';
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;
      -- Cooperativa anterior
      vr_cdcopant             craptco.cdcopant%type;
    BEGIN
      -- Limpar a tabela de erro
      pr_tab_erro.DELETE;
      -- armazena a cooperativa anterior no caso de verificar a tco
      if pr_cdcooper = 1 then
        vr_cdcopant := 2;
      elsif pr_cdcooper = 16 then
        vr_cdcopant := 1;
      end if;
      --
      IF TO_NUMBER(SUBSTR(pr_cdseqtel, 16, 3)) = 600 THEN
        --Data de movimento do lancamento
        vr_dtmvtolt := pr_dtmvtolt;
        --Agencia do lancamento
        vr_cdagenci := pr_cdagenci;
        --Banco e caixa do lancamento
        vr_cdbccxlt := pr_cdbccxlt;
        --Numero do lote
        vr_nrdolote := pr_nrdolote;
      ELSE
        --Data de movimento do lancamento
        vr_dtmvtolt := TO_DATE(SUBSTR(pr_cdseqtel, 1, 10), 'dd/mm/yyyy');
        --Agencia do lancamento
        vr_cdagenci := TO_NUMBER(SUBSTR(pr_cdseqtel, 12, 3));
        --Banco e caixa do lancamento
        vr_cdbccxlt := TO_NUMBER(SUBSTR(pr_cdseqtel, 16, 3));
        --Numero do lote
        vr_nrdolote := TO_NUMBER(SUBSTR(pr_cdseqtel, 20, 6));
      END IF;
      --Codigo de compensacao do cheque
      vr_cdcmpchq := TO_NUMBER(SUBSTR(pr_cdseqtel, 27, 3));
      --Codigo do banco do cheque
      vr_cdbanchq := TO_NUMBER(SUBSTR(pr_cdseqtel, 31, 3));
      --Codigo da agencia do cheque
      vr_cdagechq := TO_NUMBER(SUBSTR(pr_cdseqtel, 35, 4));
      --Conta do cheque
      vr_nrctachq := TO_NUMBER(SUBSTR(pr_cdseqtel, 40, 8));
      --Numero do cheque
      vr_nrcheque := TO_NUMBER(SUBSTR(pr_cdseqtel, 49, 6));
      --Busca cheques contidos do Bordero de desconto de cheques
      OPEN cr_crapcdb(pr_dtmvtolt => vr_dtmvtolt,
                      pr_cdagenci => vr_cdagenci,
                      pr_cdbccxlt => vr_cdbccxlt,
                      pr_nrdolote => vr_nrdolote,
                      pr_cdcmpchq => vr_cdcmpchq,
                      pr_cdbanchq => vr_cdbanchq,
                      pr_cdagechq => vr_cdagechq,
                      pr_nrctachq => vr_nrctachq,
                      pr_nrcheque => vr_nrcheque);
        FETCH cr_crapcdb INTO rw_crapcdb;
        -- Se não encontrar
        IF cr_crapcdb%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapcdb;
          vr_nrcustod := 0;
          --Atualiza o registro de lancamento automatico
          BEGIN
            UPDATE craplau lau
               SET lau.insitlau = 3
             WHERE lau.rowid = pr_craplau_rowid;
          EXCEPTION
            WHEN OTHERS THEN
              --Monta mensagem de erro
              vr_dscritic := 'Erro ao atualizar a tabela de Lancamentos automaticos (CRAPLAU) - Conta: ' || pr_nrdconta || '. Detalhes: ' || sqlerrm;
              --Gera excecao
              RAISE vr_exc_erro;
          END;
          --Chamada a procedure pc_proc_rejeitados passando o erro 680
          pc_proc_rejeitados(pr_cdcooper => pr_cdcooper,
                             pr_cdagenci => pr_cdagenci,
                             pr_nrdcaixa => pr_nrdcaixa,
                             pr_nrdconta => pr_nrdconta,
                             pr_dtmvtopr => pr_dtmvtopr,
                             pr_nrcustod => vr_nrcustod,
                             pr_cdseqtel => pr_cdseqtel,
                             pr_vllanaut => pr_vllanaut,
                             pr_cdhistor => pr_cdhistor,
                             pr_nrdctabb => pr_nrdctabb,
                             pr_nrdocmto => pr_nrdocmto,
                             pr_nrseqdig => pr_nrseqdig,
                             pr_cdcritic => 680, --ERRO DE SISTEMA! Nao foi encontrado o CRAPCST/CRAPCDB.
                             pr_des_reto => pr_des_reto,
                             pr_tab_erro => pr_tab_erro);
          -- Se retornar erro
          IF pr_des_reto <> 'OK' THEN
            IF pr_tab_erro.COUNT > 0 THEN
              -- Montar mensagem de erro
              vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            ELSE
              -- Por algum motivo retornou erro mais a tabela veio vazia
              vr_dscritic := 'Tab.Erro vazia - não é possível retornar o erro da chamada pc_proc_rejeitados';
            END IF;
            --Gera excecao
            RAISE vr_exc_erro;
          END IF;
          --Retorna OK
          pr_des_reto := 'OK';
          RETURN;
        end if;
      -- Apenas fechar o cursor
      CLOSE cr_crapcdb;
      --Se o bordero nao tiver data de liberacao para credito em conta.
      IF rw_crapcdb.dtlibbdc IS NULL THEN
        --Armzena numero da conta
        vr_nrcustod := rw_crapcdb.nrdconta;
        --Atualiza registro de lancamento automatico
        BEGIN
          UPDATE craplau lau
             SET lau.insitlau = 3
           WHERE lau.rowid = pr_craplau_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            --Monta mensagem de erro
            vr_dscritic := 'Erro ao atualizar a tabela de Lancamentos automaticos (CRAPLAU) - Conta: ' || pr_nrdconta || '. Detalhes: ' || sqlerrm;
            --Gera excecao
            RAISE vr_exc_erro;
        END;
        pc_proc_rejeitados(pr_cdcooper => pr_cdcooper,
                           pr_cdagenci => pr_cdagenci,
                           pr_nrdcaixa => pr_nrdcaixa,
                           pr_nrdconta => pr_nrdconta,
                           pr_dtmvtopr => pr_dtmvtopr,
                           pr_nrcustod => vr_nrcustod,
                           pr_cdseqtel => pr_cdseqtel,
                           pr_vllanaut => pr_vllanaut,
                           pr_cdhistor => pr_cdhistor,
                           pr_nrdctabb => pr_nrdctabb,
                           pr_nrdocmto => pr_nrdocmto,
                           pr_nrseqdig => pr_nrseqdig,
                           pr_cdcritic => 777, --Bordero NAO liberado.
                           pr_des_reto => pr_des_reto,
                           pr_tab_erro => pr_tab_erro);
        -- Se retornar erro
        IF pr_des_reto <> 'OK' THEN
          IF pr_tab_erro.COUNT > 0 THEN
            -- Montar mensagem de erro
            vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            -- Por algum motivo retornou erro mais a tabela veio vazia
            vr_dscritic := 'Tab.Erro vazia - não é possível retornar o erro da chamada pc_proc_rejeitados';
          END IF;
          --Gera excecao
          RAISE vr_exc_erro;
        END IF;
        --
        RETURN;
      END IF;
      --Armazena numero da conta
      vr_nrcustod := rw_crapcdb.nrdconta;
      --Busca lote
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                      pr_dtmvtolt => pr_dtmvtopr,
                      pr_cdagenci => 1,
                      pr_cdbccxlt => 100,
                      pr_nrdolote => 4501);
      FETCH cr_craplot INTO rw_craplot;
      IF cr_craplot%NOTFOUND THEN
        -- fechando o cursor
        CLOSE cr_craplot;
        --Cria lote
        BEGIN
          INSERT INTO craplot
            (craplot.dtmvtolt,
             craplot.cdagenci,
             craplot.cdbccxlt,
             craplot.nrdolote,
             craplot.tplotmov,
             craplot.cdcooper)
          VALUES
            (pr_dtmvtopr,
             1,
             100,
             4501,
             1,
             pr_cdcooper)
          RETURNING craplot.ROWID,
                    craplot.dtmvtolt,
                    craplot.cdagenci,
                    craplot.cdbccxlt,
                    craplot.nrdolote,
                    craplot.nrseqdig
               INTO rw_craplot.rowid,
                    rw_craplot.dtmvtolt,
                    rw_craplot.cdagenci,
                    rw_craplot.cdbccxlt,
                    rw_craplot.nrdolote,
                    rw_craplot.nrseqdig;
        EXCEPTION
          WHEN OTHERS THEN
            --Monta mensagem de erro
            vr_dscritic := 'Erro ao inserir dados na tabela craplot na rotina pr_proc_trata_desconto. ' || SQLERRM;
            -- retorna a critica para o programa que chamou a rotina
            RETURN;
        END;
      else
        -- fechando o cursor
        CLOSE cr_craplot;
      end if;
      --
      vr_cdcritic := 0;
      vr_flgentra := true;
      --
      IF pr_cdhistor = 521 OR
         pr_cdhistor = 526 THEN
        rw_craptco_ant := null;
        -- Busca cheque na cooperativa atual
        OPEN cr_crapfdc(pr_cdcooper => pr_cdcooper,
                        pr_cdbanchq => rw_crapcdb.cdbanchq,
                        pr_cdagechq => rw_crapcdb.cdagechq,
                        pr_nrctachq => rw_crapcdb.nrctachq,
                        pr_nrcheque => rw_crapcdb.nrcheque);
          FETCH cr_crapfdc INTO rw_crapfdc;
          IF cr_crapfdc%NOTFOUND THEN
            --Fecha o cursor
            CLOSE cr_crapfdc;
            -- Verifica se a conta do cheque eh conta migrada
            OPEN cr_craptco_ant(pr_cdcopant => vr_cdcopant,
                                pr_nrctaant => rw_crapcdb.nrctachq);
            FETCH cr_craptco_ant
              INTO rw_craptco_ant;
            IF cr_craptco_ant%FOUND THEN
              -- Busca o cheque na cooperativa antiga
              OPEN cr_crapfdc(pr_cdcooper => rw_craptco_ant.cdcopant,
                              pr_cdbanchq => rw_crapcdb.cdbanchq,
                              pr_cdagechq => rw_crapcdb.cdagechq,
                              pr_nrctachq => rw_craptco_ant.nrctaant,
                              pr_nrcheque => rw_crapcdb.nrcheque);
              FETCH cr_crapfdc INTO rw_crapfdc;
            END IF;
          END IF;
          --
          IF cr_crapfdc%FOUND THEN
            IF rw_crapfdc.nrdconta = 0 THEN
              vr_cdcritic := 286; --Cheque salario nao existe.
            ELSIF rw_crapfdc.incheque IN ('5', '6', '7') THEN
              vr_cdcritic := 97; --Cheque ja entrou.
            ELSIF rw_crapfdc.incheque = 1 THEN
              vr_cdcritic := 96; --Cheque com contra-ordem.
            ELSIF rw_crapfdc.incheque = 8 THEN
              vr_cdcritic := 320; --Cheque cancelado.
            ELSIF rw_crapfdc.tpcheque = 3 AND --Cheque salario
                  rw_crapfdc.vlcheque <> pr_vllanaut THEN
              vr_cdcritic := 269; --Valor errado.
            ELSIF rw_crapfdc.dtemschq IS NULL THEN
              vr_cdcritic := 108; --Talonario nao emitido.
            ELSIF rw_crapfdc.tpcheque = 2 THEN
              vr_cdcritic := 646; --Cheque de transferencia.
            ELSIF rw_crapfdc.dtretchq IS NULL THEN
              vr_cdcritic := 109; --Talonario nao retirado.
            END IF;
          ELSE
            vr_cdcritic := 286; --Cheque salario nao existe.
          END IF;
        close cr_crapfdc;
      ELSE
        vr_cdcritic := 245; --Historico nao processado.
      END IF;
      IF vr_cdcritic = 0 THEN
        --Busca lancamento
        OPEN cr_craplcm(pr_cdcooper => pr_cdcooper,
                        pr_dtmvtolt => pr_dtmvtopr,
                        pr_cdagenci => rw_craplot.cdagenci,
                        pr_cdbccxlt => rw_craplot.cdbccxlt,
                        pr_nrdolote => rw_craplot.nrdolote,
                        pr_nrdctabb => pr_nrdctabb,
                        pr_nrdocmto => pr_nrdocmto);
          FETCH cr_craplcm INTO rw_craplcm;
          IF cr_craplcm%FOUND THEN
            --Fechar o cursor
            CLOSE cr_craplcm;
            vr_cdcritic := 92;
          ELSIF pr_cdhistor = 526 AND
               rw_crapfdc.incheque = 2 THEN
            vr_cdcritic := 287; --Cheque salario com alerta!!!
          ELSIF pr_cdhistor = 521 THEN
            IF rw_crapfdc.incheque = 2 THEN
              vr_cdcritic := 257; --Cheque com alerta.
            ELSIF rw_crapfdc.incheque = 1 THEN
              vr_cdcritic := 96; --Cheque com contra-ordem.
            END IF;
          END IF;
        close cr_craplcm;
      END IF;
      --
      IF vr_cdcritic > 0 THEN
        pc_proc_rejeitados(pr_cdcooper => pr_cdcooper,
                           pr_cdagenci => pr_cdagenci,
                           pr_nrdcaixa => pr_nrdcaixa,
                           pr_nrdconta => pr_nrdconta,
                           pr_dtmvtopr => pr_dtmvtopr,
                           pr_nrcustod => vr_nrcustod,
                           pr_cdseqtel => pr_cdseqtel,
                           pr_vllanaut => pr_vllanaut,
                           pr_cdhistor => pr_cdhistor,
                           pr_nrdctabb => pr_nrdctabb,
                           pr_nrdocmto => pr_nrdocmto,
                           pr_nrseqdig => pr_nrseqdig,
                           pr_cdcritic => vr_cdcritic,
                           pr_des_reto => pr_des_reto,
                           pr_tab_erro => pr_tab_erro);
        -- Se retornar erro
        IF pr_des_reto <> 'OK' THEN
          IF pr_tab_erro.COUNT > 0 THEN
            -- Montar mensagem de erro
            vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            -- Por algum motivo retornou erro mais a tabela veio vazia
            vr_dscritic := 'Tab.Erro vazia - não é possível retornar o erro da chamada pc_proc_rejeitados';
          END IF;
          --Gera excecao
          RAISE vr_exc_erro;
        END IF;
        IF vr_cdcritic IN ('257', '287') THEN
          vr_cdcritic := 0;
          vr_flgentra := TRUE;
        ELSE
          vr_cdcritic := 0;
          vr_flgentra := FALSE;
        END IF;
      END IF;
      IF vr_flgentra THEN
        --Verifica se eh conta migrada
        IF nvl(rw_craptco_ant.cdcooper, 0) > 0 THEN
          IF pr_cdcooper = 1 AND
             rw_crapcdb.nrdconta = 85448 THEN
            --Atualiza o registro de lancamento automatico
            BEGIN
              UPDATE craplau lau
                 SET lau.dtdebito = rw_craplot.dtmvtolt,
                     lau.insitlau = 3
               WHERE ROWID = pr_craplau_rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerando a critica
                vr_dscritic := 'Erro ao atualizar a tabela craplau na rotina pc_proc_trata_desconto. ' || SQLERRM;
                -- gerando excecao
                RAISE vr_exc_erro;
            END;
            --Atualiza o registro de Cheques contidos do Bordero de desconto de cheques
            BEGIN
              UPDATE crapcdb cdb
                 SET cdb.insitchq = 4
               WHERE ROWID = rw_crapcdb.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerando a critica
                vr_dscritic := 'Erro ao atualizar a tabela crapcdb na rotina pc_proc_trata_desconto. ' || SQLERRM;
                -- gerando excecao
                RAISE vr_exc_erro;
            END;
          ELSE
            -- debita da conta nova
            vr_idcheque := LPad(rw_craptco_ant.nrdconta, 9, '0') || LPAD(pr_nrdocmto, 10, '0');
            pr_tab_cheques_altovale(vr_idcheque).cdcooper := rw_craptco_ant.cdcooper;
            pr_tab_cheques_altovale(vr_idcheque).nrdconta := rw_craptco_ant.nrdconta;
            pr_tab_cheques_altovale(vr_idcheque).nrdctabb := pr_nrdctabb;
            pr_tab_cheques_altovale(vr_idcheque).nrdctitg := pr_nrdctitg;
            pr_tab_cheques_altovale(vr_idcheque).nrdocmto := pr_nrdocmto; -- rw_craplau.nrdocmto;
            pr_tab_cheques_altovale(vr_idcheque).cdhistor := pr_cdhistor;
            pr_tab_cheques_altovale(vr_idcheque).vllanmto := pr_vllanaut;
            pr_tab_cheques_altovale(vr_idcheque).cdbanchq := rw_crapfdc.cdbanchq;
            pr_tab_cheques_altovale(vr_idcheque).cdagechq := rw_crapfdc.cdagechq;
            pr_tab_cheques_altovale(vr_idcheque).nrctachq := rw_crapfdc.nrctachq;
            BEGIN
              UPDATE craplau lau
                 SET lau.dtdebito = rw_craplot.dtmvtolt,
                     lau.insitlau = 2
               WHERE ROWID = pr_craplau_rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerando a critica
                vr_dscritic := 'Erro ao atualizar a tabela craplau na rotina pc_proc_trata_desconto. ' || SQLERRM;
                -- gerando excecao
                RAISE vr_exc_erro;
            END;
            BEGIN
              UPDATE crapcdb cdb
                 SET cdb.insitchq = 4
               WHERE ROWID = rw_crapcdb.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerando a critica
                vr_dscritic := 'Erro ao atualizar a tabela crapcdb na rotina pc_proc_trata_desconto. ' || SQLERRM;
                -- gerando excecao
                RAISE vr_exc_erro;
            END;
            IF pr_cdhistor = 526 THEN
              BEGIN
                UPDATE crapfdc fdc
                   SET fdc.incheque = fdc.incheque + 5,
                       fdc.dtliqchq = pr_dtmvtolt,
                       fdc.vlcheque = pr_vllanaut
                 WHERE ROWID = rw_crapfdc.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Gerando a critica
                  vr_dscritic := 'Erro ao atualizar a tabela crapfdc na rotina pc_proc_trata_desconto. ' || SQLERRM;
                  -- gerando excecao
                  RAISE vr_exc_erro;
              END;
            ELSE
              IF pr_cdhistor = 521 THEN
                BEGIN
                  UPDATE crapfdc fdc
                     SET fdc.incheque = fdc.incheque + 5,
                         fdc.dtliqchq = pr_dtmvtopr,
                         fdc.vlcheque = pr_vllanaut
                   WHERE ROWID = rw_crapfdc.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Gerando a critica
                    vr_dscritic := 'Erro ao atualizar a tabela crapfdc na rotina pc_proc_trata_desconto. ' || SQLERRM;
                    -- gerando excecao
                    RAISE vr_exc_erro;
                END;
              END IF;
            END IF;
          END IF;
        ELSE
          --cria craplcm
          BEGIN
            INSERT INTO craplcm
              (craplcm.dtmvtolt,
               craplcm.dtrefere,
               craplcm.cdagenci,
               craplcm.cdbccxlt,
               craplcm.nrdolote,
               craplcm.nrdconta,
               craplcm.nrdctabb,
               craplcm.nrdctitg,
               craplcm.nrdocmto,
               craplcm.cdhistor,
               craplcm.vllanmto,
               craplcm.nrseqdig,
               craplcm.cdcooper,
               craplcm.cdbanchq,
               craplcm.cdagechq,
               craplcm.nrctachq,
               craplcm.cdpesqbb)
            VALUES
              (rw_craplot.dtmvtolt,
               rw_craplot.dtmvtolt,
               rw_craplot.cdagenci,
               rw_craplot.cdbccxlt,
               rw_craplot.nrdolote,
               pr_nrdconta,
               pr_nrdctabb,
               pr_nrdctitg,
               pr_nrdocmto,
               pr_cdhistor,
               pr_vllanaut,
               (rw_craplot.nrseqdig + 1),
               pr_cdcooper,
               rw_crapfdc.cdbanchq,
               rw_crapfdc.cdagechq,
               rw_crapfdc.nrctachq,
               to_char(pr_dtmvtolt, 'dd/mm/yyyy') ||'-'||
               gene0002.fn_mask(pr_cdagenci, '999') || '-'||
               gene0002.fn_mask(pr_cdbccxlt, '999') ||'-'||
               gene0002.fn_mask(pr_nrdolote, '999999') || '-'||
               gene0002.fn_mask(pr_nrseqdig, '99999'))
            RETURNING craplcm.nrseqdig INTO rw_craplcm.nrseqdig;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir dados na tabela craplcm na rotina pc_proc_trata_descontos. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          BEGIN
            UPDATE craplot lot
               SET lot.qtinfoln = lot.qtinfoln + 1,
                   lot.qtcompln = lot.qtcompln + 1,
                   lot.vlinfodb = lot.vlinfodb + pr_vllanaut,
                   lot.vlcompdb = lot.vlcompdb + pr_vllanaut,
                   lot.nrseqdig = rw_craplcm.nrseqdig
             WHERE ROWID = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar dados na tabela craplot na rotina pc_proc_trata_descontos. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          BEGIN
            UPDATE craplau lau
               SET lau.dtdebito = rw_craplot.dtmvtolt,
                   lau.insitlau = 2
             WHERE ROWID = pr_craplau_rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar dados na tabela craplau na rotina pc_proc_trata_descontos. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          BEGIN
            UPDATE crapcdb cdb
               SET cdb.insitchq = 4
             WHERE ROWID = rw_crapcdb.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar dados na tabela crapcdb na rotina pc_proc_trata_descontos. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          IF pr_cdhistor = 526 THEN
            BEGIN
              UPDATE crapfdc fdc
                 SET fdc.incheque = fdc.incheque + 5,
                     fdc.dtliqchq = pr_dtmvtolt,
                     fdc.vlcheque = pr_vllanaut
               WHERE ROWID = rw_crapfdc.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir dados na tabela craplcm na rotina pc_proc_trata_descontos. ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
          ELSE
            IF pr_cdhistor = 521 THEN
              BEGIN
                UPDATE crapfdc fdc
                   SET fdc.incheque = fdc.incheque + 5,
                       fdc.dtliqchq = pr_dtmvtopr,
                       fdc.vlcheque = pr_vllanaut
                 WHERE ROWID = rw_crapfdc.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir dados na tabela craplcm na rotina pc_proc_trata_descontos. ' || SQLERRM;
                  RAISE vr_exc_erro;
              END;
            END IF;
          END IF;
        END IF;
      ELSE
        BEGIN
          UPDATE craplau lau
             SET lau.insitlau = 3,
                 lau.dtdebito = rw_craplot.dtmvtolt
           WHERE ROWID = pr_craplau_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar dados na tabela craplau na rotina pc_proc_trata_descontos. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        BEGIN
          UPDATE crapcdb cdb
             SET cdb.insitchq = 3
           WHERE ROWID = rw_crapcdb.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar dados na tabela crapcdb na rotina pc_proc_trata_descontos. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;
      --
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1, --> Fixo
                              pr_cdcritic => NVL(vr_cdcritic, 0),
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
      WHEN OTHERS THEN
        
        cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper,
                                     pr_compleme => 'Conta:' || pr_nrdconta);
      
        vr_dscritic := 'pc_proc_trata_desconto --> Erro não tratado ao processar tratamento de desconto de cheques:' || 'Conta:' || pr_nrdconta ||
                       '.Detalhes:' || sqlerrm;
        pr_des_reto := 'NOK';
        -- Gerar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1, --> Fixo
                              pr_cdcritic => NVL(vr_cdcritic, 0),
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);
    END;

  BEGIN
    -- Limpar a tabela de erro
    vr_tab_erro.DELETE;
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
      INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    IF vr_cdcritic <> 0 THEN
      -- Buscar descrição da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
    -- Verificacao do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
    --Busca os lancamentos automaticos
    FOR rw_craplau IN cr_craplau LOOP
      vr_nrdconta := rw_craplau.nrdconta; -- Conta Cheque
      vr_cdcritic := 0;
      LOOP
        --Busca o associado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => vr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        -- Se nao encontrar
        IF cr_crapass%NOTFOUND THEN
          --Critica
          vr_cdcritic := 251;
        ELSIF NOT rw_crapass.dtelimin IS NULL THEN  --Se associado jah foi eliminado
          -- Montar mensagem de critica
          vr_cdcritic := 410;
        ELSIF rw_crapass.cdsitdtl IN (5, 6, 7, 8) THEN
          -- Montar mensagem de critica
          vr_cdcritic := 695;
        ELSIF rw_crapass.cdsitdtl IN (2, 4) THEN
          --Busca transaferencia ou duplicacao de matricula da conta cem questao
          OPEN cr_craptrf(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => vr_nrdconta);
          -- Se nao encontrar
          IF cr_craptrf%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craptrf;
            -- Montar mensagem de critica
            vr_cdcritic := 95;
          ELSE
            -- Fechar o cursor
            CLOSE cr_craptrf;
            CONTINUE;
          END IF;
        END IF;
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
        EXIT;
      END LOOP;
      --
      IF vr_cdcritic > 0 THEN
        --Monta a mesagem da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratado
                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic || ' CONTA = ' || gene0002.fn_mask_conta(vr_nrdconta));
      --  IF vr_cdcritic = 251 OR
      --     vr_cdcritic = 95 THEN
        vr_cdcritic := 0;
        CONTINUE;
      --  END IF;
      --  RAISE vr_exc_saida;
      END IF;
      -- Tratamento dos descontos de lançamentos automáticos
      pc_proc_trata_desconto(pr_cdcooper             => pr_cdcooper,
                             pr_cdagenci             => rw_craplau.cdagenci,
                             pr_nrdcaixa             => 0,
                             pr_nrdconta             => rw_craplau.nrdconta,
                             pr_dtmvtolt             => rw_craplau.dtmvtolt,
                             pr_dtmvtopr             => rw_crapdat.dtmvtopr,
                             pr_cdseqtel             => rw_craplau.cdseqtel,
                             pr_vllanaut             => rw_craplau.vllanaut,
                             pr_cdbccxlt             => rw_craplau.cdbccxlt,
                             pr_nrdolote             => rw_craplau.nrdolote,
                             pr_cdhistor             => rw_craplau.cdhistor,
                             pr_nrdctabb             => rw_craplau.nrdctabb,
                             pr_nrdocmto             => rw_craplau.nrdocmto,
                             pr_nrseqdig             => rw_craplau.nrseqdig,
                             pr_nrdctitg             => rw_craplau.nrdctitg,
                             pr_craplau_rowid        => rw_craplau.rowid,
                             pr_tab_cheques_altovale => vr_tab_cheques_altovale,
                             pr_des_reto             => vr_des_reto,
                             pr_tab_erro             => vr_tab_erro);
      -- Se retornar erro
      IF vr_des_reto <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Montar erro
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          -- Por algum motivo retornou erro mais a tabela veio vazia
          vr_dscritic := 'Tab.Erro vazia - não é possível retornar o erro da chamada proc_trata_desconto';
        END IF;
        IF vr_cdcritic > 0 AND
           vr_cdcritic <> 777 THEN
          --Monta mensagem de critica
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        end if;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratado
                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic || ' CONTA = ' || gene0002.fn_mask_conta(vr_nrdconta));
        
        vr_cdcritic := 0;
        vr_dscritic := '';
        CONTINUE; -- Próximo craplau
      END IF;
    END LOOP;
    -- Tratamento de cheques de contas migradas
    if vr_tab_cheques_altovale.first is not null then
      pc_processamento_tco(pr_cdcooper             => pr_cdcooper,
                           pr_dtmvtopr             => rw_crapdat.dtmvtopr,
                           pr_tab_cheques_altovale => vr_tab_cheques_altovale,
                           pr_cdprogra             => vr_cdprogra,
                           pr_des_reto             => vr_des_reto,
                           pr_tab_erro             => vr_tab_erro);
    end if;
    --Inicializa o CLOB
    dbms_lob.createtemporary(vr_dsxmldad,
                             TRUE);
    dbms_lob.OPEN(vr_dsxmldad,
                  dbms_lob.lob_readwrite);
    -- Leitura da capa de lote 4501 para geração do XML
    FOR rw_craplot IN (SELECT lot.cdcooper,
                              lot.qtinfoln,
                              lot.vlinfodb,
                              lot.vlinfocr,
                              lot.qtcompln,
                              lot.vlcompdb,
                              lot.vlcompcr,
                              lot.cdagenci,
                              lot.dtmvtolt,
                              lot.nrdolote,
                              lot.tplotmov,
                              lot.cdbccxlt,
                              lot.dtmvtopg
                         FROM craplot lot
                        WHERE lot.cdcooper = pr_cdcooper
                          AND lot.dtmvtolt = rw_crapdat.dtmvtopr
                          AND lot.nrdolote = 4501) LOOP
      vr_qtdifeln := rw_craplot.qtcompln - rw_craplot.qtinfoln;
      vr_vldifedb := rw_craplot.vlcompdb - rw_craplot.vlinfodb;
      vr_vldifecr := rw_craplot.vlcompcr - rw_craplot.vlinfocr;
      --Inicia o xml
      pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?>' ||
                      '<crrl287>' ||
                         '<tipo>TIPO: CHEQUES DESCONTADOS</tipo>' ||
                         '<mensagem>' ||
                           'DATA: ' || to_char(rw_craplot.dtmvtolt, 'dd/mm/yyyy') ||
                           ' AGENCIA: ' || lpad(rw_craplot.cdagenci, 3, ' ') ||
                           '   BANCO/CAIXA: ' || rpad(rw_craplot.cdbccxlt, 5, ' ') ||
                           ' LOTE: ' || lpad(to_char(rw_craplot.nrdolote, 'FM999G999G999'), 7, ' ') ||
                           ' TIPO: ' || lpad(rw_craplot.tplotmov, 1, '0') ||
                         '</mensagem>'||
                         '<dtmvtopg>'||to_char(rw_craplot.dtmvtopg, 'dd/mm/yyyy')||'</dtmvtopg>'
                         );
      vr_cont_rej := 0;
      -- Leitura dos registros rejeitados para inclusão no XML
      FOR rw_craprej IN cr_craprej(pr_cdcooper => rw_craplot.cdcooper,
                                   pr_dtmvtolt => rw_craplot.dtmvtolt,
                                   pr_cdagenci => rw_craplot.cdagenci,
                                   pr_cdbccxlt => rw_craplot.cdbccxlt,
                                   pr_nrdolote => rw_craplot.nrdolote) LOOP
        IF vr_cdcritic <> rw_craprej.cdcritic THEN
          vr_cdcritic := rw_craprej.cdcritic;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          IF rw_craprej.cdcritic IN ('257', '287') THEN
            -- 257	COOPER
            -- 287	FARM.SESI IBI
            vr_dscritic := '* ' || vr_dscritic;
          END IF;
        END IF;
        vr_dshistor := TO_CHAR(gene0002.fn_mask(rw_craprej.nraplica,'zzzz.zzz.z')) ||
                       ' ==> ' || trim(rw_craprej.cdpesqbb) ||
                       TO_CHAR(rw_craprej.vllanmto,'9999G990D00') ||
                       ' --> ' || vr_dscritic;

        pc_escreve_clob('<rejeitados>      
                           <dshistor>' || vr_dshistor || '</dshistor>
                         </rejeitados> ');
        vr_cont_rej := vr_cont_rej + 1;
      END LOOP;
      --incluir tag caso não tenha nenhum rejeitado, para o correto funcionamento do ireport
      IF vr_cont_rej = 0 THEN
        pc_escreve_clob('<rejeitados/>'); 
      END IF;  
      
      pc_escreve_clob('<cont_rej>'||vr_cont_rej||'</cont_rej>');
      pc_escreve_clob( '<total>' ||
                            '<qtinfoln>' || to_char(rw_craplot.qtinfoln, 'fm999g990') ||  '</qtinfoln>' ||
                            '<vlinfodb>' || to_char(rw_craplot.vlinfodb, 'fm999g999g999g990d00') ||  '</vlinfodb>' ||
                            '<vlinfocr>' || to_char(rw_craplot.vlinfocr, 'fm999g999g999g990d00') ||  '</vlinfocr>' ||
                            '<qtcompln>' || to_char(rw_craplot.qtcompln, 'fm999g990') ||  '</qtcompln>' ||
                            '<vlcompdb>' || to_char(rw_craplot.vlcompdb, 'fm999g999g999g990d00') ||  '</vlcompdb>' ||
                            '<vlcompcr>' || to_char(rw_craplot.vlcompcr, 'fm999g999g999g990d00') ||  '</vlcompcr>' ||
                            '<qtdifeln>' || to_char(vr_qtdifeln, 'fm999g990') ||  '</qtdifeln>' ||
                            '<vldifedb>' || to_char(vr_vldifedb, 'fm999g999g999g990d00') ||  '</vldifedb>' ||
                            '<vldifecr>' || to_char(vr_vldifecr, 'fm999g999g999g990d00') ||  '</vldifecr>' ||
                            '<qttot>' || to_char(rw_craplot.qtinfoln + rw_craplot.qtcompln, 'fm9g999g990') ||  '</qttot>' ||
                         '</total>' ||
                      '</crrl287>');
    END LOOP;

    if nvl(length(vr_dsxmldad), 0) = 0 then
      -- Não haviam registros para processar
      pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?>' ||
                      '<crrl287><tipo></tipo><mensagem>** NENHUM LANCAMENTO NO DIA **</mensagem><rejeitados><cont_rej>0</cont_rej></rejeitados><total><qttot>0</qttot></total></crrl287>');
    end if;

    --Busca o diretório para geracao do relatorio
    vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C', --> /usr/Coop
                                         pr_cdcooper => pr_cdcooper,
                                         pr_nmsubdir => 'rl');
    -- Efetuar solicitacao de geracao de relatorio --
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,             --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,             --> Programa chamador
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt,     --> Data do movimento atual
                                pr_dsxml     => vr_dsxmldad,             --> Arquivo XML de dados
                                pr_dsxmlnode => '/crrl287/rejeitados',   --> Nó base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl287.jasper',        --> Arquivo de layout do iReport
                                pr_dsparams  => '',                      --> Enviar como parâmetro apenas o valor maior deposito
                                pr_dsarqsaid => vr_dsdireto || '/' || vr_nmrelato || '.lst', --> Arquivo final com código da agência
                                pr_qtcoluna  => 132,                     --> 132 colunas
                                pr_sqcabrel  => 1,                       --> Sequencia do Relatorio {includes/cabrel132_1.i}
                                pr_flg_impri => 'S',                     --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => '132dm',                 --> Nome do formulário para impressão
                                pr_nrcopias  => 1,                       --> Número de cópias
                                pr_flg_gerar => 'N' ,                    --> gerar PDF
                                pr_des_erro  => vr_dscritic);            --> Saída com erro
    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;
    -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_dsxmldad);
    dbms_lob.freetemporary(vr_dsxmldad);
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
    -- Limpar as tabelas geradas no processo
    vr_tab_erro.DELETE;
    -- Efetuar commit
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Liberando a memoria alocada pro CLOB
      if nvl(length(vr_dsxmldad), 0) > 0 then
        dbms_lob.close(vr_dsxmldad);
        dbms_lob.freetemporary(vr_dsxmldad);
      end if;

      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

      -- Se foi gerada critica para envio ao log
      IF vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratado
                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || vr_dscritic);
      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar commit pois gravaremos o que foi processo até então
      COMMIT;

    WHEN vr_exc_saida THEN
      -- Liberando a memoria alocada pro CLOB
      if nvl(length(vr_dsxmldad), 0) > 0 then
        dbms_lob.close(vr_dsxmldad);
        dbms_lob.freetemporary(vr_dsxmldad);
      end if;

      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN

      cecred.pc_internal_exception(pr_cdcooper);

      -- Liberando a memoria alocada pro CLOB
      if nvl(length(vr_dsxmldad), 0) > 0 then
        dbms_lob.close(vr_dsxmldad);
        dbms_lob.freetemporary(vr_dsxmldad);
      end if;
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS341;
/
