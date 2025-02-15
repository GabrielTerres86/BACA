--INC0026468 - Ajustar datas contratos TR Viacredi
--Ana Volles - 30/09/2019

BEGIN
  --Viacredi
  update crapepr e set e.dtdpagto = to_date('20/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 2729890  and  nrctremp = 281545;
  update crapepr e set e.dtdpagto = to_date('22/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3672409  and  nrctremp = 473448;
  update crapepr e set e.dtdpagto = to_date('10/10/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 9679979  and  nrctremp = 1295667;
  update crapepr e set e.dtdpagto = to_date('10/10/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 80097197 and  nrctremp = 1503087;
  update crapepr e set e.dtdpagto = to_date('20/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1200046  and  nrctremp = 553548;
  update crapepr e set e.dtdpagto = to_date('22/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 90054970 and  nrctremp = 284907;

  update crapepr e set e.dtdpagto = to_date('05/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 3869237 and  nrctremp = 997429;
  update crapepr e set e.dtdpagto = to_date('25/07/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1900528 and  nrctremp = 777054;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
      
