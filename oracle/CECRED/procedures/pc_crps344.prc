CREATE OR REPLACE PROCEDURE CECRED.pc_crps344(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                      ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS344 (Antigo Fontes/crps344.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2003                       Ultima atualizacao: 28/04/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamentos de tarifas do desconto de cheques.

   Alteracoes: 24/10/2003 - Alterado para incluir a cobranca da tarifa de res-
                            gate de cheque descontado (Edson).

               02/04/2004 - Corrigir erro na cobranca do resgate de cheque
                            descontado (Edson).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).

               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               01/09/2008 - Alteracao CDEMPRES (Kbase).

               24/10/2008 - Corrigir atualizacao do lote (Magui).

               15/10/2010 - Alterado historico 434 p/ 893. Demandas Auditoria
                            BACEN (Guilherme).

               10/07/2013 - Alterado processo de geracao tarifas para utilizar
                            rotinas da b1wgen0153, projeto Tarifas. (Daniel)

               11/10/2013 - Incluido parametro cdprogra nas procedures da
                            b1wgen0153 que carregam dados de tarifas (Tiago).

               30/04/2014 - Adaptado a rotina carrega_tabela_tarifas para
                            carregar temp table com o valor correto da faixa
                            da tarifa (Tiago/Rodrigo SD141136).

               09/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)

               25/08/2015 - Inclusao do parametro pr_cdpesqbb na procedure
                            tari0001.pc_cria_lan_auto_tarifa, projeto de
                            Tarifas-218(Jean Michel)

               28/04/2016 - Incluido chamada à procedure TARI0001.pc_verifica_tarifa_operacao,
                            alteração feita para o Projeto de Tarifas - 218 fase 2
                            (Reinert).

               13/07/2017 - Melhoria 150 - Adicionado o valor total de cheques por bordero
                            para cálculo do percentual da tarifa (Everton-Mouts)

  ............................................................................. */

  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor genérico de calendário
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  -- Cursor Cadastro de Aditivos Contratuais
  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE,
                    pr_dtmvtolt IN craplim.dtinivig%TYPE) IS
    SELECT lim.nrdconta
          ,lim.qtrenova
          ,lim.vllimite
          ,NVL(ass.inpessoa,0) inpessoa
          ,lim.nrctrlim
     FROM craplim lim
         ,crapass ass
    WHERE lim.cdcooper = pr_cdcooper
      AND lim.tpctrlim = 2 -- Desconto de Cheque
      AND lim.insitlim = 2 -- Ativo
      AND lim.dtinivig = pr_dtmvtolt
      AND ass.cdcooper (+) = lim.cdcooper
      AND ass.nrdconta (+) = lim.nrdconta;


  -- Cursor Cadastro de Aditivos Contratuais
  CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE,
                    pr_dtmvtolt IN crapbdc.dtlibbdc%TYPE) IS
    SELECT bdc.nrdconta,
           bdc.dtmvtolt,
           bdc.cdagenci,
           bdc.cdbccxlt,
           bdc.nrdolote,
           bdc.nrborder,
           NVL(ass.inpessoa,0) inpessoa,
           (SELECT sum(c.vlcheque)
              from crapcdb c
             where c.nrborder = bdc.nrborder
               and c.cdcooper = pr_cdcooper) vlchequetot
     FROM crapbdc bdc
         ,crapass ass
    WHERE bdc.cdcooper = pr_cdcooper
      AND bdc.insitbdc = 3 -- Liberado
      AND bdc.dtlibbdc = pr_dtmvtolt
      AND ass.cdcooper (+) = bdc.cdcooper
      AND ass.nrdconta (+) = bdc.nrdconta;

  -- Cursor Lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE,
                    pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                    pr_cdagenci IN craplot.cdagenci%TYPE,
                    pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                    pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT lot.qtcompln
     FROM craplot lot
    WHERE lot.cdcooper = pr_cdcooper
      AND lot.dtmvtolt = pr_dtmvtolt
      AND lot.cdagenci = pr_cdagenci
      AND lot.cdbccxlt = pr_cdbccxlt
      AND lot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  -- Cursor Cheques Contidos do Bordero de Desconto de Cheques
  CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE,
                    pr_dtmvtolt IN crapcdb.dtdevolu%TYPE) IS
    SELECT /*index (CDB CRAPCDB##CRAPCDB6)*/
           cdb.nrdconta
          ,cdb.vlcheque
          ,NVL(ass.inpessoa,0) inpessoa
          ,cdb.nrcheque
     FROM crapcdb cdb
         ,crapass ass
    WHERE cdb.cdcooper = pr_cdcooper
      AND cdb.dtdevolu = pr_dtmvtolt
      AND ass.cdcooper (+) = cdb.cdcooper
      AND ass.nrdconta (+) = cdb.nrdconta;

  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS344';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);

  -- Tabela Temporaria
  vr_tab_erro GENE0001.typ_tab_erro;

  -- Rowid de retorno lançamento de tarifa
  vr_rowid    ROWID;

  -- Variaveis de tarifa
  vr_cdhistor craphis.cdhistor%TYPE;
  vr_cdhisest craphis.cdhistor%TYPE;
  vr_dtdivulg DATE;
  vr_dtvigenc DATE;
  vr_cdfvlcop crapfco.cdfvlcop%TYPE;
  vr_vltarifa crapfco.vltarifa%TYPE;
  vr_cdbattar VARCHAR2(10);
  vr_qtacobra INTEGER;
  vr_fliseope INTEGER;

  -- Listas utilizadas para carga de tarifas
  vr_lstarifa VARCHAR2(2000);

  -- Tabela temporaria para as tarifas
  TYPE typ_reg_tarifa IS
   RECORD(cdhistor crapfvl.cdhistor%TYPE
         ,cdfvlcop crapfvl.cdfaixav%TYPE
         ,vltarifa crapfco.vltarifa%TYPE);
  TYPE typ_tab_tarifa IS
    TABLE OF typ_reg_tarifa
      INDEX BY VARCHAR2(10);
  -- Vetor para armazenar os percentuais de risco
  vr_tab_tarifa typ_tab_tarifa;

