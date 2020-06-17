--INC0047264 - Ajustar datas contratos TR Viacredi
--Ana Volles - 29/04/2020
BEGIN
  --Viacredi
update crapepr e set e.dtdpagto = to_date('20/02/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 829986   and e.nrctremp = 485976 ;
update crapepr e set e.dtdpagto = to_date('15/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 847917   and e.nrctremp = 292150 ;
update crapepr e set e.dtdpagto = to_date('20/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 881546   and e.nrctremp = 296680 ;
update crapepr e set e.dtdpagto = to_date('20/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 1200046  and e.nrctremp = 553548 ;
update crapepr e set e.dtdpagto = to_date('25/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 1900528  and e.nrctremp = 777054 ;
update crapepr e set e.dtdpagto = to_date('10/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 1904299  and e.nrctremp = 288672 ;
update crapepr e set e.dtdpagto = to_date('20/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 2089262  and e.nrctremp = 403174 ;
update crapepr e set e.dtdpagto = to_date('10/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 2152231  and e.nrctremp = 782285 ;
update crapepr e set e.dtdpagto = to_date('20/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 2700174  and e.nrctremp = 693594 ;
update crapepr e set e.dtdpagto = to_date('20/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 2725886  and e.nrctremp = 1373806;
update crapepr e set e.dtdpagto = to_date('20/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 2729890  and e.nrctremp = 281545 ;
update crapepr e set e.dtdpagto = to_date('10/12/2019','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 2887754  and e.nrctremp = 627873 ;
update crapepr e set e.dtdpagto = to_date('10/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 3086887  and e.nrctremp = 915123 ;
update crapepr e set e.dtdpagto = to_date('15/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 3126390  and e.nrctremp = 465855 ;
update crapepr e set e.dtdpagto = to_date('15/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 6072470  and e.nrctremp = 696577 ;
update crapepr e set e.dtdpagto = to_date('20/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 6218369  and e.nrctremp = 280021 ;
update crapepr e set e.dtdpagto = to_date('10/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 6226710  and e.nrctremp = 565570 ;
update crapepr e set e.dtdpagto = to_date('10/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 6534740  and e.nrctremp = 1302200;
update crapepr e set e.dtdpagto = to_date('25/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 6751466  and e.nrctremp = 293175 ;
update crapepr e set e.dtdpagto = to_date('25/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 7112866  and e.nrctremp = 378422 ;
update crapepr e set e.dtdpagto = to_date('10/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 9735194  and e.nrctremp = 1630505;
update crapepr e set e.dtdpagto = to_date('25/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 80032192 and e.nrctremp = 336252 ;
update crapepr e set e.dtdpagto = to_date('25/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 90054970 and e.nrctremp = 284907 ;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
