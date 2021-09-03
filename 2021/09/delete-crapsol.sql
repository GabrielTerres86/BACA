begin
  delete crapsol
  where  cdcooper = 8
    and  dtrefere = to_date('16/07/2021','DD/MM/YYYY')
      or dtrefere = to_date('25/08/2021','DD/MM/YYYY');
commit;
end;
