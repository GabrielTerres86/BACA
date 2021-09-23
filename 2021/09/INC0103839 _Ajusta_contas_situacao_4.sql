DECLARE
  
  --
  CURSOR cr_crapcot (p_nrdconta   NUMBER
                     , p_cdcooper number) is
    select vldcotas
    from crapcot
    where cdcooper = p_cdcooper
      and nrdconta = p_nrdconta;
  --
  
  vr_dttransa   DATE;
  vr_hrtransa   VARCHAR2(5);
  vr_log_script VARCHAR2(4000);
  vr_vldcotas   NUMBER(25,2);
  vr_dstransa   VARCHAR2(1000);
  vr_capdev_ant NUMBER(15,2);
  vr_dtdemiss_ant DATE;
  vr_dtelimin_ant DATE;
  vr_dtasitct_ant DATE;
  vr_cdmotdem_ant NUMBER(5);
  vr_insere     CHAR(1);
  vr_dtmvtolt   DATE;
  vr_nrdocmto   INTEGER;
  vr_nrseqdig   INTEGER;
  vr_cdcooper   NUMBER(1);
  vr_cdsitdct   NUMBER(1);
  vr_tppessoa   NUMBER(1);
  vr_cdhistor   NUMBER(4);
  vr_cdhistorenc  NUMBER(4);
  vr_cdcritic   NUMBER(5);
  vr_cdagenci   NUMBER(5);
  vr_vllimcre   NUMBER(25,2);
  vr_vlsddisp   NUMBER(25,2);
  vr_dscritic   VARCHAR2(1000);
  
  vr_clob            CLOB;
  vr_clob_line       VARCHAR2(4000);
  vr_clob_line_count NUMBER;
  vr_delimitador     NUMBER;
  vr_nrdconta        NUMBER;
  vr_registros       NUMBER;
  vr_index           NUMBER;
  vr_data_demissao   VARCHAR2(10);
  vr_des_reto        VARCHAR2(3);
  --
  
  rw_crapdat  CECRED.BTCH0001.cr_crapdat%ROWTYPE;
  vr_tab_sald CECRED.EXTR0001.typ_tab_saldos;
  vr_tab_erro CECRED.GENE0001.typ_tab_erro;
  vr_tab_retorno  lanc0001.typ_reg_retorno;
  vr_incrineg     NUMBER;
  vr_rowid        ROWID;
  
  -- Tratamento de erros
  vr_exc_lanc_conta               EXCEPTION;
  vr_exc_sem_registro_bloq        EXCEPTION;
  vr_exc_par_vazio                EXCEPTION;
  vr_exc_sem_data_cooperativa     EXCEPTION;
  vr_exc_associados               EXCEPTION;
  vr_exc_saldo                    EXCEPTION;
  --
BEGIN
  --
  vr_log_script := ' ** Início script' || chr(10);
  --
  
  -- TRANSPORCRED
  vr_cdcooper:=9;
  
  -- Insere log de atualização para a VERLOG. Ex: CADA0003 (6708)
  vr_dttransa := trunc(sysdate);
  vr_hrtransa := gene0002.fn_busca_time;
  
  DBMS_OUTPUT.ENABLE (buffer_size => NULL);
