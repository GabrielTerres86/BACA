DECLARE
  
  CURSOR cr_crapsld IS
    SELECT t.vlsmnmes
         , t.vlsmnesp
         , t.vljuresp
         , t.vliofmes
      FROM crapsld t
     WHERE t.cdcooper = 1
       AND t.nrdconta = 11460148;
  rg_crapsld   cr_crapsld%ROWTYPE;
  
  vc_dstransaStatusCC   CONSTANT VARCHAR2(4000) := 'Zerar saldos medios negativos indevidos - INC0220422';
  vr_dttransa           cecred.craplgm.dttransa%type;
  vr_hrtransa           cecred.craplgm.hrtransa%type;
  vr_nrdrowid           ROWID;
  vr_dscritic           VARCHAR2(1000);
BEGIN
  
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;

  OPEN  cr_crapsld;
  FETCH cr_crapsld INTO rg_crapsld;
  CLOSE cr_crapsld;


  UPDATE crapsld  t
     SET t.vlsmnmes = 0
       , t.vlsmnesp = 0
       , t.vljuresp = 0
       , t.vliofmes = 0
   WHERE t.cdcooper = 1
     AND t.nrdconta = 11460148;

  
  CECRED.GENE0001.pc_gera_log(pr_cdcooper => 1
                             ,pr_cdoperad => '1'
                             ,pr_dscritic => vr_dscritic
                             ,pr_dsorigem => 'AIMARO'
                             ,pr_dstransa => vc_dstransaStatusCC
                             ,pr_dttransa => vr_dttransa
                             ,pr_flgtrans => 1
                             ,pr_hrtransa => vr_hrtransa
                             ,pr_idseqttl => 0
                             ,pr_nmdatela => NULL
                             ,pr_nrdconta => 11460148
                             ,pr_nrdrowid => vr_nrdrowid);
                         
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
  
  COMMIT;
  
END;
