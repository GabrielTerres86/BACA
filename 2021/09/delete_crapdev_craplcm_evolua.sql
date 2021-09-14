begin
  
delete crapdev
  where  cdcooper = 14;
commit;

delete craplcm
  where  cdcooper = 14
  and  dtmvtolt = to_date('03/08/2021','DD/MM/YYYY');
commit;
 
end;
