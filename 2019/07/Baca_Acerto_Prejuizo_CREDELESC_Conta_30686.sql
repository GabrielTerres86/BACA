 DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 8;
    pr_nrdconta   craplcm.nrdconta%TYPE := 30686;
    pr_vllanmto   craplcm.vllanmto%TYPE := 21.46;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
  --  pr_cdhistor IN  craplcm.cdhistor%TYPE
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
  --  pr_nrdctabb IN  craplcm.nrdctabb%TYPE
    pr_cdcritic   NUMBER;
    pr_dscritic   VARCHAR2(10000);
    --
    vr_dthrtran   DATE := SYSDATE;
    vr_idprejuizo tbcc_prejuizo.idprejuizo%TYPE;
    vr_idlancto_prejuizo  tbcc_prejuizo_detalhe.idlancto%TYPE := NULL;    
    --
    vr_exc_saida  EXCEPTION;
  BEGIN
    BEGIN
      SELECT dtmvtolt
        INTO pr_dtmvtolt
        FROM crapdat
       WHERE cdcooper = pr_cdcooper;
    EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao buscar DTMVTOLT = '||SQLERRM;
      RAISE vr_exc_saida;
    END;
    --
    UPDATE tbcc_prejuizo a
       SET vlsdprej = nvl(vlsdprej, 0) - pr_vllanmto
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
    RETURNING a.idprejuizo INTO vr_idprejuizo;
    --
    -- Lança débito referente ao pagamento do prejuízo
    PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_dtmvtolt => pr_dtmvtolt
                            , pr_cdhistor => 2721
                            , pr_idprejuizo => vr_idprejuizo
                            , pr_vllanmto => pr_vllanmto
                            , pr_dthrtran => vr_dthrtran
--    , pr_idlancto_prejuizo => vr_idlancto_prejuizo -- Descomentar para executar no H3                                                                                  
                            , pr_cdcritic => pr_cdcritic
                            , pr_dscritic => pr_dscritic);
    IF NVL(pr_cdcritic,0) > 0
    OR pr_dscritic IS NOT NULL
    THEN
      RAISE vr_exc_saida;
    END IF;
    -- Lança crédito referente ao pagamento do prejuízo
    PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                            , pr_nrdconta => pr_nrdconta
                            , pr_dtmvtolt => pr_dtmvtolt
                            , pr_cdhistor => 2733
                            , pr_idprejuizo => vr_idprejuizo
                            , pr_vllanmto => pr_vllanmto
                            , pr_dthrtran => vr_dthrtran
--    , pr_idlancto_prejuizo => vr_idlancto_prejuizo -- Descomentar para executar no H3                                                                                                              
                            , pr_cdcritic => pr_cdcritic
                            , pr_dscritic => pr_dscritic);
    IF NVL(pr_cdcritic,0) > 0
    OR pr_dscritic IS NOT NULL
    THEN
      RAISE vr_exc_saida;
    END IF;
    -- Valor pago do saldo devedor principal do prejuízo
    PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                           , pr_nrdconta => pr_nrdconta
                           , pr_dtmvtolt => pr_dtmvtolt
                           , pr_cdhistor => 2725
                           , pr_idprejuizo => vr_idprejuizo
                           , pr_vllanmto => pr_vllanmto
                           , pr_dthrtran => vr_dthrtran
--    , pr_idlancto_prejuizo => vr_idlancto_prejuizo -- Descomentar para executar no H3                                                                                                             
                           , pr_cdcritic => pr_cdcritic
                           , pr_dscritic => pr_dscritic);
    IF NVL(pr_cdcritic,0) > 0
    OR pr_dscritic IS NOT NULL
    THEN
      RAISE vr_exc_saida;
    END IF;
	COMMIT;
  EXCEPTION
  WHEN vr_exc_saida THEN
    if pr_cdcritic is not null and pr_dscritic is null then
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    end if;
    rollback;
    RAISE_APPLICATION_ERROR(-20500,pr_dscritic);
  WHEN OTHERS THEN
    pr_dscritic := 'Erro ao atualizar CRAPSLD = '||SQLERRM;
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
  end;