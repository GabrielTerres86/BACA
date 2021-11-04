DECLARE
  vr_dttransa cecred.craplgm.dttransa%type;
  vr_hrtransa cecred.craplgm.hrtransa%type;
  vr_nrdconta cecred.crapass.nrdconta%type;
  vr_cdcooper cecred.crapcop.cdcooper%type;
  vr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  
  vr_nrdrowid ROWID;

BEGIN
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;
  vr_cdcooper := 1;
  vr_nrdconta := 12405850;

  GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                       pr_cdoperad => vr_cdoperad,
                       pr_dscritic => vr_dscritic,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => 'Alteracao da situacao de conta por script - INC0111716',
                       pr_dttransa => vr_dttransa,
                       pr_flgtrans => 1,
                       pr_hrtransa => vr_hrtransa,
                       pr_idseqttl => 1,
                       pr_nmdatela => 'Atenda',
                       pr_nrdconta => vr_nrdconta,
                       pr_nrdrowid => vr_nrdrowid);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'crapsld.VLSDDISP',
                            pr_dsdadant => 253.03,
                            pr_dsdadatu => 691.47);

  UPDATE crapsld a
     SET a.VLSDDISP = 691.47
   WHERE a.nrdconta = 12405850
     AND a.cdcooper = 1;    

   GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                   pr_nmdcampo => 'crapsda.VLSDDISP',
                                   pr_dsdadant => 20.00,
                                   pr_dsdadatu => 691.47);
  UPDATE crapsda a
     SET a.VLSDDISP = 691.47
   WHERE a.nrdconta = 12405850
     AND a.cdcooper = 1
     AND a.dtmvtolt BETWEEN to_date('01/11/2021', 'dd/mm/yyyy') AND
         TRUNC(SYSDATE);
 
  commit;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar situação cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;

