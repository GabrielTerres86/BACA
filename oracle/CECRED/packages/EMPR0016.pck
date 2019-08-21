CREATE OR REPLACE PACKAGE CECRED.EMPR0016 IS

  -- Author  : Rafael Muniz Monteiro (Mout's)
  -- Created : 24/08/2018 
  -- Purpose : 

  -- Realizar o crédito online para empréstimo PP
  PROCEDURE pc_credito_online_pp(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato
                                ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Codigo Programa
                                ,pr_inpessoa  IN crapass.inpessoa%TYPE     --> Tipo de pessoa
                                ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo da agencia
                                ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                ,pr_cdpactra  IN crapage.cdagenci%TYPE     --> Codigo do PA de Transacao
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE     --> Codigo do Operador
                                ,pr_vltottar OUT NUMBER                    --> Valor da tarifa
                                ,pr_vltariof OUT NUMBER                    --> Valor do IOF
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE);

END EMPR0016;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0016 is

  PROCEDURE pc_credito_online_pp(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo da Cooperativa
                                ,pr_nrdconta  IN crapass.nrdconta%TYPE     --> Numero da Conta
                                ,pr_nrctremp  IN crawepr.nrctremp%TYPE     --> Numero do contrato
                                ,pr_cdprogra  IN crapprg.cdprogra%TYPE     --> Codigo Programa
                                ,pr_inpessoa  IN crapass.inpessoa%TYPE     --> Tipo de pessoa
                                ,pr_cdagenci  IN crapage.cdagenci%TYPE     --> Codigo da agencia
                                ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     --> Numero do caixa
                                ,pr_cdpactra  IN crapage.cdagenci%TYPE     --> Codigo do PA de Transacao
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE     --> Codigo do Operador
                                ,pr_vltottar OUT NUMBER                    --> Valor da tarifa
                                ,pr_vltariof OUT NUMBER                    --> Valor do IOF
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE)IS
    /* ..............................................................................
      Programa: pc_credito_online_pp
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Rafael Muniz Monteiro
      Data    : Agosto/2018                        Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para realizar o crédito online de Empréstimo tipo PP

      Alteracoes: 
    .................................................................................*/    
    -- Cursores --
    -- Cursor de Proposta de Emprestimo
    CURSOR cr_crawepr(prc_cdcooper IN crawepr.cdcooper%TYPE
                     ,prc_nrdconta IN crawepr.nrdconta%TYPE
                     ,prc_nrctremp IN crawepr.nrctremp%TYPE) IS
      SELECT wepr.qtpreemp
            ,wepr.vlpreemp
            ,wepr.vlemprst
            ,wepr.dtdpagto
            ,wepr.dtlibera
            ,wepr.cdfinemp
            ,wepr.cdlcremp
            ,wepr.tpemprst
            ,wepr.dtcarenc
            ,wepr.idcarenc
            ,wepr.idfiniof
        FROM crawepr wepr
       WHERE wepr.cdcooper = prc_cdcooper
         AND wepr.nrdconta = prc_nrdconta
         AND wepr.nrctremp = prc_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;    
    -- 
    -- Cursor Linhas de Credito
    CURSOR cr_craplcr(prc_cdcooper IN craplcr.cdcooper%TYPE
                     ,prc_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT lcr.cdlcremp
            ,lcr.flgtarif
            ,lcr.nrctacre
            ,lcr.vltrfesp
            ,lcr.flgcrcta
            ,lcr.flgtaiof
            ,lcr.cdusolcr
            ,lcr.tpctrato
            ,lcr.txdiaria
            ,lcr.dsoperac
        FROM craplcr lcr
       WHERE cdcooper = prc_cdcooper
         AND cdlcremp = prc_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;       
    --  
    CURSOR cr_crapbpr (prc_cdcooper IN crapcop.cdcooper%TYPE
                      ,prc_nrdconta IN crapepr.nrdconta%TYPE
                      ,prc_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT *
        FROM crapbpr
       WHERE cdcooper = prc_cdcooper
         AND nrdconta = prc_nrdconta
         AND tpctrpro = 90
         AND nrctrpro = prc_nrctremp
         AND flgalien = 1; -- TRUE;
    --  
    CURSOR cr_portabilidade(prc_cdcooper IN crapcop.cdcooper%TYPE
                           ,prc_nrdconta IN crapcop.nrdconta%TYPE
                           ,prc_nrctremp IN crawepr.nrctremp%TYPE) IS
      SELECT 1
        FROM tbepr_portabilidade
       WHERE cdcooper = prc_cdcooper
         AND nrdconta = prc_nrdconta
         AND nrctremp = prc_nrctremp;   
    rw_portabilidade cr_portabilidade%ROWTYPE; 
    --
    -- Busca o associado
    CURSOR cr_crapass(prc_cdcooper IN crapass.cdcooper%TYPE
                     ,prc_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.vllimcre
        FROM crapass
       WHERE crapass.cdcooper = prc_cdcooper
         AND crapass.nrdconta = prc_nrdconta;
    rw_crapass cr_crapass%ROWTYPE; 
    --
    CURSOR cr_craplcm (prc_cdcooper IN crapcop.cdcooper%TYPE
                      ,prc_nrdconta IN crapcop.nrdconta%TYPE
                      ,prc_nrctremp IN crawepr.nrctremp%TYPE
                      ,prc_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT 1
      FROM craplcm lcm 
     WHERE lcm.cdcooper = prc_cdcooper 
       AND lcm.nrdconta = prc_nrdconta
       AND lcm.dtmvtolt = prc_dtmvtolt
       AND to_number(TRIM(REPLACE(lcm.cdpesqbb,'.',''))) = prc_nrctremp 
       AND lcm.cdhistor = 15
       ; 
        rw_craplcm cr_craplcm%ROWTYPE; 

    --
    -- Variáveis --
    vr_cdcooper        crawepr.cdcooper%TYPE;
    vr_nrdconta        crawepr.nrdconta%TYPE;
    vr_nrctremp        crawepr.nrctremp%TYPE;    
    rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;
    vr_flgcrcta        craplcr.flgcrcta%TYPE;
    vr_tab_erro        GENE0001.typ_tab_erro;
    vr_tab_saldos      EXTR0001.typ_tab_saldos;
    vr_des_reto        VARCHAR2(5);
    vr_dsbemgar        VARCHAR2(32000);
    vr_vlsldisp        NUMBER;

    vr_vlrtarif        crapfco.vltarifa%TYPE;    
    vr_vltrfesp        craplcr.vltrfesp%TYPE;
    vr_vltrfgar        NUMBER;
    vr_cdhistor        craphis.cdhistor%TYPE;
    vr_cdfvlcop        crapfco.cdfvlcop%TYPE;    
    vr_cdhisgar        craphis.cdhistor%TYPE;
    vr_cdfvlgar        crapfco.cdfvlcop%TYPE;
    vr_cdlantar        craplat.cdlantar%TYPE;
    vr_qtdias_carencia tbepr_posfix_param_carencia.qtddias%TYPE;    
    vr_floperac        BOOLEAN;
    vr_vltottar        NUMBER := 0;
    vr_vlpreclc        NUMBER := 0; -- Parcela calcula    
    vr_vltariof        NUMBER := 0;
    vr_nrseqdig        craplem.nrseqdig%TYPE;
    vr_vliofpri        NUMBER(25,2);
    vr_vliofadi        NUMBER(25,2);
    vr_flgimune        PLS_INTEGER;
    -- Rowid de retorno lançamento de tarifa
    vr_rowid         ROWID;
    
    
    -- Exceções e variaveis de erro--
    vr_exc_erro  EXCEPTION;
    vr_exc_sair  EXCEPTION;    
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  crapcri.dscritic%TYPE;

    -- Principal --
  BEGIN
    -- Iniciar váriaveis 
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    vr_des_reto := 'OK';
    vr_vlsldisp := 0;
    vr_tab_erro.DELETE;
    vr_tab_saldos.DELETE;
    
    IF pr_cdcooper IS NULL OR pr_cdcooper <= 0 THEN
      vr_dscritic := 0;
      vr_dscritic := 'Código da cooperativa nulo ou zerado';
      RAISE vr_exc_erro;       
    END IF;
    IF pr_nrdconta IS NULL OR pr_nrdconta <= 0 THEN
      vr_dscritic := 0;
      vr_dscritic := 'Número da conta nulo ou zerado';
      RAISE vr_exc_erro;          
    END IF;
    IF pr_nrctremp IS NULL OR pr_nrctremp <= 0 THEN
      vr_dscritic := 0;
      vr_dscritic := 'Código da proposta nulo ou zerado';
      RAISE vr_exc_erro;         
    END IF;
    
    vr_cdcooper := pr_cdcooper;
    vr_nrdconta := pr_nrdconta;
    vr_nrctremp := pr_nrctremp;
    --
    -- Seleciona data sistema
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se NAO encontrou
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic := 1;
      -- 001 - Sistema sem data de movimento.
      RAISE vr_exc_erro;
    END IF;  
    CLOSE BTCH0001.cr_crapdat;
    --
    -- Buscar dados da proposta emprestimo
    OPEN cr_crawepr(prc_cdcooper => vr_cdcooper
                   ,prc_nrdconta => vr_nrdconta
                   ,prc_nrctremp => vr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    -- Se NAO achou
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      -- 510 - Proposta de emprestimo nao encontrada.      
      vr_cdcritic := 510;
      RAISE vr_exc_erro;
    END IF;    
    CLOSE cr_crawepr;
    --
    -- Se for diferente de PP    
    IF rw_crawepr.tpemprst <> 1 THEN
      vr_dscritic := 0;
      vr_dscritic := 'Tipo de contrato não habilitado para o crédito Online';
      RAISE vr_exc_erro;      
    END IF;
    --    
    -- Selecionar Linha de Credito
    OPEN cr_craplcr(prc_cdcooper => vr_cdcooper
                   ,prc_cdlcremp => rw_crawepr.cdlcremp);
    FETCH cr_craplcr INTO rw_craplcr;
    -- Se NAO achou
    IF cr_craplcr%NOTFOUND THEN
      CLOSE cr_craplcr;
      vr_dscritic := 'Linha de Credito nao encontrada.';
      RAISE vr_exc_erro;
    END IF;    
    CLOSE cr_craplcr;
    --
    -- Se for Financiamento
    vr_floperac := (rw_craplcr.dsoperac = 'FINANCIAMENTO');    
    --
    -- Busca o associado
    OPEN cr_crapass(prc_cdcooper => vr_cdcooper
                   ,prc_nrdconta => vr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Se NAO achou
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
    --
    OPEN cr_craplcm(prc_cdcooper => vr_cdcooper
                   ,prc_nrdconta => vr_nrdconta
                   ,prc_nrctremp => vr_nrctremp
                   ,prc_dtmvtolt => rw_crapdat.dtmvtolt);
    FETCH cr_craplcm INTO rw_craplcm;
    -- Se encontrar portabilidade
    IF cr_craplcm%FOUND THEN 
      CLOSE cr_craplcm;
      RAISE vr_exc_sair;
    END IF;   
    CLOSE cr_craplcm;
    --
    --Consulta o registro na tabela de portabilidade
    OPEN cr_portabilidade(prc_cdcooper => vr_cdcooper
                         ,prc_nrdconta => vr_nrdconta
                         ,prc_nrctremp => vr_nrctremp);
    FETCH cr_portabilidade INTO rw_portabilidade;
    -- Se encontrar portabilidade
    IF cr_portabilidade%FOUND THEN
      vr_flgcrcta := 0;
    ELSE
      vr_flgcrcta := rw_craplcr.flgcrcta;
    END IF;    
    CLOSE cr_portabilidade;
    --
    vr_dsbemgar := '';
    -- Percorrer todos os bens da Proposta de Emprestimo
    FOR rw_crapbpr IN cr_crapbpr(prc_cdcooper => vr_cdcooper
                                ,prc_nrdconta => vr_nrdconta
                                ,prc_nrctremp => vr_nrctremp) LOOP
      vr_dsbemgar := vr_dsbemgar || '|' || rw_crapbpr.dscatbem;
    END LOOP;    
    --
    -- Caso seja permitido pela linha creditar, inserir na conta
    IF vr_flgcrcta = 1 THEN
      -- Efetua o credito na conta corrente do cooperado
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => vr_cdcooper   --> Cooperativa conectada
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Movimento atual
                                    ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                    ,pr_cdbccxlt => 100           --> Numero do caixa
                                    ,pr_cdoperad => pr_cdoperad   --> Codigo do Operador
                                    ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                    ,pr_nrdolote => 8456          --> Numero do Lote
                                    ,pr_nrdconta => vr_nrdconta   --> Numero da conta
                                    ,pr_cdhistor => 15            --> Codigo historico -- CR.EMPRESTIMO
                                    ,pr_vllanmto => rw_crawepr.vlemprst --> Valor do emprestimo
                                    ,pr_nrparepr => 0             --> Numero parcelas emprestimo
                                    ,pr_nrctremp => vr_nrctremp   --> Numero do contrato de emprestimo
                                    ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se possui algum erro na tabela de erros
        IF vr_tab_erro.COUNT() > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Falha ao criar o lancamento de credito na conta';
        END IF;
        RAISE vr_exc_erro;
      END IF;
    END IF;
    --
    -- Busca quantidade de dias da carencia
    EMPR0011.pc_busca_qtd_dias_carencia(pr_idcarencia => rw_crawepr.idcarenc
                                       ,pr_qtddias    => vr_qtdias_carencia
                                       ,pr_cdcritic   => vr_cdcritic
                                       ,pr_dscritic   => vr_dscritic);
    -- Se retornou erro
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    -- Calcula o IOF
    TIOF0001.pc_calcula_iof_epr(pr_cdcooper        => vr_cdcooper
                               ,pr_nrdconta        => vr_nrdconta
                               ,pr_nrctremp        => vr_nrctremp
                               ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                               ,pr_inpessoa        => pr_inpessoa
                               ,pr_cdfinemp        => rw_crawepr.cdfinemp
                               ,pr_cdlcremp        => rw_crawepr.cdlcremp
                               ,pr_qtpreemp        => rw_crawepr.qtpreemp
                               ,pr_vlpreemp        => rw_crawepr.vlpreemp
                               ,pr_vlemprst        => rw_crawepr.vlemprst
                               ,pr_dtdpagto        => rw_crawepr.dtdpagto
                               ,pr_dtlibera        => rw_crawepr.dtlibera
                               ,pr_tpemprst        => rw_crawepr.tpemprst
                               ,pr_dtcarenc        => rw_crawepr.dtcarenc
                               ,pr_qtdias_carencia => vr_qtdias_carencia
                               ,pr_dscatbem        => vr_dsbemgar
                               ,pr_idfiniof        => rw_crawepr.idfiniof
                               ,pr_idgravar        => 'N'                                 
                               ,pr_vlpreclc        => vr_vlpreclc
                               ,pr_valoriof        => vr_vltariof
                               ,pr_vliofpri        => vr_vliofpri
                               ,pr_vliofadi        => vr_vliofadi
                               ,pr_flgimune        => vr_flgimune
                               ,pr_dscritic        => vr_dscritic);
    -- Se ocorreu erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := vr_dscritic ||' - calculo IOF credito online PP';
      RAISE vr_exc_erro;
    END IF;
    IF nvl(rw_crawepr.idfiniof,0) = 0 THEN
      -- Condicao para verificar se possui valor do IOF
      IF vr_vltariof > 0 THEN
        -- Operacao de Financiamento
        IF vr_floperac THEN
          --Codigo historico PP
          vr_cdhistor := 2309;
        ELSE
          --Codigo historico PP
          vr_cdhistor := 2308;
        END IF;
      
        -- Lanca o IOF na conta corrente do cooperado
        EMPR0001.pc_cria_lancamento_cc_chave(pr_cdcooper => vr_cdcooper   --> Cooperativa conectada
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Movimento atual
                                            ,pr_cdagenci => pr_cdagenci   --> Codigo da agencia
                                            ,pr_cdbccxlt => 100           --> Numero do caixa
                                            ,pr_cdoperad => pr_cdoperad   --> Codigo do Operador
                                            ,pr_cdpactra => pr_cdpactra   --> PA da transacao
                                            ,pr_nrdolote => 10025         --> Numero do Lote
                                            ,pr_nrdconta => vr_nrdconta   --> Numero da conta
                                            ,pr_cdhistor => vr_cdhistor   --> Codigo historico
                                            ,pr_vllanmto => vr_vltariof   --> Valor de IOF
                                            ,pr_nrparepr => 0             --> Numero parcelas emprestimo
                                            ,pr_nrctremp => vr_nrctremp   --> Numero do contrato de emprestimo
                                            ,pr_nrseqdig => vr_nrseqdig
                                            ,pr_des_reto => vr_des_reto   --> Retorno OK / NOK
                                            ,pr_tab_erro => vr_tab_erro); --> Tabela com possives erros
        -- Se ocorreu erro
        IF vr_des_reto <> 'OK' THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar o lancamento de IOF na conta.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
          
        BEGIN
          UPDATE crapcot
             SET crapcot.vliofepr = crapcot.vliofepr + vr_vltariof
                ,crapcot.vlbsiepr = crapcot.vlbsiepr + rw_crawepr.vlemprst
           WHERE crapcot.cdcooper = vr_cdcooper
             AND crapcot.nrdconta = vr_nrdconta;
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a crapcot: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
          
      END IF;
        
      -- Insere registro de pagamento de IOF na tbgen_iof_lancamento
      tiof0001.pc_insere_iof(pr_cdcooper     => vr_cdcooper
                            ,pr_nrdconta     => vr_nrdconta
                            ,pr_dtmvtolt     => rw_crapdat.dtmvtolt
                            ,pr_tpproduto    => 1 -- Emprestimo
                            ,pr_nrcontrato   => vr_nrctremp
                            ,pr_idlautom     => null
                            ,pr_dtmvtolt_lcm => rw_crapdat.dtmvtolt
                            ,pr_cdagenci_lcm => pr_cdpactra
                            ,pr_cdbccxlt_lcm => 100
                            ,pr_nrdolote_lcm => 10025
                            ,pr_nrseqdig_lcm => vr_nrseqdig
                            ,pr_vliofpri     => vr_vliofpri
                            ,pr_vliofadi     => vr_vliofadi
                            ,pr_vliofcpl     => 0
                            ,pr_flgimune     => vr_flgimune
                            ,pr_cdcritic     => vr_cdcritic 
                            ,pr_dscritic     => vr_dscritic);

      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;     
    --
    -- Obter Saldo do Dia
    EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => vr_cdcooper
                               ,pr_rw_crapdat => rw_crapdat
                               ,pr_cdagenci   => pr_cdagenci
                               ,pr_nrdcaixa   => pr_nrdcaixa
                               ,pr_cdoperad   => pr_cdoperad
                               ,pr_nrdconta   => vr_nrdconta
                               ,pr_flgcrass   => FALSE
                               ,pr_vllimcre   => rw_crapass.vllimcre
                               ,pr_dtrefere   => rw_crapdat.dtmvtolt
                               ,pr_des_reto   => vr_des_reto
                               ,pr_tab_sald   => vr_tab_saldos
                               ,pr_tipo_busca => 'A'
                               ,pr_tab_erro   => vr_tab_erro);
    IF vr_tab_saldos.COUNT() > 0 THEN
      -- Saldo Disponivel
      vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_tab_saldos.FIRST).vlsddisp, 0) +
                           NVL(vr_tab_saldos(vr_tab_saldos.FIRST).vllimcre, 0),2);
    END IF;
    

    vr_vlrtarif := 0;
    vr_vltrfesp := 0;
    vr_vltrfgar := 0;
    -- Calcular a tarifa    
    TARI0001.pc_calcula_tarifa(pr_cdcooper => vr_cdcooper , 
                               pr_nrdconta => vr_nrdconta, 
                               pr_cdlcremp => rw_crawepr.cdlcremp, 
                               pr_vlemprst => rw_crawepr.vlemprst, 
                               pr_cdusolcr => rw_craplcr.cdusolcr, 
                               pr_tpctrato => rw_craplcr.tpctrato, 
                               pr_dsbemgar => vr_dsbemgar, 
                               pr_cdprogra => pr_cdprogra, 
                               pr_flgemail => 'N', 
                               pr_tpemprst => rw_crawepr.tpemprst,
                               pr_idfiniof => rw_crawepr.idfiniof,
                               pr_vlrtarif => vr_vlrtarif, 
                               pr_vltrfesp => vr_vltrfesp, 
                               pr_vltrfgar => vr_vltrfgar, 
                               pr_cdhistor => vr_cdhistor, 
                               pr_cdfvlcop => vr_cdfvlcop, 
                               pr_cdhisgar => vr_cdhisgar, 
                               pr_cdfvlgar => vr_cdfvlgar, 
                               pr_cdcritic => vr_cdcritic, 
                               pr_dscritic => vr_dscritic);
                                             
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic:= 0;
      vr_dscritic:= vr_dscritic ||' credito online PP';
    END IF;    
    -- Total Tarifa a ser Cobrado
    vr_vltottar := NVL(vr_vlrtarif,0) + NVL(vr_vltrfesp,0);
    IF vr_vltottar > 0 AND nvl(rw_crawepr.idfiniof,0) = 0 THEN
      -- Se possuir saldo
      IF vr_vlsldisp > vr_vltottar THEN
        -- Realizar lancamento tarifa
        TARI0001.pc_lan_tarifa_online(pr_cdcooper => vr_cdcooper   -- Codigo Cooperativa
                                     ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                     ,pr_nrdconta => vr_nrdconta   -- Numero da Conta Destino
                                     ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                     ,pr_nrdolote => 8452          -- Numero do Lote
                                     ,pr_tplotmov => 1             -- Tipo Lote
                                     ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                     ,pr_dtmvtlat => rw_crapdat.dtmvtolt   -- Data Tarifa
                                     ,pr_dtmvtlcm => rw_crapdat.dtmvtolt   -- Data lancamento
                                     ,pr_nrdctabb => vr_nrdconta   -- Numero Conta BB
                                     ,pr_nrdctitg => TO_CHAR(vr_nrdconta,'fm00000000') -- Conta Integracao
                                     ,pr_cdhistor => vr_cdhistor   -- Codigo Historico
                                     ,pr_cdpesqbb => vr_nrctremp   -- Codigo pesquisa
                                     ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                     ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                     ,pr_nrctachq => 0             -- Numero Conta Cheque
                                     ,pr_flgaviso => FALSE         -- Flag Aviso
                                     ,pr_tpdaviso => 0             -- Tipo Aviso
                                     ,pr_vltarifa => vr_vltottar   -- Valor tarifa
                                     ,pr_nrdocmto => vr_nrctremp   -- Numero Documento
                                     ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                     ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                     ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                     ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                     ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                     ,pr_dsidenti => NULL          -- Descricao Identificacao
                                     ,pr_cdfvlcop => vr_cdfvlcop   -- Codigo Faixa Valor Cooperativa
                                     ,pr_inproces => 1             -- Indicador Processo
                                     ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                     ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                     ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                     ,pr_dscritic => vr_dscritic); -- Descricao do erro
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel lancar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
      
      ELSE
        -- Criar lancamento automatico de tarifa
        TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => vr_cdcooper
                                        ,pr_nrdconta      => vr_nrdconta
                                        ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                        ,pr_cdhistor      => vr_cdhistor
                                        ,pr_vllanaut      => vr_vltottar
                                        ,pr_cdoperad      => pr_cdoperad
                                        ,pr_cdagenci      => pr_cdagenci
                                        ,pr_cdbccxlt 	    => 100
                                        ,pr_nrdolote      => 8452
                                        ,pr_tpdolote      => 1
                                        ,pr_nrdocmto      => vr_nrctremp
                                        ,pr_nrdctabb      => vr_nrdconta
                                        ,pr_nrdctitg      => GENE0002.fn_mask(vr_nrdconta,'99999999')
                                        ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(vr_nrctremp)
                                        ,pr_cdbanchq      => 0
                                        ,pr_cdagechq      => 0
                                        ,pr_nrctachq      => 0
                                        ,pr_flgaviso      => FALSE
                                        ,pr_tpdaviso      => 0
                                        ,pr_cdfvlcop      => vr_cdfvlcop
                                        ,pr_inproces      => 1
                                        ,pr_rowid_craplat => vr_rowid
                                        ,pr_tab_erro      => vr_tab_erro
                                        ,pr_cdcritic      => vr_cdcritic
                                        ,pr_dscritic      => vr_dscritic);
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Subtrai do saldo o valor da tarifa
        vr_vlsldisp := vr_vlsldisp - vr_vltottar;

      END IF; -- vr_vlsldisp > vr_vltottar

    END IF; 
    --
    -- Lancamento das tarifas de garantia
    IF rw_crawepr.idfiniof = 0 AND vr_vltrfgar > 0 THEN
      IF vr_vlsldisp > vr_vltrfgar THEN
        -- Realizar lancamento tarifa online 
        TARI0001.pc_lan_tarifa_online(pr_cdcooper => vr_cdcooper   -- Codigo Cooperativa
                                     ,pr_cdagenci => pr_cdagenci   -- Codigo Agencia destino
                                     ,pr_nrdconta => vr_nrdconta   -- Numero da Conta Destino
                                     ,pr_cdbccxlt => 100           -- Codigo banco/caixa
                                     ,pr_nrdolote => 8452          -- Numero do Lote
                                     ,pr_tplotmov => 1             -- Tipo Lote
                                     ,pr_cdoperad => pr_cdoperad   -- Codigo Operador
                                     ,pr_dtmvtlat => rw_crapdat.dtmvtolt -- Data Tarifa
                                     ,pr_dtmvtlcm => rw_crapdat.dtmvtolt -- Data lancamento
                                     ,pr_nrdctabb => vr_nrdconta   -- Numero Conta BB
                                     ,pr_nrdctitg => TO_CHAR(vr_nrdconta,'fm00000000') -- Conta Integracao
                                     ,pr_cdhistor => vr_cdhisgar   -- Codigo Historico
                                     ,pr_cdpesqbb => vr_nrctremp   -- Codigo pesquisa
                                     ,pr_cdbanchq => 0             -- Codigo Banco Cheque
                                     ,pr_cdagechq => 0             -- Codigo Agencia Cheque
                                     ,pr_nrctachq => 0             -- Numero Conta Cheque
                                     ,pr_flgaviso => FALSE         -- Flag Aviso
                                     ,pr_tpdaviso => 0             -- Tipo Aviso
                                     ,pr_vltarifa => vr_vltrfgar   -- Valor tarifa
                                     ,pr_nrdocmto => vr_nrctremp   -- Numero Documento
                                     ,pr_cdcoptfn => 0             -- Codigo Cooperativa Terminal
                                     ,pr_cdagetfn => 0             -- Codigo Agencia Terminal
                                     ,pr_nrterfin => 0             -- Numero Terminal Financeiro
                                     ,pr_nrsequni => 0             -- Numero Sequencial Unico
                                     ,pr_nrautdoc => 0             -- Numero Autenticacao Documento
                                     ,pr_dsidenti => NULL          -- Descricao Identificacao
                                     ,pr_cdfvlcop => vr_cdfvlgar   -- Codigo Faixa Valor Cooperativa
                                     ,pr_inproces => 1             -- Indicador Processo
                                     ,pr_cdlantar => vr_cdlantar   -- Codigo Lancamento tarifa
                                     ,pr_tab_erro => vr_tab_erro   -- Tabela de erro
                                     ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                     ,pr_dscritic => vr_dscritic); -- Descricao do erro
        -- Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui algum erro na tabela de erros
          IF vr_tab_erro.COUNT() > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel lancar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;      
      ELSE  -- Criar lancamento automatico de tarifa
        TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => vr_cdcooper
                                        ,pr_nrdconta      => vr_nrdconta
                                        ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                        ,pr_cdhistor      => vr_cdhisgar
                                        ,pr_vllanaut      => vr_vltrfgar
                                        ,pr_cdoperad      => '1'
                                        ,pr_cdagenci      => 1
                                        ,pr_cdbccxlt      => 100
                                        ,pr_nrdolote      => 8452
                                        ,pr_tpdolote      => 1
                                        ,pr_nrdocmto      => vr_nrctremp
                                        ,pr_nrdctabb      => vr_nrdconta
                                        ,pr_nrdctitg      => gene0002.fn_mask(vr_nrdconta,'99999999')
                                        ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(vr_nrctremp)
                                        ,pr_cdbanchq      => 0
                                        ,pr_cdagechq      => 0
                                        ,pr_nrctachq      => 0
                                        ,pr_flgaviso      => FALSE
                                        ,pr_tpdaviso      => 0
                                        ,pr_cdfvlcop      => vr_cdfvlgar
                                        ,pr_inproces      => rw_crapdat.inproces
                                        ,pr_rowid_craplat => vr_rowid
                                        ,pr_tab_erro      => vr_tab_erro
                                        ,pr_cdcritic      => vr_cdcritic
                                        ,pr_dscritic      => vr_dscritic
                                        );
            
        -- Se ocorreu erro
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui erro no vetor
          IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro no lancamento aut. tarifa adtivo.';
          END IF;
          RAISE vr_exc_erro;                                   
        END IF;
      END IF;
    END IF;  

    -- Total Tarifa a ser Cobrado
    vr_vltottar := NVL(vr_vltottar,0) + NVL(vr_vltrfgar,0);
    -- Retorna as tarifas
    pr_vltottar := NVL(vr_vltottar, 0);
    pr_vltariof := NVL(vr_vltariof, 0);      
    
    --COMMIT;
    
  EXCEPTION
    WHEN vr_exc_sair THEN
      NULL;
    WHEN vr_exc_erro THEN -- Exceção para tratar erros
      -- Apenas retornar a variavel de saida
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN -- Erro geral rotina
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic ||' '||SQLERRM;
  END pc_credito_online_pp;


END EMPR0016;
/
