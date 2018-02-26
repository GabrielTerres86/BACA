CREATE OR REPLACE PROCEDURE CECRED.pc_crps723(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps723
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Jaison
     Data    : Agosto/2017                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Atualizar saldo das parcelas de todos os contratos do produto Pos-Fixado.

     Alteracoes: 

  ............................................................................ */
  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do programa
    vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'CRPS723';

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
            ,crapepr.qtmesdec
            ,crapepr.qtprecal
            ,crapepr.dtdpagto
            ,crapepr.vlsprojt
            ,crapepr.vlemprst
            ,crapepr.cdlcremp
            ,crapepr.qttolatr
            ,crawepr.txmensal
            ,crawepr.dtdpagto dtprivcto
            ,crapepr.ROWID
        FROM crapepr
        JOIN crawepr
          ON crawepr.cdcooper = crapepr.cdcooper
         AND crawepr.nrdconta = crapepr.nrdconta
         AND crawepr.nrctremp = crapepr.nrctremp
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.tpemprst = 2 -- Pos-Fixado
         AND crapepr.inliquid = 0;

    -- Soma valor pago da parcela
    CURSOR cr_vltotal_pag_par(pr_cdcooper IN crappep.cdcooper%TYPE
                             ,pr_nrdconta IN crappep.nrdconta%TYPE
                             ,pr_nrctremp IN crappep.nrctremp%TYPE) IS	
      SELECT SUM(crappep.vlpagpar)
        FROM crappep
       WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp;
         
    -- Soma valor pago da parcela
    CURSOR cr_vltotal_pago_princ(pr_cdcooper IN crappep.cdcooper%TYPE
                                ,pr_nrdconta IN crappep.nrdconta%TYPE
                                ,pr_nrctremp IN crappep.nrctremp%TYPE
                                ,pr_dtvencto IN crappep.dtvencto%TYPE) IS		
      SELECT SUM(crappep.vlpagpar)
        FROM crappep
       WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.dtvencto >= pr_dtvencto
         AND crappep.vldespar > 0;
         
    -- Soma valor pago da parcela
    CURSOR cr_vltotal_parcela(pr_cdcooper IN crappep.cdcooper%TYPE
                             ,pr_nrdconta IN crappep.nrdconta%TYPE
                             ,pr_nrctremp IN crappep.nrctremp%TYPE
                             ,pr_dtvencto IN crappep.dtvencto%TYPE) IS
      SELECT SUM(crappep.vlparepr)
        FROM crappep
       WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.dtvencto <= pr_dtvencto
         AND crappep.vldespar = 0;
         
    -- Soma valor total de Juros     
    CURSOR cr_vltotal_juros(pr_cdcooper IN crappep.cdcooper%TYPE
                           ,pr_nrdconta IN crappep.nrdconta%TYPE
                           ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
      SELECT SUM(vllanmto)
        FROM craplem 
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp
         AND cdhistor in (2343,2342,2345,2344);
         
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    TYPE typ_reg_crapepr IS RECORD
      (dtdpagto crapepr.dtdpagto%TYPE
      ,qtmesdec crapepr.qtmesdec%TYPE
      ,vlsprojt crapepr.vlsprojt%TYPE
      ,vlsdvctr crapepr.vlsdvctr%TYPE
      ,qtpcalat crapepr.qtpcalat%TYPE
      ,vlsdevat crapepr.vlsdevat%TYPE
      ,vlpapgat crapepr.vlpapgat%TYPE
      ,vlppagat crapepr.vlppagat%TYPE
      ,vr_rowid ROWID);
    TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY PLS_INTEGER;
    vr_tab_crapepr  typ_tab_crapepr;
    
    TYPE typ_reg_crappep IS RECORD
      (cdcooper  crappep.cdcooper%TYPE
      ,nrdconta  crappep.nrdconta%TYPE
      ,nrctremp  crappep.nrctremp%TYPE
      ,nrparepr  crappep.nrparepr%TYPE
      ,vlsdvatu  crappep.vlsdvatu%TYPE
      ,vlmrapar  crappep.vlmrapar%TYPE
      ,vlmtapar  crappep.vlmtapar%TYPE);
    TYPE typ_tab_crappep IS TABLE OF typ_reg_crappep INDEX BY PLS_INTEGER;
    vr_tab_crappep  typ_tab_crappep;

    vr_tab_parcelas EMPR0011.typ_tab_parcelas;

    ------------------------------- VARIAVEIS -------------------------------
    vr_vlsprojt         crapepr.vlsprojt%TYPE;
    vr_flgachou         BOOLEAN;
    vr_dtdpagto         crapepr.dtdpagto%TYPE;
    vr_dtvencto         crappep.dtvencto%TYPE;
    vr_qtmesdec         crapepr.qtmesdec%TYPE;
    vr_index            PLS_INTEGER;
    vr_index_pos        PLS_INTEGER;
    vr_vlsdvctr         NUMBER;
    vr_vlsdevat         NUMBER;
    vr_vlpreapg         NUMBER;
    vr_vlprepag         NUMBER;
    vr_vltotal_juros    NUMBER(25,2);
    vr_vltotal_parcela	NUMBER(25,2);
    vr_vltotal_pago     NUMBER(25,2);
    
    -- Função buscar os meses decorridos
    FUNCTION fn_retorna_meses_decorridos(pr_cdcooper IN crapepr.cdcooper%TYPE             
                                        ,pr_nrdconta IN crapepr.nrdconta%TYPE
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                        ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) 
                                         RETURN NUMBER IS
                                               
      -- Cursor para buscar as parcelas que vencem hoje
      CURSOR cr_crappep (pr_cdcooper IN crapepr.cdcooper%TYPE             
                        ,pr_nrdconta IN crapepr.nrdconta%TYPE
                        ,pr_nrctremp IN crapepr.nrctremp%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                        ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE) IS
        SELECT dtvencto
          from crappep
         WHERE cdcooper  = pr_cdcooper
           AND nrdconta  = pr_nrdconta
           AND nrctremp  = pr_nrctremp
           AND dtvencto <= pr_dtmvtolt
           AND ((crappep.inliquid = 0) OR (crappep.inliquid = 1 AND crappep.dtvencto > pr_dtmvtoan));
    BEGIN        
      FOR rw_crappep IN cr_crappep (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_dtmvtoan => pr_dtmvtoan) LOOP                                   
        -- Condicao para verificar se estah em dia                           
        IF rw_crappep.dtvencto > pr_dtmvtoan THEN
          RETURN 1;
        END IF;
      END LOOP;
      
      RETURN 0;                             
    END;

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

    -- Listagem dos contratos
    FOR rw_crapepr IN cr_crapepr(pr_cdcooper => pr_cdcooper) LOOP
      -- Reseta as variaveis
      vr_qtmesdec        := rw_crapepr.qtmesdec;
      vr_vlsprojt        := rw_crapepr.vlsprojt;
      vr_vlsdvctr        := 0;
      vr_vlsdevat        := 0;
      vr_vlpreapg        := 0;
      vr_vlprepag        := 0;
      vr_vltotal_juros   := 0;
      vr_vltotal_parcela := 0;
      
      -- Busca as parcelas para pagamento
      EMPR0011.pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
                                      ,pr_flgbatch => TRUE
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                      ,pr_nrdconta => rw_crapepr.nrdconta
                                      ,pr_nrctremp => rw_crapepr.nrctremp
                                      ,pr_dtefetiv => rw_crapepr.dtmvtolt
                                      ,pr_cdlcremp => rw_crapepr.cdlcremp
                                      ,pr_vlemprst => rw_crapepr.vlemprst
                                      ,pr_txmensal => rw_crapepr.txmensal
                                      ,pr_dtdpagto => rw_crapepr.dtprivcto
                                      ,pr_vlsprojt => rw_crapepr.vlsprojt
                                      ,pr_qttolatr => rw_crapepr.qttolatr
                                      ,pr_tab_parcelas => vr_tab_parcelas
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
      -- Se houve erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO retornou parcela
      IF vr_tab_parcelas.COUNT = 0 THEN
        vr_dscritic := 'Erro no calculo da parcela.';
        RAISE vr_exc_saida;
      END IF;

      -- Armazena primeiro indice
      vr_index_pos := vr_tab_parcelas.FIRST;
      -- Armazena data de pagamento da primeira parcela
      vr_dtdpagto := vr_tab_parcelas(vr_index_pos).dtvencto;
      -- Percorre as pascelas
      WHILE vr_index_pos IS NOT NULL LOOP
        -- Saldo Contratado
        vr_vlsdvctr := vr_vlsdvctr + vr_tab_parcelas(vr_index_pos).vlatupar;
        -- Saldo devedor atualizado
        vr_vlsdevat := vr_vlsdevat + vr_tab_parcelas(vr_index_pos).vlatupar;
        -- Se estiver 1-Em dia ou 2-Em Atraso
        IF vr_tab_parcelas(vr_index_pos).insitpar IN (1,2) THEN
          vr_vlpreapg := vr_vlpreapg + vr_tab_parcelas(vr_index_pos).vlatupar;
        END IF;
        
        -- Atualiza os valores das Parcelas
        vr_index := vr_tab_crappep.count + 1;
        vr_tab_crappep(vr_index).cdcooper := pr_cdcooper;
        vr_tab_crappep(vr_index).nrdconta := rw_crapepr.nrdconta;
        vr_tab_crappep(vr_index).nrctremp := rw_crapepr.nrctremp;
        vr_tab_crappep(vr_index).nrparepr := vr_tab_parcelas(vr_index_pos).nrparepr;
        vr_tab_crappep(vr_index).vlsdvatu := vr_tab_parcelas(vr_index_pos).vlatupar;        
        vr_tab_crappep(vr_index).vlmrapar := vr_tab_parcelas(vr_index_pos).vlmrapar;
        vr_tab_crappep(vr_index).vlmtapar := vr_tab_parcelas(vr_index_pos).vlmtapar;        
        -- Proximo indice
        vr_index_pos := vr_tab_parcelas.NEXT(vr_index_pos);
      END LOOP;

      -- Busca a soma do valor pago da parcela
      OPEN cr_vltotal_pag_par(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crapepr.nrdconta
                             ,pr_nrctremp => rw_crapepr.nrctremp);
      FETCH cr_vltotal_pag_par INTO vr_vlprepag;
      CLOSE cr_vltotal_pag_par;

      -- Data de Vencimento correspondente do mês
      vr_dtvencto := TO_DATE(TO_CHAR(vr_dtdpagto,'DD')||'/'||TO_CHAR(rw_crapdat.dtmvtolt,'MM')||'/'||TO_CHAR(rw_crapdat.dtmvtolt,'RRRR'),'DD/MM/RRRR');                             
      -- Condicao para verificar se a Parcela vence hoje
      IF vr_dtvencto > rw_crapdat.dtmvtoan AND vr_dtvencto <= rw_crapdat.dtmvtolt THEN
        -- Somar o Valor Total Pago
        vr_vltotal_pago := 0;
        OPEN cr_vltotal_pago_princ(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => rw_crapepr.nrdconta
                                  ,pr_nrctremp => rw_crapepr.nrctremp
                                  ,pr_dtvencto => rw_crapepr.dtprivcto);
        FETCH cr_vltotal_pago_princ INTO vr_vltotal_pago;
        CLOSE cr_vltotal_pago_princ;
      
        -- Somar o Valor Total de Juros de Emprestimo
        vr_vltotal_juros := 0;
        OPEN cr_vltotal_juros(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_crapepr.nrdconta
                             ,pr_nrctremp => rw_crapepr.nrctremp);
        FETCH cr_vltotal_juros INTO vr_vltotal_juros;
        CLOSE cr_vltotal_juros;
      
        -- Somar o valor da parcela ate o momento
        vr_vltotal_parcela := 0;
        OPEN cr_vltotal_parcela(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapepr.nrdconta
                               ,pr_nrctremp => rw_crapepr.nrctremp
                               ,pr_dtvencto => vr_dtvencto);
        FETCH cr_vltotal_parcela INTO vr_vltotal_parcela;
        CLOSE cr_vltotal_parcela;
        
        -- Valor Total do Saldo Projetado
        vr_vlsprojt := NVL(rw_crapepr.vlemprst,0) + NVL(vr_vltotal_juros,0) - NVL(vr_vltotal_parcela,0) - NVL(vr_vltotal_pago,0);
      END IF;            

      -- Calcula os meses decorridos
      vr_qtmesdec := vr_qtmesdec + NVL(fn_retorna_meses_decorridos(pr_cdcooper => pr_cdcooper            
                                                                  ,pr_nrdconta => rw_crapepr.nrdconta
                                                                  ,pr_nrctremp => rw_crapepr.nrctremp
                                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                                  ,pr_dtmvtoan => rw_crapdat.dtmvtoan),0);

      -- Alterar data de pagamento do emprestimo
      vr_index := vr_tab_crapepr.COUNT + 1;
      vr_tab_crapepr(vr_index).dtdpagto := vr_dtdpagto;
      vr_tab_crapepr(vr_index).vlsdvctr := vr_vlsdvctr;
      vr_tab_crapepr(vr_index).qtpcalat := rw_crapepr.qtprecal;
      vr_tab_crapepr(vr_index).vlsdevat := vr_vlsdevat;
      vr_tab_crapepr(vr_index).vlpapgat := vr_vlpreapg;
      vr_tab_crapepr(vr_index).vlppagat := NVL(vr_vlprepag,0);
      vr_tab_crapepr(vr_index).qtmesdec := vr_qtmesdec;
      vr_tab_crapepr(vr_index).vlsprojt := vr_vlsprojt;
      vr_tab_crapepr(vr_index).vr_rowid := rw_crapepr.ROWID;
    END LOOP; -- cr_crapepr
    
    -- Atualizar Parcela Emprestimo
    BEGIN
      FORALL idx IN INDICES OF vr_tab_crappep SAVE EXCEPTIONS
        update crappep
           set vlsdvatu = vr_tab_crappep(idx).vlsdvatu
              ,vlmrapar = vr_tab_crappep(idx).vlmrapar
              ,vlmtapar = vr_tab_crappep(idx).vlmtapar
         where cdcooper = vr_tab_crappep(idx).cdcooper
           AND nrdconta = vr_tab_crappep(idx).nrdconta
           AND nrctremp = vr_tab_crappep(idx).nrctremp
           AND nrparepr = vr_tab_crappep(idx).nrparepr;
    EXCEPTION
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crappep: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        raise vr_exc_saida;
    END;
    
    -- Atualizar Emprestimo
    BEGIN
      FORALL idx IN INDICES OF vr_tab_crapepr SAVE EXCEPTIONS
        UPDATE crapepr
           SET dtdpagto = vr_tab_crapepr(idx).dtdpagto
              ,vlsdvctr = vr_tab_crapepr(idx).vlsdvctr
              ,qtlcalat = 0
              ,qtpcalat = vr_tab_crapepr(idx).qtpcalat
              ,vlsdevat = vr_tab_crapepr(idx).vlsdevat
              ,vlpapgat = vr_tab_crapepr(idx).vlpapgat
              ,vlppagat = vr_tab_crapepr(idx).vlppagat
              ,qtmesdec = vr_tab_crapepr(idx).qtmesdec
              ,qtmdecat = vr_tab_crapepr(idx).qtmesdec
              ,vlsprojt = vr_tab_crapepr(idx).vlsprojt
         WHERE ROWID = vr_tab_crapepr(idx).vr_rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crapepr: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_saida;
    END;

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

END pc_crps723;
/
