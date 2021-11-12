declare
  vr_dttransa cecred.craplgm.dttransa%type;
  vr_hrtransa cecred.craplgm.hrtransa%type;
  vr_nrdconta cecred.crapass.nrdconta%type;
  vr_cdcooper cecred.crapcop.cdcooper%type;
  vr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;

  CURSOR cr_craplcm is
    SELECT DTMVTOLT,
           CDAGENCI,
           CDBCCXLT,
           NRDOLOTE,
           NRDCONTA,
           NRDOCMTO,
           CDHISTOR,
           NRSEQDIG,
           VLLANMTO,
           NRDCTABB,
           CDPESQBB,
           DTREFERE,
           HRTRANSA,
           CDCOOPER,
           DTTRANS
      from CRAPLCM a
     WHERE a.Cdagenci = 20
       and a.nrdconta = 6212034
       and a.cdhistor = 1545
       and a.nrseqdig = 22648298
       and a.vllanmto = 764.96;

  rg_craplcm cr_craplcm%rowtype;

begin

  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;
  vr_cdcooper := 1;
  vr_nrdconta := 6212034;

  open cr_craplcm;
  fetch cr_craplcm
    into rg_craplcm;

  delete craplcm a
   where a.Cdagenci = 20
     and a.nrdconta = 6212034
     and a.cdhistor = 1545
     and a.nrseqdig = 22648298
     and a.vllanmto = 764.96;

  GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                       pr_cdoperad => vr_cdoperad,
                       pr_dscritic => vr_dscritic,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => 'INC0110549 - Lançamento de débito da fatura não sensibilizada.',
                       pr_dttransa => to_date('12-07-2021', 'dd-mm-yyyy'),
                       pr_flgtrans => 1,
                       pr_hrtransa => 46608,
                       pr_idseqttl => 0,
                       pr_nmdatela => NULL,
                       pr_nrdconta => vr_nrdconta,
                       pr_nrdrowid => vr_nrdrowid);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.DTMVTOLT',
                            pr_dsdadant => rg_craplcm.DTMVTOLT,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.CDAGENCI',
                            pr_dsdadant => rg_craplcm.CDAGENCI,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.CDBCCXLT',
                            pr_dsdadant => rg_craplcm.CDBCCXLT,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.NRDOLOTE',
                            pr_dsdadant => rg_craplcm.NRDOLOTE,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.NRDCONTA',
                            pr_dsdadant => rg_craplcm.NRDCONTA,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.NRDOCMTO',
                            pr_dsdadant => rg_craplcm.NRDOCMTO,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.CDHISTOR',
                            pr_dsdadant => rg_craplcm.CDHISTOR,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.NRSEQDIG',
                            pr_dsdadant => rg_craplcm.NRSEQDIG,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.VLLANMTO',
                            pr_dsdadant => rg_craplcm.VLLANMTO,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.NRDCTABB',
                            pr_dsdadant => rg_craplcm.NRDCTABB,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.CDPESQBB',
                            pr_dsdadant => rg_craplcm.CDPESQBB,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.DTREFERE',
                            pr_dsdadant => rg_craplcm.DTREFERE,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.HRTRANSA',
                            pr_dsdadant => rg_craplcm.HRTRANSA,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.CDCOOPER',
                            pr_dsdadant => rg_craplcm.CDCOOPER,
                            pr_dsdadatu => null);

  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'craplcm.DTTRANS',
                            pr_dsdadant => rg_craplcm.DTTRANS,
                            pr_dsdadatu => null);

  close cr_craplcm;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
END;
