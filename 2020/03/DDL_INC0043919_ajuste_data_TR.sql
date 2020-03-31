--INC0043769 - Ajustar datas contratos TR Viacredi
--Ana Volles - 31/03/2020

BEGIN
  --Viacredi
update crapepr e set e.dtdpagto = to_date('10/04/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2152231 and e.nrctremp = 	782285;
update crapepr e set e.dtdpagto = to_date('08/09/2019','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	6828167 and e.nrctremp = 	69768;
update crapepr e set e.dtdpagto = to_date('05/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2452537 and e.nrctremp = 	298673;
update crapepr e set e.dtdpagto = to_date('10/01/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2887754 and e.nrctremp = 	627873;
update crapepr e set e.dtdpagto = to_date('20/03/2020','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	2998149 and e.nrctremp = 	31066;
update crapepr e set e.dtdpagto = to_date('15/12/2019','DD/MM/YYYY') where cdcooper = 1 and e.nrdconta =	8225915 and e.nrctremp = 	1195867;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
