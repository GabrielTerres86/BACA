begin
  update craplcm l
     set l.dtmvtolt = to_date('03/10/2022', 'mm/dd/rrrr')
   where l.cdhistor = 3852
     and l.nrdconta in (194301, 66958, 284262, 113565)
     and l.cdcooper = 14;
  commit;
end;
/
