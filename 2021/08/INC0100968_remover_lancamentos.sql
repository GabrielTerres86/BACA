/*
Tempo total de executação de 1 segundo
Geração dos DELETEs:

SELECT 'DELETE FROM craplcm WHERE cdcooper = ' || x.cdcooper || ' AND nrdconta = ' || x.nrdconta || ' AND dtmvtolt = TO_DATE('''|| x.dtmvtolt ||''', ''dd/mm/YYYY'') AND progress_recid = ' || x.progress_recid || ';'
  FROM craplcm x,crapass a 
 WHERE a.cdcooper = x.cdcooper
   AND a.nrdconta = x.nrdconta
   AND x.cdcooper = 9  -- Transpocred
   AND a.cdagenci = 28 -- PA CredCorreios
   AND x.dtmvtolt >= '09/08/2021' -- Dia de movimento da cooperativa após incorporação
   AND TRUNC(x.dttrans) = '31/07/2021'; -- Dia da incorporação

*/

DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500488 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174486273;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 522481 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174488416;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 523410 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174488598;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 521507 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174489635;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 501743 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174500578;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 529524 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174486058;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500364 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174490824;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500364 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174490964;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500364 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174492079;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 511099 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174492217;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 512591 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174492474;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 505951 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174493890;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500470 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174494007;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502103 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174494174;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 503568 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174494582;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 507350 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174496661;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 508977 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174496779;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525324 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174497961;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500860 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174499337;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 518980 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174499769;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 501328 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174500136;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500690 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174500476;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 518565 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174500820;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 504459 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174501306;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 501603 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174501914;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525146 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174502033;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 528471 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174503153;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531235 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174504749;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525057 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174504870;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 511293 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174514015;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 501239 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174514674;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 527130 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174516136;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 511951 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174516790;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502685 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174517363;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502820 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174522532;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500712 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174522782;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 524417 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174522900;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500100 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174523412;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 532100 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174524047;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 506524 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174524538;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 503061 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174524990;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 506532 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174527031;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 528722 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174529795;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502200 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174530011;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 523364 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174531109;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 523550 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174531215;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502898 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174531316;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 524778 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174536364;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 501255 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174536572;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502529 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174538309;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 501166 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174538431;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 530280 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174538624;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500810 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174538813;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525251 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174539469;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502057 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174539874;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 505129 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174545224;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 504041 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174548476;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 519618 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174548606;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 505129 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174552115;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 518514 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174554070;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 503932 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174554220;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500275 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174554518;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500275 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174554573;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 511501 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174554689;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500402 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174556899;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500399 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174556965;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500399 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174557025;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502928 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174561827;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502073 AND dtmvtolt = TO_DATE('15/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174486911;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 503690 AND dtmvtolt = TO_DATE('15/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174500244;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 517968 AND dtmvtolt = TO_DATE('15/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174513280;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 528641 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174503658;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 514110 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174504096;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 528153 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174504211;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500410 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174507447;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 501972 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174510294;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531090 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174510618;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 519650 AND dtmvtolt = TO_DATE('10/08/2021', 'dd/mm/YYYY') AND progress_recid = 1174513630;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 504327 AND dtmvtolt = TO_DATE('01/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174499897;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 501190 AND dtmvtolt = TO_DATE('01/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174487045;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 505960 AND dtmvtolt = TO_DATE('01/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174493616;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531146 AND dtmvtolt = TO_DATE('01/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174494698;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531090 AND dtmvtolt = TO_DATE('01/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174510619;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 504629 AND dtmvtolt = TO_DATE('01/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174516636;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 526100 AND dtmvtolt = TO_DATE('01/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174520277;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 524778 AND dtmvtolt = TO_DATE('01/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174536365;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531383 AND dtmvtolt = TO_DATE('01/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174539669;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502308 AND dtmvtolt = TO_DATE('05/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174488261;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525979 AND dtmvtolt = TO_DATE('05/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174506205;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 507318 AND dtmvtolt = TO_DATE('07/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174545992;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500488 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174486285;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 522481 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174488417;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 514110 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174504097;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500100 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174523413;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502200 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174530012;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 530280 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174538625;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502057 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174539875;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 519618 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174548607;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502189 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174556133;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 513490 AND dtmvtolt = TO_DATE('10/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174556633;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502073 AND dtmvtolt = TO_DATE('15/09/2021', 'dd/mm/YYYY') AND progress_recid = 1174486912;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 524778 AND dtmvtolt = TO_DATE('01/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174536366;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 501190 AND dtmvtolt = TO_DATE('01/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174487046;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 504327 AND dtmvtolt = TO_DATE('01/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174499898;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 526100 AND dtmvtolt = TO_DATE('01/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174520278;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531383 AND dtmvtolt = TO_DATE('01/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174539670;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525979 AND dtmvtolt = TO_DATE('05/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174506206;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 500488 AND dtmvtolt = TO_DATE('10/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174486290;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502200 AND dtmvtolt = TO_DATE('10/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174530013;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 513490 AND dtmvtolt = TO_DATE('10/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174556634;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502073 AND dtmvtolt = TO_DATE('15/10/2021', 'dd/mm/YYYY') AND progress_recid = 1174486913;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502073 AND dtmvtolt = TO_DATE('15/11/2021', 'dd/mm/YYYY') AND progress_recid = 1174486915;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531383 AND dtmvtolt = TO_DATE('01/11/2021', 'dd/mm/YYYY') AND progress_recid = 1174539671;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525979 AND dtmvtolt = TO_DATE('05/11/2021', 'dd/mm/YYYY') AND progress_recid = 1174506207;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 513490 AND dtmvtolt = TO_DATE('10/11/2021', 'dd/mm/YYYY') AND progress_recid = 1174556635;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 502073 AND dtmvtolt = TO_DATE('15/12/2021', 'dd/mm/YYYY') AND progress_recid = 1174486918;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531383 AND dtmvtolt = TO_DATE('01/12/2021', 'dd/mm/YYYY') AND progress_recid = 1174539672;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525979 AND dtmvtolt = TO_DATE('05/12/2021', 'dd/mm/YYYY') AND progress_recid = 1174506208;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525979 AND dtmvtolt = TO_DATE('05/01/2022', 'dd/mm/YYYY') AND progress_recid = 1174506210;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531383 AND dtmvtolt = TO_DATE('01/01/2022', 'dd/mm/YYYY') AND progress_recid = 1174539673;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 525979 AND dtmvtolt = TO_DATE('05/02/2022', 'dd/mm/YYYY') AND progress_recid = 1174506212;
DELETE FROM craplcm WHERE cdcooper = 9 AND nrdconta = 531383 AND dtmvtolt = TO_DATE('01/02/2022', 'dd/mm/YYYY') AND progress_recid = 1174539674;
COMMIT;