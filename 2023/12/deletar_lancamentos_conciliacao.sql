begin
     delete from craplcm a
   WHERE cdcooper = 3
   AND nrdconta in (99999862)
   and a.dtmvtolt > to_date('10/12/2023', 'dd/mm/yyyy');
   commit;
 end;