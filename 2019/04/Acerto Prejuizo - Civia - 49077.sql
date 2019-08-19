DECLARE
  pr_cdcooper   craplcm.cdcooper%TYPE := 13;
  pr_nrdconta   craplcm.nrdconta%TYPE := 49077;
  pr_dtmvtolt   craplcm.dtmvtolt%TYPE;
--  pr_cdhistor IN  craplcm.cdhistor%TYPE
  pr_cdoperad   craplcm.cdoperad%TYPE := 1;
  pr_nrdocmto   craplcm.nrdocmto%type := 1;
  pr_cdagenci   craplcm.cdagenci%type := 1;
  pr_cdbccxlt   craplcm.cdbccxlt%type := 100;
  pr_vllanmto   craplcm.vllanmto%TYPE := 0.69;
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
  --
  PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
                         , pr_nrdconta => pr_nrdconta
                         , pr_cdoperad => pr_cdoperad
                         , pr_vlrlanc =>  pr_vllanmto
                         , pr_dtmvtolt => pr_dtmvtolt
                         , pr_cdcritic => pr_cdcritic
                         , pr_dscritic => pr_dscritic);
  if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
    RAISE vr_exc_saida;
  end if;
  --
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
