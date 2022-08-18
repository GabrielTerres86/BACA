DECLARE
  CURSOR cr_craptdb(pr_cdcooper cecred.craptdb.cdcooper%TYPE
                   ,pr_nrdconta cecred.craptdb.nrdconta%TYPE
                   ,pr_nrborder cecred.craptdb.nrborder%TYPE) IS
    SELECT a.cdcooper
          ,a.nrdconta
          ,a.nrborder
          ,a.cdbandoc
          ,a.nrdctabb
          ,a.nrcnvcob
          ,a.nrdocmto
      FROM cecred.craptdb a
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND a.nrborder = pr_nrborder;

  rw_craptdb  cr_craptdb%ROWTYPE;
  vr_vlpagmto NUMBER := 0;
  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic cecred.crapcri.dscritic%TYPE;
  vr_exception EXCEPTION;
BEGIN
  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 1);
  FETCH cecred.btch0001.cr_crapdat
    INTO cecred.btch0001.rw_crapdat;
  CLOSE cecred.btch0001.cr_crapdat;

  OPEN cr_craptdb(pr_cdcooper => 1
                 ,pr_nrdconta => 7893175
                 ,pr_nrborder => 550327);
  FETCH cr_craptdb
    INTO rw_craptdb;
  CLOSE cr_craptdb;

  cecred.prej0005.pc_pagar_titulo_prejuizo(pr_cdcooper => rw_craptdb.cdcooper,
                                           pr_cdagenci => 1,
                                           pr_nrdcaixa => 100,
                                           pr_cdoperad => 1,
                                           pr_nrdconta => rw_craptdb.nrdconta,
                                           pr_nrborder => rw_craptdb.nrborder,
                                           pr_cdbandoc => rw_craptdb.cdbandoc,
                                           pr_nrdctabb => rw_craptdb.nrdctabb,
                                           pr_nrcnvcob => rw_craptdb.nrcnvcob,
                                           pr_nrdocmto => rw_craptdb.nrdocmto,
                                           pr_dtmvtolt => cecred.btch0001.rw_crapdat.dtmvtolt,
                                           pr_vlpagmto => vr_vlpagmto,
                                           pr_vlaboorj => 972.98,
                                           pr_flgvalac => 1,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
  IF nvl(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exception;
  END IF;

  COMMIT;
EXCEPTION
  WHEN vr_exception THEN
    ROLLBACK;
    raise_application_error(-20500, vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
