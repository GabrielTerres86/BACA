DECLARE
  vr_dttransa cecred.craplgm.dttransa%type;
  vr_hrtransa cecred.craplgm.hrtransa%type;
  vr_nrdconta cecred.crapass.nrdconta%type;
  vr_cdcooper cecred.crapcop.cdcooper%type;
  vr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;

  vr_nrdrowid ROWID;
  
  vc_dstransaSensbCRAPSLD             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSLD) por script - INC0134925';
  vc_dstransaSensbCRAPSDA             CONSTANT VARCHAR2(4000) := 'Sensibilizacao do Saldo (CRAPSDA) por script - INC0134925';

  v_code NUMBER;
  v_errm VARCHAR2(64);

  CURSOR cr_crapsld is
    SELECT a.nrdconta
          ,a.vlsddisp
          ,contas.valor
      from CECRED.crapsld a
          ,(select 850004 as nrdconta, -32140.52 as valor from dual union all
            select 8579997 as nrdconta, -15443.79 as valor from dual union all
            select 11613491 as nrdconta, -6539.03 as valor from dual union all
            select 10430210 as nrdconta, -2283.74 as valor from dual union all
            select 12982806 as nrdconta, 1.94 as valor from dual union all
            select 13425625 as nrdconta, 5.63 as valor from dual union all
            select 10367489 as nrdconta, 26.12 as valor from dual union all
            select 8574030 as nrdconta, 55.47 as valor from dual union all
            select 13295420 as nrdconta, 76.27 as valor from dual union all
            select 12590118 as nrdconta, 87.33 as valor from dual union all
            select 12181064 as nrdconta, 101.08 as valor from dual union all
            select 3864308 as nrdconta, 109.37 as valor from dual union all
            select 7351224 as nrdconta, 120 as valor from dual union all
            select 6234569 as nrdconta, 126.61 as valor from dual union all
            select 7173725 as nrdconta, 160.99 as valor from dual union all
            select 1870599 as nrdconta, 200.98 as valor from dual union all
            select 8991995 as nrdconta, 233.92 as valor from dual union all
            select 12140376 as nrdconta, 237.65 as valor from dual union all
            select 12983080 as nrdconta, 279.73 as valor from dual union all
            select 8006113 as nrdconta, 332.04 as valor from dual union all
            select 7128835 as nrdconta, 623.58 as valor from dual union all
            select 3674355 as nrdconta, 723.19 as valor from dual union all
            select 6141811 as nrdconta, 915.93 as valor from dual union all
            select 2225530 as nrdconta, 1418.64 as valor from dual union all
            select 6383394 as nrdconta, 5136.47 as valor from dual) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = 1;

  CURSOR cr_crapsda is
    SELECT a.nrdconta, a.vlsddisp, a.dtmvtolt, contas.valor
      from CECRED.crapsda a
          ,(select 850004 as nrdconta, -32140.52 as valor from dual union all
            select 8579997 as nrdconta, -15443.79 as valor from dual union all
            select 11613491 as nrdconta, -6539.03 as valor from dual union all
            select 10430210 as nrdconta, -2283.74 as valor from dual union all
            select 12982806 as nrdconta, 1.94 as valor from dual union all
            select 13425625 as nrdconta, 5.63 as valor from dual union all
            select 10367489 as nrdconta, 26.12 as valor from dual union all
            select 8574030 as nrdconta, 55.47 as valor from dual union all
            select 13295420 as nrdconta, 76.27 as valor from dual union all
            select 12590118 as nrdconta, 87.33 as valor from dual union all
            select 12181064 as nrdconta, 101.08 as valor from dual union all
            select 3864308 as nrdconta, 109.37 as valor from dual union all
            select 7351224 as nrdconta, 120 as valor from dual union all
            select 6234569 as nrdconta, 126.61 as valor from dual union all
            select 7173725 as nrdconta, 160.99 as valor from dual union all
            select 1870599 as nrdconta, 200.98 as valor from dual union all
            select 8991995 as nrdconta, 233.92 as valor from dual union all
            select 12140376 as nrdconta, 237.65 as valor from dual union all
            select 12983080 as nrdconta, 279.73 as valor from dual union all
            select 8006113 as nrdconta, 332.04 as valor from dual union all
            select 7128835 as nrdconta, 623.58 as valor from dual union all
            select 3674355 as nrdconta, 723.19 as valor from dual union all
            select 6141811 as nrdconta, 915.93 as valor from dual union all
            select 2225530 as nrdconta, 1418.64 as valor from dual union all
            select 6383394 as nrdconta, 5136.47 as valor from dual) contas
     WHERE a.nrdconta = contas.nrdconta
       AND a.cdcooper = 1
       AND a.dtmvtolt BETWEEN to_date('31/03/2022', 'dd/mm/yyyy') AND
           TRUNC(SYSDATE)
     ORDER BY a.nrdconta, a.dtmvtolt asc;

BEGIN
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;
  vr_cdcooper := 1;

  FOR rg_crapsld IN cr_crapsld LOOP
    
    vr_nrdconta := rg_crapsld.nrdconta;
    vr_nrdrowid := null;
    
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => vc_dstransaSensbCRAPSLD,
                         pr_dttransa => vr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vr_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => vr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);

    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapsld.VLSDDISP',
                              pr_dsdadant => rg_crapsld.vlsddisp,
                              pr_dsdadatu => rg_crapsld.vlsddisp + rg_crapsld.valor);
    UPDATE crapsld a
       SET a.VLSDDISP = a.vlsddisp + rg_crapsld.valor
     WHERE a.nrdconta = vr_nrdconta
       AND a.cdcooper = vr_cdcooper;
       
  END LOOP;

  FOR rg_crapsda IN cr_crapsda LOOP
    
    vr_nrdconta := rg_crapsda.nrdconta;
    vr_nrdrowid := null;
    
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => vc_dstransaSensbCRAPSDA,
                         pr_dttransa => vr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vr_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => vr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);

    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapsda.DTMVTOLT',
                              pr_dsdadant => rg_crapsda.dtmvtolt,
                              pr_dsdadatu => rg_crapsda.dtmvtolt);
    
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapsda.VLSDDISP',
                              pr_dsdadant => rg_crapsda.vlsddisp,
                              pr_dsdadatu => rg_crapsda.vlsddisp + rg_crapsda.valor);

      UPDATE crapsda a
         SET a.VLSDDISP = a.vlsddisp + rg_crapsda.valor
       WHERE a.nrdconta = vr_nrdconta
         AND a.cdcooper = vr_cdcooper
         AND a.dtmvtolt = rg_crapsda.dtmvtolt;

   end loop;
   
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    v_code := SQLCODE;
    v_errm := SUBSTR(SQLERRM, 1 , 64);    
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar saldo da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||  ' - ' || v_code || ' - ' || v_errm);
END;
