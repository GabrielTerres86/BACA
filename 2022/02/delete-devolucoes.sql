begin
  
delete crapdev v 
where v.cdcooper in (3, 8);

commit;

delete gncpchq 
where dtmvtolt = to_date('21/01/2022','DD/MM/YYYY') 
  and cdcooper = 8;
  
commit;

delete craplcm 
where  cdcooper = 8 
  and dtmvtolt = to_date('21/01/2022','DD/MM/YYYY') 
  and cdhistor = 524;
  
commit; 
end;
