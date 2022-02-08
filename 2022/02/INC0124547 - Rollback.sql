DECLARE
  vr_dttransa    cecred.craplgm.dttransa%type;
  vr_hrtransa    cecred.craplgm.hrtransa%type;
  vr_nrdconta    cecred.crapass.nrdconta%type;
  vr_cdcooper    cecred.crapcop.cdcooper%type;
  vr_cdoperad    cecred.craplgm.cdoperad%TYPE;
  vr_dscritic    cecred.craplgm.dscritic%TYPE;
  vr_cdcooperold cecred.crapcop.cdcooper%type;

  CURSOR cr_craplgm is
    select a.*,
           (select b.dsdadant
              from craplgi b
             where b.cdcooper = a.cdcooper
               and b.nrdconta = a.nrdconta
               and b.nmdcampo = 'crapass.flgctitg') dsdadant
      from craplgm a
     where dstransa =
           'Alteracao do ITG de conta por script - INC0124547';

  rg_craplgm crapass%rowtype;

  vr_nrdrowid ROWID;

BEGIN
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := GENE0002.fn_busca_time;

  FOR rg_craplgm IN cr_craplgm LOOP
  
    if vr_cdcooperold is null then
      vr_cdcooperold := rg_craplgm.cdcooper;
    end if;
  
    vr_cdcooper := rg_craplgm.cdcooper;
    vr_nrdconta := rg_craplgm.nrdconta;
  
    if vr_cdcooperold != vr_cdcooper then
      commit;
    end if;
  
    update crapass a
       set a.flgctitg = rg_craplgm.dsdadant
     where a.cdcooper = vr_cdcooper
       and a.nrdconta = vr_nrdconta;
  
    DELETE CECRED.craplgm lgm
     WHERE lgm.cdcooper = vr_cdcooper
       and lgm.nrdconta = vr_nrdconta
       and lgm.dstransa =
           'Alteracao do ITG de conta por script - INC0123608';
  
    DELETE CECRED.craplgi lgi
     WHERE lgi.cdcooper = vr_cdcooper
       and lgi.nrdconta = vr_nrdconta
       and lgi.nmdcampo = 'crapass.flgctitg';
  
  end loop;
  commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar situa��o cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
