DECLARE
  pr_cdcooper craprac.cdcooper%TYPE := 1;
  pr_dtmvtolt DATE := TRUNC(SYSDATE);
  pr_nrdconta craprac.nrdconta%TYPE := 8996911;
  pr_vlaplica craplac.vllanmto%TYPE := 1000.00;
  pr_nraplica craplac.nraplica%TYPE := 53;
  vr_incrineg      INTEGER;
  vr_tab_retorno   LANC0001.typ_reg_retorno;
  vr_exc_saida EXCEPTION;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  pr_cdcritic crapcri.cdcritic%TYPE;   
  pr_dscritic crapcri.dscritic%TYPE;
       
BEGIN
  BEGIN       
   INSERT INTO craplac
           (CDCOOPER,
            NRDCONTA,
            NRAPLICA,
            CDAGENCI,
            CDBCCXLT,
            DTMVTOLT,
            NRDOLOTE,
            NRDOCMTO,
            NRSEQDIG,
            VLLANMTO,
            CDHISTOR,
            VLRENDIM,
            VLBASREN,
            NRSEQRGT,
            IDLCTCUS,
            CDCANAL)
    VALUES
           (pr_cdcooper,
            pr_nrdconta,
            pr_nraplica,
            1,
            100,
            pr_dtmvtolt,
            8500,
            pr_nraplica,
            9982,
            pr_vlaplica,
            3527,
            0.00,
            0.00,
            6,
            null,
            5);

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro de lancamento CRAPLAC. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

     CECRED.LANC0001.pc_gerar_lancamento_conta(
                          pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 8501
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdctabb => pr_nrdconta
                         ,pr_nrdocmto => pr_nraplica
                         ,pr_nrseqdig => 0
                         ,pr_dtrefere => pr_dtmvtolt
                         ,pr_vllanmto => pr_vlaplica
                         ,pr_cdhistor => 3526
                         ,pr_nraplica => pr_nraplica
                         ,pr_inprolot => 1
                         ,pr_tplotmov => 1
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
               vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' || vr_dscritic;
               RAISE vr_exc_saida;
            END IF;
            
   COMMIT;         
 EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;
END;
