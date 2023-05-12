DECLARE
  vr_cdcooper craplap.cdcooper%TYPE := 1;
  vr_nrdconta craplap.nrdconta%TYPE := 13131834;
  vr_cdhistor craplap.cdhistor%TYPE := 474;
  vr_cdagenci craplap.cdagenci%TYPE := 1;
  vr_cdbccxlt craplap.cdbccxlt%TYPE := 100;
  vr_nrdolote craplap.nrdolote%TYPE := 8480;

  vr_nraplica craplap.nraplica%TYPE;
  vr_nrdocmto craplap.nrdocmto%TYPE;
  vr_vllanmto NUMBER;
  vr_dtfimper DATE;

  vr_rowidlot      ROWID;
  vr_rowid_craplap ROWID;
  vr_vlinfodb      NUMBER;
  vr_vlcompdb      NUMBER;
  vr_qtinfoln      craplot.qtinfoln%TYPE;
  vr_qtcompln      craplot.qtcompln%TYPE;
  vr_vlinfocr      NUMBER;
  vr_vlcompcr      NUMBER;

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
      FROM CECRED.craplap lap
     WHERE lap.cdcooper = pr_cdcooper
       AND lap.nrdconta = pr_nrdconta
       AND lap.nraplica = pr_nraplica
       AND ROWNUM = 1
     ORDER BY lap.progress_recid desc;

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

  vr_nrdocmto := CECRED.SEQCAPT_CRAPLAP_NRSEQDIG.nextval;
  vr_nraplica := 5;
  vr_vllanmto := 496.43;

  OPEN cr_craplap(pr_cdcooper => vr_cdcooper,
                  pr_nrdconta => vr_nrdconta,
                  pr_nraplica => vr_nraplica);
  FETCH cr_craplap
    INTO rw_craplap;

  IF cr_craplap%NOTFOUND
  THEN
    CLOSE cr_craplap;
    vr_cdcritic := 90;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 90) ||
                   gene0002.fn_mask_conta(vr_nrdconta) || gene0002.fn_mask(vr_nraplica, 'zzz.zz9');
  
    RAISE vr_excsaida;
  ELSE
    CLOSE cr_craplap;
  END IF;
  
  BEGIN
   SELECT A.DTFIMPER
     INTO vr_dtfimper
     FROM CECRED.CRAPRDA A
    WHERE A.CDCOOPER = vr_cdcooper
      AND A.NRDCONTA = vr_nrdconta
      AND A.NRAPLICA = vr_nraplica
      AND A.INSAQTOT = 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      vr_dtfimper := null;
  END;
  
  IF vr_dtfimper IS NOT NULL THEN
    INSERT INTO CECRED.craplap
      (cdcooper
      ,dtmvtolt
      ,cdagenci
      ,cdbccxlt
      ,nrdolote
      ,nrdconta
      ,nraplica
      ,nrdocmto
      ,txaplica
      ,txaplmes
      ,cdhistor
      ,nrseqdig
      ,vllanmto
      ,dtrefere
      ,vlrendmm)
    VALUES
      (vr_cdcooper
      ,rw_crapdat.dtmvtolt
      ,vr_cdagenci
      ,vr_cdbccxlt
      ,vr_nrdolote
      ,vr_nrdconta
      ,vr_nraplica
      ,vr_nrdocmto + 555000
      ,rw_craplap.txaplica
      ,rw_craplap.txaplica
      ,vr_cdhistor
      ,NVL(vr_nrdocmto, 0) + 1
      ,vr_vllanmto
      ,vr_dtfimper
      ,0);
    
    UPDATE CECRED.CRAPRDA RDA
       SET RDA.VLSLFMES = VLSLFMES + vr_vllanmto
     WHERE RDA.CDCOOPER = vr_cdcooper
       AND RDA.NRDCONTA = vr_nrdconta
       AND RDA.NRAPLICA = vr_nraplica;
  END IF;
  
  
  vr_nrdocmto := CECRED.SEQCAPT_CRAPLAP_NRSEQDIG.nextval;
  vr_nraplica := 9;
  vr_vllanmto := 49.23;

  OPEN cr_craplap(pr_cdcooper => vr_cdcooper,
                  pr_nrdconta => vr_nrdconta,
                  pr_nraplica => vr_nraplica);
  FETCH cr_craplap
    INTO rw_craplap;

  IF cr_craplap%NOTFOUND
  THEN
    CLOSE cr_craplap;
    vr_cdcritic := 90;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 90) ||
                   gene0002.fn_mask_conta(vr_nrdconta) || gene0002.fn_mask(vr_nraplica, 'zzz.zz9');
  
    RAISE vr_excsaida;
  ELSE
    CLOSE cr_craplap;
  END IF;

  BEGIN
   SELECT A.DTFIMPER
     INTO vr_dtfimper
     FROM CECRED.CRAPRDA A
    WHERE A.CDCOOPER = vr_cdcooper
      AND A.NRDCONTA = vr_nrdconta
      AND A.NRAPLICA = vr_nraplica
      AND A.INSAQTOT = 0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      vr_dtfimper := null;
  END;
  
  IF vr_dtfimper IS NOT NULL THEN
    INSERT INTO CECRED.craplap
      (cdcooper
      ,dtmvtolt
      ,cdagenci
      ,cdbccxlt
      ,nrdolote
      ,nrdconta
      ,nraplica
      ,nrdocmto
      ,txaplica
      ,txaplmes
      ,cdhistor
      ,nrseqdig
      ,vllanmto
      ,dtrefere
      ,vlrendmm)
    VALUES
      (vr_cdcooper
      ,rw_crapdat.dtmvtolt
      ,vr_cdagenci
      ,vr_cdbccxlt
      ,vr_nrdolote
      ,vr_nrdconta
      ,vr_nraplica
      ,vr_nrdocmto + 555000
      ,rw_craplap.txaplica
      ,rw_craplap.txaplica
      ,vr_cdhistor
      ,NVL(vr_nrdocmto, 0) + 1
      ,vr_vllanmto
      ,vr_dtfimper
      ,0);
    
    UPDATE CECRED.CRAPRDA RDA
       SET RDA.VLSLFMES = VLSLFMES + vr_vllanmto
     WHERE RDA.CDCOOPER = vr_cdcooper
       AND RDA.NRDCONTA = vr_nrdconta
       AND RDA.NRAPLICA = vr_nraplica;
  END IF;
  
  COMMIT;
EXCEPTION
  WHEN vr_excsaida THEN
    CECRED.pc_log_programa(pr_dstiplog      => 'O',
                           pr_tpocorrencia  => 4,
                           pr_cdcriticidade => 0,
                           pr_tpexecucao    => 3,
                           pr_dsmensagem    => vr_dscritic,
                           pr_cdmensagem    => vr_cdcritic,
                           pr_cdprograma    => 'INC0263877',
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
                           pr_cdprograma    => 'INC0263877',
                           pr_cdcooper      => 3,
                           pr_idprglog      => vr_idprglog);
    ROLLBACK;
END;
/
