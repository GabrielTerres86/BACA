BEGIN
  --Viacredi
	update crapepr e set e.dtdpagto = to_date('20/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6617700 and e.nrctremp = 470375;
	update crapepr e set e.dtdpagto = to_date('25/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 1900528 and e.nrctremp = 777054;
	update crapepr e set e.dtdpagto = to_date('13/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2711060 and e.nrctremp = 714118;
	update crapepr e set e.dtdpagto = to_date('25/05/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2836866 and e.nrctremp = 482186;
	update crapepr e set e.dtdpagto = to_date('25/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3641074 and e.nrctremp = 582672;
	update crapepr e set e.dtdpagto = to_date('16/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 646849 and e.nrctremp = 786138;
	update crapepr e set e.dtdpagto = to_date('10/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 1904299 and e.nrctremp = 288672;
	update crapepr e set e.dtdpagto = to_date('15/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3845966 and e.nrctremp = 294897;
	update crapepr e set e.dtdpagto = to_date('15/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8225915 and e.nrctremp = 1195867;
	update crapepr e set e.dtdpagto = to_date('10/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2966077 and e.nrctremp = 618541;
	update crapepr e set e.dtdpagto = to_date('20/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6173780 and e.nrctremp = 312529;
	update crapepr e set e.dtdpagto = to_date('23/05/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 7004915 and e.nrctremp = 987337;
	update crapepr e set e.dtdpagto = to_date('25/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 90054970 and e.nrctremp = 284907;
	update crapepr e set e.dtdpagto = to_date('10/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6637914 and e.nrctremp = 992383;
	update crapepr e set e.dtdpagto = to_date('25/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 80005608 and e.nrctremp = 288560;
	update crapepr e set e.dtdpagto = to_date('10/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3086887 and e.nrctremp = 915123;
	update crapepr e set e.dtdpagto = to_date('20/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3794644 and e.nrctremp = 1006620;
	update crapepr e set e.dtdpagto = to_date('20/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3794644 and e.nrctremp = 1006413;
	update crapepr e set e.dtdpagto = to_date('20/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6890946 and e.nrctremp = 10906;
	update crapepr e set e.dtdpagto = to_date('20/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2089262 and e.nrctremp = 403174;
	update crapepr e set e.dtdpagto = to_date('20/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3130282 and e.nrctremp = 384460;
	update crapepr e set e.dtdpagto = to_date('20/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 7665318 and e.nrctremp = 621280;
	update crapepr e set e.dtdpagto = to_date('22/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2117266 and e.nrctremp = 473510;
	update crapepr e set e.dtdpagto = to_date('22/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2117266 and e.nrctremp = 473526;
	update crapepr e set e.dtdpagto = to_date('15/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 1884964 and e.nrctremp = 604566;
	update crapepr e set e.dtdpagto = to_date('10/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8667683 and e.nrctremp = 911566;

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;