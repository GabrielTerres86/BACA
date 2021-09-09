/*
    Atualização parcelas efetivadas Aimaro e FIS em tempos distintos causando diferença na parcela.
*/
UPDATE crappep SET vlsdvpar = vlsdvpar -0.05, vlparepr = vlparepr -0.05 WHERE cdcooper = 9 AND nrdconta = 500100 AND nrctremp = 2020025;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.01, vlparepr = vlparepr -0.01 WHERE cdcooper = 9 AND nrdconta = 500690 AND nrctremp = 20100302;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.01, vlparepr = vlparepr -0.01 WHERE cdcooper = 9 AND nrdconta = 500917 AND nrctremp = 20200019;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.03, vlparepr = vlparepr -0.03 WHERE cdcooper = 9 AND nrdconta = 501646 AND nrctremp = 20100441;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.13, vlparepr = vlparepr -0.13 WHERE cdcooper = 9 AND nrdconta = 501999 AND nrctremp = 20100370;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.02, vlparepr = vlparepr -0.02 WHERE cdcooper = 9 AND nrdconta = 501999 AND nrctremp = 21100050;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.02, vlparepr = vlparepr -0.02 WHERE cdcooper = 9 AND nrdconta = 502928 AND nrctremp = 21300035 AND nrparepr > 1; -- Não fazer primeira parcela
UPDATE crappep SET vlsdvpar = vlsdvpar +0.02, vlparepr = vlparepr +0.02 WHERE cdcooper = 9 AND nrdconta = 503061 AND nrctremp = 20300036;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.01, vlparepr = vlparepr -0.01 WHERE cdcooper = 9 AND nrdconta = 503614 AND nrctremp = 20100037;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.01, vlparepr = vlparepr -0.01 WHERE cdcooper = 9 AND nrdconta = 504530 AND nrctremp = 21100253;
UPDATE crappep SET vlsdvpar = vlsdvpar +0.12, vlparepr = vlparepr +0.12 WHERE cdcooper = 9 AND nrdconta = 505277 AND nrctremp = 21100150;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.04, vlparepr = vlparepr -0.04 WHERE cdcooper = 9 AND nrdconta = 505358 AND nrctremp = 21300027;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.05, vlparepr = vlparepr -0.05 WHERE cdcooper = 9 AND nrdconta = 511293 AND nrctremp = 20100547;
UPDATE crappep SET vlsdvpar = vlsdvpar +0.01, vlparepr = vlparepr +0.01 WHERE cdcooper = 9 AND nrdconta = 511358 AND nrctremp = 20100239;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.02, vlparepr = vlparepr -0.02 WHERE cdcooper = 9 AND nrdconta = 516880 AND nrctremp = 21100013;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.16, vlparepr = vlparepr -0.16 WHERE cdcooper = 9 AND nrdconta = 517976 AND nrctremp = 20100502;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.02, vlparepr = vlparepr -0.02 WHERE cdcooper = 9 AND nrdconta = 518565 AND nrctremp = 20100317;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.12, vlparepr = vlparepr -0.12 WHERE cdcooper = 9 AND nrdconta = 519650 AND nrctremp = 20100538;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.11, vlparepr = vlparepr -0.11 WHERE cdcooper = 9 AND nrdconta = 524026 AND nrctremp = 20100258;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.05, vlparepr = vlparepr -0.05 WHERE cdcooper = 9 AND nrdconta = 527807 AND nrctremp = 21100070;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.02, vlparepr = vlparepr -0.02 WHERE cdcooper = 9 AND nrdconta = 528480 AND nrctremp = 21100193;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.19, vlparepr = vlparepr -0.19 WHERE cdcooper = 9 AND nrdconta = 528587 AND nrctremp = 20100359;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.10, vlparepr = vlparepr -0.10 WHERE cdcooper = 9 AND nrdconta = 528641 AND nrctremp = 20100365;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.01, vlparepr = vlparepr -0.01 WHERE cdcooper = 9 AND nrdconta = 530280 AND nrctremp = 21100103;
UPDATE crappep SET vlsdvpar = vlsdvpar -0.02, vlparepr = vlparepr -0.02 WHERE cdcooper = 9 AND nrdconta = 531111 AND nrctremp = 21100231;

COMMIT;