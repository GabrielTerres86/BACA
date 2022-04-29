declare
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  
  
  vr_cdcooper crapcop.cdcooper%TYPE := 13;
  vr_nrdconta crapass.nrdconta%TYPE := 188123;
  vr_nrctremp craplem.nrctremp%TYPE := 102857;
  vr_nrparepr crappep.nrparepr%TYPE := 11;
  
  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_lancamento IS
    SELECT REGEXP_SUBSTR('1041,1705,1708,1711,3027','[^,]+', 1, LEVEL) as vr_cdhistor,
           REGEXP_SUBSTR('7.21,52.92,1.05,0.03,144.80','[^,]+', 1, LEVEL) as vr_vllanmto          
      FROM DUAL
   CONNECT BY REGEXP_SUBSTR('1041,1705,1708,1711,3027','[^,]+', 1, LEVEL) IS NOT NULL;     
  
BEGIN
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
  FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;  
  FOR rw_lancamento IN cr_lancamento LOOP

    EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                                    pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                    pr_cdagenci => rw_crapass.cdagenci,
                                    pr_cdbccxlt => 100,
                                    pr_cdoperad => 1,
                                    pr_cdpactra => rw_crapass.cdagenci,
                                    pr_tplotmov => 5,
                                    pr_nrdolote => 600031,
                                    pr_nrdconta => vr_nrdconta,
                                    pr_cdhistor => TO_NUMBER(rw_lancamento.vr_cdhistor),
                                    pr_nrctremp => vr_nrctremp,
                                    pr_vllanmto => TO_NUMBER(REPLACE(rw_lancamento.vr_vllanmto,',','.'),'9999.99'),
                                    pr_dtpagemp => rw_crapdat.dtmvtolt,
                                    pr_txjurepr => 0,
                                    pr_vlpreemp => 0,
                                    pr_nrsequni => 0,
                                    pr_nrparepr => case when TO_NUMBER(rw_lancamento.vr_cdhistor) = 1041
                                                     then null 
                                                     else vr_nrparepr
                                                 end,
                                    pr_flgincre => FALSE,
                                    pr_flgcredi => FALSE,
                                    pr_nrseqava => 0,
                                    pr_cdorigem => 5,
                                    pr_cdcritic => vr_cdcritic,
                                    pr_dscritic => vr_dscritic);
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  END LOOP;  
  
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
