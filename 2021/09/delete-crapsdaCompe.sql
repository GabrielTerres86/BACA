begin
  delete crapsda
  where  cdcooper = 8
    and (dtmvtolt = to_date('02/08/2021','DD/MM/YYYY')
      or dtmvtolt = to_date('03/08/2021','DD/MM/YYYY')
      or dtmvtolt = to_date('04/08/2021','DD/MM/YYYY')
      or dtmvtolt = to_date('05/08/2021','DD/MM/YYYY')
      or dtmvtolt = to_date('06/08/2021','DD/MM/YYYY'));
commit;
end;
