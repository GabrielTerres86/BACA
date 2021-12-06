begin

delete craplcm
where  cdcooper = 5
  and  dtmvtolt = to_date('01/11/2021','DD/MM/YYYY')
  and  cdhistor = 524;
  
commit;
end;  
