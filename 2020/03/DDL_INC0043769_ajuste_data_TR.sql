--INC0043769 - Ajustar datas contratos TR Viacredi
--Ana Volles - 30/03/2020

BEGIN
  --Viacredi
update crapepr e set e.dtdpagto = to_date('16/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	646849	and e.nrctremp = 	786138	;
update crapepr e set e.dtdpagto = to_date('15/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	648388	and e.nrctremp = 	172865	;
update crapepr e set e.dtdpagto = to_date('15/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	762547	and e.nrctremp = 	506468	;
update crapepr e set e.dtdpagto = to_date('15/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	847917	and e.nrctremp = 	292150	;
update crapepr e set e.dtdpagto = to_date('25/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	1830830	and e.nrctremp = 	236552	;
update crapepr e set e.dtdpagto = to_date('15/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	1884964	and e.nrctremp = 	604566	;
update crapepr e set e.dtdpagto = to_date('15/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2031132	and e.nrctremp = 	498920	;
update crapepr e set e.dtdpagto = to_date('20/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2089262	and e.nrctremp = 	403174	;
update crapepr e set e.dtdpagto = to_date('22/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2117266	and e.nrctremp = 	473526	;
update crapepr e set e.dtdpagto = to_date('10/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2152231	and e.nrctremp = 	782285	;
update crapepr e set e.dtdpagto = to_date('20/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2700174	and e.nrctremp = 	693594	;
update crapepr e set e.dtdpagto = to_date('25/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2836866	and e.nrctremp = 	482186	;
update crapepr e set e.dtdpagto = to_date('10/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	3086887	and e.nrctremp = 	915123	;
update crapepr e set e.dtdpagto = to_date('25/02/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	3641074	and e.nrctremp = 	582672	;
update crapepr e set e.dtdpagto = to_date('20/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	3645681	and e.nrctremp = 	262726	;
update crapepr e set e.dtdpagto = to_date('05/12/2019','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	3869237	and e.nrctremp = 	997429	;
update crapepr e set e.dtdpagto = to_date('20/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	6218369	and e.nrctremp = 	280021	;
update crapepr e set e.dtdpagto = to_date('10/12/2019','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	6226710	and e.nrctremp = 	565589	;
update crapepr e set e.dtdpagto = to_date('20/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	6637914	and e.nrctremp = 	992383	;
update crapepr e set e.dtdpagto = to_date('10/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	6816029	and e.nrctremp = 	982404	;
update crapepr e set e.dtdpagto = to_date('25/02/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	7311168	and e.nrctremp = 	32406	;
update crapepr e set e.dtdpagto = to_date('25/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	7794711	and e.nrctremp = 	613194	;
update crapepr e set e.dtdpagto = to_date('20/02/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	8023298	and e.nrctremp = 	982474	;
update crapepr e set e.dtdpagto = to_date('25/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =   90054970	and e.nrctremp = 	284907	;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
