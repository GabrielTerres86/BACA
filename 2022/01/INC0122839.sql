DECLARE
  vr_dttransa cecred.craplgm.dttransa%type;
  vr_hrtransa cecred.craplgm.hrtransa%type;
  vr_nrdconta cecred.crapass.nrdconta%type;
  vr_cdcooper cecred.crapcop.cdcooper%type;
  vr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_dstransa VARCHAR(1000);

  vr_nrdrowid ROWID;
  rg_assoc  cecred.TBCC_ASSOCIADOS%rowtype;

  CURSOR cr_assoc(pr_cdcooper cecred.TBCC_ASSOCIADOS.cdcooper%type,
                  pr_nrdconta cecred.TBCC_ASSOCIADOS.nrdconta%type) is
    SELECT *
      from CECRED.TBCC_ASSOCIADOS a
     WHERE a.nrdconta = pr_nrdconta
       AND a.cdcooper = pr_cdcooper;

BEGIN

  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;
  vr_cdcooper := 10;
  vr_nrdconta := 189235;
  vr_dstransa := 'Alteracao de município por script - INC0122839';

  open cr_assoc(vr_cdcooper, vr_nrdconta);
  fetch cr_assoc
    into rg_assoc;
  close cr_assoc;

  GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                       pr_cdoperad => vr_cdoperad,
                       pr_dscritic => vr_dscritic,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => vr_dstransa,
                       pr_dttransa => vr_dttransa,
                       pr_flgtrans => 1,
                       pr_hrtransa => vr_hrtransa,
                       pr_idseqttl => 1,
                       pr_nmdatela => 'Atenda',
                       pr_nrdconta => vr_nrdconta,
                       pr_nrdrowid => vr_nrdrowid);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'TBCC_ASSOCIADOS.ID_GRUPOMUNICIPAL',
                            pr_dsdadant => rg_assoc.idgrupo_municipal,
                            pr_dsdadatu => 8183);
  UPDATE TBCC_ASSOCIADOS a
     SET a.idgrupo_municipal = 8183
   WHERE a.nrdconta = vr_nrdconta
     AND a.cdcooper = vr_cdcooper;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar saldo da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
