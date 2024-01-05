begin
   delete from craplcm a
   where a.nrdconta =  99999862 
   and a.dtmvtolt > to_date('01/01/2024', 'dd/mm/yyyy')
   and a.cdcooper = 3;
   commit;
 end;   