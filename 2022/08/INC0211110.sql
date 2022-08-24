DECLARE
  vr_cdcritic CECRED.crapcri.cdcritic%TYPE;
  vr_dscritic CECRED.crapcri.dscritic%TYPE;

  PROCEDURE pc_efetiva_reg_pendentes(pr_dtprocesso IN DATE
                                    ,pr_cdcritic   OUT CECRED.crapcri.cdcritic%TYPE
                                    ,pr_dscritic   OUT VARCHAR2) IS
  
    vr_tab_retorno LANC0001.typ_reg_retorno;
    vr_incrineg    INTEGER;
  
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    CURSOR cr_lancamento IS
      SELECT arq.idarquivo
            ,arq.nmarquivo_origem
            ,lct.nrcnpj_credenciador
            ,lct.nrcnpjbase_principal
            ,arq.tparquivo
            ,to_date(arq.dtreferencia, 'YYYY-MM-DD') dtreferencia
            ,lct.dhprocessamento
            ,lct.idlancto
            ,pdv.dtpagamento
            ,pdv.tpforma_transf
            ,SUM(pdv.vlpagamento) vlpagamento
        FROM CECRED.tbdomic_liqtrans_lancto     lct
            ,CECRED.tbdomic_liqtrans_arquivo    arq
            ,CECRED.tbdomic_liqtrans_centraliza ctz
            ,CECRED.tbdomic_liqtrans_pdv        pdv
       WHERE lct.idarquivo = arq.idarquivo
         AND ctz.idlancto = lct.idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND arq.idarquivo IN (602674)
       GROUP BY arq.idarquivo
               ,arq.nmarquivo_origem
               ,lct.nrcnpj_credenciador
               ,lct.nrcnpjbase_principal
               ,arq.tparquivo
               ,to_date(arq.dtreferencia, 'YYYY-MM-DD')
               ,lct.dhprocessamento
               ,lct.idlancto
               ,pdv.dtpagamento
               ,pdv.tpforma_transf
       ORDER BY arq.tparquivo
               ,lct.nrcnpj_credenciador
               ,lct.nrcnpjbase_principal
               ,to_date(arq.dtreferencia, 'YYYY-MM-DD');
  
    CURSOR cr_tabela(pr_idlancto       tbdomic_liqtrans_lancto.idlancto%TYPE
                    ,pr_tpforma_transf tbdomic_liqtrans_pdv.tpforma_transf%TYPE) IS
      SELECT pdv.nrliquidacao
            ,ctz.nrcnpjcpf_centraliza
            ,ctz.tppessoa_centraliza
            ,ctz.cdagencia_centraliza
            ,ctz.nrcta_centraliza
            ,pdv.vlpagamento
            ,to_date(pdv.dtpagamento, 'YYYY-MM-DD') dtpagamento
            ,pdv.idpdv
            ,pdv.cdocorrencia
            ,pdv.cdocorrencia_retorno
            ,pdv.dserro
            ,pdv.dsocorrencia_retorno
        FROM CECRED.tbdomic_liqtrans_centraliza ctz
            ,CECRED.tbdomic_liqtrans_pdv        pdv
            ,CECRED.tbdomic_liqtrans_lancto     lct
            ,CECRED.tbdomic_liqtrans_arquivo    arq
       WHERE ctz.idlancto = pr_idlancto
         AND pdv.idcentraliza = ctz.idcentraliza
         AND lct.idarquivo = arq.idarquivo
         AND ctz.idlancto = lct.idlancto
         AND pdv.tpforma_transf = pr_tpforma_transf
         AND arq.idarquivo IN (602674)
         AND NVL(pdv.cdocorrencia, '00') = '00'
       ORDER BY ctz.cdagencia_centraliza
               ,ctz.nrcta_centraliza
               ,to_date(pdv.dtpagamento, 'YYYY-MM-DD');
  
    CURSOR cr_crapcop IS
      SELECT cdcooper
            ,cdagectl
            ,nmrescop
            ,flgativo
        FROM CECRED.crapcop;
  
    CURSOR cr_craptco(pr_cdcopant IN CECRED.crapcop.cdcooper%TYPE
                     ,pr_nrctaant IN craptco.nrctaant%TYPE) IS
      SELECT tco.nrdconta
            ,tco.cdcooper
        FROM CECRED.craptco tco
       WHERE tco.cdcopant = pr_cdcopant
         AND tco.nrctaant = pr_nrctaant;
    rw_craptco cr_craptco%ROWTYPE;
  
    TYPE typ_crapcop IS RECORD(
      cdcooper CECRED.crapcop.cdcooper%TYPE,
      nmrescop CECRED.crapcop.nmrescop%TYPE,
      flgativo CECRED.crapcop.flgativo%TYPE);
    TYPE typ_tab_crapcop IS TABLE OF typ_crapcop INDEX BY PLS_INTEGER;
    vr_crapcop typ_tab_crapcop;
  
    vr_cdcritic CECRED.crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(32000);
  
    vr_exc_saida EXCEPTION;
    vr_erro      EXCEPTION;
  
    vr_nrseqdiglcm   CECRED.craplcm.nrseqdig%TYPE;
    vr_nrseqdiglau   CECRED.craplau.nrseqdig%TYPE;
    vr_dserro        VARCHAR2(100);
    vr_dserro_arq    VARCHAR2(100);
    vr_cdocorr       VARCHAR2(2) := NULL;
    vr_cdocorr_arq   VARCHAR2(2) := NULL;
    vr_inpessoa      CECRED.crapass.inpessoa%TYPE;
    vr_cdcooper      CECRED.crapcop.cdcooper%TYPE;
    vr_cdhistor      CECRED.craphis.cdhistor%TYPE;
    vr_nrdolote      CECRED.craplcm.nrdolote%TYPE;
    vr_qterros       PLS_INTEGER := 0;
    vr_qtprocessados PLS_INTEGER := 0;
    vr_qtfuturos     PLS_INTEGER := 0;
    vr_inlctfut      VARCHAR2(01);
  
    vr_coopdest     CECRED.crapcop.cdcooper%TYPE;
    vr_nrdconta     NUMBER(25);
    vr_cdcooper_lcm CECRED.craplcm.cdcooper%TYPE;
    vr_cdcooper_lau CECRED.craplau.cdcooper%TYPE;
    vr_dtprocesso   CECRED.crapdat.dtmvtolt%TYPE;
    vr_qtproclancto PLS_INTEGER := 0;
  
    vr_para     VARCHAR2(300);
    vr_assunto  VARCHAR2(300);
    vr_mensagem VARCHAR2(32767);
  BEGIN
  
    FOR rw_crapcop IN cr_crapcop LOOP
      vr_crapcop(rw_crapcop.cdagectl).cdcooper := rw_crapcop.cdcooper;
      vr_crapcop(rw_crapcop.cdagectl).nmrescop := rw_crapcop.nmrescop;
      vr_crapcop(rw_crapcop.cdagectl).flgativo := rw_crapcop.flgativo;
    END LOOP;
  
    FOR rw_lancamento IN cr_lancamento LOOP
    
      vr_cdcooper_lcm := 0;
      vr_cdcooper_lau := 0;
      vr_dserro_arq   := NULL;
      vr_cdocorr_arq  := NULL;
    
      IF rw_lancamento.tparquivo NOT IN (1, 2, 3) THEN
        vr_dserro_arq  := 'Tipo de arquivo (' || rw_lancamento.tparquivo || ') nao previsto.';
        vr_cdocorr_arq := '99';
      END IF;
    
      vr_qtproclancto := 0;
    
      FOR rw_tabela IN cr_tabela(rw_lancamento.idlancto, rw_lancamento.tpforma_transf) LOOP
      
        vr_dserro       := NULL;
        vr_cdocorr      := NULL;
        vr_qtproclancto := vr_qtproclancto + 1;
      
        BEGIN
        
          IF vr_crapcop(rw_tabela.cdagencia_centraliza).flgativo = 0 THEN
          
            OPEN cr_craptco(pr_cdcopant => vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper,
                            pr_nrctaant => rw_tabela.nrcta_centraliza);
            FETCH cr_craptco
              INTO rw_craptco;
          
            IF cr_craptco%FOUND THEN
              vr_nrdconta := rw_craptco.nrdconta;
              vr_coopdest := rw_craptco.cdcooper;
            ELSE
              vr_nrdconta := 0;
              vr_coopdest := 0;
            END IF;
          
            CLOSE cr_craptco;
          
          ELSE
            vr_nrdconta := rw_tabela.nrcta_centraliza;
            vr_coopdest := vr_crapcop(rw_tabela.cdagencia_centraliza).cdcooper;
          END IF;
        
          OPEN btch0001.cr_crapdat(vr_coopdest);
          FETCH btch0001.cr_crapdat
            INTO rw_crapdat;
          CLOSE btch0001.cr_crapdat;
        
          IF pr_dtprocesso IS NULL THEN
            IF rw_crapdat.inproces > 1 THEN
              vr_dtprocesso := rw_crapdat.dtmvtopr;
            ELSE
              vr_dtprocesso := rw_crapdat.dtmvtolt;
            END IF;
          ELSE
            vr_dtprocesso := trunc(nvl(pr_dtprocesso, SYSDATE));
          END IF;
        
        EXCEPTION
          WHEN vr_erro THEN
            NULL;
        END;
      
        vr_nrdolote := 9666;
      
        IF rw_lancamento.tparquivo = 1 THEN
          IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN
            vr_cdhistor := 2444;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01027058000191 THEN
            vr_cdhistor := 2546;
          ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN
            vr_cdhistor := 2443;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN
            vr_cdhistor := 2442;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN
            vr_cdhistor := 2450;
          ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN
            vr_cdhistor := 2453;
          ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN
            vr_cdhistor := 2478;
          ELSIF rw_lancamento.nrcnpj_credenciador = 28127603000178 THEN
            vr_cdhistor := 2484;
          ELSIF rw_lancamento.nrcnpj_credenciador = 60114865000100 THEN
            vr_cdhistor := 2485;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01722480000167 THEN
            vr_cdhistor := 2486;
          ELSIF rw_lancamento.nrcnpj_credenciador = 04670195000138 THEN
            vr_cdhistor := 2487;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08561701000101 THEN
            vr_cdhistor := 2488;
          ELSIF rw_lancamento.nrcnpj_credenciador = 10440482000154 THEN
            vr_cdhistor := 2489;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17887874000105 THEN
            vr_cdhistor := 2490;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20520298000178 THEN
            vr_cdhistor := 2491;
          ELSIF rw_lancamento.nrcnpj_credenciador = 58160789000128 THEN
            vr_cdhistor := 2492;
          ELSIF rw_lancamento.nrcnpj_credenciador = 19250003000101 THEN
            vr_cdhistor := 2843;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08965639000113 THEN
            vr_cdhistor := 2844;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17768068000118 THEN
            vr_cdhistor := 2845;
          ELSIF rw_lancamento.nrcnpj_credenciador = 18577728000146 THEN
            vr_cdhistor := 2846;
          ELSIF rw_lancamento.nrcnpj_credenciador = 22121209000146 THEN
            vr_cdhistor := 2847;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16668076000120 THEN
            vr_cdhistor := 2848;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20250105000106 THEN
            vr_cdhistor := 2849;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14380200000121 THEN
            vr_cdhistor := 2850;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14625224000101 THEN
            vr_cdhistor := 2851;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20551972000181 THEN
            vr_cdhistor := 2852;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787003383 THEN
            vr_cdhistor := 2853;
          ELSE
            vr_cdhistor := 2445;
          END IF;
        ELSIF rw_lancamento.tparquivo = 2 THEN
          IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN
            vr_cdhistor := 2448;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01027058000191 THEN
            vr_cdhistor := 2547;
          ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN
            vr_cdhistor := 2447;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN
            vr_cdhistor := 2446;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN
            vr_cdhistor := 2451;
          ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN
            vr_cdhistor := 2413;
          ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN
            vr_cdhistor := 2479;
          ELSIF rw_lancamento.nrcnpj_credenciador = 28127603000178 THEN
            vr_cdhistor := 2493;
          ELSIF rw_lancamento.nrcnpj_credenciador = 60114865000100 THEN
            vr_cdhistor := 2494;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01722480000167 THEN
            vr_cdhistor := 2495;
          ELSIF rw_lancamento.nrcnpj_credenciador = 04670195000138 THEN
            vr_cdhistor := 2496;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08561701000101 THEN
            vr_cdhistor := 2497;
          ELSIF rw_lancamento.nrcnpj_credenciador = 10440482000154 THEN
            vr_cdhistor := 2498;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17887874000105 THEN
            vr_cdhistor := 2499;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20520298000178 THEN
            vr_cdhistor := 2500;
          ELSIF rw_lancamento.nrcnpj_credenciador = 58160789000128 THEN
            vr_cdhistor := 2501;
          ELSIF rw_lancamento.nrcnpj_credenciador = 19250003000101 THEN
            vr_cdhistor := 2854;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08965639000113 THEN
            vr_cdhistor := 2855;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17768068000118 THEN
            vr_cdhistor := 2856;
          ELSIF rw_lancamento.nrcnpj_credenciador = 18577728000146 THEN
            vr_cdhistor := 2857;
          ELSIF rw_lancamento.nrcnpj_credenciador = 22121209000146 THEN
            vr_cdhistor := 2858;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16668076000120 THEN
            vr_cdhistor := 2859;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20250105000106 THEN
            vr_cdhistor := 2860;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14380200000121 THEN
            vr_cdhistor := 2861;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14625224000101 THEN
            vr_cdhistor := 2862;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20551972000181 THEN
            vr_cdhistor := 2863;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787003383 THEN
            vr_cdhistor := 2864;
          ELSE
            vr_cdhistor := 2449;
          END IF;
        ELSE
          IF rw_lancamento.nrcnpj_credenciador = 59438325000101 THEN
            vr_cdhistor := 2456;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01027058000191 THEN
            vr_cdhistor := 2548;
          ELSIF rw_lancamento.nrcnpj_credenciador = 02038232000164 THEN
            vr_cdhistor := 2455;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787000104 THEN
            vr_cdhistor := 2454;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16501555000157 THEN
            vr_cdhistor := 2452;
          ELSIF rw_lancamento.nrcnpj_credenciador = 12592831000189 THEN
            vr_cdhistor := 2414;
          ELSIF rw_lancamento.nrcnpj_credenciador = 92934215000106 THEN
            vr_cdhistor := 2480;
          ELSIF rw_lancamento.nrcnpj_credenciador = 28127603000178 THEN
            vr_cdhistor := 2502;
          ELSIF rw_lancamento.nrcnpj_credenciador = 60114865000100 THEN
            vr_cdhistor := 2503;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01722480000167 THEN
            vr_cdhistor := 2504;
          ELSIF rw_lancamento.nrcnpj_credenciador = 04670195000138 THEN
            vr_cdhistor := 2505;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08561701000101 THEN
            vr_cdhistor := 2506;
          ELSIF rw_lancamento.nrcnpj_credenciador = 10440482000154 THEN
            vr_cdhistor := 2507;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17887874000105 THEN
            vr_cdhistor := 2508;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20520298000178 THEN
            vr_cdhistor := 2509;
          ELSIF rw_lancamento.nrcnpj_credenciador = 58160789000128 THEN
            vr_cdhistor := 2510;
          ELSIF rw_lancamento.nrcnpj_credenciador = 19250003000101 THEN
            vr_cdhistor := 2865;
          ELSIF rw_lancamento.nrcnpj_credenciador = 08965639000113 THEN
            vr_cdhistor := 2866;
          ELSIF rw_lancamento.nrcnpj_credenciador = 17768068000118 THEN
            vr_cdhistor := 2867;
          ELSIF rw_lancamento.nrcnpj_credenciador = 18577728000146 THEN
            vr_cdhistor := 2868;
          ELSIF rw_lancamento.nrcnpj_credenciador = 22121209000146 THEN
            vr_cdhistor := 2869;
          ELSIF rw_lancamento.nrcnpj_credenciador = 16668076000120 THEN
            vr_cdhistor := 2870;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20250105000106 THEN
            vr_cdhistor := 2871;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14380200000121 THEN
            vr_cdhistor := 2872;
          ELSIF rw_lancamento.nrcnpj_credenciador = 14625224000101 THEN
            vr_cdhistor := 2873;
          ELSIF rw_lancamento.nrcnpj_credenciador = 20551972000181 THEN
            vr_cdhistor := 2874;
          ELSIF rw_lancamento.nrcnpj_credenciador = 01425787003383 THEN
            vr_cdhistor := 2875;
          ELSE
            vr_cdhistor := 2457;
          END IF;
        END IF;
      
        IF vr_cdocorr IS NULL THEN
        
          vr_cdcooper     := vr_coopdest;
          pr_cdcritic     := NULL;
          vr_dscritic     := NULL;
          vr_cdcooper_lcm := vr_cdcooper;
        
          ccrd0006.pc_procura_ultseq_craplcm(pr_cdcooper    => vr_cdcooper,
                                             pr_dtmvtolt    => vr_dtprocesso,
                                             pr_cdagenci    => 1,
                                             pr_cdbccxlt    => 100,
                                             pr_nrdolote    => vr_nrdolote,
                                             pr_nrseqdiglcm => vr_nrseqdiglcm,
                                             pr_cdcritic    => vr_cdcritic,
                                             pr_dscritic    => vr_dscritic);
        
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        
          BEGIN
            LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => trunc(vr_dtprocesso),
                                               pr_cdagenci    => 1,
                                               pr_cdbccxlt    => 100,
                                               pr_nrdolote    => vr_nrdolote,
                                               pr_nrdconta    => vr_nrdconta,
                                               pr_nrdocmto    => vr_nrseqdiglcm,
                                               pr_cdhistor    => vr_cdhistor,
                                               pr_nrseqdig    => vr_nrseqdiglcm,
                                               pr_vllanmto    => rw_tabela.vlpagamento,
                                               pr_nrdctabb    => vr_nrdconta,
                                               pr_nrdctitg    => GENE0002.fn_mask(vr_nrdconta,
                                                                                  '99999999'),
                                               pr_cdcooper    => vr_cdcooper,
                                               pr_dtrefere    => rw_tabela.dtpagamento,
                                               pr_cdoperad    => 1,
                                               pr_cdpesqbb    => rw_tabela.nrliquidacao,
                                               pr_tab_retorno => vr_tab_retorno,
                                               pr_incrineg    => vr_incrineg,
                                               pr_cdcritic    => vr_cdcritic,
                                               pr_dscritic    => vr_dscritic);
          
            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          EXCEPTION
            WHEN vr_exc_saida THEN
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CRAPLCM: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        
          BEGIN
            UPDATE CECRED.craplau
               SET dtdebito = trunc(vr_dtprocesso)
             WHERE cdcooper = vr_cdcooper
               AND dtmvtopg = rw_tabela.dtpagamento
               AND nrdconta = vr_nrdconta
               AND cdseqtel = rw_tabela.nrliquidacao;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar tabela CRAPLAU - dtdebito : ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        
          vr_qtprocessados := vr_qtprocessados + 1;
        
          vr_dscritic := NULL;
        END IF;
      END LOOP;
    END LOOP;
  
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
    
      ROLLBACK;
      raise_application_error(-20001,
                              'pc_efetiva_reg_pendentes vr_exc_saida' || ' ' || pr_cdcritic || ' ' ||
                              SQLERRM);
    
    WHEN OTHERS THEN
      raise_application_error(-20001, 'pc_efetiva_reg_pendentes ' || SQLERRM);
    
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
    
      ROLLBACK;
    
  END;

BEGIN

  BEGIN
    UPDATE CECRED.tbdomic_liqtrans_lancto
       SET insituacao = 1
     WHERE idarquivo IN (602674);
  END;

  BEGIN
    UPDATE tbdomic_liqtrans_pdv pdv
       SET pdv.DSERRO = NULL
          ,pdv.cdocorrencia = '00'
     WHERE idcentraliza IN (SELECT idcentraliza
                              FROM tbdomic_liqtrans_centraliza
                             WHERE idlancto IN (SELECT idlancto
                                                  FROM tbdomic_liqtrans_lancto
                                                 WHERE idarquivo IN (602674)));
  END;

  pc_efetiva_reg_pendentes(trunc(SYSDATE), vr_cdcritic, vr_dscritic);

  UPDATE CECRED.tbdomic_liqtrans_lancto
     SET insituacao = 2
   WHERE idarquivo IN (602674);

  COMMIT;

END;