vr_clob := '509558;27/12/2012
507911;01/02/2002
511145;30/11/2011
514217;18/12/2014
516562;16/02/2005
520420;29/11/2012
500038;12/01/2021
517089;06/07/2017
520888;11/11/2014
525642;01/12/2012
528528;22/03/2017
531570;04/06/2021
520918;23/02/2015
510076;29/12/2016
509523;20/10/2016
509396;27/09/2013
528412;30/03/2012
513717;16/12/2015
525103;02/12/2016
519995;23/01/2015
528323;29/12/2016
528447;03/12/2020
515523;27/05/2019
523933;18/11/2012
525944;10/05/2019
515906;13/02/2015
515604;23/03/2016
517631;23/12/2014
533149;18/11/2012
528757;18/11/2020
506583;13/07/2020
530794;02/03/2016
513423;15/04/2016
532410;09/10/2007
519898;17/08/2011
507296;03/07/2015
520047;17/03/2011
507512;05/04/2016
510637;30/11/2011
523488;26/07/2016
528102;07/08/2015
517887;18/11/2012
529303;28/12/2017
531936;02/05/2014
519804;20/05/2004
527238;12/09/2019
524590;29/10/2014
524603;18/10/2013
522104;25/10/2010
516074;07/12/2018
508551;29/12/2016
523089;18/11/2012
516180;03/11/2017
524751;21/12/2017
511129;19/04/2006
503320;17/04/2017
520004;18/11/2012
525391;12/05/2015
532681;18/11/2012
521418;28/05/2015
506877;30/09/2009
508462;31/10/2013
515868;30/11/2015
515477;16/12/2013
530530;02/09/2019
506974;13/02/2015
522805;09/01/2017
532614;18/11/2012
505420;04/06/2021
509264;10/10/2016
512249;11/08/2017
511250;18/11/2012
519782;08/06/2018
530743;03/12/2020
508179;01/12/2001
517925;30/06/2015
528420;08/02/2019
500267;04/06/2021
521981;15/01/2021
509671;11/08/2006
510491;18/11/2012
519910;24/03/2015
509868;19/04/2004
511463;30/11/2011
532517;30/04/2009
510220;24/05/2010
527300;16/03/2017
513547;04/03/2011
529753;10/07/2019
507784;15/10/2002
510912;01/08/2011
514080;04/11/2016
503088;07/06/2021
502340;16/08/2018
502383;16/08/2021
510742;04/07/2017
524891;02/12/2013
528382;04/07/2017
525090;18/11/2012
513652;02/08/2017
526053;14/09/2016
528790;15/10/2019
511366;17/06/2009
508705;21/06/2017
516813;30/12/2015
527602;09/12/2015
524336;10/07/2013
510211;19/04/2006
527181;25/09/2015
533424;04/06/2021
528854;12/05/2021
508284;26/11/2015
509256;27/11/2014
517208;30/03/2012
530999;06/08/2021
526800;17/04/2017
528803;15/07/2019
518662;17/04/2016
522341;31/10/2016
514284;09/11/2015
523372;04/10/2017
525294;17/02/2017
506559;03/07/2020
519332;01/12/2016
531898;21/12/2017
526851;31/10/2011
503142;04/06/2021
515418;30/06/2007
506842;19/01/2009
512036;18/11/2012
510548;30/11/2011
532487;14/09/2009
526320;04/06/2021
529907;29/12/2016
523992;01/08/2011
510408;17/08/2009
512893;18/12/2015
525464;18/11/2012
521892;10/10/2014
523020;18/11/2012
518999;31/07/2012
524344;21/10/2016
518638;07/10/2013
525600;08/05/2014
527270;06/11/2012
510025;22/04/2014
525430;02/04/2014
507482;29/12/2016
526517;06/10/2017
503860;07/08/2020
502855;07/06/2021
518689;07/04/2008
500119;22/02/2017
503177;07/06/2021
532592;18/11/2012
510831;11/04/2012
510173;11/11/2016
510068;21/12/2012
515329;18/11/2012
504670;29/11/2020
518654;20/06/2016
509426;31/12/2009
513261;18/11/2012
521035;01/11/2013
532703;15/10/2015
509574;09/04/2003
532657;30/04/2014
516147;10/12/2014
507024;09/10/2014
530611;18/10/2017
505900;10/05/2017
519260;15/12/2011
504149;18/12/2019
531782;16/05/2016
512613;24/12/2007
503789;03/07/2021
528684;07/07/2020
507130;03/07/2015
511544;17/10/2016
531030;02/10/2017
519715;06/08/2012
507334;30/11/2011
508543;11/05/2016
529516;30/10/2020
527017;26/01/2016
504483;28/02/2019
514276;11/12/2015
516643;31/12/2019
527360;14/03/2017
532240;22/12/2017
514764;19/04/2006
520276;28/11/2013
526924;06/12/2012
507083;30/11/2011
507342;18/11/2012
509051;31/12/2009
514853;27/10/2015
526487;11/12/2012
517283;30/11/2016
517224;21/03/2011
505854;27/12/2019
511390;22/02/2016
526975;03/10/2017
506664;05/07/2021
524255;14/04/2016
511188;13/06/2017
519979;01/10/2015
533580;07/06/2021
508810;26/06/2015
510807;10/10/2016
520950;07/12/2015
520250;14/10/2016
523585;15/10/2015
504815;25/02/2021
527726;06/12/2012
524549;22/12/2015
507148;30/11/2015
509825;08/05/2003
531286;04/06/2021
505307;25/05/2020
520225;17/03/2015
510114;20/10/2014
532940;30/09/2016
520233;18/11/2012
517216;11/12/2013
509701;22/12/2014
509914;30/04/2008
508942;18/11/2012
510386;30/03/2017
508667;28/10/2016
529710;30/01/2021
524387;30/11/2017
511315;15/07/2011
511617;15/10/2013
511889;22/12/2016
515272;18/11/2012
533629;07/06/2021
528358;09/02/2021
509361;31/07/2013
503215;04/06/2021
532126;04/06/2021
514136;18/11/2012
507580;07/05/2008
526932;27/11/2014
518123;31/10/2011
526070;04/10/2019
514365;09/11/2015
524476;26/12/2007
524158;16/04/2013
524832;01/10/2014
524905;18/11/2014
522783;26/06/2015
526541;26/03/2021
507261;08/11/2011
505153;03/11/2020
529265;08/06/2018
517429;27/05/2013
515388;19/04/2007
521922;08/01/2016
508470;13/05/2002
506907;30/11/2011
527459;18/12/2019
506923;29/09/2011
521361;27/10/2020
509540;06/03/2018
508055;16/10/2007
507539;28/01/2016
509108;07/10/2014
510505;12/03/2002
517046;29/12/2014
510513;30/03/2011
506826;31/01/2006
524433;07/12/2016
517143;14/06/2017
506346;28/04/2019
525235;31/08/2012
511340;29/01/2015
521213;30/11/2006
521051;17/02/2007
508454;21/11/2014
508969;20/06/2016
507652;08/01/2016
524115;01/04/2008
512621;29/03/2017
507644;08/04/2016
533114;08/04/2015
523836;07/04/2011
518972;20/07/2016
520560;05/06/2014
521825;08/12/2012
512168;31/10/2016
521280;29/04/2016
523720;10/12/2014
527874;03/12/2014
523500;19/08/2016
524760;30/10/2012
503495;17/04/2017
525863;29/12/2014
515043;28/09/2012
512583;25/07/2016
509728;12/03/2009
532339;15/11/2013
517879;31/12/2009
524620;18/11/2012
519081;18/11/2016
500070;11/11/2019
519022;27/07/2012
508292;11/08/2009
518603;26/12/2011
515817;15/12/2015
508950;11/02/2015
507377;13/06/2017
511919;01/11/2016
511234;05/01/2015
511560;06/09/2016
513016;31/12/2009
509647;15/07/2015
508853;11/12/2015
520748;16/12/2013
518379;04/06/2021
514330;28/03/2016
502871;04/06/2021
507172;03/07/2015
508799;07/04/2017
505161;04/12/2020
516546;22/06/2004
508403;29/02/2016
509205;16/03/2017
511412;11/01/2016
500585;09/02/2021
523321;15/10/2013
525529;29/03/2016
510238;21/02/2002
512990;17/02/2011
528021;23/11/2016
503622;31/05/2021
508985;11/01/2012
504475;24/05/2019
520659;15/10/2015
519170;19/09/2016
533025;26/12/2017
518506;28/12/2012
512320;30/11/2011
528625;02/12/2016
514292;31/07/2001
524379;12/09/2016
524492;18/11/2012
515124;28/12/2015
524727;10/03/2016
511668;30/11/2011
511170;31/07/2001
524034;18/11/2012
515990;14/01/2016
517135;28/05/2019
511765;09/04/2013
525197;19/05/2017
509353;30/08/2016
520802;13/04/2009
511420;08/05/2017
508616;22/11/2016
520160;08/01/2016
525413;18/11/2012
510343;18/04/2016
510823;11/12/2017
530468;04/06/2021
528307;01/03/2016
528030;12/01/2016
509035;25/04/2017
515930;07/12/2016
520080;01/12/2015
518280;26/05/2015
509132;18/01/2017
523950;15/10/2015
509175;03/08/2017
506966;05/08/2015
529346;01/10/2020
510106;10/12/2014
507571;04/07/2017
507938;30/09/2014
510904;21/10/2014
502707;07/06/2021
527700;08/02/2019
520500;24/05/2010
511455;13/11/2017
516279;18/11/2012
512907;31/08/2004
508721;08/07/2016
505501;12/12/2020
513687;03/05/2016
506818;25/09/2008
528498;13/07/2015
532649;17/08/2009
530344;08/07/2016
514322;17/06/2016
527882;04/10/2017
527890;03/05/2012
516295;03/04/2012
514802;28/05/2009
508063;30/04/2011
506958;16/02/2009
508535;23/02/2011
528781;09/01/2020
512850;02/03/2011
525383;29/01/2014
511870;27/02/2004
531693;12/09/2014
512389;04/12/2014
530409;18/12/2018
532983;18/11/2012
503819;21/05/2019
523291;16/11/2015
520039;05/05/2015
511323;31/12/2009
519502;18/11/2012
529770;31/03/2017
503479;30/12/2009
525960;11/12/2014
507636;07/05/2009
507555;19/04/2007
519219;19/12/2014
523780;04/02/2014
532851;14/03/2017
509507;31/12/2009
507989;31/12/2009
507725;19/04/2006
524514;09/10/2013
510556;16/02/2005
517054;18/11/2012
525618;24/02/2012
509612;03/04/2002
511730;31/12/2009
512010;30/04/2001
509086;06/03/2018
510793;11/05/2006
514098;30/11/2011
517038;31/12/2009
521000;27/06/2011
519014;10/10/2016
503916;03/07/2021
525200;20/10/2015
511498;19/04/2007
521353;15/12/2015
510947;22/04/2016
523984;06/04/2017
513822;21/12/2016
510017;26/12/2012
508888;22/05/2009
511587;07/05/2009
519707;27/02/2014
528510;08/01/2015
515361;01/09/2004
522414;20/07/2012
507105;03/07/2015
532290;22/04/2016
530093;27/10/2017
526274;18/11/2012
524840;18/11/2012
519090;11/02/2014
527106;11/01/2016
521698;20/12/2017
512818;01/08/2001
523135;09/08/2013
524280;01/05/2011
508233;03/12/2014
508217;18/11/2012
509442;31/10/2011
510955;24/04/2009
511900;23/03/2016
524697;08/01/2016
509043;24/10/2016
510297;08/10/2015
511838;11/10/2016
518042;20/05/2016
514896;16/02/2012
517488;29/12/2015
532606;28/04/2010
510580;21/12/2009
510858;09/11/2015
509418;05/03/2015
510440;19/04/2007
515515;18/11/2012
511013;23/10/2014
504122;04/11/2019
532380;01/09/2016
521817;27/02/2009
511641;20/10/2016
509140;30/12/2011
532452;18/11/2012
508802;30/11/2011
519251;07/11/2017
522155;30/11/2011
500097;28/03/2019
515035;30/12/2016
507520;07/06/2021
509680;12/08/2004
526134;26/01/2016
508780;20/05/2004
509531;02/01/2017
519057;07/06/2021
527556;22/06/2011
528676;27/03/2019
527009;30/06/2009
508080;18/11/2012
528293;12/11/2014
508683;05/11/2014
526495;15/05/2012
526630;14/10/2015
513938;30/12/2011
526614;03/08/2016
527564;03/11/2015
525456;31/05/2012
523704;08/07/2015
500011;19/10/2016
506753;26/07/2016
526193;30/12/2014
524107;18/11/2012
520705;08/08/2017
512656;15/10/2015
513873;22/09/2014
513636;11/12/2014
508578;21/06/2017
505692;09/06/2021
510130;07/01/2013
508012;31/12/2009
503738;05/02/2021
508748;11/08/2016
512230;19/01/2011
509493;16/12/2015
509639;01/10/2001
531855;10/10/2016
503967;12/01/2021
528935;27/05/2016
521680;15/10/2015
517577;26/12/2013
533262;30/11/2016
521493;10/12/2014
509213;31/12/2009
510769;31/01/2006
521124;10/12/2015
512370;07/03/2017
509884;31/12/2009
510530;12/12/2016
520462;05/06/2012
533351;28/12/2012
508381;21/12/2016
505706;09/06/2021
516899;15/10/2002
509620;30/09/2015
528099;11/02/2021
509876;29/12/2016
508845;09/04/2003
516430;03/08/2012
505048;26/02/2020
510270;04/11/2011
529877;14/03/2017
506567;30/09/2020
530328;29/09/2017
517550;14/11/2011
517658;18/11/2012
503800;04/06/2021
511382;08/06/2017
514969;20/10/2014
509434;09/04/2008
519189;28/12/2012
503843;15/12/2020
516821;29/12/2014
532134;30/04/2020
507407;31/07/2014
518557;08/10/2015
518964;01/10/2013
516937;09/02/2009
507210;07/03/2018
533610;07/06/2021
533238;02/08/2017
500208;11/06/2019
512796;28/11/2014
504505;24/06/2019
513008;11/12/2014
518549;16/08/2013
509736;18/11/2012
510459;31/12/2009
522570;03/12/2011
512354;31/12/2009
526690;04/12/2007
524999;27/06/2013
522643;25/02/2008
533289;30/12/2015
531871;12/05/2016
521191;26/04/2013
507679;18/11/2012
509833;20/01/2014
509230;06/12/2012
507490;09/05/2002
530913;07/07/2015
528927;30/10/2020
522767;10/10/2016
531251;26/10/2015
509477;31/05/2013
526088;04/06/2021
508527;09/06/2008
508837;15/07/2014
530204;04/06/2021
521795;28/03/2014
510572;10/10/2002
526592;28/06/2021
532746;17/12/2014
519197;08/11/2016
533165;17/12/2014
532576;08/05/2003
504580;23/05/2019
508926;28/08/2013
509930;09/12/2014
507415;17/06/2009
510777;04/11/2008
515710;19/04/2006
508195;19/09/2014
510203;27/11/2014
520055;08/05/2003
532843;19/09/2011
526770;24/12/2015
523402;23/01/2014
528838;30/11/2018
515531;21/07/2017
508756;12/02/2009
506850;12/06/2017
517275;02/07/2012
510599;09/11/2007
517348;15/02/2016
523232;18/11/2012
503444;18/11/2012
532550;18/11/2012
512877;27/11/2014
528951;06/12/2019
508071;12/03/2014
512060;28/02/2002
504866;02/10/2019
521779;04/03/2015
528960;04/12/2019
507440;06/06/2002
522554;18/01/2012
515191;21/09/2015
509248;18/05/2011
504017;27/12/2019
532533;11/05/2016
518522;01/12/2001
513695;15/12/2015
509019;18/10/2007
508349;28/11/2012
521442;26/05/2016
514918;15/06/2015
508250;01/06/2015
510610;15/12/2016
512532;24/02/2015
522597;10/03/2017
510289;05/10/2016
514411;15/07/2014
522368;04/06/2021
512915;09/08/2017
512834;26/11/2014
528218;10/04/2017
522082;26/01/2012
510335;09/12/2014
528900;22/12/2017
505714;09/06/2021
522520;21/11/2014
503851;10/05/2019
526916;01/10/2014
524271;13/01/2014
527858;07/05/2014
532215;15/06/2016
522651;18/11/2012
515280;23/11/2009
509744;10/04/2008
507113;20/10/2016
510149;04/12/2013
513229;27/12/2017
529800;08/07/2021
510963;22/10/2014
530433;30/10/2015
506800;19/04/2007
513954;17/03/2014
508918;30/11/2011
514713;04/06/2020
522279;08/12/2016
518743;28/10/2015
523097;05/11/2015
526550;19/11/2012
523828;17/08/2015
533432;28/11/2016
511056;15/10/2008
524212;01/06/2016
514225;01/12/2001
510181;01/08/2014
528005;18/12/2014
525219;18/11/2011
527076;04/06/2021
520632;04/12/2013
533599;07/06/2021
533335;02/06/2015
518590;06/02/2017
511048;21/12/2007
507660;16/11/2016
515116;06/01/2014
510734;27/12/2017
509922;31/12/2009
525286;29/01/2016
521663;11/02/2016
503100;07/06/2021
522724;04/11/2016
503452;18/11/2012
532118;22/04/2016
520934;03/03/2017
533467;22/05/2018
518492;18/11/2012
509370;30/11/2011
508691;31/12/2009
531588;07/11/2019
510688;18/11/2012
527831;29/12/2020
516996;05/09/2016
526118;22/05/2009
521744;28/11/2016
524670;15/10/2015
525677;30/11/2012
522228;19/11/2020
519227;28/10/2015
526363;19/07/2016
512001;19/04/2004
505722;09/06/2021
516317;18/11/2014
514624;17/12/2012
507466;12/07/2001
514667;14/03/2011
533157;26/03/2014
502901;27/01/2021
512150;05/11/2015
513725;18/11/2012
527793;09/06/2016
522732;04/06/2021
509191;28/11/2014
517240;30/11/2015
523860;15/12/2015
509990;30/07/2015
520608;05/05/2016
514071;04/06/2021
518824;19/06/2013
509973;27/10/2014
514241;02/01/2012
506109;04/07/2018
508829;20/04/2007
510971;18/11/2012
513164;30/06/2004
511790;18/11/2012
525030;13/04/2012
521973;03/11/2016
510033;09/05/2002
533270;30/06/2014
507156;06/10/2015
523437;06/11/2014
513741;20/04/2016
512397;01/02/2002
522384;24/10/2013
508047;20/04/2005
504491;24/05/2019
518085;06/07/2006
511676;27/04/2015
533416;28/12/2012
510327;17/02/2011
518760;24/02/2015
507237;17/04/2018
514977;15/11/2015
510670;11/06/2014
511439;18/11/2014
519790;18/11/2012
512257;10/08/2016
528455;30/03/2017
514004;31/07/2011
515620;26/08/2011
529001;04/07/2017
511102;06/02/2017
528978;31/03/2016
516341;18/07/2014
510424;10/10/2002
527904;27/12/2017
517771;18/11/2014
510378;11/12/2015
525049;05/12/2014
524077;04/11/2016
527777;04/06/2013
512788;07/12/2009
501883;04/06/2021
515140;13/11/2014
507601;29/06/2007
529591;31/01/2019
526797;15/02/2019
509582;26/11/2015
525723;18/11/2012
513539;18/11/2012
513040;18/11/2012
509469;30/11/2011
525936;17/08/2015
533572;07/06/2021
519308;24/11/2016
527319;22/12/2015
512737;07/06/2016
516635;16/05/2014
533602;07/06/2021
510882;02/04/2013
517097;19/06/2007
507008;30/12/2011
528560;14/01/2013
509850;15/10/2014
506656;31/05/2021
532460;25/10/2013
505730;09/06/2021';
 
 vr_clob_line_count := length(vr_clob) - nvl(length(replace(vr_clob,chr(10))),0) + 1;
 
 -- buscar a data de movimentação da cooperativa
 OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH cecred.btch0001.cr_crapdat INTO rw_crapdat;

   -- Se nao encontrar
   IF cecred.btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE cecred.btch0001.cr_crapdat;
      raise vr_exc_sem_data_cooperativa;
   ELSE
      CLOSE cecred.btch0001.cr_crapdat;
   END IF;

 vr_dtmvtolt:=rw_crapdat.dtmvtolt;
     
 
 FOR vr_indice IN 1.. vr_clob_line_count LOOP
   
   BEGIN
  
    vr_registros :=vr_indice;
  
    vr_clob_line :=regexp_substr(vr_clob,'^.*$',1,vr_indice,'m');
  
    vr_delimitador :=instr(vr_clob_line,';');
  
    vr_nrdconta :=substr(vr_clob_line,1,vr_delimitador - 1);
  
    vr_data_demissao :=substr(vr_clob_line,vr_delimitador + 1, 10);
  
    
  vr_cdsitdct:=NULL;
  vr_tppessoa:=NULL;
  vr_cdagenci:=NULL; 
  vr_vllimcre:=NULL; 
  vr_dtdemiss_ant:=NULL; 
  vr_cdmotdem_ant:=NULL;
  vr_dtelimin_ant:=NULL;
  vr_dtasitct_ant:=NULL;
  
  -- Verificando a situação da conta
    
  BEGIN 
    
      SELECT cdsitdct, inpessoa, cdagenci, vllimcre, dtdemiss, cdmotdem, dtelimin, dtasitct
        into vr_cdsitdct, vr_tppessoa, vr_cdagenci, vr_vllimcre, vr_dtdemiss_ant, vr_cdmotdem_ant, vr_dtelimin_ant, vr_dtasitct_ant
      FROM cecred.crapass
      WHERE nrdconta = vr_nrdconta
        AND cdcooper = vr_cdcooper;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vr_cdsitdct:=NULL;
        WHEN OTHERS THEN
        raise vr_exc_associados;
  END;
          
    
  IF (vr_cdsitdct is not null) and (vr_cdsitdct != 4) THEN  
      vr_dstransa := 'Alteracao da conta para situacao 4 INC0103839.';
      
      -- Obter saldo do dia
        cecred.EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => vr_cdcooper
                   ,pr_rw_crapdat => rw_crapdat
                   ,pr_cdagenci   => vr_cdagenci
                   ,pr_nrdcaixa   => 0 -- pr_nrdcaixa
                   ,pr_cdoperad   => 1 -- pr_cdoperad
                   ,pr_nrdconta   => vr_nrdconta
                   ,pr_vllimcre   => vr_vllimcre
                   ,pr_dtrefere   => vr_dtmvtolt
                   ,pr_flgcrass   => FALSE --pr_flgcrass  -- true
                   ,pr_tipo_busca => 'A' -- pr_tipo_busca -- pode ser A, I, P
                   ,pr_des_reto   => vr_des_reto
                   ,pr_tab_sald   => vr_tab_sald
                   ,pr_tab_erro   => vr_tab_erro);

        IF vr_des_reto = 'OK' THEN
         IF vr_tab_sald.count() > 0 THEN
          begin
           vr_index    := vr_tab_sald.first();
           vr_vlsddisp := vr_tab_sald(vr_index).vlsddisp;
          end;
         END IF;
        ELSE
         IF vr_tab_erro.count() > 0 THEN
         begin
           vr_index    := vr_tab_erro.first();
           vr_cdcritic := vr_tab_erro(vr_index).cdcritic;
           vr_dscritic := vr_tab_erro(vr_index).dscritic;
           raise vr_exc_saldo;
         end;
         END IF;

        END IF;
      
      
      -- verifica se a conta é PF E PJ, e define o códigos dos históricos
         
      IF vr_tppessoa = 1 THEN
        BEGIN
           vr_cdhistor:=2079;
           vr_cdhistorenc:=2061;
          END;
        ELSIF vr_tppessoa = 2 THEN
         BEGIN
            vr_cdhistor:=2080;
            vr_cdhistorenc:=2062;
         END;
        END IF;
      --
      
      -- se o saldo for positivo, debita valor
      IF vr_vlsddisp > 0 THEN
      
         vr_capdev_ant := 0;
         vr_insere     := 'N';
        
         cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper => vr_cdcooper
                                         , pr_dtmvtolt => vr_dtmvtolt
                                         , pr_cdagenci => vr_cdagenci
                                         , pr_cdbccxlt => 1 --rw_craplot_rvt.cdbccxlt
                                         , pr_nrdolote => 37000 --vr_nrdolote --rw_craplot_rvt.nrdolote
                                         , pr_nrdctabb => vr_nrdconta
                                         , pr_nrdocmto => vr_nrdconta || vr_cdcooper
                                         , pr_cdhistor => vr_cdhistorenc

                                         , pr_vllanmto => vr_vlsddisp
                                         , pr_nrdconta => vr_nrdconta
                                         , pr_hrtransa => gene0002.fn_busca_time --TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                         , pr_nrdctitg => TO_CHAR(gene0002.fn_mask(vr_nrdconta,'99999999'))
                                         , pr_cdorigem => 0 --pr_idorigem
                                         , pr_inprolot  => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                         --, pr_tplotmov  => 1
                                         , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                         , pr_incrineg  => vr_incrineg      -- OUT Indicador de cr?tica de neg?cio
                                         , pr_cdcritic  => vr_cdcritic      -- OUT
                                         , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lan?amento (CRAPLCM, conta transit?ria, etc)
  
           
      
            IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                     raise vr_exc_lanc_conta;
                  ELSE
                BEGIN
              SELECT VLCAPITAL
                 into vr_capdev_ant
              FROM CECRED.TBCOTAS_DEVOLUCAO
              WHERE TPDEVOLUCAO = 4
                AND cdcooper = vr_cdcooper
                AND nrdconta = vr_nrdconta;
                EXCEPTION 
                WHEN no_data_found THEN
               BEGIN
                     vr_capdev_ant := 0;
                     dbms_output.put_line(chr(10) || 'Não encontrado TBCOTAS_DEVOLUCAO anterior para conta ' || vr_nrdconta);
                     vr_insere := 'S';
               END;
              END;  

                    IF vr_insere = 'S' THEN
            --
              INSERT INTO CECRED.TBCOTAS_DEVOLUCAO
              ( cdcooper, 
                nrdconta, 
                tpdevolucao, 
                vlcapital, 
                qtparcelas, 
                dtinicio_credito, 
                vlpago)
              VALUES 
             ( vr_cdcooper, 
             vr_nrdconta, 
             4, 
             vr_vlsddisp, 
             1, 
             null, 
             0);
             --
             dbms_output.put_line('inserindo na TBCOTAS_DEVOLUCAO (' || vr_cdcooper || ') ' || vr_nrdconta);
            --
              ELSE 
              -- Adiciona valor de cota capital para devolução.
              UPDATE CECRED.TBCOTAS_DEVOLUCAO
                SET VLCAPITAL = VLCAPITAL + vr_vlsddisp
              WHERE CDCOOPER = vr_cdcooper
                AND NRDCONTA = vr_nrdconta
               AND TPDEVOLUCAO = 4;
              END IF;
          
          END IF;   
            
      END IF;
      
      
      -- Verificar o valor de cotas a devolver ao cooperado.
      vr_vldcotas := 0;
      --
      OPEN cr_crapcot(vr_nrdconta
              , vr_cdcooper);
      FETCH cr_crapcot into vr_vldcotas;
      CLOSE cr_crapcot;
      --
            
      --
      IF NVL(vr_vldcotas, 0) > 0 THEN 
        --
        vr_capdev_ant := 0;
        vr_insere     := 'N';
        --
        BEGIN
        SELECT VLCAPITAL
          into vr_capdev_ant
        FROM CECRED.TBCOTAS_DEVOLUCAO
        where TPDEVOLUCAO = 3
          and cdcooper = vr_cdcooper
          and nrdconta = vr_nrdconta;
        EXCEPTION 
        WHEN no_data_found THEN
          vr_capdev_ant := 0;
          dbms_output.put_line(chr(10) || 'Não encontrado TBCOTAS_DEVOLUCAO anterior para conta ' || vr_nrdconta);
          vr_insere := 'S';
        END;
        
        --
        IF vr_insere = 'S' THEN
        --
        INSERT INTO CECRED.TBCOTAS_DEVOLUCAO
        ( cdcooper, 
          nrdconta, 
          tpdevolucao, 
          vlcapital, 
          qtparcelas, 
          dtinicio_credito, 
          vlpago)
        VALUES 
          ( vr_cdcooper, 
          vr_nrdconta, 
          3, 
          vr_vldcotas, 
          1, 
          null, 
          0);
        --
        dbms_output.put_line('inserindo na TBCOTAS_DEVOLUCAO (' || vr_cdcooper || ') ' || vr_nrdconta);
        --
        ELSE 
        -- Adiciona valor de cota capital para devolução.
        UPDATE CECRED.TBCOTAS_DEVOLUCAO
          SET VLCAPITAL = VLCAPITAL + vr_vldcotas
        WHERE CDCOOPER = vr_cdcooper
          AND NRDCONTA = vr_nrdconta
          AND TPDEVOLUCAO = 3;
        END IF;
        --
                
        -- Remove valor de cota capital
        UPDATE cecred.crapcot
           SET vldcotas = vldcotas - vr_vldcotas
        WHERE cdcooper = vr_cdcooper
          AND nrdconta = vr_nrdconta; 
        
        --
        vr_nrdocmto := vr_nrdconta || vr_cdcooper;
        vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', vr_cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';16;100;600040');
        --
                 
        -- efetua o lançamento do extrato
        INSERT INTO cecred.craplct(cdcooper
        ,cdagenci
        ,cdbccxlt
        ,nrdolote
        ,dtmvtolt
        ,cdhistor
        ,nrctrpla
        ,nrdconta
        ,nrdocmto
        ,nrseqdig
        ,vllanmto)
        VALUES (vr_cdcooper
        ,16
        ,100
        ,600040
        ,vr_dtmvtolt
        ,vr_cdhistor
        ,0
        ,vr_nrdconta 
        ,vr_nrdocmto
        ,vr_nrseqdig
        ,vr_vldcotas); 
        --
        vr_dstransa := vr_dstransa || ' Movimentando saldo de capital para valores a devolver por script. R$ ' || to_char(vr_vldcotas, '9G999D99') || ' ' || vr_dtmvtolt;
        --
      END IF;
      --
      --vr_log_script := vr_log_script || ' | ' || vr_dstransa;
      --
      -- Atualiza crapass
      UPDATE CECRED.CRAPASS
        SET cdsitdct = 4, 
            dtdemiss = to_date(vr_data_demissao,'DD/MM/YYYY'),
          dtelimin = to_date(vr_data_demissao,'DD/MM/YYYY'),
                dtasitct = to_date(vr_data_demissao,'DD/MM/YYYY'),
                  cdmotdem = 11
      WHERE nrdconta = vr_nrdconta
        AND cdcooper = vr_cdcooper;
      --
      

      INSERT INTO cecred.craplgm(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,dstransa
        ,dsorigem
        ,nmdatela
        ,flgtrans
        ,dscritic
        ,cdoperad
        ,nmendter)
      VALUES
        (vr_cdcooper
        ,vr_nrdconta
        ,1
        ,1
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,vr_dstransa
        ,'AIMARO'
        ,''
        ,1
        ,' '
        ,1
        ,' ');
      --
      
      -- Insere log com valores de antes x depois.
      INSERT INTO cecred.craplgi(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,nrseqcmp
        ,nmdcampo
        ,dsdadant
        ,dsdadatu)
      VALUES
        (vr_cdcooper
        ,vr_nrdconta
        ,1
        ,1
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,1
        ,'crapass.cdsitdct'
        ,vr_cdsitdct
        ,'4');
      
      -- Insere log com valores de antes x depois.
      INSERT INTO cecred.craplgi(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,nrseqcmp
        ,nmdcampo
        ,dsdadant
        ,dsdadatu)
      VALUES
        (vr_cdcooper
        ,vr_nrdconta
        ,1
        ,1
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,2
        ,'crapass.dtdemiss'
        ,to_char(vr_dtdemiss_ant,'DD/MM/YYYY')
        ,vr_data_demissao);
        
        
      -- Insere log com valores de antes x depois.
      INSERT INTO cecred.craplgi(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,nrseqcmp
        ,nmdcampo
        ,dsdadant
        ,dsdadatu)
      VALUES
        (vr_cdcooper
        ,vr_nrdconta
        ,1
        ,1
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,3
        ,'crapass.cdmotdem'
        ,vr_cdmotdem_ant
        ,'11');
            
      -- Insere log com valores de antes x depois.
      INSERT INTO cecred.craplgi(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,nrseqcmp
        ,nmdcampo
        ,dsdadant
        ,dsdadatu)
      VALUES
        (vr_cdcooper
        ,vr_nrdconta
        ,1
        ,1
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,4
        ,'crapass.dtelimin'
        ,to_char(vr_dtelimin_ant,'DD/MM/YYYY')
        ,vr_data_demissao);
        
      -- Insere log com valores de antes x depois.
      INSERT INTO cecred.craplgi(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,nrseqcmp
        ,nmdcampo
        ,dsdadant
        ,dsdadatu)
      VALUES
        (vr_cdcooper
        ,vr_nrdconta
        ,1
        ,1
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,5
        ,'crapass.dtasitct'
        ,to_char(vr_dtasitct_ant,'DD/MM/YYYY')
        ,vr_data_demissao);  
          
        
      --
      IF NVL(vr_vldcotas, 0) > 0 then
        --
        -- Insere log com valores de antes x depois da TBCOTAS_DEVOLUCAO.
        INSERT INTO cecred.craplgi(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,nrseqcmp
        ,nmdcampo
        ,dsdadant
        ,dsdadatu)
        VALUES
        (vr_cdcooper
        ,vr_nrdconta
        ,1
        ,1
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,6
        ,'tbcotas_devolucao.VLCAPITAL'
        ,vr_capdev_ant
        ,(vr_capdev_ant + vr_vldcotas) );
        --
        -- Insere log com valores de antes x depois da CRAPCOT.
        INSERT INTO cecred.craplgi(cdcooper
        ,nrdconta
        ,idseqttl
        ,nrsequen
        ,dttransa
        ,hrtransa
        ,nrseqcmp
        ,nmdcampo
        ,dsdadant
        ,dsdadatu)
        VALUES
        (vr_cdcooper
        ,vr_nrdconta
        ,1
        ,1
        ,vr_dtmvtolt
        ,vr_hrtransa
        ,7
        ,'crapcot.vldcotas'
        ,vr_vldcotas
        ,0 );
        --
      END IF;
      
      COMMIT;
      --
  END IF;
      
   END;     
  
  END LOOP;  
  --
  --DBMS_OUTPUT.PUT_LINE(vr_log_script);
  --
  --
  DBMS_OUTPUT.PUT_LINE('Sucesso na atualização.');
  --
EXCEPTION
  WHEN vr_exc_lanc_conta THEN
      BEGIN
         vr_cdcritic := NVL(vr_cdcritic, 0);

         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := cecred.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         END IF;
         RAISE_APPLICATION_ERROR(-20000, 'Atenção: ' || vr_dscritic);
      END;
  WHEN vr_exc_saldo THEN
     BEGIN
       vr_dscritic := cecred.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
     RAISE_APPLICATION_ERROR(-20000, 'Atenção: ' || vr_dscritic);
     END;
  WHEN vr_exc_sem_data_cooperativa THEN
     BEGIN
        vr_cdcritic := 1;
        vr_dscritic := cecred.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE_APPLICATION_ERROR(-20000, 'Atenção: ' || vr_dscritic);
     END;
  WHEN vr_exc_associados THEN
     BEGIN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao consultar associados: ' || SQLERRM);
     END;
  WHEN OTHERS THEN
    --
    ROLLBACK;
    --
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
    --
END;
