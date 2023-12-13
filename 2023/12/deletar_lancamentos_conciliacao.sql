begin
   delete from craplcm a
   WHERE cdcooper = 8
   AND nrdconta in (99968258, 99969505)
   and cdhistor in (2937,2936,2967,2969);
   commit;
 end;

  begin
   delete from craplcm a
   WHERE cdcooper = 3
   AND nrdconta in (99999862)
   and a.dtmvtolt >to_date('10/12/2023', 'dd/mm/yyyy')
   commit;
 end;