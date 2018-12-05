CREATE OR REPLACE PROCEDURE CECRED.pc_crps403(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps403 (Fontes/crps403.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Evandro
       Data    : Outubro/2004                       Ultima atualizacao: 25/08/2015

       Dados referentes ao programa:

       Frequencia: Semanal.
       Objetivo  : Atende a solicitacao 82 Ordem 47.
                   Gerar relatorio (364) com a relacao de baixas do CCF
                   Gerar lancamento de tarifa de regularizacao do CCF.
                   Este programa passou de uma cadeia paralela para exclusiva.

       Alteracoes: 30/11/2004 - Incluido "CPF/CNPJ" (Evandro).

                   23/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                   10/04/2007 - Lista situacao dos cheques como "ENVIADO/NAO
                                ENVIADO" e separa o relatorio por bancos (Elton).

                   23/05/2007 - Eliminada atribuicao TRUE de glb_infimsol pois
                                nao e o ultimo programa da cadeia (Guilherme).

                   13/07/2007 - Corrigidas as descricoes das situacoes dos cheques
                                (Evandro).

                   20/11/2007 - Tarifar regularizacao de CCF, alterado de paralelo
                                para exclusivo solicitacao 82, ordem 47 (Guilherme).

                   11/05/2009 - Alteracao CDOPERAD (Kbase).

                   16/11/2009 - Nao cobrar tarifa no período de pré inclusao do
                                cheque no CCF (Fernando).

                   18/03/2010 - Adaptacao CCF Projeto IF CECRED (Guilherme).

                   21/02/2011 - Atender a Trf. 38210 para o valor da tarifa dos
                                cooperados ser da TAB027 e nao da tela TRFCMP (Ze).

                   14/01/2013 - Tratamento para contas migradas
                                Viacredi -> AltoVale. (Fabricio)

                   15/03/2013 - Incluir ajustes do Projeto de Tarifas Fase 2
                                Grupo de cheque (Lucas R.).

                   09/09/2013 - Nova forma de chamar as agencias, de PAC agora
                                a escrita será PA (André Euzébio - Supero).

                   11/10/2013 - Incluido parametro cdprogra nas procedures da
                                b1wgen0153 que carregam dados de tarifas (Tiago).

                   24/04/2014 - Conversão Progress para PLSQL (Odirlei/AMcom)

                   25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                                tari0001.pc_cria_lan_auto_tarifa, projeto de 
                                Tarifas-218(Jean Michel) 
                                
                   16/11/2018 - PJ435 Validar conta encerrada - Rafael Faria (Supero)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS403';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_tab_erro   GENE0001.typ_tab_erro;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.cdbcoctl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Leitura do Cadastro de controle dos saldos negativos e devolucoes de cheques.
      CURSOR cr_crapneg (pr_cdcooper crapneg.cdcooper%type,
                         pr_dtmvtolt crapdat.dtmvtolt%type) IS
        SELECT crapneg.dtfimest,
               crapneg.dtiniest,
               crapneg.nrdconta,
               crapneg.cdbanchq,
               crapneg.cdagechq,
               crapneg.nrctachq,
               crapneg.nrdocmto,
               crapneg.flgctitg,
               crapneg.vlestour,
               crapneg.cdobserv,
               crapneg.cdoperad,
               crapass.nrdctitg,
               crapass.inpessoa,
               crapass.nrcpfcgc,
               crapass.cdagenci,
               crapass.nmprimtl,
               row_number() over (partition by crapneg.cdbanchq
                                      order by crapneg.cdbanchq,crapass.cdagenci,crapass.nrdconta) nrseqreg,
               COUNT(*) over (partition by crapneg.cdbanchq
                                      order by crapneg.cdbanchq) nrqtdreg,
               crapass.dtdemiss
          FROM crapneg, crapass
         WHERE crapneg.cdcooper = pr_cdcooper
           AND crapneg.dtfimest >= pr_dtmvtolt
           AND crapneg.cdobserv IN (12,13)
           AND crapass.cdcooper = pr_cdcooper
           AND crapass.cdcooper = crapneg.cdcooper
           AND crapass.nrdconta = crapneg.nrdconta
           ORDER BY crapneg.cdbanchq,
                    crapass.cdagenci,
                    crapass.nrdconta;

      -- Verificar se o operador existe
      CURSOR cr_crapope (pr_cdcooper crapneg.cdcooper%TYPE,
                         pr_cdoperad crapneg.cdoperad%TYPE) IS
        SELECT crapope.cdoperad
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
       rw_crapope cr_crapope%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      TYPE typ_reg_contas_migradas IS RECORD (
         cdcooper  craplcm.cdcooper%TYPE,
         nrdconta  craplcm.nrdconta%TYPE,
         vllanmto  craplcm.vllanmto%TYPE,
         cdbanchq  crapneg.cdbanchq%TYPE,
         cdagechq  crapneg.cdagechq%TYPE,
         nrctachq  crapneg.nrctachq%TYPE,
         nrdocmto  crapneg.nrdocmto%TYPE);

      TYPE typ_tab_contas_migradas IS TABLE OF typ_reg_contas_migradas
       INDEX BY PLS_INTEGER;

      vr_tab_contas_migradas typ_tab_contas_migradas;

      ------------------------------- VARIAVEIS -------------------------------
      vr_nmarqimp   VARCHAR2(100) := 'crrl364.lst'; -- Nome do relatorio
      vr_vltarifa   NUMBER;            -- Valor Tarifa
      vr_cdhistor   INTEGER;           -- Historico da tarifa
      vr_cdhisest   INTEGER;           -- Historico estorno
      vr_cdhisbac   INTEGER;           -- Historico da tarifa basen
      vr_vltarbac   NUMBER;            -- Valor Tarifa bacen
      vr_cdfvlbac   INTEGER;           -- Codigo faixa valor bacen
      vr_cdfvlcop   INTEGER;           -- Codigo faixa valor cooperativa
      vr_cdtarifa   VARCHAR2(100);     -- Código do tipo de tarifa
      vr_cdtarbac   VARCHAR2(100);     -- Código do tipo de tarifa bacen
      vr_flg_tarifado BOOLEAN;         -- Indicado de tarifado
      vr_dtdivulg   DATE;              -- Data Divulgacao
      vr_dtvigenc   DATE;              -- Data Vigencia
      vr_migrado    BOOLEAN;           -- Indicador de conta migrada
      vr_rowid_craplat ROWID;          -- rowid do lançamento da craplat
      vr_vlregccf   NUMBER := 0;       -- Valor de lançamento
      vr_conta_ativa BOOLEAN;          -- somente cobrar tarifa para conta ativa

      --Variaveis para armazenar informações do relatorio
      vr_rel_nrcpfcgc  VARCHAR2(20);
      vr_rel_dsoperad  VARCHAR2(20);
      vr_rel_situacao  VARCHAR2(20);
      vr_rel_nmdbanco  VARCHAR2(20);

      -- Variáveis para armazenar as informações em XML
      vr_des_xml         CLOB;
      -- Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_texto_completo  VARCHAR2(32600);
      -- diretorio de geracao do relatorio
      vr_nom_direto  VARCHAR2(100);


      --------------------------- SUBROTINAS INTERNAS --------------------------
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
      BEGIN
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      END;

      --verificar se o cooperado foi migrado e armazenat em temtable
      PROCEDURE pc_verifica_cooperado_migrado(pr_cdcooper IN INTEGER, --> Codigo da cooperativa
                                              pr_nrdconta IN INTEGER, --> Numero da conta do cooperado
                                              pr_vllanmto IN NUMBER,  --> Valor do lancamento
                                              pr_cdbanchq IN INTEGER, --> codigo do banco do cheque
                                              pr_cdagechq IN INTEGER, --> codigo da agencia do cheque
                                              pr_nrctachq IN NUMBER,  --> Numero da conta co cheque
                                              pr_nrdocmto IN NUMBER,  --> Numero do documento
                                              pr_migrado  OUT BOOLEAN,--> retorna identificador de conta migrada
                                              pr_dscritic OUT VARCHAR2) IS
        -- Verificar contas transferidas entre cooperativas
        CURSOR cr_craptco IS
          SELECT cdcooper,
                 nrdconta
            FROM craptco
           WHERE craptco.cdcopant = pr_cdcooper
             AND craptco.nrctaant = pr_nrdconta
             AND craptco.flgativo = 1 --TRUE
             AND craptco.tpctatrf = 1;
        rw_craptco cr_craptco%ROWTYPE;

        vr_idx      PLS_INTEGER := 0;
        vr_exc_erro EXCEPTION;

      BEGIN

        -- Verificar contas transferidas entre cooperativas
        OPEN cr_craptco;
        FETCH cr_craptco
          INTO rw_craptco;

        -- se existir deve criar registro na temptable
        IF cr_craptco%FOUND THEN
          --gerar index sequencial
          vr_idx := vr_tab_contas_migradas.count + 1;

          vr_tab_contas_migradas(vr_idx).cdcooper := rw_craptco.cdcooper;
          vr_tab_contas_migradas(vr_idx).nrdconta := rw_craptco.nrdconta;
          vr_tab_contas_migradas(vr_idx).vllanmto := pr_vllanmto;
          vr_tab_contas_migradas(vr_idx).cdbanchq := pr_cdbanchq;
          vr_tab_contas_migradas(vr_idx).cdagechq := pr_cdagechq;
          vr_tab_contas_migradas(vr_idx).nrctachq := pr_nrctachq;
          vr_tab_contas_migradas(vr_idx).nrdocmto := pr_nrdocmto;
          --retornar como conta migrada
          pr_migrado := TRUE;
        ELSE
         --retornar como conta não migrada
         pr_migrado := FALSE;
        END IF;
        --fechar cursor
        CLOSE cr_craptco;

      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro na pc_verifica_cooperado_migrado: '||SQLERRM;
      END pc_verifica_cooperado_migrado;

      -- Processa contas migradas
      PROCEDURE pc_processamento_tco (pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

        ------------CURSOR--------------
        -- buscar dados do associado
        CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%type,
                           pr_nrdconta crapass.nrdconta%type)IS
          SELECT inpessoa
                ,dtdemiss
            FROM crapass
           WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;

        ----------VARIAVEIS-------------
        vr_idx       PLS_INTEGER;
        vr_exc_erro  EXCEPTION;
        vr_conta_ativa BOOLEAN;      -- somente cobrar tarifa para conta ativa

      BEGIN
        --buscar primeiro registro
        vr_idx := vr_tab_contas_migradas.first;

        -- varrer temptable enquanto houver index
        WHILE vr_idx IS NOT NULL LOOP
          -- Buscar dados do associado
          OPEN cr_crapass (pr_cdcooper => vr_tab_contas_migradas(vr_idx).cdcooper,
                           pr_nrdconta => vr_tab_contas_migradas(vr_idx).nrdconta);
          FETCH cr_crapass
            INTO rw_crapass;

          -- Caso não localizar, levantar exception
          IF cr_crapass%NOTFOUND THEN
            vr_cdcritic := 251;
            -- Fecha cursor 
            CLOSE cr_crapass;
            RAISE vr_exc_erro;
          END IF;
          
          -- Fecha cursor 
          CLOSE cr_crapass;

          vr_conta_ativa := (CASE WHEN rw_crapass.dtdemiss IS NULL THEN TRUE ELSE FALSE END);

          IF rw_crapass.inpessoa = 3 THEN
            -- caso for tipo de pessoa 3 deve ir para o proximo
            vr_idx := vr_tab_contas_migradas.next(vr_idx);
            continue;
          END IF;

          -- se a conta esta ativa busca as tarifas e lança na conta
          -- se nao estiver ativa apenas gera o relatorio
          IF vr_conta_ativa THEN
          --Definir codigo da tarifa
          IF rw_crapass.inpessoa = 1 THEN
            vr_cdtarifa := 'EXCLUCCFPF';  /* sigla da tarifa */
            vr_cdtarbac := 'EXCCCFBCPF';  /* cod. tarifa - taxa bacen */
          ELSE
            vr_cdtarifa := 'EXCLUCCFPJ';  /* sigla da tarifa */
            vr_cdtarbac := 'EXCCCFBCPJ';  /* cod. tarifa taxa bacen */
          END IF;
          END IF;

          IF vr_cdtarifa IN ('EXCLUCCFPF','EXCLUCCFPJ') THEN
            /*  Busca valor da tarifa sem registro*/
            TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                                  ,pr_cdbattar  => vr_cdtarifa  --Codigo Tarifa
                                                  ,pr_vllanmto  => 1            --Valor Lancamento
                                                  ,pr_cdprogra  => vr_cdprogra  --Codigo Programa
                                                  ,pr_cdhistor  => vr_cdhistor  --Codigo Historico
                                                  ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                                  ,pr_vltarifa  => vr_vltarifa  --Valor tarifa
                                                  ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                                  ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                                  ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                                  ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                                  ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                                  ,pr_tab_erro  => vr_tab_erro); --Tabela erros
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Se possui erro no vetor
              IF vr_tab_erro.Count > 0 THEN
                vr_cdcritic:= vr_tab_erro(1).cdcritic;
                vr_dscritic:= vr_tab_erro(1).dscritic;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
              END IF;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;

          /* BUSCA INFORMACOES TAXA BACEN*/
          IF vr_cdtarbac IN ('EXCCCFBCPF','EXCCCFBCPJ')  THEN
            /*  Busca valor da tarifa sem registro*/
            TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                                  ,pr_cdbattar  => vr_cdtarbac  --Codigo Tarifa
                                                  ,pr_vllanmto  => 1            --Valor Lancamento
                                                  ,pr_cdprogra  => vr_cdprogra  --Codigo Programa
                                                  ,pr_cdhistor  => vr_cdhisbac  --Codigo Historico
                                                  ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                                  ,pr_vltarifa  => vr_vltarbac  --Valor tarifa
                                                  ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                                  ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                                  ,pr_cdfvlcop  => vr_cdfvlbac  --Codigo faixa valor cooperativa
                                                  ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                                  ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                                  ,pr_tab_erro  => vr_tab_erro); --Tabela erros
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Se possui erro no vetor
              IF vr_tab_erro.Count > 0 THEN
                vr_cdcritic:= vr_tab_erro(1).cdcritic;
                vr_dscritic:= vr_tab_erro(1).dscritic;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
              END IF;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;

          --Gerar lancamentos
          IF vr_cdtarifa IN ('EXCLUCCFPF','EXCLUCCFPJ') AND
             vr_vltarifa > 0 THEN

            --Inicializar variavel retorno erro
            TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper =>  vr_tab_contas_migradas(vr_idx).cdcooper      -- Codigo Cooperativa
                                             ,pr_nrdconta =>  vr_tab_contas_migradas(vr_idx).nrdconta      -- Numero da Conta
                                             ,pr_dtmvtolt =>  rw_crapdat.dtmvtolt                          -- Data Lancamento
                                             ,pr_cdhistor => vr_cdhistor                                   -- Codigo Historico
                                             ,pr_vllanaut => vr_vltarifa                                   -- Valor lancamento automatico
                                             ,pr_cdoperad => '1'                                           -- Codigo Operador
                                             ,pr_cdagenci => 1                                             -- Codigo Agencia
                                             ,pr_cdbccxlt => 100                                           -- Codigo banco caixa
                                             ,pr_nrdolote => 10514                                         -- Numero do lote
                                             ,pr_tpdolote => 1                                             -- Tipo do lote
                                             ,pr_nrdocmto =>  vr_tab_contas_migradas(vr_idx).nrdocmto      -- Numero do documento
                                             ,pr_nrdctabb =>  vr_tab_contas_migradas(vr_idx).nrdconta      -- Numero da conta
                                             ,pr_nrdctitg =>  vr_tab_contas_migradas(vr_idx).nrdconta      -- Numero da conta integracao
                                             ,pr_cdpesqbb => 'Fato gerador tarifa:' || TO_CHAR(vr_tab_contas_migradas(vr_idx).nrdocmto)   --Codigo pesquisa
                                             ,pr_cdbanchq =>  vr_tab_contas_migradas(vr_idx).cdbanchq      -- Codigo Banco Cheque
                                             ,pr_cdagechq =>  vr_tab_contas_migradas(vr_idx).cdagechq      -- Codigo Agencia Cheque
                                             ,pr_nrctachq =>  vr_tab_contas_migradas(vr_idx).nrctachq      -- Numero Conta Cheque
                                             ,pr_flgaviso => FALSE                                         -- Flag aviso
                                             ,pr_tpdaviso => 0                                             -- Tipo aviso
                                             ,pr_cdfvlcop => vr_cdfvlcop                                   -- Codigo cooperativa
                                             ,pr_inproces => rw_crapdat.inproces                           -- Indicador processo
                                             ,pr_rowid_craplat => vr_rowid_craplat                         -- Rowid do lancamento tarifa
                                             ,pr_tab_erro => vr_tab_erro                                   -- Tabela retorno erro
                                             ,pr_cdcritic => vr_cdcritic                                   -- Codigo Critica
                                             ,pr_dscritic => vr_dscritic);                                 -- Descricao Critica
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
              IF vr_tab_erro.Count > 0 THEN
                vr_cdcritic:= vr_tab_erro(1).cdcritic;
                vr_dscritic:= vr_tab_erro(1).dscritic;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Nao foi possivel gerar craplat: ('||vr_cdcritic||') '||vr_dscritic;
              END IF;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

          END IF;

          /* cria lancamento para tarifa de regularizacao ccf - Taxa BACEN */
          IF vr_cdtarbac in ('EXCCCFBCPF','EXCCCFBCPJ') AND
             vr_vltarbac > 0  THEN
            --Inicializar variavel retorno erro
            TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => vr_tab_contas_migradas(vr_idx).cdcooper      -- Codigo Cooperativa
                                             ,pr_nrdconta => vr_tab_contas_migradas(vr_idx).nrdconta      -- Numero da Conta
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt                          -- Data Lancamento
                                             ,pr_cdhistor => vr_cdhisbac                                  -- Codigo Historico
                                             ,pr_vllanaut => vr_vltarbac                                  -- Valor lancamento automatico
                                             ,pr_cdoperad => '1'                                          -- Codigo Operador
                                             ,pr_cdagenci => 1                                            -- Codigo Agencia
                                             ,pr_cdbccxlt => 100                                          -- Codigo banco caixa
                                             ,pr_nrdolote => 10514                                        -- Numero do lote
                                             ,pr_tpdolote => 1                                            -- Tipo do lote
                                             ,pr_nrdocmto => 0                                            -- Numero do documento
                                             ,pr_nrdctabb =>  vr_tab_contas_migradas(vr_idx).nrdconta     -- Numero da conta
                                             ,pr_nrdctitg =>  vr_tab_contas_migradas(vr_idx).nrdconta     -- Numero da conta integracao
                                             ,pr_cdpesqbb => 'Fato gerador tarifa:' || TO_CHAR(vr_tab_contas_migradas(vr_idx).nrdocmto)   --Codigo pesquisa
                                             ,pr_cdbanchq =>  vr_tab_contas_migradas(vr_idx).cdbanchq     -- Codigo Banco Cheque
                                             ,pr_cdagechq =>  vr_tab_contas_migradas(vr_idx).cdagechq     -- Codigo Agencia Cheque
                                             ,pr_nrctachq =>  vr_tab_contas_migradas(vr_idx).nrctachq     -- Numero Conta Cheque
                                             ,pr_flgaviso => FALSE                                        -- Flag aviso
                                             ,pr_tpdaviso => 0                                            -- Tipo aviso
                                             ,pr_cdfvlcop => vr_cdfvlbac                                  -- Codigo cooperativa
                                             ,pr_inproces => rw_crapdat.inproces                          -- Indicador processo
                                             ,pr_rowid_craplat => vr_rowid_craplat                        -- Rowid do lancamento tarifa
                                             ,pr_tab_erro => vr_tab_erro                                  -- Tabela retorno erro
                                             ,pr_cdcritic => vr_cdcritic                                  -- Codigo Critica
                                             ,pr_dscritic => vr_dscritic);                                -- Descricao Critica
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
              IF vr_tab_erro.Count > 0 THEN
                vr_cdcritic:= vr_tab_erro(1).cdcritic;
                vr_dscritic:= vr_tab_erro(1).dscritic;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Nao foi possivel gerar craplat(Bacen): ('||vr_cdcritic||') '||vr_dscritic;
              END IF;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF; /* fim do if taxa bacen */

          vr_idx := vr_tab_contas_migradas.next(vr_idx);
        END LOOP;

      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          pr_dscritic := 'Erro na pc_verifica_cooperado_migrado: '||SQLERRM;
      END pc_processamento_tco;

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

      -- Leitura da PL/Table e geração do arquivo XML
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl364 nmextcop="'||rw_crapcop.nmextcop||'">');

      -- Leitura do Cadastro de controle dos saldos negativos e devolucoes de cheques.
      FOR rw_crapneg IN cr_crapneg(pr_cdcooper => pr_cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

        vr_conta_ativa := (CASE WHEN rw_crapneg.dtdemiss IS NULL THEN TRUE ELSE FALSE END);
        
        vr_flg_tarifado := FALSE;

        -- somente cobrar tarifa para contas ativas
        -- caso a conta nao estiver ativa apenas gerar o relatorio
        IF vr_conta_ativa THEN
        --Definir tipo de tarifa conforme tipo de pessoa
        IF rw_crapneg.inpessoa = 1 THEN
          vr_cdtarifa := 'EXCLUCCFPF'; /* sigla da tarifa */
          vr_cdtarbac := 'EXCCCFBCPF'; /* cod. tarifa - taxa bacen */
        ELSE
          vr_cdtarifa := 'EXCLUCCFPJ'; /* sigla da tarifa */
          vr_cdtarbac := 'EXCCCFBCPJ'; /* cod. tarifa taxa bacen */
          END IF;
        END IF;

        IF vr_cdtarifa IN ('EXCLUCCFPF','EXCLUCCFPJ') THEN
          /*  Busca valor da tarifa sem registro*/
          TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                                ,pr_cdbattar  => vr_cdtarifa  --Codigo Tarifa
                                                ,pr_vllanmto  => 1            --Valor Lancamento
                                                ,pr_cdprogra  => vr_cdprogra  --Codigo Programa
                                                ,pr_cdhistor  => vr_cdhistor  --Codigo Historico
                                                ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                                ,pr_vltarifa  => vr_vltarifa  --Valor tarifa
                                                ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                                ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                                ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                                ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                                ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                                ,pr_tab_erro  => vr_tab_erro); --Tabela erros
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= vr_tab_erro(1).cdcritic;
              vr_dscritic:= vr_tab_erro(1).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        END IF;

        /* BUSCA INFORMACOES TAXA BACEN*/
        IF vr_cdtarbac IN ('EXCCCFBCPF','EXCCCFBCPJ')  THEN
          /*  Busca valor da tarifa sem registro*/
          TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                                ,pr_cdbattar  => vr_cdtarbac  --Codigo Tarifa
                                                ,pr_vllanmto  => 1            --Valor Lancamento
                                                ,pr_cdprogra  => vr_cdprogra  --Codigo Programa
                                                ,pr_cdhistor  => vr_cdhisbac  --Codigo Historico
                                                ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                                ,pr_vltarifa  => vr_vltarbac  --Valor tarifa
                                                ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                                ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                                ,pr_cdfvlcop  => vr_cdfvlbac  --Codigo faixa valor cooperativa
                                                ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                                ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                                ,pr_tab_erro  => vr_tab_erro); --Tabela erros
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Se possui erro no vetor
            IF vr_tab_erro.Count > 0 THEN
              vr_cdcritic:= vr_tab_erro(1).cdcritic;
              vr_dscritic:= vr_tab_erro(1).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        END IF;

        /* Nao cobrar tarifa no periodo de pre-inclusao do cheque no CCF */
        IF rw_crapneg.dtfimest IS NOT NULL AND
           (rw_crapneg.dtfimest - rw_crapneg.dtiniest) > 9  AND
           rw_crapneg.inpessoa <> 3 THEN

          --verificar se o cooperado foi migrado e armazenat em temtable
          pc_verifica_cooperado_migrado(pr_cdcooper => pr_cdcooper,          --> Codigo da cooperativa
                                        pr_nrdconta => rw_crapneg.nrdconta,  --> Numero da conta do cooperado
                                        pr_vllanmto => vr_vlregccf,          --> Valor do lancamento
                                        pr_cdbanchq => rw_crapneg.cdbanchq,  --> codigo do banco do cheque
                                        pr_cdagechq => rw_crapneg.cdagechq,  --> codigo da agencia do cheque
                                        pr_nrctachq => rw_crapneg.nrctachq,  --> Numero da conta co cheque
                                        pr_nrdocmto => rw_crapneg.nrdocmto,  --> Numero do documento
                                        pr_migrado  => vr_migrado,           --> retorna identificador de conta migrada
                                        pr_dscritic => vr_dscritic);

          -- Caso identificar alguma falha, levantar exception
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          IF NOT vr_migrado THEN
            IF vr_cdtarifa IN ('EXCLUCCFPF','EXCLUCCFPJ') THEN
              --Inicializar variavel retorno erro
              TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper              -- Codigo Cooperativa
                                               ,pr_nrdconta => rw_crapneg.nrdconta      -- Numero da Conta
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt      -- Data Lancamento
                                               ,pr_cdhistor => vr_cdhistor              -- Codigo Historico
                                               ,pr_vllanaut => vr_vltarifa              -- Valor lancamento automatico
                                               ,pr_cdoperad => '1'                      -- Codigo Operador
                                               ,pr_cdagenci => 1                        -- Codigo Agencia
                                               ,pr_cdbccxlt => 100                      -- Codigo banco caixa
                                               ,pr_nrdolote => 10514                    -- Numero do lote
                                               ,pr_tpdolote => 1                        -- Tipo do lote
                                               ,pr_nrdocmto => rw_crapneg.nrdocmto      -- Numero do documento
                                               ,pr_nrdctabb => rw_crapneg.nrdconta      -- Numero da conta
                                               ,pr_nrdctitg => rw_crapneg.nrdctitg      -- Numero da conta integracao
                                               ,pr_cdpesqbb => 'Fato gerador tarifa:' || TO_CHAR(rw_crapneg.nrdocmto)   --Codigo pesquisa
                                               ,pr_cdbanchq => rw_crapneg.cdbanchq      -- Codigo Banco Cheque
                                               ,pr_cdagechq => rw_crapneg.cdagechq      -- Codigo Agencia Cheque
                                               ,pr_nrctachq => rw_crapneg.nrctachq      -- Numero Conta Cheque
                                               ,pr_flgaviso => FALSE                    -- Flag aviso
                                               ,pr_tpdaviso => 0                        -- Tipo aviso
                                               ,pr_cdfvlcop => vr_cdfvlcop              -- Codigo cooperativa
                                               ,pr_inproces => rw_crapdat.inproces      -- Indicador processo
                                               ,pr_rowid_craplat => vr_rowid_craplat    -- Rowid do lancamento tarifa
                                               ,pr_tab_erro => vr_tab_erro              -- Tabela retorno erro
                                               ,pr_cdcritic => vr_cdcritic              -- Codigo Critica
                                               ,pr_dscritic => vr_dscritic);            -- Descricao Critica
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
                IF vr_tab_erro.Count > 0 THEN
                  vr_cdcritic:= vr_tab_erro(1).cdcritic;
                  vr_dscritic:= vr_tab_erro(1).dscritic;
                ELSE
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Nao foi possivel gerar craplat: ('||vr_cdcritic||') '||vr_dscritic;
                END IF;
                --Levantar Excecao
                RAISE vr_exc_saida;
              END IF;

              vr_flg_tarifado := TRUE;
            END IF;

            /* cria lancamento para tarifa de regularizacao
                                          ccf - Taxa BACEN */
            IF vr_cdtarbac IN ('EXCCCFBCPF','EXCCCFBCPJ') THEN
              --Inicializar variavel retorno erro
              TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper              -- Codigo Cooperativa
                                               ,pr_nrdconta => rw_crapneg.nrdconta      -- Numero da Conta
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt      -- Data Lancamento
                                               ,pr_cdhistor => vr_cdhisbac             -- Codigo Historico
                                               ,pr_vllanaut => vr_vltarbac              -- Valor lancamento automatico
                                               ,pr_cdoperad => '1'                      -- Codigo Operador
                                               ,pr_cdagenci => 1                        -- Codigo Agencia
                                               ,pr_cdbccxlt => 100                      -- Codigo banco caixa
                                               ,pr_nrdolote => 10514                    -- Numero do lote
                                               ,pr_tpdolote => 1                        -- Tipo do lote
                                               ,pr_nrdocmto => 0                        -- Numero do documento
                                               ,pr_nrdctabb => rw_crapneg.nrdconta      -- Numero da conta
                                               ,pr_nrdctitg => rw_crapneg.nrdctitg      -- Numero da conta integracao
                                               ,pr_cdpesqbb => 'Fato gerador tarifa:' || TO_CHAR(rw_crapneg.nrdocmto)   --Codigo pesquisa
                                               ,pr_cdbanchq => rw_crapneg.cdbanchq      -- Codigo Banco Cheque
                                               ,pr_cdagechq => rw_crapneg.cdagechq      -- Codigo Agencia Cheque
                                               ,pr_nrctachq => rw_crapneg.nrctachq      -- Numero Conta Cheque
                                               ,pr_flgaviso => FALSE                    -- Flag aviso
                                               ,pr_tpdaviso => 0                        -- Tipo aviso
                                               ,pr_cdfvlcop => vr_cdfvlbac              -- Codigo cooperativa
                                               ,pr_inproces => rw_crapdat.inproces      -- Indicador processo
                                               ,pr_rowid_craplat => vr_rowid_craplat    -- Rowid do lancamento tarifa
                                               ,pr_tab_erro => vr_tab_erro              -- Tabela retorno erro
                                               ,pr_cdcritic => vr_cdcritic              -- Codigo Critica
                                               ,pr_dscritic => vr_dscritic);            -- Descricao Critica
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
                IF vr_tab_erro.Count > 0 THEN
                  vr_cdcritic:= vr_tab_erro(1).cdcritic;
                  vr_dscritic:= vr_tab_erro(1).dscritic;
                ELSE
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Nao foi possivel gerar craplat(Bacen): ('||vr_cdcritic||') '||vr_dscritic;
                END IF;
                --Levantar Excecao
                RAISE vr_exc_saida;
              END IF;

              vr_flg_tarifado := TRUE;
            END IF;/* fim do if taxa bacen */

          END IF;
        END IF;

        -- Verificar se o operador existe
        OPEN cr_crapope (pr_cdcooper => pr_cdcooper,
                         pr_cdoperad => rw_crapneg.cdoperad);
        FETCH cr_crapope
          INTO rw_crapope;
        -- guardar codigo do operador para o relatorio
        IF cr_crapope%FOUND THEN
          vr_rel_dsoperad := rw_crapneg.cdoperad;
        END IF;
        CLOSE cr_crapope;

        /* Tratamento de CPF/CNPJ */
        IF rw_crapneg.inpessoa = 1   THEN
          vr_rel_nrcpfcgc := gene0002.fn_mask(rw_crapneg.nrcpfcgc,'99999999999');
          vr_rel_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(vr_rel_nrcpfcgc,rw_crapneg.inpessoa);
        ELSE
          vr_rel_nrcpfcgc := gene0002.fn_mask(rw_crapneg.nrcpfcgc,'99999999999999');
          vr_rel_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(vr_rel_nrcpfcgc,rw_crapneg.inpessoa);
        END IF;

        -- Definir descrição da situação
        IF rw_crapneg.flgctitg IN (0,4,5,6)THEN
          vr_rel_situacao := 'NAO ENVIADO';
        ELSIF rw_crapneg.flgctitg = 1 THEN
         vr_rel_situacao := 'ENVIADO';
        ELSIF rw_crapneg.flgctitg = 2   THEN
          vr_rel_situacao := 'PROCESSADO';
        ELSE
          vr_rel_situacao := 'SIT.INVALID';
        END IF;

        -- Se for o primeiro registro do cdbanchq
        IF rw_crapneg.nrseqreg = 1 THEN
          --Definir nome do banco
          IF rw_crapneg.cdbanchq = rw_crapcop.cdbcoctl  THEN
            vr_rel_nmdbanco := 'IF AILOS';
          ELSIF rw_crapneg.cdbanchq = 756 THEN
            vr_rel_nmdbanco := 'BANCOOB';
          ELSIF rw_crapneg.cdbanchq = 1  THEN
            vr_rel_nmdbanco := 'BANCO DO BRASIL';
          ELSE
            vr_rel_nmdbanco := NULL;
          END IF;

          pc_escreve_xml('<banco nmdbanco="'||vr_rel_nmdbanco||'">');
        END IF;

        pc_escreve_xml('<conta>
                          <cdagenci>'||rw_crapneg.cdagenci ||'</cdagenci>
                          <nrdconta>'||gene0002.fn_mask_conta(rw_crapneg.nrdconta) ||'</nrdconta>
                          <nmprimtl>'||SUBSTR(rw_crapneg.nmprimtl,1,27) ||'</nmprimtl>
                          <nrcpfcgc>'||vr_rel_nrcpfcgc     ||'</nrcpfcgc>
                          <nrdocmto>'||gene0002.fn_mask(rw_crapneg.nrdocmto,'zzz.zzz.9') ||'</nrdocmto>
                          <vlestour>'||rw_crapneg.vlestour ||'</vlestour>
                          <tarifado>'||(CASE WHEN vr_flg_tarifado THEN 'SIM' ELSE 'NAO' END)||'</tarifado>
                          <cdobserv>'||rw_crapneg.cdobserv ||'</cdobserv>
                          <dtfimest>'||to_char(rw_crapneg.dtfimest,'DD/MM/RR') ||'</dtfimest>
                          <dsoperad>'||vr_rel_dsoperad     ||'</dsoperad>
                          <situacao>'||vr_rel_situacao     ||'</situacao>
                        </conta>');

        -- Se for a ultima ocorrecia do banco, gerar tag final
        IF rw_crapneg.nrseqreg = rw_crapneg.nrqtdreg then
          pc_escreve_xml('</banco>');
        END IF;

      END LOOP;
      --incluir a tag em branco, caso não gerou nenhuma tag de banco
      IF vr_rel_nmdbanco IS NULL THEN
        pc_escreve_xml('<banco><conta/></banco>');
      END IF;  

      IF vr_tab_contas_migradas.count > 0 THEN
        -- Processa contas migradas
        pc_processamento_tco (pr_cdcritic => vr_cdcritic   --> Critica encontrada
                             ,pr_dscritic => vr_dscritic); --> Texto de erro/critica encontrada

        -- se encontrar critica, levantaer execption
        IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Finalizar o agrupador do relatório
      pc_escreve_xml('</crrl364>',TRUE);      

      -- Busca do diretório base da cooperativa para PDF
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl364/banco/conta'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl364.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'N'                 --> gerar PDF
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

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
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
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
        pr_dscritic := SQLERRM;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps403;
/

