begin
	UPDATE cecred.crapsld 
	   SET dtrefere = to_date('15/03/2024','dd/mm/yyyy') 
	 WHERE cdcooper = 13 
	   AND nrdconta = 99874954;
	commit;
end;