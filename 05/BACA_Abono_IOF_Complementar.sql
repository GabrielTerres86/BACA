DECLARE
  

  CURSOR cr_craplcm_iof IS
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 1985000   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 10043
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 2577518   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.04 and nrdocmto = 1081
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 2577518   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.14 and nrdocmto = 1330
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 2577518   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.19 and nrdocmto = 1346
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 3069060   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.03 and nrdocmto = 2414
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 3581055   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.02 and nrdocmto = 24
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 3581055   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.03 and nrdocmto = 29
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 6123490   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 9257
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 6196420   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 26632
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 9924701   and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 52
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 80495192      and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 2741
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 80495192      and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.03 and nrdocmto = 2751
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 80495192      and dtmvtolt = to_date('25/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 2756
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 6123490   and dtmvtolt = to_date('26/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 9249
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 6123490   and dtmvtolt = to_date('26/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 9255
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 8524700   and dtmvtolt = to_date('26/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.03 and nrdocmto = 502
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 8973709   and dtmvtolt = to_date('29/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.05 and nrdocmto = 409
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 2892022   and dtmvtolt = to_date('30/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.04 and nrdocmto = 3479
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 3910989   and dtmvtolt = to_date('30/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 742
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 8524700   and dtmvtolt = to_date('30/04/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.11 and nrdocmto = 502
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 3910989   and dtmvtolt = to_date('03/05/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 742
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 3910989   and dtmvtolt = to_date('06/05/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 742
    UNION
    select cdcooper, nrdconta, vllanmto, nrdocmto, to_number(substr(cdpesqbb,-6,6)) as nrborder from craplcm where cdcooper = 1 and nrdconta = 3910989   and dtmvtolt = to_date('08/05/2019','DD/MM/RRRR') and cdhistor = 2321 and vllanmto = 0.01 and nrdocmto = 742;
  rw_craplcm_iof cr_craplcm_iof%rowtype;
  
  /* Cursor genérico de calendário */
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
          ,dat.dtmvtopr
          ,dat.dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,trunc(dat.dtmvtolt,'mm')               dtinimes -- Pri. Dia Mes Corr.
          ,trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(dat.dtmvtolt,-1))  dtultdma -- Ult. Dia Mes Ant.
          ,last_day(dat.dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.
          ,rowid
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;
  
  vr_cdcritic     crapcri.cdcritic%TYPE;
  vr_dscritic     crapcri.dscritic%TYPE;
  
  
BEGIN
  
  OPEN  cr_crapdat(pr_cdcooper => 1);
  FETCH cr_crapdat into rw_crapdat;
  CLOSE cr_crapdat;

  FOR rw_craplcm_iof IN cr_craplcm_iof LOOP
    
    -- então lançar o saldo restante como crédito na conta corrente do cooperado
    DSCT0003.pc_efetua_lanc_cc (pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => 1
                               ,pr_cdbccxlt => 100
                               ,pr_nrdconta => rw_craplcm_iof.nrdconta
                               ,pr_vllanmto => rw_craplcm_iof.vllanmto
                               ,pr_cdhistor => 325
                               ,pr_cdcooper => rw_craplcm_iof.cdcooper
                               ,pr_cdoperad => '1'
                               ,pr_nrborder => rw_craplcm_iof.nrborder
                               ,pr_cdpactra => 0
                               ,pr_nrdocmto => rw_craplcm_iof.nrdocmto
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
    -- Condicao para verificar se houve critica
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
  
  END LOOP;  
  COMMIT;
  
END;
