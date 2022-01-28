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
SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
  FROM CRAPASS t
 WHERE ((t.cdcooper = 7 and t.nrdconta = 42803) or
       (t.cdcooper = 6 and t.nrdconta = 38830) or
       (t.cdcooper = 1 and t.nrdconta = 9736735) or
       (t.cdcooper = 16 and t.nrdconta = 50750) or
       (t.cdcooper = 16 and t.nrdconta = 2004968) or
       (t.cdcooper = 16 and t.nrdconta = 6437664) or
       (t.cdcooper = 16 and t.nrdconta = 82325) or
       (t.cdcooper = 16 and t.nrdconta = 14567))
union
SELECT t.flgctitg, t.cdcooper, t.nrdconta, 2 newsit
  FROM CRAPASS t
 WHERE ((t.cdcooper = 16 and t.nrdconta = 10561) or
       (t.cdcooper = 16 and t.nrdconta = 2735342));


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
                         pr_dstransa => 'Alteracao do ITG de conta por script - INC0123608',
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
