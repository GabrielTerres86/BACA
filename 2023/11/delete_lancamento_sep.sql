BEGIN
  DELETE FROM craplcm lcm
   WHERE lcm.cdhistor IN (2936, 2937, 2967)
     AND lcm.cdcooper = 8
     AND lcm.dtmvtolt = to_date('23/11/2023', 'dd/mm/yyyy');

  DELETE FROM craplcm lcm
   WHERE lcm.cdhistor = 2941
     AND lcm.cdcooper = 3
     AND lcm.dtmvtolt = to_date('27/11/2023', 'dd/mm/yyyy');

  COMMIT;
END;
