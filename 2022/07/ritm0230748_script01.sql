DECLARE

  TYPE dados_typ IS RECORD(
    vr_cdcooper       cecred.tbcrd_cessao_credito.cdcooper%TYPE,
    vr_nrdconta       cecred.tbcrd_cessao_credito.nrdconta%TYPE,
    vr_nrconta_cartao cecred.tbcrd_cessao_credito.nrconta_cartao%TYPE);

  TYPE t_dados_tab IS TABLE OF dados_typ;
  v_dados t_dados_tab := t_dados_tab();

  vr_qtdtotalregistros NUMBER;
  vr_qtdregistrosok    NUMBER;
  vr_qtdregistorserror NUMBER;
  vr_descqtdregistros  VARCHAR2(4000);
  vr_nrdrowid          ROWID;
  vr_desclog           VARCHAR2(4000);

BEGIN


    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 6;
    v_dados(v_dados.last()).vr_nrdconta := 227919;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563232017789;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 6;
    v_dados(v_dados.last()).vr_nrdconta := 205656;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563232015330;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10030697;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239711816;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14311992;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239902059;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13118544;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239782089;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10571787;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239487280;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10378634;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239465611;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10911324;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532983;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10235744;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239443095;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11970197;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239655582;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12874493;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239756372;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12843415;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239752876;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11841559;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239640647;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11895144;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239646652;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12637254;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239733238;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13370952;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239817772;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13335316;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239813381;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13118420;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239782025;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13651072;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239838984;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13676490;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239841758;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13468804;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239819375;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13527371;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239824398;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12530182;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239717813;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13968874;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239871235;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14198827;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239892587;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12348627;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239697711;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14141710;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239887405;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13313592;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239803949;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13995227;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239873539;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13297643;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239800919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13271865;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239797620;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13454994;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239817860;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10038272;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239416065;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9628762;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239365367;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6809235;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239285794;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10147098;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239432314;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11587075;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239662357;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12142328;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239674728;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11860669;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239642810;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12945692;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239766125;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12954683;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239767358;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12999458;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239769121;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13687433;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239842171;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12035939;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239773916;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13112856;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239781452;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13797557;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239852870;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13846418;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239859618;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13888838;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239862032;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13928406;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239866660;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14086328;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239881539;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14091240;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239883131;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14124106;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239886228;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12795984;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239750144;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11367512;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239893132;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12016292;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239660442;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11231556;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239571350;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11638311;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239623110;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13451200;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239817547;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13266438;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239799572;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13526464;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239824320;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13631594;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239835753;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13626302;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239838559;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7710950;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239046700;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9608842;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239362664;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11937521;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239652787;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7907400;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239482170;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14231328;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239902489;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13313231;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239802937;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8816948;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239242945;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10287795;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239450457;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6940439;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239284652;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12133949;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239674820;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12935492;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239761999;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12653454;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239737131;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12979732;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239767542;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9961208;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239769656;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11827521;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239638933;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12271578;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239688569;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12482757;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239712388;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13244663;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239794770;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14152959;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239888511;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14196654;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239892411;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9337849;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239324588;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8701130;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239219145;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12486884;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239717475;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14274353;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239898756;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12817520;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239750066;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14120518;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239885449;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12334146;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239696258;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12648507;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239731836;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13913921;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239865706;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14202158;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239892619;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12463531;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239710205;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13863819;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239861150;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13642537;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239876547;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14104237;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239884518;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13052373;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239778134;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14053705;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239879447;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12914363;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239760752;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11197765;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239567063;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11318473;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239581425;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11699124;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239624128;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6400264;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239010617;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10647937;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239497395;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9902406;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239397520;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11494867;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239601657;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11907843;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239647834;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11216999;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239569391;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11320567;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239586975;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13783114;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239851201;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13844016;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239857057;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11196815;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239567590;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13917579;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239865788;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12747181;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239884665;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12469939;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239710985;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12057940;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239749132;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13267680;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239797199;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13461583;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239818752;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11123915;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239558439;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9678816;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239371879;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9173153;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239420843;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13344978;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239806255;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12376086;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239700540;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13971093;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239871328;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10505300;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239886599;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4086856;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239160362;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8232741;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239300014;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7402376;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239375098;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10045449;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239417167;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12593265;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239725123;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12619647;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239727756;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10502483;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239705561;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13288121;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239800963;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10156500;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239797131;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13668960;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239839721;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13671723;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239840019;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7761813;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239850811;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2741792;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239226081;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13357000;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239807602;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12894915;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239759910;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12959553;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239764161;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11353767;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239588508;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10910760;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532784;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8535132;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239368451;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3805255;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239274148;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10818251;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239519857;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12021857;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239661217;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11549521;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239607663;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11623438;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239615862;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13349287;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239807408;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11777591;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239634461;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2789175;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239590787;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12763675;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239744061;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14058294;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239879937;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11459166;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239598116;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13226444;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239795051;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13424688;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239814322;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12297402;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239692370;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13459996;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239819380;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8216762;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239687261;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7886667;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239020663;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7823533;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532722;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10520503;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239480761;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10648267;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239785476;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11218940;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239569578;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13026860;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239772936;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13444735;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239819697;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10516298;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239505539;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13044052;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239777388;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12212105;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239689180;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12323365;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239699436;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12814571;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239794677;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13141465;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239786209;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13773208;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239849608;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14149192;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239888905;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14186276;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239891524;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11589345;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239893173;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3691152;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239266581;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12333093;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239696225;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13458272;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239820111;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12958352;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239767570;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13384597;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239811635;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13488945;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239821346;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13978411;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239872454;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14089610;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239883030;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12427616;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239706643;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12471828;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239711218;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12505218;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239714923;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12358525;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239698730;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13999184;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239874404;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12271144;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239689589;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11193832;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239567035;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11196734;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239568110;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11137355;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239562447;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6003680;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239603773;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11488239;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239600178;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11528117;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239613161;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6699227;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239481660;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10333320;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239455952;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12131873;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239674003;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11540230;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239606107;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11740086;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239628853;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12018775;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239685200;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12578665;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239723348;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12260207;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239688297;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11147962;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239561272;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13063154;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239776126;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13129953;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239813471;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14193280;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239892099;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14250527;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239896768;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13443194;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239816532;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11078880;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239560455;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6416683;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239128695;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13923420;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239866475;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12064629;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239671243;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14063190;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239880271;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6797890;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239168355;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10335005;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239456283;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12985520;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239767709;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4030958;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239778012;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12806030;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239748733;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12816558;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239750019;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11050993;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239742201;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11993731;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239658279;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13657550;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239838394;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13643533;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239841093;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14004011;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239874608;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13897217;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239863016;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13086375;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239895004;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8155232;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239049856;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1862626;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239297127;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12554227;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239720620;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13975285;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239870839;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14127733;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239886594;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13658190;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239838489;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13134221;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239784247;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13409638;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239813998;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10892850;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239529509;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10943013;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239537070;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10249575;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239594660;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11943467;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239652076;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11648929;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239618574;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12209686;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239682309;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12217603;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239682821;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12271411;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239688566;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12955710;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239785204;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13568817;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239829428;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12714097;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239738508;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13150740;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239787122;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14187604;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239891723;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12186570;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239679465;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14268299;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239899030;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13405233;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239814081;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11587229;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239612850;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11606096;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239613665;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2690080;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239674775;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12292699;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239691718;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11499320;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239620592;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11709235;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239625408;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13438905;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239817226;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12326453;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239694615;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12893072;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239758142;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13266730;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239798710;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11047976;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239552923;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13089374;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239778704;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11729180;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239628453;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10512268;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239480144;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10029923;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239414739;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2260964;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239448955;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3761770;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239300819;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12617490;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239728964;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8035113;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239774442;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13048538;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239774541;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12707473;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239737780;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11943076;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239652586;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12800775;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239748176;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12171689;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239678478;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12875775;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239757716;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11901993;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239647242;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11839805;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239641305;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12122599;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239672255;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13485270;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239823510;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13313061;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239802985;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13317733;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239804046;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13428578;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239814887;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13125788;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239783389;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13371959;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239808990;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13587080;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239832700;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13635670;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239836403;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10123814;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239878206;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13783688;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239851228;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13860860;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239863839;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14315637;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239902476;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7500564;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239004306;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9005919;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239296253;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12643432;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239731282;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10097953;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239786041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13892649;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239864146;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14081148;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239880835;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12297011;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239692352;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13527614;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239825599;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14207540;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239893362;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7984090;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239754279;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13830716;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239855854;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13841254;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239856971;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13451979;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239817611;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12884030;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239890331;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13095625;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239779389;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13122380;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239782780;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11363606;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239587035;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11378646;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239588166;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3609952;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239006168;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9365575;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239328118;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10289003;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239450041;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10918175;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239534655;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9476016;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239592636;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12055522;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239664778;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12200999;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239681930;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12204862;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239682050;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12943762;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239762804;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10415050;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239631298;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13724568;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239849916;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6973779;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239627242;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13815768;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239855583;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13168339;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239787469;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11119616;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239558748;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3585026;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239612741;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12530930;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239717915;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13427881;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239815904;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2074230;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239004046;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11010380;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239545170;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2404125;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239426683;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9991336;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239409359;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13125184;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239807393;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1846183;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239674521;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10462970;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239472702;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10826068;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239520813;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12802000;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239748292;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12805505;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239748707;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12661414;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239749894;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12229890;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239685273;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10715886;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239671434;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13310488;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239802626;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13121561;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239782592;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13393170;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239812610;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13607308;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239834896;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10949097;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239849183;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7972792;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239851719;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13827650;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239855730;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14303159;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239901261;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2723492;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239049086;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6287921;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239108257;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11941910;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239737876;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12215163;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239687942;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12716715;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239738818;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13489682;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239821368;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7489587;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239876620;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13114832;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239866889;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14036924;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239877621;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9430318;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239751385;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13705482;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239844539;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13457497;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239818379;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7320329;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239565711;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11247142;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239572940;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11731966;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239627852;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11562048;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239609789;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7413378;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239614785;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7109113;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239002912;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3905640;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239413971;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12218944;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239907920;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13907662;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239864632;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12799580;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239748895;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10480013;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239474850;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9163085;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239295919;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11872799;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239644875;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11976268;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239655689;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13274120;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239807486;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13397460;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239811988;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13768310;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239848978;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11362120;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239586345;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13027875;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239772239;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13528947;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239829241;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13824171;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239854577;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12714518;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239740920;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12733059;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239743985;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11913584;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239689113;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2162776;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239679301;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7788673;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239747439;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14283905;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239899801;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13482556;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239822469;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13599305;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239832941;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13631241;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239838801;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8360936;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239134723;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2623900;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239204009;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8958033;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239448207;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80211607;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239361442;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10598626;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239495975;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9230041;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239372501;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12825867;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239750949;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12480649;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239712470;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12669202;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239733354;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13461664;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239818762;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13121383;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239787927;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13352172;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239807208;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13687336;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239867713;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9467866;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239344716;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2236230;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239306153;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8314764;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239183992;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14005670;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239874664;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9505431;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239794962;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13479318;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239821130;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13501151;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239822427;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14232480;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239896023;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10293396;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239858083;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3966046;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239569015;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10008950;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239512565;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10700978;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239504737;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2127458;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239379113;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11207116;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239569165;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11998008;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239658251;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13065831;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239789204;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13305395;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239803047;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13644041;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239836881;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12953830;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239766475;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13076000;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239777689;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13138634;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239785312;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13529463;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239860985;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13163450;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239786994;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13931407;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239867352;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14188309;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239891777;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14027470;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239895677;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12311995;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239693164;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13394150;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239811596;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11353341;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239585324;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7769628;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239146393;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10918299;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532943;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10621873;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239495009;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11134461;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239559606;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7916558;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239403849;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 955116;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265046710;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1005430;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265051261;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 228850;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265009471;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 761117;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265054551;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1048651;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265055504;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1016482;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265052461;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 969630;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265048099;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 821349;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265033496;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1042157;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265054790;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 158216;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563318008171;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 198110;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563318015479;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 198510;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563318011456;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 68799;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416007517;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 361372;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416025016;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 400157;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416027783;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 299596;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416021502;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 371807;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416025602;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 371220;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416028482;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 406678;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416028383;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 783749;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420066996;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 983667;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420089626;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 881570;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420080088;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 695181;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420086473;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 963380;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420087176;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 975605;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420088842;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 522384;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420044010;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 675750;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420055257;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 767727;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420065077;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 636908;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420065117;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 986780;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420090013;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 943584;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420085170;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 708267;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420065876;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 785954;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420067229;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 915254;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420081863;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 706620;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420063564;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 792365;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420068101;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 217190;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420083181;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1008951;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420093114;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 2599570;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420072581;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 746436;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420062867;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 973173;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420089143;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 90697;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420058269;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 924636;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420094330;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 914762;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420081852;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 804339;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420084428;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 442887;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420043162;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1010077;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420094279;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 897051;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420080427;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 482889;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420039508;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 81930;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420006526;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 975591;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420088677;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 938688;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420084614;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 675148;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420092785;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 741965;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420062187;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 603970;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420089240;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 865257;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420075592;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 941999;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420084979;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 979643;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420092689;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1011529;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420093493;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 790141;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420080375;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1018035;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420094309;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 448265;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420063983;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 978132;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420088882;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 377031;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420029462;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 107514;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420088736;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1015109;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420093896;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 959502;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420086965;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 514136;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420081219;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 891886;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438074127;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 777412;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438062717;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 751073;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438059534;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 607061;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438048023;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 720356;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438057276;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14204827;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438077435;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 769096;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438061435;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 667897;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438071141;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 673056;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438065710;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 782130;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438063352;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 607010;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438044350;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 791938;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438064129;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 905550;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438076674;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 916978;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438078702;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 543047;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438062337;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 887463;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438073250;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14066963;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438075832;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14085143;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438076032;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 904104;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438076641;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 380890;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438019791;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 835471;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438074469;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 904015;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438076362;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 908002;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438077024;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14056780;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438075645;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14346427;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438079195;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 731218;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438076768;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 767840;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438072109;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 58696;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438056429;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 838136;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438068661;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 380920;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438019794;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 564125;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438051850;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 570915;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438077513;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 642576;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438047641;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 350052;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438017799;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14311550;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438078834;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 116408;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443008063;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 54330;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443001390;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 116432;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443005866;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 394327;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444029298;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 136557;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444007496;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 422088;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444031727;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 195251;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444014485;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 121916;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444005128;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 402257;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444032079;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 178683;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449013155;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 49280;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449001363;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 139033;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449008829;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 186511;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449014026;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 282332;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457018030;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 366331;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457025842;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 338494;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457023028;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 511633;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457038533;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 635910;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457051146;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 571806;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457044814;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 209520;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468018450;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 356646;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468032245;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 14247054;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468034005;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 158160;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468012948;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 142735;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468011374;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 205923;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468017762;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 229407;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468019874;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 214965;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468018698;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 327875;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468029989;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 219126;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468018792;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 86886;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468009611;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 213250;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468018294;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 322652;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468029140;


  vr_qtdtotalregistros := 0;
  vr_qtdregistrosok    := 0;
  vr_qtdregistorserror := 0;

  FOR x IN NVL(v_dados.first(), 1) .. nvl(v_dados.last(), 0) LOOP
  
    vr_qtdtotalregistros := vr_qtdtotalregistros + 1;
  
    UPDATE cecred.tbcrd_cessao_credito cess
       SET cess.dtvencto = trunc(to_date('22/03/2022', 'dd/mm/yyyy'))
     WHERE cess.cdcooper = v_dados(x).vr_cdcooper
       AND cess.nrdconta = v_dados(x).vr_nrdconta
       AND cess.nrconta_cartao = v_dados(x).vr_nrconta_cartao
       AND trunc(cess.dtvencto) = trunc(to_date('22/06/2022', 'dd/mm/yyyy'));
  
    IF SQL%ROWCOUNT = 1 THEN
      vr_qtdregistrosok := vr_qtdregistrosok + 1;
    ELSE
      vr_desclog := 'vr_nrdconta = ' || v_dados(x).vr_nrdconta || ', vr_nrconta_cartao = ' || v_dados(x).vr_nrconta_cartao ||
                    '. Quantidade de Registros Alterados: ' || SQL%ROWCOUNT;
    
      INSERT INTO cecred.tbgen_erro_sistema
        (cdcooper
        ,dherro
        ,dserro
        ,nrsqlcode)
      VALUES
        (1
        ,SYSDATE
        ,vr_desclog
        ,NULL);
    
      vr_qtdregistorserror := vr_qtdregistorserror + 1;
    END IF;
  
  END LOOP;

  vr_descqtdregistros := 'Quantidades de Registros: vr_qtdtotalregistros = ' ||
                         vr_qtdtotalregistros || ', vr_qtdregistrosok = ' || vr_qtdregistrosok ||
                         ', vr_qtdregistorserror = ' || vr_qtdregistorserror || '.';

  IF vr_qtdtotalregistros = 574 and vr_qtdregistrosok = 574 and vr_qtdregistorserror = 0 THEN
    COMMIT;
  
    vr_desclog := vr_descqtdregistros || ' Commit. Ok.';
  
    INSERT INTO cecred.tbgen_erro_sistema
      (cdcooper
      ,dherro
      ,dserro
      ,nrsqlcode)
    VALUES
      (1
      ,SYSDATE
      ,vr_desclog
      ,NULL);
  ELSE
    RAISE_application_error(-20500,
                            'Não foram atualizados o número correto de registros. ' ||
                            vr_descqtdregistros);
  END IF;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
  
    vr_desclog := SQLCODE || SQLERRM || ' Rollback. Error.';
  
    INSERT INTO cecred.tbgen_erro_sistema
      (cdcooper
      ,dherro
      ,dserro
      ,nrsqlcode)
    VALUES
      (1
      ,SYSDATE
      ,vr_desclog
      ,NULL);
  
    COMMIT;
  
END;
