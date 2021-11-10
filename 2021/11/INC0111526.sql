DECLARE
  vr_dttransa    cecred.craplgm.dttransa%type;
  vr_hrtransa    cecred.craplgm.hrtransa%type;
  vr_nrdconta    cecred.crapass.nrdconta%type;
  vr_cdcooper    cecred.crapcop.cdcooper%type;
  vr_cdoperad    cecred.craplgm.cdoperad%TYPE;
  vr_dscritic    cecred.craplgm.dscritic%TYPE;
  vr_cdcooperold cecred.crapcop.cdcooper%type;
  vr_nrdrowid    ROWID;

  CURSOR cr_crapass is
    SELECT a.cdsitdct, a.cdcooper, a.nrdconta
      FROM CRAPASS a
     WHERE a.cdsitdct <> 8
       and ((a.cdcooper = 5 and a.nrdconta = 90883) or
           (a.cdcooper = 5 and a.nrdconta = 174599) or
           (a.cdcooper = 5 and a.nrdconta = 136310) or
           (a.cdcooper = 5 and a.nrdconta = 240010) or
           (a.cdcooper = 2 and a.nrdconta = 791865) or
           (a.cdcooper = 2 and a.nrdconta = 834955) or
           (a.cdcooper = 2 and a.nrdconta = 331376) or
           (a.cdcooper = 2 and a.nrdconta = 641294) or
           (a.cdcooper = 13 and a.nrdconta = 240915) or
           (a.cdcooper = 13 and a.nrdconta = 352292) or
           (a.cdcooper = 13 and a.nrdconta = 266884) or
           (a.cdcooper = 13 and a.nrdconta = 367150) or
           (a.cdcooper = 13 and a.nrdconta = 170844) or
           (a.cdcooper = 13 and a.nrdconta = 332330) or
           (a.cdcooper = 13 and a.nrdconta = 339946) or
           (a.cdcooper = 13 and a.nrdconta = 404527) or
           (a.cdcooper = 13 and a.nrdconta = 327409) or
           (a.cdcooper = 13 and a.nrdconta = 420875) or
           (a.cdcooper = 7 and a.nrdconta = 312410) or
           (a.cdcooper = 7 and a.nrdconta = 173703) or
           (a.cdcooper = 7 and a.nrdconta = 301353) or
           (a.cdcooper = 8 and a.nrdconta = 40800) or
           (a.cdcooper = 10 and a.nrdconta = 27715) or
           (a.cdcooper = 11 and a.nrdconta = 63789) or
           (a.cdcooper = 11 and a.nrdconta = 250112) or
           (a.cdcooper = 11 and a.nrdconta = 558443) or
           (a.cdcooper = 11 and a.nrdconta = 594032) or
           (a.cdcooper = 11 and a.nrdconta = 468622) or
           (a.cdcooper = 11 and a.nrdconta = 533300) or
           (a.cdcooper = 11 and a.nrdconta = 412791) or
           (a.cdcooper = 11 and a.nrdconta = 654221) or
           (a.cdcooper = 11 and a.nrdconta = 405965) or
           (a.cdcooper = 11 and a.nrdconta = 553190) or
           (a.cdcooper = 9 and a.nrdconta = 89559) or
           (a.cdcooper = 6 and a.nrdconta = 167010) or
           (a.cdcooper = 1 and a.nrdconta = 9082700) or
           (a.cdcooper = 1 and a.nrdconta = 11296496) or
           (a.cdcooper = 1 and a.nrdconta = 7916604) or
           (a.cdcooper = 1 and a.nrdconta = 11228270) or
           (a.cdcooper = 1 and a.nrdconta = 26786) or
           (a.cdcooper = 1 and a.nrdconta = 10978593) or
           (a.cdcooper = 1 and a.nrdconta = 10956565) or
           (a.cdcooper = 1 and a.nrdconta = 8365628) or
           (a.cdcooper = 1 and a.nrdconta = 9329412) or
           (a.cdcooper = 1 and a.nrdconta = 11004622) or
           (a.cdcooper = 1 and a.nrdconta = 11347406) or
           (a.cdcooper = 1 and a.nrdconta = 8449538) or
           (a.cdcooper = 1 and a.nrdconta = 11373636) or
           (a.cdcooper = 1 and a.nrdconta = 10749900) or
           (a.cdcooper = 1 and a.nrdconta = 10866612) or
           (a.cdcooper = 1 and a.nrdconta = 11242671) or
           (a.cdcooper = 1 and a.nrdconta = 6413722) or
           (a.cdcooper = 1 and a.nrdconta = 7784775) or
           (a.cdcooper = 1 and a.nrdconta = 10764364) or
           (a.cdcooper = 1 and a.nrdconta = 9399399) or
           (a.cdcooper = 1 and a.nrdconta = 10776176) or
           (a.cdcooper = 1 and a.nrdconta = 3524175) or
           (a.cdcooper = 1 and a.nrdconta = 8426783) or
           (a.cdcooper = 1 and a.nrdconta = 9899073) or
           (a.cdcooper = 1 and a.nrdconta = 10027521) or
           (a.cdcooper = 1 and a.nrdconta = 10139184) or
           (a.cdcooper = 1 and a.nrdconta = 11438061) or
           (a.cdcooper = 1 and a.nrdconta = 10571280) or
           (a.cdcooper = 1 and a.nrdconta = 11064064) or
           (a.cdcooper = 1 and a.nrdconta = 11116838) or
           (a.cdcooper = 1 and a.nrdconta = 9373098) or
           (a.cdcooper = 1 and a.nrdconta = 9794506) or
           (a.cdcooper = 1 and a.nrdconta = 11278005) or
           (a.cdcooper = 1 and a.nrdconta = 11139781) or
           (a.cdcooper = 1 and a.nrdconta = 11102543) or
           (a.cdcooper = 1 and a.nrdconta = 10949771) or
           (a.cdcooper = 1 and a.nrdconta = 10925023) or
           (a.cdcooper = 1 and a.nrdconta = 11198397) or
           (a.cdcooper = 1 and a.nrdconta = 11820926) or
           (a.cdcooper = 1 and a.nrdconta = 8854149) or
           (a.cdcooper = 1 and a.nrdconta = 6939660) or
           (a.cdcooper = 1 and a.nrdconta = 10911901) or
           (a.cdcooper = 1 and a.nrdconta = 7753829) or
           (a.cdcooper = 1 and a.nrdconta = 8861676) or
           (a.cdcooper = 1 and a.nrdconta = 6345999) or
           (a.cdcooper = 1 and a.nrdconta = 10282971) or
           (a.cdcooper = 1 and a.nrdconta = 8607729) or
           (a.cdcooper = 1 and a.nrdconta = 10219161) or
           (a.cdcooper = 1 and a.nrdconta = 7726600) or
           (a.cdcooper = 1 and a.nrdconta = 7726090) or
           (a.cdcooper = 16 and a.nrdconta = 615293) or
           (a.cdcooper = 16 and a.nrdconta = 11207) or
           (a.cdcooper = 16 and a.nrdconta = 580511) or
           (a.cdcooper = 16 and a.nrdconta = 597953) or
           (a.cdcooper = 16 and a.nrdconta = 653845) or
           (a.cdcooper = 16 and a.nrdconta = 654116) or
           (a.cdcooper = 16 and a.nrdconta = 509574) or
           (a.cdcooper = 16 and a.nrdconta = 572497));
    
     rg_crapass cr_crapass%rowtype;

BEGIN
  vr_cdcooperold := null;
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := GENE0002.fn_busca_time;

  FOR rg_crapass IN cr_crapass LOOP
  
    if vr_cdcooperold is null then
      vr_cdcooperold := rg_crapass.cdcooper;
    end if;
  
    vr_cdcooper := rg_crapass.cdcooper;
    vr_nrdconta := rg_crapass.nrdconta;
  
    if vr_cdcooperold != vr_cdcooper then
      commit;
    end if;
  
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => 'Alteracao da situacao de conta por script - INC0111526',
                         pr_dttransa => vr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vr_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => vr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.cdsitdct',
                              pr_dsdadant => rg_crapass.cdsitdct,
                              pr_dsdadatu => 8);
  
    update crapass a
       set a.cdsitdct = 8
     where a.cdcooper = vr_cdcooper
       and a.nrdconta = vr_nrdconta;
  
  end loop;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar situação cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
