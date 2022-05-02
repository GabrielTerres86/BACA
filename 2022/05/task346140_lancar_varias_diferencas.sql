DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto VARCHAR(3);
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_nrdconta crapass.nrdconta%TYPE;
  vr_nrctremp craplem.nrctremp%TYPE;
  vr_vllanmto craplem.vllanmto%TYPE;
  vr_cdhistor craplem.cdhistor%TYPE;
  vr_nrparepr craplem.nrparepr%TYPE;
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_lancamentos IS
    SELECT TO_NUMBER(vr_nrdconta) vr_nrdconta
      ,TO_NUMBER(vr_nrctremp) vr_nrctremp
      ,TO_NUMBER(vr_cdcooper) vr_cdcooper
      ,TO_NUMBER(vr_nrparepr) vr_nrparepr
      ,TO_NUMBER(REPLACE(vr_vllanmto, '.', ',')) vr_vllanmto
      ,TO_NUMBER(vr_cdhistor) vr_cdhistor
    FROM (
    SELECT REGEXP_SUBSTR('472700,127388,86347,65242,141690','[^,]+',1,LEVEL) AS vr_nrdconta
       ,REGEXP_SUBSTR('5746041,14405,17154,31517,12363','[^,]+',1,LEVEL) AS vr_nrctremp
       ,REGEXP_SUBSTR('11,10,10,10,10', '[^,]+', 1, LEVEL) AS vr_cdcooper
       ,REGEXP_SUBSTR('0,0,0,0,0', '[^,]+', 1, LEVEL) AS vr_nrparepr
       ,REGEXP_SUBSTR('12406.50,3874.11,7152.42,1232.09,1798.86','[^,]+',1,LEVEL) AS vr_vllanmto
       ,REGEXP_SUBSTR('1040,3917,3917,3917,1040','[^,]+',1,LEVEL) AS vr_cdhistor
     FROM DUAL
    CONNECT BY REGEXP_SUBSTR('472700,127388,86347,65242,141690','[^,]+',1,LEVEL) IS NOT NULL );
  rw_lancamentos cr_lancamentos%ROWTYPE;
BEGIN
  
  FOR rw_lancamentos IN cr_lancamentos LOOP
  
  vr_cdcooper := TO_NUMBER(rw_lancamentos.vr_cdcooper);
  vr_nrdconta := TO_NUMBER(rw_lancamentos.vr_nrdconta);
  vr_nrctremp := TO_NUMBER(rw_lancamentos.vr_nrctremp);
  vr_nrparepr := TO_NUMBER(rw_lancamentos.vr_nrparepr);
  vr_vllanmto := TO_NUMBER(rw_lancamentos.vr_vllanmto);
  vr_cdhistor := TO_NUMBER(rw_lancamentos.vr_cdhistor);
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  OPEN cr_crapass(pr_cdcooper => vr_cdcooper, pr_nrdconta => vr_nrdconta);
    FETCH cr_crapass
    INTO rw_crapass;
  CLOSE cr_crapass;
  
  EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => vr_cdcooper,
                  pr_dtmvtolt => rw_crapdat.dtmvtolt,
                  pr_cdagenci => rw_crapass.cdagenci,
                  pr_cdbccxlt => 100,
                  pr_cdoperad => 1,
                  pr_cdpactra => rw_crapass.cdagenci,
                  pr_tplotmov => 5,
                  pr_nrdolote => 600031,
                  pr_nrdconta => vr_nrdconta,
                  pr_cdhistor => vr_cdhistor,
                  pr_nrctremp => vr_nrctremp,
                  pr_vllanmto => vr_vllanmto,
                  pr_dtpagemp => rw_crapdat.dtmvtolt,
                  pr_txjurepr => 0,
                  pr_vlpreemp => 0,
                  pr_nrsequni => 0,
                  pr_nrparepr => vr_nrparepr,
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