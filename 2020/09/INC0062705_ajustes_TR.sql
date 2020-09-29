BEGIN
  --Viacredi
	update crapepr e set e.dtdpagto = to_date('25/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 1900528 and e.nrctremp = 777054;
	update crapepr e set e.dtdpagto = to_date('25/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6571760 and e.nrctremp = 279148;
	update crapepr e set e.dtdpagto = to_date('25/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 90054970 and e.nrctremp = 284907;
	update crapepr e set e.dtdpagto = to_date('10/10/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6637914 and e.nrctremp = 992383;
	update crapepr e set e.dtdpagto = to_date('20/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6218369 and e.nrctremp = 280021;
	update crapepr e set e.dtdpagto = to_date('25/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 80005608 and e.nrctremp = 288560;
	update crapepr e set e.dtdpagto = to_date('10/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3086887 and e.nrctremp = 915123;
	update crapepr e set e.dtdpagto = to_date('20/10/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3794644 and e.nrctremp = 1006620;
	update crapepr e set e.dtdpagto = to_date('20/10/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3794644 and e.nrctremp = 1006413;
	update crapepr e set e.dtdpagto = to_date('20/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3130282 and e.nrctremp = 384460;
	update crapepr e set e.dtdpagto = to_date('20/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 7665318 and e.nrctremp = 621280;
	update crapepr e set e.dtdpagto = to_date('22/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3672409 and e.nrctremp = 473448;
	update crapepr e set e.dtdpagto = to_date('22/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2117266 and e.nrctremp = 473526;
	update crapepr e set e.dtdpagto = to_date('10/10/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2152231 and e.nrctremp = 782285;
	update crapepr e set e.dtdpagto = to_date('10/10/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8639973 and e.nrctremp = 1449590;
	update crapepr e set e.dtdpagto = to_date('10/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8667683 and e.nrctremp = 911566;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;