DECLARE

  CURSOR cr_craplcm_est IS
    select 1 as cdcooper, 3910989 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 742 as nrdocmto, 359 as cdhistor, 16.99 as vllanmto, 562941 as nrborder from dual
    UNION 
    select 1 as cdcooper, 3910989 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 742 as nrdocmto, 359 as cdhistor, 2.61 as vllanmto, 562941 as nrborder from dual
    UNION 
    select 1 as cdcooper, 3910989 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 742 as nrdocmto, 359 as cdhistor, 0.04 as vllanmto, 562941 as nrborder from dual
    UNION 
    select 1 as cdcooper, 3910989 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 742 as nrdocmto, 359 as cdhistor, 0.2 as vllanmto, 562941 as nrborder from dual
    UNION 
    select 1 as cdcooper, 3910989 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 742 as nrdocmto, 359 as cdhistor, 0.11 as vllanmto, 562941 as nrborder from dual
    UNION 
    select 1 as cdcooper, 3910989 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 742 as nrdocmto, 359 as cdhistor, 22.37 as vllanmto, 562941 as nrborder from dual
    UNION 
    select 1 as cdcooper, 3910989 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 742 as nrdocmto, 359 as cdhistor, 39.73 as vllanmto, 562941 as nrborder from dual
    UNION 
    select 1 as cdcooper, 3910989 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 742 as nrdocmto, 359 as cdhistor, 0.08 as vllanmto, 562941 as nrborder from dual
    UNION 
    select 1 as cdcooper, 2892022 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 3479 as nrdocmto, 359 as cdhistor, 592.58 as vllanmto, 551001 as nrborder from dual
    UNION 
    select 1 as cdcooper, 80280161 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 200000851 as nrdocmto, 359 as cdhistor, 689.47 as vllanmto, 564817 as nrborder from dual
    UNION 
    select 1 as cdcooper, 8524700 as nrdconta, (select dtmvtolt from crapdat where cdcooper = 1) as dtmvtolt, 502 as nrdocmto, 359 as cdhistor, 785.23 as vllanmto, 562802 as nrborder  from dual;
  rw_craplcm_est cr_craplcm_est%rowtype;
  
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

  FOR rw_craplcm_est IN cr_craplcm_est LOOP
    
    -- então lançar o saldo restante como crédito na conta corrente do cooperado
    DSCT0003.pc_efetua_lanc_cc (pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_cdagenci => 1
                               ,pr_cdbccxlt => 100
                               ,pr_nrdconta => rw_craplcm_est.nrdconta
                               ,pr_vllanmto => rw_craplcm_est.vllanmto
                               ,pr_cdhistor => rw_craplcm_est.cdhistor
                               ,pr_cdcooper => rw_craplcm_est.cdcooper
                               ,pr_cdoperad => '1'
                               ,pr_nrborder => rw_craplcm_est.nrborder
                               ,pr_cdpactra => 0
                               ,pr_nrdocmto => rw_craplcm_est.nrdocmto
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
    -- Condicao para verificar se houve critica
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      dbms_output.put_line('erro: - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    
    dbms_output.put_line('  * Inserir lançamento do histórico ' || rw_craplcm_est.cdhistor || ' no valor de ' || rw_craplcm_est.vllanmto || ' na conta ' || rw_craplcm_est.nrdconta);
    
  END LOOP;  
  COMMIT;
  
END;
