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
    v_dados(v_dados.last()).vr_nrdconta := 253715;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563232019223;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 6;
    v_dados(v_dados.last()).vr_nrdconta := 186198;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563232013884;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10782222;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239515078;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12653284;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239732678;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12986909;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239771684;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13387561;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239812239;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14175169;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239890378;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12416371;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239704321;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13281330;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239798877;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11890720;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239646605;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11894210;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239646267;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12219169;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239683903;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11724315;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239627029;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13297392;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239800897;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12148482;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239676405;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12271730;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239699407;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12867551;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239755643;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13663119;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239839148;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9320504;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239746422;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11514957;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239776011;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3996743;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239021461;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6341403;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239284173;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7333188;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239039632;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7714521;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239093189;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7694725;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239315621;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6622410;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239324114;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9833900;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239389567;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11887915;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239646700;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13646508;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239839841;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13200925;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239793293;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10297570;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239769006;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11046295;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239549972;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9627162;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239860344;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12151122;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239675774;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3760553;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239746819;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12888206;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239757753;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13359789;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239809887;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10776133;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239515418;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10914064;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532379;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13064215;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239777416;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13731343;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239845823;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12742597;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239741650;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12926370;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239761088;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11431970;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239594141;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11674946;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239621380;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11184361;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239565732;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13451383;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239818252;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11062983;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239607881;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11669179;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239621727;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8655260;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239739577;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2081830;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239040470;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4054423;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239184191;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2822709;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239126713;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8524572;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239194938;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2877171;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239290280;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8673446;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239237722;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12743321;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239741718;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12110035;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239671534;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13231600;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239796949;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11764651;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239631762;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13675753;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239843543;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12748722;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239743450;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3625826;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239635918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13269348;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239797409;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13454730;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239819487;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13909860;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239864969;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13157795;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239798706;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11150912;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239856148;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11073519;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239617959;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12067547;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239666017;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9933492;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239400933;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10114424;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239426940;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10633103;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239495183;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13723839;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239845722;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12285633;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239690231;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12596310;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239725434;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13328670;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239805918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10800026;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239517867;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6659195;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239852631;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3659208;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239867616;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12090778;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239669593;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13050923;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239774739;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11349476;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239585825;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12962660;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239764416;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12385476;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239702024;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10863583;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239526509;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10868895;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239526960;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10030638;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239632021;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12137707;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239674880;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12863637;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239756853;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11534621;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239605978;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2803399;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239415516;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10387854;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239463233;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10343199;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239458157;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9754237;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239381849;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9787194;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239386098;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10417346;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239467138;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2899639;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239398847;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2396785;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239146952;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14177846;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239890582;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14097311;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239892226;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13849492;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239886784;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14010720;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239875230;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3035387;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239022656;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6634192;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239016464;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9968598;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239405987;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10317430;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239453768;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13371134;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239808857;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11336080;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239583644;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11966637;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239654947;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12943940;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239762842;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11120819;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239558233;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13068555;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239776784;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12234613;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239684678;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13442619;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239816456;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2692651;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239043918;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6243177;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239359374;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8864012;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239254052;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10445420;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239470202;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9778012;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239478737;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 772828;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239414767;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9785310;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239385857;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2982773;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239123110;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7501200;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239053304;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10915400;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532554;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11048239;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239552425;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13371452;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239808965;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6220266;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239588179;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12824496;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239809905;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11956577;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239722088;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11322586;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239581812;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14195275;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239892231;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10876065;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239527289;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13170813;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239787795;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13764306;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239847164;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11393084;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239593323;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13765795;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239848879;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12062430;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239665711;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14073226;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239882207;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13341316;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239807777;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 837490;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239650521;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14068389;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239880742;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12705616;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239738468;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12053732;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239667782;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14104954;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239883986;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13661949;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239839001;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13800400;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239855533;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8726701;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239541851;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8566666;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239197648;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8744122;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239227949;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10380922;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239462275;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12322180;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239694492;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12948160;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239763213;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11570008;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239612559;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11730269;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239627674;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11365951;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239586822;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11571179;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239610484;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11184019;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239565636;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11254378;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239573982;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12280712;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239690839;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12342955;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239698723;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12791822;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239747560;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11259841;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239574495;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12840076;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239752481;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14137321;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239887042;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9871616;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239393352;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10508740;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239484515;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10292080;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239451031;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6810381;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239469152;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14081717;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239882530;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14082322;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239882567;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14144409;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239888086;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12931659;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239761742;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13372041;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239814057;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11490659;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239600536;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13722832;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239846295;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13744739;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239846880;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11484829;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239600984;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12338850;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239776726;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12063100;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239665633;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12846767;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239753204;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13325078;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239803764;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11139110;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239560403;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12154512;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239676566;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12458643;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239709956;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8592543;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239212491;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10370820;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239460575;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8961646;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239305920;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7088302;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239090959;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7656408;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239186227;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2510430;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239038697;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8294860;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239431200;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9494898;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239347255;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10305246;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239452369;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13661698;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239839407;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3870847;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239712813;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13717677;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239843398;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14026813;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239875464;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13270800;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239797557;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13600702;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239844389;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13682261;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239840885;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12619841;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239727764;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13745352;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239846927;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10664327;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239499525;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11490241;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239622372;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8416575;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239682201;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12721522;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239739324;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10522794;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239744473;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10827013;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239520972;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11570415;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239609500;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11042192;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239549982;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12821594;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239750526;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11900342;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239649441;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12136590;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239674207;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11062681;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239551221;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11477644;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239599037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12570028;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239723836;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10925430;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239882868;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10081879;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239422097;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7437358;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239404576;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6970788;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239437865;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6699243;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239117843;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12759961;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239885207;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14117940;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239885081;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14029219;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239877072;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14046130;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239878460;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14231964;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239895360;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14222477;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239894329;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 923478;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239037411;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10410619;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239465720;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7947143;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239482200;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10301453;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239689827;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12791741;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239747037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13220861;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239794228;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14142155;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239887398;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11946172;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239652424;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13525263;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239824218;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12810525;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239749286;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13881213;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239861380;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14010399;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239875638;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13999885;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239876707;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14214687;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239893724;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11486910;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239600075;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11556935;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239609754;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12119423;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239673489;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12602604;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239726083;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2133113;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239528806;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7191936;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239708073;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12760463;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239743677;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12081892;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239667749;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13653156;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239838033;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11915358;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239650089;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11229373;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239570869;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13076400;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239779977;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13422790;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239814132;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9796142;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239819206;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9915354;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239467355;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11191074;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239596516;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10538259;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239504098;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13401483;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239832870;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9531777;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239521574;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9046593;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239589149;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13198963;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239790602;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12884189;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239757291;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12384917;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239701504;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11577134;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239611029;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11717165;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239626267;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12264750;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239689871;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13195050;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239791314;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13206800;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239791363;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10424083;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239845253;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12283517;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239703119;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12710385;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239738086;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11056703;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239857162;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12922145;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239761548;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10269347;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239583724;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12431222;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239706093;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13384503;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239811291;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4000641;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239147735;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9164910;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239296037;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8332630;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239057857;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7437137;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239011010;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10030921;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239417471;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8344264;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239424402;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8565244;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239201703;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13004891;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239769642;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13664158;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239839930;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11612835;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239614436;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13010344;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239770284;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13232959;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239793578;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13359207;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239809596;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13741519;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239858199;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10786813;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239516282;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11778636;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239633408;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13390228;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239812401;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11961260;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239654174;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12815462;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239749773;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13234269;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239793742;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10095365;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239424188;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3733211;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239664198;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13419951;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239815869;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12475483;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239711544;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13113038;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239781481;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13885286;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239861590;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13326155;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239805445;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9709800;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239376084;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8683883;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239657953;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13227416;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239795349;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13634011;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239835279;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10999566;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239543461;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8418730;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239638414;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12380210;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239701321;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10237283;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239618531;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11022078;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239547658;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11826630;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239639263;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11667290;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239623472;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12963739;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239764552;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9852719;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239410030;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10379924;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239461609;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8389667;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239432975;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14226596;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239894866;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14139090;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239887626;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2097567;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239052713;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8062110;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239039971;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2384388;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239018494;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8831289;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239246649;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6178120;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239301329;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7765339;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239034985;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6828973;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239303222;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8248982;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239047800;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3998924;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239361480;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8873828;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239255733;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2715368;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239355116;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2221888;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239004507;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2260182;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239203396;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9123202;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239224247;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6092;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239707321;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6988792;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239595977;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13119516;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239784244;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10705511;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239792798;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13649361;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239837532;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12117153;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239671610;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13096869;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239779540;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13085220;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239779715;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13260189;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239796478;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13757814;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239848646;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13463390;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239820143;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13424440;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239814285;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14000792;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239874136;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11868309;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239643721;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13823426;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239855665;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12567400;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239722242;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2362392;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239119985;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7581556;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239282437;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4063260;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239319866;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6341209;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239283777;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3906914;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239012530;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9053018;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239294347;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8164630;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239112107;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9279164;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239314391;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9589295;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239360267;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7976046;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239355878;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10945016;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239536377;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11989653;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239683695;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12323357;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239695390;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12971502;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239767881;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12481092;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239712681;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11537205;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239616758;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12547158;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239719803;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12849200;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239753501;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13573098;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239831276;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12112127;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239671563;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12644749;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239730408;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10234942;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239443046;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13800817;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239855535;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 90162676;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239808962;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13012100;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239770467;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11803126;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239636136;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12855537;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239771222;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13155601;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239786192;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10184813;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239833944;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12015059;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239664335;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12821276;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239758435;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10911332;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532520;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13081438;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239777645;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13208691;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239791507;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7419953;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239477331;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10520830;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239571026;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13634070;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239835197;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12336491;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239715321;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11093870;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239554812;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8234639;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239624734;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11998822;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239658488;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13355384;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239811204;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11213809;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239573876;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12053643;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239664552;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3926915;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239483285;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7661959;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239432603;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8101272;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239153515;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14191253;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239892093;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14197472;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239892514;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14149613;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239889408;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13922653;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239878607;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11030909;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239891808;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13211285;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239888733;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9314296;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239328400;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 909939;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239055660;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8531048;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239145035;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9414355;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239335439;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8088950;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239308289;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8578796;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239491704;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9921940;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239399380;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9981039;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239417108;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9126201;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239750415;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13351516;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239807116;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12718840;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239739048;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12212393;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239682149;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7284683;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239831118;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13748483;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239847619;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10810773;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239519139;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12716057;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239738933;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12718408;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239739543;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11313722;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239580961;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12478768;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239711975;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11022469;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239547161;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10798730;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239517180;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10910140;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532255;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10301283;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239593734;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6574688;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239358231;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9531726;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239352528;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12746355;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239742080;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80428576;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239222342;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8924210;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239264438;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9412492;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239335334;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8347069;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239367137;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7977751;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239179400;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8990433;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239281362;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13303023;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239801742;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13688278;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239842506;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12638617;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239729654;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10546081;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239488232;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12982482;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239768471;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10045562;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239416920;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9404589;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239468860;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10703004;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239504715;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11563559;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239608628;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12709816;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239756132;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12941271;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239798466;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6802877;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239470531;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11878061;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239644692;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9994661;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239653713;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13104071;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239780912;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3156133;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239664190;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13204556;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239791186;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13968505;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239871217;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9553789;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239804997;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13711938;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239845391;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11496126;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239689839;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12230227;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239684072;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13068008;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239778318;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13683691;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239841021;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10518002;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239480067;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13350374;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239806979;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8804478;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239622339;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12079960;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239669518;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11924047;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239650273;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11574135;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239609979;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11653809;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239619076;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 80109322;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239663117;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2461749;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239372021;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7664877;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239001147;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2546272;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239023450;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7821107;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239267987;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7654340;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239052831;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2970066;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239215292;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6419119;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239059952;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3998568;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239177624;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9181598;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239298584;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9239391;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239308092;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9504974;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239348544;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8485119;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239163313;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8980705;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239274080;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9981080;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239407856;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9599576;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239361433;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9228594;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239306383;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3818632;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239019382;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9914145;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239398659;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2558831;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239237005;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9985522;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239412841;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3972895;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239140544;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2596962;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239110302;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6350836;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239203044;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11178485;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239565765;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11411970;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239591920;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11712317;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239625703;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13252615;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239800098;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10713204;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239548988;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2517868;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239742917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11629126;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239708132;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13791575;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239852200;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12725382;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239743733;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13464337;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239819093;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13615939;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239836797;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14109000;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239884888;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8127735;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239642888;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7541538;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239516663;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13881680;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239861398;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11790628;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239635054;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3801993;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239682833;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11119810;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239557904;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12927333;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239763458;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13674420;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239865290;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12337633;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239695687;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11136634;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239560589;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13945092;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239868834;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13078623;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239780532;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3627993;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239133234;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2121646;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239101491;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11182121;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239565245;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12403229;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239703411;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6461492;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239703917;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12496162;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239713951;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11058390;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239550971;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11995238;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239657908;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13618903;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239833890;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12184772;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239702369;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12315362;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239702557;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12793450;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239747267;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13116312;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239781774;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13383647;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239810540;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11508914;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239602425;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11445173;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239595779;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12435180;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239707151;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11803231;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239636207;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9631704;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239517228;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3918424;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239649086;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13512862;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239822926;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12087300;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239668349;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12290009;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239691626;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9737081;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239380828;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9964509;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239459979;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8679096;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239556662;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12522899;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239717536;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13802135;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239853026;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11665459;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239620443;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7265182;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239740303;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12776149;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239745395;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10911855;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532266;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9779337;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239518470;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11792850;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239638581;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3522849;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239409559;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6454429;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239477981;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10236600;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239443205;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6421288;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239490749;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10453253;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239471356;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10419055;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239467480;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14161214;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239889335;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14123312;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239886095;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7314930;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239036806;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10971157;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239902463;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8101582;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239486423;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6592228;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239104967;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8658331;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239881944;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3979636;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239049772;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8761698;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239320771;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3548295;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239425122;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7770448;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239349256;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9587195;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239359955;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10477969;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239474753;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14185741;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239891437;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13582003;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239842900;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10984291;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239645387;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11968125;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239654750;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12681717;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239734586;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12466778;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239715259;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12497142;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239715755;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9504605;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239610482;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14233762;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239895708;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8428026;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239626561;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11052481;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239550000;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13062590;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239778575;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13800485;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239852378;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13931644;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239867967;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12612936;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239767970;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14106400;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239884516;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2200740;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239227132;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9032673;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239282991;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8674612;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239213487;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8746346;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239228448;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3648435;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239127506;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8922896;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239264358;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9422420;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239340045;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7419457;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239159276;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9062270;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239288162;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9229639;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239306652;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9414371;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239335684;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11440988;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239595813;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12117250;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239671626;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12345920;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239696491;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13850660;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239859639;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13853945;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239859658;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13280694;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239798834;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13430823;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239815095;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8140480;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239419994;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10063714;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239420083;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13534378;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239826556;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13480294;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239820513;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12314633;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239700692;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12265713;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239687884;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13294164;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239821250;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13081543;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239777652;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13287516;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239799744;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4066634;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239376227;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6360939;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239774210;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12291056;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239690699;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13347071;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239806504;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13485849;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239822520;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13935216;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239867500;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13989006;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239872824;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11320745;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239584871;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12610917;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239727694;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13804006;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239852523;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13994832;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239873526;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11203382;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239568224;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11724498;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239627062;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11501898;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239601639;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11566639;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239609362;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10914510;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239532432;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12989169;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239768130;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11568267;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239609224;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12662194;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239732617;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11974478;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239655557;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6017;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239540885;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11145838;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239561075;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12942510;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239762673;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11474513;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239599165;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 2289253;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239453030;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9991301;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239410090;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10504591;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239478231;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3933288;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239478343;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6037186;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239381339;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8409293;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239095721;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8446326;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239141190;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14094576;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239883289;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13922327;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239891302;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 14228947;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239897345;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 3753247;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239024678;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7034008;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239066666;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7827202;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239011791;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10444734;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239470126;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 756067;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239143145;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10459022;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239472404;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9528466;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239420030;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6927408;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239011030;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 7117086;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239196601;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1936107;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239358586;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 8748926;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239228870;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9624619;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239366573;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6282229;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239061825;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 4031687;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239148179;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 1254120;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239226044;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12111600;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239671291;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13622293;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239853664;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10393617;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239464057;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10812814;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239520424;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13266640;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239799198;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12643823;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239730268;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13126601;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239784830;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10596925;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239490457;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12020362;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239661831;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13597922;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239832719;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13623265;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239839024;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13711180;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239844206;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9445951;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239833456;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 6790038;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239023298;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10025774;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239414210;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 9034803;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239283334;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10592172;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239489859;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13512790;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239822936;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 12282936;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239690135;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 13680234;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239840751;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 11674482;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239622726;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 1;
    v_dados(v_dados.last()).vr_nrdconta := 10317660;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563239809737;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 991767;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265050743;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 713279;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265023747;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1057383;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265056228;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1123408;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265062633;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 742490;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265025636;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 942979;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265045507;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 974366;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265048683;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 997706;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265050983;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 846570;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265035842;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1025643;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265053109;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1043030;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265054861;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 994944;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265050629;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 1110020;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265061405;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 877603;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265039053;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 926817;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265043646;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 999601;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265051127;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 644110;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265016901;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 869031;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265038320;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 759520;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265027356;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 894451;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265040504;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 2;
    v_dados(v_dados.last()).vr_nrdconta := 935514;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563265046087;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 159298;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563318009506;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 5;
    v_dados(v_dados.last()).vr_nrdconta := 244821;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7563318015804;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 243728;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416003284;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 350222;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416024334;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 384011;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416026665;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 243884;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416003296;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 365718;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416025240;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 382698;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416026534;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 383805;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416026533;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 392278;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416027136;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 400602;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416028169;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 7;
    v_dados(v_dados.last()).vr_nrdconta := 372773;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564416025688;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 790893;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420067908;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 875805;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420084991;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 205222;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420008954;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 963488;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420087188;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 200026;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420084173;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 659517;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420053612;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 734187;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420061382;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 177440;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420007312;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 274526;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420057421;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 972479;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420090623;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1009710;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420093024;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1024655;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420095017;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 41904;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420081986;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1003534;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420092283;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 839396;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420073294;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 664944;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420080550;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 252450;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420020548;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 291595;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420049578;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 879940;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420080058;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 907286;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420081727;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 599441;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420052204;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 903159;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420089652;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 484806;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420038355;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 780170;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420071787;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 675423;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420055332;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 572527;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420057315;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 994677;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420091120;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 687294;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420056393;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 706477;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420074648;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 994529;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420091387;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 303640;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420022894;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 758345;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420064086;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1020919;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420094585;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 3909999;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420001006;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 789135;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420067552;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 596078;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420058875;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 906905;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420005779;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 439150;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420047723;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 787752;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420067357;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 778168;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420068040;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 995223;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420091208;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 440000;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420063632;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1006096;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420092647;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 931063;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420083711;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 618519;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420077858;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 640395;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420059926;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 6608663;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420040729;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1024124;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420094946;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 945544;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420022648;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 803103;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420069306;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 834661;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420087956;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 899801;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420079859;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 838578;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420072986;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 211818;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420009143;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 951986;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420086109;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 6596428;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420082032;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 418765;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420061767;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 834165;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420072718;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 255270;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420017757;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 931322;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420084960;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 386049;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420030931;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1006363;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420092710;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 792497;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420067957;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 940500;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420084826;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 624845;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420050168;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 435481;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420082031;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 940283;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420085133;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 684341;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420056074;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1002791;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420092129;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1003364;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420092202;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 722499;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420060123;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 951919;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420086067;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 343170;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420026520;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 941131;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420084894;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1021745;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420094615;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 828858;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420072287;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 946338;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420090547;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 26115;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420033585;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 9229;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420010084;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1007700;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420092964;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 865001;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420078553;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 3075613;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420029978;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 727156;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420060654;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 688096;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420056429;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 555975;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420043452;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 988820;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420090234;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 56782;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420011129;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 925594;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420083177;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 937436;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420084593;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 670936;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420054925;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 693766;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420069667;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 834742;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420073753;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 2798018;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420016038;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 332798;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420075532;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 912204;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420081632;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 394564;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420086605;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 769789;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420067182;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 852686;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420074664;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 769428;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420066167;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 574830;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420050235;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 404551;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420072264;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 389730;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420030405;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 501352;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420041873;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 283428;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420020906;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 825905;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420072027;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 922455;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420082653;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 797375;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420074869;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 705802;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420058260;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 948926;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420093632;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 863165;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420076123;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 1022180;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420094753;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 3678695;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420004019;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 557161;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420053753;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 891460;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420079076;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 868167;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420076337;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 702056;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420060475;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 842362;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420094793;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 755362;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420082722;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 760889;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420064267;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 2155184;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420044254;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 438600;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420065990;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 16;
    v_dados(v_dados.last()).vr_nrdconta := 607886;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564420050769;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 42650;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564435002921;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 8;
    v_dados(v_dados.last()).vr_nrdconta := 58831;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564435004482;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 617806;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438046109;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 752959;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438060712;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14078473;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438075981;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 783617;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438077589;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 152536;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438005448;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14224267;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438078427;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 844721;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438070524;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 909912;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438077595;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 591629;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438042834;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 873357;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438071585;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 494844;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438033044;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 210161;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438006094;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 516520;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438034735;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 227250;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438006947;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 840351;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438068516;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 848379;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438069260;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 733733;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438072107;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 587281;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438042530;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 653080;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438060646;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 424315;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438067610;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 905267;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438076502;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 891452;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438074708;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 567361;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438041915;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 531537;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438038437;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 827916;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438067693;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 349704;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438016204;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 508136;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438033825;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 690813;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438060084;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 810690;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438078421;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 806285;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438065203;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 876810;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438072136;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 536296;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438037426;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 886220;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438073406;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 753173;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438059812;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 905364;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438076501;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 875163;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438071825;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 770132;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438062105;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 1250027;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438009271;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 499889;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438032871;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 689750;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438053197;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 800171;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438072378;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 375454;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438019244;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14228343;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438078224;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 739707;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438058645;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 768677;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438062140;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 14129191;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438076466;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 229822;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438013207;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 242489;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438059750;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 546437;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438038132;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 11;
    v_dados(v_dados.last()).vr_nrdconta := 169099;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564438026785;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 145890;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443009488;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 25194;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443001157;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 211524;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443015964;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 190799;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443014016;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 139416;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443008891;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 178195;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443012818;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 10;
    v_dados(v_dados.last()).vr_nrdconta := 204250;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564443015240;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 385620;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444029071;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 181897;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444017031;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 332356;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444023630;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 305464;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444032899;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 458180;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444034679;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 392260;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444029174;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 423505;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444031725;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 293903;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444022278;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 9;
    v_dados(v_dados.last()).vr_nrdconta := 314390;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564444022440;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 136603;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449008502;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 180505;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449013356;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 142980;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449009305;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 171301;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449012424;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 188247;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449014274;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 12;
    v_dados(v_dados.last()).vr_nrdconta := 128295;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564449007552;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 430773;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457030622;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 544280;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457042118;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 145793;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457009515;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 426750;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457030253;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 619299;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457049963;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 538876;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457041521;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 441996;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457031727;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 547352;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457042400;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 548022;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457043617;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 626910;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457050109;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 385441;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457027480;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 424595;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457030027;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 490504;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457036823;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 446017;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457032200;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 732737;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457018903;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 44814;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457024593;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 13;
    v_dados(v_dados.last()).vr_nrdconta := 611786;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564457048510;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 39896;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468002180;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 250112;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468022257;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 344168;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468031163;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 354295;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468032003;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 358886;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468032475;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 349356;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468031539;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 168335;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468013899;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 285455;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468025867;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 239780;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468021282;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 328529;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468029666;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 337269;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468030445;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 258008;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468022876;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 114448;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468008484;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 167282;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468013886;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 255939;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468022360;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 330019;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468029829;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 21164;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468016659;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 217255;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468018650;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 211567;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468018266;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 278858;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468024830;

    v_dados.extend();
    v_dados(v_dados.last()).vr_cdcooper := 14;
    v_dados(v_dados.last()).vr_nrdconta := 244414;
    v_dados(v_dados.last()).vr_nrconta_cartao := 7564468021401;


  vr_qtdtotalregistros := 0;
  vr_qtdregistrosok    := 0;
  vr_qtdregistorserror := 0;

  FOR x IN NVL(v_dados.first(), 1) .. nvl(v_dados.last(), 0) LOOP
  
    vr_qtdtotalregistros := vr_qtdtotalregistros + 1;
  
    UPDATE cecred.tbcrd_cessao_credito cess
       SET cess.dtvencto = trunc(to_date('19/03/2022', 'dd/mm/yyyy'))
     WHERE cess.cdcooper = v_dados(x).vr_cdcooper
       AND cess.nrdconta = v_dados(x).vr_nrdconta
       AND cess.nrconta_cartao = v_dados(x).vr_nrconta_cartao
       AND trunc(cess.dtvencto) = trunc(to_date('19/06/2022', 'dd/mm/yyyy'));
  
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

  IF vr_qtdtotalregistros = 950 and vr_qtdregistrosok = 950 and vr_qtdregistorserror = 0 THEN
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
