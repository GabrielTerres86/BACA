begin
   delete from craplcm 
WHERE cdcooper = 3
   AND nrdconta = 99999862
   AND dtmvtolt = to_date('19/12/2023', 'dd/mm/yyyy');
   commit;
 end;