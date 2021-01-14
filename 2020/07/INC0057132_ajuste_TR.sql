--INC0053489 - Ajustar datas contratos TR Viacredi
BEGIN
  --Viacredi
update crapepr e set e.dtdpagto = to_date('25/05/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2836866 and e.nrctremp = 482186;
update crapepr e set e.dtdpagto = to_date('10/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6637914 and e.nrctremp = 992383;
update crapepr e set e.dtdpagto = to_date('15/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 6072470 and e.nrctremp = 696577;
update crapepr e set e.dtdpagto = to_date('20/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3794644 and e.nrctremp = 1006620;
update crapepr e set e.dtdpagto = to_date('20/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3794644 and e.nrctremp = 1006413;
update crapepr e set e.dtdpagto = to_date('20/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3645681 and e.nrctremp = 262726;
update crapepr e set e.dtdpagto = to_date('20/08/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2089262 and e.nrctremp = 403174;
update crapepr e set e.dtdpagto = to_date('25/06/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 80005608 and e.nrctremp = 288560;

COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
