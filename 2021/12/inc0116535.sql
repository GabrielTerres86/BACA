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
     WHERE (t.cdcooper,t.nrdconta) IN ((13,322733),
                                       (7,255777),
                                       (14,47279),
                                       (14,140503),
                                       (9,247391),
                                       (9,211273),
                                       (6,142956),
                                       (1,2699800),
                                       (1,11178647),
                                       (1,10934626),
                                       (1,2565692),
                                       (1,10030573),
                                       (1,10705740),
                                       (1,11413301),
                                       (1,7204167),
                                       (1,7249608),
                                       (1,1849360),
                                       (1,9825070),
                                       (1,9659790),
                                       (16,686379),
                                       (16,600318),
                                       (16,328391),
                                       (16,554235),
                                       (16,578975),
                                       (16,434388));

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
                         pr_dstransa => 'Alteracao da situacao de conta por script - INC0116535',
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
