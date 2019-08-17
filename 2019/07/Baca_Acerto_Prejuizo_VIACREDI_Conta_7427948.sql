 DECLARE
    --Oque fazer: Realizar um débito no campo bloqueado prejuízo no valor de R$47,53, 
    -- fazer o crédito deste valor no depósito a vista utilizando o histórico 2720. 
    -- Limpar o saldo devedor na tabela do prejuízo está -0,07.
 
    pr_cdcooper   craplcm.cdcooper%TYPE := 1;
    pr_nrdconta   craplcm.nrdconta%TYPE := 7427948;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
  --  pr_cdhistor IN  craplcm.cdhistor%TYPE
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
    pr_vllanmto   craplcm.vllanmto%TYPE := 47.53;
--    pr_nrdctabb   craplcm.nrdctabb%TYPE := 7662050;
    pr_cdcritic   NUMBER;
    pr_dscritic   VARCHAR2(10000);
    vr_nrseqdig       craplot.nrseqdig%TYPE;   -- Aramazena o valor do campo "nrseqdig" da CRAPLOT para referência na CRAPLCM
    vr_tab_retorno    lanc0001.typ_reg_retorno;
    vr_incrineg       INTEGER;

    vr_exc_saida      EXCEPTION;

  BEGIN
    BEGIN
      SELECT dtmvtolt
        INTO pr_dtmvtolt
        FROM crapdat
       WHERE cdcooper = pr_cdcooper;
    EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao buscar DTMVTOLT = '||SQLERRM;
    END;
    --
    prej0003.pc_gera_transf_cta_prj(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_cdoperad => 1
                                   ,pr_vllanmto => pr_vllanmto
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_versaldo => 0 -- pr_versaldo
                                   ,pr_atsldlib => 0 -- pr_atsldlib
                                   ,pr_cdcritic => pr_cdcritic
                                   ,pr_dscritic => pr_dscritic);
    if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
      RAISE vr_exc_saida;
    end if;

    UPDATE tbcc_prejuizo a
       SET vlsdprej = 0
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
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
    rollback;
    RAISE_APPLICATION_ERROR(-20510,pr_dscritic);
  end;