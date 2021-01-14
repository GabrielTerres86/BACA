BEGIN
  --Viacredi
	update crapepr e set e.dtdpagto = to_date('25/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 7794711 and e.nrctremp = 613194;
	update crapepr e set e.dtdpagto = to_date('10/09/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 8639973 and e.nrctremp = 1449590;
	update crapepr e set e.dtdpagto = to_date('23/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 7004915 and e.nrctremp = 987337;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;