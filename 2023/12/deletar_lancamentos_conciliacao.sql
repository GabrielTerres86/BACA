begin
   delete from craplcm 
   where nrdconta =  99999862 
   and dtmvtolt > to_date('01/01/2024', 'dd/mm/yyyy')
   and cdcooper = 3;
   commit;
 end;