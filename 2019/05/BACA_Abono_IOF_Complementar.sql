DECLARE
  

  CURSOR cr_craplcm_iof IS
    select 1 as cdcooper, 1985000 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 10043 as nrdocmto, 548746 as nrborder from dual
    UNION
    select 1 as cdcooper, 2577518 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.14 as vllanmto, 1330 as nrdocmto, 561658 as nrborder from dual
    UNION
    select 1 as cdcooper, 2577518 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.19 as vllanmto, 1346 as nrdocmto, 561658 as nrborder from dual
    UNION
    select 1 as cdcooper, 3069060 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.03 as vllanmto, 2414 as nrdocmto, 564620 as nrborder from dual
    UNION
    select 1 as cdcooper, 3581055 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.02 as vllanmto, 24 as nrdocmto, 561664 as nrborder from dual
    UNION
    select 1 as cdcooper, 3581055 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.03 as vllanmto, 29 as nrdocmto, 561664 as nrborder from dual
    UNION
    select 1 as cdcooper, 6123490 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 9257 as nrdocmto, 563288 as nrborder from dual
    UNION
    select 1 as cdcooper, 6196420 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 26632 as nrdocmto, 563913 as nrborder from dual
    UNION
    select 1 as cdcooper, 9924701 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 52 as nrdocmto, 561154 as nrborder from dual
    UNION
    select 1 as cdcooper, 80495192 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 2741 as nrdocmto, 562880 as nrborder from dual
    UNION
    select 1 as cdcooper, 80495192 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.03 as vllanmto, 2751 as nrdocmto, 562880 as nrborder from dual
    UNION
    select 1 as cdcooper, 80495192 as nrdconta,  to_date('25/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 2756 as nrdocmto, 562880 as nrborder from dual
    UNION
    select 1 as cdcooper, 6123490 as nrdconta,  to_date('26/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 9249 as nrdocmto, 563864 as nrborder from dual
    UNION
    select 1 as cdcooper, 6123490 as nrdconta,  to_date('26/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 9255 as nrdocmto, 563864 as nrborder from dual
    UNION
    select 1 as cdcooper, 8524700 as nrdconta,  to_date('26/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.03 as vllanmto, 502 as nrdocmto, 562802 as nrborder from dual
    UNION
    select 1 as cdcooper, 8973709 as nrdconta,  to_date('29/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.05 as vllanmto, 409 as nrdocmto, 562305 as nrborder from dual
    UNION
    select 1 as cdcooper, 2892022 as nrdconta,  to_date('30/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.04 as vllanmto, 3479 as nrdocmto, 551001 as nrborder from dual
    UNION
    select 1 as cdcooper, 3910989 as nrdconta,  to_date('30/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 742 as nrdocmto, 562941 as nrborder from dual
    UNION
    select 1 as cdcooper, 8524700 as nrdconta,  to_date('30/04/2019','DD/MM/RRRR'), 325 as cdhistor, 0.11 as vllanmto, 502 as nrdocmto, 562802 as nrborder from dual
    UNION
    select 1 as cdcooper, 3910989 as nrdconta,  to_date('03/05/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 742 as nrdocmto, 562941 as nrborder from dual
    UNION
    select 1 as cdcooper, 3910989 as nrdconta,  to_date('06/05/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 742 as nrdocmto, 562941 as nrborder from dual
    UNION
select 1 as cdcooper, 3910989 as nrdconta,  to_date('08/05/2019','DD/MM/RRRR'), 325 as cdhistor, 0.01 as vllanmto, 742 as nrdocmto, 562941 as nrborder from dual;
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