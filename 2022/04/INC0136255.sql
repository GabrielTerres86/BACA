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
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 2 newsit
      FROM CRAPASS t
     WHERE 1=1
       and cdcooper = 11
       and nrdconta in (337
                       ,3441
                       ,19240
                       ,4782
                       ,61514
                       ,38580
                       ,38628
                       ,84050
                       ,39373
                       ,56723
                       ,68179
                       ,60461
                       ,81310
                       ,41416
                       ,60682
                       ,83518
                       ,66427
                       ,46310
                       ,89761
                       ,58068
                       ,94170
                       ,98345
                       ,94951
                       ,119547
                       ,147460
                       ,155918
                       ,191744
                       ,197025
                       ,152595
                       ,201413
                       ,203130
                       ,224294
                       ,238775
                       ,71854
                       ,243612
                       ,240931
                       ,194530
                       ,40754
                       ,268119
                       ,178764
                       ,282596
                       ,282669
                       ,290840
                       ,306975
                       ,329665
                       ,345776
                       ,366935
                       ,305332
                       ,188450
                       ,372854
                       ,378011
                       ,390399
                       ,399531
                       ,404403
                       ,422240
                       ,394920
                       ,430064
                       ,434809
                       ,449105
                       ,322920
                       ,424463
                       ,467790
                       ,480274
                       ,366919
                       ,480436
                       ,424757
                       ,62987
                       ,509221
                       ,440973
                       ,527106
                       ,541915
                       ,524352
                       ,365211
                       ,521450
                       ,556130
                       ,572705
                       ,90360
                       ,578304
                       ,477931
                       ,437557
                       ,159557
                       ,334430
                       ,154563
                       ,430455
                       ,697010
                       ,168718
                       ,626449
                       ,435236
                       ,432466
                       ,431540
                       ,76716
                       ,430323
                       ,434698
                       ,430951
                       ,21997
                       ,281638
                       ,320820
                       ,356301
                       ,397865
                       ,205931
                       ,486752
                       );
           

  rg_crapass cr_crapass%rowtype;

BEGIN
  vr_cdcooperold := null;
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := GENE0002.fn_busca_time;

  FOR rg_crapass IN cr_crapass LOOP
  
    vr_cdcooper := rg_crapass.cdcooper;
    vr_nrdconta := rg_crapass.nrdconta;
    
    IF (rg_crapass.flgctitg = 2) THEN
      dbms_output.put_line('Conta já está ativa: ' || vr_nrdconta);
      continue;
    END IF;
    
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => 'Alteracao do ITG de conta por script - INC0136255',
                         pr_dttransa => vr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vr_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => vr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.flgctitg',
                              pr_dsdadant => rg_crapass.flgctitg,
                              pr_dsdadatu => rg_crapass.newsit);
  
    update crapass a
       set a.flgctitg = rg_crapass.newsit
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
