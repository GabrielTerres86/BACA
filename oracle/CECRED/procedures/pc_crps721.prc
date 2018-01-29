CREATE OR REPLACE PROCEDURE CECRED.pc_crps721(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps721
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jaison
     Data    : Julho/2017                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Mensal.
     Objetivo  : Efetua o lancamento do Juros Remuneratorio e Juros de Correcao no produto Pos-Fixado.

     Alteracoes: 

  ............................................................................ */

  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Codigo do programa
    vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'CRPS721';

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Cursor generico de calendario
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

    -- Busca os contratos
    CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapepr.nrdconta
            ,crapepr.nrctremp
            ,crapepr.dtmvtolt
            ,crapepr.dtdpagto
            ,crapepr.vlsprojt
            ,crapepr.txmensal
            ,crapepr.vlpreemp
            ,crapepr.dtrefjur
            ,crapepr.diarefju
            ,crapepr.mesrefju
            ,crapepr.anorefju            
            ,crapepr.txjuremp
            ,crapepr.vlemprst
            ,crapepr.qtpreemp
            ,crapepr.nrctaav1
            ,crapepr.nrctaav2
            ,crapepr.cdagenci
            ,crapepr.cdbccxlt
            ,crapepr.nrdolote
            ,crapepr.cdfinemp
            ,crapepr.cdlcremp
            ,crapepr.qttolatr
            ,TO_CHAR(crapepr.dtdpagto, 'DD') diapagto
            ,crawepr.cddindex
        FROM crapepr
        JOIN crawepr
          ON crawepr.cdcooper = crapepr.cdcooper
         AND crawepr.nrdconta = crapepr.nrdconta
         AND crawepr.nrctremp = crapepr.nrctremp
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.tpemprst = 2 -- Pos-Fixado
         AND crapepr.inliquid = 0;
    
    -- Busca a parcela que sera lancado o Juros na Mensal
    CURSOR cr_crappep_mensal(pr_cdcooper IN crapepr.cdcooper%TYPE
                            ,pr_nrdconta IN crapepr.nrdconta%TYPE
                            ,pr_nrctremp IN crapepr.nrctremp%TYPE
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT MIN(nrparepr) nrparepr,
               vltaxatu
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND dtvencto >= pr_dtmvtolt
      GROUP BY vltaxatu;
    rw_crappep_mensal cr_crappep_mensal%ROWTYPE;
    
    -- Busca as parcelas atrasadas
    CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                     ,pr_nrdconta IN crappep.nrdconta%TYPE
                     ,pr_nrctremp IN crappep.nrctremp%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT crappep.nrparepr
            ,crappep.vlparepr
            ,crappep.dtvencto
            ,crappep.dtultpag
            ,crappep.vlsdvpar
            ,crappep.vlpagmta
        FROM crappep
       WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.inliquid = 0 
         AND crappep.dtvencto < pr_dtmvtolt;

    -- Busca os dados da linha de credito
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE) IS
      SELECT cdlcremp
            ,dsoperac
            ,perjurmo
            ,flgcobmu
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND tpprodut = 2;

    
    -- Soma os valores lancados dentro do mes
    CURSOR cr_craplem_sum(pr_cdcooper IN craplem.cdcooper%TYPE
                         ,pr_nrdconta IN craplem.nrdconta%TYPE
                         ,pr_nrctremp IN craplem.nrctremp%TYPE
                         ,pr_dtamvini IN craplem.dtmvtolt%TYPE
                         ,pr_dtamvfin IN craplem.dtmvtolt%TYPE) IS
      SELECT SUM(craplem.vllanmto)
        FROM craplem
       WHERE craplem.cdcooper = pr_cdcooper
         AND craplem.nrdconta = pr_nrdconta
         AND craplem.nrctremp = pr_nrctremp
         AND craplem.cdhistor IN (2343,2342,2345,2344)
         AND craplem.dtmvtolt >= pr_dtamvini
         AND craplem.dtmvtolt <= pr_dtamvfin;
    vr_vllanmto craplem.vllanmto%TYPE;

    -- Verificar Registro de Microfilmagem
    CURSOR cr_crapmcr(pr_cdcooper IN crapmcr.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapmcr.dtmvtolt%TYPE
                     ,pr_cdagenci IN crapmcr.cdagenci%TYPE
                     ,pr_cdbccxlt IN crapmcr.cdbccxlt%TYPE
                     ,pr_nrdolote IN crapmcr.nrdolote%TYPE
                     ,pr_nrdconta IN crapmcr.nrdconta%TYPE
                     ,pr_nrcontra IN crapmcr.nrcontra%TYPE) IS
      SELECT 1
        FROM crapmcr
       WHERE crapmcr.cdcooper = pr_cdcooper
         AND crapmcr.dtmvtolt = pr_dtmvtolt
         AND crapmcr.cdagenci = pr_cdagenci
         AND crapmcr.cdbccxlt = pr_cdbccxlt
         AND crapmcr.nrdolote = pr_nrdolote
         AND crapmcr.nrdconta = pr_nrdconta
         AND crapmcr.nrcontra = pr_nrcontra
         AND crapmcr.tpctrmif = 1; -- Emprestimo
    rw_crapmcr cr_crapmcr%ROWTYPE;
    
    --Selecionar Moedas
    CURSOR cr_crapmfx (pr_cdcooper IN crapmfx.cdcooper%TYPE
                      ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                      ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
      SELECT crapmfx.cdcooper
            ,crapmfx.vlmoefix
        FROM crapmfx
       WHERE crapmfx.cdcooper = pr_cdcooper
         AND crapmfx.dtmvtolt = pr_dtmvtolt
         AND crapmfx.tpmoefix = pr_tpmoefix;
    rw_crapmfx cr_crapmfx%ROWTYPE;

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

    vr_tab_flg_lcr CADA0001.typ_tab_number;
    vr_tab_crapmfx CADA0001.typ_tab_number;

    ------------------------------- VARIAVEIS -------------------------------
    vr_flgachou          BOOLEAN;
    vr_flg_lancar_mensal BOOLEAN;
    vr_floperac          BOOLEAN;
    vr_txdiaria          craplcr.txdiaria%TYPE;
    vr_vljuremu          NUMBER;
    vr_vljurcor          NUMBER;
    vr_vlmtapar          NUMBER;
    vr_vlmrapar          NUMBER;
    vr_dtvencto          DATE;
    vr_percmult          NUMBER(25,2);
    vr_cdhistor          craphis.cdhistor%TYPE;
    vr_dstextab          craptab.dstextab%TYPE;
    vr_diarefju          crapepr.diarefju%TYPE;
    vr_mesrefju          crapepr.mesrefju%TYPE;
    vr_anorefju          crapepr.anorefju%TYPE;
  BEGIN

    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                              ,pr_action => NULL);

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- Leitura do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    vr_flgachou := BTCH0001.cr_crapdat%FOUND;
    CLOSE BTCH0001.cr_crapdat;
    -- Se NAO achou
    IF NOT vr_flgachou THEN
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    END IF;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se possui erro
    IF vr_cdcritic <> 0 THEN
      RAISE vr_exc_saida;
    END IF;

    -- Limpar tabela de memoria
    vr_tab_craplcr.DELETE;
    vr_tab_flg_lcr.DELETE;
    vr_tab_crapmfx.DELETE;

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
    
    --Selecionar Valor Moeda
    OPEN cr_crapmfx (pr_cdcooper => pr_cdcooper
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                    ,pr_tpmoefix => 2);
    FETCH cr_crapmfx INTO rw_crapmfx;
    --Se nao encontrou
    IF cr_crapmfx%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 140;
      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      --Complementar mensagem
      vr_dscritic:= vr_dscritic ||' da UFIR.';
      RAISE vr_exc_saida;
    END IF;

    -- Carregar linhas de credito
    FOR rw_craplcr IN cr_craplcr(pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_craplcr(rw_craplcr.cdlcremp).dsoperac := rw_craplcr.dsoperac;
      vr_tab_craplcr(rw_craplcr.cdlcremp).perjurmo := rw_craplcr.perjurmo;
      vr_tab_craplcr(rw_craplcr.cdlcremp).flgcobmu := rw_craplcr.flgcobmu;
      vr_tab_flg_lcr(rw_craplcr.cdlcremp) := 0;
    END LOOP;

    -- Listagem dos contratos
    FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper) LOOP
      -- Zerar a Variavel
      vr_vljuremu := 0;
      vr_vljurcor := 0;
      vr_vlmrapar := 0;
      vr_diarefju := rw_crapepr.diarefju;
      vr_mesrefju := rw_crapepr.mesrefju;
      vr_anorefju := rw_crapepr.anorefju;

      -- Se NAO achou a linha de credito
      IF NOT vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
        vr_cdcritic := 363;
        RAISE vr_exc_saida;
      END IF;
      
      -- Cursor para buscar a parcela que sera calculado o Juros
      OPEN cr_crappep_mensal(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapepr.nrdconta
                            ,pr_nrctremp => rw_crapepr.nrctremp
                            ,pr_dtmvtolt => last_day(rw_crapdat.dtmvtolt));
      FETCH cr_crappep_mensal INTO rw_crappep_mensal;
      vr_flg_lancar_mensal := cr_crappep_mensal%FOUND;
      CLOSE cr_crappep_mensal;
      
      -- Condicao para verificar se havera lancamento na mensal
      IF vr_flg_lancar_mensal THEN
        -- Se for Financiamento
        vr_floperac := (vr_tab_craplcr(rw_crapepr.cdlcremp).dsoperac = 'FINANCIAMENTO');
        -- Calcula a taxa diaria
        vr_txdiaria := POWER(1 + (NVL(rw_crapepr.txmensal,0) / 100),(1 / 30)) - 1;
        -- Monta data de vencimento
        vr_dtvencto := TO_DATE(rw_crapepr.diapagto || '/' || TO_CHAR(rw_crapdat.dtmvtolt, 'MM/RRRR'),'DD/MM/RRRR');
        -- Efetuar o lancamento de Juros Remuneratorio
        EMPR0011.pc_efetua_lcto_juros_remun(pr_cdcooper => pr_cdcooper
                                           ,pr_dtcalcul => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => rw_crapepr.cdagenci
                                           ,pr_cdpactra => rw_crapepr.cdagenci
                                           ,pr_cdoperad => 1
                                           ,pr_cdorigem => 7 -- BATCH
                                           ,pr_nrdconta => rw_crapepr.nrdconta
                                           ,pr_nrctremp => rw_crapepr.nrctremp
                                           ,pr_txjuremp => rw_crapepr.txjuremp
                                           ,pr_vlpreemp => rw_crapepr.vlpreemp
                                           ,pr_dtlibera => rw_crapepr.dtmvtolt
                                           ,pr_dtrefjur => rw_crapepr.dtrefjur
                                           ,pr_floperac => vr_floperac
                                           ,pr_dtvencto => vr_dtvencto
                                           ,pr_vlsprojt => rw_crapepr.vlsprojt
                                           ,pr_ehmensal => TRUE
                                           ,pr_txdiaria => vr_txdiaria
                                           ,pr_nrparepr => rw_crappep_mensal.nrparepr
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
        EMPR0011.pc_efetua_lcto_juros_correc(pr_cdcooper => pr_cdcooper
                                            ,pr_dtcalcul => rw_crapdat.dtmvtolt
                                            ,pr_cdagenci => rw_crapepr.cdagenci
                                            ,pr_cdpactra => rw_crapepr.cdagenci
                                            ,pr_cdoperad => 1
                                            ,pr_cdorigem => 7 -- BATCH
                                            ,pr_flgbatch => TRUE
                                            ,pr_nrdconta => rw_crapepr.nrdconta
                                            ,pr_nrctremp => rw_crapepr.nrctremp
                                            ,pr_dtlibera => rw_crapepr.dtmvtolt
                                            ,pr_dtrefjur => rw_crapepr.dtrefjur
                                            ,pr_vlrdtaxa => rw_crappep_mensal.vltaxatu
                                            ,pr_txjuremp => rw_crapepr.txjuremp
                                            ,pr_vlpreemp => rw_crapepr.vlpreemp
                                            ,pr_dtvencto => vr_dtvencto
                                            ,pr_vlsprojt => rw_crapepr.vlsprojt
                                            ,pr_ehmensal => TRUE
                                            ,pr_floperac => vr_floperac
                                            ,pr_nrparepr => rw_crappep_mensal.nrparepr
                                            ,pr_vljurcor => vr_vljurcor
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
        -- Se houve erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        vr_vllanmto := 0;
        -- Soma os valores lancados dentro do mes
        OPEN cr_craplem_sum(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapepr.nrdconta
                           ,pr_nrctremp => rw_crapepr.nrctremp
                           ,pr_dtamvini => TO_DATE('01' || TO_CHAR(rw_crapdat.dtmvtolt,'/MM/RRRR'), 'DD/MM/RRRR')
                           ,pr_dtamvfin => LAST_DAY(rw_crapdat.dtmvtolt));
        FETCH cr_craplem_sum INTO vr_vllanmto;
        CLOSE cr_craplem_sum;
        
        -- Se teve juros pra lancar
        IF NVL(vr_vllanmto,0) > 0 THEN
          -- Atualizar tabela cotas
          BEGIN
            UPDATE crapcot 
               SET crapcot.qtjurmfx = NVL(crapcot.qtjurmfx,0) + ROUND(vr_vllanmto / rw_crapmfx.vlmoefix,4)
             WHERE crapcot.cdcooper = pr_cdcooper
               AND crapcot.nrdconta = rw_crapepr.nrdconta;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar tabela crapcot. ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        
      END IF;  -- -- Condicao para verificar se havera lancamento na mensal

      --  Inicializa os meses decorridos para os contratos do mes
      IF TO_CHAR(rw_crapepr.dtmvtolt,'YYYYMM') = TO_CHAR(rw_crapdat.dtmvtolt,'YYYYMM') THEN

        -- Verificar Registro de Microfilmagem
        OPEN cr_crapmcr(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => rw_crapepr.dtmvtolt
                       ,pr_cdagenci => rw_crapepr.cdagenci
                       ,pr_cdbccxlt => rw_crapepr.cdbccxlt
                       ,pr_nrdolote => rw_crapepr.nrdolote
                       ,pr_nrdconta => rw_crapepr.nrdconta
                       ,pr_nrcontra => rw_crapepr.nrctremp);
        FETCH cr_crapmcr INTO rw_crapmcr;
        vr_flgachou := cr_crapmcr%FOUND;
        CLOSE cr_crapmcr;
        -- Se achou
        IF vr_flgachou THEN
          vr_dscritic := 'ATENCAO: Contrato ja microfilmado. Conta: '
                      || GENE0002.fn_mask(rw_crapepr.nrdconta,'zzzz.zzz9.9')
                      || '  Contrato: '
                      || GENE0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9');
          -- Envio centralizado de log de erro
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - '
                                                     || vr_cdprogra || ' --> ' || vr_dscritic);
        ELSE
          -- Inserir registro microfilmagem
          BEGIN
            INSERT INTO crapmcr
              (crapmcr.dtmvtolt
              ,crapmcr.cdagenci
              ,crapmcr.cdbccxlt
              ,crapmcr.nrdolote
              ,crapmcr.nrdconta
              ,crapmcr.nrcontra
              ,crapmcr.tpctrmif
              ,crapmcr.vlcontra
              ,crapmcr.qtpreemp
              ,crapmcr.nrctaav1
              ,crapmcr.nrctaav2
              ,crapmcr.cdlcremp
              ,crapmcr.cdfinemp
              ,crapmcr.cdcooper)
            VALUES
              (rw_crapepr.dtmvtolt
              ,rw_crapepr.cdagenci
              ,rw_crapepr.cdbccxlt
              ,rw_crapepr.nrdolote
              ,rw_crapepr.nrdconta
              ,rw_crapepr.nrctremp
              ,1
              ,rw_crapepr.vlemprst
              ,rw_crapepr.qtpreemp
              ,NVL(rw_crapepr.nrctaav1,0)
              ,NVL(rw_crapepr.nrctaav2,0)
              ,rw_crapepr.cdlcremp
              ,rw_crapepr.cdfinemp
              ,pr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao inserir CRAPMCR: ' || rw_crapepr.nrdconta || '-' || rw_crapepr.nrctremp || '. ' || SQLERRM;
              -- Envio centralizado de log de erro
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => TO_CHAR(SYSDATE,'hh24:mi:ss') || ' - '
                                                           || vr_cdprogra || ' --> ' || vr_dscritic);
          END;
        END IF; -- vr_flgachou

        -- Reseta variavel
        vr_dscritic := NULL;

      END IF; -- TO_CHAR(rw_crapepr.dtmvtolt,'YYYYMM') = TO_CHAR(rw_crapdat.dtmvtolt,'YYYYMM')

      -- Verifica se a linha de credito ja foi atualizada
      IF vr_tab_flg_lcr(rw_crapepr.cdlcremp) = 0 THEN
        --  Atualizacao do indicador de saldo devedor
        BEGIN
          UPDATE craplcr 
             SET craplcr.flgsaldo = 1
           WHERE craplcr.cdcooper = pr_cdcooper
             AND craplcr.cdlcremp = rw_crapepr.cdlcremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic	:= 'Erro ao atualizar linha credito. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
        -- Marcar que ja atualizou essa linha Emprestimo
        vr_tab_flg_lcr(rw_crapepr.cdlcremp) := 1;
      END IF;

      -- Condicao para verificar se possui parcelas em atraso
      IF rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt THEN

        -- Listagem das parcelas vencidas
        FOR rw_crappep IN cr_crappep(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => rw_crapepr.nrdconta
                                    ,pr_nrctremp => rw_crapepr.nrctremp
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

          -- Verifica se a Linha de Credito Cobra Multa
          IF vr_tab_craplcr(rw_crapepr.cdlcremp).flgcobmu = 1 THEN
            -- Utilizar como % de multa, as 6 primeiras posicoes encontradas
            vr_percmult := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
          ELSE
            vr_percmult := 0;
          END IF;

          -- Procedure para calcular o Valor de Juros de Mora
          EMPR0011.pc_calcula_atraso_pos_fixado(pr_dtcalcul => rw_crapdat.dtmvtolt
                                               ,pr_vlparepr => rw_crappep.vlparepr
                                               ,pr_dtvencto => rw_crappep.dtvencto
                                               ,pr_dtultpag => rw_crappep.dtultpag
                                               ,pr_vlsdvpar => rw_crappep.vlsdvpar
                                               ,pr_perjurmo => vr_tab_craplcr(rw_crapepr.cdlcremp).perjurmo
                                               ,pr_vlpagmta => rw_crappep.vlpagmta
                                               ,pr_percmult => vr_percmult
                                               ,pr_txmensal => rw_crapepr.txmensal
                                               ,pr_qttolatr => rw_crapepr.qttolatr
                                               ,pr_vlmrapar => vr_vlmrapar
                                               ,pr_vlmtapar => vr_vlmtapar
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
          -- Se houve erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          -- Efetua o Lancamento de Juros de Mora do Contrato de Emprestimo
          IF NVL(vr_vlmrapar, 0) > 0 THEN

            -- Se for Financiamento
            IF vr_floperac THEN
              vr_cdhistor := 2347;
            ELSE
              vr_cdhistor := 2346;
            END IF;

            -- Efetuar o lancamento do juros de mora
            EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => rw_crapepr.cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => 1
                                           ,pr_cdpactra => rw_crapepr.cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 650004
                                           ,pr_nrdconta => rw_crapepr.nrdconta
                                           ,pr_cdhistor => vr_cdhistor
                                           ,pr_nrctremp => rw_crapepr.nrctremp
                                           ,pr_vllanmto => vr_vlmrapar
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => rw_crapepr.txjuremp
                                           ,pr_vlpreemp => rw_crapepr.vlpreemp
                                           ,pr_nrsequni => rw_crappep.nrparepr
                                           ,pr_nrparepr => rw_crappep.nrparepr
                                           ,pr_flgincre => TRUE
                                           ,pr_flgcredi => TRUE
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 	-- BATCH
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
            -- Se houve erro
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF; -- NVL(vr_vlmrapar, 0) > 0
           
         END LOOP;
      END IF;
      
      -- Condicao para verificar se foi lancado Juros Remuneratorio
      IF vr_vljuremu <= 0 THEN
        vr_diarefju := rw_crapepr.diarefju;
        vr_mesrefju := rw_crapepr.mesrefju;
        vr_anorefju := rw_crapepr.anorefju;
      END IF;

      -- Atualizar Emprestimo
      BEGIN
        UPDATE crapepr
           SET crapepr.dtrefjur = rw_crapdat.dtmvtolt
              ,crapepr.diarefju = vr_diarefju
              ,crapepr.mesrefju = vr_mesrefju
              ,crapepr.anorefju = vr_anorefju
              ,crapepr.vlsdeved = NVL(crapepr.vlsdeved,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0) + NVL(vr_vlmrapar,0)
              ,crapepr.vljuracu = NVL(crapepr.vljuracu,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0)
              ,crapepr.vljurmes = NVL(crapepr.vljuratu,0) + NVL(vr_vljuremu,0) + NVL(vr_vljurcor,0)
              ,crapepr.vljuratu = 0
              ,crapepr.indpagto = 0
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = rw_crapepr.nrdconta
           AND crapepr.nrctremp = rw_crapepr.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar o emprestimo. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    END LOOP; -- cr_crapepr

    -- Processo OK, devemos chamar a fimprg
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

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

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

  END;

END pc_crps721;
/
