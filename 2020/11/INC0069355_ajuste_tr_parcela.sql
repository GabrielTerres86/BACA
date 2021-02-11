BEGIN
  --Viacredi
	update crapepr e set e.dtdpagto = to_date('25/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3641074 and e.nrctremp = 582672;
	update crapepr e set e.dtdpagto = to_date('10/12/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 1904299 and e.nrctremp = 288672;
	update crapepr e set e.dtdpagto = to_date('28/10/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 7160003 and e.nrctremp = 397260;
	update crapepr e set e.dtdpagto = to_date('25/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 927031 and e.nrctremp = 422586;
	update crapepr e set e.dtdpagto = to_date('20/11/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2356848 and e.nrctremp = 277548;
	update crapepr e set e.dtdpagto = to_date('20/12/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3794644 and e.nrctremp = 1006413;
	update crapepr e set e.dtdpagto = to_date('10/12/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6515860 and e.nrctremp = 509660;
	update crapepr e set e.dtdpagto = to_date('10/12/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8365806 and e.nrctremp = 1500007;
	update crapepr e set e.dtdpagto = to_date('15/12/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 80140556 and e.nrctremp = 473189;
	update crapepr e set e.dtdpagto = to_date('10/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 26310 and e.nrctremp = 885855;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;