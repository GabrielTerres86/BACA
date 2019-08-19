--INC0019020 - Ana Lucia - 27/06/2019
--Ajuste data TR
/*
select nrdconta, nrctremp, dtdpagto from crapepr where cdcooper = 1 and nrdconta in (
2836866 ,3641074 ,7160003 ,927031  ,6637914 ,3086887 ,2117266 ,6226710 ,1884964 ,2490447)
and nrctremp in (482186, 582672, 397260, 422586, 992383, 915123, 473526, 565570, 604566, 150139);
*/
update crapepr e set e.dtdpagto = to_date('25/03/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2836866 and  nrctremp = 482186;
update crapepr e set e.dtdpagto = to_date('25/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3641074 and  nrctremp = 582672;
update crapepr e set e.dtdpagto = to_date('28/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7160003 and  nrctremp = 397260;
update crapepr e set e.dtdpagto = to_date('25/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 927031  and  nrctremp = 422586;
update crapepr e set e.dtdpagto = to_date('10/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6637914 and  nrctremp = 992383;
update crapepr e set e.dtdpagto = to_date('15/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3086887 and  nrctremp = 915123;
update crapepr e set e.dtdpagto = to_date('22/03/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2117266 and  nrctremp = 473526;
update crapepr e set e.dtdpagto = to_date('10/03/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6226710 and  nrctremp = 565570;
update crapepr e set e.dtdpagto = to_date('15/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1884964 and  nrctremp = 604566;
update crapepr e set e.dtdpagto = to_date('15/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2490447 and  nrctremp = 150139;


COMMIT;


