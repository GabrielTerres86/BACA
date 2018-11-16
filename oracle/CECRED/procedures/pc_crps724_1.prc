CREATE OR REPLACE PROCEDURE CECRED.pc_crps724_1(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                               ,pr_idparale  IN crappar.idparale%TYPE     --> Indicador de processo paralelo
                                               ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo Agencia
                                               ,pr_cdrestart IN tbgen_batch_controle.cdrestart%TYPE --> Controle do registro de restart em caso de erro na execucao
                                               ,pr_qtdexec   IN NUMBER DEFAULT 1          --> numero da execucao no dia (debitador unico)
                                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                               ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps724_1
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jaison
     Data    : Agosto/2017                     Ultima atualizacao: 28/09/2018 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Pagar as parcelas dos contratos do produto Pos-Fixado.

     Alteracoes: 
     29/08/2018 - permitir executar mais de uma vez e deve paralelizar somente na primeira execucao.
                - Projeto Debitador Unico - Fabiano B. Dias (AMcom).
	   28/09/2018 - Incluir validacao de pos-fixado com acordo ativo (Adriano Nagasava - Supero)

  ............................................................................ */

  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Codigo do programa
    vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'CRPS724';

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);
    vr_des_reto  VARCHAR2(3);

    ------------------------------- CURSORES ---------------------------------

    -- Cursor generico de calendario
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca os dados dos contratos e parcelas
    CURSOR cr_epr_pep(pr_cdcooper  IN crapcop.cdcooper%TYPE
                     ,pr_cdagenci  IN crapage.cdagenci%TYPE
                     ,pr_cdrestart IN tbgen_batch_controle.cdrestart%TYPE) IS
      SELECT crapepr.dtmvtolt
            ,crapepr.cdagenci
            ,crapepr.nrdconta
            ,crapepr.nrctremp
            ,crapepr.tpemprst
            ,crapepr.cdlcremp
            ,crapepr.vlpreemp
            ,crapepr.qtprepag
            ,crapepr.qtprecal
            ,crapepr.dtrefjur
            ,crapepr.diarefju
            ,crapepr.mesrefju
            ,crapepr.anorefju
            ,crapepr.txmensal
            ,crapepr.txjuremp
            ,crapepr.vlsprojt
            ,crapepr.qttolatr
            ,crappep.nrparepr
            ,crappep.vlparepr
            ,crappep.dtvencto
            ,crappep.vlsdvpar
            ,crappep.vlsdvatu
            ,crappep.vljura60
            ,crappep.dtultpag
            ,crappep.vlpagmta
            ,crappep.vltaxatu
            ,crappep.vlpagpar
            ,crappep.vldstrem
            ,crappep.vldstcor
            ,crappep.dtdstjur
            ,crapass.vllimcre
            ,crawepr.dtdpagto
            ,crapepr.dtrefcor
            ,crapepr.idfiniof
            ,crapepr.vlemprst
            ,ROW_NUMBER() OVER (PARTITION BY crapepr.nrdconta, crapepr.nrctremp ORDER BY crapepr.cdcooper, crapepr.nrdconta, crappep.nrctremp, crappep.nrparepr) AS numconta
            ,COUNT(1) OVER (PARTITION BY crapepr.nrdconta, crapepr.nrctremp) qtdconta
        FROM crapepr
        JOIN crawepr
          ON crawepr.cdcooper = crapepr.cdcooper
         AND crawepr.nrdconta = crapepr.nrdconta
         AND crawepr.nrctremp = crapepr.nrctremp
        JOIN crappep
          ON crappep.cdcooper = crapepr.cdcooper
         AND crappep.nrdconta = crapepr.nrdconta
         AND crappep.nrctremp = crapepr.nrctremp
        JOIN crapass
          ON crapass.cdcooper = crapepr.cdcooper
         AND crapass.nrdconta = crapepr.nrdconta
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.cdagenci = decode(pr_cdagenci, 0, crapepr.cdagenci, pr_cdagenci) -- 29/08/2018. 
         AND crapepr.nrdconta > NVL(pr_cdrestart,0)
         AND crapepr.tpemprst = 2 -- Pos-Fixado
         AND crappep.inliquid = 0 -- Pendente
    ORDER BY crappep.cdcooper
            ,crappep.nrdconta
            ,crappep.nrctremp
            ,crappep.nrparepr;
    
    -- Busca os dados da linha de credito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE) IS
      SELECT cdlcremp
            ,dsoperac
            ,perjurmo
            ,flgcobmu
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND tpprodut = 2;

    CURSOR cr_craplem (pr_cdcooper IN craplem.cdcooper%TYPE
                      ,pr_nrdconta IN craplem.nrdconta%TYPE
                      ,pr_nrctremp IN craplem.nrctremp%TYPE
                      ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
      SELECT 1
        FROM craplem
       WHERE craplem.cdcooper = pr_cdcooper
         AND craplem.nrdconta = pr_nrdconta
         AND craplem.nrctremp = pr_nrctremp
         AND craplem.dtmvtolt = pr_dtmvtolt
         AND craplem.cdhistor IN (2343,2342,2345,2344);
    rw_craplem cr_craplem%ROWTYPE;
        
   -- Consulta contratos ativos de acordos
   CURSOR cr_ctr_acordo IS
		 SELECT tbrecup_acordo_contrato.nracordo
					 ,tbrecup_acordo.cdcooper
					 ,tbrecup_acordo.nrdconta
					 ,tbrecup_acordo_contrato.nrctremp
			 FROM tbrecup_acordo_contrato
			 JOIN tbrecup_acordo
				 ON tbrecup_acordo.nracordo   = tbrecup_acordo_contrato.nracordo
			WHERE tbrecup_acordo.cdsituacao = 1
				AND tbrecup_acordo_contrato.cdorigem IN (2,3);
		rw_ctr_acordo cr_ctr_acordo%ROWTYPE;
		
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- Definicao do tipo da tabela para linhas de credito
    TYPE typ_reg_craplcr IS
     RECORD(dsoperac craplcr.dsoperac%TYPE,
            perjurmo craplcr.perjurmo%TYPE,
            flgcobmu craplcr.flgcobmu%TYPE);	
    TYPE typ_tab_craplcr IS
      TABLE OF typ_reg_craplcr
        INDEX BY PLS_INTEGER; -- Codigo da Linha
    -- Vetor para armazenar os dados de Linha de Credito
    vr_tab_craplcr typ_tab_craplcr;
    
    -- Definicao do tipo da tabela para controlar as parcelas que precisam ser processadas
    TYPE typ_tab_controle_lcto_juros IS
      TABLE OF BOOLEAN
        INDEX BY VARCHAR2(20); --> O número da conta + nr contrato serão as chaves
    vr_tab_controle_lcto_juros typ_tab_controle_lcto_juros;

    /* Contratos de acordo */
    TYPE typ_tab_acordo IS TABLE OF NUMBER(10) INDEX BY VARCHAR2(30);
    vr_tab_acordo   typ_tab_acordo;
		
    ------------------------------- VARIAVEIS -------------------------------
    vr_flgachou          BOOLEAN;
    vr_blnachou          BOOLEAN;
    vr_floperac          BOOLEAN;
    vr_flmensal          BOOLEAN;
    vr_infimsol          PLS_INTEGER;
    vr_stprogra          PLS_INTEGER;
    vr_vlsldisp          NUMBER;
    vr_vlpagpar          NUMBER;
    vr_percmult          NUMBER(25,2);
    vr_vljuremu          NUMBER(25,2);
    vr_vljurcor          NUMBER(25,2);
    vr_dstextab          craptab.dstextab%TYPE;
    vr_txdiaria          craplcr.txdiaria%TYPE;
    vr_dsctactrjud       crapprm.dsvlrprm%TYPE := NULL;
    vr_qtdconta          INTEGER;
    vr_ultconta          INTEGER;
    vr_idcontrole        tbgen_batch_controle.idcontrole%TYPE;
    vr_dtvencto_niv      crappep.dtvencto%TYPE;
    vr_diarefju          crapepr.diarefju%TYPE;
    vr_mesrefju          crapepr.mesrefju%TYPE;
    vr_anorefju          crapepr.anorefju%TYPE;
    vr_index_controle    VARCHAR2(20);

		vr_cdindice VARCHAR2(30) := ''; -- Indice da tabela de acordos

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Grava os dados dos pagamentos e controle do batch
    PROCEDURE pc_grava_dados(pr_cdrestart IN tbgen_batch_controle.cdrestart%TYPE) IS -- Controle do registro de restart em caso de erro na execucao
    BEGIN
      -- Grava agencia no controle do batch
      GENE0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper
                                      ,pr_cdprogra    => vr_cdprogra
                                      ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                      ,pr_tpagrupador => 1 -- PA
                                      ,pr_cdagrupador => pr_cdagenci
                                      ,pr_cdrestart   => pr_cdrestart
                                      ,pr_nrexecucao  => pr_qtdexec
                                      ,pr_idcontrole  => vr_idcontrole
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      COMMIT;
    END pc_grava_dados;

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                              ,pr_action => 'PC_' || vr_cdprogra || '_1');

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- Leitura do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    vr_flgachou := BTCH0001.cr_crapdat%FOUND;
    CLOSE BTCH0001.cr_crapdat;
    -- Se nao achou
    IF NOT vr_flgachou THEN
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    END IF;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => vr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se possui erro
    IF vr_cdcritic <> 0 THEN
      RAISE vr_exc_saida;
    END IF;

    -- Incializar controle
    IF nvl(pr_cdrestart,0) = 0 THEN
      pc_grava_dados(pr_cdrestart => 0);
    END IF;  

    -- Limpar tabela de memoria
    vr_tab_craplcr.DELETE;
    vr_tab_controle_lcto_juros.DELETE;
    
    -- Obter o % de multa da CECRED - TAB090
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3 -- Fixo 3 - Cecred
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'PAREMPCTL'
                                             ,pr_tpregist => 01);
    IF vr_dstextab IS NULL THEN
      vr_cdcritic := 55;
      RAISE vr_exc_saida;
    END IF;

    -- Lista de contas e contratos especificos que nao podem debitar os emprestimos (formato="(cta,ctr)") SD#618307
    vr_dsctactrjud := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_cdacesso => 'CTA_CTR_ACAO_JUDICIAL');

    -- Carregar linhas de credito
    FOR rw_craplcr IN cr_craplcr(pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_craplcr(rw_craplcr.cdlcremp).dsoperac := rw_craplcr.dsoperac;
      vr_tab_craplcr(rw_craplcr.cdlcremp).perjurmo := rw_craplcr.perjurmo;
      vr_tab_craplcr(rw_craplcr.cdlcremp).flgcobmu := rw_craplcr.flgcobmu;
    END LOOP;

		-- Carregar Contratos de Acordos
    FOR rw_ctr_acordo IN cr_ctr_acordo LOOP
      vr_cdindice := LPAD(rw_ctr_acordo.cdcooper,10,'0') || LPAD(rw_ctr_acordo.nrdconta,10,'0') ||
                     LPAD(rw_ctr_acordo.nrctremp,10,'0');
      vr_tab_acordo(vr_cdindice) := rw_ctr_acordo.nracordo;
    END LOOP;

    -- Reseta variaveis
    vr_qtdconta := 0;
    vr_ultconta := 0;

    -- Listagem dos contratos e parcelas
    FOR rw_epr_pep IN cr_epr_pep(pr_cdcooper  => pr_cdcooper
                                ,pr_cdagenci  => pr_cdagenci
                                ,pr_cdrestart => pr_cdrestart) LOOP

      -- Se NAO achou a linha de credito
      IF NOT vr_tab_craplcr.EXISTS(rw_epr_pep.cdlcremp) THEN
        vr_cdcritic := 363;
        RAISE vr_exc_saida;
      END IF;

      -- Trava para nao cobrar as parcelas desta conta e contrato especifico pelo motivo de uma acao judicial SD#618307
      IF INSTR(REPLACE(vr_dsctactrjud,' '),'('||TRIM(TO_CHAR(rw_epr_pep.nrdconta))||','||TRIM(TO_CHAR(rw_epr_pep.nrctremp))||')') > 0 THEN
        CONTINUE;
      END IF;      
      
      -- Se for a Mensal
      vr_flmensal := (TO_CHAR(rw_crapdat.dtmvtolt, 'MM') <> TO_CHAR(rw_crapdat.dtmvtopr, 'MM'));
      -- Se for Financiamento
      vr_floperac := (vr_tab_craplcr(rw_epr_pep.cdlcremp).dsoperac = 'FINANCIAMENTO');
      -- Calcula a taxa diaria
      vr_txdiaria := POWER(1 + (NVL(rw_epr_pep.txmensal,0) / 100),(1 / 30)) - 1;
      
      -------------------------------------------------------------------------------------------------------------
      -- Parcela em dia
      -------------------------------------------------------------------------------------------------------------
      IF rw_epr_pep.dtvencto > rw_crapdat.dtmvtoan AND rw_epr_pep.dtvencto <= rw_crapdat.dtmvtolt THEN
        -- Chama validacao generica
        EMPR0011.pc_valida_pagamentos_pos(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_epr_pep.nrdconta
                                         ,pr_cdagenci => rw_epr_pep.cdagenci
                                         ,pr_nrdcaixa => 0
                                         ,pr_cdoperad => 1
                                         ,pr_rw_crapdat => rw_crapdat
                                         ,pr_tpemprst => rw_epr_pep.tpemprst
                                         ,pr_dtlibera => rw_epr_pep.dtmvtolt
                                         ,pr_vllimcre => rw_epr_pep.vllimcre
                                         ,pr_flgcrass => TRUE
                                         ,pr_nrctrliq_1 => 0
                                         ,pr_nrctrliq_2 => 0
                                         ,pr_nrctrliq_3 => 0
                                         ,pr_nrctrliq_4 => 0
                                         ,pr_nrctrliq_5 => 0
                                         ,pr_nrctrliq_6 => 0
                                         ,pr_nrctrliq_7 => 0
                                         ,pr_nrctrliq_8 => 0
                                         ,pr_nrctrliq_9 => 0
                                         ,pr_nrctrliq_10 => 0
                                         ,pr_vlapagar => rw_epr_pep.vlparepr
                                         ,pr_vlsldisp => vr_vlsldisp
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
              
				-- Valida se o contrato possui acordo ativo
				vr_cdindice := LPAD(pr_cdcooper,10,'0') || LPAD(rw_epr_pep.nrdconta,10,'0') || LPAD(rw_epr_pep.nrctremp,10,'0');
				--
				IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
          --
					vr_vlsldisp := 0;
					--
        END IF;
              
        -- Recebe o saldo devedor da parcela
        vr_vlpagpar := rw_epr_pep.vlsdvpar;
        -- Condicao para verifica o valor pago da parcela
        IF NVL(vr_vlpagpar,0) > NVL(vr_vlsldisp,0) THEN
          vr_vlpagpar := vr_vlsldisp;
        END IF;

        -- Efetua o pagamento da parcela em Dia
        EMPR0011.pc_efetua_pagamento_em_dia(pr_cdcooper => pr_cdcooper
                                           ,pr_cdprogra => vr_cdprogra
                                           ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => rw_epr_pep.cdagenci
                                           ,pr_cdpactra => rw_epr_pep.cdagenci
                                           ,pr_cdoperad => 1
                                           ,pr_cdorigem => 7 -- BATCH
                                           ,pr_flgbatch => TRUE
                                           ,pr_nrdconta => rw_epr_pep.nrdconta
                                           ,pr_nrctremp => rw_epr_pep.nrctremp
                                           ,pr_vlpreemp => rw_epr_pep.vlpreemp
                                           ,pr_qtprepag => rw_epr_pep.qtprepag
                                           ,pr_qtprecal => rw_epr_pep.qtprecal
                                           ,pr_dtlibera => rw_epr_pep.dtmvtolt
                                           ,pr_dtrefjur => rw_epr_pep.dtrefjur
                                           ,pr_diarefju => rw_epr_pep.diarefju
                                           ,pr_mesrefju => rw_epr_pep.mesrefju
                                           ,pr_anorefju => rw_epr_pep.anorefju
                                           ,pr_vlrdtaxa => rw_epr_pep.vltaxatu
                                           ,pr_txdiaria => vr_txdiaria
                                           ,pr_txjuremp => rw_epr_pep.txjuremp
                                           ,pr_vlsprojt => rw_epr_pep.vlsprojt
                                           ,pr_floperac => vr_floperac
                                           ,pr_nrseqava => 0
                                           ,pr_nrparepr => rw_epr_pep.nrparepr
                                           ,pr_dtvencto => rw_epr_pep.dtvencto
                                           ,pr_vlpagpar => vr_vlpagpar
                                           ,pr_vlsdvpar => rw_epr_pep.vlsdvpar
                                           ,pr_vlsdvatu => rw_epr_pep.vlsdvatu
                                           ,pr_vljura60 => rw_epr_pep.vljura60
                                           ,pr_ehmensal => vr_flmensal
                                           ,pr_vlsldisp => vr_vlsldisp
                                           ,pr_dtrefcor => rw_epr_pep.dtrefcor
                                           ,pr_txmensal => rw_epr_pep.txmensal
                                           ,pr_dtdstjur => rw_epr_pep.dtdstjur
                                           ,pr_vlpagpar_atu => NVL(rw_epr_pep.vlpagpar,0) + 
                                                               NVL(rw_epr_pep.vldstrem,0) + 
                                                               NVL(rw_epr_pep.vldstcor,0)
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      ---------------------
      -- Parcela Vencida --
      ---------------------
      ELSIF rw_epr_pep.dtvencto < rw_crapdat.dtmvtolt THEN
        -- Chama validacao generica
        EMPR0011.pc_valida_pagamentos_pos(pr_cdcooper   => pr_cdcooper
                                         ,pr_nrdconta   => rw_epr_pep.nrdconta
                                         ,pr_cdagenci   => rw_epr_pep.cdagenci
                                         ,pr_nrdcaixa   => 0
                                         ,pr_cdoperad   => 1
                                         ,pr_rw_crapdat => rw_crapdat
                                         ,pr_tpemprst   => rw_epr_pep.tpemprst
                                         ,pr_dtlibera   => rw_epr_pep.dtmvtolt
                                         ,pr_vllimcre   => rw_epr_pep.vllimcre
                                         ,pr_flgcrass   => TRUE
                                         ,pr_nrctrliq_1 => 0
                                         ,pr_nrctrliq_2 => 0
                                         ,pr_nrctrliq_3 => 0
                                         ,pr_nrctrliq_4 => 0
                                         ,pr_nrctrliq_5 => 0
                                         ,pr_nrctrliq_6 => 0
                                         ,pr_nrctrliq_7 => 0
                                         ,pr_nrctrliq_8 => 0
                                         ,pr_nrctrliq_9 => 0
                                         ,pr_nrctrliq_10 => 0
                                         ,pr_vlapagar => rw_epr_pep.vlparepr
                                         ,pr_vlsldisp => vr_vlsldisp
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
				
				-- Valida se o contrato possui acordo ativo
				vr_cdindice := LPAD(pr_cdcooper,10,'0') || LPAD(rw_epr_pep.nrdconta,10,'0') || LPAD(rw_epr_pep.nrctremp,10,'0');
				--
				IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
          --
					vr_vlsldisp := 0;
					--
        END IF;

        -- Se NAO possuir saldo, pula o registro
        IF NVL(vr_vlsldisp, 0) <= 0 THEN
          CONTINUE;
        END IF;

        -- Verifica se tem uma parcela anterior nao liquida e ja vencida
        EMPR0001.pc_verifica_parcel_anteriores(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                              ,pr_nrdconta => rw_epr_pep.nrdconta --> Numero da conta
                                              ,pr_nrctremp => rw_epr_pep.nrctremp --> Numero do contrato de emprestimo
                                              ,pr_nrparepr => rw_epr_pep.nrparepr --> Numero parcelas emprestimo
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                              ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                              ,pr_dscritic => vr_dscritic);       --> Descricao Erro
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          CONTINUE;
        END IF;

        -- Verifica se a Linha de Credito Cobra Multa
        IF vr_tab_craplcr(rw_epr_pep.cdlcremp).flgcobmu = 1 THEN
          -- Utilizar como % de multa, as 6 primeiras posicoes encontradas
          vr_percmult := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
        ELSE
          vr_percmult := 0;
        END IF;

        -- Efetua o pagamento da parcela Vencida
        EMPR0011.pc_efetua_pagamento_em_atraso(pr_cdcooper => pr_cdcooper
                                              ,pr_cdprogra => vr_cdprogra
                                              ,pr_dtcalcul => rw_crapdat.dtmvtolt
                                              ,pr_cdagenci => rw_epr_pep.cdagenci
                                              ,pr_cdpactra => rw_epr_pep.cdagenci
                                              ,pr_cdoperad => 1
                                              ,pr_cdorigem => 7 -- BATCH
                                              ,pr_flgbatch => TRUE
                                              ,pr_nrdconta => rw_epr_pep.nrdconta
                                              ,pr_nrctremp => rw_epr_pep.nrctremp
                                              ,pr_vlpreemp => rw_epr_pep.vlpreemp
                                              ,pr_qtprepag => rw_epr_pep.qtprepag
                                              ,pr_qtprecal => rw_epr_pep.qtprecal
                                              ,pr_txjuremp => rw_epr_pep.txjuremp
                                              ,pr_qttolatr => rw_epr_pep.qttolatr
                                              ,pr_floperac => vr_floperac
                                              ,pr_nrseqava => 0
                                              ,pr_cdlcremp => rw_epr_pep.cdlcremp
                                              ,pr_nrparepr => rw_epr_pep.nrparepr
                                              ,pr_dtvencto => rw_epr_pep.dtvencto
                                              ,pr_dtultpag => rw_epr_pep.dtultpag
                                              ,pr_vlparepr => rw_epr_pep.vlparepr
                                              ,pr_vlpagpar => vr_vlsldisp
                                              ,pr_vlsdvpar => rw_epr_pep.vlsdvpar
                                              ,pr_vlsdvatu => rw_epr_pep.vlsdvatu
                                              ,pr_vljura60 => rw_epr_pep.vljura60
                                              ,pr_vlpagmta => rw_epr_pep.vlpagmta
                                              ,pr_perjurmo => vr_tab_craplcr(rw_epr_pep.cdlcremp).perjurmo
                                              ,pr_percmult => vr_percmult
                                              ,pr_txmensal => rw_epr_pep.txmensal
                                              ,pr_idfiniof => rw_epr_pep.idfiniof
                                              ,pr_vlemprst => rw_epr_pep.vlemprst
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
      ---------------------
      -- Parcela Vencer --
      ---------------------  
      ELSE
        -------------------------------------------------------------------------------------------------------------
        -- INICIO -- Na data de aniversario da parcela devera ser lancado Juros Remuneratorio e Juros de Correcao
        -------------------------------------------------------------------------------------------------------------
        vr_dtvencto_niv := TO_DATE(TO_CHAR(rw_epr_pep.dtvencto,'DD')||'/'||TO_CHAR(rw_crapdat.dtmvtolt,'MM')||'/'||TO_CHAR(rw_crapdat.dtmvtolt,'RRRR'),'DD/MM/RRRR');
        IF vr_dtvencto_niv > rw_crapdat.dtmvtoan AND vr_dtvencto_niv <= rw_crapdat.dtmvtolt THEN
          -- Condicao para verificar se a parcela ja foi lancado Juros
          vr_index_controle := LPAD(rw_epr_pep.nrdconta,10,'0') || LPAD(rw_epr_pep.nrctremp,10,'0');
          IF vr_tab_controle_lcto_juros.EXISTS(vr_index_controle) THEN
            CONTINUE;
          END IF;

          -- Tab de controle para somente lancar juros para uma parcela por contrato
          vr_tab_controle_lcto_juros(vr_index_controle) := TRUE;
          
          -- Condicao para verificar se jah foi lancado Juros Remuneratorio e Juros Correcao
          OPEN cr_craplem(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_epr_pep.nrdconta
                         ,pr_nrctremp => rw_epr_pep.nrctremp
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
          FETCH cr_craplem INTO rw_craplem;
          vr_blnachou := cr_craplem%FOUND;
          CLOSE cr_craplem;
          -- Se NAO achou
          IF vr_blnachou THEN
            CONTINUE;
          END IF;          

          vr_diarefju := rw_epr_pep.diarefju;
          vr_mesrefju := rw_epr_pep.mesrefju;
          vr_anorefju := rw_epr_pep.anorefju;          
          -- Efetua o lancamento de Juros Remuneratorio
          EMPR0011.pc_efetua_lcto_juros_remun(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => rw_epr_pep.cdagenci
                                             ,pr_cdpactra => rw_epr_pep.cdagenci
                                             ,pr_cdoperad => 1
                                             ,pr_cdorigem => 7 -- BATCH
                                             ,pr_nrdconta => rw_epr_pep.nrdconta
                                             ,pr_nrctremp => rw_epr_pep.nrctremp
                                             ,pr_txjuremp => rw_epr_pep.txjuremp
                                             ,pr_vlpreemp => rw_epr_pep.vlpreemp
                                             ,pr_dtlibera => rw_epr_pep.dtmvtolt
                                             ,pr_dtrefjur => rw_epr_pep.dtrefjur
                                             ,pr_floperac => vr_floperac
                                             ,pr_dtvencto => vr_dtvencto_niv
                                             ,pr_insitpar => 1
                                             ,pr_vlsprojt => rw_epr_pep.vlsprojt
                                             ,pr_ehmensal => vr_flmensal
                                             ,pr_txdiaria => vr_txdiaria
                                             ,pr_nrparepr => rw_epr_pep.nrparepr
                                             ,pr_diarefju => vr_diarefju
                                             ,pr_mesrefju => vr_mesrefju
                                             ,pr_anorefju => vr_anorefju
                                             ,pr_vljuremu => vr_vljuremu
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- Efetuar o lancameto de Juros de Correcao
          EMPR0011.pc_efetua_lcto_juros_correc (pr_cdcooper => pr_cdcooper
                                               ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                               ,pr_cdagenci => rw_epr_pep.cdagenci
                                               ,pr_cdpactra => rw_epr_pep.cdagenci
                                               ,pr_cdoperad => 1
                                               ,pr_cdorigem => 7 -- BATCH
                                               ,pr_flgbatch => TRUE
                                               ,pr_nrdconta => rw_epr_pep.nrdconta
                                               ,pr_nrctremp => rw_epr_pep.nrctremp
                                               ,pr_dtlibera => rw_epr_pep.dtmvtolt
                                               ,pr_dtrefjur => rw_epr_pep.dtrefjur
                                               ,pr_diarefju => rw_epr_pep.diarefju
                                               ,pr_mesrefju => rw_epr_pep.mesrefju
                                               ,pr_anorefju => rw_epr_pep.anorefju
                                               ,pr_vlrdtaxa => rw_epr_pep.vltaxatu
                                               ,pr_txjuremp => rw_epr_pep.txjuremp
                                               ,pr_vlpreemp => rw_epr_pep.vlpreemp
                                               ,pr_dtvencto => vr_dtvencto_niv
                                               ,pr_insitpar => 1
                                               ,pr_vlsprojt => rw_epr_pep.vlsprojt
                                               ,pr_ehmensal => vr_flmensal
                                               ,pr_floperac => vr_floperac
                                               ,pr_nrparepr => rw_epr_pep.nrparepr
                                               ,pr_dtrefcor => rw_epr_pep.dtrefcor
                                               ,pr_vljurcor => vr_vljurcor
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          -- Atualizar Emprestimo
          BEGIN
            UPDATE crapepr
               SET crapepr.dtrefjur = rw_crapdat.dtmvtolt
                  ,crapepr.diarefju = vr_diarefju
                  ,crapepr.mesrefju = vr_mesrefju
                  ,crapepr.anorefju = vr_anorefju
                  ,crapepr.dtrefcor = rw_crapdat.dtmvtolt
                  ,crapepr.vlsdeved = NVL(crapepr.vlsdeved,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0)
                  ,crapepr.vljuratu = NVL(crapepr.vljuratu,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0)
                  ,crapepr.vljuracu = NVL(crapepr.vljuracu,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0)
             WHERE crapepr.cdcooper = pr_cdcooper
               AND crapepr.nrdconta = rw_epr_pep.nrdconta
               AND crapepr.nrctremp = rw_epr_pep.nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar crapepr'   ||
                             '. Coop.: '    || pr_cdcooper || 
                             '. Conta: '    || rw_epr_pep.nrdconta ||
                             '. Contrato: ' || rw_epr_pep.nrctremp || 
                             '. ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
          
        END IF;
        -------------------------------------------------------------------------------------------------------------
        -- FIM -- Na data de aniversario da parcela devera ser lancado Juros Remuneratorio e Juros de Correcao
        -------------------------------------------------------------------------------------------------------------
        
      END IF; -- Parcela a Vencer

      -- Faz a liquidacao do contrato
      EMPR0011.pc_efetua_liquidacao_empr_pos(pr_cdcooper   => pr_cdcooper
                                            ,pr_nrdconta   => rw_epr_pep.nrdconta
                                            ,pr_nrctremp   => rw_epr_pep.nrctremp
                                            ,pr_rw_crapdat => rw_crapdat
                                            ,pr_cdagenci   => rw_epr_pep.cdagenci
                                            ,pr_cdpactra   => rw_epr_pep.cdagenci
                                            ,pr_cdoperad   => 1
                                            ,pr_nrdcaixa   => 0
                                            ,pr_cdorigem   => 7 -- BATCH
                                            ,pr_nmdatela   => vr_cdprogra
                                            ,pr_floperac   => vr_floperac
                                            ,pr_cdcritic   => vr_cdcritic
                                            ,pr_dscritic   => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Seta a ultima conta
      vr_ultconta := rw_epr_pep.nrdconta;

      -- Caso seja ultimo registro da conta e contrato
      IF rw_epr_pep.numconta = rw_epr_pep.qtdconta THEN
         vr_qtdconta := vr_qtdconta + 1;
         -- Salvar a cada 1.000 contas
         IF MOD(vr_qtdconta,1000) = 0 THEN
           -- Grava agencia no controle do batch
           pc_grava_dados(pr_cdrestart => vr_ultconta);
         END IF;
      END IF;

    END LOOP; -- cr_epr_pep

    IF pr_cdagenci <> 0 THEN -- 29/08/2018
	
    -- Grava os dados restantes conforme PL Table
    pc_grava_dados(pr_cdrestart => vr_ultconta);
    
    -- Finaliza agencia no controle do batch
    GENE0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole
                                       ,pr_cdcritic   => vr_cdcritic
                                       ,pr_dscritic   => vr_dscritic);
    -- Se houve erro
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Encerrar o job do processamento paralelo dessa agencia
    GENE0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => pr_cdagenci
                                ,pr_des_erro => vr_dscritic);
    -- Se houve erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    END IF; -- pr_cdagenci <> 0 THEN -- 29/08/2018
    
    -- Processo OK, devemos chamar a fimprg
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => vr_infimsol
                             ,pr_stprogra => vr_stprogra);

    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    COMMIT;

  EXCEPTION

    WHEN vr_exc_saida THEN
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
      
      -- Novamente tenta encerrar o JOB
      GENE0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_cdagenci
                                  ,pr_des_erro => vr_dscritic);
      -- Se aconteceu erro
      IF vr_dscritic IS NOT NULL THEN
        pr_dscritic := pr_dscritic || ' - ' || vr_dscritic;
      END IF;

      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - '
                                                 || vr_cdprogra || ' --> PA: ' || pr_cdagenci || ' - '
                                                 || pr_dscritic);

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

      -- Novamente tenta encerrar o JOB
      GENE0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => pr_cdagenci
                                  ,pr_des_erro => vr_dscritic);
      -- Se aconteceu erro
      IF vr_dscritic IS NOT NULL THEN
        pr_dscritic := pr_dscritic || ' - ' || vr_dscritic;
      END IF;

      -- Envio centralizado de log de erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - '
                                                 || vr_cdprogra || ' --> PA: ' || pr_cdagenci || ' - '
                                                 || pr_dscritic);

  END;

END pc_crps724_1;
/
