--INC0038020 - Ajustar datas contratos TR Viacredi
--Ana Volles - 31/01/2020

BEGIN
  --Viacredi
  update crapepr e set e.dtdpagto = to_date('25/12/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1900528 and  nrctremp = 777054;
  update crapepr e set e.dtdpagto = to_date('20/11/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3788750 and  nrctremp = 471324;
  update crapepr e set e.dtdpagto = to_date('20/02/2020','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3574121 and  nrctremp = 451537;
  update crapepr e set e.dtdpagto = to_date('15/02/2020','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 847917  and  nrctremp = 292150;
  update crapepr e set e.dtdpagto = to_date('20/02/2020','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3794644 and  nrctremp = 1006620;
  update crapepr e set e.dtdpagto = to_date('20/02/2020','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3794644 and  nrctremp = 1006413;
  update crapepr e set e.dtdpagto = to_date('10/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 7546831 and  nrctremp = 1015650;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;







