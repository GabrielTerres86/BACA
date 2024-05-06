begin
   delete   FROM craplcm lcm
    WHERE lcm.cdcooper = 3
    AND lcm.nrdconta = 99999862
    AND lcm.dtmvtolt > to_date('01/01/2024', 'dd/mm/yyyy')
    AND lcm.cdhistor IN (2939, 2940, 2941, 3240);
   commit;
 end;  