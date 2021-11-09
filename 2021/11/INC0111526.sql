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
    SELECT t.cdsitdct,
           t.cdcooper,
           t.nrdconta
      FROM CRAPASS t
     WHERE (t.cdcooper = 9 AND t.nrdconta IN (89559))
        OR (t.cdcooper = 6 AND t.nrdconta IN (167010))
        OR (t.cdcooper = 8 AND t.nrdconta IN (40800))
        OR (t.cdcooper = 10 AND t.nrdconta IN (27715))
        OR (t.cdcooper = 11 AND
           t.nrdconta IN (63789,
                           250112,
                           558443,
                           594032,
                           468622,
                           533300,
                           412791,
                           654221,
                           405965,
                           553190))
        OR (t.cdcooper = 7 AND t.nrdconta IN (312410, 173703, 301353))
        OR (t.cdcooper = 13 AND
           t.nrdconta IN (240915,
                           352292,
                           266884,
                           367150,
                           170844,
                           332330,
                           339946,
                           404527,
                           327409,
                           420875))
        OR (t.cdcooper = 5 AND
           t.nrdconta IN (90883, 174599, 136310, 240010))
        OR (t.cdcooper = 16 AND
           t.nrdconta IN
           (615293, 11207, 580511, 597953, 653845, 654116, 509574, 572497))
        OR (t.cdcooper = 1 AND
           t.nrdconta IN (9082700,
                           11296496,
                           7916604,
                           11228270,
                           26786,
                           10978593,
                           10956565,
                           8365628,
                           9329412,
                           11004622,
                           11347406,
                           8449538,
                           11373636,
                           10749900,
                           10866612,
                           11242671,
                           6413722,
                           7784775,
                           10764364,
                           9399399,
                           10776176,
                           3524175,
                           8426783,
                           9899073,
                           10027521,
                           10139184,
                           11438061,
                           10571280,
                           11064064,
                           11116838,
                           9373098,
                           9794506,
                           11278005,
                           11139781,
                           11102543,
                           10949771,
                           10925023,
                           11198397,
                           11820926,
                           8854149,
                           6939660,
                           10911901,
                           7753829,
                           8861676,
                           6345999,
                           10282971,
                           8607729,
                           10219161,
                           7726600,
                           7726090));

  rg_crapass cr_crapass%rowtype;

BEGIN
  vr_cdcooperold := null;
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;
  
  
  
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
