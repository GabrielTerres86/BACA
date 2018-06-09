CREATE OR REPLACE PROCEDURE CECRED.pc_crps736(pr_cdcooper  IN crapcop.cdcooper%TYPE     --> Codigo Cooperativa
                                             ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                             ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps736
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
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS736';
    
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
             craptdb.nrdocmto,
             craptdb.vlmratit,
             craptdb.vlpagmra,
             craptdb.nrtitulo
        FROM craptdb, crapbdt
       WHERE craptdb.cdcooper =  crapbdt.cdcooper
         AND craptdb.nrdconta =  crapbdt.nrdconta
         AND craptdb.nrborder =  crapbdt.nrborder
         AND craptdb.cdcooper =  pr_cdcooper
         AND craptdb.dtvencto <= pr_dtmvtolt
         AND craptdb.insittit =  4  -- liberado
         AND crapbdt.flverbor =  1; -- bordero liberado na nova versão
    
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
    
    -- Loop principal dos títulos vencidos
    FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      
      -- Caso o titulo venca num feriado ou fim de semana, pula pois sera pego no proximo dia util 
      IF rw_craptdb.dtvencto > rw_crapdat.dtmvtoan AND rw_craptdb.dtvencto < rw_crapdat.dtmvtolt THEN
        CONTINUE;
      END IF;
      
      -- Lança os juros de mora mensal na operação de desconto de titulos
      DSCT0003.pc_inserir_lancamento_bordero( pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => rw_craptdb.nrdconta
                                             ,pr_nrborder => rw_craptdb.nrborder
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdhistor => DSCT0003.vr_cdhistordsct_pgtojurosopc
                                             ,pr_vllanmto => (rw_craptdb.vlmratit - rw_craptdb.vlpagmra)
                                             ,pr_cdbandoc => rw_craptdb.cdbandoc
                                             ,pr_nrdctabb => rw_craptdb.nrdctabb
                                             ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                             ,pr_nrdocmto => rw_craptdb.nrdocmto
                                             ,pr_nrtitulo => rw_craptdb.nrtitulo
                                             ,pr_dscritic => vr_dscritic );
      
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
        
    END LOOP;
    
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

END pc_crps736;
/
