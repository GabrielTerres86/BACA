begin
  delete crapsda
  where  cdcooper = 8
    and  dtmvtolt = to_date('30/07/2021','DD/MM/YYYY');
commit;
end;
