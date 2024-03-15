begin
	DELETE
	  from crapsda a 
	  where a.cdcooper = 13
	  and a.dtmvtolt >= to_date('08/03/2024','dd/mm/yyyy');
	commit;
end;