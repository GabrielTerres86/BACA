DECLARE
  vr_dttransa    cecred.craplgm.dttransa%type;
  vr_hrtransa    cecred.craplgm.hrtransa%type;
  vr_nrdconta    cecred.crapass.nrdconta%type;
  vr_cdcooper    cecred.crapcop.cdcooper%type;
  vr_cdoperad    cecred.craplgm.cdoperad%TYPE;
  vr_dscritic    cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid    ROWID;

  CURSOR cr_crapass is
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 1 and t.nrdconta = 9764488) or (t.cdcooper = 1 and t.nrdconta = 9773592) or (t.cdcooper = 1 and t.nrdconta = 9765760) or
(t.cdcooper = 1 and t.nrdconta = 80096506) or (t.cdcooper = 1 and t.nrdconta = 9745238) or (t.cdcooper = 1 and t.nrdconta = 1975935) or
(t.cdcooper = 1 and t.nrdconta = 3839893) or (t.cdcooper = 1 and t.nrdconta = 90072324) or (t.cdcooper = 1 and t.nrdconta = 90072910) or
(t.cdcooper = 1 and t.nrdconta = 90072952) or (t.cdcooper = 1 and t.nrdconta = 90072987) or (t.cdcooper = 1 and t.nrdconta = 90073231) or
(t.cdcooper = 1 and t.nrdconta = 90073347) or (t.cdcooper = 1 and t.nrdconta = 90073550) or (t.cdcooper = 1 and t.nrdconta = 90073932) or
(t.cdcooper = 1 and t.nrdconta = 90073991) or (t.cdcooper = 1 and t.nrdconta = 90074467) or (t.cdcooper = 1 and t.nrdconta = 90075048) or
(t.cdcooper = 1 and t.nrdconta = 90078071) or (t.cdcooper = 1 and t.nrdconta = 90078152) or (t.cdcooper = 1 and t.nrdconta = 90078250) or
(t.cdcooper = 1 and t.nrdconta = 90078268) or (t.cdcooper = 1 and t.nrdconta = 90078420) or (t.cdcooper = 1 and t.nrdconta = 90078659) or
(t.cdcooper = 1 and t.nrdconta = 90078691) or (t.cdcooper = 1 and t.nrdconta = 90078845) or (t.cdcooper = 1 and t.nrdconta = 90078977) or
(t.cdcooper = 1 and t.nrdconta = 90079248) or (t.cdcooper = 1 and t.nrdconta = 90079469) or (t.cdcooper = 1 and t.nrdconta = 90104927) or
(t.cdcooper = 1 and t.nrdconta = 90110250) or (t.cdcooper = 1 and t.nrdconta = 90111630) or (t.cdcooper = 1 and t.nrdconta = 90111656) or
(t.cdcooper = 1 and t.nrdconta = 90111907) or (t.cdcooper = 1 and t.nrdconta = 90112385) or (t.cdcooper = 1 and t.nrdconta = 90112652) or
(t.cdcooper = 1 and t.nrdconta = 90113306) or (t.cdcooper = 1 and t.nrdconta = 90129695) or (t.cdcooper = 1 and t.nrdconta = 90134095) or
(t.cdcooper = 1 and t.nrdconta = 90135059) or (t.cdcooper = 1 and t.nrdconta = 90136241) or (t.cdcooper = 1 and t.nrdconta = 90136250) or
(t.cdcooper = 1 and t.nrdconta = 90136349) or (t.cdcooper = 1 and t.nrdconta = 90136462) or (t.cdcooper = 1 and t.nrdconta = 90136829) or
(t.cdcooper = 1 and t.nrdconta = 90160053) or (t.cdcooper = 1 and t.nrdconta = 90160720) or (t.cdcooper = 1 and t.nrdconta = 90162099) or
(t.cdcooper = 1 and t.nrdconta = 90162145) or (t.cdcooper = 1 and t.nrdconta = 90162250) or (t.cdcooper = 1 and t.nrdconta = 90163028) or
(t.cdcooper = 1 and t.nrdconta = 90163672) or (t.cdcooper = 1 and t.nrdconta = 90164210) or (t.cdcooper = 1 and t.nrdconta = 90169506) or
(t.cdcooper = 1 and t.nrdconta = 90220854) or (t.cdcooper = 1 and t.nrdconta = 90220927) or (t.cdcooper = 1 and t.nrdconta = 90220943) or
(t.cdcooper = 1 and t.nrdconta = 90221460) or (t.cdcooper = 1 and t.nrdconta = 90221575) or (t.cdcooper = 1 and t.nrdconta = 90221591) or
(t.cdcooper = 1 and t.nrdconta = 90221664) or (t.cdcooper = 1 and t.nrdconta = 90221893) or (t.cdcooper = 1 and t.nrdconta = 90222040) or
(t.cdcooper = 1 and t.nrdconta = 90222105) or (t.cdcooper = 1 and t.nrdconta = 90222261) or (t.cdcooper = 1 and t.nrdconta = 90222326) or
(t.cdcooper = 1 and t.nrdconta = 90222970) or (t.cdcooper = 1 and t.nrdconta = 90223080) or (t.cdcooper = 1 and t.nrdconta = 90223101) or
(t.cdcooper = 1 and t.nrdconta = 90223322) or (t.cdcooper = 1 and t.nrdconta = 90223497) or (t.cdcooper = 1 and t.nrdconta = 90223560) or
(t.cdcooper = 1 and t.nrdconta = 90223578) or (t.cdcooper = 1 and t.nrdconta = 90223683) or (t.cdcooper = 1 and t.nrdconta = 90223713) or
(t.cdcooper = 1 and t.nrdconta = 90223861) or (t.cdcooper = 1 and t.nrdconta = 90224469) or (t.cdcooper = 1 and t.nrdconta = 90224744) or
(t.cdcooper = 1 and t.nrdconta = 90224906) or (t.cdcooper = 1 and t.nrdconta = 90263324) or (t.cdcooper = 1 and t.nrdconta = 90266862) or
(t.cdcooper = 1 and t.nrdconta = 8671982) or (t.cdcooper = 1 and t.nrdconta = 8766070) or (t.cdcooper = 1 and t.nrdconta = 10027548) or
(t.cdcooper = 1 and t.nrdconta = 12602280) or (t.cdcooper = 1 and t.nrdconta = 12602302) or (t.cdcooper = 1 and t.nrdconta = 596949) or
(t.cdcooper = 1 and t.nrdconta = 3766160) or (t.cdcooper = 1 and t.nrdconta = 6233805) or (t.cdcooper = 1 and t.nrdconta = 7018410) or
(t.cdcooper = 1 and t.nrdconta = 7437064) or (t.cdcooper = 1 and t.nrdconta = 90054644) or (t.cdcooper = 1 and t.nrdconta = 90122780) or
(t.cdcooper = 1 and t.nrdconta = 9099972) or (t.cdcooper = 1 and t.nrdconta = 9928553) or (t.cdcooper = 1 and t.nrdconta = 8952035) or
(t.cdcooper = 1 and t.nrdconta = 6795919) or (t.cdcooper = 1 and t.nrdconta = 90164288) or (t.cdcooper = 1 and t.nrdconta = 90164318) or
(t.cdcooper = 1 and t.nrdconta = 90164555) or (t.cdcooper = 1 and t.nrdconta = 90164563) or (t.cdcooper = 1 and t.nrdconta = 90165012) or
(t.cdcooper = 1 and t.nrdconta = 90168674) or (t.cdcooper = 1 and t.nrdconta = 90168682) or (t.cdcooper = 1 and t.nrdconta = 90169131) or
(t.cdcooper = 1 and t.nrdconta = 90169247) or (t.cdcooper = 1 and t.nrdconta = 90221036) or (t.cdcooper = 1 and t.nrdconta = 90221931) or
(t.cdcooper = 1 and t.nrdconta = 90222245) or (t.cdcooper = 1 and t.nrdconta = 90222377) or (t.cdcooper = 1 and t.nrdconta = 90222776) or
(t.cdcooper = 1 and t.nrdconta = 90223357) or (t.cdcooper = 1 and t.nrdconta = 90223420) or (t.cdcooper = 1 and t.nrdconta = 90224396) or
(t.cdcooper = 1 and t.nrdconta = 90224787) or (t.cdcooper = 1 and t.nrdconta = 90260473) or (t.cdcooper = 1 and t.nrdconta = 90261038) or
(t.cdcooper = 1 and t.nrdconta = 90262336) or (t.cdcooper = 1 and t.nrdconta = 90262425) or (t.cdcooper = 1 and t.nrdconta = 90262476) or
(t.cdcooper = 1 and t.nrdconta = 90263626) or (t.cdcooper = 1 and t.nrdconta = 90263723) or (t.cdcooper = 1 and t.nrdconta = 90264088) or
(t.cdcooper = 1 and t.nrdconta = 90264657) or (t.cdcooper = 1 and t.nrdconta = 90265033) or (t.cdcooper = 1 and t.nrdconta = 90266196) or
(t.cdcooper = 1 and t.nrdconta = 9731334) or (t.cdcooper = 1 and t.nrdconta = 3862747) or (t.cdcooper = 1 and t.nrdconta = 7452535) or
(t.cdcooper = 1 and t.nrdconta = 6154778) or (t.cdcooper = 1 and t.nrdconta = 9763031) or (t.cdcooper = 1 and t.nrdconta = 9740554) or
(t.cdcooper = 1 and t.nrdconta = 3809404) or (t.cdcooper = 1 and t.nrdconta = 6353975) or (t.cdcooper = 1 and t.nrdconta = 3948641) or
(t.cdcooper = 1 and t.nrdconta = 2873370) or (t.cdcooper = 1 and t.nrdconta = 80366139) or (t.cdcooper = 1 and t.nrdconta = 3211940) or
(t.cdcooper = 1 and t.nrdconta = 9746668) or (t.cdcooper = 1 and t.nrdconta = 9750924) or (t.cdcooper = 1 and t.nrdconta = 9212299) or
(t.cdcooper = 1 and t.nrdconta = 7581300) or (t.cdcooper = 1 and t.nrdconta = 80369260) or (t.cdcooper = 1 and t.nrdconta = 9773525) or
(t.cdcooper = 1 and t.nrdconta = 1857355) or (t.cdcooper = 1 and t.nrdconta = 9179038) or (t.cdcooper = 1 and t.nrdconta = 7216556) or
(t.cdcooper = 1 and t.nrdconta = 7394683) or (t.cdcooper = 1 and t.nrdconta = 7668953) or (t.cdcooper = 1 and t.nrdconta = 9598537) or
(t.cdcooper = 1 and t.nrdconta = 973890) or (t.cdcooper = 1 and t.nrdconta = 10329986) or (t.cdcooper = 1 and t.nrdconta = 6806791) or
(t.cdcooper = 1 and t.nrdconta = 7484135) or (t.cdcooper = 1 and t.nrdconta = 4020766) or (t.cdcooper = 1 and t.nrdconta = 9661492) or
(t.cdcooper = 1 and t.nrdconta = 9736999) or (t.cdcooper = 1 and t.nrdconta = 9779272) or (t.cdcooper = 1 and t.nrdconta = 3877760) or
(t.cdcooper = 1 and t.nrdconta = 9766413) or (t.cdcooper = 1 and t.nrdconta = 2713527) or (t.cdcooper = 1 and t.nrdconta = 9814345) or
(t.cdcooper = 1 and t.nrdconta = 3576060) or (t.cdcooper = 1 and t.nrdconta = 6661050) or (t.cdcooper = 1 and t.nrdconta = 986054) or
(t.cdcooper = 1 and t.nrdconta = 7459521) or (t.cdcooper = 1 and t.nrdconta = 6522858) or (t.cdcooper = 1 and t.nrdconta = 6996841) or
(t.cdcooper = 1 and t.nrdconta = 7337205) or (t.cdcooper = 1 and t.nrdconta = 6744885) or (t.cdcooper = 1 and t.nrdconta = 3768988) or
(t.cdcooper = 1 and t.nrdconta = 6512658) or (t.cdcooper = 1 and t.nrdconta = 7290144) or (t.cdcooper = 1 and t.nrdconta = 7242697) or
(t.cdcooper = 1 and t.nrdconta = 7108257) or (t.cdcooper = 1 and t.nrdconta = 2376741) or (t.cdcooper = 1 and t.nrdconta = 7679319) or
(t.cdcooper = 1 and t.nrdconta = 1904116) or (t.cdcooper = 1 and t.nrdconta = 10352554) or (t.cdcooper = 1 and t.nrdconta = 7750331) or
(t.cdcooper = 1 and t.nrdconta = 6854168) or (t.cdcooper = 1 and t.nrdconta = 8072680) or (t.cdcooper = 1 and t.nrdconta = 8462712) or
(t.cdcooper = 1 and t.nrdconta = 6159621) or (t.cdcooper = 1 and t.nrdconta = 7348851) or (t.cdcooper = 1 and t.nrdconta = 7432003) or
(t.cdcooper = 1 and t.nrdconta = 7400080) or (t.cdcooper = 1 and t.nrdconta = 7597673) or (t.cdcooper = 1 and t.nrdconta = 8086869) or
(t.cdcooper = 1 and t.nrdconta = 9735631) or (t.cdcooper = 1 and t.nrdconta = 9730508) or (t.cdcooper = 1 and t.nrdconta = 7269366) or
(t.cdcooper = 1 and t.nrdconta = 9856099) or (t.cdcooper = 1 and t.nrdconta = 7308310) or (t.cdcooper = 1 and t.nrdconta = 7309856) or
(t.cdcooper = 1 and t.nrdconta = 7687397) or (t.cdcooper = 1 and t.nrdconta = 10159010) or (t.cdcooper = 1 and t.nrdconta = 9727884) or
(t.cdcooper = 1 and t.nrdconta = 6267599) or (t.cdcooper = 1 and t.nrdconta = 9757554) or (t.cdcooper = 1 and t.nrdconta = 8149909) or
(t.cdcooper = 1 and t.nrdconta = 9767312) or (t.cdcooper = 1 and t.nrdconta = 7246390) or (t.cdcooper = 1 and t.nrdconta = 7297203) or
(t.cdcooper = 1 and t.nrdconta = 2919761) or (t.cdcooper = 1 and t.nrdconta = 7369573) or (t.cdcooper = 1 and t.nrdconta = 2627108) or
(t.cdcooper = 1 and t.nrdconta = 9750649) or (t.cdcooper = 1 and t.nrdconta = 8146128) or (t.cdcooper = 1 and t.nrdconta = 773379) or
(t.cdcooper = 1 and t.nrdconta = 2221063) or (t.cdcooper = 1 and t.nrdconta = 2261804) or (t.cdcooper = 1 and t.nrdconta = 2312590) or
(t.cdcooper = 1 and t.nrdconta = 2884100) or (t.cdcooper = 1 and t.nrdconta = 2898918) or (t.cdcooper = 1 and t.nrdconta = 2947544) or
(t.cdcooper = 1 and t.nrdconta = 6832555) or (t.cdcooper = 1 and t.nrdconta = 6885780) or (t.cdcooper = 1 and t.nrdconta = 6965920) or
(t.cdcooper = 1 and t.nrdconta = 90168640) or (t.cdcooper = 1 and t.nrdconta = 8423776) or (t.cdcooper = 1 and t.nrdconta = 9308229) or
(t.cdcooper = 1 and t.nrdconta = 8629307) or (t.cdcooper = 1 and t.nrdconta = 8037990) or (t.cdcooper = 1 and t.nrdconta = 9765689) or
(t.cdcooper = 1 and t.nrdconta = 3759130) or (t.cdcooper = 1 and t.nrdconta = 7856059) or (t.cdcooper = 1 and t.nrdconta = 9722556) or
(t.cdcooper = 1 and t.nrdconta = 2714450) or (t.cdcooper = 1 and t.nrdconta = 2141701) or (t.cdcooper = 1 and t.nrdconta = 970816) or
(t.cdcooper = 1 and t.nrdconta = 1866478) or (t.cdcooper = 1 and t.nrdconta = 1866486) or (t.cdcooper = 1 and t.nrdconta = 1946765) or
(t.cdcooper = 1 and t.nrdconta = 1969099) or (t.cdcooper = 1 and t.nrdconta = 2016060) or (t.cdcooper = 1 and t.nrdconta = 2040212) or
(t.cdcooper = 1 and t.nrdconta = 2045192) or (t.cdcooper = 1 and t.nrdconta = 2146975) or (t.cdcooper = 1 and t.nrdconta = 3132994) or
(t.cdcooper = 1 and t.nrdconta = 3542874) or (t.cdcooper = 1 and t.nrdconta = 6362559) or (t.cdcooper = 1 and t.nrdconta = 6660738) or
(t.cdcooper = 1 and t.nrdconta = 6875831) or (t.cdcooper = 1 and t.nrdconta = 6991700) or (t.cdcooper = 1 and t.nrdconta = 7074212) or
(t.cdcooper = 1 and t.nrdconta = 7293992) or (t.cdcooper = 1 and t.nrdconta = 90070771) or (t.cdcooper = 1 and t.nrdconta = 90072499) or
(t.cdcooper = 1 and t.nrdconta = 90073126) or (t.cdcooper = 1 and t.nrdconta = 90078187) or (t.cdcooper = 1 and t.nrdconta = 90111125) or
(t.cdcooper = 1 and t.nrdconta = 90111281) or (t.cdcooper = 1 and t.nrdconta = 90111494) or (t.cdcooper = 1 and t.nrdconta = 90121660) or
(t.cdcooper = 1 and t.nrdconta = 90134583) or (t.cdcooper = 1 and t.nrdconta = 90162080) or (t.cdcooper = 1 and t.nrdconta = 90162668) or
(t.cdcooper = 1 and t.nrdconta = 90164270) or (t.cdcooper = 1 and t.nrdconta = 90164733) or (t.cdcooper = 1 and t.nrdconta = 90165047) or
(t.cdcooper = 1 and t.nrdconta = 90165381) or (t.cdcooper = 1 and t.nrdconta = 90165780) or (t.cdcooper = 1 and t.nrdconta = 90167589) or
(t.cdcooper = 1 and t.nrdconta = 90169727) or (t.cdcooper = 1 and t.nrdconta = 90221524) or (t.cdcooper = 1 and t.nrdconta = 90224078) or
(t.cdcooper = 1 and t.nrdconta = 90263367) or (t.cdcooper = 1 and t.nrdconta = 90264282) or (t.cdcooper = 1 and t.nrdconta = 90264312) or
(t.cdcooper = 1 and t.nrdconta = 90264916) or (t.cdcooper = 1 and t.nrdconta = 90265394) or (t.cdcooper = 1 and t.nrdconta = 90267125) or
(t.cdcooper = 1 and t.nrdconta = 90267184) or (t.cdcooper = 1 and t.nrdconta = 90267842) or (t.cdcooper = 1 and t.nrdconta = 90267877) or
(t.cdcooper = 1 and t.nrdconta = 7840926) or (t.cdcooper = 1 and t.nrdconta = 8131562) or (t.cdcooper = 1 and t.nrdconta = 9752439) or
(t.cdcooper = 1 and t.nrdconta = 9756795) or (t.cdcooper = 1 and t.nrdconta = 9758283) or (t.cdcooper = 1 and t.nrdconta = 9777954) or
(t.cdcooper = 1 and t.nrdconta = 9054995) or (t.cdcooper = 1 and t.nrdconta = 8749965) or (t.cdcooper = 1 and t.nrdconta = 8687285) or
(t.cdcooper = 1 and t.nrdconta = 6293794) or (t.cdcooper = 1 and t.nrdconta = 6764991) or (t.cdcooper = 1 and t.nrdconta = 7509774) or
(t.cdcooper = 1 and t.nrdconta = 6787908) or (t.cdcooper = 1 and t.nrdconta = 7133260) or (t.cdcooper = 1 and t.nrdconta = 6056989) or
(t.cdcooper = 1 and t.nrdconta = 9802355) or (t.cdcooper = 1 and t.nrdconta = 9762469) or (t.cdcooper = 1 and t.nrdconta = 9767045) or
(t.cdcooper = 1 and t.nrdconta = 9237739) or (t.cdcooper = 1 and t.nrdconta = 3100227) or (t.cdcooper = 1 and t.nrdconta = 3974782) or
(t.cdcooper = 1 and t.nrdconta = 7105592) or (t.cdcooper = 1 and t.nrdconta = 9742875) or (t.cdcooper = 1 and t.nrdconta = 2858266) or
(t.cdcooper = 1 and t.nrdconta = 6357687) or (t.cdcooper = 1 and t.nrdconta = 3177491) or (t.cdcooper = 1 and t.nrdconta = 10082590) or
(t.cdcooper = 1 and t.nrdconta = 6530125) or (t.cdcooper = 1 and t.nrdconta = 9952101) or (t.cdcooper = 1 and t.nrdconta = 6093639) or
(t.cdcooper = 1 and t.nrdconta = 7562802) or (t.cdcooper = 1 and t.nrdconta = 9759379) or (t.cdcooper = 1 and t.nrdconta = 9327860) or
(t.cdcooper = 1 and t.nrdconta = 2816954) or (t.cdcooper = 1 and t.nrdconta = 2942402) or (t.cdcooper = 1 and t.nrdconta = 3983498) or
(t.cdcooper = 1 and t.nrdconta = 6430910) or (t.cdcooper = 1 and t.nrdconta = 6372074) or (t.cdcooper = 1 and t.nrdconta = 90050312) or
(t.cdcooper = 1 and t.nrdconta = 7103832) or (t.cdcooper = 1 and t.nrdconta = 90109090) or (t.cdcooper = 1 and t.nrdconta = 2324440) or
(t.cdcooper = 1 and t.nrdconta = 9768165) or (t.cdcooper = 1 and t.nrdconta = 2184532) or (t.cdcooper = 1 and t.nrdconta = 9497218) or
(t.cdcooper = 1 and t.nrdconta = 2813424) or (t.cdcooper = 1 and t.nrdconta = 2948370) or (t.cdcooper = 1 and t.nrdconta = 7705964) or
(t.cdcooper = 1 and t.nrdconta = 7328818) or (t.cdcooper = 1 and t.nrdconta = 6576192) or (t.cdcooper = 1 and t.nrdconta = 9731164) or
(t.cdcooper = 1 and t.nrdconta = 9733370) or (t.cdcooper = 1 and t.nrdconta = 618047) or (t.cdcooper = 1 and t.nrdconta = 618080) or
(t.cdcooper = 1 and t.nrdconta = 754005) or (t.cdcooper = 1 and t.nrdconta = 765945) or (t.cdcooper = 1 and t.nrdconta = 766739) or
(t.cdcooper = 1 and t.nrdconta = 908533) or (t.cdcooper = 1 and t.nrdconta = 971839) or (t.cdcooper = 1 and t.nrdconta = 1329901) or
(t.cdcooper = 1 and t.nrdconta = 1355392) or (t.cdcooper = 1 and t.nrdconta = 1907662) or (t.cdcooper = 1 and t.nrdconta = 1949233) or
(t.cdcooper = 1 and t.nrdconta = 1966669) or (t.cdcooper = 1 and t.nrdconta = 1993488) or (t.cdcooper = 1 and t.nrdconta = 2079291) or
(t.cdcooper = 1 and t.nrdconta = 2175720) or (t.cdcooper = 1 and t.nrdconta = 2559609) or (t.cdcooper = 1 and t.nrdconta = 3518345) or
(t.cdcooper = 1 and t.nrdconta = 6213618) or (t.cdcooper = 1 and t.nrdconta = 90050010) or (t.cdcooper = 1 and t.nrdconta = 90050576) or
(t.cdcooper = 1 and t.nrdconta = 90052200) or (t.cdcooper = 1 and t.nrdconta = 90052846) or (t.cdcooper = 1 and t.nrdconta = 90052862) or
(t.cdcooper = 1 and t.nrdconta = 90052943) or (t.cdcooper = 1 and t.nrdconta = 90053770) or (t.cdcooper = 1 and t.nrdconta = 90054806) or
(t.cdcooper = 1 and t.nrdconta = 90057643) or (t.cdcooper = 1 and t.nrdconta = 90070801) or (t.cdcooper = 1 and t.nrdconta = 90070933) or
(t.cdcooper = 1 and t.nrdconta = 90071239) or (t.cdcooper = 1 and t.nrdconta = 90071247) or (t.cdcooper = 1 and t.nrdconta = 90071301) or
(t.cdcooper = 1 and t.nrdconta = 90071506) or (t.cdcooper = 1 and t.nrdconta = 90071514) or (t.cdcooper = 1 and t.nrdconta = 90071557) or
(t.cdcooper = 1 and t.nrdconta = 90071590) or (t.cdcooper = 1 and t.nrdconta = 90071719) or (t.cdcooper = 1 and t.nrdconta = 90071913) or
(t.cdcooper = 1 and t.nrdconta = 90072090) or (t.cdcooper = 1 and t.nrdconta = 90073339) or (t.cdcooper = 1 and t.nrdconta = 90074726) or
(t.cdcooper = 1 and t.nrdconta = 90074912) or (t.cdcooper = 1 and t.nrdconta = 90075277) or (t.cdcooper = 1 and t.nrdconta = 90076516) or
(t.cdcooper = 1 and t.nrdconta = 90076974) or (t.cdcooper = 1 and t.nrdconta = 90077156) or (t.cdcooper = 1 and t.nrdconta = 90077172) or
(t.cdcooper = 1 and t.nrdconta = 90077210) or (t.cdcooper = 1 and t.nrdconta = 90077237) or (t.cdcooper = 1 and t.nrdconta = 90077369) or
(t.cdcooper = 1 and t.nrdconta = 90077741) or (t.cdcooper = 1 and t.nrdconta = 90077792) or (t.cdcooper = 1 and t.nrdconta = 90078764) or
(t.cdcooper = 1 and t.nrdconta = 90079175) or (t.cdcooper = 1 and t.nrdconta = 90079612) or (t.cdcooper = 1 and t.nrdconta = 90079744) or
(t.cdcooper = 1 and t.nrdconta = 90104900) or (t.cdcooper = 1 and t.nrdconta = 90106628) or (t.cdcooper = 1 and t.nrdconta = 90112288) or
(t.cdcooper = 1 and t.nrdconta = 90112725) or (t.cdcooper = 1 and t.nrdconta = 90122453) or (t.cdcooper = 1 and t.nrdconta = 90122844) or
(t.cdcooper = 1 and t.nrdconta = 90123360) or (t.cdcooper = 1 and t.nrdconta = 90123557) or (t.cdcooper = 1 and t.nrdconta = 90136900) or
(t.cdcooper = 1 and t.nrdconta = 90136985) or (t.cdcooper = 1 and t.nrdconta = 90160134) or (t.cdcooper = 1 and t.nrdconta = 90160266) or
(t.cdcooper = 1 and t.nrdconta = 90160517) or (t.cdcooper = 1 and t.nrdconta = 90160711) or (t.cdcooper = 1 and t.nrdconta = 90161211) or
(t.cdcooper = 1 and t.nrdconta = 90161416) or (t.cdcooper = 1 and t.nrdconta = 90163176) or (t.cdcooper = 1 and t.nrdconta = 90163303) or
(t.cdcooper = 1 and t.nrdconta = 90164130) or (t.cdcooper = 1 and t.nrdconta = 90164180) or (t.cdcooper = 1 and t.nrdconta = 90165420) or
(t.cdcooper = 1 and t.nrdconta = 90166671) or (t.cdcooper = 1 and t.nrdconta = 90168038) or (t.cdcooper = 1 and t.nrdconta = 90169190) or
(t.cdcooper = 1 and t.nrdconta = 90221559) or (t.cdcooper = 1 and t.nrdconta = 90221745) or (t.cdcooper = 1 and t.nrdconta = 90222393) or
(t.cdcooper = 1 and t.nrdconta = 90222717) or (t.cdcooper = 1 and t.nrdconta = 90223195) or (t.cdcooper = 1 and t.nrdconta = 90223373) or
(t.cdcooper = 1 and t.nrdconta = 90223977) or (t.cdcooper = 1 and t.nrdconta = 90260058) or (t.cdcooper = 1 and t.nrdconta = 90260660) or
(t.cdcooper = 1 and t.nrdconta = 90261763) or (t.cdcooper = 1 and t.nrdconta = 90264002) or (t.cdcooper = 1 and t.nrdconta = 90264100) or
(t.cdcooper = 1 and t.nrdconta = 90264118) or (t.cdcooper = 1 and t.nrdconta = 90264240) or (t.cdcooper = 1 and t.nrdconta = 90265203) or
(t.cdcooper = 1 and t.nrdconta = 9109129) or (t.cdcooper = 1 and t.nrdconta = 9126813) or (t.cdcooper = 1 and t.nrdconta = 9126961) or
(t.cdcooper = 1 and t.nrdconta = 9126970) or (t.cdcooper = 1 and t.nrdconta = 9128735) or (t.cdcooper = 1 and t.nrdconta = 9764364) or
(t.cdcooper = 1 and t.nrdconta = 872326) or (t.cdcooper = 1 and t.nrdconta = 7231482) or (t.cdcooper = 1 and t.nrdconta = 9744371) or
(t.cdcooper = 1 and t.nrdconta = 8582807) or (t.cdcooper = 1 and t.nrdconta = 9768629) or (t.cdcooper = 1 and t.nrdconta = 9770747) or
(t.cdcooper = 1 and t.nrdconta = 9762892) or (t.cdcooper = 1 and t.nrdconta = 9764046) or (t.cdcooper = 1 and t.nrdconta = 9765433) or
(t.cdcooper = 1 and t.nrdconta = 9765794) or (t.cdcooper = 1 and t.nrdconta = 9752617) or (t.cdcooper = 1 and t.nrdconta = 9761640) or
(t.cdcooper = 1 and t.nrdconta = 7752083) or (t.cdcooper = 1 and t.nrdconta = 7741936) or (t.cdcooper = 1 and t.nrdconta = 8976600) or
(t.cdcooper = 1 and t.nrdconta = 9756701) or (t.cdcooper = 1 and t.nrdconta = 9756728) or (t.cdcooper = 1 and t.nrdconta = 9755764) or
(t.cdcooper = 1 and t.nrdconta = 2342200) or (t.cdcooper = 1 and t.nrdconta = 7080921) or (t.cdcooper = 1 and t.nrdconta = 9751114) or
(t.cdcooper = 1 and t.nrdconta = 9747346) or (t.cdcooper = 1 and t.nrdconta = 9746161) or (t.cdcooper = 1 and t.nrdconta = 9558144) or
(t.cdcooper = 1 and t.nrdconta = 9738185) or (t.cdcooper = 1 and t.nrdconta = 9739092) or (t.cdcooper = 1 and t.nrdconta = 9735461) or
(t.cdcooper = 1 and t.nrdconta = 9736034) or (t.cdcooper = 1 and t.nrdconta = 7189028) or (t.cdcooper = 1 and t.nrdconta = 9730877) or
(t.cdcooper = 1 and t.nrdconta = 6408087) or (t.cdcooper = 1 and t.nrdconta = 7080239) or (t.cdcooper = 1 and t.nrdconta = 8826943) or
(t.cdcooper = 1 and t.nrdconta = 9725113) or (t.cdcooper = 1 and t.nrdconta = 9725504) or (t.cdcooper = 1 and t.nrdconta = 6664032) or
(t.cdcooper = 1 and t.nrdconta = 1842579) or (t.cdcooper = 1 and t.nrdconta = 7478941) or (t.cdcooper = 1 and t.nrdconta = 7333765) or
(t.cdcooper = 1 and t.nrdconta = 6231152) or (t.cdcooper = 1 and t.nrdconta = 7634773) or (t.cdcooper = 1 and t.nrdconta = 6922520) or
(t.cdcooper = 1 and t.nrdconta = 6217958) or (t.cdcooper = 1 and t.nrdconta = 7608055) or (t.cdcooper = 1 and t.nrdconta = 7265271) or
(t.cdcooper = 1 and t.nrdconta = 80367178) or (t.cdcooper = 1 and t.nrdconta = 9409548) or (t.cdcooper = 1 and t.nrdconta = 8534128) or
(t.cdcooper = 1 and t.nrdconta = 6316026) or (t.cdcooper = 1 and t.nrdconta = 3858871) or (t.cdcooper = 1 and t.nrdconta = 7001991) or
(t.cdcooper = 1 and t.nrdconta = 2170825) or (t.cdcooper = 1 and t.nrdconta = 9579001) or (t.cdcooper = 1 and t.nrdconta = 7978871) or
(t.cdcooper = 1 and t.nrdconta = 7723601) or (t.cdcooper = 1 and t.nrdconta = 6853064) or (t.cdcooper = 1 and t.nrdconta = 8336180) or
(t.cdcooper = 1 and t.nrdconta = 1833634) or (t.cdcooper = 1 and t.nrdconta = 6434711) or (t.cdcooper = 1 and t.nrdconta = 6878725) or
(t.cdcooper = 1 and t.nrdconta = 6137920) or (t.cdcooper = 1 and t.nrdconta = 3941540) or (t.cdcooper = 1 and t.nrdconta = 6744443) or
(t.cdcooper = 1 and t.nrdconta = 2894343) or (t.cdcooper = 1 and t.nrdconta = 6649726) or (t.cdcooper = 1 and t.nrdconta = 6544045) or
(t.cdcooper = 1 and t.nrdconta = 7107390) or (t.cdcooper = 1 and t.nrdconta = 7320833) or (t.cdcooper = 1 and t.nrdconta = 6586503) or
(t.cdcooper = 1 and t.nrdconta = 7451601) or (t.cdcooper = 1 and t.nrdconta = 3622002) or (t.cdcooper = 1 and t.nrdconta = 6371779) or
(t.cdcooper = 1 and t.nrdconta = 7815328) or (t.cdcooper = 1 and t.nrdconta = 7082304) or (t.cdcooper = 1 and t.nrdconta = 7751982) or
(t.cdcooper = 1 and t.nrdconta = 7623569) or (t.cdcooper = 1 and t.nrdconta = 7217366) or (t.cdcooper = 1 and t.nrdconta = 7368097) or
(t.cdcooper = 1 and t.nrdconta = 6018068) or (t.cdcooper = 1 and t.nrdconta = 2627132) or (t.cdcooper = 1 and t.nrdconta = 3011178) or
(t.cdcooper = 1 and t.nrdconta = 2988747) or (t.cdcooper = 1 and t.nrdconta = 6989730) or (t.cdcooper = 1 and t.nrdconta = 8184399) or
(t.cdcooper = 1 and t.nrdconta = 7436696) or (t.cdcooper = 1 and t.nrdconta = 7772700) or (t.cdcooper = 1 and t.nrdconta = 3751074) or
(t.cdcooper = 1 and t.nrdconta = 7593538) or (t.cdcooper = 1 and t.nrdconta = 2702550) or (t.cdcooper = 1 and t.nrdconta = 6438695) or
(t.cdcooper = 1 and t.nrdconta = 7007400) or (t.cdcooper = 1 and t.nrdconta = 8949190) or (t.cdcooper = 1 and t.nrdconta = 3708098) or
(t.cdcooper = 1 and t.nrdconta = 7712057) or (t.cdcooper = 1 and t.nrdconta = 7686900) or (t.cdcooper = 1 and t.nrdconta = 6911668) or
(t.cdcooper = 1 and t.nrdconta = 7829949) or (t.cdcooper = 1 and t.nrdconta = 7409966) or (t.cdcooper = 1 and t.nrdconta = 6017479) or
(t.cdcooper = 1 and t.nrdconta = 2701650) or (t.cdcooper = 1 and t.nrdconta = 6872247) or (t.cdcooper = 1 and t.nrdconta = 3072088) or
(t.cdcooper = 1 and t.nrdconta = 6812880) or (t.cdcooper = 1 and t.nrdconta = 7017944) or (t.cdcooper = 1 and t.nrdconta = 2002914) or
(t.cdcooper = 1 and t.nrdconta = 4038070) or (t.cdcooper = 1 and t.nrdconta = 2363682) or (t.cdcooper = 1 and t.nrdconta = 2305992) or
(t.cdcooper = 1 and t.nrdconta = 7567952) or (t.cdcooper = 1 and t.nrdconta = 7074662) or (t.cdcooper = 1 and t.nrdconta = 6249850) or
(t.cdcooper = 1 and t.nrdconta = 3782794) or (t.cdcooper = 1 and t.nrdconta = 8813213) or (t.cdcooper = 1 and t.nrdconta = 7312725) or
(t.cdcooper = 1 and t.nrdconta = 90053729) or (t.cdcooper = 1 and t.nrdconta = 2455552) or (t.cdcooper = 1 and t.nrdconta = 6963099) or
(t.cdcooper = 1 and t.nrdconta = 977233) or (t.cdcooper = 1 and t.nrdconta = 3025560) or (t.cdcooper = 1 and t.nrdconta = 7120117) or
(t.cdcooper = 1 and t.nrdconta = 2287072) or (t.cdcooper = 1 and t.nrdconta = 6422934) or (t.cdcooper = 1 and t.nrdconta = 6191843) or
(t.cdcooper = 1 and t.nrdconta = 6306152) or (t.cdcooper = 1 and t.nrdconta = 7446918) or (t.cdcooper = 1 and t.nrdconta = 6010830) or
(t.cdcooper = 1 and t.nrdconta = 2881780) or (t.cdcooper = 1 and t.nrdconta = 7114095) or (t.cdcooper = 1 and t.nrdconta = 3572684) or
(t.cdcooper = 1 and t.nrdconta = 7816847) or (t.cdcooper = 1 and t.nrdconta = 7634900) or (t.cdcooper = 1 and t.nrdconta = 7399456) or
(t.cdcooper = 1 and t.nrdconta = 7590768) or (t.cdcooper = 1 and t.nrdconta = 2218666) or (t.cdcooper = 1 and t.nrdconta = 7097859) or
(t.cdcooper = 1 and t.nrdconta = 7002106) or (t.cdcooper = 1 and t.nrdconta = 7488335) or (t.cdcooper = 1 and t.nrdconta = 6459331) or
(t.cdcooper = 1 and t.nrdconta = 7158840) or (t.cdcooper = 1 and t.nrdconta = 7340168) or (t.cdcooper = 1 and t.nrdconta = 7495838) or
(t.cdcooper = 1 and t.nrdconta = 7652038) or (t.cdcooper = 1 and t.nrdconta = 2870851) or (t.cdcooper = 1 and t.nrdconta = 7396910) or
(t.cdcooper = 1 and t.nrdconta = 6824170) or (t.cdcooper = 1 and t.nrdconta = 6071996) or (t.cdcooper = 1 and t.nrdconta = 6626335) or
(t.cdcooper = 1 and t.nrdconta = 7733364) or (t.cdcooper = 1 and t.nrdconta = 7490364) or (t.cdcooper = 1 and t.nrdconta = 3704122) or
(t.cdcooper = 1 and t.nrdconta = 7477589) or (t.cdcooper = 1 and t.nrdconta = 6943152) or (t.cdcooper = 1 and t.nrdconta = 7123566) or
(t.cdcooper = 1 and t.nrdconta = 3608930) or (t.cdcooper = 1 and t.nrdconta = 7658931) or (t.cdcooper = 1 and t.nrdconta = 3061620) or
(t.cdcooper = 1 and t.nrdconta = 751472) or (t.cdcooper = 1 and t.nrdconta = 2374897) or (t.cdcooper = 1 and t.nrdconta = 6605451) or
(t.cdcooper = 1 and t.nrdconta = 7634811) or (t.cdcooper = 1 and t.nrdconta = 7158491) or (t.cdcooper = 1 and t.nrdconta = 7264810) or
(t.cdcooper = 1 and t.nrdconta = 4075226) or (t.cdcooper = 1 and t.nrdconta = 7329474) or (t.cdcooper = 1 and t.nrdconta = 6528350) or
(t.cdcooper = 1 and t.nrdconta = 6936237) or (t.cdcooper = 1 and t.nrdconta = 7452470) or (t.cdcooper = 1 and t.nrdconta = 7738978) or
(t.cdcooper = 1 and t.nrdconta = 2219654) or (t.cdcooper = 1 and t.nrdconta = 7411863) or (t.cdcooper = 1 and t.nrdconta = 7349432) or
(t.cdcooper = 1 and t.nrdconta = 7142510) or (t.cdcooper = 1 and t.nrdconta = 7193971) or (t.cdcooper = 1 and t.nrdconta = 3192296) or
(t.cdcooper = 1 and t.nrdconta = 6207413) or (t.cdcooper = 1 and t.nrdconta = 7700156) or (t.cdcooper = 1 and t.nrdconta = 7229631) or
(t.cdcooper = 1 and t.nrdconta = 7387180) or (t.cdcooper = 1 and t.nrdconta = 7352611) or (t.cdcooper = 1 and t.nrdconta = 6223540) or
(t.cdcooper = 1 and t.nrdconta = 3186997) or (t.cdcooper = 1 and t.nrdconta = 7651112) or (t.cdcooper = 1 and t.nrdconta = 8557519) or
(t.cdcooper = 1 and t.nrdconta = 7381735) or (t.cdcooper = 1 and t.nrdconta = 7609) or (t.cdcooper = 1 and t.nrdconta = 8290) or
(t.cdcooper = 1 and t.nrdconta = 7166141) or (t.cdcooper = 1 and t.nrdconta = 7843682) or (t.cdcooper = 1 and t.nrdconta = 7041721) or
(t.cdcooper = 1 and t.nrdconta = 7185600) or (t.cdcooper = 1 and t.nrdconta = 2709465) or (t.cdcooper = 1 and t.nrdconta = 7308914) or
(t.cdcooper = 1 and t.nrdconta = 3231062) or (t.cdcooper = 1 and t.nrdconta = 7306261) or (t.cdcooper = 1 and t.nrdconta = 7134681) or
(t.cdcooper = 1 and t.nrdconta = 7230303) or (t.cdcooper = 1 and t.nrdconta = 7297718) or (t.cdcooper = 1 and t.nrdconta = 80127070) or
(t.cdcooper = 1 and t.nrdconta = 7219997) or (t.cdcooper = 1 and t.nrdconta = 8431558) or (t.cdcooper = 1 and t.nrdconta = 7050623) or
(t.cdcooper = 1 and t.nrdconta = 6595081) or (t.cdcooper = 1 and t.nrdconta = 7673892) or (t.cdcooper = 1 and t.nrdconta = 3596249) or
(t.cdcooper = 1 and t.nrdconta = 3618870) or (t.cdcooper = 1 and t.nrdconta = 7050950) or (t.cdcooper = 1 and t.nrdconta = 8335087) or
(t.cdcooper = 1 and t.nrdconta = 6886620) or (t.cdcooper = 1 and t.nrdconta = 3179532) or (t.cdcooper = 1 and t.nrdconta = 6963927) or
(t.cdcooper = 1 and t.nrdconta = 7398328) or (t.cdcooper = 1 and t.nrdconta = 7546688) or (t.cdcooper = 1 and t.nrdconta = 6080073) or
(t.cdcooper = 1 and t.nrdconta = 7585632) or (t.cdcooper = 1 and t.nrdconta = 7386354) or (t.cdcooper = 1 and t.nrdconta = 3065790) or
(t.cdcooper = 1 and t.nrdconta = 6860184) or (t.cdcooper = 1 and t.nrdconta = 8151393) or (t.cdcooper = 1 and t.nrdconta = 6053629) or
(t.cdcooper = 1 and t.nrdconta = 6889735) or (t.cdcooper = 1 and t.nrdconta = 6349501) or (t.cdcooper = 1 and t.nrdconta = 6234224) or
(t.cdcooper = 1 and t.nrdconta = 8211426) or (t.cdcooper = 1 and t.nrdconta = 7271441) or (t.cdcooper = 1 and t.nrdconta = 7526598) or
(t.cdcooper = 1 and t.nrdconta = 1853325) or (t.cdcooper = 1 and t.nrdconta = 7997051) or (t.cdcooper = 1 and t.nrdconta = 2441381) or
(t.cdcooper = 1 and t.nrdconta = 7416814) or (t.cdcooper = 1 and t.nrdconta = 6605052) or (t.cdcooper = 1 and t.nrdconta = 6183905) or
(t.cdcooper = 1 and t.nrdconta = 2985730) or (t.cdcooper = 1 and t.nrdconta = 2800527) or (t.cdcooper = 1 and t.nrdconta = 8025355) or
(t.cdcooper = 1 and t.nrdconta = 90263472) or (t.cdcooper = 1 and t.nrdconta = 7490070) or (t.cdcooper = 1 and t.nrdconta = 7119674) or
(t.cdcooper = 1 and t.nrdconta = 794228) or (t.cdcooper = 1 and t.nrdconta = 80420141) or (t.cdcooper = 1 and t.nrdconta = 7265085) or
(t.cdcooper = 1 and t.nrdconta = 7212950) or (t.cdcooper = 1 and t.nrdconta = 6361471) or (t.cdcooper = 1 and t.nrdconta = 2676915) or
(t.cdcooper = 1 and t.nrdconta = 7822286) or (t.cdcooper = 1 and t.nrdconta = 7274904) or (t.cdcooper = 1 and t.nrdconta = 1718029) or
(t.cdcooper = 1 and t.nrdconta = 3218074) or (t.cdcooper = 1 and t.nrdconta = 7408200) or (t.cdcooper = 1 and t.nrdconta = 3180794) or
(t.cdcooper = 1 and t.nrdconta = 3975355) or (t.cdcooper = 1 and t.nrdconta = 6964257) or (t.cdcooper = 1 and t.nrdconta = 2541246) or
(t.cdcooper = 1 and t.nrdconta = 9148167) or (t.cdcooper = 1 and t.nrdconta = 3186733) or (t.cdcooper = 1 and t.nrdconta = 3646920) or
(t.cdcooper = 1 and t.nrdconta = 7038607) or (t.cdcooper = 1 and t.nrdconta = 7412401) or (t.cdcooper = 1 and t.nrdconta = 2659352) or
(t.cdcooper = 1 and t.nrdconta = 7232594) or (t.cdcooper = 1 and t.nrdconta = 2813904) or (t.cdcooper = 1 and t.nrdconta = 7641605) or
(t.cdcooper = 1 and t.nrdconta = 7010672) or (t.cdcooper = 1 and t.nrdconta = 3013880) or (t.cdcooper = 1 and t.nrdconta = 7582650) or
(t.cdcooper = 1 and t.nrdconta = 7393601) or (t.cdcooper = 1 and t.nrdconta = 7138954) or (t.cdcooper = 1 and t.nrdconta = 7452683) or
(t.cdcooper = 1 and t.nrdconta = 7018185) or (t.cdcooper = 1 and t.nrdconta = 7627661) or (t.cdcooper = 1 and t.nrdconta = 7194285) or
(t.cdcooper = 1 and t.nrdconta = 6706444) or (t.cdcooper = 1 and t.nrdconta = 7678711) or (t.cdcooper = 1 and t.nrdconta = 3181391) or
(t.cdcooper = 1 and t.nrdconta = 7027613) or (t.cdcooper = 1 and t.nrdconta = 3159868) or (t.cdcooper = 1 and t.nrdconta = 6808697) or
(t.cdcooper = 1 and t.nrdconta = 6171460) or (t.cdcooper = 1 and t.nrdconta = 6985041) or (t.cdcooper = 1 and t.nrdconta = 6943764) or
(t.cdcooper = 1 and t.nrdconta = 7167920) or (t.cdcooper = 1 and t.nrdconta = 6133665) or (t.cdcooper = 1 and t.nrdconta = 7449402) or
(t.cdcooper = 1 and t.nrdconta = 7502885) or (t.cdcooper = 1 and t.nrdconta = 6541763) or (t.cdcooper = 1 and t.nrdconta = 7273436) or
(t.cdcooper = 1 and t.nrdconta = 7295731) or (t.cdcooper = 1 and t.nrdconta = 7471203) or (t.cdcooper = 1 and t.nrdconta = 9138293) or
(t.cdcooper = 1 and t.nrdconta = 6271308) or (t.cdcooper = 1 and t.nrdconta = 6548423) or (t.cdcooper = 1 and t.nrdconta = 6066194) or
(t.cdcooper = 1 and t.nrdconta = 2287560) or (t.cdcooper = 1 and t.nrdconta = 7591608) or (t.cdcooper = 1 and t.nrdconta = 6565433) or
(t.cdcooper = 1 and t.nrdconta = 6722474) or (t.cdcooper = 1 and t.nrdconta = 6917895) or (t.cdcooper = 1 and t.nrdconta = 6344542) or
(t.cdcooper = 1 and t.nrdconta = 2626004) or (t.cdcooper = 1 and t.nrdconta = 6939562) or (t.cdcooper = 1 and t.nrdconta = 7317395) or
(t.cdcooper = 1 and t.nrdconta = 6845134) or (t.cdcooper = 1 and t.nrdconta = 7161131) or (t.cdcooper = 1 and t.nrdconta = 7211520) or
(t.cdcooper = 1 and t.nrdconta = 7490410) or (t.cdcooper = 1 and t.nrdconta = 3023184) or (t.cdcooper = 1 and t.nrdconta = 6662277) or
(t.cdcooper = 1 and t.nrdconta = 2349078) or (t.cdcooper = 1 and t.nrdconta = 7473389) or (t.cdcooper = 1 and t.nrdconta = 3147320) or
(t.cdcooper = 1 and t.nrdconta = 7437404) or (t.cdcooper = 1 and t.nrdconta = 6445500) or (t.cdcooper = 1 and t.nrdconta = 7350570) or
(t.cdcooper = 1 and t.nrdconta = 7410069) or (t.cdcooper = 1 and t.nrdconta = 80234364) or (t.cdcooper = 1 and t.nrdconta = 7241461) or
(t.cdcooper = 1 and t.nrdconta = 6293557) or (t.cdcooper = 1 and t.nrdconta = 74137433) or (t.cdcooper = 1 and t.nrdconta = 6259308) or
(t.cdcooper = 1 and t.nrdconta = 7396198) or (t.cdcooper = 1 and t.nrdconta = 6344488) or (t.cdcooper = 1 and t.nrdconta = 7117507) or
(t.cdcooper = 1 and t.nrdconta = 7447698) or (t.cdcooper = 1 and t.nrdconta = 1391755) or (t.cdcooper = 1 and t.nrdconta = 7082223) or
(t.cdcooper = 1 and t.nrdconta = 3196720) or (t.cdcooper = 1 and t.nrdconta = 6212751) or (t.cdcooper = 1 and t.nrdconta = 3193659) or
(t.cdcooper = 1 and t.nrdconta = 7412134) or (t.cdcooper = 1 and t.nrdconta = 3601234) or (t.cdcooper = 1 and t.nrdconta = 7173237) or
(t.cdcooper = 1 and t.nrdconta = 7274920) or (t.cdcooper = 1 and t.nrdconta = 7365594) or (t.cdcooper = 1 and t.nrdconta = 7435614) or
(t.cdcooper = 1 and t.nrdconta = 80192335) or (t.cdcooper = 1 and t.nrdconta = 2574284) or (t.cdcooper = 1 and t.nrdconta = 6469795) or
(t.cdcooper = 1 and t.nrdconta = 7219938) or (t.cdcooper = 1 and t.nrdconta = 80410707) or (t.cdcooper = 1 and t.nrdconta = 7159404) or
(t.cdcooper = 1 and t.nrdconta = 1949292) or (t.cdcooper = 1 and t.nrdconta = 3132889) or (t.cdcooper = 1 and t.nrdconta = 80422772) or
(t.cdcooper = 1 and t.nrdconta = 80482490) or (t.cdcooper = 1 and t.nrdconta = 80482988) or (t.cdcooper = 1 and t.nrdconta = 80416039) or
(t.cdcooper = 1 and t.nrdconta = 7023006) or (t.cdcooper = 1 and t.nrdconta = 7097425) or (t.cdcooper = 1 and t.nrdconta = 6359647) or
(t.cdcooper = 1 and t.nrdconta = 7283342) or (t.cdcooper = 1 and t.nrdconta = 80113010) or (t.cdcooper = 1 and t.nrdconta = 80213863) or
(t.cdcooper = 1 and t.nrdconta = 3533646) or (t.cdcooper = 1 and t.nrdconta = 7167849) or (t.cdcooper = 1 and t.nrdconta = 6716628) or
(t.cdcooper = 1 and t.nrdconta = 6949533) or (t.cdcooper = 1 and t.nrdconta = 3736202) or (t.cdcooper = 1 and t.nrdconta = 6975666) or
(t.cdcooper = 1 and t.nrdconta = 80480713) or (t.cdcooper = 1 and t.nrdconta = 3068315) or (t.cdcooper = 1 and t.nrdconta = 80431232) or
(t.cdcooper = 1 and t.nrdconta = 3528014) or (t.cdcooper = 1 and t.nrdconta = 80273300) or (t.cdcooper = 1 and t.nrdconta = 6417469) or
(t.cdcooper = 1 and t.nrdconta = 80494994) or (t.cdcooper = 1 and t.nrdconta = 6145434) or (t.cdcooper = 1 and t.nrdconta = 80212824) or
(t.cdcooper = 1 and t.nrdconta = 6588239) or (t.cdcooper = 1 and t.nrdconta = 80129951) or (t.cdcooper = 1 and t.nrdconta = 7193700) or
(t.cdcooper = 1 and t.nrdconta = 2299429) or (t.cdcooper = 1 and t.nrdconta = 6596053) or (t.cdcooper = 1 and t.nrdconta = 6244521) or
(t.cdcooper = 1 and t.nrdconta = 80438466) or (t.cdcooper = 1 and t.nrdconta = 80245510) or (t.cdcooper = 1 and t.nrdconta = 7158548) or
(t.cdcooper = 1 and t.nrdconta = 7079559) or (t.cdcooper = 1 and t.nrdconta = 7106572) or (t.cdcooper = 1 and t.nrdconta = 80333630) or
(t.cdcooper = 1 and t.nrdconta = 1939360) or (t.cdcooper = 1 and t.nrdconta = 3583058) or (t.cdcooper = 1 and t.nrdconta = 6926967) or
(t.cdcooper = 1 and t.nrdconta = 6182437) or (t.cdcooper = 1 and t.nrdconta = 3050025) or (t.cdcooper = 1 and t.nrdconta = 3868990) or
(t.cdcooper = 1 and t.nrdconta = 2475065) or (t.cdcooper = 1 and t.nrdconta = 3656241) or (t.cdcooper = 1 and t.nrdconta = 6358373) or
(t.cdcooper = 1 and t.nrdconta = 6618510) or (t.cdcooper = 1 and t.nrdconta = 6328237) or (t.cdcooper = 1 and t.nrdconta = 6373240) or
(t.cdcooper = 1 and t.nrdconta = 3706460) or (t.cdcooper = 1 and t.nrdconta = 9119124) or (t.cdcooper = 1 and t.nrdconta = 769231) or
(t.cdcooper = 1 and t.nrdconta = 1938207) or (t.cdcooper = 1 and t.nrdconta = 2216167) or (t.cdcooper = 1 and t.nrdconta = 3523349) or
(t.cdcooper = 1 and t.nrdconta = 845540) or (t.cdcooper = 1 and t.nrdconta = 6270719) or (t.cdcooper = 1 and t.nrdconta = 2164930) or
(t.cdcooper = 1 and t.nrdconta = 6577172) or (t.cdcooper = 1 and t.nrdconta = 6909132) or (t.cdcooper = 1 and t.nrdconta = 80328849) or
(t.cdcooper = 1 and t.nrdconta = 6223990) or (t.cdcooper = 1 and t.nrdconta = 6390153) or (t.cdcooper = 1 and t.nrdconta = 6956912) or
(t.cdcooper = 1 and t.nrdconta = 6916210) or (t.cdcooper = 1 and t.nrdconta = 80326030) or (t.cdcooper = 1 and t.nrdconta = 6183034) or
(t.cdcooper = 1 and t.nrdconta = 6423450) or (t.cdcooper = 1 and t.nrdconta = 6525164) or (t.cdcooper = 1 and t.nrdconta = 6604641) or
(t.cdcooper = 1 and t.nrdconta = 6852840) or (t.cdcooper = 1 and t.nrdconta = 6862900) or (t.cdcooper = 1 and t.nrdconta = 3913562) or
(t.cdcooper = 1 and t.nrdconta = 6387845) or (t.cdcooper = 1 and t.nrdconta = 2478218) or (t.cdcooper = 1 and t.nrdconta = 3961915) or
(t.cdcooper = 1 and t.nrdconta = 3910342) or (t.cdcooper = 1 and t.nrdconta = 6170153) or (t.cdcooper = 1 and t.nrdconta = 7038321) or
(t.cdcooper = 1 and t.nrdconta = 1868969) or (t.cdcooper = 1 and t.nrdconta = 6236987) or (t.cdcooper = 1 and t.nrdconta = 2490161) or
(t.cdcooper = 1 and t.nrdconta = 3897281) or (t.cdcooper = 1 and t.nrdconta = 6472699) or (t.cdcooper = 1 and t.nrdconta = 6821898) or
(t.cdcooper = 1 and t.nrdconta = 6895590) or (t.cdcooper = 1 and t.nrdconta = 6696031) or (t.cdcooper = 1 and t.nrdconta = 2879611) or
(t.cdcooper = 1 and t.nrdconta = 3912833) or (t.cdcooper = 1 and t.nrdconta = 6277411) or (t.cdcooper = 1 and t.nrdconta = 6513816) or
(t.cdcooper = 1 and t.nrdconta = 6981860) or (t.cdcooper = 1 and t.nrdconta = 6824366) or (t.cdcooper = 1 and t.nrdconta = 6939805) or
(t.cdcooper = 1 and t.nrdconta = 6817564) or (t.cdcooper = 1 and t.nrdconta = 6931596) or (t.cdcooper = 1 and t.nrdconta = 90076524) or
(t.cdcooper = 1 and t.nrdconta = 3915905) or (t.cdcooper = 1 and t.nrdconta = 6494285) or (t.cdcooper = 1 and t.nrdconta = 6861792) or
(t.cdcooper = 1 and t.nrdconta = 7027800) or (t.cdcooper = 1 and t.nrdconta = 3837734) or (t.cdcooper = 1 and t.nrdconta = 6434843) or
(t.cdcooper = 1 and t.nrdconta = 6711634) or (t.cdcooper = 1 and t.nrdconta = 6914071) or (t.cdcooper = 1 and t.nrdconta = 3757080) or
(t.cdcooper = 1 and t.nrdconta = 2384370) or (t.cdcooper = 1 and t.nrdconta = 6617786) or (t.cdcooper = 1 and t.nrdconta = 6604579) or
(t.cdcooper = 1 and t.nrdconta = 2702940) or (t.cdcooper = 1 and t.nrdconta = 6840817) or (t.cdcooper = 1 and t.nrdconta = 6939635) or
(t.cdcooper = 1 and t.nrdconta = 2295539) or (t.cdcooper = 1 and t.nrdconta = 2937042) or (t.cdcooper = 1 and t.nrdconta = 3072053) or
(t.cdcooper = 1 and t.nrdconta = 6731147) or (t.cdcooper = 1 and t.nrdconta = 6743820) or (t.cdcooper = 1 and t.nrdconta = 2452863) or
(t.cdcooper = 1 and t.nrdconta = 6225365) or (t.cdcooper = 1 and t.nrdconta = 6697518) or (t.cdcooper = 1 and t.nrdconta = 2535114) or
(t.cdcooper = 1 and t.nrdconta = 3825655) or (t.cdcooper = 1 and t.nrdconta = 6303323) or (t.cdcooper = 1 and t.nrdconta = 1714600) or
(t.cdcooper = 1 and t.nrdconta = 80480993) or (t.cdcooper = 1 and t.nrdconta = 90162773) or (t.cdcooper = 1 and t.nrdconta = 6649084) or
(t.cdcooper = 1 and t.nrdconta = 6822045) or (t.cdcooper = 1 and t.nrdconta = 2606070) or (t.cdcooper = 1 and t.nrdconta = 2769760) or
(t.cdcooper = 1 and t.nrdconta = 6367550) or (t.cdcooper = 1 and t.nrdconta = 6486053) or (t.cdcooper = 1 and t.nrdconta = 2529505) or
(t.cdcooper = 1 and t.nrdconta = 80175953) or (t.cdcooper = 1 and t.nrdconta = 80367909) or (t.cdcooper = 1 and t.nrdconta = 2005727) or
(t.cdcooper = 1 and t.nrdconta = 6846319) or (t.cdcooper = 1 and t.nrdconta = 6422306) or (t.cdcooper = 1 and t.nrdconta = 6583750) or
(t.cdcooper = 1 and t.nrdconta = 6723802) or (t.cdcooper = 1 and t.nrdconta = 6435530) or (t.cdcooper = 1 and t.nrdconta = 2323940) or
(t.cdcooper = 1 and t.nrdconta = 2616580) or (t.cdcooper = 1 and t.nrdconta = 2845350) or (t.cdcooper = 1 and t.nrdconta = 3878422) or
(t.cdcooper = 1 and t.nrdconta = 2772337) or (t.cdcooper = 1 and t.nrdconta = 3806197) or (t.cdcooper = 1 and t.nrdconta = 3871711) or
(t.cdcooper = 1 and t.nrdconta = 2562472) or (t.cdcooper = 1 and t.nrdconta = 3830446) or (t.cdcooper = 1 and t.nrdconta = 3936708) or
(t.cdcooper = 1 and t.nrdconta = 6481540) or (t.cdcooper = 1 and t.nrdconta = 6588085) or (t.cdcooper = 1 and t.nrdconta = 2920816) or
(t.cdcooper = 1 and t.nrdconta = 2864290) or (t.cdcooper = 1 and t.nrdconta = 6758584) or (t.cdcooper = 1 and t.nrdconta = 6937276) or
(t.cdcooper = 1 and t.nrdconta = 6888437) or (t.cdcooper = 1 and t.nrdconta = 6726259) or (t.cdcooper = 1 and t.nrdconta = 2440083) or
(t.cdcooper = 1 and t.nrdconta = 2584662) or (t.cdcooper = 1 and t.nrdconta = 3755568) or (t.cdcooper = 1 and t.nrdconta = 6851029) or
(t.cdcooper = 1 and t.nrdconta = 6905730) or (t.cdcooper = 1 and t.nrdconta = 6668585) or (t.cdcooper = 1 and t.nrdconta = 2545705) or
(t.cdcooper = 1 and t.nrdconta = 2556022) or (t.cdcooper = 1 and t.nrdconta = 6195857) or (t.cdcooper = 1 and t.nrdconta = 3651398) or
(t.cdcooper = 1 and t.nrdconta = 6872999) or (t.cdcooper = 1 and t.nrdconta = 2308916) or (t.cdcooper = 1 and t.nrdconta = 6289738) or
(t.cdcooper = 1 and t.nrdconta = 6134750) or (t.cdcooper = 1 and t.nrdconta = 2194678) or (t.cdcooper = 1 and t.nrdconta = 2212030) or
(t.cdcooper = 1 and t.nrdconta = 6163394) or (t.cdcooper = 1 and t.nrdconta = 6861997) or (t.cdcooper = 1 and t.nrdconta = 6699766) or
(t.cdcooper = 1 and t.nrdconta = 2918935) or (t.cdcooper = 1 and t.nrdconta = 6259553) or (t.cdcooper = 1 and t.nrdconta = 6729754) or
(t.cdcooper = 1 and t.nrdconta = 2582511) or (t.cdcooper = 1 and t.nrdconta = 3581039) or (t.cdcooper = 1 and t.nrdconta = 3139697) or
(t.cdcooper = 1 and t.nrdconta = 1253735) or (t.cdcooper = 1 and t.nrdconta = 3041050) or (t.cdcooper = 1 and t.nrdconta = 6323014) or
(t.cdcooper = 1 and t.nrdconta = 3607194) or (t.cdcooper = 1 and t.nrdconta = 6224652) or (t.cdcooper = 1 and t.nrdconta = 6316085) or
(t.cdcooper = 1 and t.nrdconta = 2988089) or (t.cdcooper = 1 and t.nrdconta = 3742067) or (t.cdcooper = 1 and t.nrdconta = 6128840) or
(t.cdcooper = 1 and t.nrdconta = 3888916) or (t.cdcooper = 1 and t.nrdconta = 6589162) or (t.cdcooper = 1 and t.nrdconta = 3675777) or
(t.cdcooper = 1 and t.nrdconta = 6642489) or (t.cdcooper = 1 and t.nrdconta = 6214584) or (t.cdcooper = 1 and t.nrdconta = 6642730) or
(t.cdcooper = 1 and t.nrdconta = 6061206) or (t.cdcooper = 1 and t.nrdconta = 3530477) or (t.cdcooper = 1 and t.nrdconta = 6725880) or
(t.cdcooper = 1 and t.nrdconta = 882259) or (t.cdcooper = 1 and t.nrdconta = 2036657) or (t.cdcooper = 1 and t.nrdconta = 2131668) or
(t.cdcooper = 1 and t.nrdconta = 2142180) or (t.cdcooper = 1 and t.nrdconta = 2178583) or (t.cdcooper = 1 and t.nrdconta = 2284189) or
(t.cdcooper = 1 and t.nrdconta = 2345501) or (t.cdcooper = 1 and t.nrdconta = 2376091) or (t.cdcooper = 1 and t.nrdconta = 2402335) or
(t.cdcooper = 1 and t.nrdconta = 2767040) or (t.cdcooper = 1 and t.nrdconta = 2958015) or (t.cdcooper = 1 and t.nrdconta = 3611140) or
(t.cdcooper = 1 and t.nrdconta = 3675670) or (t.cdcooper = 1 and t.nrdconta = 3677796) or (t.cdcooper = 1 and t.nrdconta = 3679900) or
(t.cdcooper = 1 and t.nrdconta = 3835936) or (t.cdcooper = 1 and t.nrdconta = 3900908) or (t.cdcooper = 1 and t.nrdconta = 3986179) or
(t.cdcooper = 1 and t.nrdconta = 6060722) or (t.cdcooper = 1 and t.nrdconta = 6076238) or (t.cdcooper = 1 and t.nrdconta = 6096867) or
(t.cdcooper = 1 and t.nrdconta = 6156568) or (t.cdcooper = 1 and t.nrdconta = 6157971) or (t.cdcooper = 1 and t.nrdconta = 6158501) or
(t.cdcooper = 1 and t.nrdconta = 6255442) or (t.cdcooper = 1 and t.nrdconta = 6268714) or (t.cdcooper = 1 and t.nrdconta = 6370160) or
(t.cdcooper = 1 and t.nrdconta = 6399983) or (t.cdcooper = 1 and t.nrdconta = 6468390) or (t.cdcooper = 1 and t.nrdconta = 6520510) or
(t.cdcooper = 1 and t.nrdconta = 6520715) or (t.cdcooper = 1 and t.nrdconta = 6553346) or (t.cdcooper = 1 and t.nrdconta = 6554725) or
(t.cdcooper = 1 and t.nrdconta = 6555225) or (t.cdcooper = 1 and t.nrdconta = 6555403) or (t.cdcooper = 1 and t.nrdconta = 6597505) or
(t.cdcooper = 1 and t.nrdconta = 6597599) or (t.cdcooper = 1 and t.nrdconta = 6597696) or (t.cdcooper = 1 and t.nrdconta = 6641482) or
(t.cdcooper = 1 and t.nrdconta = 6641628) or (t.cdcooper = 1 and t.nrdconta = 6642667) or (t.cdcooper = 1 and t.nrdconta = 2347121) or
(t.cdcooper = 1 and t.nrdconta = 6685722) or (t.cdcooper = 1 and t.nrdconta = 6709664) or (t.cdcooper = 1 and t.nrdconta = 6051308) or
(t.cdcooper = 1 and t.nrdconta = 6494668) or (t.cdcooper = 1 and t.nrdconta = 6359418) or (t.cdcooper = 1 and t.nrdconta = 6556256) or
(t.cdcooper = 1 and t.nrdconta = 80430775) or (t.cdcooper = 1 and t.nrdconta = 6633323) or (t.cdcooper = 1 and t.nrdconta = 6019978) or
(t.cdcooper = 1 and t.nrdconta = 6243746) or (t.cdcooper = 1 and t.nrdconta = 6775292) or (t.cdcooper = 1 and t.nrdconta = 3098630) or
(t.cdcooper = 1 and t.nrdconta = 90224043) or (t.cdcooper = 1 and t.nrdconta = 90262743) or (t.cdcooper = 1 and t.nrdconta = 2933179) or
(t.cdcooper = 1 and t.nrdconta = 3940136) or (t.cdcooper = 1 and t.nrdconta = 6084230) or (t.cdcooper = 1 and t.nrdconta = 90222440) or
(t.cdcooper = 1 and t.nrdconta = 90222946) or (t.cdcooper = 1 and t.nrdconta = 90223624) or (t.cdcooper = 1 and t.nrdconta = 90223640) or
(t.cdcooper = 1 and t.nrdconta = 2759578) or (t.cdcooper = 1 and t.nrdconta = 6545238) or (t.cdcooper = 1 and t.nrdconta = 3964183) or
(t.cdcooper = 1 and t.nrdconta = 2935716) or (t.cdcooper = 1 and t.nrdconta = 3615839) or (t.cdcooper = 1 and t.nrdconta = 6357377) or
(t.cdcooper = 1 and t.nrdconta = 6234062) or (t.cdcooper = 1 and t.nrdconta = 3636941) or (t.cdcooper = 1 and t.nrdconta = 6100805) or
(t.cdcooper = 1 and t.nrdconta = 80415660) or (t.cdcooper = 1 and t.nrdconta = 2214660) or (t.cdcooper = 1 and t.nrdconta = 90260716) or
(t.cdcooper = 1 and t.nrdconta = 6368883) or (t.cdcooper = 1 and t.nrdconta = 6139973) or (t.cdcooper = 1 and t.nrdconta = 2615940) or
(t.cdcooper = 1 and t.nrdconta = 2612054) or (t.cdcooper = 1 and t.nrdconta = 6311431) or (t.cdcooper = 1 and t.nrdconta = 6428614) or
(t.cdcooper = 1 and t.nrdconta = 2233290) or (t.cdcooper = 1 and t.nrdconta = 6628168) or (t.cdcooper = 1 and t.nrdconta = 2780208) or
(t.cdcooper = 1 and t.nrdconta = 3167216) or (t.cdcooper = 1 and t.nrdconta = 3640680) or (t.cdcooper = 1 and t.nrdconta = 6573142) or
(t.cdcooper = 1 and t.nrdconta = 2010224) or (t.cdcooper = 1 and t.nrdconta = 2866471) or (t.cdcooper = 1 and t.nrdconta = 3997669) or
(t.cdcooper = 1 and t.nrdconta = 3163296) or (t.cdcooper = 1 and t.nrdconta = 3856291) or (t.cdcooper = 1 and t.nrdconta = 80066526) or
(t.cdcooper = 1 and t.nrdconta = 6351727) or (t.cdcooper = 1 and t.nrdconta = 6579310) or (t.cdcooper = 1 and t.nrdconta = 90264541) or
(t.cdcooper = 1 and t.nrdconta = 6639232) or (t.cdcooper = 1 and t.nrdconta = 6448062) or (t.cdcooper = 1 and t.nrdconta = 6493033) or
(t.cdcooper = 1 and t.nrdconta = 6250041) or (t.cdcooper = 1 and t.nrdconta = 6349471) or (t.cdcooper = 1 and t.nrdconta = 6494587) or
(t.cdcooper = 1 and t.nrdconta = 6267742) or (t.cdcooper = 1 and t.nrdconta = 2617927) or (t.cdcooper = 1 and t.nrdconta = 6308090) or
(t.cdcooper = 1 and t.nrdconta = 6595707) or (t.cdcooper = 1 and t.nrdconta = 2184265) or (t.cdcooper = 1 and t.nrdconta = 2763443) or
(t.cdcooper = 1 and t.nrdconta = 6357806) or (t.cdcooper = 1 and t.nrdconta = 3505197) or (t.cdcooper = 1 and t.nrdconta = 3805573) or
(t.cdcooper = 1 and t.nrdconta = 3997510) or (t.cdcooper = 1 and t.nrdconta = 2995590) or (t.cdcooper = 1 and t.nrdconta = 6555373) or
(t.cdcooper = 1 and t.nrdconta = 2644835) or (t.cdcooper = 1 and t.nrdconta = 6280056) or (t.cdcooper = 1 and t.nrdconta = 6507514) or
(t.cdcooper = 1 and t.nrdconta = 6449131) or (t.cdcooper = 1 and t.nrdconta = 6027113) or (t.cdcooper = 1 and t.nrdconta = 6267530) or
(t.cdcooper = 1 and t.nrdconta = 2925923) or (t.cdcooper = 1 and t.nrdconta = 3554198) or (t.cdcooper = 1 and t.nrdconta = 6151574) or
(t.cdcooper = 1 and t.nrdconta = 6500374) or (t.cdcooper = 1 and t.nrdconta = 2335646) or (t.cdcooper = 1 and t.nrdconta = 3888193) or
(t.cdcooper = 1 and t.nrdconta = 6387160) or (t.cdcooper = 1 and t.nrdconta = 6141099) or (t.cdcooper = 1 and t.nrdconta = 80364640) or
(t.cdcooper = 1 and t.nrdconta = 2780526) or (t.cdcooper = 1 and t.nrdconta = 6131123) or (t.cdcooper = 1 and t.nrdconta = 6410308) or
(t.cdcooper = 1 and t.nrdconta = 90264886) or (t.cdcooper = 1 and t.nrdconta = 6057721) or (t.cdcooper = 1 and t.nrdconta = 3924092) or
(t.cdcooper = 1 and t.nrdconta = 80338410) or (t.cdcooper = 1 and t.nrdconta = 2308231) or (t.cdcooper = 1 and t.nrdconta = 6364012) or
(t.cdcooper = 1 and t.nrdconta = 6207669) or (t.cdcooper = 1 and t.nrdconta = 3040780) or (t.cdcooper = 1 and t.nrdconta = 6174361) or
(t.cdcooper = 1 and t.nrdconta = 6234941) or (t.cdcooper = 1 and t.nrdconta = 3552845) or (t.cdcooper = 1 and t.nrdconta = 90265220) or
(t.cdcooper = 1 and t.nrdconta = 2423456) or (t.cdcooper = 1 and t.nrdconta = 6093680) or (t.cdcooper = 1 and t.nrdconta = 9117083) or
(t.cdcooper = 1 and t.nrdconta = 1999753) or (t.cdcooper = 1 and t.nrdconta = 6357784) or (t.cdcooper = 1 and t.nrdconta = 90160797) or
(t.cdcooper = 1 and t.nrdconta = 2679809) or (t.cdcooper = 1 and t.nrdconta = 3698009) or (t.cdcooper = 1 and t.nrdconta = 3724409) or
(t.cdcooper = 1 and t.nrdconta = 2675781) or (t.cdcooper = 1 and t.nrdconta = 90123409) or (t.cdcooper = 1 and t.nrdconta = 90262921) or
(t.cdcooper = 1 and t.nrdconta = 2199980) or (t.cdcooper = 1 and t.nrdconta = 90265963) or (t.cdcooper = 1 and t.nrdconta = 2405245) or
(t.cdcooper = 1 and t.nrdconta = 2591103) or (t.cdcooper = 1 and t.nrdconta = 2673231) or (t.cdcooper = 1 and t.nrdconta = 3013464) or
(t.cdcooper = 1 and t.nrdconta = 3686493) or (t.cdcooper = 1 and t.nrdconta = 3718310) or (t.cdcooper = 1 and t.nrdconta = 3823601) or
(t.cdcooper = 1 and t.nrdconta = 3956385) or (t.cdcooper = 1 and t.nrdconta = 3958124) or (t.cdcooper = 1 and t.nrdconta = 6074367) or
(t.cdcooper = 1 and t.nrdconta = 6271847) or (t.cdcooper = 1 and t.nrdconta = 90054261) or (t.cdcooper = 1 and t.nrdconta = 90074904) or
(t.cdcooper = 1 and t.nrdconta = 90262565) or (t.cdcooper = 1 and t.nrdconta = 90264070) or (t.cdcooper = 1 and t.nrdconta = 80242286) or
(t.cdcooper = 1 and t.nrdconta = 6213189) or (t.cdcooper = 1 and t.nrdconta = 90224540) or (t.cdcooper = 1 and t.nrdconta = 3790142) or
(t.cdcooper = 1 and t.nrdconta = 2436450) or (t.cdcooper = 1 and t.nrdconta = 3725383) or (t.cdcooper = 1 and t.nrdconta = 3817814) or
(t.cdcooper = 1 and t.nrdconta = 90167937) or (t.cdcooper = 1 and t.nrdconta = 90223349) or (t.cdcooper = 1 and t.nrdconta = 3064204) or
(t.cdcooper = 1 and t.nrdconta = 90266498) or (t.cdcooper = 1 and t.nrdconta = 90169425) or (t.cdcooper = 1 and t.nrdconta = 3081184) or
(t.cdcooper = 1 and t.nrdconta = 90123395) or (t.cdcooper = 1 and t.nrdconta = 90221761) or (t.cdcooper = 1 and t.nrdconta = 3094103) or
(t.cdcooper = 1 and t.nrdconta = 3938590) or (t.cdcooper = 1 and t.nrdconta = 2873184) or (t.cdcooper = 1 and t.nrdconta = 3035956) or
(t.cdcooper = 1 and t.nrdconta = 6199755) or (t.cdcooper = 1 and t.nrdconta = 6213464) or (t.cdcooper = 1 and t.nrdconta = 3857077) or
(t.cdcooper = 1 and t.nrdconta = 90261062) or (t.cdcooper = 1 and t.nrdconta = 3818063) or (t.cdcooper = 1 and t.nrdconta = 90162285) or
(t.cdcooper = 1 and t.nrdconta = 6134602) or (t.cdcooper = 1 and t.nrdconta = 3588335) or (t.cdcooper = 1 and t.nrdconta = 3980952) or
(t.cdcooper = 1 and t.nrdconta = 2184222) or (t.cdcooper = 1 and t.nrdconta = 3637131) or (t.cdcooper = 1 and t.nrdconta = 6178529) or
(t.cdcooper = 1 and t.nrdconta = 3840441) or (t.cdcooper = 1 and t.nrdconta = 6074553) or (t.cdcooper = 1 and t.nrdconta = 2570599) or
(t.cdcooper = 1 and t.nrdconta = 90265238) or (t.cdcooper = 1 and t.nrdconta = 6226663) or (t.cdcooper = 1 and t.nrdconta = 3834760) or
(t.cdcooper = 1 and t.nrdconta = 2850770) or (t.cdcooper = 1 and t.nrdconta = 6128904) or (t.cdcooper = 1 and t.nrdconta = 2526611) or
(t.cdcooper = 1 and t.nrdconta = 3718760) or (t.cdcooper = 1 and t.nrdconta = 90260147) or (t.cdcooper = 1 and t.nrdconta = 2202859) or
(t.cdcooper = 1 and t.nrdconta = 2862522) or (t.cdcooper = 1 and t.nrdconta = 90169573) or (t.cdcooper = 1 and t.nrdconta = 2908352) or
(t.cdcooper = 1 and t.nrdconta = 3975452) or (t.cdcooper = 1 and t.nrdconta = 612260) or (t.cdcooper = 1 and t.nrdconta = 3912477) or
(t.cdcooper = 1 and t.nrdconta = 6066127) or (t.cdcooper = 1 and t.nrdconta = 3870944) or (t.cdcooper = 1 and t.nrdconta = 3969240) or
(t.cdcooper = 1 and t.nrdconta = 6054471) or (t.cdcooper = 1 and t.nrdconta = 6000142) or (t.cdcooper = 1 and t.nrdconta = 90222539) or
(t.cdcooper = 1 and t.nrdconta = 3506193) or (t.cdcooper = 1 and t.nrdconta = 2476967) or (t.cdcooper = 1 and t.nrdconta = 3706273) or
(t.cdcooper = 1 and t.nrdconta = 3774350) or (t.cdcooper = 1 and t.nrdconta = 6016464) or (t.cdcooper = 1 and t.nrdconta = 3073777) or
(t.cdcooper = 1 and t.nrdconta = 3512681) or (t.cdcooper = 1 and t.nrdconta = 90079051) or (t.cdcooper = 1 and t.nrdconta = 2217597) or
(t.cdcooper = 1 and t.nrdconta = 3646360) or (t.cdcooper = 1 and t.nrdconta = 3966623) or (t.cdcooper = 1 and t.nrdconta = 90223136) or
(t.cdcooper = 1 and t.nrdconta = 3612864) or (t.cdcooper = 1 and t.nrdconta = 3895106) or (t.cdcooper = 1 and t.nrdconta = 2691787) or
(t.cdcooper = 1 and t.nrdconta = 3021394) or (t.cdcooper = 1 and t.nrdconta = 2416913) or (t.cdcooper = 1 and t.nrdconta = 2533227) or
(t.cdcooper = 1 and t.nrdconta = 9133313) or (t.cdcooper = 1 and t.nrdconta = 2131730) or (t.cdcooper = 1 and t.nrdconta = 2264765) or
(t.cdcooper = 1 and t.nrdconta = 2266032) or (t.cdcooper = 1 and t.nrdconta = 2358212) or (t.cdcooper = 1 and t.nrdconta = 2993155) or
(t.cdcooper = 1 and t.nrdconta = 2981661) or (t.cdcooper = 1 and t.nrdconta = 3679861) or (t.cdcooper = 1 and t.nrdconta = 3818403) or
(t.cdcooper = 1 and t.nrdconta = 2493454) or (t.cdcooper = 1 and t.nrdconta = 2889820) or (t.cdcooper = 1 and t.nrdconta = 6019145) or
(t.cdcooper = 1 and t.nrdconta = 3877990) or (t.cdcooper = 1 and t.nrdconta = 6060323) or (t.cdcooper = 1 and t.nrdconta = 1896172) or
(t.cdcooper = 1 and t.nrdconta = 3905632) or (t.cdcooper = 1 and t.nrdconta = 90221427) or (t.cdcooper = 1 and t.nrdconta = 3823237) or
(t.cdcooper = 1 and t.nrdconta = 2391163) or (t.cdcooper = 1 and t.nrdconta = 2931583) or (t.cdcooper = 1 and t.nrdconta = 3754855) or
(t.cdcooper = 1 and t.nrdconta = 3815544) or (t.cdcooper = 1 and t.nrdconta = 3857085) or (t.cdcooper = 1 and t.nrdconta = 90123549) or
(t.cdcooper = 1 and t.nrdconta = 90222504) or (t.cdcooper = 1 and t.nrdconta = 90260872) or (t.cdcooper = 1 and t.nrdconta = 90051912) or
(t.cdcooper = 1 and t.nrdconta = 90136608) or (t.cdcooper = 1 and t.nrdconta = 90223209) or (t.cdcooper = 1 and t.nrdconta = 90262450) or
(t.cdcooper = 1 and t.nrdconta = 90262832) or (t.cdcooper = 1 and t.nrdconta = 90269632) or (t.cdcooper = 1 and t.nrdconta = 90166639) or
(t.cdcooper = 1 and t.nrdconta = 90167759) or (t.cdcooper = 1 and t.nrdconta = 2582961) or (t.cdcooper = 1 and t.nrdconta = 3678350) or
(t.cdcooper = 1 and t.nrdconta = 3769682) or (t.cdcooper = 1 and t.nrdconta = 3841138) or (t.cdcooper = 1 and t.nrdconta = 2960214) or
(t.cdcooper = 1 and t.nrdconta = 3943801) or (t.cdcooper = 1 and t.nrdconta = 90262360) or (t.cdcooper = 1 and t.nrdconta = 6205410) or
(t.cdcooper = 1 and t.nrdconta = 2723417) or (t.cdcooper = 1 and t.nrdconta = 2773953) or (t.cdcooper = 1 and t.nrdconta = 2888580) or
(t.cdcooper = 1 and t.nrdconta = 2222957) or (t.cdcooper = 1 and t.nrdconta = 2484242) or (t.cdcooper = 1 and t.nrdconta = 2798247) or
(t.cdcooper = 1 and t.nrdconta = 2798409) or (t.cdcooper = 1 and t.nrdconta = 2914115) or (t.cdcooper = 1 and t.nrdconta = 2148625) or
(t.cdcooper = 1 and t.nrdconta = 2696142) or (t.cdcooper = 1 and t.nrdconta = 2810190) or (t.cdcooper = 1 and t.nrdconta = 3563073) or
(t.cdcooper = 1 and t.nrdconta = 3882322) or (t.cdcooper = 1 and t.nrdconta = 6162673) or (t.cdcooper = 1 and t.nrdconta = 2658259) or
(t.cdcooper = 1 and t.nrdconta = 3783510) or (t.cdcooper = 1 and t.nrdconta = 6007090) or (t.cdcooper = 1 and t.nrdconta = 2156768) or
(t.cdcooper = 1 and t.nrdconta = 90079884) or (t.cdcooper = 1 and t.nrdconta = 2705893) or (t.cdcooper = 1 and t.nrdconta = 3577287) or
(t.cdcooper = 1 and t.nrdconta = 90168500) or (t.cdcooper = 1 and t.nrdconta = 90167716) or (t.cdcooper = 1 and t.nrdconta = 3158217) or
(t.cdcooper = 1 and t.nrdconta = 6064418) or (t.cdcooper = 1 and t.nrdconta = 6151418) or (t.cdcooper = 1 and t.nrdconta = 90265416) or
(t.cdcooper = 1 and t.nrdconta = 2946424) or (t.cdcooper = 1 and t.nrdconta = 2270374) or (t.cdcooper = 1 and t.nrdconta = 3699307) or
(t.cdcooper = 1 and t.nrdconta = 2318024) or (t.cdcooper = 1 and t.nrdconta = 3029867) or (t.cdcooper = 1 and t.nrdconta = 2526000) or
(t.cdcooper = 1 and t.nrdconta = 2654962) or (t.cdcooper = 1 and t.nrdconta = 3042278) or (t.cdcooper = 1 and t.nrdconta = 3645240) or
(t.cdcooper = 1 and t.nrdconta = 4994264) or (t.cdcooper = 1 and t.nrdconta = 3518698) or (t.cdcooper = 1 and t.nrdconta = 90163419) or
(t.cdcooper = 1 and t.nrdconta = 2203324) or (t.cdcooper = 1 and t.nrdconta = 3879356) or (t.cdcooper = 1 and t.nrdconta = 90070569) or
(t.cdcooper = 1 and t.nrdconta = 2440580) or (t.cdcooper = 1 and t.nrdconta = 2682265) or (t.cdcooper = 1 and t.nrdconta = 3912876) or
(t.cdcooper = 1 and t.nrdconta = 2447088) or (t.cdcooper = 1 and t.nrdconta = 90168968) or (t.cdcooper = 1 and t.nrdconta = 6034721) or
(t.cdcooper = 1 and t.nrdconta = 3877752) or (t.cdcooper = 1 and t.nrdconta = 3854922) or (t.cdcooper = 1 and t.nrdconta = 2036401) or
(t.cdcooper = 1 and t.nrdconta = 90222709) or (t.cdcooper = 1 and t.nrdconta = 6045472) or (t.cdcooper = 1 and t.nrdconta = 6075100) or
(t.cdcooper = 1 and t.nrdconta = 3987965) or (t.cdcooper = 1 and t.nrdconta = 3557057) or (t.cdcooper = 1 and t.nrdconta = 2348080) or
(t.cdcooper = 1 and t.nrdconta = 3735885) or (t.cdcooper = 1 and t.nrdconta = 90162978) or (t.cdcooper = 1 and t.nrdconta = 2873354) or
(t.cdcooper = 1 and t.nrdconta = 90260244) or (t.cdcooper = 1 and t.nrdconta = 764221) or (t.cdcooper = 1 and t.nrdconta = 90164628) or
(t.cdcooper = 1 and t.nrdconta = 3963489) or (t.cdcooper = 1 and t.nrdconta = 3966674) or (t.cdcooper = 1 and t.nrdconta = 2295121) or
(t.cdcooper = 1 and t.nrdconta = 3989917) or (t.cdcooper = 1 and t.nrdconta = 90265882) or (t.cdcooper = 1 and t.nrdconta = 90261445) or
(t.cdcooper = 1 and t.nrdconta = 3834654) or (t.cdcooper = 1 and t.nrdconta = 90166680) or (t.cdcooper = 1 and t.nrdconta = 3926206) or
(t.cdcooper = 1 and t.nrdconta = 3707288) or (t.cdcooper = 1 and t.nrdconta = 90224493) or (t.cdcooper = 1 and t.nrdconta = 90136225) or
(t.cdcooper = 1 and t.nrdconta = 90221672) or (t.cdcooper = 1 and t.nrdconta = 90078330) or (t.cdcooper = 1 and t.nrdconta = 90264924) or
(t.cdcooper = 1 and t.nrdconta = 90224221) or (t.cdcooper = 1 and t.nrdconta = 90136403) or (t.cdcooper = 1 and t.nrdconta = 90267753) or
(t.cdcooper = 1 and t.nrdconta = 3931749) or (t.cdcooper = 1 and t.nrdconta = 3710505) or (t.cdcooper = 1 and t.nrdconta = 3842568) or
(t.cdcooper = 1 and t.nrdconta = 90162609) or (t.cdcooper = 1 and t.nrdconta = 90163214) or (t.cdcooper = 1 and t.nrdconta = 90071883) or
(t.cdcooper = 1 and t.nrdconta = 90071689) or (t.cdcooper = 1 and t.nrdconta = 90225031) or (t.cdcooper = 1 and t.nrdconta = 2799448) or
(t.cdcooper = 1 and t.nrdconta = 3739686) or (t.cdcooper = 1 and t.nrdconta = 3548570) or (t.cdcooper = 1 and t.nrdconta = 839698) or
(t.cdcooper = 1 and t.nrdconta = 2572710) or (t.cdcooper = 1 and t.nrdconta = 3784096) or (t.cdcooper = 1 and t.nrdconta = 3856429) or
(t.cdcooper = 1 and t.nrdconta = 3040542) or (t.cdcooper = 1 and t.nrdconta = 90168712) or (t.cdcooper = 1 and t.nrdconta = 90223314) or
(t.cdcooper = 1 and t.nrdconta = 90261836) or (t.cdcooper = 1 and t.nrdconta = 90160746) or (t.cdcooper = 1 and t.nrdconta = 90222652) or
(t.cdcooper = 1 and t.nrdconta = 3146570) or (t.cdcooper = 1 and t.nrdconta = 2653648) or (t.cdcooper = 1 and t.nrdconta = 90052277) or
(t.cdcooper = 1 and t.nrdconta = 90054083) or (t.cdcooper = 1 and t.nrdconta = 90054920) or (t.cdcooper = 1 and t.nrdconta = 90070321) or
(t.cdcooper = 1 and t.nrdconta = 90071484) or (t.cdcooper = 1 and t.nrdconta = 90072391) or (t.cdcooper = 1 and t.nrdconta = 90072944) or
(t.cdcooper = 1 and t.nrdconta = 90073843) or (t.cdcooper = 1 and t.nrdconta = 90078381) or (t.cdcooper = 1 and t.nrdconta = 90079132) or
(t.cdcooper = 1 and t.nrdconta = 90079183) or (t.cdcooper = 1 and t.nrdconta = 90079256) or (t.cdcooper = 1 and t.nrdconta = 90110722) or
(t.cdcooper = 1 and t.nrdconta = 90122623) or (t.cdcooper = 1 and t.nrdconta = 90160045) or (t.cdcooper = 1 and t.nrdconta = 90160703) or
(t.cdcooper = 1 and t.nrdconta = 90161726) or (t.cdcooper = 1 and t.nrdconta = 90161785) or (t.cdcooper = 1 and t.nrdconta = 90162692) or
(t.cdcooper = 1 and t.nrdconta = 90162960) or (t.cdcooper = 1 and t.nrdconta = 90163591) or (t.cdcooper = 1 and t.nrdconta = 90163893) or
(t.cdcooper = 1 and t.nrdconta = 90163940) or (t.cdcooper = 1 and t.nrdconta = 90164059) or (t.cdcooper = 1 and t.nrdconta = 90164326) or
(t.cdcooper = 1 and t.nrdconta = 90164458) or (t.cdcooper = 1 and t.nrdconta = 90164814) or (t.cdcooper = 1 and t.nrdconta = 90165039) or
(t.cdcooper = 1 and t.nrdconta = 90165071) or (t.cdcooper = 1 and t.nrdconta = 90165500) or (t.cdcooper = 1 and t.nrdconta = 90165764) or
(t.cdcooper = 1 and t.nrdconta = 90166000) or (t.cdcooper = 1 and t.nrdconta = 90167600) or (t.cdcooper = 1 and t.nrdconta = 90167945) or
(t.cdcooper = 1 and t.nrdconta = 90168810) or (t.cdcooper = 1 and t.nrdconta = 90169000) or (t.cdcooper = 1 and t.nrdconta = 90169310) or
(t.cdcooper = 1 and t.nrdconta = 90220897) or (t.cdcooper = 1 and t.nrdconta = 90221095) or (t.cdcooper = 1 and t.nrdconta = 90221419) or
(t.cdcooper = 1 and t.nrdconta = 90222164) or (t.cdcooper = 1 and t.nrdconta = 90222431) or (t.cdcooper = 1 and t.nrdconta = 90222911) or
(t.cdcooper = 1 and t.nrdconta = 90223160) or (t.cdcooper = 1 and t.nrdconta = 90224000) or (t.cdcooper = 1 and t.nrdconta = 90224884) or
(t.cdcooper = 1 and t.nrdconta = 90224922) or (t.cdcooper = 1 and t.nrdconta = 90260414) or (t.cdcooper = 1 and t.nrdconta = 90260929) or
(t.cdcooper = 1 and t.nrdconta = 90261674) or (t.cdcooper = 1 and t.nrdconta = 90261704) or (t.cdcooper = 1 and t.nrdconta = 90261933) or
(t.cdcooper = 1 and t.nrdconta = 90262204) or (t.cdcooper = 1 and t.nrdconta = 90264959) or (t.cdcooper = 1 and t.nrdconta = 90265785) or
(t.cdcooper = 1 and t.nrdconta = 90265890) or (t.cdcooper = 1 and t.nrdconta = 90267079) or (t.cdcooper = 1 and t.nrdconta = 3567451) or
(t.cdcooper = 1 and t.nrdconta = 90052480) or (t.cdcooper = 1 and t.nrdconta = 90053419) or (t.cdcooper = 1 and t.nrdconta = 90054121) or
(t.cdcooper = 1 and t.nrdconta = 90057627) or (t.cdcooper = 1 and t.nrdconta = 90070488) or (t.cdcooper = 1 and t.nrdconta = 90070810) or
(t.cdcooper = 1 and t.nrdconta = 90071328) or (t.cdcooper = 1 and t.nrdconta = 90079639) or (t.cdcooper = 1 and t.nrdconta = 90122917) or
(t.cdcooper = 1 and t.nrdconta = 90134311) or (t.cdcooper = 1 and t.nrdconta = 90136179) or (t.cdcooper = 1 and t.nrdconta = 90161459) or
(t.cdcooper = 1 and t.nrdconta = 90161734) or (t.cdcooper = 1 and t.nrdconta = 90163575) or (t.cdcooper = 1 and t.nrdconta = 90163826) or
(t.cdcooper = 1 and t.nrdconta = 90260767) or (t.cdcooper = 1 and t.nrdconta = 90260856) or (t.cdcooper = 1 and t.nrdconta = 90262093) or
(t.cdcooper = 1 and t.nrdconta = 90263847) or (t.cdcooper = 1 and t.nrdconta = 90264061) or (t.cdcooper = 1 and t.nrdconta = 2097206) or
(t.cdcooper = 1 and t.nrdconta = 2915677) or (t.cdcooper = 1 and t.nrdconta = 5527813) or (t.cdcooper = 1 and t.nrdconta = 3663795) or
(t.cdcooper = 1 and t.nrdconta = 3761177) or (t.cdcooper = 1 and t.nrdconta = 3651274) or (t.cdcooper = 1 and t.nrdconta = 3738655) or
(t.cdcooper = 1 and t.nrdconta = 90269519) or (t.cdcooper = 1 and t.nrdconta = 3645134) or (t.cdcooper = 1 and t.nrdconta = 2304066) or
(t.cdcooper = 1 and t.nrdconta = 2503158) or (t.cdcooper = 1 and t.nrdconta = 2691396) or (t.cdcooper = 1 and t.nrdconta = 2981580) or
(t.cdcooper = 1 and t.nrdconta = 3588645) or (t.cdcooper = 1 and t.nrdconta = 3697924) or (t.cdcooper = 1 and t.nrdconta = 2702878) or
(t.cdcooper = 1 and t.nrdconta = 2703017) or (t.cdcooper = 1 and t.nrdconta = 2729393) or (t.cdcooper = 1 and t.nrdconta = 3555380) or
(t.cdcooper = 1 and t.nrdconta = 2556626) or (t.cdcooper = 1 and t.nrdconta = 2799081) or (t.cdcooper = 1 and t.nrdconta = 2331268) or
(t.cdcooper = 1 and t.nrdconta = 2975068) or (t.cdcooper = 1 and t.nrdconta = 3085490) or (t.cdcooper = 1 and t.nrdconta = 2813203) or
(t.cdcooper = 1 and t.nrdconta = 2915251) or (t.cdcooper = 1 and t.nrdconta = 3546080) or (t.cdcooper = 1 and t.nrdconta = 3000753) or
(t.cdcooper = 1 and t.nrdconta = 3031810) or (t.cdcooper = 1 and t.nrdconta = 3511707) or (t.cdcooper = 1 and t.nrdconta = 2796066) or
(t.cdcooper = 1 and t.nrdconta = 2801353) or (t.cdcooper = 1 and t.nrdconta = 3000699) or (t.cdcooper = 1 and t.nrdconta = 80280552) or
(t.cdcooper = 1 and t.nrdconta = 1506668) or (t.cdcooper = 1 and t.nrdconta = 2372363) or (t.cdcooper = 1 and t.nrdconta = 3000265) or
(t.cdcooper = 1 and t.nrdconta = 2361515) or (t.cdcooper = 1 and t.nrdconta = 2369613) or (t.cdcooper = 1 and t.nrdconta = 2321335) or
(t.cdcooper = 1 and t.nrdconta = 3727378) or (t.cdcooper = 1 and t.nrdconta = 90168453) or (t.cdcooper = 1 and t.nrdconta = 2184362) or
(t.cdcooper = 1 and t.nrdconta = 2224135) or (t.cdcooper = 1 and t.nrdconta = 2270005) or (t.cdcooper = 1 and t.nrdconta = 2559340) or
(t.cdcooper = 1 and t.nrdconta = 2575140) or (t.cdcooper = 1 and t.nrdconta = 2874172) or (t.cdcooper = 1 and t.nrdconta = 3725510) or
(t.cdcooper = 1 and t.nrdconta = 525952) or (t.cdcooper = 1 and t.nrdconta = 3616134) or (t.cdcooper = 1 and t.nrdconta = 2550385) or
(t.cdcooper = 1 and t.nrdconta = 2308533) or (t.cdcooper = 1 and t.nrdconta = 3035786) or (t.cdcooper = 1 and t.nrdconta = 3530345) or
(t.cdcooper = 1 and t.nrdconta = 2920204) or (t.cdcooper = 1 and t.nrdconta = 3644790) or (t.cdcooper = 1 and t.nrdconta = 2695324) or
(t.cdcooper = 1 and t.nrdconta = 2262207) or (t.cdcooper = 1 and t.nrdconta = 2704552) or (t.cdcooper = 1 and t.nrdconta = 2991217) or
(t.cdcooper = 1 and t.nrdconta = 3145875) or (t.cdcooper = 1 and t.nrdconta = 2229420) or (t.cdcooper = 1 and t.nrdconta = 2533910) or
(t.cdcooper = 1 and t.nrdconta = 3563014) or (t.cdcooper = 1 and t.nrdconta = 3717771) or (t.cdcooper = 1 and t.nrdconta = 2882639) or
(t.cdcooper = 1 and t.nrdconta = 3533549) or (t.cdcooper = 1 and t.nrdconta = 90168585) or (t.cdcooper = 1 and t.nrdconta = 2817276) or
(t.cdcooper = 1 and t.nrdconta = 3672115) or (t.cdcooper = 1 and t.nrdconta = 1519670) or (t.cdcooper = 1 and t.nrdconta = 2933888) or
(t.cdcooper = 1 and t.nrdconta = 3088685) or (t.cdcooper = 1 and t.nrdconta = 3036928) or (t.cdcooper = 1 and t.nrdconta = 2777053) or
(t.cdcooper = 1 and t.nrdconta = 2556499) or (t.cdcooper = 1 and t.nrdconta = 80024726) or (t.cdcooper = 1 and t.nrdconta = 80241654) or
(t.cdcooper = 1 and t.nrdconta = 90050673) or (t.cdcooper = 1 and t.nrdconta = 90261526) or (t.cdcooper = 1 and t.nrdconta = 90264517) or
(t.cdcooper = 1 and t.nrdconta = 90266005) or (t.cdcooper = 1 and t.nrdconta = 703311) or (t.cdcooper = 1 and t.nrdconta = 751243) or
(t.cdcooper = 1 and t.nrdconta = 773964) or (t.cdcooper = 1 and t.nrdconta = 1253522) or (t.cdcooper = 1 and t.nrdconta = 1326481) or
(t.cdcooper = 1 and t.nrdconta = 1835890) or (t.cdcooper = 1 and t.nrdconta = 1844199) or (t.cdcooper = 1 and t.nrdconta = 1919962) or
(t.cdcooper = 1 and t.nrdconta = 1979175) or (t.cdcooper = 1 and t.nrdconta = 2050447) or (t.cdcooper = 1 and t.nrdconta = 2099268) or
(t.cdcooper = 1 and t.nrdconta = 2145855) or (t.cdcooper = 1 and t.nrdconta = 2146258) or (t.cdcooper = 1 and t.nrdconta = 2160056) or
(t.cdcooper = 1 and t.nrdconta = 2207532) or (t.cdcooper = 1 and t.nrdconta = 2211904) or (t.cdcooper = 1 and t.nrdconta = 2215500) or
(t.cdcooper = 1 and t.nrdconta = 2242583) or (t.cdcooper = 1 and t.nrdconta = 2269929) or (t.cdcooper = 1 and t.nrdconta = 2295857) or
(t.cdcooper = 1 and t.nrdconta = 2300044) or (t.cdcooper = 1 and t.nrdconta = 2300583) or (t.cdcooper = 1 and t.nrdconta = 2309866) or
(t.cdcooper = 1 and t.nrdconta = 2325578) or (t.cdcooper = 1 and t.nrdconta = 2325896) or (t.cdcooper = 1 and t.nrdconta = 2390892) or
(t.cdcooper = 1 and t.nrdconta = 2397803) or (t.cdcooper = 1 and t.nrdconta = 2505800) or (t.cdcooper = 1 and t.nrdconta = 2545128) or
(t.cdcooper = 1 and t.nrdconta = 2560755) or (t.cdcooper = 1 and t.nrdconta = 2571455) or (t.cdcooper = 1 and t.nrdconta = 2577640) or
(t.cdcooper = 1 and t.nrdconta = 2622769) or (t.cdcooper = 1 and t.nrdconta = 2659964) or (t.cdcooper = 1 and t.nrdconta = 2699060) or
(t.cdcooper = 1 and t.nrdconta = 2702894) or (t.cdcooper = 1 and t.nrdconta = 2703203) or (t.cdcooper = 1 and t.nrdconta = 2703483) or
(t.cdcooper = 1 and t.nrdconta = 2717549) or (t.cdcooper = 1 and t.nrdconta = 2720450) or (t.cdcooper = 1 and t.nrdconta = 2728486) or
(t.cdcooper = 1 and t.nrdconta = 2733030) or (t.cdcooper = 1 and t.nrdconta = 2741385) or (t.cdcooper = 1 and t.nrdconta = 2756552) or
(t.cdcooper = 1 and t.nrdconta = 2759497) or (t.cdcooper = 1 and t.nrdconta = 2759829) or (t.cdcooper = 1 and t.nrdconta = 2767325) or
(t.cdcooper = 1 and t.nrdconta = 2768470) or (t.cdcooper = 1 and t.nrdconta = 2802821) or (t.cdcooper = 1 and t.nrdconta = 2814846) or
(t.cdcooper = 1 and t.nrdconta = 2844427) or (t.cdcooper = 1 and t.nrdconta = 2846365) or (t.cdcooper = 1 and t.nrdconta = 2853574) or
(t.cdcooper = 1 and t.nrdconta = 2866080) or (t.cdcooper = 1 and t.nrdconta = 2869012) or (t.cdcooper = 1 and t.nrdconta = 2876183) or
(t.cdcooper = 1 and t.nrdconta = 2881497) or (t.cdcooper = 1 and t.nrdconta = 2882965) or (t.cdcooper = 1 and t.nrdconta = 2889960) or
(t.cdcooper = 1 and t.nrdconta = 2898586) or (t.cdcooper = 1 and t.nrdconta = 2905744) or (t.cdcooper = 1 and t.nrdconta = 2911183) or
(t.cdcooper = 1 and t.nrdconta = 2918633) or (t.cdcooper = 1 and t.nrdconta = 2918650) or (t.cdcooper = 1 and t.nrdconta = 2919460) or
(t.cdcooper = 1 and t.nrdconta = 2925370) or (t.cdcooper = 1 and t.nrdconta = 2928140) or (t.cdcooper = 1 and t.nrdconta = 2928531) or
(t.cdcooper = 1 and t.nrdconta = 2932040) or (t.cdcooper = 1 and t.nrdconta = 2932210) or (t.cdcooper = 1 and t.nrdconta = 2932610) or
(t.cdcooper = 1 and t.nrdconta = 2932644) or (t.cdcooper = 1 and t.nrdconta = 2933101) or (t.cdcooper = 1 and t.nrdconta = 2958708) or
(t.cdcooper = 1 and t.nrdconta = 2962683) or (t.cdcooper = 1 and t.nrdconta = 2970724) or (t.cdcooper = 1 and t.nrdconta = 2991845) or
(t.cdcooper = 1 and t.nrdconta = 2998432) or (t.cdcooper = 1 and t.nrdconta = 2998599) or (t.cdcooper = 1 and t.nrdconta = 2999200) or
(t.cdcooper = 1 and t.nrdconta = 3008649) or (t.cdcooper = 1 and t.nrdconta = 3035522) or (t.cdcooper = 1 and t.nrdconta = 3035557) or
(t.cdcooper = 1 and t.nrdconta = 3036774) or (t.cdcooper = 1 and t.nrdconta = 3043088) or (t.cdcooper = 1 and t.nrdconta = 3050327) or
(t.cdcooper = 1 and t.nrdconta = 3051013) or (t.cdcooper = 1 and t.nrdconta = 3059006) or (t.cdcooper = 1 and t.nrdconta = 3060284) or
(t.cdcooper = 1 and t.nrdconta = 3081729) or (t.cdcooper = 1 and t.nrdconta = 3084353) or (t.cdcooper = 1 and t.nrdconta = 3085406) or
(t.cdcooper = 1 and t.nrdconta = 3085953) or (t.cdcooper = 1 and t.nrdconta = 3091406) or (t.cdcooper = 1 and t.nrdconta = 3148386) or
(t.cdcooper = 1 and t.nrdconta = 3156486) or (t.cdcooper = 1 and t.nrdconta = 3507386) or (t.cdcooper = 1 and t.nrdconta = 3531430) or
(t.cdcooper = 1 and t.nrdconta = 3534120) or (t.cdcooper = 1 and t.nrdconta = 3534154) or (t.cdcooper = 1 and t.nrdconta = 3549518) or
(t.cdcooper = 1 and t.nrdconta = 3549674) or (t.cdcooper = 1 and t.nrdconta = 3554368) or (t.cdcooper = 1 and t.nrdconta = 3554813) or
(t.cdcooper = 1 and t.nrdconta = 3555054) or (t.cdcooper = 1 and t.nrdconta = 3555305) or (t.cdcooper = 1 and t.nrdconta = 3555321) or
(t.cdcooper = 1 and t.nrdconta = 3555518) or (t.cdcooper = 1 and t.nrdconta = 3555623) or (t.cdcooper = 1 and t.nrdconta = 3556107) or
(t.cdcooper = 1 and t.nrdconta = 3561895) or (t.cdcooper = 1 and t.nrdconta = 3593975) or (t.cdcooper = 1 and t.nrdconta = 3596044) or
(t.cdcooper = 1 and t.nrdconta = 3596486) or (t.cdcooper = 1 and t.nrdconta = 3602060) or (t.cdcooper = 1 and t.nrdconta = 3620930) or
(t.cdcooper = 1 and t.nrdconta = 3686302) or (t.cdcooper = 1 and t.nrdconta = 3555704) or (t.cdcooper = 1 and t.nrdconta = 3628736) or
(t.cdcooper = 1 and t.nrdconta = 3617823) or (t.cdcooper = 1 and t.nrdconta = 2764369) or (t.cdcooper = 1 and t.nrdconta = 3593088) or
(t.cdcooper = 1 and t.nrdconta = 2651122) or (t.cdcooper = 1 and t.nrdconta = 723967) or (t.cdcooper = 1 and t.nrdconta = 9130349) or
(t.cdcooper = 1 and t.nrdconta = 3531767) or (t.cdcooper = 1 and t.nrdconta = 2324598) or (t.cdcooper = 1 and t.nrdconta = 2952416) or
(t.cdcooper = 1 and t.nrdconta = 3554740) or (t.cdcooper = 1 and t.nrdconta = 3534057) or (t.cdcooper = 1 and t.nrdconta = 3533476) or
(t.cdcooper = 1 and t.nrdconta = 3554430) or (t.cdcooper = 1 and t.nrdconta = 3000370) or (t.cdcooper = 1 and t.nrdconta = 3555550) or
(t.cdcooper = 1 and t.nrdconta = 3036855) or (t.cdcooper = 1 and t.nrdconta = 3059960) or (t.cdcooper = 1 and t.nrdconta = 2915464) or
(t.cdcooper = 1 and t.nrdconta = 2891905) or (t.cdcooper = 1 and t.nrdconta = 3059421) or (t.cdcooper = 1 and t.nrdconta = 3059430) or
(t.cdcooper = 1 and t.nrdconta = 2972727) or (t.cdcooper = 1 and t.nrdconta = 3059863) or (t.cdcooper = 1 and t.nrdconta = 3031314) or
(t.cdcooper = 1 and t.nrdconta = 3036677) or (t.cdcooper = 1 and t.nrdconta = 2603373) or (t.cdcooper = 1 and t.nrdconta = 3036367) or
(t.cdcooper = 1 and t.nrdconta = 2781441) or (t.cdcooper = 1 and t.nrdconta = 2999552) or (t.cdcooper = 1 and t.nrdconta = 3035670) or
(t.cdcooper = 1 and t.nrdconta = 2998092) or (t.cdcooper = 1 and t.nrdconta = 3049779) or (t.cdcooper = 1 and t.nrdconta = 2998076) or
(t.cdcooper = 1 and t.nrdconta = 2903679) or (t.cdcooper = 1 and t.nrdconta = 2928396) or (t.cdcooper = 1 and t.nrdconta = 2423090) or
(t.cdcooper = 1 and t.nrdconta = 2887290) or (t.cdcooper = 1 and t.nrdconta = 2451018) or (t.cdcooper = 1 and t.nrdconta = 2997894) or
(t.cdcooper = 1 and t.nrdconta = 2999129) or (t.cdcooper = 1 and t.nrdconta = 2866986) or (t.cdcooper = 1 and t.nrdconta = 2866943) or
(t.cdcooper = 1 and t.nrdconta = 2914220) or (t.cdcooper = 1 and t.nrdconta = 2866870) or (t.cdcooper = 1 and t.nrdconta = 2846144) or
(t.cdcooper = 1 and t.nrdconta = 2888297) or (t.cdcooper = 1 and t.nrdconta = 2866455) or (t.cdcooper = 1 and t.nrdconta = 2927217) or
(t.cdcooper = 1 and t.nrdconta = 2739860) or (t.cdcooper = 1 and t.nrdconta = 2781387) or (t.cdcooper = 1 and t.nrdconta = 2882892) or
(t.cdcooper = 1 and t.nrdconta = 2882957) or (t.cdcooper = 1 and t.nrdconta = 2866099) or (t.cdcooper = 1 and t.nrdconta = 2781905) or
(t.cdcooper = 1 and t.nrdconta = 2866072) or (t.cdcooper = 1 and t.nrdconta = 2887991) or (t.cdcooper = 1 and t.nrdconta = 2866048) or
(t.cdcooper = 1 and t.nrdconta = 2862921) or (t.cdcooper = 1 and t.nrdconta = 2639645) or (t.cdcooper = 1 and t.nrdconta = 2865785) or
(t.cdcooper = 1 and t.nrdconta = 2544261) or (t.cdcooper = 1 and t.nrdconta = 2846160) or (t.cdcooper = 1 and t.nrdconta = 2865335) or
(t.cdcooper = 1 and t.nrdconta = 2865343) or (t.cdcooper = 1 and t.nrdconta = 2492040) or (t.cdcooper = 1 and t.nrdconta = 1400533) or
(t.cdcooper = 1 and t.nrdconta = 1943073) or (t.cdcooper = 1 and t.nrdconta = 3117596) or (t.cdcooper = 1 and t.nrdconta = 2285932) or
(t.cdcooper = 1 and t.nrdconta = 2522543) or (t.cdcooper = 1 and t.nrdconta = 2718758) or (t.cdcooper = 1 and t.nrdconta = 2468751) or
(t.cdcooper = 1 and t.nrdconta = 2496771) or (t.cdcooper = 1 and t.nrdconta = 2490447) or (t.cdcooper = 1 and t.nrdconta = 2642530) or
(t.cdcooper = 1 and t.nrdconta = 1874535) or (t.cdcooper = 1 and t.nrdconta = 4375513) or (t.cdcooper = 1 and t.nrdconta = 2599449) or
(t.cdcooper = 1 and t.nrdconta = 2092484) or (t.cdcooper = 1 and t.nrdconta = 2119846) or (t.cdcooper = 1 and t.nrdconta = 2097940) or
(t.cdcooper = 1 and t.nrdconta = 1826824) or (t.cdcooper = 1 and t.nrdconta = 2244381) or (t.cdcooper = 1 and t.nrdconta = 2577755) or
(t.cdcooper = 1 and t.nrdconta = 2204134) or (t.cdcooper = 1 and t.nrdconta = 623091) or (t.cdcooper = 1 and t.nrdconta = 646776) or
(t.cdcooper = 1 and t.nrdconta = 2089599) or (t.cdcooper = 1 and t.nrdconta = 963437) or (t.cdcooper = 1 and t.nrdconta = 624560) or
(t.cdcooper = 1 and t.nrdconta = 2505134) or (t.cdcooper = 1 and t.nrdconta = 950670) or (t.cdcooper = 1 and t.nrdconta = 962031) or
(t.cdcooper = 1 and t.nrdconta = 965138) or (t.cdcooper = 1 and t.nrdconta = 962864) or (t.cdcooper = 1 and t.nrdconta = 612944) or
(t.cdcooper = 1 and t.nrdconta = 964050) or (t.cdcooper = 1 and t.nrdconta = 951463) or (t.cdcooper = 1 and t.nrdconta = 962619) or
(t.cdcooper = 1 and t.nrdconta = 617679) or (t.cdcooper = 1 and t.nrdconta = 627275) or (t.cdcooper = 1 and t.nrdconta = 771716) or
(t.cdcooper = 1 and t.nrdconta = 2490080) or (t.cdcooper = 1 and t.nrdconta = 2375427) or (t.cdcooper = 1 and t.nrdconta = 2146290) or
(t.cdcooper = 1 and t.nrdconta = 2487381) or (t.cdcooper = 1 and t.nrdconta = 2435330) or (t.cdcooper = 1 and t.nrdconta = 3131548) or
(t.cdcooper = 1 and t.nrdconta = 3141780) or (t.cdcooper = 1 and t.nrdconta = 2026325) or (t.cdcooper = 1 and t.nrdconta = 2283590) or
(t.cdcooper = 1 and t.nrdconta = 2262878) or (t.cdcooper = 1 and t.nrdconta = 2147742) or (t.cdcooper = 1 and t.nrdconta = 1700391) or
(t.cdcooper = 1 and t.nrdconta = 942464) or (t.cdcooper = 1 and t.nrdconta = 760110) or (t.cdcooper = 1 and t.nrdconta = 2149567) or
(t.cdcooper = 1 and t.nrdconta = 2341182) or (t.cdcooper = 1 and t.nrdconta = 1477323) or (t.cdcooper = 1 and t.nrdconta = 2407825) or
(t.cdcooper = 1 and t.nrdconta = 2407582) or (t.cdcooper = 1 and t.nrdconta = 2243580) or (t.cdcooper = 1 and t.nrdconta = 2260468) or
(t.cdcooper = 1 and t.nrdconta = 964794) or (t.cdcooper = 1 and t.nrdconta = 2404273) or (t.cdcooper = 1 and t.nrdconta = 2390825) or
(t.cdcooper = 1 and t.nrdconta = 1895052) or (t.cdcooper = 1 and t.nrdconta = 5534038) or (t.cdcooper = 1 and t.nrdconta = 2147530) or
(t.cdcooper = 1 and t.nrdconta = 2340011) or (t.cdcooper = 1 and t.nrdconta = 3122131) or (t.cdcooper = 1 and t.nrdconta = 2097770) or
(t.cdcooper = 1 and t.nrdconta = 2311046) or (t.cdcooper = 1 and t.nrdconta = 2276836) or (t.cdcooper = 1 and t.nrdconta = 2077035) or
(t.cdcooper = 1 and t.nrdconta = 2254824) or (t.cdcooper = 1 and t.nrdconta = 2099012) or (t.cdcooper = 1 and t.nrdconta = 2350483) or
(t.cdcooper = 1 and t.nrdconta = 2358735) or (t.cdcooper = 1 and t.nrdconta = 5528739) or (t.cdcooper = 1 and t.nrdconta = 2278499) or
(t.cdcooper = 1 and t.nrdconta = 2026929) or (t.cdcooper = 1 and t.nrdconta = 2274191) or (t.cdcooper = 1 and t.nrdconta = 5529298) or
(t.cdcooper = 1 and t.nrdconta = 2343304) or (t.cdcooper = 1 and t.nrdconta = 2168553) or (t.cdcooper = 1 and t.nrdconta = 1253468) or
(t.cdcooper = 1 and t.nrdconta = 2176467) or (t.cdcooper = 1 and t.nrdconta = 1861239) or (t.cdcooper = 1 and t.nrdconta = 2326060) or
(t.cdcooper = 1 and t.nrdconta = 929158) or (t.cdcooper = 1 and t.nrdconta = 5533392) or (t.cdcooper = 1 and t.nrdconta = 2302853) or
(t.cdcooper = 1 and t.nrdconta = 2014610) or (t.cdcooper = 1 and t.nrdconta = 2211319) or (t.cdcooper = 1 and t.nrdconta = 2150980) or
(t.cdcooper = 1 and t.nrdconta = 930989) or (t.cdcooper = 1 and t.nrdconta = 2118793) or (t.cdcooper = 1 and t.nrdconta = 2222574) or
(t.cdcooper = 1 and t.nrdconta = 2160242) or (t.cdcooper = 1 and t.nrdconta = 80137563) or (t.cdcooper = 1 and t.nrdconta = 770671) or
(t.cdcooper = 1 and t.nrdconta = 1828185) or (t.cdcooper = 1 and t.nrdconta = 2290650) or (t.cdcooper = 1 and t.nrdconta = 3136019) or
(t.cdcooper = 1 and t.nrdconta = 2276275) or (t.cdcooper = 1 and t.nrdconta = 2222213) or (t.cdcooper = 1 and t.nrdconta = 2091461) or
(t.cdcooper = 1 and t.nrdconta = 2172046) or (t.cdcooper = 1 and t.nrdconta = 944432) or (t.cdcooper = 1 and t.nrdconta = 2160277) or
(t.cdcooper = 1 and t.nrdconta = 1847414) or (t.cdcooper = 1 and t.nrdconta = 1330438) or (t.cdcooper = 1 and t.nrdconta = 2075873) or
(t.cdcooper = 1 and t.nrdconta = 1855778) or (t.cdcooper = 1 and t.nrdconta = 2160269) or (t.cdcooper = 1 and t.nrdconta = 961671) or
(t.cdcooper = 1 and t.nrdconta = 3127575) or (t.cdcooper = 1 and t.nrdconta = 2176807) or (t.cdcooper = 1 and t.nrdconta = 3137643) or
(t.cdcooper = 1 and t.nrdconta = 3137856) or (t.cdcooper = 1 and t.nrdconta = 2087286) or (t.cdcooper = 1 and t.nrdconta = 2088266) or
(t.cdcooper = 1 and t.nrdconta = 842001) or (t.cdcooper = 1 and t.nrdconta = 2115093) or (t.cdcooper = 1 and t.nrdconta = 892882) or
(t.cdcooper = 1 and t.nrdconta = 1525301) or (t.cdcooper = 1 and t.nrdconta = 904007) or (t.cdcooper = 1 and t.nrdconta = 2040751) or
(t.cdcooper = 1 and t.nrdconta = 1973630) or (t.cdcooper = 1 and t.nrdconta = 1833308) or (t.cdcooper = 1 and t.nrdconta = 791156) or
(t.cdcooper = 1 and t.nrdconta = 2029022) or (t.cdcooper = 1 and t.nrdconta = 1973495) or (t.cdcooper = 1 and t.nrdconta = 1854879) or
(t.cdcooper = 1 and t.nrdconta = 976580) or (t.cdcooper = 1 and t.nrdconta = 1907220) or (t.cdcooper = 1 and t.nrdconta = 2011352) or
(t.cdcooper = 1 and t.nrdconta = 961400) or (t.cdcooper = 1 and t.nrdconta = 1973207) or (t.cdcooper = 1 and t.nrdconta = 755338) or
(t.cdcooper = 1 and t.nrdconta = 1973177) or (t.cdcooper = 1 and t.nrdconta = 936197) or (t.cdcooper = 1 and t.nrdconta = 1712349) or
(t.cdcooper = 1 and t.nrdconta = 1820338) or (t.cdcooper = 1 and t.nrdconta = 1927540) or (t.cdcooper = 1 and t.nrdconta = 2010836) or
(t.cdcooper = 1 and t.nrdconta = 1907654) or (t.cdcooper = 1 and t.nrdconta = 1709828) or (t.cdcooper = 1 and t.nrdconta = 1821113) or
(t.cdcooper = 1 and t.nrdconta = 373060) or (t.cdcooper = 1 and t.nrdconta = 4369998) or (t.cdcooper = 1 and t.nrdconta = 627135) or
(t.cdcooper = 1 and t.nrdconta = 3131270) or (t.cdcooper = 1 and t.nrdconta = 4105559) or (t.cdcooper = 1 and t.nrdconta = 1989570) or
(t.cdcooper = 1 and t.nrdconta = 943940) or (t.cdcooper = 1 and t.nrdconta = 950530) or (t.cdcooper = 1 and t.nrdconta = 960578) or
(t.cdcooper = 1 and t.nrdconta = 1117726) or (t.cdcooper = 1 and t.nrdconta = 616621) or (t.cdcooper = 1 and t.nrdconta = 749311) or
(t.cdcooper = 1 and t.nrdconta = 1969242) or (t.cdcooper = 1 and t.nrdconta = 619566) or (t.cdcooper = 1 and t.nrdconta = 793655) or
(t.cdcooper = 1 and t.nrdconta = 1930389) or (t.cdcooper = 1 and t.nrdconta = 1930567) or (t.cdcooper = 1 and t.nrdconta = 1830600) or
(t.cdcooper = 1 and t.nrdconta = 960535) or (t.cdcooper = 1 and t.nrdconta = 90072294) or (t.cdcooper = 1 and t.nrdconta = 90078926) or
(t.cdcooper = 1 and t.nrdconta = 616850) or (t.cdcooper = 1 and t.nrdconta = 90110366) or (t.cdcooper = 1 and t.nrdconta = 90071182) or
(t.cdcooper = 1 and t.nrdconta = 90071760) or (t.cdcooper = 1 and t.nrdconta = 90077288) or (t.cdcooper = 1 and t.nrdconta = 90077555) or
(t.cdcooper = 1 and t.nrdconta = 1884115) or (t.cdcooper = 1 and t.nrdconta = 5519187) or (t.cdcooper = 1 and t.nrdconta = 828599) or
(t.cdcooper = 1 and t.nrdconta = 960888) or (t.cdcooper = 1 and t.nrdconta = 595110) or (t.cdcooper = 1 and t.nrdconta = 1881965) or
(t.cdcooper = 1 and t.nrdconta = 3122662) or (t.cdcooper = 1 and t.nrdconta = 1889010) or (t.cdcooper = 1 and t.nrdconta = 933376) or
(t.cdcooper = 1 and t.nrdconta = 770817) or (t.cdcooper = 1 and t.nrdconta = 1898949) or (t.cdcooper = 1 and t.nrdconta = 970832) or
(t.cdcooper = 1 and t.nrdconta = 765066) or (t.cdcooper = 1 and t.nrdconta = 971065) or (t.cdcooper = 1 and t.nrdconta = 736929) or
(t.cdcooper = 1 and t.nrdconta = 970859) or (t.cdcooper = 1 and t.nrdconta = 971944) or (t.cdcooper = 1 and t.nrdconta = 972215) or
(t.cdcooper = 1 and t.nrdconta = 1923021) or (t.cdcooper = 1 and t.nrdconta = 970360) or (t.cdcooper = 1 and t.nrdconta = 1898574) or
(t.cdcooper = 1 and t.nrdconta = 970425) or (t.cdcooper = 1 and t.nrdconta = 1889028) or (t.cdcooper = 1 and t.nrdconta = 960365) or
(t.cdcooper = 1 and t.nrdconta = 970450) or (t.cdcooper = 1 and t.nrdconta = 970514) or (t.cdcooper = 1 and t.nrdconta = 1862944) or
(t.cdcooper = 1 and t.nrdconta = 1899988) or (t.cdcooper = 1 and t.nrdconta = 1904914) or (t.cdcooper = 1 and t.nrdconta = 1905066) or
(t.cdcooper = 1 and t.nrdconta = 1913093) or (t.cdcooper = 1 and t.nrdconta = 3129586) 
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 2 and t.nrdconta = 196053) or (t.cdcooper = 2 and t.nrdconta = 375730) or (t.cdcooper = 2 and t.nrdconta = 449504) or
(t.cdcooper = 2 and t.nrdconta = 458937) or (t.cdcooper = 2 and t.nrdconta = 460745) or (t.cdcooper = 2 and t.nrdconta = 40290) or
(t.cdcooper = 2 and t.nrdconta = 20745) or (t.cdcooper = 2 and t.nrdconta = 71005) or (t.cdcooper = 2 and t.nrdconta = 110736) or
(t.cdcooper = 2 and t.nrdconta = 122319) or (t.cdcooper = 2 and t.nrdconta = 314773) or (t.cdcooper = 2 and t.nrdconta = 315001) or
(t.cdcooper = 2 and t.nrdconta = 490709) or (t.cdcooper = 2 and t.nrdconta = 564800) or (t.cdcooper = 2 and t.nrdconta = 262315) or
(t.cdcooper = 2 and t.nrdconta = 451363) or (t.cdcooper = 2 and t.nrdconta = 702692) or (t.cdcooper = 2 and t.nrdconta = 556394) or
(t.cdcooper = 2 and t.nrdconta = 628778) or (t.cdcooper = 2 and t.nrdconta = 111120) or (t.cdcooper = 2 and t.nrdconta = 381608) or
(t.cdcooper = 2 and t.nrdconta = 452548) or (t.cdcooper = 2 and t.nrdconta = 512915) or (t.cdcooper = 2 and t.nrdconta = 409723) or
(t.cdcooper = 2 and t.nrdconta = 700657) or (t.cdcooper = 2 and t.nrdconta = 400211) or (t.cdcooper = 2 and t.nrdconta = 297720) or
(t.cdcooper = 2 and t.nrdconta = 449253) or (t.cdcooper = 2 and t.nrdconta = 235148) or (t.cdcooper = 2 and t.nrdconta = 407569) or
(t.cdcooper = 2 and t.nrdconta = 553409) or (t.cdcooper = 2 and t.nrdconta = 227404) or (t.cdcooper = 2 and t.nrdconta = 50199) or
(t.cdcooper = 2 and t.nrdconta = 50300) or (t.cdcooper = 2 and t.nrdconta = 51357) or (t.cdcooper = 2 and t.nrdconta = 51640) or
(t.cdcooper = 2 and t.nrdconta = 51659) or (t.cdcooper = 2 and t.nrdconta = 52949) or (t.cdcooper = 2 and t.nrdconta = 53708) or
(t.cdcooper = 2 and t.nrdconta = 54801) or (t.cdcooper = 2 and t.nrdconta = 75531) or (t.cdcooper = 2 and t.nrdconta = 75582) or
(t.cdcooper = 2 and t.nrdconta = 75663) or (t.cdcooper = 2 and t.nrdconta = 75671) or (t.cdcooper = 2 and t.nrdconta = 75795) or
(t.cdcooper = 2 and t.nrdconta = 75841) or (t.cdcooper = 2 and t.nrdconta = 75884) or (t.cdcooper = 2 and t.nrdconta = 75892) or
(t.cdcooper = 2 and t.nrdconta = 75957) or (t.cdcooper = 2 and t.nrdconta = 76031) or (t.cdcooper = 2 and t.nrdconta = 76058) or
(t.cdcooper = 2 and t.nrdconta = 76163) or (t.cdcooper = 2 and t.nrdconta = 76228) or (t.cdcooper = 2 and t.nrdconta = 76627) or
(t.cdcooper = 2 and t.nrdconta = 76643) or (t.cdcooper = 2 and t.nrdconta = 76872) or (t.cdcooper = 2 and t.nrdconta = 76945) or
(t.cdcooper = 2 and t.nrdconta = 76961) or (t.cdcooper = 2 and t.nrdconta = 79073) or (t.cdcooper = 2 and t.nrdconta = 87750) or
(t.cdcooper = 2 and t.nrdconta = 111104) or (t.cdcooper = 2 and t.nrdconta = 111198) or (t.cdcooper = 2 and t.nrdconta = 111201) or
(t.cdcooper = 2 and t.nrdconta = 111236) or (t.cdcooper = 2 and t.nrdconta = 111244) or (t.cdcooper = 2 and t.nrdconta = 132012) or
(t.cdcooper = 2 and t.nrdconta = 136980) or (t.cdcooper = 2 and t.nrdconta = 358096) or (t.cdcooper = 2 and t.nrdconta = 628158) or
(t.cdcooper = 2 and t.nrdconta = 629812) or (t.cdcooper = 2 and t.nrdconta = 201065) or (t.cdcooper = 2 and t.nrdconta = 268372) or
(t.cdcooper = 2 and t.nrdconta = 574635) or (t.cdcooper = 2 and t.nrdconta = 477826) or (t.cdcooper = 2 and t.nrdconta = 376272) or
(t.cdcooper = 2 and t.nrdconta = 552321) or (t.cdcooper = 2 and t.nrdconta = 395951) or (t.cdcooper = 2 and t.nrdconta = 394947) or
(t.cdcooper = 2 and t.nrdconta = 219924) or (t.cdcooper = 2 and t.nrdconta = 456675) or (t.cdcooper = 2 and t.nrdconta = 194697) or
(t.cdcooper = 2 and t.nrdconta = 449075) or (t.cdcooper = 2 and t.nrdconta = 269247) or (t.cdcooper = 2 and t.nrdconta = 408158) or
(t.cdcooper = 2 and t.nrdconta = 218073) or (t.cdcooper = 2 and t.nrdconta = 561819) or (t.cdcooper = 2 and t.nrdconta = 269301) or
(t.cdcooper = 2 and t.nrdconta = 457540) or (t.cdcooper = 2 and t.nrdconta = 315702) or (t.cdcooper = 2 and t.nrdconta = 198412) or
(t.cdcooper = 2 and t.nrdconta = 167541) or (t.cdcooper = 2 and t.nrdconta = 339245) or (t.cdcooper = 2 and t.nrdconta = 203220) or
(t.cdcooper = 2 and t.nrdconta = 468320) or (t.cdcooper = 2 and t.nrdconta = 200859) or (t.cdcooper = 2 and t.nrdconta = 393444) or
(t.cdcooper = 2 and t.nrdconta = 458147) or (t.cdcooper = 2 and t.nrdconta = 441880) or (t.cdcooper = 2 and t.nrdconta = 445118) or
(t.cdcooper = 2 and t.nrdconta = 468851) or (t.cdcooper = 2 and t.nrdconta = 700991) or (t.cdcooper = 2 and t.nrdconta = 220213) or
(t.cdcooper = 2 and t.nrdconta = 537365) or (t.cdcooper = 2 and t.nrdconta = 291080) or (t.cdcooper = 2 and t.nrdconta = 460044) or
(t.cdcooper = 2 and t.nrdconta = 701890) or (t.cdcooper = 2 and t.nrdconta = 208680) or (t.cdcooper = 2 and t.nrdconta = 540790) or
(t.cdcooper = 2 and t.nrdconta = 706582) or (t.cdcooper = 2 and t.nrdconta = 393355) or (t.cdcooper = 2 and t.nrdconta = 559229) or
(t.cdcooper = 2 and t.nrdconta = 478539) or (t.cdcooper = 2 and t.nrdconta = 206377) or (t.cdcooper = 2 and t.nrdconta = 389048) or
(t.cdcooper = 2 and t.nrdconta = 466387) or (t.cdcooper = 2 and t.nrdconta = 555240) or (t.cdcooper = 2 and t.nrdconta = 402150) or
(t.cdcooper = 2 and t.nrdconta = 700029) or (t.cdcooper = 2 and t.nrdconta = 702315) or (t.cdcooper = 2 and t.nrdconta = 194395) or
(t.cdcooper = 2 and t.nrdconta = 198315) or (t.cdcooper = 2 and t.nrdconta = 388815) or (t.cdcooper = 2 and t.nrdconta = 465887) or
(t.cdcooper = 2 and t.nrdconta = 557510) or (t.cdcooper = 2 and t.nrdconta = 534005) or (t.cdcooper = 2 and t.nrdconta = 559539) or
(t.cdcooper = 2 and t.nrdconta = 514306) or (t.cdcooper = 2 and t.nrdconta = 455369) or (t.cdcooper = 2 and t.nrdconta = 209899) or
(t.cdcooper = 2 and t.nrdconta = 570796) or (t.cdcooper = 2 and t.nrdconta = 570800) or (t.cdcooper = 2 and t.nrdconta = 536180) or
(t.cdcooper = 2 and t.nrdconta = 207772) or (t.cdcooper = 2 and t.nrdconta = 458066) or (t.cdcooper = 2 and t.nrdconta = 558397) or
(t.cdcooper = 2 and t.nrdconta = 558052) or (t.cdcooper = 2 and t.nrdconta = 465925) or (t.cdcooper = 2 and t.nrdconta = 372730) or
(t.cdcooper = 2 and t.nrdconta = 554235) or (t.cdcooper = 2 and t.nrdconta = 398713) or (t.cdcooper = 2 and t.nrdconta = 456381) or
(t.cdcooper = 2 and t.nrdconta = 552186) or (t.cdcooper = 2 and t.nrdconta = 55816) or (t.cdcooper = 2 and t.nrdconta = 463159) or
(t.cdcooper = 2 and t.nrdconta = 46990) or (t.cdcooper = 2 and t.nrdconta = 56472) or (t.cdcooper = 2 and t.nrdconta = 66524) or
(t.cdcooper = 2 and t.nrdconta = 92339) or (t.cdcooper = 2 and t.nrdconta = 93645) or (t.cdcooper = 2 and t.nrdconta = 105422) or
(t.cdcooper = 2 and t.nrdconta = 105791) or (t.cdcooper = 2 and t.nrdconta = 113018) or (t.cdcooper = 2 and t.nrdconta = 114154) or
(t.cdcooper = 2 and t.nrdconta = 115240) or (t.cdcooper = 2 and t.nrdconta = 129950) or (t.cdcooper = 2 and t.nrdconta = 130273) or
(t.cdcooper = 2 and t.nrdconta = 146463) or (t.cdcooper = 2 and t.nrdconta = 147192) or (t.cdcooper = 2 and t.nrdconta = 147710) or
(t.cdcooper = 2 and t.nrdconta = 173606) or (t.cdcooper = 2 and t.nrdconta = 174076) or (t.cdcooper = 2 and t.nrdconta = 175951) or
(t.cdcooper = 2 and t.nrdconta = 175960) or (t.cdcooper = 2 and t.nrdconta = 176451) or (t.cdcooper = 2 and t.nrdconta = 176958) or
(t.cdcooper = 2 and t.nrdconta = 177989) or (t.cdcooper = 2 and t.nrdconta = 179418) or (t.cdcooper = 2 and t.nrdconta = 181056) or
(t.cdcooper = 2 and t.nrdconta = 186180) or (t.cdcooper = 2 and t.nrdconta = 192333) or (t.cdcooper = 2 and t.nrdconta = 197165) or
(t.cdcooper = 2 and t.nrdconta = 212822) or (t.cdcooper = 2 and t.nrdconta = 213861) or (t.cdcooper = 2 and t.nrdconta = 230324) or
(t.cdcooper = 2 and t.nrdconta = 238104) or (t.cdcooper = 2 and t.nrdconta = 242284) or (t.cdcooper = 2 and t.nrdconta = 245518) or
(t.cdcooper = 2 and t.nrdconta = 250309) or (t.cdcooper = 2 and t.nrdconta = 250392) or (t.cdcooper = 2 and t.nrdconta = 271276) or
(t.cdcooper = 2 and t.nrdconta = 271853) or (t.cdcooper = 2 and t.nrdconta = 272248) or (t.cdcooper = 2 and t.nrdconta = 273309) or
(t.cdcooper = 2 and t.nrdconta = 277258) or (t.cdcooper = 2 and t.nrdconta = 278998) or (t.cdcooper = 2 and t.nrdconta = 289337) or
(t.cdcooper = 2 and t.nrdconta = 326038) or (t.cdcooper = 2 and t.nrdconta = 328847) or (t.cdcooper = 2 and t.nrdconta = 333638) or
(t.cdcooper = 2 and t.nrdconta = 333824) or (t.cdcooper = 2 and t.nrdconta = 335029) or (t.cdcooper = 2 and t.nrdconta = 336661) or
(t.cdcooper = 2 and t.nrdconta = 337145) or (t.cdcooper = 2 and t.nrdconta = 338419) or (t.cdcooper = 2 and t.nrdconta = 340669) or
(t.cdcooper = 2 and t.nrdconta = 340936) or (t.cdcooper = 2 and t.nrdconta = 353906) or (t.cdcooper = 2 and t.nrdconta = 356999) or
(t.cdcooper = 2 and t.nrdconta = 358070) or (t.cdcooper = 2 and t.nrdconta = 360457) or (t.cdcooper = 2 and t.nrdconta = 362417) or
(t.cdcooper = 2 and t.nrdconta = 364649) or (t.cdcooper = 2 and t.nrdconta = 365599) or (t.cdcooper = 2 and t.nrdconta = 367354) or
(t.cdcooper = 2 and t.nrdconta = 367907) or (t.cdcooper = 2 and t.nrdconta = 368938) or (t.cdcooper = 2 and t.nrdconta = 369268) or
(t.cdcooper = 2 and t.nrdconta = 369780) or (t.cdcooper = 2 and t.nrdconta = 410705) or (t.cdcooper = 2 and t.nrdconta = 412198) or
(t.cdcooper = 2 and t.nrdconta = 412392) or (t.cdcooper = 2 and t.nrdconta = 415669) or (t.cdcooper = 2 and t.nrdconta = 416037) or
(t.cdcooper = 2 and t.nrdconta = 421812) or (t.cdcooper = 2 and t.nrdconta = 422312) or (t.cdcooper = 2 and t.nrdconta = 422770) or
(t.cdcooper = 2 and t.nrdconta = 427357) or (t.cdcooper = 2 and t.nrdconta = 430080) or (t.cdcooper = 2 and t.nrdconta = 430951) or
(t.cdcooper = 2 and t.nrdconta = 431230) or (t.cdcooper = 2 and t.nrdconta = 434280) or (t.cdcooper = 2 and t.nrdconta = 436585) or
(t.cdcooper = 2 and t.nrdconta = 438464) or (t.cdcooper = 2 and t.nrdconta = 470619) or (t.cdcooper = 2 and t.nrdconta = 480711) or
(t.cdcooper = 2 and t.nrdconta = 480991) or (t.cdcooper = 2 and t.nrdconta = 482498) or (t.cdcooper = 2 and t.nrdconta = 482986) or
(t.cdcooper = 2 and t.nrdconta = 484512) or (t.cdcooper = 2 and t.nrdconta = 501140) or (t.cdcooper = 2 and t.nrdconta = 459038) or
(t.cdcooper = 2 and t.nrdconta = 303429) or (t.cdcooper = 2 and t.nrdconta = 209589) or (t.cdcooper = 2 and t.nrdconta = 388386) or
(t.cdcooper = 2 and t.nrdconta = 551791) or (t.cdcooper = 2 and t.nrdconta = 443441) or (t.cdcooper = 2 and t.nrdconta = 535028) or
(t.cdcooper = 2 and t.nrdconta = 464392) or (t.cdcooper = 2 and t.nrdconta = 413356) or (t.cdcooper = 2 and t.nrdconta = 176702) or
(t.cdcooper = 2 and t.nrdconta = 386952) or (t.cdcooper = 2 and t.nrdconta = 533491) or (t.cdcooper = 2 and t.nrdconta = 536032) or
(t.cdcooper = 2 and t.nrdconta = 398373) or (t.cdcooper = 2 and t.nrdconta = 268992) or (t.cdcooper = 2 and t.nrdconta = 305383) or
(t.cdcooper = 2 and t.nrdconta = 312258) or (t.cdcooper = 2 and t.nrdconta = 302791) or (t.cdcooper = 2 and t.nrdconta = 551414) or
(t.cdcooper = 2 and t.nrdconta = 449458) or (t.cdcooper = 2 and t.nrdconta = 449261) or (t.cdcooper = 2 and t.nrdconta = 228842) or
(t.cdcooper = 2 and t.nrdconta = 430773) or (t.cdcooper = 2 and t.nrdconta = 316148) or (t.cdcooper = 2 and t.nrdconta = 25445) or
(t.cdcooper = 2 and t.nrdconta = 374032) or (t.cdcooper = 2 and t.nrdconta = 443743) or (t.cdcooper = 2 and t.nrdconta = 206296) or
(t.cdcooper = 2 and t.nrdconta = 268887) or (t.cdcooper = 2 and t.nrdconta = 442798) or (t.cdcooper = 2 and t.nrdconta = 274399) or
(t.cdcooper = 2 and t.nrdconta = 210064) or (t.cdcooper = 2 and t.nrdconta = 314927) or (t.cdcooper = 2 and t.nrdconta = 268585) or
(t.cdcooper = 2 and t.nrdconta = 314501) or (t.cdcooper = 2 and t.nrdconta = 318795) or (t.cdcooper = 2 and t.nrdconta = 286222) or
(t.cdcooper = 2 and t.nrdconta = 407348) or (t.cdcooper = 2 and t.nrdconta = 298905) or (t.cdcooper = 2 and t.nrdconta = 286079) or
(t.cdcooper = 2 and t.nrdconta = 99856) or (t.cdcooper = 2 and t.nrdconta = 200050) or (t.cdcooper = 2 and t.nrdconta = 362468) or
(t.cdcooper = 2 and t.nrdconta = 116688) or (t.cdcooper = 2 and t.nrdconta = 314382) or (t.cdcooper = 2 and t.nrdconta = 267325) or
(t.cdcooper = 2 and t.nrdconta = 210307) or (t.cdcooper = 2 and t.nrdconta = 286087) or (t.cdcooper = 2 and t.nrdconta = 360880) or
(t.cdcooper = 2 and t.nrdconta = 207918) or (t.cdcooper = 2 and t.nrdconta = 312304) or (t.cdcooper = 2 and t.nrdconta = 302384) or
(t.cdcooper = 2 and t.nrdconta = 311880) or (t.cdcooper = 2 and t.nrdconta = 266140) or (t.cdcooper = 2 and t.nrdconta = 267171) or
(t.cdcooper = 2 and t.nrdconta = 269514) or (t.cdcooper = 2 and t.nrdconta = 280550) or (t.cdcooper = 2 and t.nrdconta = 168459) or
(t.cdcooper = 2 and t.nrdconta = 262927) or (t.cdcooper = 2 and t.nrdconta = 162396) or (t.cdcooper = 2 and t.nrdconta = 188603) or
(t.cdcooper = 2 and t.nrdconta = 168580) or (t.cdcooper = 2 and t.nrdconta = 263109) or (t.cdcooper = 2 and t.nrdconta = 24724) or
(t.cdcooper = 2 and t.nrdconta = 50679) or (t.cdcooper = 2 and t.nrdconta = 116319) or (t.cdcooper = 2 and t.nrdconta = 169781) or
(t.cdcooper = 2 and t.nrdconta = 205877) or (t.cdcooper = 2 and t.nrdconta = 227382) or (t.cdcooper = 2 and t.nrdconta = 237647) or
(t.cdcooper = 2 and t.nrdconta = 239917) or (t.cdcooper = 2 and t.nrdconta = 241652) or (t.cdcooper = 2 and t.nrdconta = 242756) or
(t.cdcooper = 2 and t.nrdconta = 245658) or (t.cdcooper = 2 and t.nrdconta = 245712) or (t.cdcooper = 2 and t.nrdconta = 251887) or
(t.cdcooper = 2 and t.nrdconta = 251895) or (t.cdcooper = 2 and t.nrdconta = 260711) or (t.cdcooper = 2 and t.nrdconta = 261521) or
(t.cdcooper = 2 and t.nrdconta = 263494) or (t.cdcooper = 2 and t.nrdconta = 264512) or (t.cdcooper = 2 and t.nrdconta = 266000) or
(t.cdcooper = 2 and t.nrdconta = 271780) or (t.cdcooper = 2 and t.nrdconta = 276863) or (t.cdcooper = 2 and t.nrdconta = 280259) or
(t.cdcooper = 2 and t.nrdconta = 252140) or (t.cdcooper = 2 and t.nrdconta = 198480) or (t.cdcooper = 2 and t.nrdconta = 164593) or
(t.cdcooper = 2 and t.nrdconta = 196851) or (t.cdcooper = 2 and t.nrdconta = 146242) or (t.cdcooper = 2 and t.nrdconta = 160067) or
(t.cdcooper = 2 and t.nrdconta = 178632) or (t.cdcooper = 2 and t.nrdconta = 179671) or (t.cdcooper = 2 and t.nrdconta = 32611) or
(t.cdcooper = 2 and t.nrdconta = 168521) or (t.cdcooper = 2 and t.nrdconta = 144061) or (t.cdcooper = 2 and t.nrdconta = 126420) or
(t.cdcooper = 2 and t.nrdconta = 108898) or (t.cdcooper = 2 and t.nrdconta = 101516) or (t.cdcooper = 2 and t.nrdconta = 149519) or
(t.cdcooper = 2 and t.nrdconta = 68977) or (t.cdcooper = 2 and t.nrdconta = 122874) or (t.cdcooper = 2 and t.nrdconta = 137561) or
(t.cdcooper = 2 and t.nrdconta = 180408) or (t.cdcooper = 2 and t.nrdconta = 137642) or (t.cdcooper = 2 and t.nrdconta = 13900) or
(t.cdcooper = 2 and t.nrdconta = 150576) or (t.cdcooper = 2 and t.nrdconta = 27960) or (t.cdcooper = 2 and t.nrdconta = 49379) or
(t.cdcooper = 2 and t.nrdconta = 131687) or (t.cdcooper = 2 and t.nrdconta = 132020) or (t.cdcooper = 2 and t.nrdconta = 105317) or
(t.cdcooper = 2 and t.nrdconta = 104418) or (t.cdcooper = 2 and t.nrdconta = 3131) or (t.cdcooper = 2 and t.nrdconta = 2089) or
(t.cdcooper = 2 and t.nrdconta = 79766) or (t.cdcooper = 2 and t.nrdconta = 9210) or (t.cdcooper = 2 and t.nrdconta = 6890) or
(t.cdcooper = 2 and t.nrdconta = 76414) or (t.cdcooper = 2 and t.nrdconta = 77011) or (t.cdcooper = 2 and t.nrdconta = 77593) or
(t.cdcooper = 2 and t.nrdconta = 77682) or (t.cdcooper = 2 and t.nrdconta = 85642) or (t.cdcooper = 2 and t.nrdconta = 17809) or
(t.cdcooper = 2 and t.nrdconta = 71110) or (t.cdcooper = 2 and t.nrdconta = 72290) or (t.cdcooper = 2 and t.nrdconta = 78921) or
(t.cdcooper = 2 and t.nrdconta = 56340) or (t.cdcooper = 2 and t.nrdconta = 70718) or (t.cdcooper = 2 and t.nrdconta = 73423) or
(t.cdcooper = 2 and t.nrdconta = 74535) or (t.cdcooper = 2 and t.nrdconta = 74705) or (t.cdcooper = 2 and t.nrdconta = 110361) or
(t.cdcooper = 2 and t.nrdconta = 72532) or (t.cdcooper = 2 and t.nrdconta = 95320) or (t.cdcooper = 2 and t.nrdconta = 56367) or
(t.cdcooper = 2 and t.nrdconta = 56804) or (t.cdcooper = 2 and t.nrdconta = 57606) or (t.cdcooper = 2 and t.nrdconta = 57614) or
(t.cdcooper = 2 and t.nrdconta = 70068) or (t.cdcooper = 2 and t.nrdconta = 70297) or (t.cdcooper = 2 and t.nrdconta = 70351) or
(t.cdcooper = 2 and t.nrdconta = 70378) or (t.cdcooper = 2 and t.nrdconta = 70416) or (t.cdcooper = 2 and t.nrdconta = 70521) or
(t.cdcooper = 2 and t.nrdconta = 70629) or (t.cdcooper = 2 and t.nrdconta = 71099) or (t.cdcooper = 2 and t.nrdconta = 71188) or
(t.cdcooper = 2 and t.nrdconta = 71315) or (t.cdcooper = 2 and t.nrdconta = 71447) or (t.cdcooper = 2 and t.nrdconta = 71765) or
(t.cdcooper = 2 and t.nrdconta = 77194) or (t.cdcooper = 2 and t.nrdconta = 77208) or (t.cdcooper = 2 and t.nrdconta = 77267) or
(t.cdcooper = 2 and t.nrdconta = 77283) or (t.cdcooper = 2 and t.nrdconta = 77330) or (t.cdcooper = 2 and t.nrdconta = 77461) or
(t.cdcooper = 2 and t.nrdconta = 77550) or (t.cdcooper = 2 and t.nrdconta = 77763) or (t.cdcooper = 2 and t.nrdconta = 77810) or
(t.cdcooper = 2 and t.nrdconta = 77933) or (t.cdcooper = 2 and t.nrdconta = 2453) or (t.cdcooper = 2 and t.nrdconta = 53520) or
(t.cdcooper = 2 and t.nrdconta = 53880) or (t.cdcooper = 2 and t.nrdconta = 54100) or (t.cdcooper = 2 and t.nrdconta = 54151) or
(t.cdcooper = 2 and t.nrdconta = 54240) or (t.cdcooper = 2 and t.nrdconta = 54712) or (t.cdcooper = 2 and t.nrdconta = 56774) or
(t.cdcooper = 2 and t.nrdconta = 52116) or (t.cdcooper = 2 and t.nrdconta = 52469) or (t.cdcooper = 2 and t.nrdconta = 52744) or
(t.cdcooper = 2 and t.nrdconta = 52850) or (t.cdcooper = 2 and t.nrdconta = 52884) or (t.cdcooper = 2 and t.nrdconta = 32336) or
(t.cdcooper = 2 and t.nrdconta = 40541) or (t.cdcooper = 2 and t.nrdconta = 36412) or (t.cdcooper = 2 and t.nrdconta = 48178) or
(t.cdcooper = 2 and t.nrdconta = 55794) or (t.cdcooper = 2 and t.nrdconta = 33766) or (t.cdcooper = 2 and t.nrdconta = 34789) or
(t.cdcooper = 2 and t.nrdconta = 56154)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 5 and t.nrdconta = 6343) or (t.cdcooper = 5 and t.nrdconta = 99961) or (t.cdcooper = 5 and t.nrdconta = 147044) or
(t.cdcooper = 5 and t.nrdconta = 148334) or (t.cdcooper = 5 and t.nrdconta = 106283) or (t.cdcooper = 5 and t.nrdconta = 86908) or
(t.cdcooper = 5 and t.nrdconta = 148571) or (t.cdcooper = 5 and t.nrdconta = 148202) or (t.cdcooper = 5 and t.nrdconta = 94110) or
(t.cdcooper = 5 and t.nrdconta = 98124) or (t.cdcooper = 5 and t.nrdconta = 132560) or (t.cdcooper = 5 and t.nrdconta = 35807) or
(t.cdcooper = 5 and t.nrdconta = 418) or (t.cdcooper = 5 and t.nrdconta = 72400) or (t.cdcooper = 5 and t.nrdconta = 96806) or
(t.cdcooper = 5 and t.nrdconta = 101923) or (t.cdcooper = 5 and t.nrdconta = 100293) or (t.cdcooper = 5 and t.nrdconta = 80578) or
(t.cdcooper = 5 and t.nrdconta = 70319) or (t.cdcooper = 5 and t.nrdconta = 108073) or (t.cdcooper = 5 and t.nrdconta = 98817) or
(t.cdcooper = 5 and t.nrdconta = 85154) or (t.cdcooper = 5 and t.nrdconta = 91928) or (t.cdcooper = 5 and t.nrdconta = 60372) or
(t.cdcooper = 5 and t.nrdconta = 77313) or (t.cdcooper = 5 and t.nrdconta = 77399) or (t.cdcooper = 5 and t.nrdconta = 77747) or
(t.cdcooper = 5 and t.nrdconta = 72516) or (t.cdcooper = 5 and t.nrdconta = 87017) or (t.cdcooper = 5 and t.nrdconta = 84700) or
(t.cdcooper = 5 and t.nrdconta = 56421) or (t.cdcooper = 5 and t.nrdconta = 66702) or (t.cdcooper = 5 and t.nrdconta = 82201) or
(t.cdcooper = 5 and t.nrdconta = 79871) or (t.cdcooper = 5 and t.nrdconta = 58670) or (t.cdcooper = 5 and t.nrdconta = 77208) or
(t.cdcooper = 5 and t.nrdconta = 75426) or (t.cdcooper = 5 and t.nrdconta = 73024) or (t.cdcooper = 5 and t.nrdconta = 671) or
(t.cdcooper = 5 and t.nrdconta = 68977) or (t.cdcooper = 5 and t.nrdconta = 64785) or (t.cdcooper = 5 and t.nrdconta = 61905) or
(t.cdcooper = 5 and t.nrdconta = 65633) or (t.cdcooper = 5 and t.nrdconta = 60917) or (t.cdcooper = 5 and t.nrdconta = 47767) or
(t.cdcooper = 5 and t.nrdconta = 15571) or (t.cdcooper = 5 and t.nrdconta = 64149) or (t.cdcooper = 5 and t.nrdconta = 46132) or
(t.cdcooper = 5 and t.nrdconta = 45020) or (t.cdcooper = 5 and t.nrdconta = 63185) or (t.cdcooper = 5 and t.nrdconta = 39497) or
(t.cdcooper = 5 and t.nrdconta = 52582) or (t.cdcooper = 5 and t.nrdconta = 50202) or (t.cdcooper = 5 and t.nrdconta = 3581) or
(t.cdcooper = 5 and t.nrdconta = 16489) or (t.cdcooper = 5 and t.nrdconta = 40720) or (t.cdcooper = 5 and t.nrdconta = 58114) or
(t.cdcooper = 5 and t.nrdconta = 48925) or (t.cdcooper = 5 and t.nrdconta = 36188) or (t.cdcooper = 5 and t.nrdconta = 6106) or
(t.cdcooper = 5 and t.nrdconta = 46892) or (t.cdcooper = 5 and t.nrdconta = 43281) or (t.cdcooper = 5 and t.nrdconta = 36560) or
(t.cdcooper = 5 and t.nrdconta = 37931) or (t.cdcooper = 5 and t.nrdconta = 39381) or (t.cdcooper = 5 and t.nrdconta = 39403) or
(t.cdcooper = 5 and t.nrdconta = 39535) or (t.cdcooper = 5 and t.nrdconta = 44237) or (t.cdcooper = 5 and t.nrdconta = 40525) or
(t.cdcooper = 5 and t.nrdconta = 31119) or (t.cdcooper = 5 and t.nrdconta = 28789) or (t.cdcooper = 5 and t.nrdconta = 37206) or
(t.cdcooper = 5 and t.nrdconta = 35009) or (t.cdcooper = 5 and t.nrdconta = 21261)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 6 and t.nrdconta = 149551) or (t.cdcooper = 6 and t.nrdconta = 73725) or (t.cdcooper = 6 and t.nrdconta = 104604) or
(t.cdcooper = 6 and t.nrdconta = 78395) or (t.cdcooper = 6 and t.nrdconta = 128384) or (t.cdcooper = 6 and t.nrdconta = 122190) or
(t.cdcooper = 6 and t.nrdconta = 122980) or (t.cdcooper = 6 and t.nrdconta = 57401) or (t.cdcooper = 6 and t.nrdconta = 59358) or
(t.cdcooper = 6 and t.nrdconta = 103438) or (t.cdcooper = 6 and t.nrdconta = 105708) or (t.cdcooper = 6 and t.nrdconta = 100277) or
(t.cdcooper = 6 and t.nrdconta = 105198) or (t.cdcooper = 6 and t.nrdconta = 103292) or (t.cdcooper = 6 and t.nrdconta = 34347) or
(t.cdcooper = 6 and t.nrdconta = 81027) or (t.cdcooper = 6 and t.nrdconta = 19569) or (t.cdcooper = 6 and t.nrdconta = 65986) or
(t.cdcooper = 6 and t.nrdconta = 70246) or (t.cdcooper = 6 and t.nrdconta = 66460) or (t.cdcooper = 6 and t.nrdconta = 64360) or
(t.cdcooper = 6 and t.nrdconta = 65994) or (t.cdcooper = 6 and t.nrdconta = 65803) or (t.cdcooper = 6 and t.nrdconta = 65773) or
(t.cdcooper = 6 and t.nrdconta = 64220) or (t.cdcooper = 6 and t.nrdconta = 51845) or (t.cdcooper = 6 and t.nrdconta = 64408) or
(t.cdcooper = 6 and t.nrdconta = 61140) or (t.cdcooper = 6 and t.nrdconta = 61778) or (t.cdcooper = 6 and t.nrdconta = 62162) or
(t.cdcooper = 6 and t.nrdconta = 61930) or (t.cdcooper = 6 and t.nrdconta = 61980) or (t.cdcooper = 6 and t.nrdconta = 61387) or
(t.cdcooper = 6 and t.nrdconta = 502243) or (t.cdcooper = 6 and t.nrdconta = 59943) or (t.cdcooper = 6 and t.nrdconta = 57835) or
(t.cdcooper = 6 and t.nrdconta = 57070) or (t.cdcooper = 6 and t.nrdconta = 59404) or (t.cdcooper = 6 and t.nrdconta = 59340) or
(t.cdcooper = 6 and t.nrdconta = 58637) or (t.cdcooper = 6 and t.nrdconta = 58327) or (t.cdcooper = 6 and t.nrdconta = 58114) or
(t.cdcooper = 6 and t.nrdconta = 57967) or (t.cdcooper = 6 and t.nrdconta = 58033) or (t.cdcooper = 6 and t.nrdconta = 56910) or
(t.cdcooper = 6 and t.nrdconta = 55573) or (t.cdcooper = 6 and t.nrdconta = 57274) or (t.cdcooper = 6 and t.nrdconta = 54399) or
(t.cdcooper = 6 and t.nrdconta = 44865) or (t.cdcooper = 6 and t.nrdconta = 55280) or (t.cdcooper = 6 and t.nrdconta = 54135) or
(t.cdcooper = 6 and t.nrdconta = 54909) or (t.cdcooper = 6 and t.nrdconta = 51950) or (t.cdcooper = 6 and t.nrdconta = 12700) or
(t.cdcooper = 6 and t.nrdconta = 13072) or (t.cdcooper = 6 and t.nrdconta = 13323) or (t.cdcooper = 6 and t.nrdconta = 14583) or
(t.cdcooper = 6 and t.nrdconta = 43397) or (t.cdcooper = 6 and t.nrdconta = 52590) or (t.cdcooper = 6 and t.nrdconta = 53031) or
(t.cdcooper = 6 and t.nrdconta = 14168) or (t.cdcooper = 6 and t.nrdconta = 43087) or (t.cdcooper = 6 and t.nrdconta = 13145) or
(t.cdcooper = 6 and t.nrdconta = 40347) or (t.cdcooper = 6 and t.nrdconta = 9156) or (t.cdcooper = 6 and t.nrdconta = 31801) or
(t.cdcooper = 6 and t.nrdconta = 6009) or (t.cdcooper = 6 and t.nrdconta = 2356) or (t.cdcooper = 6 and t.nrdconta = 4359)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 7 and t.nrdconta = 92800) or (t.cdcooper = 7 and t.nrdconta = 231274) or (t.cdcooper = 7 and t.nrdconta = 235954) or
(t.cdcooper = 7 and t.nrdconta = 218901) or (t.cdcooper = 7 and t.nrdconta = 320439) or (t.cdcooper = 7 and t.nrdconta = 312100) or
(t.cdcooper = 7 and t.nrdconta = 55662) or (t.cdcooper = 7 and t.nrdconta = 104809) or (t.cdcooper = 7 and t.nrdconta = 118729) or
(t.cdcooper = 7 and t.nrdconta = 131873) or (t.cdcooper = 7 and t.nrdconta = 149942) or (t.cdcooper = 7 and t.nrdconta = 146927) or
(t.cdcooper = 7 and t.nrdconta = 92231) or (t.cdcooper = 7 and t.nrdconta = 39594) or (t.cdcooper = 7 and t.nrdconta = 92843) or
(t.cdcooper = 7 and t.nrdconta = 78425) or (t.cdcooper = 7 and t.nrdconta = 236691) or (t.cdcooper = 7 and t.nrdconta = 247774) or
(t.cdcooper = 7 and t.nrdconta = 121509) or (t.cdcooper = 7 and t.nrdconta = 145572) or (t.cdcooper = 7 and t.nrdconta = 224359) or
(t.cdcooper = 7 and t.nrdconta = 226718) or (t.cdcooper = 7 and t.nrdconta = 94293) or (t.cdcooper = 7 and t.nrdconta = 188441) or
(t.cdcooper = 7 and t.nrdconta = 107093) or (t.cdcooper = 7 and t.nrdconta = 119156) or (t.cdcooper = 7 and t.nrdconta = 115959) or
(t.cdcooper = 7 and t.nrdconta = 330582) or (t.cdcooper = 7 and t.nrdconta = 260193) or (t.cdcooper = 7 and t.nrdconta = 146862) or
(t.cdcooper = 7 and t.nrdconta = 124265) or (t.cdcooper = 7 and t.nrdconta = 149012) or (t.cdcooper = 7 and t.nrdconta = 215490) or
(t.cdcooper = 7 and t.nrdconta = 147192) or (t.cdcooper = 7 and t.nrdconta = 128678) or (t.cdcooper = 7 and t.nrdconta = 132764) or
(t.cdcooper = 7 and t.nrdconta = 134066) or (t.cdcooper = 7 and t.nrdconta = 133019) or (t.cdcooper = 7 and t.nrdconta = 26115) or
(t.cdcooper = 7 and t.nrdconta = 151343) or (t.cdcooper = 7 and t.nrdconta = 193178) or (t.cdcooper = 7 and t.nrdconta = 321451) or
(t.cdcooper = 7 and t.nrdconta = 75493) or (t.cdcooper = 7 and t.nrdconta = 229660) or (t.cdcooper = 7 and t.nrdconta = 79570) or
(t.cdcooper = 7 and t.nrdconta = 282200) or (t.cdcooper = 7 and t.nrdconta = 54143) or (t.cdcooper = 7 and t.nrdconta = 151459) or
(t.cdcooper = 7 and t.nrdconta = 186961) or (t.cdcooper = 7 and t.nrdconta = 331716) or (t.cdcooper = 7 and t.nrdconta = 222500) or
(t.cdcooper = 7 and t.nrdconta = 103241) or (t.cdcooper = 7 and t.nrdconta = 312967) or (t.cdcooper = 7 and t.nrdconta = 97594) or
(t.cdcooper = 7 and t.nrdconta = 105481) or (t.cdcooper = 7 and t.nrdconta = 137782) or (t.cdcooper = 7 and t.nrdconta = 105228) or
(t.cdcooper = 7 and t.nrdconta = 228761) or (t.cdcooper = 7 and t.nrdconta = 221414) or (t.cdcooper = 7 and t.nrdconta = 229482) or
(t.cdcooper = 7 and t.nrdconta = 104825) or (t.cdcooper = 7 and t.nrdconta = 46981) or (t.cdcooper = 7 and t.nrdconta = 214604) or
(t.cdcooper = 7 and t.nrdconta = 93530) or (t.cdcooper = 7 and t.nrdconta = 330370) or (t.cdcooper = 7 and t.nrdconta = 227935) or
(t.cdcooper = 7 and t.nrdconta = 334880) or (t.cdcooper = 7 and t.nrdconta = 96598) or (t.cdcooper = 7 and t.nrdconta = 104108) or
(t.cdcooper = 7 and t.nrdconta = 77763) or (t.cdcooper = 7 and t.nrdconta = 117722) or (t.cdcooper = 7 and t.nrdconta = 135950) or
(t.cdcooper = 7 and t.nrdconta = 58009) or (t.cdcooper = 7 and t.nrdconta = 228494) or (t.cdcooper = 7 and t.nrdconta = 55123) or
(t.cdcooper = 7 and t.nrdconta = 156442) or (t.cdcooper = 7 and t.nrdconta = 225240) or (t.cdcooper = 7 and t.nrdconta = 154822) or
(t.cdcooper = 7 and t.nrdconta = 149616) or (t.cdcooper = 7 and t.nrdconta = 105180) or (t.cdcooper = 7 and t.nrdconta = 150150) or
(t.cdcooper = 7 and t.nrdconta = 93866) or (t.cdcooper = 7 and t.nrdconta = 146935) or (t.cdcooper = 7 and t.nrdconta = 260886) or
(t.cdcooper = 7 and t.nrdconta = 144720) or (t.cdcooper = 7 and t.nrdconta = 144215) or (t.cdcooper = 7 and t.nrdconta = 141631) or
(t.cdcooper = 7 and t.nrdconta = 223786) or (t.cdcooper = 7 and t.nrdconta = 106178) or (t.cdcooper = 7 and t.nrdconta = 229504) or
(t.cdcooper = 7 and t.nrdconta = 228877) or (t.cdcooper = 7 and t.nrdconta = 280259) or (t.cdcooper = 7 and t.nrdconta = 310328) or
(t.cdcooper = 7 and t.nrdconta = 228150) or (t.cdcooper = 7 and t.nrdconta = 108790) or (t.cdcooper = 7 and t.nrdconta = 270229) or
(t.cdcooper = 7 and t.nrdconta = 53767) or (t.cdcooper = 7 and t.nrdconta = 68993) or (t.cdcooper = 7 and t.nrdconta = 69078) or
(t.cdcooper = 7 and t.nrdconta = 239917) or (t.cdcooper = 7 and t.nrdconta = 235857) or (t.cdcooper = 7 and t.nrdconta = 65269) or
(t.cdcooper = 7 and t.nrdconta = 104850) or (t.cdcooper = 7 and t.nrdconta = 113450) or (t.cdcooper = 7 and t.nrdconta = 237248) or
(t.cdcooper = 7 and t.nrdconta = 108758) or (t.cdcooper = 7 and t.nrdconta = 104515) or (t.cdcooper = 7 and t.nrdconta = 105210) or
(t.cdcooper = 7 and t.nrdconta = 104353) or (t.cdcooper = 7 and t.nrdconta = 219495) or (t.cdcooper = 7 and t.nrdconta = 218812) or
(t.cdcooper = 7 and t.nrdconta = 238945) or (t.cdcooper = 7 and t.nrdconta = 59447) or (t.cdcooper = 7 and t.nrdconta = 59455) or
(t.cdcooper = 7 and t.nrdconta = 59463) or (t.cdcooper = 7 and t.nrdconta = 59480) or (t.cdcooper = 7 and t.nrdconta = 59560) or
(t.cdcooper = 7 and t.nrdconta = 59579) or (t.cdcooper = 7 and t.nrdconta = 59471) or (t.cdcooper = 7 and t.nrdconta = 59536) or
(t.cdcooper = 7 and t.nrdconta = 59587) or (t.cdcooper = 7 and t.nrdconta = 59595) or (t.cdcooper = 7 and t.nrdconta = 59609) or
(t.cdcooper = 7 and t.nrdconta = 59617) or (t.cdcooper = 7 and t.nrdconta = 59633) or (t.cdcooper = 7 and t.nrdconta = 58785) or
(t.cdcooper = 7 and t.nrdconta = 26182) or (t.cdcooper = 7 and t.nrdconta = 57630) or (t.cdcooper = 7 and t.nrdconta = 58017) or
(t.cdcooper = 7 and t.nrdconta = 331295) or (t.cdcooper = 7 and t.nrdconta = 92762) or (t.cdcooper = 7 and t.nrdconta = 332925) or
(t.cdcooper = 7 and t.nrdconta = 239771) or (t.cdcooper = 7 and t.nrdconta = 320838) or (t.cdcooper = 7 and t.nrdconta = 310581) or
(t.cdcooper = 7 and t.nrdconta = 230014) or (t.cdcooper = 7 and t.nrdconta = 311839) or (t.cdcooper = 7 and t.nrdconta = 97632) or
(t.cdcooper = 7 and t.nrdconta = 221694) or (t.cdcooper = 7 and t.nrdconta = 96679) or (t.cdcooper = 7 and t.nrdconta = 220906) or
(t.cdcooper = 7 and t.nrdconta = 229679) or (t.cdcooper = 7 and t.nrdconta = 223840) or (t.cdcooper = 7 and t.nrdconta = 235334) or
(t.cdcooper = 7 and t.nrdconta = 77500) or (t.cdcooper = 7 and t.nrdconta = 77518) or (t.cdcooper = 7 and t.nrdconta = 227579) or
(t.cdcooper = 7 and t.nrdconta = 225835) or (t.cdcooper = 7 and t.nrdconta = 43524) or (t.cdcooper = 7 and t.nrdconta = 93815) or
(t.cdcooper = 7 and t.nrdconta = 213586) or (t.cdcooper = 7 and t.nrdconta = 221570) or (t.cdcooper = 7 and t.nrdconta = 238589) or
(t.cdcooper = 7 and t.nrdconta = 242608) or (t.cdcooper = 7 and t.nrdconta = 25445) or (t.cdcooper = 7 and t.nrdconta = 225703) or
(t.cdcooper = 7 and t.nrdconta = 235490) or (t.cdcooper = 7 and t.nrdconta = 93050) or (t.cdcooper = 7 and t.nrdconta = 225606) or
(t.cdcooper = 7 and t.nrdconta = 225436) or (t.cdcooper = 7 and t.nrdconta = 225452) or (t.cdcooper = 7 and t.nrdconta = 225525) or
(t.cdcooper = 7 and t.nrdconta = 224626) or (t.cdcooper = 7 and t.nrdconta = 92169) or (t.cdcooper = 7 and t.nrdconta = 224723) or
(t.cdcooper = 7 and t.nrdconta = 215163) or (t.cdcooper = 7 and t.nrdconta = 90930) or (t.cdcooper = 7 and t.nrdconta = 90387) or
(t.cdcooper = 7 and t.nrdconta = 81256) or (t.cdcooper = 7 and t.nrdconta = 222968) or (t.cdcooper = 7 and t.nrdconta = 235709) or
(t.cdcooper = 7 and t.nrdconta = 234567) or (t.cdcooper = 7 and t.nrdconta = 222917) or (t.cdcooper = 7 and t.nrdconta = 234761) or
(t.cdcooper = 7 and t.nrdconta = 49450) or (t.cdcooper = 7 and t.nrdconta = 42811) or (t.cdcooper = 7 and t.nrdconta = 232882) or
(t.cdcooper = 7 and t.nrdconta = 220108) or (t.cdcooper = 7 and t.nrdconta = 48402) or (t.cdcooper = 7 and t.nrdconta = 43109) or
(t.cdcooper = 7 and t.nrdconta = 29122) or (t.cdcooper = 7 and t.nrdconta = 43346) or (t.cdcooper = 7 and t.nrdconta = 39055) or
(t.cdcooper = 7 and t.nrdconta = 43117) or (t.cdcooper = 7 and t.nrdconta = 28215) or (t.cdcooper = 7 and t.nrdconta = 13200) or
(t.cdcooper = 7 and t.nrdconta = 34444) or (t.cdcooper = 7 and t.nrdconta = 23000) or (t.cdcooper = 7 and t.nrdconta = 7927) or
(t.cdcooper = 7 and t.nrdconta = 17876)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 8 and t.nrdconta = 6297) or (t.cdcooper = 8 and t.nrdconta = 17590) or (t.cdcooper = 8 and t.nrdconta = 20842) or
(t.cdcooper = 8 and t.nrdconta = 21539) or (t.cdcooper = 8 and t.nrdconta = 23582) or (t.cdcooper = 8 and t.nrdconta = 36366) or
(t.cdcooper = 8 and t.nrdconta = 11002) or (t.cdcooper = 8 and t.nrdconta = 25976) or (t.cdcooper = 8 and t.nrdconta = 28002) or
(t.cdcooper = 8 and t.nrdconta = 41246) or (t.cdcooper = 8 and t.nrdconta = 8656) or (t.cdcooper = 8 and t.nrdconta = 12289) or
(t.cdcooper = 8 and t.nrdconta = 27235) or (t.cdcooper = 8 and t.nrdconta = 23710) or (t.cdcooper = 8 and t.nrdconta = 24422) or
(t.cdcooper = 8 and t.nrdconta = 16268) or (t.cdcooper = 8 and t.nrdconta = 4472) or (t.cdcooper = 8 and t.nrdconta = 15962) or
(t.cdcooper = 8 and t.nrdconta = 14001) or (t.cdcooper = 8 and t.nrdconta = 2020) or (t.cdcooper = 8 and t.nrdconta = 7994) or
(t.cdcooper = 8 and t.nrdconta = 140)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 9 and t.nrdconta = 263214) or (t.cdcooper = 9 and t.nrdconta = 29904) or (t.cdcooper = 9 and t.nrdconta = 906042) or
(t.cdcooper = 9 and t.nrdconta = 126403) or (t.cdcooper = 9 and t.nrdconta = 190608) or (t.cdcooper = 9 and t.nrdconta = 5126) or
(t.cdcooper = 9 and t.nrdconta = 30848) or (t.cdcooper = 9 and t.nrdconta = 34207) or (t.cdcooper = 9 and t.nrdconta = 53031) or
(t.cdcooper = 9 and t.nrdconta = 156442) or (t.cdcooper = 9 and t.nrdconta = 13900) or (t.cdcooper = 9 and t.nrdconta = 55832) or
(t.cdcooper = 9 and t.nrdconta = 68012) or (t.cdcooper = 9 and t.nrdconta = 88676) or (t.cdcooper = 9 and t.nrdconta = 187690) or
(t.cdcooper = 9 and t.nrdconta = 53775) or (t.cdcooper = 9 and t.nrdconta = 67121) or (t.cdcooper = 9 and t.nrdconta = 91871) or
(t.cdcooper = 9 and t.nrdconta = 16586) or (t.cdcooper = 9 and t.nrdconta = 33758) or (t.cdcooper = 9 and t.nrdconta = 78522) or
(t.cdcooper = 9 and t.nrdconta = 74861) or (t.cdcooper = 9 and t.nrdconta = 99503) or (t.cdcooper = 9 and t.nrdconta = 67458) or
(t.cdcooper = 9 and t.nrdconta = 164712) or (t.cdcooper = 9 and t.nrdconta = 83984) or (t.cdcooper = 9 and t.nrdconta = 62430) or
(t.cdcooper = 9 and t.nrdconta = 34118) or (t.cdcooper = 9 and t.nrdconta = 59099) or (t.cdcooper = 9 and t.nrdconta = 56863) or
(t.cdcooper = 9 and t.nrdconta = 187283) or (t.cdcooper = 9 and t.nrdconta = 80268) or (t.cdcooper = 9 and t.nrdconta = 187372) or
(t.cdcooper = 9 and t.nrdconta = 31658) or (t.cdcooper = 9 and t.nrdconta = 70114) or (t.cdcooper = 9 and t.nrdconta = 92959) or
(t.cdcooper = 9 and t.nrdconta = 31178) or (t.cdcooper = 9 and t.nrdconta = 44075) or (t.cdcooper = 9 and t.nrdconta = 93947) or
(t.cdcooper = 9 and t.nrdconta = 92754) or (t.cdcooper = 9 and t.nrdconta = 24015) or (t.cdcooper = 9 and t.nrdconta = 125717) or
(t.cdcooper = 9 and t.nrdconta = 48364) or (t.cdcooper = 9 and t.nrdconta = 87440) or (t.cdcooper = 9 and t.nrdconta = 43672) or
(t.cdcooper = 9 and t.nrdconta = 72397) or (t.cdcooper = 9 and t.nrdconta = 17361) or (t.cdcooper = 9 and t.nrdconta = 58378) or
(t.cdcooper = 9 and t.nrdconta = 28738) or (t.cdcooper = 9 and t.nrdconta = 111791) or (t.cdcooper = 9 and t.nrdconta = 34681) or
(t.cdcooper = 9 and t.nrdconta = 42005) or (t.cdcooper = 9 and t.nrdconta = 42676) or (t.cdcooper = 9 and t.nrdconta = 70432) or
(t.cdcooper = 9 and t.nrdconta = 89850) or (t.cdcooper = 9 and t.nrdconta = 23175) or (t.cdcooper = 9 and t.nrdconta = 71765) or
(t.cdcooper = 9 and t.nrdconta = 101834) or (t.cdcooper = 9 and t.nrdconta = 49115) or (t.cdcooper = 9 and t.nrdconta = 93203) or
(t.cdcooper = 9 and t.nrdconta = 66290) or (t.cdcooper = 9 and t.nrdconta = 94757) or (t.cdcooper = 9 and t.nrdconta = 32000) or
(t.cdcooper = 9 and t.nrdconta = 36641) or (t.cdcooper = 9 and t.nrdconta = 86088) or (t.cdcooper = 9 and t.nrdconta = 84638) or
(t.cdcooper = 9 and t.nrdconta = 63118) or (t.cdcooper = 9 and t.nrdconta = 72672) or (t.cdcooper = 9 and t.nrdconta = 51780) or
(t.cdcooper = 9 and t.nrdconta = 22411) or (t.cdcooper = 9 and t.nrdconta = 35750) or (t.cdcooper = 9 and t.nrdconta = 30708) or
(t.cdcooper = 9 and t.nrdconta = 73911) or (t.cdcooper = 9 and t.nrdconta = 58742) or (t.cdcooper = 9 and t.nrdconta = 45110) or
(t.cdcooper = 9 and t.nrdconta = 69868) or (t.cdcooper = 9 and t.nrdconta = 69213) or (t.cdcooper = 9 and t.nrdconta = 34398) or
(t.cdcooper = 9 and t.nrdconta = 61069) or (t.cdcooper = 9 and t.nrdconta = 65935) or (t.cdcooper = 9 and t.nrdconta = 62944) or
(t.cdcooper = 9 and t.nrdconta = 62995) or (t.cdcooper = 9 and t.nrdconta = 32050) or (t.cdcooper = 9 and t.nrdconta = 33286) or
(t.cdcooper = 9 and t.nrdconta = 33650) or (t.cdcooper = 9 and t.nrdconta = 53422) or (t.cdcooper = 9 and t.nrdconta = 56090) or
(t.cdcooper = 9 and t.nrdconta = 58432) or (t.cdcooper = 9 and t.nrdconta = 55280) or (t.cdcooper = 9 and t.nrdconta = 24660) or
(t.cdcooper = 9 and t.nrdconta = 48194) or (t.cdcooper = 9 and t.nrdconta = 49212) or (t.cdcooper = 9 and t.nrdconta = 58998) or
(t.cdcooper = 9 and t.nrdconta = 48968) or (t.cdcooper = 9 and t.nrdconta = 56820) or (t.cdcooper = 9 and t.nrdconta = 27006) or
(t.cdcooper = 9 and t.nrdconta = 44610) or (t.cdcooper = 9 and t.nrdconta = 48097) or (t.cdcooper = 9 and t.nrdconta = 40967) or
(t.cdcooper = 9 and t.nrdconta = 45675) or (t.cdcooper = 9 and t.nrdconta = 43559) or (t.cdcooper = 9 and t.nrdconta = 27448) or
(t.cdcooper = 9 and t.nrdconta = 11940) or (t.cdcooper = 9 and t.nrdconta = 35513) or (t.cdcooper = 9 and t.nrdconta = 36331) or
(t.cdcooper = 9 and t.nrdconta = 38466) or (t.cdcooper = 9 and t.nrdconta = 27588) or (t.cdcooper = 9 and t.nrdconta = 27308) or
(t.cdcooper = 9 and t.nrdconta = 26808) or (t.cdcooper = 9 and t.nrdconta = 15180) or (t.cdcooper = 9 and t.nrdconta = 34711) or
(t.cdcooper = 9 and t.nrdconta = 27340) or (t.cdcooper = 9 and t.nrdconta = 28215) or (t.cdcooper = 9 and t.nrdconta = 26379) or
(t.cdcooper = 9 and t.nrdconta = 25232) or (t.cdcooper = 9 and t.nrdconta = 11215) or (t.cdcooper = 9 and t.nrdconta = 19380) or
(t.cdcooper = 9 and t.nrdconta = 22888) or (t.cdcooper = 9 and t.nrdconta = 20540) or (t.cdcooper = 9 and t.nrdconta = 20982) or
(t.cdcooper = 9 and t.nrdconta = 15970) or (t.cdcooper = 9 and t.nrdconta = 15660) or (t.cdcooper = 9 and t.nrdconta = 15148) or
(t.cdcooper = 9 and t.nrdconta = 13331) or (t.cdcooper = 9 and t.nrdconta = 12467) or (t.cdcooper = 9 and t.nrdconta = 12475) or
(t.cdcooper = 9 and t.nrdconta = 5274) or (t.cdcooper = 9 and t.nrdconta = 10448) or (t.cdcooper = 9 and t.nrdconta = 12637) or
(t.cdcooper = 9 and t.nrdconta = 11258) or (t.cdcooper = 9 and t.nrdconta = 11274) or (t.cdcooper = 9 and t.nrdconta = 11479) or
(t.cdcooper = 9 and t.nrdconta = 11584) or (t.cdcooper = 9 and t.nrdconta = 12866) or (t.cdcooper = 9 and t.nrdconta = 8940) or
(t.cdcooper = 9 and t.nrdconta = 6700) or (t.cdcooper = 9 and t.nrdconta = 5754) 
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 10 and t.nrdconta = 15407) or (t.cdcooper = 10 and t.nrdconta = 199656) or (t.cdcooper = 10 and t.nrdconta = 16187) or
(t.cdcooper = 10 and t.nrdconta = 18384) or (t.cdcooper = 10 and t.nrdconta = 62219) or (t.cdcooper = 10 and t.nrdconta = 92690) or
(t.cdcooper = 10 and t.nrdconta = 63266) or (t.cdcooper = 10 and t.nrdconta = 22136) or (t.cdcooper = 10 and t.nrdconta = 18350) or
(t.cdcooper = 10 and t.nrdconta = 42030) or (t.cdcooper = 10 and t.nrdconta = 24287) or (t.cdcooper = 10 and t.nrdconta = 21865) or
(t.cdcooper = 10 and t.nrdconta = 28770) or (t.cdcooper = 10 and t.nrdconta = 12971) or (t.cdcooper = 10 and t.nrdconta = 20150) or
(t.cdcooper = 10 and t.nrdconta = 14850) or (t.cdcooper = 10 and t.nrdconta = 23957) or (t.cdcooper = 10 and t.nrdconta = 23485) or
(t.cdcooper = 10 and t.nrdconta = 9385) or (t.cdcooper = 10 and t.nrdconta = 17841) or (t.cdcooper = 10 and t.nrdconta = 17922) or
(t.cdcooper = 10 and t.nrdconta = 17736) or (t.cdcooper = 10 and t.nrdconta = 14370) or (t.cdcooper = 10 and t.nrdconta = 15148) or
(t.cdcooper = 10 and t.nrdconta = 10260) or (t.cdcooper = 10 and t.nrdconta = 15563) or (t.cdcooper = 10 and t.nrdconta = 14460) or
(t.cdcooper = 10 and t.nrdconta = 14559) or (t.cdcooper = 10 and t.nrdconta = 14176) or (t.cdcooper = 10 and t.nrdconta = 14320) or
(t.cdcooper = 10 and t.nrdconta = 12963) or (t.cdcooper = 10 and t.nrdconta = 12998) or (t.cdcooper = 10 and t.nrdconta = 12076) or
(t.cdcooper = 10 and t.nrdconta = 12165) or (t.cdcooper = 10 and t.nrdconta = 2968) or (t.cdcooper = 10 and t.nrdconta = 4090) or
(t.cdcooper = 10 and t.nrdconta = 5975) or (t.cdcooper = 10 and t.nrdconta = 6386)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 11 and t.nrdconta = 78441) or (t.cdcooper = 11 and t.nrdconta = 96938) or (t.cdcooper = 11 and t.nrdconta = 105066) or
(t.cdcooper = 11 and t.nrdconta = 108588) or (t.cdcooper = 11 and t.nrdconta = 205478) or (t.cdcooper = 11 and t.nrdconta = 221422) or
(t.cdcooper = 11 and t.nrdconta = 328421) or (t.cdcooper = 11 and t.nrdconta = 433292) or (t.cdcooper = 11 and t.nrdconta = 435252) or
(t.cdcooper = 11 and t.nrdconta = 52744) or (t.cdcooper = 11 and t.nrdconta = 78417) or (t.cdcooper = 11 and t.nrdconta = 3076024) or
(t.cdcooper = 11 and t.nrdconta = 161276) or (t.cdcooper = 11 and t.nrdconta = 504742) or (t.cdcooper = 11 and t.nrdconta = 430633) or
(t.cdcooper = 11 and t.nrdconta = 449989) or (t.cdcooper = 11 and t.nrdconta = 383716) or (t.cdcooper = 11 and t.nrdconta = 410977) or
(t.cdcooper = 11 and t.nrdconta = 103969) or (t.cdcooper = 11 and t.nrdconta = 104035) or (t.cdcooper = 11 and t.nrdconta = 407569) or
(t.cdcooper = 11 and t.nrdconta = 433209) or (t.cdcooper = 11 and t.nrdconta = 430030) or (t.cdcooper = 11 and t.nrdconta = 429350) or
(t.cdcooper = 11 and t.nrdconta = 471623) or (t.cdcooper = 11 and t.nrdconta = 433624) or (t.cdcooper = 11 and t.nrdconta = 75353) or
(t.cdcooper = 11 and t.nrdconta = 201898) or (t.cdcooper = 11 and t.nrdconta = 26417) or (t.cdcooper = 11 and t.nrdconta = 376051) or
(t.cdcooper = 11 and t.nrdconta = 61255) or (t.cdcooper = 11 and t.nrdconta = 34185) or (t.cdcooper = 11 and t.nrdconta = 430226) or
(t.cdcooper = 11 and t.nrdconta = 86568) or (t.cdcooper = 11 and t.nrdconta = 225770) or (t.cdcooper = 11 and t.nrdconta = 367966) or
(t.cdcooper = 11 and t.nrdconta = 96903) or (t.cdcooper = 11 and t.nrdconta = 125598) or (t.cdcooper = 11 and t.nrdconta = 126284) or
(t.cdcooper = 11 and t.nrdconta = 142867) or (t.cdcooper = 11 and t.nrdconta = 255297) or (t.cdcooper = 11 and t.nrdconta = 126551) or
(t.cdcooper = 11 and t.nrdconta = 84913) or (t.cdcooper = 11 and t.nrdconta = 168319) or (t.cdcooper = 11 and t.nrdconta = 64548) or
(t.cdcooper = 11 and t.nrdconta = 50725) or (t.cdcooper = 11 and t.nrdconta = 323063) or (t.cdcooper = 11 and t.nrdconta = 109274) or
(t.cdcooper = 11 and t.nrdconta = 127531) or (t.cdcooper = 11 and t.nrdconta = 305898) or (t.cdcooper = 11 and t.nrdconta = 9580) or
(t.cdcooper = 11 and t.nrdconta = 197033) or (t.cdcooper = 11 and t.nrdconta = 81833) or (t.cdcooper = 11 and t.nrdconta = 64254) or
(t.cdcooper = 11 and t.nrdconta = 85332) or (t.cdcooper = 11 and t.nrdconta = 77674) or (t.cdcooper = 11 and t.nrdconta = 65390) or
(t.cdcooper = 11 and t.nrdconta = 150690) or (t.cdcooper = 11 and t.nrdconta = 273600) or (t.cdcooper = 11 and t.nrdconta = 160725) or
(t.cdcooper = 11 and t.nrdconta = 161926) or (t.cdcooper = 11 and t.nrdconta = 86649) or (t.cdcooper = 11 and t.nrdconta = 264040) or
(t.cdcooper = 11 and t.nrdconta = 36056) or (t.cdcooper = 11 and t.nrdconta = 73032) or (t.cdcooper = 11 and t.nrdconta = 125946) or
(t.cdcooper = 11 and t.nrdconta = 90654) or (t.cdcooper = 11 and t.nrdconta = 112410) or (t.cdcooper = 11 and t.nrdconta = 143901) or
(t.cdcooper = 11 and t.nrdconta = 164356) or (t.cdcooper = 11 and t.nrdconta = 159000) or (t.cdcooper = 11 and t.nrdconta = 48763) or
(t.cdcooper = 11 and t.nrdconta = 55620) or (t.cdcooper = 11 and t.nrdconta = 91391) or (t.cdcooper = 11 and t.nrdconta = 98817) or
(t.cdcooper = 11 and t.nrdconta = 161900) or (t.cdcooper = 11 and t.nrdconta = 60364) or (t.cdcooper = 11 and t.nrdconta = 93742) or
(t.cdcooper = 11 and t.nrdconta = 159018) or (t.cdcooper = 11 and t.nrdconta = 17205) or (t.cdcooper = 11 and t.nrdconta = 5568) or
(t.cdcooper = 11 and t.nrdconta = 142719) or (t.cdcooper = 11 and t.nrdconta = 157147) or (t.cdcooper = 11 and t.nrdconta = 128279) or
(t.cdcooper = 11 and t.nrdconta = 92010) or (t.cdcooper = 11 and t.nrdconta = 105546) or (t.cdcooper = 11 and t.nrdconta = 141968) or
(t.cdcooper = 11 and t.nrdconta = 127353) or (t.cdcooper = 11 and t.nrdconta = 113735) or (t.cdcooper = 11 and t.nrdconta = 96822) or
(t.cdcooper = 11 and t.nrdconta = 98230) or (t.cdcooper = 11 and t.nrdconta = 101370) or (t.cdcooper = 11 and t.nrdconta = 97896) or
(t.cdcooper = 11 and t.nrdconta = 77852) or (t.cdcooper = 11 and t.nrdconta = 103900) or (t.cdcooper = 11 and t.nrdconta = 96610) or
(t.cdcooper = 11 and t.nrdconta = 93610) or (t.cdcooper = 11 and t.nrdconta = 89516) or (t.cdcooper = 11 and t.nrdconta = 89982) or
(t.cdcooper = 11 and t.nrdconta = 20990) or (t.cdcooper = 11 and t.nrdconta = 21237) or (t.cdcooper = 11 and t.nrdconta = 61395) or
(t.cdcooper = 11 and t.nrdconta = 23981) or (t.cdcooper = 11 and t.nrdconta = 55239) or (t.cdcooper = 11 and t.nrdconta = 21652) or
(t.cdcooper = 11 and t.nrdconta = 74330) or (t.cdcooper = 11 and t.nrdconta = 70300) or (t.cdcooper = 11 and t.nrdconta = 50474) or
(t.cdcooper = 11 and t.nrdconta = 30759) or (t.cdcooper = 11 and t.nrdconta = 71099) or (t.cdcooper = 11 and t.nrdconta = 76503) or
(t.cdcooper = 11 and t.nrdconta = 78271) or (t.cdcooper = 11 and t.nrdconta = 62901) or (t.cdcooper = 11 and t.nrdconta = 50733) or
(t.cdcooper = 11 and t.nrdconta = 65579) or (t.cdcooper = 11 and t.nrdconta = 42455) or (t.cdcooper = 11 and t.nrdconta = 16691) or
(t.cdcooper = 11 and t.nrdconta = 68896) or (t.cdcooper = 11 and t.nrdconta = 51810) or (t.cdcooper = 11 and t.nrdconta = 60356) or
(t.cdcooper = 11 and t.nrdconta = 3034) or (t.cdcooper = 11 and t.nrdconta = 41785) or (t.cdcooper = 11 and t.nrdconta = 30392) or
(t.cdcooper = 11 and t.nrdconta = 54607) or (t.cdcooper = 11 and t.nrdconta = 43192) or (t.cdcooper = 11 and t.nrdconta = 52434) or
(t.cdcooper = 11 and t.nrdconta = 53643) or (t.cdcooper = 11 and t.nrdconta = 5363) or (t.cdcooper = 11 and t.nrdconta = 6076) or
(t.cdcooper = 11 and t.nrdconta = 15016) or (t.cdcooper = 11 and t.nrdconta = 9563) or (t.cdcooper = 11 and t.nrdconta = 35653) or
(t.cdcooper = 11 and t.nrdconta = 16870) or (t.cdcooper = 11 and t.nrdconta = 4804) or (t.cdcooper = 11 and t.nrdconta = 8206) or
(t.cdcooper = 11 and t.nrdconta = 12548) or (t.cdcooper = 11 and t.nrdconta = 16667) or (t.cdcooper = 11 and t.nrdconta = 16713) or
(t.cdcooper = 11 and t.nrdconta = 17728) or (t.cdcooper = 11 and t.nrdconta = 14770) or (t.cdcooper = 11 and t.nrdconta = 1996) or
(t.cdcooper = 11 and t.nrdconta = 1988) or (t.cdcooper = 11 and t.nrdconta = 2909) or (t.cdcooper = 11 and t.nrdconta = 604) or
(t.cdcooper = 11 and t.nrdconta = 1384)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 12 and t.nrdconta = 14460) or (t.cdcooper = 12 and t.nrdconta = 30732) or (t.cdcooper = 12 and t.nrdconta = 12998) or
(t.cdcooper = 12 and t.nrdconta = 113794) or (t.cdcooper = 12 and t.nrdconta = 112968) or (t.cdcooper = 12 and t.nrdconta = 49964) or
(t.cdcooper = 12 and t.nrdconta = 49620) or (t.cdcooper = 12 and t.nrdconta = 17329) or (t.cdcooper = 12 and t.nrdconta = 12017) or
(t.cdcooper = 12 and t.nrdconta = 42129) or (t.cdcooper = 12 and t.nrdconta = 6084) or (t.cdcooper = 12 and t.nrdconta = 22144) or
(t.cdcooper = 12 and t.nrdconta = 20303) or (t.cdcooper = 12 and t.nrdconta = 14583) or (t.cdcooper = 12 and t.nrdconta = 15032) or
(t.cdcooper = 12 and t.nrdconta = 16551) or (t.cdcooper = 12 and t.nrdconta = 11983) or (t.cdcooper = 12 and t.nrdconta = 3271) or
(t.cdcooper = 12 and t.nrdconta = 20354) or (t.cdcooper = 12 and t.nrdconta = 15598) or (t.cdcooper = 12 and t.nrdconta = 15610) or
(t.cdcooper = 12 and t.nrdconta = 2925) or (t.cdcooper = 12 and t.nrdconta = 3468) or (t.cdcooper = 12 and t.nrdconta = 3972) or
(t.cdcooper = 12 and t.nrdconta = 6157)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 13 and t.nrdconta = 409707) or (t.cdcooper = 13 and t.nrdconta = 204056) or (t.cdcooper = 13 and t.nrdconta = 191400) or
(t.cdcooper = 13 and t.nrdconta = 73130) or (t.cdcooper = 13 and t.nrdconta = 412899) or (t.cdcooper = 13 and t.nrdconta = 38300) or
(t.cdcooper = 13 and t.nrdconta = 713511) or (t.cdcooper = 13 and t.nrdconta = 708666) or (t.cdcooper = 13 and t.nrdconta = 200751) or
(t.cdcooper = 13 and t.nrdconta = 26115) or (t.cdcooper = 13 and t.nrdconta = 232840) or (t.cdcooper = 13 and t.nrdconta = 233064) or
(t.cdcooper = 13 and t.nrdconta = 706728) or (t.cdcooper = 13 and t.nrdconta = 223522) or (t.cdcooper = 13 and t.nrdconta = 301329) or
(t.cdcooper = 13 and t.nrdconta = 301981) or (t.cdcooper = 13 and t.nrdconta = 202312) or (t.cdcooper = 13 and t.nrdconta = 9113) or
(t.cdcooper = 13 and t.nrdconta = 303089) or (t.cdcooper = 13 and t.nrdconta = 94412) or (t.cdcooper = 13 and t.nrdconta = 302309) or
(t.cdcooper = 13 and t.nrdconta = 26255) or (t.cdcooper = 13 and t.nrdconta = 91537) or (t.cdcooper = 13 and t.nrdconta = 19518) or
(t.cdcooper = 13 and t.nrdconta = 19720) or (t.cdcooper = 13 and t.nrdconta = 19895) or (t.cdcooper = 13 and t.nrdconta = 22675) or
(t.cdcooper = 13 and t.nrdconta = 8834) or (t.cdcooper = 13 and t.nrdconta = 10863) or (t.cdcooper = 13 and t.nrdconta = 2348)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 14 and t.nrdconta = 83011) or (t.cdcooper = 14 and t.nrdconta = 15288) or (t.cdcooper = 14 and t.nrdconta = 82422) or
(t.cdcooper = 14 and t.nrdconta = 56758) or (t.cdcooper = 14 and t.nrdconta = 114340) or (t.cdcooper = 14 and t.nrdconta = 36102) or
(t.cdcooper = 14 and t.nrdconta = 16420) or (t.cdcooper = 14 and t.nrdconta = 19941) or (t.cdcooper = 14 and t.nrdconta = 82627) or
(t.cdcooper = 14 and t.nrdconta = 15652) or (t.cdcooper = 14 and t.nrdconta = 57177) or (t.cdcooper = 14 and t.nrdconta = 24686) or
(t.cdcooper = 14 and t.nrdconta = 20702) or (t.cdcooper = 14 and t.nrdconta = 10200) or (t.cdcooper = 14 and t.nrdconta = 51535) or
(t.cdcooper = 14 and t.nrdconta = 30180) or (t.cdcooper = 14 and t.nrdconta = 16829) or (t.cdcooper = 14 and t.nrdconta = 18619) or
(t.cdcooper = 14 and t.nrdconta = 13129) or (t.cdcooper = 14 and t.nrdconta = 17248) or (t.cdcooper = 14 and t.nrdconta = 3980) or
(t.cdcooper = 14 and t.nrdconta = 9024) or (t.cdcooper = 14 and t.nrdconta = 1210) or (t.cdcooper = 14 and t.nrdconta = 4600) or
(t.cdcooper = 14 and t.nrdconta = 4383) 
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 16 and t.nrdconta = 655) or (t.cdcooper = 16 and t.nrdconta = 15180) or (t.cdcooper = 16 and t.nrdconta = 69450) or
(t.cdcooper = 16 and t.nrdconta = 6554431) or (t.cdcooper = 16 and t.nrdconta = 6554962) or (t.cdcooper = 16 and t.nrdconta = 163031) or
(t.cdcooper = 16 and t.nrdconta = 207446) or (t.cdcooper = 16 and t.nrdconta = 240389) or (t.cdcooper = 16 and t.nrdconta = 412023) or
(t.cdcooper = 16 and t.nrdconta = 416312) or (t.cdcooper = 16 and t.nrdconta = 417068) or (t.cdcooper = 16 and t.nrdconta = 339253) or
(t.cdcooper = 16 and t.nrdconta = 251194) or (t.cdcooper = 16 and t.nrdconta = 276081) or (t.cdcooper = 16 and t.nrdconta = 409391) or
(t.cdcooper = 16 and t.nrdconta = 416037) or (t.cdcooper = 16 and t.nrdconta = 498696) or (t.cdcooper = 16 and t.nrdconta = 2459337) or
(t.cdcooper = 16 and t.nrdconta = 26328) or (t.cdcooper = 16 and t.nrdconta = 1864793) or (t.cdcooper = 16 and t.nrdconta = 3030580) or
(t.cdcooper = 16 and t.nrdconta = 248010) or (t.cdcooper = 16 and t.nrdconta = 58700) or (t.cdcooper = 16 and t.nrdconta = 2136309) or
(t.cdcooper = 16 and t.nrdconta = 157244) or (t.cdcooper = 16 and t.nrdconta = 55700) or (t.cdcooper = 16 and t.nrdconta = 3986837) or
(t.cdcooper = 16 and t.nrdconta = 82139) or (t.cdcooper = 16 and t.nrdconta = 91537) or (t.cdcooper = 16 and t.nrdconta = 2136236) or
(t.cdcooper = 16 and t.nrdconta = 4383) or (t.cdcooper = 16 and t.nrdconta = 2409020) or (t.cdcooper = 16 and t.nrdconta = 41556) or
(t.cdcooper = 16 and t.nrdconta = 6641482) or (t.cdcooper = 16 and t.nrdconta = 3587215) or (t.cdcooper = 16 and t.nrdconta = 46582) or
(t.cdcooper = 16 and t.nrdconta = 11762) or (t.cdcooper = 16 and t.nrdconta = 25569) or (t.cdcooper = 16 and t.nrdconta = 87416) or
(t.cdcooper = 16 and t.nrdconta = 2284189) or (t.cdcooper = 16 and t.nrdconta = 2931729) or (t.cdcooper = 16 and t.nrdconta = 38245) or
(t.cdcooper = 16 and t.nrdconta = 36722) or (t.cdcooper = 16 and t.nrdconta = 18058) or (t.cdcooper = 16 and t.nrdconta = 3675777) or
(t.cdcooper = 16 and t.nrdconta = 2131668) or (t.cdcooper = 16 and t.nrdconta = 3835936) or (t.cdcooper = 16 and t.nrdconta = 6597505) or
(t.cdcooper = 16 and t.nrdconta = 6268714) or (t.cdcooper = 16 and t.nrdconta = 6370160) or (t.cdcooper = 16 and t.nrdconta = 6399983) or
(t.cdcooper = 16 and t.nrdconta = 6597599) or (t.cdcooper = 16 and t.nrdconta = 3679900) or (t.cdcooper = 16 and t.nrdconta = 2734257) or
(t.cdcooper = 16 and t.nrdconta = 3679861) or (t.cdcooper = 16 and t.nrdconta = 3802612) or (t.cdcooper = 16 and t.nrdconta = 3818403) or
(t.cdcooper = 16 and t.nrdconta = 2036657) or (t.cdcooper = 16 and t.nrdconta = 3678350) or (t.cdcooper = 16 and t.nrdconta = 2799081) or
(t.cdcooper = 16 and t.nrdconta = 1835890) or (t.cdcooper = 16 and t.nrdconta = 2207532) or (t.cdcooper = 16 and t.nrdconta = 2767325) or
(t.cdcooper = 16 and t.nrdconta = 2599449) or (t.cdcooper = 16 and t.nrdconta = 963437) or (t.cdcooper = 16 and t.nrdconta = 965138) or
(t.cdcooper = 16 and t.nrdconta = 612944) or (t.cdcooper = 16 and t.nrdconta = 951463) or (t.cdcooper = 16 and t.nrdconta = 3131548) or
(t.cdcooper = 16 and t.nrdconta = 964794)
           )
