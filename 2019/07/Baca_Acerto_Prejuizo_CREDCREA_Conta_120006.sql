DECLARE
    pr_cdcooper   craplcm.cdcooper%TYPE := 7;
    pr_nrdconta   craplcm.nrdconta%TYPE := 120006 ;
    pr_vllanmto   craplcm.vllanmto%TYPE := 0.31;
    pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
--    pr_cdhistor IN  craplcm.cdhistor%TYPE
    pr_cdoperad   craplcm.cdoperad%TYPE := 1;
    pr_nrdocmto   craplcm.nrdocmto%type := 1;
    pr_cdagenci   craplcm.cdagenci%type := 1;
    pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
    pr_nrdctabb   craplcm.nrdctabb%TYPE := 56111;
    pr_cdcritic   NUMBER;
    pr_dscritic   VARCHAR2(10000);

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
    -- Efetua lancamento de débito na contra transitória
    BEGIN
      INSERT INTO tbcc_prejuizo_lancamento(dtmvtolt
                                          ,cdagenci
                                          ,nrdconta
                                          ,cdhistor
                                          ,nrdocmto
                                          ,vllanmto
                                          ,dthrtran
                                          ,cdoperad
                                          ,cdcooper
                                          ,dsoperac)
                                    VALUES(pr_dtmvtolt      -- dtmvtolt
                                          ,1                -- cdagenci
                                          ,pr_nrdconta      -- nrdconta
                                          ,2738             -- cdhistor
                                          ,990109           -- nrdocmto
                                          ,pr_vllanmto      -- vllanmto
                                          ,SYSDATE          -- dthrtran
                                          ,pr_cdoperad      -- cdoperad
                                          ,pr_cdcooper
                                          ,0);
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro de insert na TBCC_PREJUIZO_LANCAMENTO:'||SQLERRM;
        RAISE vr_exc_saida;
    END;
    --
    if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
      RAISE vr_exc_saida;
    end if;
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