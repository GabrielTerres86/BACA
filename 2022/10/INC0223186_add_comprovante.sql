DECLARE
  TYPE tchaveconsulta IS RECORD(
    cdcooper NUMBER,
    nrdconta NUMBER,
    vllanaut NUMBER(20, 2),
    cdempres NUMBER,
    nrdocmto NUMBER);

  TYPE ttableconsulta IS TABLE OF tchaveconsulta INDEX BY PLS_INTEGER;

  vlistaconsulta ttableconsulta;
  i              NUMBER := 0;
  vr_dsinfor3    cecred.crappro.dsinform##1%TYPE;
  vr_dsprotoc    cecred.crappro.dsprotoc%TYPE;
  vr_dscritic    VARCHAR2(4000);
  vr_des_erro    VARCHAR2(4000);
  vr_idprglog    cecred.tbgen_prglog.idprglog%TYPE;

  CURSOR cr_crapatr(pr_cdcooper IN cecred.crapatr.cdcooper%TYPE,
                    pr_nrdconta IN cecred.crapatr.nrdconta%TYPE,
                    pr_cdempres IN cecred.crapatr.cdempres%TYPE,
                    pr_nrdocmto IN cecred.craplau.nrdocmto%TYPE) IS
    SELECT atr.cdrefere,
           atr.cdempcon,
           atr.cdsegmto,
           atr.dshisext,
           atr.nrdconta
      FROM cecred.crapatr atr
     WHERE atr.cdhistor = 3292
       AND atr.cdcooper = pr_cdcooper
       AND atr.cdempres = pr_cdempres
       AND atr.cdrefere = pr_nrdocmto
       AND rownum = 1;
  rw_crapatr cr_crapatr%ROWTYPE;

  CURSOR cr_crapcon(pr_cdcooper IN crapcon.cdcooper%TYPE,
                    pr_cdempcon IN crapcon.cdempcon%TYPE,
                    pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
    SELECT crapcon.nmextcon
      FROM cecred.crapcon
     WHERE crapcon.cdcooper = pr_cdcooper
       AND crapcon.cdempcon = pr_cdempcon
       AND crapcon.cdsegmto = pr_cdsegmto;
  rw_crapcon cr_crapcon%ROWTYPE;
BEGIN
  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 79.88;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 52122123;
  vlistaconsulta(i).nrdconta := 656909;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 54.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 156272;
  vlistaconsulta(i).nrdconta := 898937;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 54.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 179671;
  vlistaconsulta(i).nrdconta := 548944;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 154.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 225908;
  vlistaconsulta(i).nrdconta := 619507;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 54.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 243116;
  vlistaconsulta(i).nrdconta := 571024;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 54.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 245917;
  vlistaconsulta(i).nrdconta := 250252;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 54.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 246603;
  vlistaconsulta(i).nrdconta := 627330;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 64.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 266183;
  vlistaconsulta(i).nrdconta := 463787;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 54.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 281530;
  vlistaconsulta(i).nrdconta := 673951;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 54.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 283177;
  vlistaconsulta(i).nrdconta := 207519;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 54.55;
  vlistaconsulta(i).cdempres := 8261426;
  vlistaconsulta(i).nrdocmto := 286630;
  vlistaconsulta(i).nrdconta := 355836;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 99.91;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402102741820;
  vlistaconsulta(i).nrdconta := 1038753;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 99.91;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402160569299;
  vlistaconsulta(i).nrdconta := 1030850;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 99.91;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402276296516;
  vlistaconsulta(i).nrdconta := 816540;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 517.88;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401790463999;
  vlistaconsulta(i).nrdconta := 331880;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.8;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402055431966;
  vlistaconsulta(i).nrdconta := 513423;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402176188406;
  vlistaconsulta(i).nrdconta := 812315;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402100631815;
  vlistaconsulta(i).nrdconta := 763101;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402136957989;
  vlistaconsulta(i).nrdconta := 877565;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 99.9;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402152164182;
  vlistaconsulta(i).nrdconta := 373273;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 37.7;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401923746301;
  vlistaconsulta(i).nrdconta := 528692;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402003987400;
  vlistaconsulta(i).nrdconta := 312142;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 192.83;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401735769760;
  vlistaconsulta(i).nrdconta := 609277;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 130.54;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401845692828;
  vlistaconsulta(i).nrdconta := 159557;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 148.79;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401824962094;
  vlistaconsulta(i).nrdconta := 1026674;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 40211160545;
  vlistaconsulta(i).nrdconta := 734063;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402158133750;
  vlistaconsulta(i).nrdconta := 14990512;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402172861408;
  vlistaconsulta(i).nrdconta := 528960;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 105.57;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402232941171;
  vlistaconsulta(i).nrdconta := 167630;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 169.87;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402041052660;
  vlistaconsulta(i).nrdconta := 514233;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 129.84;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402100235081;
  vlistaconsulta(i).nrdconta := 218197;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 94.88;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401959577654;
  vlistaconsulta(i).nrdconta := 746320;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 99.96;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402017895290;
  vlistaconsulta(i).nrdconta := 497479;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 104.85;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402123760310;
  vlistaconsulta(i).nrdconta := 432270;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 71.09;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401366920751;
  vlistaconsulta(i).nrdconta := 451762;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 110.71;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401410870554;
  vlistaconsulta(i).nrdconta := 392006;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402021147975;
  vlistaconsulta(i).nrdconta := 780790;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402167058923;
  vlistaconsulta(i).nrdconta := 984310;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402192491216;
  vlistaconsulta(i).nrdconta := 802034;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 40215882298;
  vlistaconsulta(i).nrdconta := 762296;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 69.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401544322200;
  vlistaconsulta(i).nrdconta := 621170;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 79.08;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401996808496;
  vlistaconsulta(i).nrdconta := 715735;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 2;
  vlistaconsulta(i).vllanaut := 110.5;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402012035587;
  vlistaconsulta(i).nrdconta := 509060;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 5;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402091982820;
  vlistaconsulta(i).nrdconta := 6556;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 6;
  vlistaconsulta(i).vllanaut := 119.81;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402042176347;
  vlistaconsulta(i).nrdconta := 80063;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 6;
  vlistaconsulta(i).vllanaut := 84.81;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401507977485;
  vlistaconsulta(i).nrdconta := 68942;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 6;
  vlistaconsulta(i).vllanaut := 266.44;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401780712214;
  vlistaconsulta(i).nrdconta := 11576;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 6;
  vlistaconsulta(i).vllanaut := 54.87;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401880857449;
  vlistaconsulta(i).nrdconta := 1465;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 6;
  vlistaconsulta(i).vllanaut := 104.64;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402191937423;
  vlistaconsulta(i).nrdconta := 1465;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 209.31;
  vlistaconsulta(i).cdempres := 8460369;
  vlistaconsulta(i).nrdocmto := 2910372;
  vlistaconsulta(i).nrdconta := 234117;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 385.26;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 75333899;
  vlistaconsulta(i).nrdconta := 275921;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 72.06;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 102270538;
  vlistaconsulta(i).nrdconta := 189111;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 178.59;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 80018009;
  vlistaconsulta(i).nrdconta := 345121;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 398.86;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 96009047;
  vlistaconsulta(i).nrdconta := 392111;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 3253.09;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 77442172;
  vlistaconsulta(i).nrdconta := 341835;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 168.17;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 72231980;
  vlistaconsulta(i).nrdconta := 97870;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 53.97;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 109268695;
  vlistaconsulta(i).nrdconta := 353310;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 133.41;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 3041255;
  vlistaconsulta(i).nrdconta := 169676;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 378.02;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 109014944;
  vlistaconsulta(i).nrdconta := 247952;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 99.91;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402131674776;
  vlistaconsulta(i).nrdconta := 128473;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 119.88;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402130436960;
  vlistaconsulta(i).nrdconta := 77259;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 99.91;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402143194206;
  vlistaconsulta(i).nrdconta := 120693;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 31.34;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401410268404;
  vlistaconsulta(i).nrdconta := 120898;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402182164098;
  vlistaconsulta(i).nrdconta := 198650;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 110.8;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 40210255933;
  vlistaconsulta(i).nrdconta := 365580;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 98.39;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402075999179;
  vlistaconsulta(i).nrdconta := 245429;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 100.4;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401524292208;
  vlistaconsulta(i).nrdconta := 245364;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 59.99;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401262434243;
  vlistaconsulta(i).nrdconta := 241059;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 183.07;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401503060811;
  vlistaconsulta(i).nrdconta := 78670;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 125.66;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401611094390;
  vlistaconsulta(i).nrdconta := 260673;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 133.09;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401756030226;
  vlistaconsulta(i).nrdconta := 2640;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 99.85;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402112574639;
  vlistaconsulta(i).nrdconta := 11240;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402173372362;
  vlistaconsulta(i).nrdconta := 137022;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 99.8;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402105772816;
  vlistaconsulta(i).nrdconta := 14109;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 7;
  vlistaconsulta(i).vllanaut := 129.68;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402142420024;
  vlistaconsulta(i).nrdconta := 192910;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 8;
  vlistaconsulta(i).vllanaut := 120.79;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 995620805515;
  vlistaconsulta(i).nrdconta := 28517;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 8;
  vlistaconsulta(i).vllanaut := 82.64;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401614924432;
  vlistaconsulta(i).nrdconta := 20710;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 222.69;
  vlistaconsulta(i).cdempres := 8460369;
  vlistaconsulta(i).nrdocmto := 16365931;
  vlistaconsulta(i).nrdconta := 76155;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 166.46;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 80804390;
  vlistaconsulta(i).nrdconta := 259780;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 67;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 106322850;
  vlistaconsulta(i).nrdconta := 261378;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 689.13;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 107426200;
  vlistaconsulta(i).nrdconta := 199885;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 160.6;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 107383039;
  vlistaconsulta(i).nrdconta := 199885;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 80.08;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 107426340;
  vlistaconsulta(i).nrdconta := 199885;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 22.62;
  vlistaconsulta(i).cdempres := 8360006;
  vlistaconsulta(i).nrdocmto := 14596032;
  vlistaconsulta(i).nrdconta := 479411;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 99.9;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402294534343;
  vlistaconsulta(i).nrdconta := 343293;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 114.67;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401062820238;
  vlistaconsulta(i).nrdconta := 15130;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 99.9;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402075396229;
  vlistaconsulta(i).nrdconta := 89672;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 99.77;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402277788153;
  vlistaconsulta(i).nrdconta := 474975;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 81.95;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402004637829;
  vlistaconsulta(i).nrdconta := 40649;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 99.85;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402083413515;
  vlistaconsulta(i).nrdconta := 32646;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 9;
  vlistaconsulta(i).vllanaut := 114.78;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402243627541;
  vlistaconsulta(i).nrdconta := 425109;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 99.91;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402136308689;
  vlistaconsulta(i).nrdconta := 206253;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 49.98;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401693518827;
  vlistaconsulta(i).nrdconta := 43486;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 99.96;
  vlistaconsulta(i).cdempres := 8460296;
  vlistaconsulta(i).nrdocmto := 2130010248960;
  vlistaconsulta(i).nrdconta := 53775;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 127.31;
  vlistaconsulta(i).cdempres := 8460296;
  vlistaconsulta(i).nrdocmto := 2130010378235;
  vlistaconsulta(i).nrdconta := 156043;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 214.23;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999591910535;
  vlistaconsulta(i).nrdconta := 65005;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 153.67;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999945246790;
  vlistaconsulta(i).nrdconta := 47066;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 232.87;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999426013565;
  vlistaconsulta(i).nrdconta := 131890;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 298.88;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999364768002;
  vlistaconsulta(i).nrdconta := 62766;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 69.86;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999371652081;
  vlistaconsulta(i).nrdconta := 134627;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 99.86;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402117786790;
  vlistaconsulta(i).nrdconta := 122980;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 99.85;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402098171097;
  vlistaconsulta(i).nrdconta := 45721;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 99.77;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 40225694788;
  vlistaconsulta(i).nrdconta := 164623;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 99.85;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402035511637;
  vlistaconsulta(i).nrdconta := 198935;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 10;
  vlistaconsulta(i).vllanaut := 54.99;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 125424773;
  vlistaconsulta(i).nrdconta := 64319;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 11;
  vlistaconsulta(i).vllanaut := 107.86;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402003184227;
  vlistaconsulta(i).nrdconta := 666050;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 11;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 40218757832;
  vlistaconsulta(i).nrdconta := 513334;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 11;
  vlistaconsulta(i).vllanaut := 172.2;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401636220269;
  vlistaconsulta(i).nrdconta := 254770;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 11;
  vlistaconsulta(i).vllanaut := 99.85;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402153882208;
  vlistaconsulta(i).nrdconta := 363685;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 11;
  vlistaconsulta(i).vllanaut := 185.93;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401219771058;
  vlistaconsulta(i).nrdconta := 39110;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 11;
  vlistaconsulta(i).vllanaut := 106.93;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402101282636;
  vlistaconsulta(i).nrdconta := 532410;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 11;
  vlistaconsulta(i).vllanaut := 87.11;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401816687777;
  vlistaconsulta(i).nrdconta := 232408;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 12;
  vlistaconsulta(i).vllanaut := 59.98;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401516733556;
  vlistaconsulta(i).nrdconta := 72273;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 12;
  vlistaconsulta(i).vllanaut := 87.17;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401573815623;
  vlistaconsulta(i).nrdconta := 32930;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 12;
  vlistaconsulta(i).vllanaut := 60;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401322463892;
  vlistaconsulta(i).nrdconta := 57398;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 64.82;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 93999151;
  vlistaconsulta(i).nrdconta := 89249;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 130.18;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 50402420;
  vlistaconsulta(i).nrdconta := 242306;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 802.62;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 95911030;
  vlistaconsulta(i).nrdconta := 217549;
  vlistaconsulta(i).nrdconta := 355976;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 32.03;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 27049086;
  vlistaconsulta(i).nrdconta := 268127;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 81.63;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 99057620;
  vlistaconsulta(i).nrdconta := 709557;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 72.11;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 102500100;
  vlistaconsulta(i).nrdconta := 552038;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 108.96;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 84858184;
  vlistaconsulta(i).nrdconta := 296945;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 160.04;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 57239363;
  vlistaconsulta(i).nrdconta := 157856;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 278.95;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 36886980;
  vlistaconsulta(i).nrdconta := 166464;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 74.63;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 43970320;
  vlistaconsulta(i).nrdconta := 166464;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 13;
  vlistaconsulta(i).vllanaut := 130.3;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401971695638;
  vlistaconsulta(i).nrdconta := 7048;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 159.83;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 98137425;
  vlistaconsulta(i).nrdconta := 80144;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 4382.97;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 106187880;
  vlistaconsulta(i).nrdconta := 46671;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 65.48;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 100847986;
  vlistaconsulta(i).nrdconta := 36285;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 167.24;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 85279510;
  vlistaconsulta(i).nrdconta := 64238;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 138.09;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 104965045;
  vlistaconsulta(i).nrdconta := 81078;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 161.57;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 106760793;
  vlistaconsulta(i).nrdconta := 226181;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 62.65;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 104537329;
  vlistaconsulta(i).nrdconta := 195308;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 78.97;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 95921923;
  vlistaconsulta(i).nrdconta := 28460;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 62.11;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 99390159;
  vlistaconsulta(i).nrdconta := 32905;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 251.86;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 33800944;
  vlistaconsulta(i).nrdconta := 26646;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 400.36;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 97716731;
  vlistaconsulta(i).nrdconta := 41599;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 125.21;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 86160931;
  vlistaconsulta(i).nrdconta := 74276;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 46.42;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 105056880;
  vlistaconsulta(i).nrdconta := 52140;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 90.95;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 102892962;
  vlistaconsulta(i).nrdconta := 192015;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 960.35;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 9594671;
  vlistaconsulta(i).nrdconta := 11371;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 88.23;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 53670370;
  vlistaconsulta(i).nrdconta := 11371;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 97.09;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 9671730;
  vlistaconsulta(i).nrdconta := 11100;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 175.98;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 93778660;
  vlistaconsulta(i).nrdconta := 82937;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 93.92;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 36268895;
  vlistaconsulta(i).nrdconta := 174149;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 38.86;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 79273068;
  vlistaconsulta(i).nrdconta := 174149;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 958.7;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 73052663;
  vlistaconsulta(i).nrdconta := 12190;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 158.62;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 77206908;
  vlistaconsulta(i).nrdconta := 12190;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 178.16;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 93901038;
  vlistaconsulta(i).nrdconta := 297984;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 55.27;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 81497326;
  vlistaconsulta(i).nrdconta := 74640;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 20.76;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 83548092;
  vlistaconsulta(i).nrdconta := 8990;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 130.44;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 10664467;
  vlistaconsulta(i).nrdconta := 28924;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 37.49;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 106758659;
  vlistaconsulta(i).nrdconta := 129089;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 149.21;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 84048085;
  vlistaconsulta(i).nrdconta := 57703;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 134.72;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 93108826;
  vlistaconsulta(i).nrdconta := 93602;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 922.2;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 85729671;
  vlistaconsulta(i).nrdconta := 19992;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 1244.18;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 66747546;
  vlistaconsulta(i).nrdconta := 76473;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 299.4;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 66748577;
  vlistaconsulta(i).nrdconta := 76473;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 651.01;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 20404646;
  vlistaconsulta(i).nrdconta := 128112;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 121.19;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 100933963;
  vlistaconsulta(i).nrdconta := 53570;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 71.94;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 107815141;
  vlistaconsulta(i).nrdconta := 220469;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 218.7;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 65136128;
  vlistaconsulta(i).nrdconta := 173673;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 748.39;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 104388684;
  vlistaconsulta(i).nrdconta := 167479;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 93.83;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 23614714;
  vlistaconsulta(i).nrdconta := 18937;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 156.61;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 88180328;
  vlistaconsulta(i).nrdconta := 141186;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 162.06;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 48244783;
  vlistaconsulta(i).nrdconta := 156329;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 118.36;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 9645225;
  vlistaconsulta(i).nrdconta := 167550;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 132.2;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 103694919;
  vlistaconsulta(i).nrdconta := 5053;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 99.16;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 100862276;
  vlistaconsulta(i).nrdconta := 21792;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 70.27;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 31549748;
  vlistaconsulta(i).nrdconta := 8001;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 200.48;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 49664697;
  vlistaconsulta(i).nrdconta := 12289;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 335.21;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 100123007;
  vlistaconsulta(i).nrdconta := 17620;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 160.52;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 72258756;
  vlistaconsulta(i).nrdconta := 12009;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 352.67;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 36066850;
  vlistaconsulta(i).nrdconta := 590;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 81.44;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 28609301;
  vlistaconsulta(i).nrdconta := 23205;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 145.44;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 96949848;
  vlistaconsulta(i).nrdconta := 203874;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 187.27;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 57976554;
  vlistaconsulta(i).nrdconta := 111295;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 159.27;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 93603525;
  vlistaconsulta(i).nrdconta := 101966;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 149.29;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 88579980;
  vlistaconsulta(i).nrdconta := 101230;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 103.06;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 88267547;
  vlistaconsulta(i).nrdconta := 101230;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 202.78;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 100454950;
  vlistaconsulta(i).nrdconta := 116270;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 52;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 9122907;
  vlistaconsulta(i).nrdconta := 141208;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 114.63;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 65750110;
  vlistaconsulta(i).nrdconta := 116408;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 209.33;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 102599939;
  vlistaconsulta(i).nrdconta := 207640;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 85.1;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 93126549;
  vlistaconsulta(i).nrdconta := 30422;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 219.91;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 94608504;
  vlistaconsulta(i).nrdconta := 70998;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 151.9;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 93598750;
  vlistaconsulta(i).nrdconta := 23558;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 158.66;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 83457755;
  vlistaconsulta(i).nrdconta := 93220;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 209.95;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 97617172;
  vlistaconsulta(i).nrdconta := 44040;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 7369.45;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 105172618;
  vlistaconsulta(i).nrdconta := 1163;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 519.77;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 92014070;
  vlistaconsulta(i).nrdconta := 112569;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 64.88;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 85828491;
  vlistaconsulta(i).nrdconta := 671;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 85.1;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 85829560;
  vlistaconsulta(i).nrdconta := 671;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 335.94;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 85829315;
  vlistaconsulta(i).nrdconta := 671;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 486.29;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 104760052;
  vlistaconsulta(i).nrdconta := 194824;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 62.73;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 45304343;
  vlistaconsulta(i).nrdconta := 26018;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 120.46;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 30881528;
  vlistaconsulta(i).nrdconta := 90646;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 108.41;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 63205181;
  vlistaconsulta(i).nrdconta := 29645;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 124.19;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 64320235;
  vlistaconsulta(i).nrdconta := 198510;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 93.83;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 86370090;
  vlistaconsulta(i).nrdconta := 166529;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 150.13;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 94613028;
  vlistaconsulta(i).nrdconta := 81574;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 236.23;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 61881937;
  vlistaconsulta(i).nrdconta := 245194;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 29.84;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 105228060;
  vlistaconsulta(i).nrdconta := 257249;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 246.46;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 98592114;
  vlistaconsulta(i).nrdconta := 159859;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 186.76;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 23215640;
  vlistaconsulta(i).nrdconta := 38873;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 140.16;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 23160756;
  vlistaconsulta(i).nrdconta := 9148;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 210.36;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 97891282;
  vlistaconsulta(i).nrdconta := 60208;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 176.21;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 84917296;
  vlistaconsulta(i).nrdconta := 132462;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 109.15;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 23263083;
  vlistaconsulta(i).nrdconta := 698;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 323.75;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 34088962;
  vlistaconsulta(i).nrdconta := 19682;
  vlistaconsulta(i).nrdconta := 75280;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 67.78;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 68913443;
  vlistaconsulta(i).nrdconta := 269859;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 148.96;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 76788733;
  vlistaconsulta(i).nrdconta := 204927;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 112.46;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 37524186;
  vlistaconsulta(i).nrdconta := 4740;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 216.62;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 24021377;
  vlistaconsulta(i).nrdconta := 3069;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 167.88;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 36038881;
  vlistaconsulta(i).nrdconta := 35289;
  vlistaconsulta(i).nrdconta := 170909;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 78.34;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 43287328;
  vlistaconsulta(i).nrdconta := 35289;
  vlistaconsulta(i).nrdconta := 170909;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 191.86;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 9646043;
  vlistaconsulta(i).nrdconta := 5584;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 168.61;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 96723483;
  vlistaconsulta(i).nrdconta := 115860;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 103.04;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 95082107;
  vlistaconsulta(i).nrdconta := 36358;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 188.25;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 101066031;
  vlistaconsulta(i).nrdconta := 23353;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 194.78;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 98792423;
  vlistaconsulta(i).nrdconta := 23086;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 17.9;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 93943660;
  vlistaconsulta(i).nrdconta := 83089;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 112.27;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 70056200;
  vlistaconsulta(i).nrdconta := 195375;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 138.03;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 48605530;
  vlistaconsulta(i).nrdconta := 37206;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 135.11;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 57424357;
  vlistaconsulta(i).nrdconta := 314315;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 28.39;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 69523207;
  vlistaconsulta(i).nrdconta := 86541;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 68.32;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 9102477;
  vlistaconsulta(i).nrdconta := 189820;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 93.34;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 41372522;
  vlistaconsulta(i).nrdconta := 243582;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 148.09;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 26223031;
  vlistaconsulta(i).nrdconta := 54771;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 321.55;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 75605554;
  vlistaconsulta(i).nrdconta := 21741;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 124.61;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 82062048;
  vlistaconsulta(i).nrdconta := 14403544;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 223.67;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 9104046;
  vlistaconsulta(i).nrdconta := 20311;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 182.5;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 106042874;
  vlistaconsulta(i).nrdconta := 168491;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 107.49;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 73462306;
  vlistaconsulta(i).nrdconta := 37249;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 29.84;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 27187969;
  vlistaconsulta(i).nrdconta := 31712;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 211.29;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 9103791;
  vlistaconsulta(i).nrdconta := 64572;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 82.86;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 67056431;
  vlistaconsulta(i).nrdconta := 23914;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 178.87;
  vlistaconsulta(i).cdempres := 8360111;
  vlistaconsulta(i).nrdocmto := 100862322;
  vlistaconsulta(i).nrdconta := 22551;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 51.53;
  vlistaconsulta(i).cdempres := 8460020;
  vlistaconsulta(i).nrdocmto := 8000347359;
  vlistaconsulta(i).nrdconta := 217956;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 85.99;
  vlistaconsulta(i).cdempres := 8460296;
  vlistaconsulta(i).nrdocmto := 5310090794974;
  vlistaconsulta(i).nrdconta := 154270;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 149.9;
  vlistaconsulta(i).cdempres := 8460106;
  vlistaconsulta(i).nrdocmto := 8972739;
  vlistaconsulta(i).nrdconta := 159166;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 99.9;
  vlistaconsulta(i).cdempres := 8460106;
  vlistaconsulta(i).nrdocmto := 15708365;
  vlistaconsulta(i).nrdconta := 34746;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 121.18;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 9999893031424;
  vlistaconsulta(i).nrdconta := 36552;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 196.42;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 9999871962611;
  vlistaconsulta(i).nrdconta := 2321;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 96.39;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999905630220;
  vlistaconsulta(i).nrdconta := 38032;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 144.2;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999986316423;
  vlistaconsulta(i).nrdconta := 38032;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 162.38;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999710898487;
  vlistaconsulta(i).nrdconta := 108;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 189.99;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999901221244;
  vlistaconsulta(i).nrdconta := 33073;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 155.33;
  vlistaconsulta(i).cdempres := 8460082;
  vlistaconsulta(i).nrdocmto := 8999720186307;
  vlistaconsulta(i).nrdconta := 12980;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 50.99;
  vlistaconsulta(i).cdempres := 8460079;
  vlistaconsulta(i).nrdocmto := 11184401335;
  vlistaconsulta(i).nrdconta := 197076;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 200.98;
  vlistaconsulta(i).cdempres := 8460080;
  vlistaconsulta(i).nrdocmto := 11213018883;
  vlistaconsulta(i).nrdconta := 263370;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 42.99;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 119157489;
  vlistaconsulta(i).nrdconta := 40185;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 132.69;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 103995070;
  vlistaconsulta(i).nrdconta := 178055;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 53.14;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 237015917;
  vlistaconsulta(i).nrdconta := 45845;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 31.18;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 136162171;
  vlistaconsulta(i).nrdconta := 14262487;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := .08;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 152735555;
  vlistaconsulta(i).nrdconta := 31720;
  vlistaconsulta(i).nrdconta := 205974;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 45.6;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 228953968;
  vlistaconsulta(i).nrdconta := 137600;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 54.2;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 100612753;
  vlistaconsulta(i).nrdconta := 75191;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 41.62;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 121888212;
  vlistaconsulta(i).nrdconta := 91545;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 44.99;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 131454699;
  vlistaconsulta(i).nrdconta := 91545;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 30.4;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 221868299;
  vlistaconsulta(i).nrdconta := 14262487;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 14;
  vlistaconsulta(i).vllanaut := 18.18;
  vlistaconsulta(i).cdempres := 8480162;
  vlistaconsulta(i).nrdocmto := 127647022;
  vlistaconsulta(i).nrdconta := 33260;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 74.9;
  vlistaconsulta(i).cdempres := 8460369;
  vlistaconsulta(i).nrdocmto := 11660855;
  vlistaconsulta(i).nrdconta := 19;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 204.58;
  vlistaconsulta(i).cdempres := 8460369;
  vlistaconsulta(i).nrdocmto := 2772680;
  vlistaconsulta(i).nrdconta := 225541;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 76.88;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401281818745;
  vlistaconsulta(i).nrdconta := 613053;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 258.11;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401326393791;
  vlistaconsulta(i).nrdconta := 2003848;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 313.03;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401461305959;
  vlistaconsulta(i).nrdconta := 2293110;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 102.53;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401969037119;
  vlistaconsulta(i).nrdconta := 575402;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 64.72;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 40199270050;
  vlistaconsulta(i).nrdconta := 2155923;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 119.82;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402075504579;
  vlistaconsulta(i).nrdconta := 464996;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 78.52;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402172339795;
  vlistaconsulta(i).nrdconta := 253863;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 128.59;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402019878962;
  vlistaconsulta(i).nrdconta := 69043;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 201.89;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401660495309;
  vlistaconsulta(i).nrdconta := 2688794;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 98.12;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401918351862;
  vlistaconsulta(i).nrdconta := 696471;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 123.4;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401191161593;
  vlistaconsulta(i).nrdconta := 538450;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 176.79;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401381026501;
  vlistaconsulta(i).nrdconta := 2889269;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 164.71;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401681872889;
  vlistaconsulta(i).nrdconta := 295418;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 98.86;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402182322548;
  vlistaconsulta(i).nrdconta := 357022;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 34.83;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401940456295;
  vlistaconsulta(i).nrdconta := 2841150;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 117.75;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402187919046;
  vlistaconsulta(i).nrdconta := 371165;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 72.58;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401531306931;
  vlistaconsulta(i).nrdconta := 220345;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 53.54;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401905846838;
  vlistaconsulta(i).nrdconta := 105880;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 98.23;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401909091548;
  vlistaconsulta(i).nrdconta := 70874;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 98.23;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401908522316;
  vlistaconsulta(i).nrdconta := 1835378;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 78.52;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402082096443;
  vlistaconsulta(i).nrdconta := 868485;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 285.8;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 40166400623;
  vlistaconsulta(i).nrdconta := 462748;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 126.58;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 402065970709;
  vlistaconsulta(i).nrdconta := 407038;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 427.97;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401283860684;
  vlistaconsulta(i).nrdconta := 2538873;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 328.77;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401262718934;
  vlistaconsulta(i).nrdconta := 2137674;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 411.66;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401562283379;
  vlistaconsulta(i).nrdconta := 830364;

  i := i + 1;
  vlistaconsulta(i).cdcooper := 16;
  vlistaconsulta(i).vllanaut := 144.29;
  vlistaconsulta(i).cdempres := 8460313;
  vlistaconsulta(i).nrdocmto := 401663983886;
  vlistaconsulta(i).nrdconta := 140600;

  FOR i IN vlistaconsulta.first .. vlistaconsulta.last LOOP
      OPEN cr_crapatr(vlistaconsulta(i).cdcooper,
                                 vlistaconsulta(i).nrdconta,
                                 vlistaconsulta(i).cdempres,
                                 vlistaconsulta(i).nrdocmto);
      FETCH cr_crapatr INTO rw_crapatr;

        IF cr_crapatr%FOUND THEN
          CLOSE cr_crapatr;
        ELSE
          dbms_output.put_line('cdcooper: '||vlistaconsulta(i).cdcooper||' '||
                               'nrdconta: '||vlistaconsulta(i).nrdconta||' '||
                               'cdempres: '||vlistaconsulta(i).cdempres||' '||
                               'nrdocmto: '||vlistaconsulta(i).nrdocmto);
              CLOSE cr_crapatr;
        END IF;

    FOR rw_crapatr IN cr_crapatr(vlistaconsulta(i).cdcooper,
                                 vlistaconsulta(i).nrdconta,
                                 vlistaconsulta(i).cdempres,
                                 vlistaconsulta(i).nrdocmto) LOOP
    
      OPEN cr_crapcon(pr_cdcooper => vlistaconsulta(i).cdcooper,
                      pr_cdempcon => rw_crapatr.cdempcon,
                      pr_cdsegmto => rw_crapatr.cdsegmto);
      FETCH cr_crapcon
        INTO rw_crapcon;
      CLOSE cr_crapcon;
    
      vr_dsinfor3 := 'Convênio: ' || rw_crapcon.nmextcon ||
                     '#Número Identificador:' || rw_crapatr.cdrefere || 
                     '#' || rw_crapatr.dshisext;
    
      cecred.gene0006.pc_gera_protocolo(pr_cdcooper => vlistaconsulta(i).cdcooper,
                                        pr_dtmvtolt => to_date('16/08/2022', 'DD/MM/YYYY'),
                                        pr_hrtransa => gene0002.fn_busca_time,
                                        pr_nrdconta => vlistaconsulta(i).nrdconta,
                                        pr_nrdocmto => vlistaconsulta(i).nrdocmto,
                                        pr_nrseqaut => 0,
                                        pr_vllanmto => vlistaconsulta(i).vllanaut,
                                        pr_nrdcaixa => 900,
                                        pr_gravapro => TRUE,
                                        pr_cdtippro => 15,
                                        pr_dsinfor1 => 'Pagamento',
                                        pr_dsinfor2 => ' ',
                                        pr_dsinfor3 => vr_dsinfor3,
                                        pr_dscedent => rw_crapcon.nmextcon,
                                        pr_flgagend => FALSE,
                                        pr_nrcpfope => 0,
                                        pr_nrcpfpre => 0,
                                        pr_nmprepos => ' ',
                                        pr_dsprotoc => vr_dsprotoc,
                                        pr_dscritic => vr_dscritic,
                                        pr_des_erro => vr_des_erro);
    
      IF TRIM(vr_dscritic) IS NOT NULL OR TRIM(vr_des_erro) IS NOT NULL THEN
        cecred.pc_log_programa(pr_dstiplog   => 'O',
                               pr_cdprograma => 'INC0223186',
                               pr_cdcooper   => 0,
                               pr_dsmensagem => 'cdcooper: ' || vlistaconsulta(i).cdcooper ||
                                                ' nrdconta: ' || vlistaconsulta(i).nrdconta ||
                                                ' cdempres: ' || vlistaconsulta(i).cdempres ||
                                                ' nrdocmto: ' || vlistaconsulta(i).nrdocmto ||
                                                ' Critica: ' || vr_dscritic ||
                                                ' Erro: ' || vr_des_erro,
                               pr_idprglog   => vr_idprglog);
      END IF;
      COMMIT;
    END LOOP;
  END LOOP;
END;
