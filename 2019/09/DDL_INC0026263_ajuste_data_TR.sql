--INC0026263 - Ajustar datas contratos TR Viacredi e Acredicoop
--Ana Volles - 27/09/2019

BEGIN
  --Viacredi
  update crapepr e set e.dtdpagto = to_date('16/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 646849   and  nrctremp = 786138;
  update crapepr e set e.dtdpagto = to_date('15/10/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 648388   and  nrctremp = 172865;
  update crapepr e set e.dtdpagto = to_date('10/10/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 915092   and  nrctremp = 725071;
  update crapepr e set e.dtdpagto = to_date('10/10/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 915092   and  nrctremp = 725079;
  update crapepr e set e.dtdpagto = to_date('17/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 926507   and  nrctremp = 972431;
  update crapepr e set e.dtdpagto = to_date('20/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2152231  and  nrctremp = 782285;
  update crapepr e set e.dtdpagto = to_date('15/10/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2490447  and  nrctremp = 150139;
  update crapepr e set e.dtdpagto = to_date('15/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3086887  and  nrctremp = 915123;
  update crapepr e set e.dtdpagto = to_date('25/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3641074  and  nrctremp = 582672;
  update crapepr e set e.dtdpagto = to_date('05/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3869237  and  nrctremp = 997429;
  update crapepr e set e.dtdpagto = to_date('20/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6129536  and  nrctremp = 277830;
  update crapepr e set e.dtdpagto = to_date('10/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6226710  and  nrctremp = 565570;
  update crapepr e set e.dtdpagto = to_date('10/10/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6637914  and  nrctremp = 992383;
  update crapepr e set e.dtdpagto = to_date('28/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7160003  and  nrctremp = 397260;
  update crapepr e set e.dtdpagto = to_date('20/10/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7665318  and  nrctremp = 621280;
  update crapepr e set e.dtdpagto = to_date('10/10/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 9544780  and  nrctremp = 1251466;


  --Acredicoop
  update crapepr e set e.dtdpagto = to_date('10/10/2019','DD/MM/YYYY') where cdcooper = 2 and nrdconta = 378100 and  nrctremp = 21244;


  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
      
  
