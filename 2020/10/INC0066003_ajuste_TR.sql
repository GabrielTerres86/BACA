BEGIN
  --Viacredi
	update crapepr e set e.dtdpagto = to_date('15/10/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 971456 and e.nrctremp = 153934;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;