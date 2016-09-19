CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS176" ( pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                          ,pr_flgresta  IN PLS_INTEGER             --> Flag 0/1 para utilização de restar N/S
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

       Programa: pc_crps176 (Antigo Fontes/crps176.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Novembro/96.                    Ultima atualizacao: 25/11/2013

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Atende a solicitacao 5.
                   Ordem na solicitacao: 10.
                   Calcula as aplicacoes RDCA2 aniversariantes.
                   Nao gera relatorio.


       Alteracoes: 25/04/2002 - Somar todas aa aplicacoes para poder definir
                                a taxa a ser usada (Margarete).

                  10/12/2004 - Ajustes para tratar das novas aliquotas de
                               IRRF (Margarete).

                  07/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                               "fontes/iniprg.p" por causa da "glb_cdcooper"
                               (Evandro).

                  15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                  03/12/2007 - Substituir chamada da include rdca2s pela
                               b1wgen0004a.i (Sidnei - Precise).

                  25/02/2008 - Quando aux_vltotrda < 0 zerar variavel (Magui).

                  10/12/2008 - Utilizar procedure "acumula_aplicacoes" (David).

                  25/07/2012 - Ajustes para Oracle (Evandro).

                  11/07/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                  09/08/2013 - Inclusão de teste na pr_flgresta antes de
                               controlar o restart (Marcos-Supero)

                  04/11/2013 - Elimitar a vr_lsaplica (Gabriel).

                  25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS176';

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_exc_undo EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Variáveis para controle de restart
      vr_nrctares crapass.nrdconta%TYPE := 0; --> Número da conta de restart
      vr_dsrestar VARCHAR2(4000);             --> String genérica com informações para restart
      vr_inrestar INTEGER;                    --> Indicador de Restart
      vr_qtregres NUMBER := 0;                --> Quantidade de registros ignorados por terem sido processados antes do restart

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Buscar as informações para restart e Rowid para atualização posterior
      CURSOR cr_crapres IS
        SELECT res.dsrestar
              ,res.rowid
          FROM crapres res
         WHERE res.cdcooper = pr_cdcooper
           AND res.cdprogra = vr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      -- Cursor genérico de parametrização
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_dstextab IN craptab.dstextab%TYPE) IS
        SELECT craptab.dstextab
              ,craptab.tpregist
          FROM craptab craptab
         WHERE craptab.cdcooper = pr_cdcooper
           AND craptab.nmsistem = pr_nmsistem
           AND craptab.tptabela = pr_tptabela
           AND craptab.cdempres = pr_cdempres
           AND craptab.cdacesso = pr_cdacesso
           AND craptab.dstextab = pr_dstextab;

      -- Selecionar informacoes das contas bloqueadas
      CURSOR cr_craptab_ctabloq (pr_cdcooper IN craptab.cdcooper%TYPE
                                ,pr_nmsistem IN craptab.nmsistem%TYPE
                                ,pr_tptabela IN craptab.tptabela%TYPE
                                ,pr_cdempres IN craptab.cdempres%TYPE) IS
        SELECT craptab.cdacesso
              ,craptab.dstextab
          FROM craptab craptab
         WHERE craptab.cdcooper = pr_cdcooper
           AND craptab.nmsistem = pr_nmsistem
           AND craptab.tptabela = pr_tptabela
           AND craptab.cdempres = pr_cdempres
           AND craptab.tpregist > 0;

      --Selecionar quantidade de saques em poupanca nos ultimos 6 meses
      CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
        SELECT craplpp.nrdconta
              ,craplpp.nrctrrpp
              ,Count(*) qtlancmto
          FROM craplpp craplpp
         WHERE craplpp.cdcooper = pr_cdcooper
           AND craplpp.cdhistor IN (158,496)
           AND craplpp.dtmvtolt > pr_dtmvtolt
         GROUP BY craplpp.nrdconta,craplpp.nrctrrpp
        HAVING Count(*) > 3;

      -- Contar a quantidade de resgates das contas
      CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,Count(*) qtlancmto
          FROM craplrg craplrg
         WHERE craplrg.cdcooper = pr_cdcooper
           AND craplrg.tpaplica = 4
           AND craplrg.inresgat = 0
         GROUP BY craplrg.nrdconta
                 ,craplrg.nraplica;

      --Selecionar informacoes dos lancamentos de resgate
      CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                        ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,craplrg.tpaplica
              ,craplrg.tpresgat
              ,Nvl(Sum(Nvl(craplrg.vllanmto,0)),0) vllanmto
          FROM craplrg craplrg
         WHERE craplrg.cdcooper  = pr_cdcooper
           AND craplrg.dtresgat <= pr_dtresgat
           AND craplrg.inresgat  = 0
           AND craplrg.tpresgat IN(1,2)
         GROUP BY craplrg.nrdconta
                 ,craplrg.nraplica
                 ,craplrg.tpaplica
                 ,craplrg.tpresgat;

      -- Buscar o cadastro dos associados da Cooperativa
      -- e suas devidas aplicações ativas
      CURSOR cr_craprda IS
        SELECT ass.nrdconta
              ,ass.cdagenci
              ,rda.nraplica
              ,ROW_NUMBER () OVER (PARTITION BY ass.nrdconta
                                       ORDER BY ass.nrdconta
                                               ,rda.nraplica) sqregcta
          FROM crapass ass
              ,craprda rda
         WHERE rda.cdcooper = ass.cdcooper
           AND rda.nrdconta = ass.nrdconta
           AND ass.cdcooper = pr_cdcooper
           AND ass.nrdconta > vr_nrctares
           AND rda.dtfimper <= rw_crapdat.dtmvtopr -- Com encerramento anterior ou igual ao próximo dia util
           AND rda.incalmes = 0                    -- Ainda não calculado neste mês
           AND rda.insaqtot = 0                    -- Ainda não sacado totalmente
           AND rda.tpaplica = 5                    -- RDCA II
         ORDER BY ass.nrdconta
                 ,rda.nraplica;
      rw_craprda cr_craprda%ROWTYPE;

      ------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Variavel usada para montar o indice da tabela de memoria
      vr_index_craptab VARCHAR2(20);
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);

      -- Definicao das tabelas de memoria da apli0001.pc_acumula_aplicacoes
      vr_tab_acumula    APLI0001.typ_tab_acumula_aplic;
      vr_tab_tpregist   APLI0001.typ_tab_tpregist;
      vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
      vr_tab_craplpp    APLI0001.typ_tab_craplpp;
      vr_tab_craplrg    APLI0001.typ_tab_craplpp;
      vr_tab_resgate    APLI0001.typ_tab_resgate;

      ----------------------------- VARIAVEIS ------------------------------

      -- Variaveis de Retorno da Procedure pc_acumula_aplicacoes
      vr_percenir NUMBER      := 0;
      vr_qtdfaxir PLS_INTEGER := 0;
      vr_txaplica CRAPLAP.TXAPLICA%TYPE;
      vr_txaplmes CRAPLAP.TXAPLMES%TYPE;
      vr_vltotrda CRAPRDA.VLSDRDCA%TYPE;

      -- Variavel para receber valor data inicio e fim para calculo taxa rdcpos.
      vr_dstextab_rdcpos craptab.dstextab%TYPE;
      vr_dtinitax        DATE;    --> Data de inicio da utilizacao da taxa de poupanca.
      vr_dtfimtax        DATE;    --> Data de fim da utilizacao da taxa de poupanca.

      ----------------- SUBROTINAS INTERNAS --------------------

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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1 --true
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Buscar descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Tratamento e retorno de valores de restart
      btch0001.pc_valida_restart(pr_cdcooper  => pr_cdcooper   --> Cooperativa conectada
                                ,pr_cdprogra  => vr_cdprogra   --> Código do programa
                                ,pr_flgresta  => pr_flgresta   --> Indicador de restart
                                ,pr_nrctares  => vr_nrctares   --> Número da conta de restart
                                ,pr_dsrestar  => vr_dsrestar   --> String genérica com informações para restart
                                ,pr_inrestar  => vr_inrestar   --> Indicador de Restart
                                ,pr_cdcritic  => vr_cdcritic   --> Código de erro
                                ,pr_des_erro  => vr_dscritic); --> Saída de erro
      -- Se encontrou erro, gerar exceção
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Somente se a flag de restart estiver ativa
      IF pr_flgresta = 1 THEN
        -- Buscar as informações para restart e Rowid para atualização posterior
        OPEN cr_crapres;
        FETCH cr_crapres
         INTO rw_crapres;
        -- Se não tiver encontrador
        IF cr_crapres%NOTFOUND THEN
          -- Fechar o cursor e gerar erro
          CLOSE cr_crapres;
          -- Montar mensagem de critica
          vr_cdcritic := 151;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor para continuar
          CLOSE cr_crapres;
        END IF;
      END IF;

      -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
      vr_percenir := GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                            ,pr_nmsistem => 'CRED'
                                                                            ,pr_tptabela => 'CONFIG'
                                                                            ,pr_cdempres => 0
                                                                            ,pr_cdacesso => 'PERCIRAPLI'
                                                                            ,pr_tpregist => 0));

      -- Verificar as faixas de IR
      APLI0001.pc_busca_faixa_ir_rdca(pr_cdcooper => pr_cdcooper);
      -- Buscar a quantidade de faixas de ir
      vr_qtdfaxir := APLI0001.vr_faixa_ir_rdca.Count;

      -- Selecionar informacoes da data de inicio e fim da taxa para calculo da APLI0001.pc_provisao_rdc_pos
      vr_dstextab_rdcpos := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                      ,pr_nmsistem => 'CRED'
                                                      ,pr_tptabela => 'USUARI'
                                                      ,pr_cdempres => 11
                                                      ,pr_cdacesso => 'MXRENDIPOS'
                                                      ,pr_tpregist => 1);
      -- Se não encontrar
      IF vr_dstextab_rdcpos IS NULL THEN
        -- Utilizar datas padrão
        vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
        vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
      ELSE
        --Atribuir as datas encontradas
        vr_dtinitax := to_date(gene0002.fn_busca_entrada(1, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
        vr_dtfimtax := to_date(gene0002.fn_busca_entrada(2, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
      END IF;

      -- Carregar tabela de memoria de taxas
      -- Selecionar os tipos de registro da tabela generica
      FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper
                                  ,pr_nmsistem => 'CRED'
                                  ,pr_tptabela => 'GENERI'
                                  ,pr_cdempres => 3
                                  ,pr_cdacesso => 'SOMAPLTAXA'
                                  ,pr_dstextab => 'SIM') LOOP
        -- Atribuir valor para tabela memoria
        vr_tab_tpregist(rw_craptab.tpregist) := rw_craptab.tpregist;
      END LOOP;

      -- Carregar tabela de memoria de contas bloqueadas
      FOR rw_craptab IN cr_craptab_ctabloq (pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'BLQRGT'
                                           ,pr_cdempres => 0) LOOP
        -- Montar indice para a tabela de memoria
        vr_index_craptab := LPad(rw_craptab.cdacesso,12,'0')||LPad(SubStr(rw_craptab.dstextab,1,7),8,'0');
        -- Incluir as contas bloqueadas no vetor de memoria
        vr_tab_conta_bloq(vr_index_craptab) := 0;
      END LOOP;

      -- Carregar tabela de memoria de lancamentos na poupanca
      FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt - 180) LOOP
        -- Montar indice para acessar tabela
        vr_index_craplpp := LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');
        -- Atribuir quantidade encontrada de cada conta ao vetor
        vr_tab_craplpp(vr_index_craplpp) := rw_craplpp.qtlancmto;
      END LOOP;

      -- Carregar tabela de memoria com total de resgates na poupanca
      FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper) LOOP
        -- Montar Indice para acesso quantidade lancamentos de resgate
        vr_index_craplrg := LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
        -- Popular tabela de memoria
        vr_tab_craplrg(vr_index_craplrg) := rw_craplrg.qtlancmto;
      END LOOP;


      -- Carregar tabela de memória com total resgatado por conta e aplicacao
      FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                                   ,pr_dtresgat => rw_crapdat.dtmvtopr) LOOP
        -- Montar indice para selecionar total dos resgates na tabela auxiliar
        vr_index_resgate := LPad(rw_craplrg.nrdconta,10,'0')||
                            LPad(rw_craplrg.tpaplica,05,'0')||
                            LPad(rw_craplrg.nraplica,10,'0');
        -- Popular a tabela de memoria com a soma dos lancamentos de resgate
        vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
        vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
      END LOOP;

      -- Busca dos associados da Cooperativa e suas devidas aplicações em aniversário
      FOR rw_craprda IN cr_craprda LOOP
        -- Criar bloco para tratar rollback
        BEGIN

          -- Somente uma vez por conta, ou seja, na primeira sequencia
          IF rw_craprda.sqregcta = 1 THEN

            -- Zerar variaveis
            vr_vltotrda := 0;

            -- Executar rotina para acumular aplicacoes
            APLI0001.pc_acumula_aplicacoes(pr_cdcooper        => pr_cdcooper             --> Cooperativa
                                          ,pr_cdprogra        => vr_cdprogra             --> Nome do programa chamador
                                          ,pr_nrdconta        => rw_craprda.nrdconta     --> Nro da conta da aplicação RDCA
                                          ,pr_nraplica        => 0                       --> Nro da Aplicacao (0=todas)
                                          ,pr_tpaplica        => 3                       --> Tipo de Aplicacao
                                          ,pr_vlaplica        => 0                       --> Valor da Aplicacao
                                          ,pr_cdperapl        => 0                       --> Codigo Periodo Aplicacao
                                          ,pr_percenir        => vr_percenir             --> % IR para Calculo Poupanca
                                          ,pr_qtdfaxir        => vr_qtdfaxir             --> Quantidade de faixas de IR
                                          ,pr_tab_tpregist    => vr_tab_tpregist         --> Tipo de Registro para loop craptab (performance)
                                          ,pr_tab_craptab     => vr_tab_conta_bloq       --> Tipo de tabela de Conta Bloqueada (performance)
                                          ,pr_tab_craplpp     => vr_tab_craplpp          --> Tipo de tabela com lancamento poupanca (performance)
                                          ,pr_tab_craplrg     => vr_tab_craplrg          --> Tipo de tabela com resgates (performance)
                                          ,pr_tab_resgate     => vr_tab_resgate          --> Tabela com a soma dos resgates por conta e aplicacao
                                          ,pr_tab_crapdat     => rw_crapdat              --> Dados da tabela de datas
                                          ,pr_cdagenci_assoc  => rw_craprda.cdagenci     --> Agencia do associado
                                          ,pr_nrdconta_assoc  => rw_craprda.nrdconta     --> Conta do associado
                                          ,pr_dtinitax        => vr_dtinitax             --> Data Inicial da Utilizacao da taxa da poupanca
                                          ,pr_dtfimtax        => vr_dtfimtax             --> Data Final da Utilizacao da taxa da poupanca
                                          ,pr_vlsdrdca        => vr_vltotrda             --> Valor Saldo Aplicacao (OUT)
                                          ,pr_txaplica        => vr_txaplica             --> Taxa Maxima de Aplicacao (OUT)
                                          ,pr_txaplmes        => vr_txaplmes             --> Taxa Minima de Aplicacao (OUT)
                                          ,pr_retorno         => vr_des_reto             --> Descricao de erro ou sucesso OK/NOK
                                          ,pr_tab_acumula     => vr_tab_acumula          --> Aplicacoes do Associado
                                          ,pr_tab_erro        => vr_tab_erro);           --> Saida com erros
            IF vr_des_reto = 'NOK' THEN
              -- Tenta buscar o erro no vetor de erro
              IF vr_tab_erro.COUNT > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Retorno "NOK" na apli0001.pc_acumula_aplicacoes e sem informação na pr_tab_erro, Conta: '||rw_craprda.nrdconta||' Aplica: 0';
              END IF;
              -- Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

            -- Se o total da aplicacao for menor ou i zero
            IF vr_vltotrda <= 0 THEN
              -- Zerar valor total rda
              vr_vltotrda := 0;
            END IF;

          END IF; -- Somente no primeiro registro da conta

          -- Rotina de calculo do aniversario e atualização de aplicações RDCA2
          APLI0001.pc_calc_aniver_rdca2a(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do processo
                                        ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Data do processo
                                        ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicação RDCA
                                        ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicação RDCA
                                        ,pr_vltotrda => vr_vltotrda         --> Saldo total das aplicações
                                        ,pr_cdprogra => vr_cdprogra         --> Programa conectado
                                        ,pr_cdagenci => 0                   --> Código da agência
                                        ,pr_nrdcaixa => 0                   --> Número do caixa
                                        ,pr_des_reto => vr_des_reto         --> OK ou NOK
                                        ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
          IF vr_des_reto = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Retorno "NOK" na apli0001.pc_acumula_aplicacoes e sem informação na pr_tab_erro, Conta: '||rw_craprda.nrdconta||' Aplica: 0';
            END IF;
            -- Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          -- Somente se a flag de restart estiver ativa
          IF pr_flgresta = 1 THEN
            -- Salvar informacoes no banco de dados a cada 10.000 registros processados,
            -- gravar tbm o controle de restart, pois qualquer rollback que será efetuado
            -- vai retornar a situação até o ultimo commit
            -- Obs. Descontamos da quantidade atual, a quantidade que não foi processada
            --      devido a estes registros terem sido processados anteriormente ao restart
            IF Mod(cr_craprda%ROWCOUNT-vr_qtregres,10000) = 0 THEN
              -- Atualizar a tabela de restart
              BEGIN
                UPDATE crapres res
                   SET res.nrdconta = rw_craprda.nrdconta  -- conta atual
                 WHERE res.rowid = rw_crapres.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Gerar erro e fazer rollback
                  vr_dscritic := 'Erro ao atualizar a tabela de Restart (CRAPRES) - Conta:'||rw_craprda.nrdconta||'. Detalhes: '||sqlerrm;
                  RAISE vr_exc_undo;
              END;
              -- Finalmente efetua commit
              COMMIT;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_undo THEN
            -- Desfazer transacoes desde o ultimo commit
            ROLLBACK;
            -- Gerar um raise para gerar o log e sair do processo
            RAISE vr_exc_erro;
        END;

      END LOOP; -- Fim leitura das aplicações

      -- Chamar rotina para eliminação do restart para evitarmos
      -- reprocessamento das empréstimos indevidamente
      btch0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper   --> Cooperativa conectada
                                 ,pr_cdprogra => vr_cdprogra   --> Código do programa
                                 ,pr_flgresta => pr_flgresta   --> Indicador de restart
                                 ,pr_des_erro => vr_dscritic); --> Saída de erro
      -- Testar saída de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Sair do processo
        RAISE vr_exc_erro;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuamos o commit final após o processamento
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;

      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps176;
/

