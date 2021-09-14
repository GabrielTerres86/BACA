begin
  
delete crapsda 
where cdcooper = 14 
  and dtmvtolt = to_date('02/08/2021','DD/MM/YYYY');

commit;

end;
