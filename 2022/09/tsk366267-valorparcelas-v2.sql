declare
  TYPE dados_typ IS RECORD(
       vr_cdcooper       crapepr.cdcooper%type,
       vr_nrdconta       crapepr.nrdconta%type,
       vr_nrctremp       crapepr.nrctremp%type);
       
  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados          t_dados_tab := t_dados_tab();
  
begin
    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 879193;
    v_dados(v_dados.last()).vr_nrctremp := 5264961;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 888796;
    v_dados(v_dados.last()).vr_nrctremp := 5263713;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2286939;
    v_dados(v_dados.last()).vr_nrctremp := 5392382;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2379678;
    v_dados(v_dados.last()).vr_nrctremp := 4957190;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2717891;
    v_dados(v_dados.last()).vr_nrctremp := 4947514;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3507220;
    v_dados(v_dados.last()).vr_nrctremp := 5406388;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6235140;
    v_dados(v_dados.last()).vr_nrctremp := 4953029;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6446086;
    v_dados(v_dados.last()).vr_nrctremp := 4960012;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7102615;
    v_dados(v_dados.last()).vr_nrctremp := 4935936;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7540809;
    v_dados(v_dados.last()).vr_nrctremp := 5406786;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9079190;
    v_dados(v_dados.last()).vr_nrctremp := 5267529;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9319247;
    v_dados(v_dados.last()).vr_nrctremp := 4956787;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9426531;
    v_dados(v_dados.last()).vr_nrctremp := 5392607;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9557989;
    v_dados(v_dados.last()).vr_nrctremp := 4941282;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9861882;
    v_dados(v_dados.last()).vr_nrctremp := 5265178;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9914838;
    v_dados(v_dados.last()).vr_nrctremp := 5266179;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10002758;
    v_dados(v_dados.last()).vr_nrctremp := 5264066;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11682175;
    v_dados(v_dados.last()).vr_nrctremp := 5392254;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11846380;
    v_dados(v_dados.last()).vr_nrctremp := 5265273;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 353833;
    v_dados(v_dados.last()).vr_nrctremp := 55034;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 697451;
    v_dados(v_dados.last()).vr_nrctremp := 455257;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 2650428;
    v_dados(v_dados.last()).vr_nrctremp := 435274;
    
    
    FOR i IN NVL(v_dados.first(),1).. NVL(v_dados.last,0) LOOP
      UPDATE cecred.crappep p
         SET vlsdvpar = vlparepr,
             vlsdvsji = vlparepr
       WHERE p.cdcooper = v_dados(i).vr_cdcooper
         AND p.nrdconta = v_dados(i).vr_nrdconta
         AND p.nrctremp = v_dados(i).vr_nrctremp
         and p.inliquid = 0;
    END LOOP;
    
    COMMIT;
    
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;

END;
