DECLARE
  vr_dttransa cecred.craplgm.dttransa%type;
  vr_hrtransa cecred.craplgm.hrtransa%type;
  vr_nrdconta cecred.crapass.nrdconta%type;
  vr_cdcooper cecred.crapcop.cdcooper%type;
  vr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;

  vr_nrdrowid ROWID;

  CURSOR cr_crapsld is
    SELECT a.*
      from CECRED.crapsld a
     WHERE a.nrdconta = 13635778
       AND a.cdcooper = 1;

  rg_crapsld crapsld%rowtype;

  CURSOR cr_crapsda is
    SELECT a.*
      from CECRED.crapsda a
     WHERE a.nrdconta = 13635778
       AND a.cdcooper = 1
       AND a.dtmvtolt BETWEEN to_date('14/12/2021', 'dd/mm/yyyy') AND
           TRUNC(SYSDATE);

  rg_crapsda crapsda%rowtype;

BEGIN

  open cr_crapsld;
  fetch cr_crapsld
    into rg_crapsld;

  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;
  vr_cdcooper := 1;
  vr_nrdconta := 13635778;

  GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                       pr_cdoperad => vr_cdoperad,
                       pr_dscritic => vr_dscritic,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => 'Alteracao da situacao de conta por script - INC0118503',
                       pr_dttransa => vr_dttransa,
                       pr_flgtrans => 1,
                       pr_hrtransa => vr_hrtransa,
                       pr_idseqttl => 1,
                       pr_nmdatela => 'Atenda',
                       pr_nrdconta => vr_nrdconta,
                       pr_nrdrowid => vr_nrdrowid);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'crapsld.VLSDDISP',
                            pr_dsdadant => rg_crapsld.vlsddisp,
                            pr_dsdadatu => rg_crapsld.vlsddisp + 831.83);
  UPDATE crapsld a
     SET a.VLSDDISP = a.vlsddisp + 831.83
   WHERE a.nrdconta = 13635778
       AND a.cdcooper = 1;

  FOR rg_crapass IN cr_crapsda LOOP
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapsda.VLSDDISP',
                              pr_dsdadant => rg_crapass.vlsddisp,
                              pr_dsdadatu => rg_crapass.vlsddisp + 831.83);
   end loop;
   
    UPDATE crapsda a
       SET a.VLSDDISP = (a.vlsddisp + 831.83)
     WHERE a.nrdconta = 13635778
       AND a.cdcooper = 1
       AND a.dtmvtolt BETWEEN to_date('14/12/2021', 'dd/mm/yyyy') AND
           TRUNC(SYSDATE);
  
 
  close cr_crapsld;
  
  commit;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar situação cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;

