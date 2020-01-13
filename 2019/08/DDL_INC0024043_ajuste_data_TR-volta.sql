--INC0024043 - ajustar datas contratos TR Viacredi - volta
--Ana Volles - 30/08/2019

BEGIN
  update crapepr e set e.dtdpagto = to_date('25/04/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1900528 and  nrctremp = 777054;
	
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
