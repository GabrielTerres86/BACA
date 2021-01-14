--INC0053489 - Ajustar datas contratos TR Viacredi
BEGIN
  --Viacredi
update crapepr e set e.dtdpagto = to_date('20/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 1846108 and e.nrctremp = 264820;
update crapepr e set e.dtdpagto = to_date('25/05/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 90054970 and e.nrctremp = 284907;
update crapepr e set e.dtdpagto = to_date('20/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8023298 and e.nrctremp = 982474;
update crapepr e set e.dtdpagto = to_date('22/05/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2117266 and e.nrctremp = 473510;
update crapepr e set e.dtdpagto = to_date('22/05/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3672409 and e.nrctremp = 473448;
update crapepr e set e.dtdpagto = to_date('22/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2117266 and e.nrctremp = 473526;
update crapepr e set e.dtdpagto = to_date('15/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 1884964 and e.nrctremp = 604566;
update crapepr e set e.dtdpagto = to_date('10/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2152231 and e.nrctremp = 782285;
update crapepr e set e.dtdpagto = to_date('10/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 7763409 and e.nrctremp = 1256574;
update crapepr e set e.dtdpagto = to_date('10/07/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8667683 and e.nrctremp = 911566;

COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
