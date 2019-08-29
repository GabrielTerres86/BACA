--INC0023912 - ajustar datas contratos TR Viacredi e Acredi
--Ana Volles - 29/08/2019

BEGIN
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 915092   and  nrctremp = 725071;
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 915092   and  nrctremp = 725079;
  update crapepr e set e.dtdpagto = to_date('15/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1884964  and  nrctremp = 604566;
  update crapepr e set e.dtdpagto = to_date('25/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1900528  and  nrctremp = 777054;
  update crapepr e set e.dtdpagto = to_date('22/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2214784  and  nrctremp = 1143666;
  update crapepr e set e.dtdpagto = to_date('15/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2490447  and  nrctremp = 150139;
  update crapepr e set e.dtdpagto = to_date('20/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3645681  and  nrctremp = 262726;
  update crapepr e set e.dtdpagto = to_date('05/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3869237  and  nrctremp = 997429;
  update crapepr e set e.dtdpagto = to_date('20/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6129536  and  nrctremp = 277830;
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6637914  and  nrctremp = 992383;
  update crapepr e set e.dtdpagto = to_date('25/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6751466  and  nrctremp = 413199;
  update crapepr e set e.dtdpagto = to_date('25/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6751466  and  nrctremp = 293175;
  update crapepr e set e.dtdpagto = to_date('10/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7175159  and  nrctremp = 531291;
  update crapepr e set e.dtdpagto = to_date('10/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7175159  and  nrctremp = 531296;
  update crapepr e set e.dtdpagto = to_date('20/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7665318  and  nrctremp = 621280;
  update crapepr e set e.dtdpagto = to_date('20/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 8023298  and  nrctremp = 982474;
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 8724202  and  nrctremp = 1412278;
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 80418090 and  nrctremp = 1356632;

  update crapepr e set e.dtdpagto = to_date('01/09/2019','DD/MM/YYYY') where cdcooper = 2 and nrdconta = 549010   and  nrctremp = 218189;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
      
  
