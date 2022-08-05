DECLARE
  TYPE dados_typ IS RECORD(
      vr_cdcooper cecred.crapcop.cdcooper%TYPE,
      vr_nrdconta cecred.crapass.nrdconta%TYPE,
      vr_nrctremp cecred.craplem.nrctremp%TYPE,
      vr_vllanmto cecred.craplem.vllanmto%TYPE);
  
  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados          t_dados_tab := t_dados_tab();
  
BEGIN
    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8723494;
    v_dados(v_dados.last()).vr_nrctremp := 2250081;
    v_dados(v_dados.last()).vr_vllanmto := -668.24;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9185712;
    v_dados(v_dados.last()).vr_nrctremp := 2711652;
    v_dados(v_dados.last()).vr_vllanmto := -587.31;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7621094;
    v_dados(v_dados.last()).vr_nrctremp := 2402134;
    v_dados(v_dados.last()).vr_vllanmto := -581.89;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8889686;
    v_dados(v_dados.last()).vr_nrctremp := 2508103;
    v_dados(v_dados.last()).vr_vllanmto := -563.67;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9875034;
    v_dados(v_dados.last()).vr_nrctremp := 2616223;
    v_dados(v_dados.last()).vr_vllanmto := -329.85;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9667490;
    v_dados(v_dados.last()).vr_nrctremp := 2499456;
    v_dados(v_dados.last()).vr_vllanmto := -288.79;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9352473;
    v_dados(v_dados.last()).vr_nrctremp := 2717109;
    v_dados(v_dados.last()).vr_vllanmto := -286.67;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10824707;
    v_dados(v_dados.last()).vr_nrctremp := 2230580;
    v_dados(v_dados.last()).vr_vllanmto := -253.88;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8723494;
    v_dados(v_dados.last()).vr_nrctremp := 2250002;
    v_dados(v_dados.last()).vr_vllanmto := -236.8;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8681830;
    v_dados(v_dados.last()).vr_nrctremp := 2245189;
    v_dados(v_dados.last()).vr_vllanmto := -223.63;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9221603;
    v_dados(v_dados.last()).vr_nrctremp := 2463269;
    v_dados(v_dados.last()).vr_vllanmto := -207.51;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7242751;
    v_dados(v_dados.last()).vr_nrctremp := 2751523;
    v_dados(v_dados.last()).vr_vllanmto := -206.48;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10775170;
    v_dados(v_dados.last()).vr_nrctremp := 2519055;
    v_dados(v_dados.last()).vr_vllanmto := -185.83;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9707603;
    v_dados(v_dados.last()).vr_nrctremp := 2278292;
    v_dados(v_dados.last()).vr_vllanmto := -150.94;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6655092;
    v_dados(v_dados.last()).vr_nrctremp := 2522843;
    v_dados(v_dados.last()).vr_vllanmto := -131.65;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10616144;
    v_dados(v_dados.last()).vr_nrctremp := 2364448;
    v_dados(v_dados.last()).vr_vllanmto := -122.19;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10775170;
    v_dados(v_dados.last()).vr_nrctremp := 2519048;
    v_dados(v_dados.last()).vr_vllanmto := -112.45;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8723494;
    v_dados(v_dados.last()).vr_nrctremp := 2250041;
    v_dados(v_dados.last()).vr_vllanmto := -90.02;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6655092;
    v_dados(v_dados.last()).vr_nrctremp := 2522825;
    v_dados(v_dados.last()).vr_vllanmto := -80.94;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9536361;
    v_dados(v_dados.last()).vr_nrctremp := 2508219;
    v_dados(v_dados.last()).vr_vllanmto := -76.42;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10844945;
    v_dados(v_dados.last()).vr_nrctremp := 2495672;
    v_dados(v_dados.last()).vr_vllanmto := -66.1;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9989862;
    v_dados(v_dados.last()).vr_nrctremp := 2609960;
    v_dados(v_dados.last()).vr_vllanmto := -57.66;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8399204;
    v_dados(v_dados.last()).vr_nrctremp := 2227183;
    v_dados(v_dados.last()).vr_vllanmto := -46.61;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8683930;
    v_dados(v_dados.last()).vr_nrctremp := 2462690;
    v_dados(v_dados.last()).vr_vllanmto := -708.64;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6662226;
    v_dados(v_dados.last()).vr_nrctremp := 2982767;
    v_dados(v_dados.last()).vr_vllanmto := -314.34;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10647503;
    v_dados(v_dados.last()).vr_nrctremp := 2600504;
    v_dados(v_dados.last()).vr_vllanmto := -91.44;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10214046;
    v_dados(v_dados.last()).vr_nrctremp := 2721729;
    v_dados(v_dados.last()).vr_vllanmto := -88.56;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9631003;
    v_dados(v_dados.last()).vr_nrctremp := 2712190;
    v_dados(v_dados.last()).vr_vllanmto := -84.12;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8974888;
    v_dados(v_dados.last()).vr_nrctremp := 2466188;
    v_dados(v_dados.last()).vr_vllanmto := -82.59;
    
    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10360409;
    v_dados(v_dados.last()).vr_nrctremp := 2542403;
    v_dados(v_dados.last()).vr_vllanmto := -1108.37;
    
    FOR x IN NVL(v_dados.first(),1)..nvl(v_dados.last(),0) LOOP
      UPDATE CECRED.CRAPEPR
         SET vlprejuz = vlprejuz + v_dados(x).vr_vllanmto,
             vlsdprej = vlsdprej + v_dados(x).vr_vllanmto
       WHERE CDCOOPER = v_dados(x).vr_cdcooper
         AND NRDCONTA = v_dados(x).vr_nrdconta
         AND NRCTREMP = v_dados(x).vr_nrctremp;
         
    END LOOP;
    
    COMMIT;
    
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
