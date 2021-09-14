begin
  
delete crapsda 
where cdcooper = 14 
  and dtmvtolt between to_date('03/08/2021','DD/MM/YYYY') 
                   and to_date('30/08/2021','DD/MM/YYYY');

commit;

end;
