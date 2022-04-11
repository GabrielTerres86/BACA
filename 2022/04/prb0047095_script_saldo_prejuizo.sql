DECLARE

  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  pr_cdcooper craptdb.cdcooper%TYPE := 11;
  pr_nrdconta craptdb.nrdconta%TYPE := 384658;
  pr_nrborder craptdb.nrborder%TYPE := 56196;

  CURSOR cr_craptdb IS
    SELECT tdb.cdcooper
          ,tdb.nrdconta
          ,tdb.nrborder
          ,tdb.vlsdprej
          ,tdb.cdbandoc
          ,tdb.nrdctabb
          ,tdb.nrcnvcob
          ,tdb.nrdocmto
          ,tdb.nrtitulo
      FROM crapbdt bdt
          ,craptdb tdb
     WHERE bdt.cdcooper = pr_cdcooper
       AND bdt.nrdconta = pr_nrdconta
       AND bdt.nrborder = pr_nrborder
       AND bdt.cdcooper = tdb.cdcooper
       AND bdt.nrdconta = tdb.nrdconta
       AND bdt.nrborder = tdb.nrborder
       AND tdb.insittit = 3
       AND bdt.inprejuz = 1;
  rw_craptdb cr_craptdb%ROWTYPE;

BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  OPEN cr_craptdb;
  FETCH cr_craptdb
    INTO rw_craptdb;
  CLOSE cr_craptdb;

  DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => rw_craptdb.cdcooper,
                                         pr_nrdconta => rw_craptdb.nrdconta,
                                         pr_nrborder => rw_craptdb.nrborder,
                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                         pr_cdorigem => 1,
                                         pr_cdhistor => 2689,
                                         pr_vllanmto => rw_craptdb.vlsdprej,
                                         pr_cdbandoc => rw_craptdb.cdbandoc,
                                         pr_nrdctabb => rw_craptdb.nrdctabb,
                                         pr_nrcnvcob => rw_craptdb.nrcnvcob,
                                         pr_nrdocmto => rw_craptdb.nrdocmto,
                                         pr_nrtitulo => rw_craptdb.nrtitulo,
                                         pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NULL THEN
    UPDATE craptdb
       SET vlsdprej = 0
     WHERE cdcooper = rw_craptdb.cdcooper
       AND nrdconta = rw_craptdb.nrdconta
       AND nrborder = rw_craptdb.nrborder
       AND nrdocmto = rw_craptdb.nrdocmto
       AND nrtitulo = rw_craptdb.nrtitulo;
  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
