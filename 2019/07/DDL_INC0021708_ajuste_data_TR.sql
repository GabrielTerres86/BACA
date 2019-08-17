--INC0021615 - ajustar datas contratos TR
--Ana Volles - 31/07/2019

BEGIN
  update crapepr e set e.dtdpagto = to_date('15/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 648388   and  nrctremp = 172865;
  update crapepr e set e.dtdpagto = to_date('25/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 822663   and  nrctremp = 295239;
  update crapepr e set e.dtdpagto = to_date('20/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2089262  and  nrctremp = 403174;
  update crapepr e set e.dtdpagto = to_date('20/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2356848  and  nrctremp = 277548;
  update crapepr e set e.dtdpagto = to_date('20/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2700174  and  nrctremp = 693594;
  update crapepr e set e.dtdpagto = to_date('10/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3172805  and  nrctremp = 490289;
  update crapepr e set e.dtdpagto = to_date('20/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3719944  and  nrctremp = 475769;
  update crapepr e set e.dtdpagto = to_date('20/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 4072898  and  nrctremp = 622906;
  update crapepr e set e.dtdpagto = to_date('10/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 4072898  and  nrctremp = 779860;
  update crapepr e set e.dtdpagto = to_date('10/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6674216  and  nrctremp = 758233;
  update crapepr e set e.dtdpagto = to_date('25/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7311168  and  nrctremp = 32406;
  update crapepr e set e.dtdpagto = to_date('25/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7794711  and  nrctremp = 613194;
  update crapepr e set e.dtdpagto = to_date('25/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7976194  and  nrctremp = 831934;
  update crapepr e set e.dtdpagto = to_date('10/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 8041830  and  nrctremp = 580502;
  update crapepr e set e.dtdpagto = to_date('10/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 8042390  and  nrctremp = 1053872;
  update crapepr e set e.dtdpagto = to_date('10/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 90162218 and  nrctremp = 273065;
  update crapepr e set e.dtdpagto = to_date('20/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 90162218 and  nrctremp = 273483;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
      
  
