/*

	SCRIPT CORRIGIR SALDO DO COOPERADO - INC0029884


*/
--Elimina os registros incorretos
delete from crapdpb where progress_recid = 12642502;
delete from crapdpb where progress_recid = 12642569;
delete from crapdpb where progress_recid = 12642645;
delete from crapdpb where progress_recid = 12644878;
delete from crapdpb where progress_recid = 12642503;
delete from crapdpb where progress_recid = 12644880;
delete from crapdpb where progress_recid = 12642647;
delete from crapdpb where progress_recid = 12642571;
delete from crapdpb where progress_recid = 12644902;
delete from crapdpb where progress_recid = 12642516;
delete from crapdpb where progress_recid = 12642585;
delete from crapdpb where progress_recid = 12642659;
delete from crapdpb where progress_recid = 12644885;
delete from crapdpb where progress_recid = 12642575;
delete from crapdpb where progress_recid = 12642506;
delete from crapdpb where progress_recid = 12642650;
delete from crapdpb where progress_recid = 12642652;
delete from crapdpb where progress_recid = 12644891;
delete from crapdpb where progress_recid = 12642509;
delete from crapdpb where progress_recid = 12642577;
delete from crapdpb where progress_recid = 12642508;
delete from crapdpb where progress_recid = 12642651;
delete from crapdpb where progress_recid = 12642576;
delete from crapdpb where progress_recid = 12644889;
delete from crapdpb where progress_recid = 12642653;
delete from crapdpb where progress_recid = 12644892;
delete from crapdpb where progress_recid = 12642578;
delete from crapdpb where progress_recid = 12642510;
delete from crapdpb where progress_recid = 12642698;
delete from crapdpb where progress_recid = 12642620;
delete from crapdpb where progress_recid = 12642547;
delete from crapdpb where progress_recid = 12644963;
delete from crapdpb where progress_recid = 12642581;
delete from crapdpb where progress_recid = 12642512;
delete from crapdpb where progress_recid = 12644895;
delete from crapdpb where progress_recid = 12642655;
delete from crapdpb where progress_recid = 12644901;
delete from crapdpb where progress_recid = 12642584;
delete from crapdpb where progress_recid = 12642658;
delete from crapdpb where progress_recid = 12642515;
delete from crapdpb where progress_recid = 12642657;
delete from crapdpb where progress_recid = 12642583;
delete from crapdpb where progress_recid = 12642514;
delete from crapdpb where progress_recid = 12644899;
delete from crapdpb where progress_recid = 12644932;
delete from crapdpb where progress_recid = 12642595;
delete from crapdpb where progress_recid = 12642670;
delete from crapdpb where progress_recid = 12642525;
delete from crapdpb where progress_recid = 12642660;
delete from crapdpb where progress_recid = 12642586;
delete from crapdpb where progress_recid = 12642517;
delete from crapdpb where progress_recid = 12644907;
delete from crapdpb where progress_recid = 12642587;
delete from crapdpb where progress_recid = 12642519;
delete from crapdpb where progress_recid = 12644911;
delete from crapdpb where progress_recid = 12642664;
delete from crapdpb where progress_recid = 12644917;
delete from crapdpb where progress_recid = 12642590;
delete from crapdpb where progress_recid = 12642665;
delete from crapdpb where progress_recid = 12642520;
delete from crapdpb where progress_recid = 12642673;
delete from crapdpb where progress_recid = 12644944;
delete from crapdpb where progress_recid = 12642529;
delete from crapdpb where progress_recid = 12642599;
delete from crapdpb where progress_recid = 12644939;
delete from crapdpb where progress_recid = 12642527;
delete from crapdpb where progress_recid = 12642596;
delete from crapdpb where progress_recid = 12642671;
delete from crapdpb where progress_recid = 12644941;
delete from crapdpb where progress_recid = 12642597;
delete from crapdpb where progress_recid = 12642528;
delete from crapdpb where progress_recid = 12642672;
delete from crapdpb where progress_recid = 12642694;
delete from crapdpb where progress_recid = 12644953;
delete from crapdpb where progress_recid = 12642544;
delete from crapdpb where progress_recid = 12642614;
delete from crapdpb where progress_recid = 12644962;
delete from crapdpb where progress_recid = 12642618;
delete from crapdpb where progress_recid = 12642697;
delete from crapdpb where progress_recid = 12642546;
delete from crapdpb where progress_recid = 12642648;
delete from crapdpb where progress_recid = 12644882;
delete from crapdpb where progress_recid = 12642505;
delete from crapdpb where progress_recid = 12642574;
delete from crapdpb where progress_recid = 12642501;
delete from crapdpb where progress_recid = 12644877;
delete from crapdpb where progress_recid = 12642644;
delete from crapdpb where progress_recid = 12642568;

