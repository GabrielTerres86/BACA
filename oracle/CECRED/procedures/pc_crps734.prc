CREATE OR REPLACE PROCEDURE CECRED.pc_crps734(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps734
     Sistema : Crédito - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Lucas Lazari (GFT)
     Data    : Junho/2018                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diaria.
     Objetivo  : Atualizar o saldo devedor de títulos vencidos descontados.

     Alteracoes: 

  ............................................................................ */
  DECLARE

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Codigo do programa
    vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'CRPSXXX';

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------
    -- Cursor generico de calendario
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

    --  Busca todos os títulos liberados que estão vencidos
    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT craptdb.ROWID,
             craptdb.nrdconta,
             craptdb.dtvencto,
             craptdb.nrborder,
             craptdb.cdbandoc,
             craptdb.nrcnvcob,
             craptdb.nrdctabb,
             craptdb.nrdocmto
        FROM craptdb, crapbdt
       WHERE craptdb.cdcooper =  crapbdt.cdcooper
         AND craptdb.nrdconta =  crapbdt.nrdconta
         AND craptdb.nrborder =  crapbdt.nrborder
         AND craptdb.cdcooper =  pr_cdcooper
         AND craptdb.dtvencto <= pr_dtmvtolt
         AND craptdb.insittit =  4  -- liberado
         AND crapbdt.flverbor =  1; -- bordero liberado na nova versão
    
    -- Busca o borderô para verificar a qual versão ele pertence
    /*
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                      ,pr_nrborder IN crapbdt.nrborder%type) IS
      SELECT crapbdt.flverbor
        FROM crapbdt
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;
    */ 
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    TYPE typ_reg_craptdb IS RECORD
      (vlmtatit craptdb.vlmtatit%TYPE
      ,vlmratit craptdb.vlmratit%TYPE
      ,vlioftit craptdb.vliofcpl%TYPE
      ,vr_rowid ROWID);
      
    TYPE typ_tab_craptdb IS TABLE OF typ_reg_craptdb INDEX BY PLS_INTEGER;
    vr_tab_craptdb  typ_tab_craptdb;
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_index            PLS_INTEGER;
    
    vr_vlmtatit NUMBER;
    vr_vlmratit NUMBER;
    vr_vlioftit NUMBER;
    vr_qtdiaatr NUMBER;
    
  BEGIN
    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                              ,pr_action => NULL);

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    -- Leitura do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      vr_cdcritic := 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_saida;
    END IF;
    CLOSE BTCH0001.cr_crapdat;
    
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
    
    --
    /* 
    IF rw_craptdb.dtvencto > rw_crapdat.dtmvtolt AND rw_craptdb.dtvencto < rw_crapdat.dtmvtopr THEN
      CONTINUE;
    END IF;
    */
    
    vr_qtdiaatr := (rw_crapdat.dtmvtopr - rw_crapdat.dtmvtolt);
    
    
    -- Loop principal dos títulos vencidos
    FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      
      -- Calcula os valores de atraso do título    
      DSCT0003.pc_calcula_atraso_tit(pr_cdcooper => pr_cdcooper    
                                    ,pr_nrdconta => rw_craptdb.nrdconta    
                                    ,pr_nrborder => rw_craptdb.nrborder    
                                    ,pr_cdbandoc => rw_craptdb.cdbandoc    
                                    ,pr_nrdctabb => rw_craptdb.nrdctabb    
                                    ,pr_nrcnvcob => rw_craptdb.nrcnvcob    
                                    ,pr_nrdocmto => rw_craptdb.nrdocmto    
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt    
                                    ,pr_qtdiaatr => vr_qtdiaatr 
                                    ,pr_vlmtatit => vr_vlmtatit    
                                    ,pr_vlmratit => vr_vlmratit    
                                    ,pr_vlioftit => vr_vlioftit    
                                    ,pr_cdcritic => vr_cdcritic    
                                    ,pr_dscritic => vr_dscritic);
      
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_index := vr_tab_craptdb.COUNT + 1;
      
      vr_tab_craptdb(vr_index).vlmtatit := vr_vlmtatit;
      vr_tab_craptdb(vr_index).vlmratit := vr_vlmratit;
      vr_tab_craptdb(vr_index).vlioftit := vr_vlioftit;
      vr_tab_craptdb(vr_index).vr_rowid := rw_craptdb.ROWID;   
    END LOOP;
    
    -- Atualiza os valores de multa, juros de mora e iof de do atraso do título
    BEGIN
      FORALL idx IN INDICES OF vr_tab_craptdb SAVE EXCEPTIONS
        UPDATE craptdb
           SET craptdb.vlmtatit = vr_tab_craptdb(idx).vlmtatit,    
               craptdb.vlmratit = vr_tab_craptdb(idx).vlmratit,    
               craptdb.vliofcpl = vr_tab_craptdb(idx).vlioftit   
         WHERE ROWID = vr_tab_craptdb(idx).vr_rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
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

END pc_crps734;
/
