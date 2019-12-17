--INC0024022 - ajustar datas contratos TR Viacredi
--Ana Volles - 30/08/2019

BEGIN
  update crapepr e set e.dtdpagto = to_date('15/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 648388  and  nrctremp = 172865;
  update crapepr e set e.dtdpagto = to_date('15/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 847917  and  nrctremp = 292150;
  update crapepr e set e.dtdpagto = to_date('20/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1200046 and  nrctremp = 553548;
  update crapepr e set e.dtdpagto = to_date('25/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1830830 and  nrctremp = 236552;
  update crapepr e set e.dtdpagto = to_date('12/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1983334 and  nrctremp = 125310;
  update crapepr e set e.dtdpagto = to_date('20/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2089262 and  nrctremp = 403174;
  update crapepr e set e.dtdpagto = to_date('20/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2700174 and  nrctremp = 693594;
  update crapepr e set e.dtdpagto = to_date('25/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3641074 and  nrctremp = 582672;
  update crapepr e set e.dtdpagto = to_date('20/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3719944 and  nrctremp = 475769;
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 4000536 and  nrctremp = 805281;
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 4036271 and  nrctremp = 899253;
  update crapepr e set e.dtdpagto = to_date('28/08/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 4375084 and  nrctremp = 241133;
  update crapepr e set e.dtdpagto = to_date('20/06/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6218369 and  nrctremp = 280021;
  update crapepr e set e.dtdpagto = to_date('10/05/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6226710 and  nrctremp = 565570;
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 6674216 and  nrctremp = 758233;
  update crapepr e set e.dtdpagto = to_date('23/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7004915 and  nrctremp = 987337;
  update crapepr e set e.dtdpagto = to_date('25/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7311168 and  nrctremp = 32406;
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7521812 and  nrctremp = 977095;
  update crapepr e set e.dtdpagto = to_date('10/09/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 8041660 and  nrctremp = 897767;
  update crapepr e set e.dtdpagto = to_date('15/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 8225915 and  nrctremp = 1195867;
	
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
      
  
