begin
  delete gncvuni
  where  cdcooper = 1
    and  dtmvtolt = to_date('29/06/2021','DD/MM/YYYY')
    and  tpdcontr = 2;
commit;
end;