union
    SELECT t.flgctitg, t.cdcooper, t.nrdconta, 3 newsit
      FROM CRAPASS t
     where (
(t.cdcooper = 1 and t.nrdconta = 906697) or (t.cdcooper = 1 and t.nrdconta = 3123910) or (t.cdcooper = 2 and t.nrdconta = 3115) or
(t.cdcooper = 2 and t.nrdconta = 4464) or (t.cdcooper = 2 and t.nrdconta = 20826) or (t.cdcooper = 2 and t.nrdconta = 23540) or
(t.cdcooper = 2 and t.nrdconta = 31038) or (t.cdcooper = 2 and t.nrdconta = 32794) or (t.cdcooper = 2 and t.nrdconta = 39454) or
(t.cdcooper = 2 and t.nrdconta = 50040) or (t.cdcooper = 2 and t.nrdconta = 50059) or (t.cdcooper = 2 and t.nrdconta = 50156) or
(t.cdcooper = 2 and t.nrdconta = 50229) or (t.cdcooper = 2 and t.nrdconta = 50261) or (t.cdcooper = 2 and t.nrdconta = 50369) or
(t.cdcooper = 2 and t.nrdconta = 50377) or (t.cdcooper = 2 and t.nrdconta = 50385) or (t.cdcooper = 2 and t.nrdconta = 50458) or
(t.cdcooper = 2 and t.nrdconta = 50652) or (t.cdcooper = 2 and t.nrdconta = 50717) or (t.cdcooper = 2 and t.nrdconta = 50725) or
(t.cdcooper = 2 and t.nrdconta = 50733) or (t.cdcooper = 2 and t.nrdconta = 50741) or (t.cdcooper = 2 and t.nrdconta = 50784) or
(t.cdcooper = 2 and t.nrdconta = 50873) or (t.cdcooper = 2 and t.nrdconta = 50911) or (t.cdcooper = 2 and t.nrdconta = 50989) or
(t.cdcooper = 2 and t.nrdconta = 51080) or (t.cdcooper = 2 and t.nrdconta = 51152) or (t.cdcooper = 2 and t.nrdconta = 51187) or
(t.cdcooper = 2 and t.nrdconta = 51217) or (t.cdcooper = 2 and t.nrdconta = 51330) or (t.cdcooper = 2 and t.nrdconta = 51381) or
(t.cdcooper = 2 and t.nrdconta = 51462) or (t.cdcooper = 2 and t.nrdconta = 51551) or (t.cdcooper = 2 and t.nrdconta = 51608) or
(t.cdcooper = 2 and t.nrdconta = 51675) or (t.cdcooper = 2 and t.nrdconta = 51802) or (t.cdcooper = 2 and t.nrdconta = 51810) or
(t.cdcooper = 2 and t.nrdconta = 51896) or (t.cdcooper = 2 and t.nrdconta = 51985) or (t.cdcooper = 2 and t.nrdconta = 52027) or
(t.cdcooper = 2 and t.nrdconta = 52140) or (t.cdcooper = 2 and t.nrdconta = 52221) or (t.cdcooper = 2 and t.nrdconta = 52230) or
(t.cdcooper = 2 and t.nrdconta = 52248) or (t.cdcooper = 2 and t.nrdconta = 52388) or (t.cdcooper = 2 and t.nrdconta = 52400) or
(t.cdcooper = 2 and t.nrdconta = 52604) or (t.cdcooper = 2 and t.nrdconta = 52612) or (t.cdcooper = 2 and t.nrdconta = 53031) or
(t.cdcooper = 2 and t.nrdconta = 53090) or (t.cdcooper = 2 and t.nrdconta = 53228) or (t.cdcooper = 2 and t.nrdconta = 53252) or
(t.cdcooper = 2 and t.nrdconta = 53287) or (t.cdcooper = 2 and t.nrdconta = 53392) or (t.cdcooper = 2 and t.nrdconta = 53589) or
(t.cdcooper = 2 and t.nrdconta = 53600) or (t.cdcooper = 2 and t.nrdconta = 53643) or (t.cdcooper = 2 and t.nrdconta = 53686) or
(t.cdcooper = 2 and t.nrdconta = 53732) or (t.cdcooper = 2 and t.nrdconta = 53961) or (t.cdcooper = 2 and t.nrdconta = 54020) or
(t.cdcooper = 2 and t.nrdconta = 54038) or (t.cdcooper = 2 and t.nrdconta = 54046) or (t.cdcooper = 2 and t.nrdconta = 54054) or
(t.cdcooper = 2 and t.nrdconta = 54119) or (t.cdcooper = 2 and t.nrdconta = 54135) or (t.cdcooper = 2 and t.nrdconta = 54313) or
(t.cdcooper = 2 and t.nrdconta = 54330) or (t.cdcooper = 2 and t.nrdconta = 54437) or (t.cdcooper = 2 and t.nrdconta = 54500) or
(t.cdcooper = 2 and t.nrdconta = 54674) or (t.cdcooper = 2 and t.nrdconta = 54976) or (t.cdcooper = 2 and t.nrdconta = 59315) or
(t.cdcooper = 2 and t.nrdconta = 59897) or (t.cdcooper = 2 and t.nrdconta = 70025) or (t.cdcooper = 2 and t.nrdconta = 70092) or
(t.cdcooper = 2 and t.nrdconta = 70262) or (t.cdcooper = 2 and t.nrdconta = 70300) or (t.cdcooper = 2 and t.nrdconta = 70343) or
(t.cdcooper = 2 and t.nrdconta = 70360) or (t.cdcooper = 2 and t.nrdconta = 70742) or (t.cdcooper = 2 and t.nrdconta = 70793) or
(t.cdcooper = 2 and t.nrdconta = 70882) or (t.cdcooper = 2 and t.nrdconta = 70904) or (t.cdcooper = 2 and t.nrdconta = 70980) or
(t.cdcooper = 2 and t.nrdconta = 71102) or (t.cdcooper = 2 and t.nrdconta = 71382) or (t.cdcooper = 2 and t.nrdconta = 71404) or
(t.cdcooper = 2 and t.nrdconta = 71412) or (t.cdcooper = 2 and t.nrdconta = 71471) or (t.cdcooper = 2 and t.nrdconta = 71528) or
(t.cdcooper = 2 and t.nrdconta = 71560) or (t.cdcooper = 2 and t.nrdconta = 71609) or (t.cdcooper = 2 and t.nrdconta = 71617) or
(t.cdcooper = 2 and t.nrdconta = 71633) or (t.cdcooper = 2 and t.nrdconta = 71870) or (t.cdcooper = 2 and t.nrdconta = 72362) or
(t.cdcooper = 2 and t.nrdconta = 72524) or (t.cdcooper = 2 and t.nrdconta = 72583) or (t.cdcooper = 2 and t.nrdconta = 72656) or
(t.cdcooper = 2 and t.nrdconta = 72729) or (t.cdcooper = 2 and t.nrdconta = 72826) or (t.cdcooper = 2 and t.nrdconta = 72850) or
(t.cdcooper = 2 and t.nrdconta = 72931) or (t.cdcooper = 2 and t.nrdconta = 72990) or (t.cdcooper = 2 and t.nrdconta = 73040) or
(t.cdcooper = 2 and t.nrdconta = 73113) or (t.cdcooper = 2 and t.nrdconta = 73440) or (t.cdcooper = 2 and t.nrdconta = 73490) or
(t.cdcooper = 2 and t.nrdconta = 73571) or (t.cdcooper = 2 and t.nrdconta = 73598) or (t.cdcooper = 2 and t.nrdconta = 73865) or
(t.cdcooper = 2 and t.nrdconta = 73954) or (t.cdcooper = 2 and t.nrdconta = 74136) or (t.cdcooper = 2 and t.nrdconta = 74365) or
(t.cdcooper = 2 and t.nrdconta = 74373) or (t.cdcooper = 2 and t.nrdconta = 74853) or (t.cdcooper = 2 and t.nrdconta = 74861) or
(t.cdcooper = 2 and t.nrdconta = 74969) or (t.cdcooper = 2 and t.nrdconta = 75060) or (t.cdcooper = 2 and t.nrdconta = 75183) or
(t.cdcooper = 2 and t.nrdconta = 75256) or (t.cdcooper = 2 and t.nrdconta = 75264) or (t.cdcooper = 2 and t.nrdconta = 75299) or
(t.cdcooper = 2 and t.nrdconta = 75388) or (t.cdcooper = 2 and t.nrdconta = 75396) or (t.cdcooper = 2 and t.nrdconta = 75434) or
(t.cdcooper = 2 and t.nrdconta = 75680) or (t.cdcooper = 2 and t.nrdconta = 75833) or (t.cdcooper = 2 and t.nrdconta = 76120) or
(t.cdcooper = 2 and t.nrdconta = 76147) or (t.cdcooper = 2 and t.nrdconta = 76201) or (t.cdcooper = 2 and t.nrdconta = 76236) or
(t.cdcooper = 2 and t.nrdconta = 76384) or (t.cdcooper = 2 and t.nrdconta = 76589) or (t.cdcooper = 2 and t.nrdconta = 76732) or
(t.cdcooper = 2 and t.nrdconta = 76767) or (t.cdcooper = 2 and t.nrdconta = 76830) or (t.cdcooper = 2 and t.nrdconta = 76953) or
(t.cdcooper = 2 and t.nrdconta = 76996) or (t.cdcooper = 2 and t.nrdconta = 77372) or (t.cdcooper = 2 and t.nrdconta = 77488) or
(t.cdcooper = 2 and t.nrdconta = 77615) or (t.cdcooper = 2 and t.nrdconta = 77712) or (t.cdcooper = 2 and t.nrdconta = 77780) or
(t.cdcooper = 2 and t.nrdconta = 77844) or (t.cdcooper = 2 and t.nrdconta = 77852) or (t.cdcooper = 2 and t.nrdconta = 77925) or
(t.cdcooper = 2 and t.nrdconta = 78018) or (t.cdcooper = 2 and t.nrdconta = 78220) or (t.cdcooper = 2 and t.nrdconta = 78310) or
(t.cdcooper = 2 and t.nrdconta = 78735) or (t.cdcooper = 2 and t.nrdconta = 78808) or (t.cdcooper = 2 and t.nrdconta = 79219) or
(t.cdcooper = 2 and t.nrdconta = 79340) or (t.cdcooper = 2 and t.nrdconta = 79570) or (t.cdcooper = 2 and t.nrdconta = 79642) or
(t.cdcooper = 2 and t.nrdconta = 79693) or (t.cdcooper = 2 and t.nrdconta = 79790) or (t.cdcooper = 2 and t.nrdconta = 80004) or
(t.cdcooper = 2 and t.nrdconta = 81043) or (t.cdcooper = 2 and t.nrdconta = 83160) or (t.cdcooper = 2 and t.nrdconta = 88110) or
(t.cdcooper = 2 and t.nrdconta = 95397) or (t.cdcooper = 2 and t.nrdconta = 96539) or (t.cdcooper = 2 and t.nrdconta = 96865) or
(t.cdcooper = 2 and t.nrdconta = 101150) or (t.cdcooper = 2 and t.nrdconta = 102750) or (t.cdcooper = 2 and t.nrdconta = 105252) or
(t.cdcooper = 2 and t.nrdconta = 106488) or (t.cdcooper = 2 and t.nrdconta = 108480) or (t.cdcooper = 2 and t.nrdconta = 109118) or
(t.cdcooper = 2 and t.nrdconta = 110078) or (t.cdcooper = 2 and t.nrdconta = 110205) or (t.cdcooper = 2 and t.nrdconta = 110388) or
(t.cdcooper = 2 and t.nrdconta = 110418) or (t.cdcooper = 2 and t.nrdconta = 110469) or (t.cdcooper = 2 and t.nrdconta = 110620) or
(t.cdcooper = 2 and t.nrdconta = 110655) or (t.cdcooper = 2 and t.nrdconta = 110663) or (t.cdcooper = 2 and t.nrdconta = 110787) or
(t.cdcooper = 2 and t.nrdconta = 110892) or (t.cdcooper = 2 and t.nrdconta = 110965) or (t.cdcooper = 2 and t.nrdconta = 111155) or
(t.cdcooper = 2 and t.nrdconta = 111163) or (t.cdcooper = 2 and t.nrdconta = 111406) or (t.cdcooper = 2 and t.nrdconta = 111422) or
(t.cdcooper = 2 and t.nrdconta = 111430) or (t.cdcooper = 2 and t.nrdconta = 111449) or (t.cdcooper = 2 and t.nrdconta = 111457) or
(t.cdcooper = 2 and t.nrdconta = 111465) or (t.cdcooper = 2 and t.nrdconta = 111481) or (t.cdcooper = 2 and t.nrdconta = 111600) or
(t.cdcooper = 2 and t.nrdconta = 111627) or (t.cdcooper = 2 and t.nrdconta = 111686) or (t.cdcooper = 2 and t.nrdconta = 111732) or
(t.cdcooper = 2 and t.nrdconta = 111880) or (t.cdcooper = 2 and t.nrdconta = 112518) or (t.cdcooper = 2 and t.nrdconta = 112542) or
(t.cdcooper = 2 and t.nrdconta = 112593) or (t.cdcooper = 2 and t.nrdconta = 112712) or (t.cdcooper = 2 and t.nrdconta = 113280) or
(t.cdcooper = 2 and t.nrdconta = 113395) or (t.cdcooper = 2 and t.nrdconta = 121100) or (t.cdcooper = 2 and t.nrdconta = 122475) or
(t.cdcooper = 2 and t.nrdconta = 122645) or (t.cdcooper = 2 and t.nrdconta = 122726) or (t.cdcooper = 2 and t.nrdconta = 122904) or
(t.cdcooper = 2 and t.nrdconta = 122971) or (t.cdcooper = 2 and t.nrdconta = 123021) or (t.cdcooper = 2 and t.nrdconta = 123226) or
(t.cdcooper = 2 and t.nrdconta = 123285) or (t.cdcooper = 2 and t.nrdconta = 134317) or (t.cdcooper = 2 and t.nrdconta = 134376) or
(t.cdcooper = 2 and t.nrdconta = 134384) or (t.cdcooper = 2 and t.nrdconta = 134538) or (t.cdcooper = 2 and t.nrdconta = 134570) or
(t.cdcooper = 2 and t.nrdconta = 135038) or (t.cdcooper = 2 and t.nrdconta = 135127) or (t.cdcooper = 2 and t.nrdconta = 135143) or
(t.cdcooper = 2 and t.nrdconta = 136298) or (t.cdcooper = 2 and t.nrdconta = 136336) or (t.cdcooper = 2 and t.nrdconta = 136379) or
(t.cdcooper = 2 and t.nrdconta = 136433) or (t.cdcooper = 2 and t.nrdconta = 136441) or (t.cdcooper = 2 and t.nrdconta = 136484) or
(t.cdcooper = 2 and t.nrdconta = 136549) or (t.cdcooper = 2 and t.nrdconta = 136638) or (t.cdcooper = 2 and t.nrdconta = 136794) or
(t.cdcooper = 2 and t.nrdconta = 155292) or (t.cdcooper = 2 and t.nrdconta = 160008) or (t.cdcooper = 2 and t.nrdconta = 160300) or
(t.cdcooper = 2 and t.nrdconta = 160997) or (t.cdcooper = 2 and t.nrdconta = 161004) or (t.cdcooper = 2 and t.nrdconta = 161012) or
(t.cdcooper = 2 and t.nrdconta = 161020) or (t.cdcooper = 2 and t.nrdconta = 161055) or (t.cdcooper = 2 and t.nrdconta = 161110) or
(t.cdcooper = 2 and t.nrdconta = 161900) or (t.cdcooper = 2 and t.nrdconta = 162183) or (t.cdcooper = 2 and t.nrdconta = 162680) or
(t.cdcooper = 2 and t.nrdconta = 163007) or (t.cdcooper = 2 and t.nrdconta = 163325) or (t.cdcooper = 2 and t.nrdconta = 163376) or
(t.cdcooper = 2 and t.nrdconta = 163384) or (t.cdcooper = 2 and t.nrdconta = 163732) or (t.cdcooper = 2 and t.nrdconta = 163961) or
(t.cdcooper = 2 and t.nrdconta = 164046) or (t.cdcooper = 2 and t.nrdconta = 164062) or (t.cdcooper = 2 and t.nrdconta = 164070) or
(t.cdcooper = 2 and t.nrdconta = 164666) or (t.cdcooper = 2 and t.nrdconta = 164682) or (t.cdcooper = 2 and t.nrdconta = 164771) or
(t.cdcooper = 2 and t.nrdconta = 165174) or (t.cdcooper = 2 and t.nrdconta = 165310) or (t.cdcooper = 2 and t.nrdconta = 165395) or
(t.cdcooper = 2 and t.nrdconta = 165611) or (t.cdcooper = 2 and t.nrdconta = 165794) or (t.cdcooper = 2 and t.nrdconta = 166642) or
(t.cdcooper = 2 and t.nrdconta = 168076) or (t.cdcooper = 2 and t.nrdconta = 168211) or (t.cdcooper = 2 and t.nrdconta = 169099) or
(t.cdcooper = 2 and t.nrdconta = 169366) or (t.cdcooper = 2 and t.nrdconta = 169447) or (t.cdcooper = 2 and t.nrdconta = 169641) or
(t.cdcooper = 2 and t.nrdconta = 169790) or (t.cdcooper = 2 and t.nrdconta = 184330) or (t.cdcooper = 2 and t.nrdconta = 220841) or
(t.cdcooper = 2 and t.nrdconta = 221074) or (t.cdcooper = 2 and t.nrdconta = 221449) or (t.cdcooper = 2 and t.nrdconta = 221813) or
(t.cdcooper = 2 and t.nrdconta = 222631) or (t.cdcooper = 2 and t.nrdconta = 222852) or (t.cdcooper = 2 and t.nrdconta = 223247) or
(t.cdcooper = 2 and t.nrdconta = 223727) or (t.cdcooper = 2 and t.nrdconta = 223948) or (t.cdcooper = 2 and t.nrdconta = 224898) or
(t.cdcooper = 2 and t.nrdconta = 260061) or (t.cdcooper = 2 and t.nrdconta = 260070) or (t.cdcooper = 2 and t.nrdconta = 260274) or
(t.cdcooper = 2 and t.nrdconta = 260304) or (t.cdcooper = 2 and t.nrdconta = 260347) or (t.cdcooper = 2 and t.nrdconta = 260380) or
(t.cdcooper = 2 and t.nrdconta = 260398) or (t.cdcooper = 2 and t.nrdconta = 260401) or (t.cdcooper = 2 and t.nrdconta = 260541) or
(t.cdcooper = 2 and t.nrdconta = 260746) or (t.cdcooper = 2 and t.nrdconta = 260860) or (t.cdcooper = 2 and t.nrdconta = 261009) or
(t.cdcooper = 2 and t.nrdconta = 261025) or (t.cdcooper = 2 and t.nrdconta = 261149) or (t.cdcooper = 2 and t.nrdconta = 261297) or
(t.cdcooper = 2 and t.nrdconta = 261394) or (t.cdcooper = 2 and t.nrdconta = 261459) or (t.cdcooper = 2 and t.nrdconta = 261629) or
(t.cdcooper = 2 and t.nrdconta = 261637) or (t.cdcooper = 2 and t.nrdconta = 261998) or (t.cdcooper = 2 and t.nrdconta = 262188) or
(t.cdcooper = 2 and t.nrdconta = 262242) or (t.cdcooper = 2 and t.nrdconta = 262650) or (t.cdcooper = 2 and t.nrdconta = 262714) or
(t.cdcooper = 2 and t.nrdconta = 262757) or (t.cdcooper = 2 and t.nrdconta = 262773) or (t.cdcooper = 2 and t.nrdconta = 263141) or
(t.cdcooper = 2 and t.nrdconta = 263222) or (t.cdcooper = 2 and t.nrdconta = 263419) or (t.cdcooper = 2 and t.nrdconta = 263427) or
(t.cdcooper = 2 and t.nrdconta = 263451) or (t.cdcooper = 2 and t.nrdconta = 263575) or (t.cdcooper = 2 and t.nrdconta = 263591) or
(t.cdcooper = 2 and t.nrdconta = 263745) or (t.cdcooper = 2 and t.nrdconta = 263915) or (t.cdcooper = 2 and t.nrdconta = 264130) or
(t.cdcooper = 2 and t.nrdconta = 264377) or (t.cdcooper = 2 and t.nrdconta = 264580) or (t.cdcooper = 2 and t.nrdconta = 264814) or
(t.cdcooper = 2 and t.nrdconta = 265012) or (t.cdcooper = 2 and t.nrdconta = 265020) or (t.cdcooper = 2 and t.nrdconta = 265250) or
(t.cdcooper = 2 and t.nrdconta = 265268) or (t.cdcooper = 2 and t.nrdconta = 265578) or (t.cdcooper = 2 and t.nrdconta = 265837) or
(t.cdcooper = 2 and t.nrdconta = 265934) or (t.cdcooper = 2 and t.nrdconta = 265993) or (t.cdcooper = 2 and t.nrdconta = 266051) or
(t.cdcooper = 2 and t.nrdconta = 266094) or (t.cdcooper = 2 and t.nrdconta = 266256) or (t.cdcooper = 2 and t.nrdconta = 266469) or
(t.cdcooper = 2 and t.nrdconta = 266485) or (t.cdcooper = 2 and t.nrdconta = 266523) or (t.cdcooper = 2 and t.nrdconta = 266698) or
(t.cdcooper = 2 and t.nrdconta = 266779) or (t.cdcooper = 2 and t.nrdconta = 266817) or (t.cdcooper = 2 and t.nrdconta = 266833) or
(t.cdcooper = 2 and t.nrdconta = 267260) or (t.cdcooper = 2 and t.nrdconta = 269603) or (t.cdcooper = 7 and t.nrdconta = 80993) or
(t.cdcooper = 11 and t.nrdconta = 1686) or (t.cdcooper = 11 and t.nrdconta = 71277) or (t.cdcooper = 11 and t.nrdconta = 196703) or
(t.cdcooper = 11 and t.nrdconta = 272876) or (t.cdcooper = 16 and t.nrdconta = 239615) or (t.cdcooper = 16 and t.nrdconta = 288349) or
(t.cdcooper = 16 and t.nrdconta = 346640) or (t.cdcooper = 16 and t.nrdconta = 525600) or (t.cdcooper = 16 and t.nrdconta = 931586) or
(t.cdcooper = 16 and t.nrdconta = 2036665) or (t.cdcooper = 16 and t.nrdconta = 2037866) or (t.cdcooper = 16 and t.nrdconta = 2064057) or
(t.cdcooper = 16 and t.nrdconta = 2064197) or (t.cdcooper = 16 and t.nrdconta = 2156474) or (t.cdcooper = 16 and t.nrdconta = 2410460) or
(t.cdcooper = 16 and t.nrdconta = 2410559) or (t.cdcooper = 16 and t.nrdconta = 2430061) or (t.cdcooper = 16 and t.nrdconta = 2499860) or
(t.cdcooper = 16 and t.nrdconta = 2557517) or (t.cdcooper = 16 and t.nrdconta = 2731002) or (t.cdcooper = 16 and t.nrdconta = 2841100) or
(t.cdcooper = 16 and t.nrdconta = 2902397) or (t.cdcooper = 16 and t.nrdconta = 2986671) or (t.cdcooper = 16 and t.nrdconta = 3076822) or
(t.cdcooper = 16 and t.nrdconta = 3540189) or (t.cdcooper = 16 and t.nrdconta = 6096123) or (t.cdcooper = 16 and t.nrdconta = 6255477) or
(t.cdcooper = 16 and t.nrdconta = 6437486) or (t.cdcooper = 16 and t.nrdconta = 6467601) or (t.cdcooper = 16 and t.nrdconta = 6554881) or
(t.cdcooper = 16 and t.nrdconta = 6596975) or (t.cdcooper = 16 and t.nrdconta = 6734731) or (t.cdcooper = 16 and t.nrdconta = 6764380)     
           )           
;

 
rg_crapass cr_crapass%rowtype;

BEGIN
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := GENE0002.fn_busca_time;

  FOR rg_crapass IN cr_crapass LOOP
  
    vr_cdcooper := rg_crapass.cdcooper;
    vr_nrdconta := rg_crapass.nrdconta;
  
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => 'Alteracao do ITG de conta por script - INC0127332',
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
