DECLARE

  vr_cdcritic cecred.crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_exc_saida EXCEPTION;
  rw_crapdat  cecred.BTCH0001.cr_crapdat%ROWTYPE;
  vr_des_reto varchar(3);
  vr_tab_erro cecred.GENE0001.typ_tab_erro;

  TYPE dados_typ IS RECORD(
    vr_cdcooper cecred.crapcop.cdcooper%TYPE,
    vr_nrdconta cecred.crapass.nrdconta%TYPE,
    vr_nrctremp cecred.craplem.nrctremp%TYPE,
    vr_vllanmto cecred.craplem.vllanmto%TYPE,
    vr_cdhistor cecred.craplem.cdhistor%TYPE);

  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados t_dados_tab := t_dados_tab();

  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
      FROM cecred.crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

BEGIN

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 159360;
	v_dados(v_dados.last()).vr_nrctremp := 371496;
	v_dados(v_dados.last()).vr_vllanmto := 119.74;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 368148;
	v_dados(v_dados.last()).vr_nrctremp := 326262;
	v_dados(v_dados.last()).vr_vllanmto := 146.02;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 419052;
	v_dados(v_dados.last()).vr_nrctremp := 366778;
	v_dados(v_dados.last()).vr_vllanmto := 63.42;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 499196;
	v_dados(v_dados.last()).vr_nrctremp := 359792;
	v_dados(v_dados.last()).vr_vllanmto := 49.66;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 504831;
	v_dados(v_dados.last()).vr_nrctremp := 303314;
	v_dados(v_dados.last()).vr_vllanmto := 81.88;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 509094;
	v_dados(v_dados.last()).vr_nrctremp := 395508;
	v_dados(v_dados.last()).vr_vllanmto := 21.44;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 608475;
	v_dados(v_dados.last()).vr_nrctremp := 353441;
	v_dados(v_dados.last()).vr_vllanmto := 302.58;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 622435;
	v_dados(v_dados.last()).vr_nrctremp := 304265;
	v_dados(v_dados.last()).vr_vllanmto := 17.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 624462;
	v_dados(v_dados.last()).vr_nrctremp := 403401;
	v_dados(v_dados.last()).vr_vllanmto := 51.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 697540;
	v_dados(v_dados.last()).vr_nrctremp := 317240;
	v_dados(v_dados.last()).vr_vllanmto := 205.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 736767;
	v_dados(v_dados.last()).vr_nrctremp := 358645;
	v_dados(v_dados.last()).vr_vllanmto := 160.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 770876;
	v_dados(v_dados.last()).vr_nrctremp := 303009;
	v_dados(v_dados.last()).vr_vllanmto := 354.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 831581;
	v_dados(v_dados.last()).vr_nrctremp := 320894;
	v_dados(v_dados.last()).vr_vllanmto := 156.28;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 835358;
	v_dados(v_dados.last()).vr_nrctremp := 313093;
	v_dados(v_dados.last()).vr_vllanmto := 140.26;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 858072;
	v_dados(v_dados.last()).vr_nrctremp := 299588;
	v_dados(v_dados.last()).vr_vllanmto := 482.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 859354;
	v_dados(v_dados.last()).vr_nrctremp := 382251;
	v_dados(v_dados.last()).vr_vllanmto := 98.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 870110;
	v_dados(v_dados.last()).vr_nrctremp := 373409;
	v_dados(v_dados.last()).vr_vllanmto := 223.12;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 884367;
	v_dados(v_dados.last()).vr_nrctremp := 276947;
	v_dados(v_dados.last()).vr_vllanmto := 342.38;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 887382;
	v_dados(v_dados.last()).vr_nrctremp := 334227;
	v_dados(v_dados.last()).vr_vllanmto := 116.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 890499;
	v_dados(v_dados.last()).vr_nrctremp := 279292;
	v_dados(v_dados.last()).vr_vllanmto := 266.58;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 891134;
	v_dados(v_dados.last()).vr_nrctremp := 277529;
	v_dados(v_dados.last()).vr_vllanmto := 383.86;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 909165;
	v_dados(v_dados.last()).vr_nrctremp := 281596;
	v_dados(v_dados.last()).vr_vllanmto := 229.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 927228;
	v_dados(v_dados.last()).vr_nrctremp := 287284;
	v_dados(v_dados.last()).vr_vllanmto := 2331.8;
	v_dados(v_dados.last()).vr_cdhistor := 1040;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 930938;
	v_dados(v_dados.last()).vr_nrctremp := 322349;
	v_dados(v_dados.last()).vr_vllanmto := 247.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 950475;
	v_dados(v_dados.last()).vr_nrctremp := 294242;
	v_dados(v_dados.last()).vr_vllanmto := 94.72;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 958883;
	v_dados(v_dados.last()).vr_nrctremp := 329872;
	v_dados(v_dados.last()).vr_vllanmto := 566.26;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 966835;
	v_dados(v_dados.last()).vr_nrctremp := 328953;
	v_dados(v_dados.last()).vr_vllanmto := 37.94;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 978442;
	v_dados(v_dados.last()).vr_nrctremp := 367150;
	v_dados(v_dados.last()).vr_vllanmto := 59.4;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 987905;
	v_dados(v_dados.last()).vr_nrctremp := 311566;
	v_dados(v_dados.last()).vr_vllanmto := 1483.46;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 989231;
	v_dados(v_dados.last()).vr_nrctremp := 307718;
	v_dados(v_dados.last()).vr_vllanmto := 15.61;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1009605;
	v_dados(v_dados.last()).vr_nrctremp := 312639;
	v_dados(v_dados.last()).vr_vllanmto := 68.65;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1069217;
	v_dados(v_dados.last()).vr_nrctremp := 338555;
	v_dados(v_dados.last()).vr_vllanmto := 114.34;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1079115;
	v_dados(v_dados.last()).vr_nrctremp := 335834;
	v_dados(v_dados.last()).vr_vllanmto := 53.2;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1080946;
	v_dados(v_dados.last()).vr_nrctremp := 377942;
	v_dados(v_dados.last()).vr_vllanmto := 80.66;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1091891;
	v_dados(v_dados.last()).vr_nrctremp := 407029;
	v_dados(v_dados.last()).vr_vllanmto := 28.82;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1094157;
	v_dados(v_dados.last()).vr_nrctremp := 341025;
	v_dados(v_dados.last()).vr_vllanmto := 77.96;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1099434;
	v_dados(v_dados.last()).vr_nrctremp := 348550;
	v_dados(v_dados.last()).vr_vllanmto := 227.82;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1101897;
	v_dados(v_dados.last()).vr_nrctremp := 344567;
	v_dados(v_dados.last()).vr_vllanmto := 231.8;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1104870;
	v_dados(v_dados.last()).vr_nrctremp := 344916;
	v_dados(v_dados.last()).vr_vllanmto := 138.08;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1106880;
	v_dados(v_dados.last()).vr_nrctremp := 345685;
	v_dados(v_dados.last()).vr_vllanmto := 64.67;
	v_dados(v_dados.last()).vr_cdhistor := 3918;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1119605;
	v_dados(v_dados.last()).vr_nrctremp := 352146;
	v_dados(v_dados.last()).vr_vllanmto := 170.55;
	v_dados(v_dados.last()).vr_cdhistor := 3919;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1125664;
	v_dados(v_dados.last()).vr_nrctremp := 354805;
	v_dados(v_dados.last()).vr_vllanmto := 340.1;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1136470;
	v_dados(v_dados.last()).vr_nrctremp := 358638;
	v_dados(v_dados.last()).vr_vllanmto := 90.26;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1165046;
	v_dados(v_dados.last()).vr_nrctremp := 400449;
	v_dados(v_dados.last()).vr_vllanmto := 39.24;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 1169190;
	v_dados(v_dados.last()).vr_nrctremp := 395175;
	v_dados(v_dados.last()).vr_vllanmto := 17.8;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 14466244;
	v_dados(v_dados.last()).vr_nrctremp := 363449;
	v_dados(v_dados.last()).vr_vllanmto := 40.52;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 14646846;
	v_dados(v_dados.last()).vr_nrctremp := 371966;
	v_dados(v_dados.last()).vr_vllanmto := 54.62;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 14989751;
	v_dados(v_dados.last()).vr_nrctremp := 388115;
	v_dados(v_dados.last()).vr_vllanmto := 65;
	v_dados(v_dados.last()).vr_cdhistor := 3883;

	v_dados.extend();
	v_dados(v_dados.last()).vr_cdcooper := 2;
	v_dados(v_dados.last()).vr_nrdconta := 15813070;
	v_dados(v_dados.last()).vr_nrctremp := 423443;
	v_dados(v_dados.last()).vr_vllanmto := 290.84;
	v_dados(v_dados.last()).vr_cdhistor := 3919;


  FOR x IN NVL(v_dados.first(), 1) .. nvl(v_dados.last(), 0) LOOP
  
    OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => v_dados(x).vr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE cecred.btch0001.cr_crapdat;
  
    OPEN cr_crapass(pr_cdcooper => v_dados(x).vr_cdcooper, pr_nrdconta => v_dados(x).vr_nrdconta);
    FETCH cr_crapass
      INTO rw_crapass;
    CLOSE cr_crapass;
  
    cecred.EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => v_dados(x).vr_cdcooper,
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_cdagenci => rw_crapass.cdagenci,
                                           pr_cdbccxlt => 100,
                                           pr_cdoperad => 1,
                                           pr_cdpactra => rw_crapass.cdagenci,
                                           pr_tplotmov => 5,
                                           pr_nrdolote => 600031,
                                           pr_nrdconta => v_dados(x).vr_nrdconta,
                                           pr_cdhistor => v_dados(x).vr_cdhistor,
                                           pr_nrctremp => v_dados(x).vr_nrctremp,
                                           pr_vllanmto => v_dados(x).vr_vllanmto,
                                           pr_dtpagemp => rw_crapdat.dtmvtolt,
                                           pr_txjurepr => 0,
                                           pr_vlpreemp => 0,
                                           pr_nrsequni => 0,
                                           pr_nrparepr => 0,
                                           pr_flgincre => FALSE,
                                           pr_flgcredi => FALSE,
                                           pr_nrseqava => 0,
                                           pr_cdorigem => 5,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
  
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  END LOOP;

  COMMIT;

EXCEPTION

  WHEN vr_exc_saida THEN
    RAISE_application_error(-20500, vr_dscritic);
    ROLLBACK;
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
