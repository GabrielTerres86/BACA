PL/SQL Developer Test script 3.0
27
DECLARE
  rw_crapdat     btch0001.cr_crapdat%ROWTYPE;

begin

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

  cecred.prej0003.pc_gera_cred_cta_prj(pr_cdcooper => 1,
                                       pr_nrdconta => 2467496,
                                       pr_cdoperad => '',
                                       pr_vlrlanc => 6000,
                                       pr_dtmvtolt => rw_crapdat.Dtmvtolt,
                                       pr_nrdocmto => 6,
                                       pr_dsoperac => 'Acerto Conta Transitoria',
                                       pr_cdcritic => :pr_cdcritic,
                                       pr_dscritic => :pr_dscritic);

UPDATE tbcc_prejuizo_lancamento t
SET t.vllanmto = 200.89
WHERE t.idlancto_prejuizo IN (44665,44666)
;
COMMIT;

end;
9
pr_cdcooper
0
-4
pr_nrdconta
0
-4
pr_cdoperad
0
-5
pr_vlrlanc
0
-4
pr_dtmvtolt
0
-12
pr_nrdocmto
0
-4
pr_dsoperac
0
-5
pr_cdcritic
0
3
pr_dscritic
0
5
2
vr_nrdocmto_prj
pr_vlrlanc
