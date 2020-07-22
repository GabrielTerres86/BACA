--INC0047523 - Ajustar datas contratos TR Viacredi
--Ana Volles - 30/04/2020
BEGIN
  --Viacredi
update crapepr e set e.dtdpagto = to_date('25/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 2836866 and e.nrctremp = 482186;
update crapepr e set e.dtdpagto = to_date('20/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 6637914 and e.nrctremp = 992383;
update crapepr e set e.dtdpagto = to_date('15/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 6855261 and e.nrctremp = 471293;
update crapepr e set e.dtdpagto = to_date('15/05/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 6559433 and e.nrctremp = 334134;
update crapepr e set e.dtdpagto = to_date('20/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta = 6218369 and e.nrctremp = 280021;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
