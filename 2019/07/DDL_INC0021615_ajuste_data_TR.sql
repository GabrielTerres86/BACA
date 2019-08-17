--INC0021615 - ajsutar datas contratos TR
--Ana Volles - 30/07/2019

BEGIN
  update crapepr e set e.dtdpagto = to_date('22/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2214784  and  nrctremp = 1143666;
  update crapepr e set e.dtdpagto = to_date('25/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2836866  and  nrctremp = 482186;
  update crapepr e set e.dtdpagto = to_date('25/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3641074  and  nrctremp = 582672;
  update crapepr e set e.dtdpagto = to_date('11/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2887754  and  nrctremp = 884146;
  update crapepr e set e.dtdpagto = to_date('10/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6637914  and  nrctremp = 992383;
  update crapepr e set e.dtdpagto = to_date('10/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2589680  and  nrctremp = 264654;
  update crapepr e set e.dtdpagto = to_date('20/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 8023298  and  nrctremp = 982474;
  update crapepr e set e.dtdpagto = to_date('22/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2117266  and  nrctremp = 473510;
  update crapepr e set e.dtdpagto = to_date('22/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2117266  and  nrctremp = 473526;
  update crapepr e set e.dtdpagto = to_date('10/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6226710  and  nrctremp = 565589;
  update crapepr e set e.dtdpagto = to_date('20/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7665318  and  nrctremp = 621280;
  update crapepr e set e.dtdpagto = to_date('10/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6226710  and  nrctremp = 565570;
  update crapepr e set e.dtdpagto = to_date('15/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2031132  and  nrctremp = 498920;
  update crapepr e set e.dtdpagto = to_date('15/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1884964  and  nrctremp = 604566;
  update crapepr e set e.dtdpagto = to_date('20/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2152231  and  nrctremp = 782285;
  update crapepr e set e.dtdpagto = to_date('15/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2490447  and  nrctremp = 150139;
  update crapepr e set e.dtdpagto = to_date('10/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7521812  and  nrctremp = 977095;
  update crapepr e set e.dtdpagto = to_date('10/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 8232318  and  nrctremp = 1068138;
  update crapepr e set e.dtdpagto = to_date('10/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 4000536  and  nrctremp = 805281;
  update crapepr e set e.dtdpagto = to_date('10/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 8690359  and  nrctremp = 911545;
  update crapepr e set e.dtdpagto = to_date('20/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 829986   and  nrctremp = 485976;
  update crapepr e set e.dtdpagto = to_date('12/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1983334  and  nrctremp = 125310;
  update crapepr e set e.dtdpagto = to_date('10/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 915092   and  nrctremp = 725071;
  update crapepr e set e.dtdpagto = to_date('10/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 915092   and  nrctremp = 725079;
  update crapepr e set e.dtdpagto = to_date('15/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2231930  and  nrctremp = 551661;
  update crapepr e set e.dtdpagto = to_date('10/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2143160  and  nrctremp = 323890;
  update crapepr e set e.dtdpagto = to_date('20/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6218369  and  nrctremp = 280021;
  update crapepr e set e.dtdpagto = to_date('20/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 90054970 and  nrctremp = 284907;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
      
  
