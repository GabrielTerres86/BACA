DECLARE
  pr_dtmvtolt DATE := TRUNC(SYSDATE);
  vr_incrineg    INTEGER;
  vr_tab_retorno LANC0001.typ_reg_retorno;
  vr_exc_saida EXCEPTION;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  pr_cdcritic crapcri.cdcritic%TYPE;
  pr_dscritic crapcri.dscritic%TYPE;

BEGIN
  BEGIN
    FOR CR_APLICACOES IN (SELECT 1  cdcooper ,13098101 nrdconta, 5   nraplica, 601.32  vlaplica FROM dual
                          UNION ALL
                          SELECT 1  cdcooper ,13134043 nrdconta, 40  nraplica, 300     vlaplica FROM dual
                          UNION ALL
                          SELECT 1  cdcooper ,13134043 nrdconta, 39  nraplica ,200     vlaplica FROM dual) LOOP
      BEGIN
        INSERT INTO craplac
          (CDCOOPER
          ,NRDCONTA
          ,NRAPLICA
          ,CDAGENCI
          ,CDBCCXLT
          ,DTMVTOLT
          ,NRDOLOTE
          ,NRDOCMTO
          ,NRSEQDIG
          ,VLLANMTO
          ,CDHISTOR
          ,VLRENDIM
          ,VLBASREN
          ,NRSEQRGT
          ,IDLCTCUS
          ,CDCANAL)
        VALUES
          (CR_APLICACOES.cdcooper
          ,CR_APLICACOES.nrdconta
          ,CR_APLICACOES.nraplica
          ,1
          ,100
          ,pr_dtmvtolt
          ,8500
          ,CR_APLICACOES.nraplica
          ,9982
          ,CR_APLICACOES.vlaplica
          ,3527
          ,0.00
          ,0.00
          ,6
          ,NULL
          ,5);
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro de lancamento CRAPLAC. Erro: ' ||
                         SQLERRM;
          RAISE vr_exc_saida;
      END;
    
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => CR_APLICACOES.cdcooper,
                                                pr_dtmvtolt => pr_dtmvtolt,
                                                pr_cdagenci => 1,
                                                pr_cdbccxlt => 100,
                                                pr_nrdolote => 8501,
                                                pr_nrdconta => CR_APLICACOES.nrdconta,
                                                pr_nrdctabb => CR_APLICACOES.nrdconta,
                                                pr_nrdocmto => CR_APLICACOES.nraplica,
                                                pr_nrseqdig => 0,
                                                pr_dtrefere => pr_dtmvtolt,
                                                pr_vllanmto => CR_APLICACOES.vlaplica,
                                                pr_cdhistor => 3526,
                                                pr_nraplica => CR_APLICACOES.nraplica,
                                                pr_inprolot => 1,
                                                pr_tplotmov => 1,
                                                -- OUTPUT --
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
    
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' ||
                       vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
    END LOOP;
  
    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
  END;
END;
