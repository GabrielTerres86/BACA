DECLARE
  vr_dttransa cecred.craplgm.dttransa%type;
  vr_hrtransa cecred.craplgm.hrtransa%type;
  vr_nrdconta cecred.crapass.nrdconta%type;
  vr_cdcooper cecred.crapcop.cdcooper%type;
  vr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;

  vr_nrdrowid ROWID;

  CURSOR cr_crapsld is
    SELECT *
      from CECRED.crapsld a
     WHERE a.nrdconta = 9316221
       AND a.cdcooper = 1;

  rg_crapsld crapsld%rowtype;

  CURSOR cr_crapsda is
    SELECT *
      from CECRED.crapsda a
     WHERE a.nrdconta = 9316221
       AND a.cdcooper = 1
       AND a.dtmvtolt BETWEEN to_date('02/11/2021', 'dd/mm/yyyy') AND
           TRUNC(SYSDATE);

  rg_crapsda crapsda%rowtype;

BEGIN

  open cr_crapsld;
  fetch cr_crapsld
    into rg_crapsld;

  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;
  vr_cdcooper := 1;
  vr_nrdconta := 9316221;

  GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                       pr_cdoperad => vr_cdoperad,
                       pr_dscritic => vr_dscritic,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => 'Alteracao da situacao de conta por script - INC0111716',
                       pr_dttransa => vr_dttransa,
                       pr_flgtrans => 1,
                       pr_hrtransa => vr_hrtransa,
                       pr_idseqttl => 0,
                       pr_nmdatela => 'Atenda',
                       pr_nrdconta => vr_nrdconta,
                       pr_nrdrowid => vr_nrdrowid);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'crapsld.VLSDDISP',
                            pr_dsdadant => rg_crapsld.vlsddisp,
                            pr_dsdadatu => rg_crapsld.vlsddisp + 3504.39);
  UPDATE crapsld a
     SET a.VLSDDISP = a.vlsddisp + 3504.39
   WHERE a.nrdconta = vr_nrdconta
     AND a.cdcooper = vr_cdcooper;

  FOR rg_crapsda IN cr_crapsda LOOP
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapsda.VLSDDISP',
                              pr_dsdadant => rg_crapsda.vlsddisp,
                              pr_dsdadatu => rg_crapsda.vlsddisp + 3504.39);
   end loop;
   
    UPDATE crapsda a
       SET a.VLSDDISP = a.vlsddisp + 3504.39
     WHERE a.nrdconta = vr_nrdconta
       AND a.cdcooper = vr_cdcooper
       AND a.dtmvtolt BETWEEN to_date('02/11/2021', 'dd/mm/yyyy') AND
           TRUNC(SYSDATE);
  
 
  close cr_crapsld;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar situa��o cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
