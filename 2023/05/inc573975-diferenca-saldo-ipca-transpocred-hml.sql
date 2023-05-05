DECLARE
  vr_cdcooper   craplac.cdcooper%TYPE := 9;
  vr_nrdconta_1 craplac.nrdconta%TYPE := 2712;
  vr_nrdconta_2 craplac.nrdconta%TYPE := 314706;
  vr_cdhistor   craplac.cdhistor%TYPE := 3328;
  vr_cdagenci   craplac.cdagenci%TYPE := 1;
  vr_cdbccxlt   craplac.cdbccxlt%TYPE := 100;
  vr_nrdolote   craplac.nrdolote%TYPE := 558506;

  vr_nraplica craplac.nraplica%TYPE;
  vr_nrdocmto craplac.nrdocmto%TYPE;
  vr_vllanmto NUMBER;
  vr_dtfimper DATE;

  vr_cdcritic crapcri.cdcritic%TYPE := 999;
  vr_dscritic VARCHAR2(5000) := ' ';
  vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  vr_excsaida EXCEPTION;

  vr_des_reto VARCHAR2(3);
  vr_tab_erro GENE0001.typ_tab_erro;

  CURSOR cr_craplap(pr_cdcooper IN craplap.cdcooper%TYPE
                   ,pr_nrdconta IN craplap.nrdconta%TYPE
                   ,pr_nraplica IN craplap.nraplica%TYPE) IS
    SELECT lap.txaplica
      FROM craplap lap
     WHERE lap.cdcooper = pr_cdcooper
       AND lap.nrdconta = pr_nrdconta
       AND lap.nraplica = pr_nraplica
       AND ROWNUM = 1
     ORDER BY lap.progress_recid DESC;

  rw_craplap cr_craplap%ROWTYPE;
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 3);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

  IF btch0001.cr_crapdat%NOTFOUND
  THEN
    CLOSE btch0001.cr_crapdat;
    RAISE vr_excsaida;
  ELSE
    CLOSE btch0001.cr_crapdat;
  END IF;
  
  vr_nrdocmto := CECRED.SEQCAPT_CRAPLAC_NRSEQDIG.nextval;
  vr_nraplica := 1;
  vr_vllanmto := 293.48;
  
  INSERT INTO craplac
    (cdcooper
    ,dtmvtolt
    ,cdagenci
    ,cdbccxlt
    ,nrdolote
    ,nrdconta
    ,nraplica
    ,nrdocmto
    ,nrseqdig
    ,vllanmto
    ,cdhistor)
  VALUES
    (vr_cdcooper
    ,rw_crapdat.dtmvtolt
    ,vr_cdagenci
    ,vr_cdbccxlt
    ,vr_nrdolote
    ,vr_nrdconta_1
    ,vr_nraplica
    ,vr_nrdocmto  + 555000
    ,NVL(vr_nrdocmto, 0) + 1
    ,vr_vllanmto
    ,vr_cdhistor);
    
  vr_nrdocmto := CECRED.SEQCAPT_CRAPLAC_NRSEQDIG.nextval;
  vr_nraplica := 3;
  vr_vllanmto := 395.03;
  
  INSERT INTO craplac
    (cdcooper
    ,dtmvtolt
    ,cdagenci
    ,cdbccxlt
    ,nrdolote
    ,nrdconta
    ,nraplica
    ,nrdocmto
    ,nrseqdig
    ,vllanmto
    ,cdhistor)
  VALUES
    (vr_cdcooper
    ,rw_crapdat.dtmvtolt
    ,vr_cdagenci
    ,vr_cdbccxlt
    ,vr_nrdolote
    ,vr_nrdconta_2
    ,vr_nraplica
    ,vr_nrdocmto  + 555000
    ,NVL(vr_nrdocmto, 0) + 1
    ,vr_vllanmto
    ,vr_cdhistor);

  COMMIT;
EXCEPTION
  WHEN vr_excsaida THEN
    CECRED.pc_log_programa(pr_dstiplog      => 'O',
                           pr_tpocorrencia  => 4,
                           pr_cdcriticidade => 0,
                           pr_tpexecucao    => 3,
                           pr_dsmensagem    => vr_dscritic,
                           pr_cdmensagem    => vr_cdcritic,
                           pr_cdprograma    => 'INC0266453',
                           pr_cdcooper      => 3,
                           pr_idprglog      => vr_idprglog);
    ROLLBACK;
  WHEN OTHERS THEN
    vr_dscritic := SQLERRM;
    CECRED.pc_log_programa(pr_dstiplog      => 'O',
                           pr_tpocorrencia  => 4,
                           pr_cdcriticidade => 0,
                           pr_tpexecucao    => 3,
                           pr_dsmensagem    => vr_dscritic,
                           pr_cdmensagem    => vr_cdcritic,
                           pr_cdprograma    => 'INC0266453',
                           pr_cdcooper      => 3,
                           pr_idprglog      => vr_idprglog);
    ROLLBACK;
END;
/
