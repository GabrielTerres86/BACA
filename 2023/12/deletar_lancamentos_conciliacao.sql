 begin
   delete from craplcm a
   WHERE cdcooper = 8
   AND nrdconta = 99939673
   and cdhistor in (2937,2936,2967,2969);
   commit;
 
 end;
