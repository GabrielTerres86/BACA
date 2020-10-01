BEGIN
  --Viacredi
	update crapepr e set e.dtdpagto = to_date('15/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 648388 and e.nrctremp = 172865;
	update crapepr e set e.dtdpagto = to_date('25/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 927031 and e.nrctremp = 422586;
	update crapepr e set e.dtdpagto = to_date('10/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8355614 and e.nrctremp = 1193088;
	update crapepr e set e.dtdpagto = to_date('10/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8355614 and e.nrctremp = 1112267;
	update crapepr e set e.dtdpagto = to_date('10/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8565341 and e.nrctremp = 1356631;
	update crapepr e set e.dtdpagto = to_date('10/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 9735194 and e.nrctremp = 1630505;
	update crapepr e set e.dtdpagto = to_date('10/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 80482139 and e.nrctremp = 1178986;
	update crapepr e set e.dtdpagto = to_date('25/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 90054970 and e.nrctremp = 284907;
	update crapepr e set e.dtdpagto = to_date('15/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8128111 and e.nrctremp = 299369;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;