begin

 update cecred.crapass set dtadmiss = to_date('03/11/2023','dd/mm/yyyy')
  where cdcooper = 12
    and nrdconta = 216674;
	
 commit;
end;
/