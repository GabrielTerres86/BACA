begin
  delete crapsda
  where  cdcooper = 8
    and  dtmvtolt between to_date('08/08/2021','DD/MM/YYYY') and to_date('31/08/2021','DD/MM/YYYY');
commit;
end;
