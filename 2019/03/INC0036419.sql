--========================================================================================--

BEGIN

update crapepr e set e.dtdpagto = to_date('25/01/2019','DD/MM/YYYY') where cdcooper = 1 and nrdconta = 1900528 and  nrctremp = 777054;

	
END;
/
COMMIT;