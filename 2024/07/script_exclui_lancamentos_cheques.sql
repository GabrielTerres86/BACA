begin 
  
delete cecred.craplcm
 where cdcooper = 12
   and dtmvtolt = to_date('24/06/2024','dd/mm/yyyy')
   and nrdconta = 82921288
   and cdhistor = 524
   and progress_recid >= 2323338386;

commit;

end;


