--INC0053616 - Ajustar datas contratos TR Viacredi
--Ana Volles - 30/06/2020
BEGIN
  --Viacredi

update crapepr e set e.dtdpagto = to_date('25/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 680702	 and e.nrctremp = 291171;
update crapepr e set e.dtdpagto = to_date('25/02/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 1830830 and e.nrctremp = 236552;
update crapepr e set e.dtdpagto = to_date('20/07/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 2332914 and e.nrctremp = 465280;
update crapepr e set e.dtdpagto = to_date('10/02/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 2728907 and e.nrctremp = 287720;
update crapepr e set e.dtdpagto = to_date('15/07/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 3014819 and e.nrctremp = 383352;
update crapepr e set e.dtdpagto = to_date('10/07/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 3086887 and e.nrctremp = 915123;
update crapepr e set e.dtdpagto = to_date('25/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 7794711 and e.nrctremp = 613194;
update crapepr e set e.dtdpagto = to_date('15/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 7870949 and e.nrctremp = 298173;
update crapepr e set e.dtdpagto = to_date('10/07/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 8257183 and e.nrctremp = 1283452;
update crapepr e set e.dtdpagto = to_date('08/07/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 9052658 and e.nrctremp = 1805964;
update crapepr e set e.dtdpagto = to_date('10/07/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 9851364 and e.nrctremp = 1224514;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
