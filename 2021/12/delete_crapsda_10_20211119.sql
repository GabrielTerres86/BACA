begin

delete crapsda 
where  cdcooper = 10
  and  dtmvtolt >= to_date('19/11/2021','DD/MM/YYYY');
  
commit;
end;