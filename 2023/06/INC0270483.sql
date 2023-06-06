DECLARE
  
  CURSOR cr_crapsld IS
    SELECT t.vlsmnmes
         , t.vlsmnesp
         , t.vljuresp
         , t.vliofmes
         , t.cdcooper
         , t.nrdconta
      FROM cecred.crapsld t
     WHERE t.progress_recid = 675138;
  rg_crapsld   cr_crapsld%ROWTYPE;
  
  CURSOR cr_tar_fut(pr_cdcooper in cecred.crapcop.cdcooper%type,
                    pr_nrdconta in cecred.crapass.nrdconta%type) IS
   SELECT craplat.cdcooper
         ,craplat.nrdconta
         ,craplat.cdmotest
         ,craplat.dtdestor
         ,craplat.cdopeest
         ,craplat.cdlantar
         ,craplat.insitlat
     FROM cecred.craplat craplat
    WHERE craplat.cdcooper = pr_cdcooper  
      AND craplat.nrdconta = pr_nrdconta 
      AND craplat.insitlat = 1;
  
  vc_dstransaStatusCC   CONSTANT VARCHAR2(4000) := 'Zerar saldos medios negativos indevidos - INC0270483';
  vr_dttransa           cecred.craplgm.dttransa%type;
  vr_hrtransa           cecred.craplgm.hrtransa%type;
  vr_nrdrowid           ROWID;
  vr_dscritic           VARCHAR2(1000);
  rw_crapdat            cecred.BTCH0001.cr_crapdat%ROWTYPE;
  
  vr_cdcooper            cecred.crapcop.cdcooper%type;
  vr_nrdconta            cecred.crapass.nrdconta%type;
  vc_insitlat            CONSTANT cecred.craplat.insitlat%TYPE := 3;
  vc_cdopeest            CONSTANT cecred.craplat.cdopeest%TYPE := 1;
  vc_insit_ope_cancelado CONSTANT cecred.craplat.cdopeest%TYPE := 4;
  vc_cdmotest            CONSTANT cecred.craplat.cdmotest%TYPE := 3;

  
BEGIN
  
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;

  OPEN  cr_crapsld;
  FETCH cr_crapsld INTO rg_crapsld;
  CLOSE cr_crapsld;

  vr_cdcooper := rg_crapsld.cdcooper;
  vr_nrdconta := rg_crapsld.nrdconta;
  
  OPEN CECRED.BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH CECRED.BTCH0001.cr_crapdat INTO rw_crapdat;
  IF CECRED.BTCH0001.cr_crapdat%NOTFOUND THEN
     CLOSE CECRED.BTCH0001.cr_crapdat;
     RAISE_APPLICATION_ERROR(-20001,'Erro abrir data para cooperativa:' || vr_cdcooper || ' - ' || sqlerrm);
  ELSE
     CLOSE CECRED.BTCH0001.cr_crapdat;
  END IF;
  
  FOR rw_tar_fut in cr_tar_fut(vr_cdcooper, vr_nrdconta) LOOP
   
      vr_nrdrowid := null;
    
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                                  pr_cdoperad => '1',
                                  pr_dscritic => vr_dscritic,
                                  pr_dsorigem => 'AIMARO',
                                  pr_dstransa => vc_dstransaStatusCC,
                                  pr_dttransa => vr_dttransa,
                                  pr_flgtrans => 1,
                                  pr_hrtransa => vr_hrtransa,
                                  pr_idseqttl => 0,
                                  pr_nmdatela => NULL,
                                  pr_nrdconta => vr_nrdconta,
                                  pr_nrdrowid => vr_nrdrowid);
                           
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplat.CDCOOPER',
                                       pr_dsdadant => vr_cdcooper,
                                       pr_dsdadatu => vr_cdcooper);

      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplat.NRDCONTA',
                                       pr_dsdadant => vr_nrdconta,
                                       pr_dsdadatu => vr_nrdconta);

      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplat.CDLANTAR',
                                       pr_dsdadant => rw_tar_fut.cdlantar,
                                       pr_dsdadatu => rw_tar_fut.cdlantar);

      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplat.DTDESTOR',
                                       pr_dsdadant => rw_tar_fut.dtdestor,
                                       pr_dsdadatu => rw_crapdat.dtmvtolt);

      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplat.INSITLAT',
                                       pr_dsdadant => rw_tar_fut.insitlat,
                                       pr_dsdadatu => vc_insitlat);

      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplat.CDMOTEST',
                                       pr_dsdadant => rw_tar_fut.cdmotest,
                                       pr_dsdadatu => vc_cdmotest);

      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplat.CDOPEEST',
                                       pr_dsdadant => rw_tar_fut.cdopeest,
                                       pr_dsdadatu => vc_cdopeest);

                               
       CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'crapsld.vlsmnmes'
                                       ,pr_dsdadant => rg_crapsld.vlsmnmes
                                       ,pr_dsdadatu => 0);
  
       CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'crapsld.vlsmnesp'
                                       ,pr_dsdadant => rg_crapsld.vlsmnesp
                                       ,pr_dsdadatu => 0);
                                  
       CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'crapsld.vljuresp'
                                       ,pr_dsdadant => rg_crapsld.vljuresp
                                       ,pr_dsdadatu => 0);
                                  
       CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'crapsld.vliofmes'
                                       ,pr_dsdadant => rg_crapsld.vliofmes
                                       ,pr_dsdadatu => 0);  
	  
	  UPDATE cecred.craplat lat
         SET lat.insitlat = vc_insitlat
            ,lat.cdmotest = vc_cdmotest 
            ,lat.dtdestor = rw_crapdat.dtmvtolt
            ,lat.cdopeest = vc_cdopeest
       WHERE lat.cdcooper = rw_tar_fut.cdcooper
         AND lat.nrdconta = rw_tar_fut.nrdconta
         and lat.cdlantar = rw_tar_fut.cdlantar;
   
  END LOOP;  
   
  UPDATE cecred.crapsld  t
     SET t.vlsmnmes = 0
       , t.vlsmnesp = 0
       , t.vljuresp = 0
       , t.vliofmes = 0
   WHERE t.cdcooper = rg_crapsld.cdcooper
     AND t.nrdconta = rg_crapsld.nrdconta;

  
  

  COMMIT;
  
END;