--Atualiza o saldo
UPDATE crapsld a SET a.vlsdblpr = 4000 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 1501976;
UPDATE crapsld a SET a.vlsdblpr = 900 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 1964712;
UPDATE crapsld a SET a.vlsdblpr = 520 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 2347032;
UPDATE crapsld a SET a.vlsdblpr = 27585.6 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 2500876;
UPDATE crapsld a SET a.vlsdblpr = 1200 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 2571552;
UPDATE crapsld a SET a.vlsdblpr = 8464 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 3030334;
UPDATE crapsld a SET a.vlsdblpr = 11212 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 3502678;
UPDATE crapsld a SET a.vlsdblpr = 1586.68 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 3770001;
UPDATE crapsld a SET a.vlsdblpr = 5594.24 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 3885100;
UPDATE crapsld a SET a.vlsdblpr = 10171.68 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 6057888;
UPDATE crapsld a SET a.vlsdblpr = 9808 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 6179819;
UPDATE crapsld a SET a.vlsdblpr = 60000 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 6244009;
UPDATE crapsld a SET a.vlsdblpr = 400 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 6321062;
UPDATE crapsld a SET a.vlsdblpr = 9935.48 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 6898491;
UPDATE crapsld a SET a.vlsdblpr = 5654.48 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 7182775;
UPDATE crapsld a SET a.vlsdblpr = 1680 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 7974400;
UPDATE crapsld a SET a.vlsdblpr = 5260 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 8432627;
UPDATE crapsld a SET a.vlsdblpr = 1143.88 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 8507201;
UPDATE crapsld a SET a.vlsdblpr = 7965 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 8851972;
UPDATE crapsld a SET a.vlsdblpr = 2000 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 9037950;
UPDATE crapsld a SET a.vlsdblpr = 13855.64 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 9115145;
UPDATE crapsld a SET a.vlsdblpr = 7642 - (a.vlsdblpr*-1)  WHERE a.cdcooper = 1 AND a.nrdconta = 80004903;

commit;

/*

--Rollback dos ajustes
UPDATE crapsld a SET a.vlsdblpr = -4000 WHERE a.cdcooper = 1 AND a.nrdconta = 1501976;
UPDATE crapsld a SET a.vlsdblpr = -900 WHERE a.cdcooper = 1 AND a.nrdconta = 1964712;
UPDATE crapsld a SET a.vlsdblpr = -520 WHERE a.cdcooper = 1 AND a.nrdconta = 2347032;
UPDATE crapsld a SET a.vlsdblpr = -27585.6 WHERE a.cdcooper = 1 AND a.nrdconta = 2500876;
UPDATE crapsld a SET a.vlsdblpr = -1200 WHERE a.cdcooper = 1 AND a.nrdconta = 2571552;
UPDATE crapsld a SET a.vlsdblpr = -8464 WHERE a.cdcooper = 1 AND a.nrdconta = 3030334;
UPDATE crapsld a SET a.vlsdblpr = -11212 WHERE a.cdcooper = 1 AND a.nrdconta = 3502678;
UPDATE crapsld a SET a.vlsdblpr = -1586.68 WHERE a.cdcooper = 1 AND a.nrdconta = 3770001;
UPDATE crapsld a SET a.vlsdblpr = -4108.69 WHERE a.cdcooper = 1 AND a.nrdconta = 3885100;
UPDATE crapsld a SET a.vlsdblpr = -10171.68 WHERE a.cdcooper = 1 AND a.nrdconta = 6057888;
UPDATE crapsld a SET a.vlsdblpr = -9808 WHERE a.cdcooper = 1 AND a.nrdconta = 6179819;
UPDATE crapsld a SET a.vlsdblpr = -60000 WHERE a.cdcooper = 1 AND a.nrdconta = 6244009;
UPDATE crapsld a SET a.vlsdblpr = -400 WHERE a.cdcooper = 1 AND a.nrdconta = 6321062;
UPDATE crapsld a SET a.vlsdblpr = -9935.48 WHERE a.cdcooper = 1 AND a.nrdconta = 6898491;
UPDATE crapsld a SET a.vlsdblpr = -5654.48 WHERE a.cdcooper = 1 AND a.nrdconta = 7182775;
UPDATE crapsld a SET a.vlsdblpr = -1680 WHERE a.cdcooper = 1 AND a.nrdconta = 7974400;
UPDATE crapsld a SET a.vlsdblpr = -5260 WHERE a.cdcooper = 1 AND a.nrdconta = 8432627;
UPDATE crapsld a SET a.vlsdblpr = -1143.88 WHERE a.cdcooper = 1 AND a.nrdconta = 8507201;
UPDATE crapsld a SET a.vlsdblpr = -7965 WHERE a.cdcooper = 1 AND a.nrdconta = 8851972;
UPDATE crapsld a SET a.vlsdblpr = -2000 WHERE a.cdcooper = 1 AND a.nrdconta = 9037950;
UPDATE crapsld a SET a.vlsdblpr = -13855.64 WHERE a.cdcooper = 1 AND a.nrdconta = 9115145;
UPDATE crapsld a SET a.vlsdblpr = -7642 WHERE a.cdcooper = 1 AND a.nrdconta = 80004903;


*/