BEGIN

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => NULL);

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
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  -- Se não encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic:= 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
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

  -- Processo de carga tarifas para Pl/Table
  vr_lstarifa := 'DSCCHQBOPF;' || -- Bordero Emitido para Pessoa Fisica
                 'DSCCHQBOPJ;' || -- Bordero Emitido para Pessoa Juridica
                 'DSCCHQCHPF;' || -- Tarifa de Cheque Descontado Pessoa Fisica
                 'DSCCHQCHPJ';    -- Tarifa de Cheque Descontado Pessoa Juridica

  -- Popula a PL/TABLE de tarifas
  FOR ind IN 1..4 LOOP

    -- Inicializa as variaveis
    vr_cdhistor := 0;
    vr_cdfvlcop := 0;
    vr_vltarifa := 0;

    -- Codigo da Tarifa
    vr_cdbattar := gene0002.fn_busca_entrada(ind,vr_lstarifa,';');

    -- Busca valor da tarifa transferencia cartao BB pessoa fisica
    TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                        ,pr_cdbattar => vr_cdbattar
                                        ,pr_vllanmto => 1
                                        ,pr_cdprogra => vr_cdprogra
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_cdhisest => vr_cdhisest
                                        ,pr_vltarifa => vr_vltarifa
                                        ,pr_dtdivulg => vr_dtdivulg
                                        ,pr_dtvigenc => vr_dtvigenc
                                        ,pr_cdfvlcop => vr_cdfvlcop
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_tab_erro => vr_tab_erro);

    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Se possui erro no vetor
      IF vr_tab_erro.Count() > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
      END IF;
      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic || ' - ' || vr_cdbattar);
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
    END IF;

    -- Armazena Valores na PL/TABLE
    vr_tab_tarifa(vr_cdbattar).cdhistor := vr_cdhistor;
    vr_tab_tarifa(vr_cdbattar).cdfvlcop := vr_cdfvlcop;
    vr_tab_tarifa(vr_cdbattar).vltarifa := vr_vltarifa;

  END LOOP;

  -- Leitura dos Contrato de Desconto de Cheques
  FOR rw_craplim IN cr_craplim(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP


    -- Caso rw_craplim.inpessoa for igual a 0 significa que não
    -- encontrou nem um associado com o valor de rw_craplim.nrdconta
    -- Neste caso iremos logar critica 9 e pular para o proximo registro
    IF rw_craplim.inpessoa = 0 THEN
      vr_cdcritic:= 9;
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                    gene0002.fn_mask(rw_craplim.nrdconta,'zzzz.zzz.9');

      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);

      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;

      -- Proximo Registro
      CONTINUE;
    END IF;

    -- 1 - Pessoa Fisica
    IF rw_craplim.inpessoa = 1 THEN
      IF rw_craplim.qtrenova = 0 THEN
        vr_cdbattar := 'DSCCHQCTPF'; -- Novo contrato pessoa fisica
      ELSE
        vr_cdbattar := 'DSCCHQREPF'; -- Renovacao contrato pessoa fisica
      END IF;
    ELSE
      IF rw_craplim.qtrenova = 0 THEN
        vr_cdbattar := 'DSCCHQCTPJ'; -- Novo contrato pessoa juridica
      ELSE
        vr_cdbattar := 'DSCCHQREPJ'; -- Renovacao contrato pessoa juridica
      END IF;
    END IF;

    -- Busca valor da tarifa
    TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                         ,pr_cdbattar => vr_cdbattar
                                         ,pr_vllanmto => rw_craplim.vllimite
                                         ,pr_cdprogra => vr_cdprogra
                                         ,pr_cdhistor => vr_cdhistor
                                         ,pr_cdhisest => vr_cdhisest
                                         ,pr_vltarifa => vr_vltarifa
                                         ,pr_dtdivulg => vr_dtdivulg
                                         ,pr_dtvigenc => vr_dtvigenc
                                         ,pr_cdfvlcop => vr_cdfvlcop
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_tab_erro => vr_tab_erro);

    -- Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Se possui erro no vetor
      IF vr_tab_erro.Count() > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
      END IF;
      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic || ' - ' || vr_cdbattar);
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;

      -- Se não Existe Tarifa
      CONTINUE;
    END IF;

    -- Verifica se valor da tarifa esta zerado
    IF vr_vltarifa = 0 THEN
        CONTINUE;
    END IF;

    -- Criar Lançamento automatico Tarifas de contrato de desconto de cheques
    TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                    , pr_nrdconta     => rw_craplim.nrdconta
                                    , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                    , pr_cdhistor     => vr_cdhistor
                                    , pr_vllanaut     => vr_vltarifa
                                    , pr_cdoperad     => '1'
                                    , pr_cdagenci     => 1
                                    , pr_cdbccxlt     => 100
                                    , pr_nrdolote     => 10028
                                    , pr_tpdolote     => 1
                                    , pr_nrdocmto     => 0
                                    , pr_nrdctabb     => rw_craplim.nrdconta
                                    , pr_nrdctitg     => gene0002.fn_mask(rw_craplim.nrdconta,'99999999')
                                    , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_craplim.nrctrlim)
                                    , pr_cdbanchq     => 0
                                    , pr_cdagechq     => 0
                                    , pr_nrctachq     => 0
                                    , pr_flgaviso     => TRUE
                                    , pr_tpdaviso     => 2
                                    , pr_cdfvlcop     => vr_cdfvlcop
                                    , pr_inproces     => rw_crapdat.inproces
                                    , pr_rowid_craplat=> vr_rowid
                                    , pr_tab_erro     => vr_tab_erro
                                    , pr_cdcritic     => vr_cdcritic
                                    , pr_dscritic     => vr_dscritic);
    -- Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Se possui erro no vetor
      IF vr_tab_erro.Count > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro no lancamento Tarifa de contrato de desconto de cheques';
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '||
                                                    gene0002.fn_mask_conta(rw_craplim.nrdconta)||'- '
                                                 || vr_dscritic );
      -- Limpa valores das variaveis de critica
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
    END IF;

  END LOOP; -- Fim Leitura Limites

  -- *********** Cobrança Tarifas de desconto de cheques ***********

  -- Leitura do Cadastro de borderos de descontos de cheques
  FOR rw_crapbdc IN cr_crapbdc(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP


    -- Caso rw_crapbdc.inpessoa for igual a 0 significa que não
    -- encontrou nem um associado com o valor de rw_crapbdc.nrdconta
    -- Neste caso iremos logar critica 9 e pular para o proximo registro
    IF rw_crapbdc.inpessoa = 0 THEN
      vr_cdcritic:= 9;
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                    gene0002.fn_mask(rw_crapbdc.nrdconta,'zzzz.zzz.9');

      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);

      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;

      -- Proximo Registro
      CONTINUE;
    END IF;

    -- 1 - Pessoa Fisica
    IF rw_crapbdc.inpessoa = 1 THEN
      vr_cdbattar := 'DSCCHQBOPF'; -- Bordero Emitido para Pessoa Fisica
    ELSE
      vr_cdbattar := 'DSCCHQBOPJ'; -- Bordero Emitido para Pessoa Juridica
    END IF;

    TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                        ,pr_cdbattar => vr_cdbattar
                                        ,pr_vllanmto => rw_crapbdc.vlchequetot
                                        ,pr_cdprogra => vr_cdprogra
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_cdhisest => vr_cdhisest
                                        ,pr_vltarifa => vr_vltarifa
                                        ,pr_dtdivulg => vr_dtdivulg
                                        ,pr_dtvigenc => vr_dtvigenc
                                        ,pr_cdfvlcop => vr_cdfvlcop
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_tab_erro => vr_tab_erro);

    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
      --Se possui erro no vetor
      IF vr_tab_erro.Count() > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
      END IF;
      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic || ' - ' || vr_cdbattar);
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
    END IF;
    --

    /* Verifica se valor da tarifa esta zerado*/
    IF  vr_vltarifa = 0  THEN
        CONTINUE;
    END IF;

    -- Verificar se deve ser isento de tarifa ou não
    tari0001.pc_verifica_tarifa_operacao(pr_cdcooper => pr_cdcooper          -- Cooperativa
                                        ,pr_cdoperad => '1'                  -- Operador
                                        ,pr_cdagenci => 1                    -- PA
                                        ,pr_cdbccxlt => 100                  -- Cód. Banco
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento
                                        ,pr_cdprogra => vr_cdprogra          -- Cód. programa
                                        ,pr_idorigem => 7                    -- Identificador de origem
                                        ,pr_nrdconta => rw_crapbdc.nrdconta  -- Nr. da conta
                                        ,pr_tipotari => 17                   -- Tipo de tarifa
                                        ,pr_tipostaa => 0                    -- Tipo TAA
                                        ,pr_qtoperac => 1                    -- Qtd. de operações
                                        ,pr_qtacobra => vr_qtacobra          -- Qtd. de operações cobradas
                                        ,pr_fliseope => vr_fliseope          -- Flag de isenção de operações 0 - não isenta/ 1 - isenta
                                        ,pr_cdcritic => vr_cdcritic          -- Cód. da crítica
                                        ,pr_dscritic => vr_dscritic);        -- Desc. da crítica

    -- Se ocorreu erro
    IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '||
                                                    gene0002.fn_mask_conta(rw_crapbdc.nrdconta)||'- '
                                                 || vr_dscritic );
      -- Limpa valores das variaveis de critica
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

    ELSE

      /* Se não isenta tarifa */
      IF vr_fliseope <> 1 THEN

      -- Criar Lançamento automatico Tarifas de contrato de desconto de cheques
      TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                      , pr_nrdconta     => rw_crapbdc.nrdconta
                                      , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                      , pr_cdhistor     => vr_cdhistor
                                      , pr_vllanaut     => vr_vltarifa
                                      , pr_cdoperad     => '1'
                                      , pr_cdagenci     => 1
                                      , pr_cdbccxlt     => 100
                                      , pr_nrdolote     => 10028
                                      , pr_tpdolote     => 1
                                      , pr_nrdocmto     => 0
                                      , pr_nrdctabb     => rw_crapbdc.nrdconta
                                      , pr_nrdctitg     => gene0002.fn_mask(rw_crapbdc.nrdconta,'99999999')
                                      , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapbdc.nrborder)
                                      , pr_cdbanchq     => 0
                                      , pr_cdagechq     => 0
                                      , pr_nrctachq     => 0
                                      , pr_flgaviso     => TRUE
                                      , pr_tpdaviso     => 2
                                      , pr_cdfvlcop     => vr_cdfvlcop
                                      , pr_inproces     => rw_crapdat.inproces
                                      , pr_rowid_craplat=> vr_rowid
                                      , pr_tab_erro     => vr_tab_erro
                                      , pr_cdcritic     => vr_cdcritic
                                      , pr_dscritic     => vr_dscritic
                                      );
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro no lancamento Tarifa de contrato de desconto de cheques';
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '||
                                                      gene0002.fn_mask_conta(rw_crapbdc.nrdconta)||'- '
                                                   || vr_dscritic );
        -- Limpa valores das variaveis de critica
        vr_cdcritic:= 0;
        vr_dscritic:= NULL;
      END IF;
      END IF;
    END IF;

    -- 1 - Pessoa Fisica
    IF rw_crapbdc.inpessoa = 1 THEN
       vr_cdbattar := 'DSCCHQCHPF';  -- Tarifa de Cheque Descontado Pessoa Fisica
    ELSE
       vr_cdbattar := 'DSCCHQCHPJ';  -- Tarifa de Cheque Descontado Pessoa Juridica
    END IF;

    -- Inicializa Variaveis de Tarifa
    vr_vltarifa := 0;
    vr_cdhistor := 0;
    vr_cdfvlcop := 0;

    -- Verifica se existe o registro na PL/TABLE
    IF vr_tab_tarifa.EXISTS(vr_cdbattar) THEN

      vr_vltarifa := vr_tab_tarifa(vr_cdbattar).vltarifa;
      vr_cdhistor := vr_tab_tarifa(vr_cdbattar).cdhistor;
      vr_cdfvlcop := vr_tab_tarifa(vr_cdbattar).cdfvlcop;

    END IF;

    -- Verifica se valor da não esta zerado
    IF vr_vltarifa > 0 THEN

      -- Verifica Existencia de Lote
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => rw_crapbdc.dtmvtolt
                     ,pr_cdagenci => rw_crapbdc.cdagenci
                     ,pr_cdbccxlt => rw_crapbdc.cdbccxlt
                     ,pr_nrdolote => rw_crapbdc.nrdolote);
      FETCH cr_craplot INTO rw_craplot;

      -- Se não encontrou lote
      IF cr_craplot%NOTFOUND THEN

        -- Monta critica a ser exibida no Log
        vr_dscritic :=  'LOTE NAO ENCONTRADO ' ||
                        to_char(rw_crapbdc.dtmvtolt) || '-' ||
                        to_char(rw_crapbdc.cdagenci) || '-' ||
                        to_char(rw_crapbdc.cdbccxlt) || '-' ||
                        to_char(rw_crapbdc.nrdolote);

        --Fechar Cursor
        CLOSE cr_craplot;

        -- Gera Log
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro Tratado
                                   pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                      ' -' || vr_cdprogra || ' --> '  ||
                                                      vr_dscritic);
        -- Limpa valores das variaveis de critica
        vr_cdcritic:= 0;
        vr_dscritic:= NULL;

        -- Proximo registro
        CONTINUE;
      END IF;

      -- Fechar Cursor
      CLOSE cr_craplot;

      -- Criar Lançamento automatico Tarifa de Cheque Descontado
      TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                      , pr_nrdconta     => rw_crapbdc.nrdconta
                                      , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                      , pr_cdhistor     => vr_cdhistor
                                      , pr_vllanaut     => vr_vltarifa * rw_craplot.qtcompln
                                      , pr_cdoperad     => '1'
                                      , pr_cdagenci     => 1
                                      , pr_cdbccxlt     => 100
                                      , pr_nrdolote     => 10028
                                      , pr_tpdolote     => 1
                                      , pr_nrdocmto     => 0
                                      , pr_nrdctabb     => rw_crapbdc.nrdconta
                                      , pr_nrdctitg     => gene0002.fn_mask(rw_crapbdc.nrdconta,'99999999')
                                      , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapbdc.nrborder)
                                      , pr_cdbanchq     => 0
                                      , pr_cdagechq     => 0
                                      , pr_nrctachq     => 0
                                      , pr_flgaviso     => TRUE
                                      , pr_tpdaviso     => 2
                                      , pr_cdfvlcop     => vr_cdfvlcop
                                      , pr_inproces     => rw_crapdat.inproces
                                      , pr_rowid_craplat=> vr_rowid
                                      , pr_tab_erro     => vr_tab_erro
                                      , pr_cdcritic     => vr_cdcritic
                                      , pr_dscritic     => vr_dscritic);
      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro no lancamento Tarifa de Cheque Descontad';
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '||
                                                      gene0002.fn_mask_conta(rw_crapbdc.nrdconta)||'- '
                                                   || vr_dscritic );
        -- Limpa valores das variaveis de critica
        vr_cdcritic:= 0;
        vr_dscritic:= NULL;
      END IF;

    END IF;

  END LOOP;  -- Final Leitura crapbdc

  -- Tarifas de Cheques Resgatados
  FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

    -- Caso rw_crapcdb.inpessoa for igual a 0 significa que não
    -- encontrou nem um associado com o valor de rw_crapcdb.nrdconta
    -- Neste caso iremos logar critica 9 e pular para o proximo registro
    IF rw_crapcdb.inpessoa = 0 THEN
      vr_cdcritic:= 9;
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                    gene0002.fn_mask(rw_crapcdb.nrdconta,'zzzz.zzz.9');

      -- Gera Log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro Tratado
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                    ' -' || vr_cdprogra || ' --> '  ||
                                                    vr_dscritic);

      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;

      -- Proximo Registro
      CONTINUE;
    END IF;

    IF rw_crapcdb.inpessoa = 1 THEN
      vr_cdbattar := 'DSCCHQRSPF';  -- Tarifa de Resgate de Cheque Pessoa Fisica
    ELSE
      vr_cdbattar := 'DSCCHQRSPJ';  -- Tarifa de Resgate de Cheque Pessoa Juridica
    END IF;

    -- Busca valor da tarifa
    TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                         ,pr_cdbattar => vr_cdbattar
                                         ,pr_vllanmto => rw_crapcdb.vlcheque
                                         ,pr_cdprogra => vr_cdprogra
                                         ,pr_cdhistor => vr_cdhistor
                                         ,pr_cdhisest => vr_cdhisest
                                         ,pr_vltarifa => vr_vltarifa
                                         ,pr_dtdivulg => vr_dtdivulg
                                         ,pr_dtvigenc => vr_dtvigenc
                                         ,pr_cdfvlcop => vr_cdfvlcop
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_tab_erro => vr_tab_erro);

    -- Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Se possui erro no vetor
      IF vr_tab_erro.Count() > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
      END IF;
      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic || ' - ' || vr_cdbattar);
      -- Efetua Limpeza das variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;

      -- Se não Existe Tarifa
      CONTINUE;
    END IF;

    /* Verifica se valor da tarifa esta zerado*/
    IF  vr_vltarifa = 0  THEN
        CONTINUE;
    END IF;

    -- Criar Lançamento automatico Tarifas de contrato de desconto de cheques
    TARI0001.pc_cria_lan_auto_tarifa( pr_cdcooper     => pr_cdcooper
                                    , pr_nrdconta     => rw_crapcdb.nrdconta
                                    , pr_dtmvtolt     => rw_crapdat.dtmvtolt
                                    , pr_cdhistor     => vr_cdhistor
                                    , pr_vllanaut     => vr_vltarifa
                                    , pr_cdoperad     => '1'
                                    , pr_cdagenci     => 1
                                    , pr_cdbccxlt     => 100
                                    , pr_nrdolote     => 10028
                                    , pr_tpdolote     => 1
                                    , pr_nrdocmto     => 0
                                    , pr_nrdctabb     => rw_crapcdb.nrdconta
                                    , pr_nrdctitg     => gene0002.fn_mask(rw_crapcdb.nrdconta,'99999999')
                                    , pr_cdpesqbb     => 'Fato gerador tarifa:' || TO_CHAR(rw_crapcdb.nrcheque)
                                    , pr_cdbanchq     => 0
                                    , pr_cdagechq     => 0
                                    , pr_nrctachq     => 0
                                    , pr_flgaviso     => TRUE
                                    , pr_tpdaviso     => 2
                                    , pr_cdfvlcop     => vr_cdfvlcop
                                    , pr_inproces     => rw_crapdat.inproces
                                    , pr_rowid_craplat=> vr_rowid
                                    , pr_tab_erro     => vr_tab_erro
                                    , pr_cdcritic     => vr_cdcritic
                                    , pr_dscritic     => vr_dscritic
                                    );
    -- Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Se possui erro no vetor
      IF vr_tab_erro.Count > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro no lancamento Tarifa de contrato de desconto de cheques';
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '||
                                                    gene0002.fn_mask_conta(rw_crapcdb.nrdconta)||'- '
                                                 || vr_dscritic );
      -- Limpa valores das variaveis de critica
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
    END IF;

  END LOOP; -- Final Loop crapcdb

  -- Processo OK, devemos chamar a fimprg
  BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN

    -- Se retornou apenas o codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Busca Descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerado critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

      -- Envio Centralizado de Log de Erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- ERRO TRATATO
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' -' || vr_cdprogra || ' --> ' ||
                                                    vr_dscritic);

    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no banco de dados
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END pc_crps344;
/

