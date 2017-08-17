CREATE OR REPLACE PROCEDURE CECRED.pc_crps724_1(pr_cdcooper   IN crapcop.cdcooper%TYPE       --> Codigo Cooperativa
                                               ,pr_idparale   IN crappar.idparale%TYPE       --> Indicador de processo paralelo
                                               ,pr_cdagenci   IN crapage.cdagenci%TYPE       --> Codigo Agencia
                                               ,pr_cdcritic  OUT crapcri.cdcritic%TYPE       --> Codigo da Critica
                                               ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS   --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps724_1
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jaison
     Data    : Agosto/2017                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Pagar as parcelas dos contratos do produto Pos-Fixado.

     Alteracoes: 

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
    CURSOR cr_epr_pep(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_cdagenci IN crapage.cdagenci%TYPE,
                      pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT crapepr.cdagenci,
             crapepr.nrdconta,
             crapepr.nrctremp,
             crapepr.tpemprst,
             crapepr.cdlcremp,
             crapepr.vlpreemp,
             crapepr.qtprepag,
             crapepr.qtprecal,
             crapepr.dtrefjur,
             crapepr.txmensal,
             crapepr.txjuremp,
             crapepr.vlsprojt,
             crapepr.qttolatr,
             crawepr.dtlibera,
             crawepr.cddindex,
             crappep.nrparepr,
             crappep.vlparepr,
             crappep.dtvencto,
             crappep.vlsdvpar,
             crappep.vlsdvatu,
             crappep.vljura60,
             crappep.dtultpag,
             crappep.vlpagmta

        FROM crapepr

        JOIN crawepr
          ON crawepr.cdcooper = crapepr.cdcooper
         AND crawepr.nrdconta = crapepr.nrdconta
         AND crawepr.nrctremp = crapepr.nrctremp

        JOIN crappep
          ON crappep.cdcooper = crapepr.cdcooper
         AND crappep.nrdconta = crapepr.nrdconta
         AND crappep.nrctremp = crapepr.nrctremp

       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.cdagenci = pr_cdagenci
         AND crapepr.tpemprst = 2 -- Pos-Fixado
         AND crappep.inliquid = 0 -- Pendente
         AND crappep.dtvencto <= pr_dtmvtolt;
    
    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT nrdconta
            ,vllimcre
        FROM crapass
       WHERE cdcooper = pr_cdcooper;

    -- Busca os dados da linha de credito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE) IS
      SELECT cdlcremp
            ,dsoperac
            ,perjurmo
            ,flgcobmu
        FROM craplcr
       WHERE cdcooper = pr_cdcooper;

    -- Buscar a taxa acumulada do CDI
    CURSOR cr_craptxi(pr_dtiniper IN craptxi.dtiniper%TYPE) IS
      SELECT cddindex
            ,vlrdtaxa
        FROM craptxi
       WHERE dtiniper = pr_dtiniper;

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

    vr_tab_crapass CADA0001.typ_tab_number;
    vr_tab_craptxi CADA0001.typ_tab_number;

    ------------------------------- VARIAVEIS -------------------------------
    vr_flgachou BOOLEAN;
    vr_floperac BOOLEAN;
    vr_flmensal BOOLEAN;
    vr_infimsol PLS_INTEGER;
    vr_stprogra PLS_INTEGER;
    vr_vlsldisp NUMBER;
    vr_vlpagpar NUMBER;
    vr_percmult NUMBER(25,2);
    vr_dstextab craptab.dstextab%TYPE;
    vr_txdiaria craplcr.txdiaria%TYPE;
    vr_dsctactrjud crapprm.dsvlrprm%TYPE := NULL;

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

    -- Limpar tabela de memoria
    vr_tab_crapass.DELETE;
    vr_tab_craplcr.DELETE;
    vr_tab_craptxi.DELETE;

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

    -- Carregar associados
    FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_crapass(rw_crapass.nrdconta) := rw_crapass.vllimcre;
    END LOOP;

    -- Carregar linhas de credito
    FOR rw_craplcr IN cr_craplcr(pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_craplcr(rw_craplcr.cdlcremp).dsoperac := rw_craplcr.dsoperac;
      vr_tab_craplcr(rw_craplcr.cdlcremp).perjurmo := rw_craplcr.perjurmo;
      vr_tab_craplcr(rw_craplcr.cdlcremp).flgcobmu := rw_craplcr.flgcobmu;
    END LOOP;

    -- Carregar taxas
    FOR rw_craptxi IN cr_craptxi(pr_dtiniper => rw_crapdat.dtmvtoan) LOOP
      vr_tab_craptxi(rw_craptxi.cddindex) := rw_craptxi.vlrdtaxa;
    END LOOP;

    -- Listagem dos contratos e parcelas
    FOR rw_epr_pep IN cr_epr_pep(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

      -- Se NAO achou a linha de credito
      IF NOT vr_tab_craplcr.EXISTS(rw_epr_pep.cdlcremp) THEN
        vr_cdcritic := 363;
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO achou a taxa
      IF NOT vr_tab_craptxi.EXISTS(rw_epr_pep.cddindex) THEN
        vr_dscritic := 'Taxa do CDI nao cadastrada. Data: ' || TO_CHAR(rw_crapdat.dtmvtoan,'DD/MM/RRRR');
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

      -- Chama validacao generica
      EMPR0011.pc_valida_pagamentos_pos(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_epr_pep.nrdconta
                                       ,pr_cdagenci => rw_epr_pep.cdagenci
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => 1
                                       ,pr_rw_crapdat => rw_crapdat
                                       ,pr_tpemprst => rw_epr_pep.tpemprst
                                       ,pr_dtlibera => rw_epr_pep.dtlibera
                                       ,pr_vllimcre => vr_tab_crapass(rw_epr_pep.nrdconta)
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

      --------------------
      -- Parcela em dia --
      --------------------
      IF rw_epr_pep.dtvencto > rw_crapdat.dtmvtoan AND rw_epr_pep.dtvencto <= rw_crapdat.dtmvtolt THEN

        -- Recebe o saldo devedor da parcela
        vr_vlpagpar := rw_epr_pep.vlsdvpar;
        -- Condicao para verifica o valor pago da parcela
        IF NVL(vr_vlpagpar,0) > NVL(vr_vlsldisp,0) THEN
          vr_vlpagpar := vr_vlsldisp;
        END IF;

        -- Efetua o pagamento da parcela em Dia
        EMPR0011.pc_efetua_pagamento_em_dia(pr_cdcooper => pr_cdcooper
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
                                           ,pr_dtlibera => rw_epr_pep.dtlibera
                                           ,pr_dtrefjur => rw_epr_pep.dtrefjur
                                           ,pr_vlrdtaxa => vr_tab_craptxi(rw_epr_pep.cddindex)
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
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      ----------------------
      -- Parcela a Vencer --
      ----------------------
      ELSIF rw_epr_pep.dtvencto > rw_crapdat.dtmvtolt THEN
        
        --  Se eh mensal e o dia do vencimento for maior que o dia atual
        IF vr_flmensal AND TO_NUMBER(TO_CHAR(rw_epr_pep.dtvencto,'DD')) > TO_NUMBER(TO_CHAR(rw_crapdat.dtmvtolt,'DD')) THEN

          -- Efetua o pagamento da parcela em Dia
          EMPR0011.pc_efetua_pagamento_em_dia(pr_cdcooper => pr_cdcooper
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
                                             ,pr_dtlibera => rw_epr_pep.dtlibera
                                             ,pr_dtrefjur => rw_epr_pep.dtrefjur
                                             ,pr_vlrdtaxa => vr_tab_craptxi(rw_epr_pep.cddindex)
                                             ,pr_txdiaria => vr_txdiaria
                                             ,pr_txjuremp => rw_epr_pep.txjuremp
                                             ,pr_vlsprojt => rw_epr_pep.vlsprojt
                                             ,pr_floperac => vr_floperac
                                             ,pr_nrseqava => 0
                                             ,pr_nrparepr => rw_epr_pep.nrparepr
                                             ,pr_dtvencto => rw_epr_pep.dtvencto
                                             ,pr_vlpagpar => 0
                                             ,pr_vlsdvpar => rw_epr_pep.vlsdvpar
                                             ,pr_vlsdvatu => rw_epr_pep.vlsdvatu
                                             ,pr_vljura60 => rw_epr_pep.vljura60
                                             ,pr_ehmensal => vr_flmensal
                                             ,pr_vlsldisp => vr_vlsldisp
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

        END IF; -- vr_flmensal

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

    END LOOP; -- cr_epr_pep

    -- Encerrar o job do processamento paralelo dessa agencia
    GENE0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => pr_cdagenci
                                ,pr_des_erro => pr_dscritic);
    -- Se houve erro
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Grava agencia no controle do batch
    GENE0001.pc_grava_batch_controle_age(pr_cdcooper => pr_cdcooper
                                        ,pr_cdprogra => vr_cdprogra
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
    -- Se houve erro
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

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

  END;

END pc_crps724_1;
/
